#include "boot_image.h"
#include "bytecode.h"
#include "coder.h"
#include "host_inputs.h"
#include "reader.h"
#include "thumb.h"
#include "verifier.h"
#include "vm_types.h"

#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { IMAGE_BASE = 0x10000000, IMAGE_CAPACITY = 16 << 20,
       NATIVE_BASE = 0x20000000, GLOBAL_BASE = 0x30000000, FIELD_BASE = 0x40000000,
       FIELD_STRIDE = 64, /* Thumb static loads share addresses only within 64-byte groups. */
       STATIC_CAPACITY = 65536, FIRST_CLASS_ID = 1024 };

typedef struct Name {
    uint8_t *bytes;
    size_t length;
    uint16_t id;
} Name;

typedef struct Names {
    Name *entries;
    size_t count;
} Names;

typedef struct Type {
    JbedClass klass;
    char *name;
    bool defined, preparing, prepared;
    bool has_layout, signature_only;
    bool has_initializer_order;
    uint32_t initializer_order;
    uint32_t instance_size, original_flags;
    struct FieldLayout *fields;
    struct MissingMethod *missing_methods;
} Type;

typedef struct MissingMethod {
    char *name, *descriptor;
    uint32_t flags;
    struct MissingMethod *next;
} MissingMethod;

typedef struct FieldLayout {
    char *name, *descriptor;
    uint8_t storage;
    uint32_t offset, flags;
    struct FieldLayout *next;
} FieldLayout;

typedef struct ClassInput {
    const uint8_t *data;
    size_t length, position;
    char **utf8;
    uint16_t constants;
    const char *owner, *method, *descriptor;
    bool unavailable;
    struct Host *host;
} ClassInput;

typedef struct LabelFixup {
    uint32_t site, label;
    bool call;
} LabelFixup;

typedef struct NativeBinding {
    char *owner, *name, *descriptor, *symbol;
    int convention; /* -1 denotes a managed-ABI symbol. */
} NativeBinding;

typedef struct BoundNative {
    const NativeBinding *binding;
    uint32_t flags;
} BoundNative;

typedef struct FieldBinding {
    char *owner, *name, *descriptor, *symbol;
} FieldBinding;

typedef struct Property {
    JbedPoolString *key, *value;
} Property;

typedef struct Host {
    JbedRuntime runtime;
    JbedEmitter emitter;
    JbedSignatureEncoder signatures;
    JbedSignatureServices signature_services;
    JbedPoolServices pool_services;
    JbedWriter writer;
    JbedWriterOps writer_ops;
    JbedWriterServices writer_services;
    JbedBuffer buffer;
    JbedReaderLayout layout;
    Type **types;
    size_t type_count;
    JbedTypeId next_type;
    Names methods, fields, packages, bases, signature_names;
    JbedBootRelocation *relocations;
    size_t relocation_count;
    LabelFixup *fixups;
    size_t fixup_count;
    const char **natives;
    size_t native_count;
    uint32_t stack_maps;
    uint32_t class_index, package_table, base_table, method_table, field_table, signature_table;
    uint32_t globals_size, statics_size;
    uint32_t sync_slots, intern_table;
    JbedPoolString **strings;
    size_t string_count;
    Property *property_entries;
    size_t property_count;
    uint32_t properties;
    uint32_t initializers, initializer_count, main_method;
    NativeBinding *bindings;
    size_t binding_count;
    BoundNative *native_methods;
    size_t native_method_count;
    FieldBinding *field_bindings;
    size_t field_binding_count;
    const FieldBinding **bound_fields;
    size_t bound_field_count;
    bool check_bindings;
    bool generating_code;
    const char **source_classes;
    size_t source_class_count;
    size_t missing_bodies, missing_natives;
    jmp_buf *handler;
    JbedError error;
} Host;

static _Noreturn void die(const char *message)
{
    fprintf(stderr, "jbedrom: %s\n", message);
    exit(EXIT_FAILURE);
}

static void *allocate(void *context, size_t bytes)
{
    (void)context;
    void *p = calloc(1, bytes ? bytes : 1);
    if (!p) die("out of memory");
    return p;
}

static void *resize(void *p, size_t bytes)
{
    p = realloc(p, bytes);
    if (!p) die("out of memory");
    return p;
}

static char *copy_string(const uint8_t *s, size_t length)
{
    char *p = allocate(NULL, length + 1);
    memcpy(p, s, length);
    return p;
}

static void raise_error(void *context, const JbedError *error)
{
    Host *h = context;
    h->error = *error;
    if (h->handler) longjmp(*h->handler, 1);
    fprintf(stderr, "jbedrom: error %u at bytecode %d: %s\n", error->kind,
            error->bytecode_offset, error->message ? error->message : "compilation failed");
    exit(EXIT_FAILURE);
}

static void halt(void *context, int32_t code, const char *message)
{
    (void)context; (void)code;
    die(message);
}

static bool protect(void *context, void (*body)(void *), void *argument, JbedError *error)
{
    Host *h = context;
    jmp_buf local;
    jmp_buf *previous = h->handler;
    h->handler = &local;
    if (setjmp(local)) {
        *error = h->error;
        h->handler = previous;
        return false;
    }
    body(argument);
    h->handler = previous;
    return true;
}

static uint16_t intern(Names *table, const uint8_t *bytes, size_t length, bool create)
{
    for (size_t i = 0; i < table->count; ++i)
        if (table->entries[i].length == length &&
            !memcmp(table->entries[i].bytes, bytes, length))
            return table->entries[i].id;
    if (!create) return 0;
    uint32_t hash = 0;
    for (size_t i = 0; i < length; ++i) hash = 31 * hash + bytes[i];
    uint16_t bucket = (uint16_t)(hash & 2047), id = 0;
    for (unsigned probe = 0; probe < 2048; ++probe, bucket = (bucket + 1) & 2047) {
        unsigned count = 0;
        for (size_t i = 0; i < table->count; ++i)
            if ((table->entries[i].id >> 4) == bucket) ++count;
        if (count < 15) { id = (uint16_t)(bucket * 16 + count + 1); break; }
    }
    if (!id) die("too many boot-image names");
    table->entries = resize(table->entries, (table->count + 1) * sizeof(*table->entries));
    table->entries[table->count++] = (Name){(uint8_t *)copy_string(bytes, length), length, id};
    return id;
}

static Name *find_name(Names *table, uint16_t id)
{
    for (size_t i = 0; i < table->count; ++i)
        if (table->entries[i].id == id) return &table->entries[i];
    return NULL;
}

static Type *type_by_id(Host *h, JbedTypeId id)
{
    for (size_t i = 0; i < h->type_count; ++i)
        if (h->types[i]->klass.id == id) return h->types[i];
    return NULL;
}

static uint32_t reserved_class(const char *name)
{
    static const struct { const char *name; uint32_t id; } reserved[] = {
        {"java/lang/Object", JBED_ROM_CLASS_OBJECT}, {"java/lang/Class", JBED_ROM_CLASS_CLASS},
        {"java/lang/String", JBED_ROM_CLASS_STRING}, {"java/lang/Throwable", JBED_ROM_CLASS_THROWABLE},
        {"[Ljava/lang/Object;", JBED_ROM_CLASS_OBJECT_ARRAY},
        {"[Z", JBED_ROM_CLASS_BOOLEAN_ARRAY}, {"[B", JBED_ROM_CLASS_BYTE_ARRAY},
        {"[C", JBED_ROM_CLASS_CHAR_ARRAY}, {"[S", JBED_ROM_CLASS_SHORT_ARRAY},
        {"[I", JBED_ROM_CLASS_INT_ARRAY}, {"[J", JBED_ROM_CLASS_LONG_ARRAY},
        {"[F", JBED_ROM_CLASS_FLOAT_ARRAY}, {"[D", JBED_ROM_CLASS_DOUBLE_ARRAY}
    };
    for (size_t i = 0; i < sizeof(reserved) / sizeof(*reserved); ++i)
        if (!strcmp(name, reserved[i].name)) return reserved[i].id;
    return 0;
}

static Type *primitive_type(Host *h, JbedTypeId id)
{
    Type *t = type_by_id(h, id);
    if (t) return t;
    if (id < JBED_TYPE_BOOLEAN || id > JBED_TYPE_LONG) die("invalid primitive type");
    t = allocate(NULL, sizeof(*t));
    t->name = copy_string((const uint8_t *)"ZCFDBSIJ" + id - JBED_TYPE_BOOLEAN, 1);
    t->klass = (JbedClass){.id = id, .base_id = (uint16_t)id,
        .flags = JBED_CLASS_PRIMITIVE | JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE |
                 JBED_ACC_PUBLIC | JBED_ACC_FINAL,
        .instance_size = 1 << (id & 3)};
    t->defined = t->prepared = true;
    h->types = resize(h->types, (h->type_count + 1) * sizeof(*h->types));
    h->types[h->type_count++] = t;
    return t;
}

static Type *type_named(Host *h, const char *name)
{
    for (size_t i = 0; i < h->type_count; ++i)
        if (!(h->types[i]->klass.flags & JBED_CLASS_PRIMITIVE) &&
            !strcmp(h->types[i]->name, name)) return h->types[i];
    Type *t = allocate(NULL, sizeof(*t));
    t->name = copy_string((const uint8_t *)name, strlen(name));
    t->klass.id = reserved_class(name);
    if (!t->klass.id) t->klass.id = h->next_type++;
    t->klass.flags = JBED_CLASS_DYNAMIC;
    if (*name != '[') {
        const char *slash = strrchr(name, '/');
        if (slash) t->klass.package_id = intern(&h->packages, (const uint8_t *)name,
                                               (size_t)(slash - name), true);
        const char *base = slash ? slash + 1 : name;
        t->klass.base_id = intern(&h->bases, (const uint8_t *)base, strlen(base), true);
    }
    h->types = resize(h->types, (h->type_count + 1) * sizeof(*h->types));
    h->types[h->type_count++] = t;
    if (*name == '[') {
        const char *component = name + 1;
        Type *element;
        if (*component == 'L') {
            char *plain = copy_string((const uint8_t *)component + 1, strlen(component) - 2);
            element = type_named(h, plain);
            free(plain);
        } else if (*component == '[') element = type_named(h, component);
        else {
            const char *primitive = strchr("ZCFDBSIJ", *component);
            if (!primitive || component[1]) die("invalid primitive array descriptor");
            element = primitive_type(h, (JbedTypeId)(primitive - "ZCFDBSIJ") + JBED_TYPE_BOOLEAN);
        }
        t->klass.flags |= JBED_CLASS_ARRAY | JBED_CLASS_INSTANTIABLE |
                          JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE | JBED_ACC_PUBLIC |
                          JBED_ACC_FINAL | JBED_ACC_ABSTRACT;
        t->klass.superclass = &element->klass;
        t->klass.package_id = element->klass.package_id;
        t->klass.base_id = element->klass.base_id;
        t->klass.array_dimensions = element->klass.array_dimensions + 1;
        t->klass.instance_size = 16;
        t->klass.depth = 1;
        t->defined = true;
    }
    return t;
}

static JbedTypeId class_id(void *context, const uint8_t *bytes, uint32_t start, uint32_t end,
                           uint32_t slash, uint32_t dimensions)
{
    (void)slash;
    Host *h = context;
    size_t length = end - start;
    char *name = allocate(NULL, dimensions + length + 3);
    memset(name, '[', dimensions);
    size_t pos = dimensions;
    if (dimensions) name[pos++] = 'L';
    memcpy(name + pos, bytes + start, length);
    if (dimensions) name[pos + length] = ';';
    JbedTypeId id = type_named(h, name)->klass.id;
    free(name);
    return id;
}

static JbedTypeId primitive_array(void *context, JbedTypeId primitive, uint32_t dimensions)
{
    if (primitive < 4 || primitive > 11 || dimensions > 255) die("invalid primitive array");
    if (!dimensions) return primitive_type(context, primitive)->klass.id;
    char name[257];
    memset(name, '[', dimensions);
    name[dimensions] = "ZCFDBSIJ"[primitive - 4];
    name[dimensions + 1] = 0;
    return type_named(context, name)->klass.id;
}

static bool pool_class_id(void *context, const uint8_t *bytes, size_t start, size_t end,
                           size_t slash, uint16_t dimensions, JbedTypeId *id, JbedError *error)
{
    (void)error;
    *id = class_id(context, bytes, (uint32_t)start, (uint32_t)end, (uint32_t)slash, dimensions);
    return true;
}

static bool pool_primitive_array(void *context, JbedTypeId primitive, uint16_t dimensions,
                                 JbedTypeId *id, JbedError *error)
{
    (void)error;
    *id = primitive_array(context, primitive, dimensions);
    return true;
}

static JbedTypeId array_of(void *context, JbedTypeId id)
{
    Host *h = context;
    Type *component = type_by_id(h, id);
    if (!component) die("unknown array component");
    if (component->klass.flags & JBED_CLASS_PRIMITIVE) return primitive_array(h, id, 1);
    if (component->klass.flags & JBED_CLASS_ARRAY) {
        char *name = allocate(NULL, strlen(component->name) + 2);
        name[0] = '[';
        strcpy(name + 1, component->name);
        Type *t = type_named(h, name);
        free(name);
        return t->klass.id;
    }
    return class_id(h, (const uint8_t *)component->name, 0, (uint32_t)strlen(component->name), 0, 1);
}

static bool pool_array_of(void *context, JbedTypeId id, JbedTypeId *out, JbedError *error)
{
    (void)error;
    *out = array_of(context, id);
    return true;
}

static const char *class_name(void *context, JbedTypeId id)
{
    Type *t = type_by_id(context, id);
    return t ? t->name : "<missing class>";
}

static const char *signature_class_name(void *context, JbedTypeId id, bool *array)
{
    Type *t = type_by_id(context, id);
    *array = t && (t->klass.flags & JBED_CLASS_ARRAY);
    return t ? t->name : NULL;
}

static const char *method_name(void *context, JbedNameId id)
{
    Name *n = find_name(&((Host *)context)->methods, id);
    return n ? (const char *)n->bytes : "<missing method>";
}

static const char *field_name(void *context, JbedNameId id)
{
    Name *n = find_name(&((Host *)context)->fields, id);
    return n ? (const char *)n->bytes : "<missing field>";
}

static const char *signature_name(void *context, JbedSignatureId id)
{
    return jbed_signature_descriptor(jbed_signature_copy_if_busy(&((Host *)context)->signatures), id);
}

static uint8_t name_first(void *context, JbedNameId id)
{
    return (uint8_t)method_name(context, id)[0];
}

static bool pool_name(void *context, bool method, const uint8_t *bytes, size_t length,
                       bool create, JbedNameId *id, JbedError *error)
{
    (void)error;
    Host *h = context;
    *id = intern(method ? &h->methods : &h->fields, bytes, length, create);
    return true;
}

static JbedSignatureId signature_intern(void *context, const uint8_t *bytes, size_t length)
{
    return intern(&((Host *)context)->signature_names, bytes, length, true);
}

static int32_t signature_fetch(void *context, JbedSignatureId id, uint8_t *bytes, size_t size)
{
    Name *n = find_name(&((Host *)context)->signature_names, id);
    if (!n) return -1;
    if (size >= n->length) memcpy(bytes, n->bytes, n->length);
    return (int32_t)n->length;
}

static JbedClass *get_class(void *context, JbedTypeId id)
{
    Type *t = type_by_id(context, id);
    return t ? &t->klass : NULL;
}

static bool load_class(void *context, JbedTypeId id, JbedClass **klass, JbedError *error)
{
    Type *t = type_by_id(context, id);
    if (!t || !t->defined) {
        *error = (JbedError){.kind = JBED_ERROR_NO_CLASS_DEF, .is_java_error = true,
                             .class_id = id, .message = class_name(context, id)};
        return false;
    }
    *klass = &t->klass;
    return true;
}

static bool package_id(void *context, JbedTypeId id, uint16_t *package, JbedError *error)
{
    (void)error;
    *package = get_class(context, id)->package_id;
    return true;
}

static int32_t array_level(void *context, JbedTypeId id)
{
    JbedClass *c = get_class(context, id);
    return c ? c->array_dimensions : 0;
}

static void writer_fault(void *context, JbedWriterFault fault, const char *message)
{
    (void)context; (void)fault;
    die(message);
}

static Host *writer_host(JbedWriter *w) { return w->services->context; }

static uint8_t *image_at(JbedWriter *w, uint32_t address, uint32_t size)
{
    Host *h = writer_host(w);
    if (address < IMAGE_BASE || address - IMAGE_BASE > h->buffer.size ||
        size > h->buffer.size - (address - IMAGE_BASE)) die("boot image exceeds its address space");
    return h->buffer.data + address - IMAGE_BASE;
}

static void word(JbedWriter *w, uint32_t address, uint32_t value)
{
    uint8_t *p = image_at(w, address, 4);
    for (unsigned i = 0; i < 4; ++i) p[i] = (uint8_t)(value >> (8 * i));
}

static void half(JbedWriter *w, uint32_t address, uint16_t value)
{
    uint8_t *p = image_at(w, address, 2);
    p[0] = (uint8_t)value; p[1] = (uint8_t)(value >> 8);
}

static void byte(JbedWriter *w, uint32_t address, uint8_t value) { *image_at(w, address, 1) = value; }
static uint32_t get_word(JbedWriter *w, uint32_t address)
{
    uint8_t *p = image_at(w, address, 4);
    return p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static int16_t get_half(JbedWriter *w, uint32_t address)
{
    uint8_t *p = image_at(w, address, 2);
    return (int16_t)(p[0] | (uint16_t)p[1] << 8);
}

static void relocation(Host *h, uint32_t site, uint32_t target, JbedBootRelocationKind kind)
{
    for (size_t i = 0; i < h->relocation_count; ++i)
        if (h->relocations[i].offset == site - IMAGE_BASE) {
            h->relocations[i] = (JbedBootRelocation){site - IMAGE_BASE, target, kind};
            return;
        }
    h->relocations = resize(h->relocations, (h->relocation_count + 1) * sizeof(*h->relocations));
    h->relocations[h->relocation_count++] = (JbedBootRelocation){site - IMAGE_BASE, target, kind};
}

static void clear_relocation(Host *h, uint32_t site)
{
    for (size_t i = 0; i < h->relocation_count; ++i)
        if (h->relocations[i].offset == site - IMAGE_BASE) {
            h->relocations[i] = h->relocations[--h->relocation_count];
            return;
        }
}

static void pointer(JbedWriter *w, uint32_t address, uint32_t value)
{
    Host *h = writer_host(w);
    if (value >= NATIVE_BASE && (value - NATIVE_BASE) / 4 < h->native_count)
        relocation(h, address, (value - NATIVE_BASE) / 4, JBED_BOOT_NATIVE_POINTER);
    else if (value >= IMAGE_BASE && value - IMAGE_BASE < IMAGE_CAPACITY)
        relocation(h, address, value - IMAGE_BASE, JBED_BOOT_IMAGE_POINTER);
    else if (value >= GLOBAL_BASE && value - GLOBAL_BASE < h->globals_size)
        relocation(h, address, value - GLOBAL_BASE, JBED_BOOT_GLOBAL_POINTER);
    else if (value >= FIELD_BASE && !((value - FIELD_BASE) % FIELD_STRIDE) &&
             (value - FIELD_BASE) / FIELD_STRIDE < h->bound_field_count)
        relocation(h, address, (value - FIELD_BASE) / FIELD_STRIDE, JBED_BOOT_RUNTIME_FIELD_POINTER);
    else if (value) die("unresolved pointer in boot image");
    else clear_relocation(h, address);
    word(w, address, 0);
}

static void put_reloc(JbedWriter *w, uint32_t address, uint32_t value, bool resident)
{
    (void)resident;
    pointer(w, address, value);
}

static void put_call(JbedWriter *w, uint32_t address, uint32_t value, bool resident)
{
    (void)resident;
    Host *h = writer_host(w);
    uint32_t target = jbed_thumb_call_destination(address, value);
    if (target >= NATIVE_BASE && (target - NATIVE_BASE) / 4 < h->native_count)
        relocation(h, address, (target - NATIVE_BASE) / 4, JBED_BOOT_NATIVE_THUMB_CALL);
    else if (target < IMAGE_BASE || target - IMAGE_BASE >= IMAGE_CAPACITY)
        die("unresolved call in boot image");
    else clear_relocation(h, address);
    word(w, address, value);
}

static uint32_t allocate_code(JbedWriter *w, JbedCodeOwner *owner, uint32_t bytes, uint32_t maximum)
{
    (void)maximum;
    image_at(w, w->cursor, bytes);
    w->owner = owner;
    return w->cursor;
}

static uint32_t allocate_data(JbedWriter *w, JbedCodeOwner *owner, uint32_t bytes)
{
    uint32_t address = allocate_code(w, owner, bytes, bytes);
    w->cursor = (w->cursor + bytes + 3) & ~3u;
    return address;
}

static void flush_code(JbedWriter *w, JbedCodeOwner *owner, uint32_t end)
{
    (void)owner;
    image_at(w, end, 0);
    w->cursor = (end + 3) & ~3u;
}

static void write_block(JbedWriter *w, uint32_t address, const uint8_t *bytes, uint32_t size)
{
    memcpy(image_at(w, address, size), bytes, size);
}

static uint32_t label_fixup(JbedWriter *w, uint32_t address, uint32_t label, bool call)
{
    Host *h = writer_host(w);
    if (!label) label = jbed_writer_get_label(w);
    h->fixups = resize(h->fixups, (h->fixup_count + 1) * sizeof(*h->fixups));
    h->fixups[h->fixup_count++] = (LabelFixup){address, label, call};
    return label;
}

static uint32_t write_label(JbedWriter *w, uint32_t address, uint32_t label)
{
    return label_fixup(w, address, label, false);
}

static uint32_t write_call_label(JbedWriter *w, uint32_t address, uint32_t instruction, uint32_t label)
{
    (void)instruction;
    return label_fixup(w, address, label, true);
}

static void cleanup_writer(JbedWriter *w) { (void)w; }

static uint32_t native(Host *h, const char *name)
{
    for (size_t i = 0; i < h->native_count; ++i)
        if (!strcmp(h->natives[i], name)) return NATIVE_BASE + 4 * (uint32_t)i + 1;
    h->natives = resize(h->natives, (h->native_count + 1) * sizeof(*h->natives));
    h->natives[h->native_count] = name;
    return NATIVE_BASE + 4 * (uint32_t)h->native_count++ + 1;
}

static const NativeBinding *binding(Host *h, const char *owner, const char *name, const char *descriptor)
{
    for (size_t i = 0; i < h->binding_count; ++i) {
        NativeBinding *b = &h->bindings[i];
        if (!strcmp(b->owner, owner) && !strcmp(b->name, name) && !strcmp(b->descriptor, descriptor))
            return b;
    }
    return NULL;
}

static bool source_class(const Host *h, const char *name)
{
    for (size_t i = 0; i < h->source_class_count; ++i)
        if (!strcmp(h->source_classes[i], name)) return true;
    return false;
}

static bool identifier(const char *name)
{
    if (!*name) return false;
    for (const char *p = name; *p; ++p)
        if (!((*p >= 'a' && *p <= 'z') || (*p >= 'A' && *p <= 'Z') || *p == '_' ||
              (p != name && *p >= '0' && *p <= '9'))) return false;
    return true;
}

static void read_bindings(Host *h, const char *path)
{
    FILE *file = fopen(path, "r");
    if (!file) die("cannot open native bindings");
    char line[8192], owner[1024], name[1024], descriptor[4096], symbol[512], convention[16], extra[2];
    while (fgets(line, sizeof(line), file)) {
        char *comment = strchr(line, '#');
        if (comment) *comment = 0;
        char first[16];
        if (sscanf(line, "%15s", first) == 1 && !strcmp(first, "field")) {
            int fields = sscanf(line, " field %1023s %1023s %4095s %511s %1s",
                                 owner, name, descriptor, symbol, extra);
            if (fields != 4 || !identifier(symbol))
                die("field binding requires: field class name descriptor resolver");
            for (size_t i = 0; i < h->field_binding_count; ++i) {
                FieldBinding *f = &h->field_bindings[i];
                if (!strcmp(f->owner, owner) && !strcmp(f->name, name) &&
                    !strcmp(f->descriptor, descriptor)) die("duplicate field binding");
            }
            h->field_bindings = resize(h->field_bindings,
                (h->field_binding_count + 1) * sizeof(*h->field_bindings));
            h->field_bindings[h->field_binding_count++] = (FieldBinding){
                copy_string((uint8_t *)owner, strlen(owner)), copy_string((uint8_t *)name, strlen(name)),
                copy_string((uint8_t *)descriptor, strlen(descriptor)), copy_string((uint8_t *)symbol, strlen(symbol))};
            continue;
        }
        int fields = sscanf(line, "%1023s %1023s %4095s %511s %15s %1s", owner, name, descriptor,
                             symbol, convention, extra);
        if (fields == EOF) continue;
        if ((fields != 4 && fields != 5) || !identifier(symbol))
            die("native binding requires: class method descriptor symbol [managed|jbni|kni]");
        int abi = -1;
        if (fields == 5) {
            if (!strcmp(convention, "jbni")) abi = JBED_NATIVE_JBNI;
            else if (!strcmp(convention, "kni")) abi = JBED_NATIVE_KNI;
            else if (strcmp(convention, "managed")) die("unknown native binding convention");
        }
        if (binding(h, owner, name, descriptor)) die("duplicate native binding");
        h->bindings = resize(h->bindings, (h->binding_count + 1) * sizeof(*h->bindings));
        h->bindings[h->binding_count++] = (NativeBinding){
            copy_string((uint8_t *)owner, strlen(owner)), copy_string((uint8_t *)name, strlen(name)),
            copy_string((uint8_t *)descriptor, strlen(descriptor)), copy_string((uint8_t *)symbol, strlen(symbol)), abi};
    }
    if (ferror(file)) die("cannot read native bindings");
    fclose(file);
}

static bool intern_string(void *context, const uint16_t *characters, size_t count,
                           JbedPoolString **out, bool *retained, JbedError *error)
{
    (void)error;
    Host *h = context;
    for (size_t i = 0; i < h->string_count; ++i)
        if (h->strings[i]->length == count &&
            !memcmp(h->strings[i]->characters, characters, count * sizeof(*characters))) {
            *out = h->strings[i];
            *retained = false;
            return true;
        }
    type_named(h, "java/lang/String");
    JbedPoolString *s = allocate(NULL, sizeof(*s));
    uint16_t *saved = allocate(NULL, count * sizeof(*saved));
    memcpy(saved, characters, count * sizeof(*saved));
    s->characters = saved;
    s->length = count;
    s->address = allocate_data(&h->writer, NULL, 32);
    uint32_t chars = allocate_data(&h->writer, NULL, (uint32_t)count * 2);
    uint32_t hash = 0;
    for (size_t i = 0; i < count; ++i) {
        half(&h->writer, chars + 2 * (uint32_t)i, saved[i]);
        hash = 31 * hash + saved[i];
    }
    word(&h->writer, s->address + 4, (hash << 8) | 7);
    word(&h->writer, s->address + 8, (uint32_t)(2 * h->string_count + 1));
    pointer(&h->writer, s->address + 16, chars);
    word(&h->writer, s->address + 20, (uint32_t)count);
    byte(&h->writer, s->address + 28, 1);
    h->strings = resize(h->strings, (h->string_count + 1) * sizeof(*h->strings));
    h->strings[h->string_count++] = s;
    *out = s;
    *retained = false;
    return true;
}

static JbedPoolString *property_string(Host *h, const char *text)
{
    const uint8_t *p = (const uint8_t *)text;
    uint16_t *characters = allocate(NULL, (strlen(text) + 1) * sizeof(*characters));
    size_t count = 0;
    while (*p) {
        uint32_t value = *p++;
        if (value >= 0x80) {
            unsigned remaining;
            uint32_t minimum;
            if (value >= 0xc2 && value <= 0xdf) { remaining = 1; minimum = 0x80; value &= 31; }
            else if (value >= 0xe0 && value <= 0xef) { remaining = 2; minimum = 0x800; value &= 15; }
            else if (value >= 0xf0 && value <= 0xf4) { remaining = 3; minimum = 0x10000; value &= 7; }
            else die("invalid UTF-8 in system properties");
            while (remaining--) {
                if ((*p & 0xc0) != 0x80) die("invalid UTF-8 in system properties");
                value = (value << 6) | (*p++ & 63);
            }
            if (value < minimum || value > 0x10ffff || (value >= 0xd800 && value <= 0xdfff))
                die("invalid UTF-8 in system properties");
        }
        if (value >= 0x10000) {
            value -= 0x10000;
            characters[count++] = (uint16_t)(0xd800 + (value >> 10));
            value = 0xdc00 + (value & 1023);
        }
        characters[count++] = (uint16_t)value;
    }
    JbedPoolString *result;
    bool retained;
    JbedError error;
    intern_string(h, characters, count, &result, &retained, &error);
    free(characters);
    return result;
}

static void read_properties(Host *h, const char *path)
{
    FILE *file = fopen(path, "r");
    if (!file) die("cannot open system properties");
    char line[8192];
    while (fgets(line, sizeof(line), file)) {
        size_t length = strlen(line);
        if (length == sizeof(line) - 1 && line[length - 1] != '\n')
            die("system property line is too long");
        while (length && (line[length - 1] == '\n' || line[length - 1] == '\r')) line[--length] = 0;
        char *key = line;
        while (*key == ' ' || *key == '\t') ++key;
        if (!*key || *key == '#' || *key == '!') continue;
        char *value = strchr(key, '=');
        if (!value) die("system property requires key=value");
        char *end = value++;
        while (end > key && (end[-1] == ' ' || end[-1] == '\t')) --end;
        *end = 0;
        if (!*key) die("system property key is empty");
        while (*value == ' ' || *value == '\t') ++value;
        JbedPoolString *name = property_string(h, key), *text = property_string(h, value);
        size_t i = 0;
        while (i < h->property_count && h->property_entries[i].key != name) ++i;
        if (i == h->property_count) {
            h->property_entries = resize(h->property_entries, (i + 1) * sizeof(*h->property_entries));
            ++h->property_count;
        }
        h->property_entries[i] = (Property){name, text};
    }
    if (ferror(file)) die("cannot read system properties");
    fclose(file);
}

static uint32_t reference_array(Host *h, JbedTypeId type, uint32_t length)
{
    uint32_t array = allocate_data(&h->writer, NULL, 16 + 4 * length);
    pointer(&h->writer, array, get_class(h, type)->descriptor_address);
    word(&h->writer, array + 4, 7);
    word(&h->writer, array + 8, 2 * h->sync_slots++ + 1);
    word(&h->writer, array + 12, length);
    return array;
}

static void emit_properties(Host *h)
{
    enum { PROPERTY_BUCKETS = 16 };
    uint32_t counts[PROPERTY_BUCKETS] = {0}, buckets[PROPERTY_BUCKETS] = {0};
    JbedTypeId strings = array_of(h, JBED_ROM_CLASS_STRING);
    h->properties = reference_array(h, array_of(h, strings), PROPERTY_BUCKETS);
    for (size_t i = 0; i < h->property_count; ++i) {
        JbedPoolString *key = h->property_entries[i].key;
        uint32_t hash = 0;
        for (size_t j = 0; j < key->length; ++j) hash = 31 * hash + key->characters[j];
        ++counts[hash & (PROPERTY_BUCKETS - 1)];
    }
    for (unsigned i = 0; i < PROPERTY_BUCKETS; ++i)
        if (counts[i]) {
            buckets[i] = reference_array(h, strings, 2 * counts[i]);
            pointer(&h->writer, h->properties + 16 + 4 * i, buckets[i]);
            counts[i] = 0;
        }
    for (size_t i = 0; i < h->property_count; ++i) {
        Property *entry = &h->property_entries[i];
        uint32_t hash = 0;
        for (size_t j = 0; j < entry->key->length; ++j) hash = 31 * hash + entry->key->characters[j];
        unsigned bucket = hash & (PROPERTY_BUCKETS - 1);
        uint32_t slot = buckets[bucket] + 16 + 8 * counts[bucket]++;
        pointer(&h->writer, slot, entry->key->address);
        pointer(&h->writer, slot + 4, entry->value->address);
    }
}

static uint32_t input_integer(ClassInput *in, unsigned bytes)
{
    if (in->position > in->length || bytes > in->length - in->position) die("truncated class input");
    uint32_t value = 0;
    while (bytes--) value = (value << 8) | in->data[in->position++];
    return value;
}

static void input_skip(ClassInput *in, size_t bytes)
{
    if (in->position > in->length || bytes > in->length - in->position) die("truncated class attribute");
    in->position += bytes;
}

static char *input_utf8(ClassInput *in, uint32_t index)
{
    if (!index || index >= in->constants || !in->utf8[index]) die("invalid attribute name");
    return in->utf8[index];
}

static char *input_text(ClassInput *in)
{
    uint32_t length = input_integer(in, 2);
    size_t start = in->position;
    input_skip(in, length);
    return copy_string(in->data + start, length);
}

static void input_attributes(ClassInput *in, Type *type, FieldLayout *field, bool bound)
{
    uint32_t count = input_integer(in, 2);
    while (count--) {
        const char *name = input_utf8(in, input_integer(in, 2));
        uint32_t size = input_integer(in, 4);
        size_t end = in->position + size;
        if (end < in->position || end > in->length) die("invalid attribute length");
        if (!strcmp(name, "JbedClassLayout") && type && !field) {
            if (size != 14 || input_integer(in, 2) != 1) die("unsupported JbedClassLayout");
            type->has_layout = true;
            uint32_t id = input_integer(in, 4);
            /* Bundle-qualified IDs join this image's local class namespace. */
            if (id <= UINT16_MAX) type->klass.id = id;
            type->instance_size = input_integer(in, 4);
            type->original_flags = input_integer(in, 4);
        } else if (!strcmp(name, "JbedInitializerOrder") && type && !field) {
            if (size != 6 || input_integer(in, 2) != 1) die("unsupported JbedInitializerOrder");
            type->has_initializer_order = true;
            type->initializer_order = input_integer(in, 4);
        } else if (!strcmp(name, "JbedUnresolvedTypes") && type && !field) {
            if (input_integer(in, 2) != 1) die("unsupported JbedUnresolvedTypes");
            unsigned unresolved = input_integer(in, 2);
            while (unresolved--) {
                uint32_t id = input_integer(in, 4);
                char *external_name = input_text(in);
                Type *external = type_named(in->host, external_name);
                if (external->defined || external->has_layout) die("unresolved type has a class definition");
                external->signature_only = true;
                external->klass.id = id;
                external->klass.instance_size = -1;
                free(external_name);
            }
            if (in->position != end) die("invalid JbedUnresolvedTypes length");
        } else if (!strcmp(name, "JbedFieldLayout") && field) {
            if (size != 9) die("unsupported JbedFieldLayout");
            field->storage = (uint8_t)input_integer(in, 1);
            field->offset = input_integer(in, 4);
            field->flags = input_integer(in, 4);
            field->next = type->fields;
            type->fields = field;
        } else if (!strcmp(name, "JbedUnavailableBody")) {
            in->unavailable = !bound;
        } else if (!strcmp(name, "JbedUnavailableMethods") && type && !field) {
            if (input_integer(in, 2) != 1) die("unsupported JbedUnavailableMethods");
            unsigned missing = input_integer(in, 2);
            while (missing--) {
                MissingMethod *m = allocate(NULL, sizeof(*m));
                m->name = input_text(in);
                m->descriptor = input_text(in);
                m->flags = input_integer(in, 4);
                if (source_class(in->host, in->owner) &&
                    !binding(in->host, in->owner, m->name, m->descriptor)) continue;
                if (!*m->descriptor) {
                    fprintf(stderr, "jbedrom: missing method descriptor: %s.%s\n", in->owner, m->name);
                    ++in->host->missing_bodies;
                    if (!in->host->check_bindings) exit(EXIT_FAILURE);
                    continue;
                }
                if (!binding(in->host, in->owner, m->name, m->descriptor)) {
                    ++in->host->missing_bodies;
                    fprintf(stderr, "jbedrom: omitted initializer requires source binding: %s.%s%s\n",
                            in->owner, m->name, m->descriptor);
                    if (!in->host->check_bindings) exit(EXIT_FAILURE);
                }
                m->next = type->missing_methods;
                type->missing_methods = m;
            }
            if (in->position != end) die("invalid JbedUnavailableMethods length");
        }
        in->position = end;
    }
}

static bool declare_class(void *context, const char *name, const uint8_t *bytes, size_t size)
{
    Host *h = context;
    Type *type = type_named(context, name);
    if (type->signature_only) die("unresolved type has a class definition");
    ClassInput in = {.data = bytes, .length = size, .owner = name, .host = h};
    if (input_integer(&in, 4) != 0xcafebabe) die("invalid class input");
    input_skip(&in, 4);
    in.constants = (uint16_t)input_integer(&in, 2);
    in.utf8 = allocate(NULL, in.constants * sizeof(*in.utf8));
    for (unsigned i = 1; i < in.constants; ++i) {
        unsigned tag = input_integer(&in, 1);
        if (tag == 1) {
            uint32_t length = input_integer(&in, 2);
            size_t start = in.position;
            input_skip(&in, length);
            in.utf8[i] = copy_string(bytes + start, length);
        } else if (tag == 5 || tag == 6) { input_skip(&in, 8); ++i; }
        else if (tag == 7 || tag == 8) input_skip(&in, 2);
        else if (tag == 3 || tag == 4 || (tag >= 9 && tag <= 12)) input_skip(&in, 4);
        else die("unsupported class constant");
    }
    input_skip(&in, 6);
    uint32_t interfaces = input_integer(&in, 2);
    input_skip(&in, 2 * interfaces);
    uint32_t fields = input_integer(&in, 2);
    while (fields--) {
        input_skip(&in, 2);
        FieldLayout *field = allocate(NULL, sizeof(*field));
        field->name = input_utf8(&in, input_integer(&in, 2));
        field->descriptor = input_utf8(&in, input_integer(&in, 2));
        input_attributes(&in, type, field, false);
    }
    uint32_t methods = input_integer(&in, 2);
    while (methods--) {
        uint32_t flags = input_integer(&in, 2);
        const char *method = input_utf8(&in, input_integer(&in, 2));
        const char *descriptor = input_utf8(&in, input_integer(&in, 2));
        in.method = method;
        in.descriptor = descriptor;
        in.unavailable = false;
        bool bound = binding(context, name, method, descriptor) != NULL;
        input_attributes(&in, NULL, NULL, bound);
        if (!bound && !source_class(h, name) && (in.unavailable || (flags & JBED_ACC_NATIVE))) {
            if (in.unavailable) ++h->missing_bodies;
            else ++h->missing_natives;
            fprintf(stderr, "jbedrom: %s requires source binding: %s.%s%s\n",
                    in.unavailable ? "unrecovered body" : "native method", name, method, descriptor);
            if (!h->check_bindings) exit(EXIT_FAILURE);
        }
    }
    input_attributes(&in, type, NULL, false);
    if (in.position != size) die("trailing class input bytes");
    return true;
}

static JbedTypeId descriptor_type(Host *h, const char **cursor, bool result)
{
    const char *p = *cursor;
    uint32_t dimensions = 0;
    while (*p == '[') { ++p; ++dimensions; }
    JbedTypeId id;
    if (*p == 'L') {
        const char *end = strchr(++p, ';');
        if (!end) die("invalid native method descriptor");
        id = class_id(h, (const uint8_t *)p, 0, (uint32_t)(end - p), 0, dimensions);
        p = end + 1;
    } else {
        const char *primitive = *p ? strchr("ZCFDBSIJ", *p) : NULL;
        if (primitive) {
            id = (JbedTypeId)(primitive - "ZCFDBSIJ") + JBED_TYPE_BOOLEAN;
            if (dimensions) id = primitive_array(h, id, dimensions);
        } else if (*p == 'V' && result && !dimensions) id = JBED_TYPE_VOID;
        else die("invalid native method descriptor");
        ++p;
    }
    *cursor = p;
    return id;
}

static JbedSignatureId descriptor_signature(Host *h, const char *descriptor)
{
    const char *p = descriptor;
    if (*p++ != '(') die("invalid native method descriptor");
    JbedTypeId arguments[255];
    size_t count = 0;
    while (*p && *p != ')') {
        if (count == sizeof(arguments) / sizeof(*arguments)) die("too many native arguments");
        arguments[count++] = descriptor_type(h, &p, false);
    }
    if (*p++ != ')') die("invalid native method descriptor");
    JbedTypeId result = descriptor_type(h, &p, true);
    if (*p) die("invalid native method descriptor");
    return jbed_signature_build_types(&h->signatures, arguments, count, result, !result);
}

static bool define_class(void *context, const char *name, const uint8_t *bytes, size_t size)
{
    Host *h = context;
    Type *t = type_named(h, name);
    if (t->defined) die("duplicate class definition");
    t->defined = true;
    JbedReader reader;
    JbedError error = {0};
    if (!jbed_reader_init(&reader, &h->runtime, bytes, size, 0, (int32_t)size, &error) ||
        !jbed_reader_class(&reader, &h->pool_services, &t->klass, &error))
        raise_error(h, &error);
    for (JbedMethod *m = t->klass.methods; m; m = m->next)
        if (binding(h, name, method_name(h, m->name_id), signature_name(h, m->signature_id))) {
            m->flags = (m->flags | JBED_ACC_NATIVE) & ~JBED_ACC_ABSTRACT;
            m->code = NULL;
            m->code_length = 0;
        }
    JbedMethod **tail = &t->klass.methods;
    while (*tail) tail = &(*tail)->next;
    for (MissingMethod *missing = t->missing_methods; missing; missing = missing->next) {
        JbedMethod *m = allocate(NULL, sizeof(*m));
        m->owner = &t->klass;
        m->name_id = intern(&h->methods, (const uint8_t *)missing->name, strlen(missing->name), true);
        m->signature_id = descriptor_signature(h, missing->descriptor);
        m->flags = (missing->flags & 0x1dff) | JBED_ACC_NATIVE;
        if (m->name_id == JBED_NAME_INIT) m->flags |= JBED_METHOD_CONSTRUCTOR;
        if (m->name_id == JBED_NAME_CLINIT) m->flags |= JBED_METHOD_CLASS_INITIALIZER | JBED_ACC_STATIC;
        *tail = m;
        tail = &m->next;
        ++t->klass.method_count;
    }
    if (source_class(h, name)) {
        JbedMethod **link = &t->klass.methods;
        t->klass.method_count = 0;
        while (*link) {
            JbedMethod *m = *link;
            if (!binding(h, name, method_name(h, m->name_id), signature_name(h, m->signature_id)))
                *link = m->next;
            else {
                ++t->klass.method_count;
                link = &m->next;
            }
        }
    }
    return true;
}

static uint32_t class_address(void *context, JbedClass *klass)
{
    Host *h = context;
    if (!klass) return 0;
    Type *type = type_by_id(h, klass->id);
    if (!type || !type->defined) die("unresolved type requires class metadata");
    if (!klass->guest_address) {
        if (h->generating_code) die("class metadata was not prepared before code emission");
        klass->guest_address = allocate_data(&h->writer, NULL,
                                  56 + 16 * (uint32_t)(klass->method_count + klass->field_count));
    }
    return klass->guest_address;
}

static bool put_class(void *context, uint32_t site, JbedClass *klass, JbedError *error)
{
    (void)error;
    JbedWriter *writer = context;
    pointer(writer, site, class_address(writer_host(writer), klass));
    return true;
}

static void apply_field_layout(Host *h, Type *type, bool statics)
{
    if (!type->has_layout) return;
    for (JbedField *field = type->klass.fields; field; field = field->next) {
        if (((field->flags & JBED_ACC_STATIC) != 0) != statics) continue;
        const char *name = field_name(h, field->name_id);
        FieldLayout *layout = type->fields;
        while (layout && strcmp(layout->name, name)) layout = layout->next;
        if (!layout) die("runtime-layout field has no original location");
        uint32_t width = field->type_id >= 4 && field->type_id <= 11
                           ? 1u << (field->type_id & 3) : 4;
        if (layout->offset > UINT32_MAX - width) die("field offset overflow");
        uint32_t end = layout->offset + width;
        if (layout->storage == 0 || layout->storage == 1) {
            field->offset = layout->offset;
            if (layout->storage == 1) {
                field->flags |= JBED_FIELD_RELATIVE_STATIC;
                if (h->statics_size < end) h->statics_size = end;
            }
        } else if (layout->storage == 2) {
            if (end > UINT32_MAX - GLOBAL_BASE) die("global field offset exceeds address space");
            field->offset = GLOBAL_BASE + layout->offset;
            field->flags &= ~JBED_FIELD_RELATIVE_STATIC;
            if (h->globals_size < end) h->globals_size = end;
        } else if (layout->storage != 3) die("invalid runtime field storage");
    }
}

static void bind_fields(Host *h, Type *type)
{
    for (size_t i = 0; i < h->field_binding_count; ++i) {
        FieldBinding *binding = &h->field_bindings[i];
        if (strcmp(type->name, binding->owner)) continue;
        const char *descriptor = binding->descriptor;
        JbedTypeId id = descriptor_type(h, &descriptor, false);
        if (*descriptor) die("invalid bound field descriptor");
        JbedField *field;
        for (field = type->klass.fields; field; field = field->next)
            if (field->type_id == id && !strcmp(field_name(h, field->name_id), binding->name)) break;
        if (!field) die("bound field does not exist");
        if ((field->flags & (JBED_ACC_STATIC | JBED_FIELD_CONSTANT)) != JBED_ACC_STATIC)
            die("runtime field binding requires a nonconstant static field");
        h->bound_fields = resize(h->bound_fields,
            (h->bound_field_count + 1) * sizeof(*h->bound_fields));
        field->flags &= ~JBED_FIELD_RELATIVE_STATIC;
        field->offset = FIELD_BASE + FIELD_STRIDE * (uint32_t)h->bound_field_count;
        h->bound_fields[h->bound_field_count++] = binding;
    }
}

static void prepare(Host *h, Type *type)
{
    JbedClass *c = &type->klass;
    if (type->prepared) return;
    if (!type->defined) { fprintf(stderr, "jbedrom: missing class %s\n", type->name); exit(1); }
    if (type->preparing) die("circular class hierarchy");
    type->preparing = true;
    if (c->flags & JBED_CLASS_ARRAY) {
        prepare(h, type_by_id(h, c->superclass->id));
        Type *object = type_by_id(h, JBED_ROM_CLASS_OBJECT);
        if (!object) die("java/lang/Object is required");
        prepare(h, object);
        c->vtable_size = object->klass.vtable_size;
        c->flags |= JBED_CLASS_PREPARED;
    } else {
        JbedClass header = {.flags = JBED_ACC_PUBLIC, .depth = -1,
                            .instance_size = type->has_layout ? 4 : 12};
        if (c->unresolved_super_id) {
            Type *base = type_by_id(h, c->unresolved_super_id);
            if (!base) die("missing superclass");
            prepare(h, base);
            c->superclass = &base->klass;
        } else if (c->id == JBED_ROM_CLASS_OBJECT) c->superclass = &header;
        else die("only java/lang/Object may have no superclass");
        c->interface_count = c->unresolved_interface_count;
        c->interfaces = allocate(NULL, c->interface_count * sizeof(*c->interfaces));
        for (size_t i = 0; i < c->interface_count; ++i) {
            Type *iface = type_by_id(h, c->unresolved_interface_ids[i]);
            if (!iface) die("missing interface");
            prepare(h, iface);
            c->interfaces[i] = &iface->klass;
        }
        JbedReaderLayoutServices services = {.pool = c->pool};
        jbed_reader_layout_use_writer(&services, &h->writer);
        JbedError error = {0};
        if (!jbed_reader_prepare(&h->layout, &services, c, &error)) raise_error(h, &error);
        if (c->id == JBED_ROM_CLASS_OBJECT) c->superclass = NULL;
    }
    if (type->has_layout) {
        c->instance_size = (int32_t)type->instance_size;
        c->flags |= type->original_flags & (JBED_CLASS_INSTANTIABLE | JBED_CLASS_TRACE | JBED_CLASS_FINALIZED);
        if (type->original_flags & JBED_CLASS_DESCRIPTOR_WRITTEN)
            c->flags |= JBED_CLASS_INSTANTIABLE;
        apply_field_layout(h, type, false);
    }
    type->preparing = false;
    type->prepared = true;
}

static void quote(FILE *output, const char *s)
{
    putc('"', output);
    for (; *s; ++s) {
        unsigned char ch = (unsigned char)*s;
        if (ch == '"' || ch == '\\') fprintf(output, "\\%c", ch);
        else if (ch < 32 || ch > 126) fprintf(output, "\\%03o", ch);
        else putc(ch, output);
    }
    putc('"', output);
}

static uint32_t emit_names(Host *h, const Names *names)
{
    JbedWriter *w = &h->writer;
    uint32_t address = allocate_data(w, NULL, 4 + 4 * 2048);
    byte(w, address, 0x4b); /* 2^11 buckets, four-bit chain ordinal. */
    byte(w, address + 1, 0x4b);
    for (unsigned bucket = 0; bucket < 2048; ++bucket) {
        size_t count = 0, bytes = 1;
        for (size_t i = 0; i < names->count; ++i) {
            const Name *n = &names->entries[i];
            if ((n->id >> 4) != bucket) continue;
            ++count;
            bytes += n->length + 1;
            for (size_t length = n->length; length > 127; length >>= 7) ++bytes;
        }
        if (!count) continue;
        uint32_t data = allocate_data(w, NULL, (uint32_t)bytes);
        pointer(w, address + 4 + 4 * bucket, data);
        for (unsigned ordinal = 1; ordinal <= count; ++ordinal) {
            const Name *n = NULL;
            for (size_t i = 0; i < names->count; ++i)
                if (names->entries[i].id == bucket * 16 + ordinal) n = &names->entries[i];
            if (!n) die("noncontiguous reflection bucket");
            unsigned shift = 0;
            for (size_t length = n->length; length > 127; length >>= 7) shift += 7;
            for (; shift; shift -= 7) byte(w, data++, (uint8_t)((n->length >> shift) & 127));
            byte(w, data++, (uint8_t)(n->length | 128));
            write_block(w, data, n->bytes, (uint32_t)n->length);
            data += (uint32_t)n->length;
        }
    }
    return address;
}

static uint32_t emit_class_index(Host *h)
{
    enum { BUCKETS = 256, CHAIN_LIMIT = 256 };
    unsigned counts[BUCKETS] = {0};
    unsigned *buckets = allocate(NULL, h->type_count * sizeof(*buckets));
    uint32_t id_limit = 0, count = 0;
    for (size_t i = 0; i < h->type_count; ++i) {
        if (h->types[i]->signature_only) continue;
        JbedClass *c = &h->types[i]->klass;
        if (c->id > id_limit) id_limit = c->id;
        if (c->flags & JBED_CLASS_PRIMITIVE) continue;
        ++count;
        unsigned b = (((c->package_id >> 4) & 0xff0) | (c->base_id >> 8)) & (BUCKETS - 1);
        unsigned first = b;
        while (counts[b] == CHAIN_LIMIT) {
            b = (b + 1) & (BUCKETS - 1);
            if (b == first) die("too many boot classes");
        }
        buckets[i] = b;
        ++counts[b];
    }
    if (id_limit > UINT16_MAX || count > UINT16_MAX) die("too many boot classes");
    JbedWriter *w = &h->writer;
    uint32_t address = allocate_data(w, NULL, 8 + 4 * BUCKETS);
    byte(w, address, 0x88);
    half(w, address + 4, (uint16_t)count);
    half(w, address + 6, (uint16_t)id_limit);
    for (unsigned b = 0; b < BUCKETS; ++b) {
        if (!counts[b]) continue;
        uint32_t data = allocate_data(w, NULL, 4 + 12 * counts[b]);
        pointer(w, address + 8 + 4 * b, data);
        word(w, data, counts[b]);
        data += 4;
        for (size_t i = 0; i < h->type_count; ++i) {
            JbedClass *c = &h->types[i]->klass;
            if (h->types[i]->signature_only || (c->flags & JBED_CLASS_PRIMITIVE) || buckets[i] != b) continue;
            half(w, data, c->package_id);
            half(w, data + 2, c->base_id);
            half(w, data + 4, c->array_dimensions);
            pointer(w, data + 8, c->guest_address);
            data += 12;
        }
    }
    free(buckets);
    return address;
}

static void output_image(Host *h, const char *path, const char *symbol)
{
    FILE *output = fopen(path, "w");
    if (!output) die("cannot open output");
    uint32_t used = h->writer.cursor - IMAGE_BASE;
    unsigned *native_indices = allocate(NULL, h->native_count * sizeof(*native_indices));
    size_t natives = 0;
    for (size_t i = 0; i < h->relocation_count; ++i) {
        JbedBootRelocation *r = &h->relocations[i];
        if ((r->kind == JBED_BOOT_NATIVE_POINTER || r->kind == JBED_BOOT_NATIVE_THUMB_CALL) &&
            !native_indices[r->target])
            native_indices[r->target] = (unsigned)++natives;
    }
    fprintf(output, "#include \"boot_image.h\"\n\n");
    for (size_t i = 0; i < h->native_count; ++i)
        if (native_indices[i]) fprintf(output, "extern void %s(void);\n", h->natives[i]);
    for (size_t i = 0; i < h->native_method_count; ++i)
        fprintf(output, "extern void %s(void);\n", h->native_methods[i].binding->symbol);
    for (size_t i = 0; i < h->bound_field_count; ++i)
        fprintf(output, "extern void *%s(void *);\n", h->bound_fields[i]->symbol);
    fprintf(output, "\nstatic const uint8_t image_bytes[] = {\n");
    for (uint32_t i = 0; i < used; ++i)
        fprintf(output, "%s0x%02x,%s", i % 16 ? " " : "    ", h->buffer.data[i],
                i % 16 == 15 ? "\n" : "");
    fprintf(output, "\n};\n\nstatic const JbedBootRelocation image_relocations[] = {\n");
    if (!h->relocation_count) fprintf(output, "    {0},\n");
    for (size_t i = 0; i < h->relocation_count; ++i) {
        JbedBootRelocation *r = &h->relocations[i];
        uint32_t target = (r->kind == JBED_BOOT_NATIVE_POINTER || r->kind == JBED_BOOT_NATIVE_THUMB_CALL)
                            ? native_indices[r->target] - 1 : r->target;
        fprintf(output, "    {%u, %u, %u},\n", r->offset, target, r->kind);
    }
    fprintf(output, "};\n\nstatic const JbedBootNative image_natives[] = {\n");
    if (!natives) fprintf(output, "    {0},\n");
    for (size_t index = 1; index <= natives; ++index)
        for (size_t i = 0; i < h->native_count; ++i)
            if (native_indices[i] == index)
                fprintf(output, "    {\"%s\", %s},\n", h->natives[i], h->natives[i]);
    fprintf(output, "};\n\nstatic const JbedBootMethod image_methods[] = {\n");
    size_t methods = 0;
    for (size_t i = 0; i < h->type_count; ++i) {
        Type *t = h->types[i];
        for (JbedMethod *m = t->klass.methods; m; m = m->next) {
            if (m->flags & JBED_ACC_ABSTRACT) continue;
            ++methods;
            fprintf(output, "    {"); quote(output, t->name); fprintf(output, ", ");
            quote(output, method_name(h, m->name_id)); fprintf(output, ", ");
            quote(output, signature_name(h, m->signature_id));
            fprintf(output, ", %u, %u},\n", (m->code_address - IMAGE_BASE) | 1, m->flags);
        }
    }
    if (!methods) fprintf(output, "    {0},\n");
    fprintf(output, "};\n\nstatic const JbedBootClass image_classes[] = {\n");
    size_t classes = 0;
    for (size_t i = 0; i < h->type_count; ++i) {
        Type *t = h->types[i];
        if (!t->klass.guest_address) continue;
        ++classes;
        fprintf(output, "    {"); quote(output, t->name);
        fprintf(output, ", %u, %u},\n", t->klass.id, t->klass.guest_address - IMAGE_BASE);
    }
    if (!classes) fprintf(output, "    {0},\n");
    fprintf(output, "};\n\nstatic const JbedBootNativeMethod image_native_methods[] = {\n");
    if (!h->native_method_count) fprintf(output, "    {0},\n");
    for (size_t i = 0; i < h->native_method_count; ++i) {
        const BoundNative *m = &h->native_methods[i];
        const NativeBinding *b = m->binding;
        fprintf(output, "    {"); quote(output, b->owner); fprintf(output, ", ");
        quote(output, b->name); fprintf(output, ", "); quote(output, b->descriptor);
        fprintf(output, ", %s, %u, %d},\n", b->symbol, m->flags, b->convention);
    }
    fprintf(output, "};\n\nstatic const JbedBootField image_fields[] = {\n");
    if (!h->bound_field_count) fprintf(output, "    {0},\n");
    for (size_t i = 0; i < h->bound_field_count; ++i) {
        const FieldBinding *f = h->bound_fields[i];
        fprintf(output, "    {"); quote(output, f->owner); fprintf(output, ", ");
        quote(output, f->name); fprintf(output, ", "); quote(output, f->descriptor);
        fprintf(output, ", %s},\n", f->symbol);
    }
    fprintf(output, "};\n\nconst JbedBootImage %s = {\n"
            "    image_bytes, sizeof(image_bytes), image_relocations, %zu,\n"
            "    image_natives, %zu, image_methods, %zu, image_classes, %zu,\n"
            "    %u, %u, %u, %u, %u, %u, %u, %u, %u, image_native_methods, %zu, %u, %u,\n"
            "    image_fields, %zu, %u, %u, %u, %u\n};\n",
            symbol, h->relocation_count, natives, methods, classes,
            h->statics_size, h->stack_maps ? h->stack_maps - IMAGE_BASE : 0,
            h->class_index ? h->class_index - IMAGE_BASE : 0,
            h->package_table ? h->package_table - IMAGE_BASE : 0,
            h->base_table ? h->base_table - IMAGE_BASE : 0,
            h->method_table ? h->method_table - IMAGE_BASE : 0,
            h->field_table ? h->field_table - IMAGE_BASE : 0,
            h->signature_table ? h->signature_table - IMAGE_BASE : 0, h->globals_size,
            h->native_method_count, h->sync_slots,
            h->intern_table ? h->intern_table - IMAGE_BASE : 0, h->bound_field_count,
            h->properties ? h->properties - IMAGE_BASE : 0,
            h->main_method ? h->main_method - IMAGE_BASE : 0,
            h->initializers ? h->initializers - IMAGE_BASE : 0, h->initializer_count);
    if (fclose(output)) die("cannot finish output");
    fprintf(stderr, "jbedrom: %zu methods, %zu classes, %u image bytes, %zu relocations\n",
            methods, classes, used, h->relocation_count);
}

/* Recovered ROM methods contain privileged VM accesses, such as Isolate's
 * writes to package-private Thread.sched. Preserve the declared visibility. */
static bool trusted_access(void *context, const JbedClass *from, const JbedClass *owner)
{
    Host *h = context;
    Type *caller = from ? type_by_id(h, from->id) : NULL;
    Type *target = owner ? type_by_id(h, owner->id) : NULL;
    return caller && target && caller->has_layout && target->has_layout;
}

static void initialize(Host *h)
{
    h->next_type = FIRST_CLASS_ID;
    h->statics_size = STATIC_CAPACITY;
    intern(&h->methods, (const uint8_t *)"<init>", 6, true);
    intern(&h->methods, (const uint8_t *)"<clinit>", 8, true);
    h->runtime = (JbedRuntime){.context = h, .allocate_zeroed = allocate,
                               .raise_error = raise_error, .halt = halt, .protected_call = protect};
    JbedEmitterNames *names = allocate(NULL, sizeof(*names));
    *names = (JbedEmitterNames){h, class_name, method_name, field_name, signature_name};
    h->emitter = (JbedEmitter){.runtime = &h->runtime, .names = names};
    h->signature_services = (JbedSignatureServices){.runtime = &h->runtime, .context = h,
        .types = jbed_signature_rom_types(), .intern = signature_intern, .fetch = signature_fetch,
        .class_id = class_id, .primitive_array_id = primitive_array, .class_name = signature_class_name};
    jbed_signature_init(&h->signatures, &h->signature_services);
    h->pool_services = (JbedPoolServices){.runtime = &h->runtime, .context = h, .emitter = &h->emitter,
        .name_id = pool_name, .class_id = pool_class_id, .primitive_array_id = pool_primitive_array,
        .array_class_id = pool_array_of, .load_class = load_class, .package_id = package_id,
        .signature_encoder = &h->signatures, .boot_image = true, .class_object_address = class_address,
        .intern_string = intern_string, .trusted_access = trusted_access};
    h->buffer = (JbedBuffer){allocate(NULL, IMAGE_CAPACITY), IMAGE_CAPACITY, IMAGE_BASE};
    h->writer_services = (JbedWriterServices){.context = h, .fault = writer_fault};
    jbed_writer_init(&h->writer, &h->writer_services);
    h->writer_ops = (JbedWriterOps){.allocate_code = allocate_code, .allocate = allocate_data,
        .allocate_raw = allocate_data, .flush_code = flush_code, .put_word = word,
        .put_halfword = half, .put_byte = byte, .put_pointer = pointer, .put_static = pointer,
        .put_reloc = put_reloc, .put_call = put_call, .get_halfword = get_half, .get_word = get_word,
        .write_block = write_block, .write_label = write_label, .write_call_label = write_call_label,
        .write_long_jump_label = write_label, .set_label = jbed_writer_define_label,
        .cleanup = cleanup_writer};
    h->writer.ops = &h->writer_ops;
    h->writer.buffer = &h->buffer;
    h->writer.cursor = IMAGE_BASE + 4;
    h->writer.limit = IMAGE_BASE + IMAGE_CAPACITY;
    jbed_reader_layout_init(&h->layout, STATIC_CAPACITY, STATIC_CAPACITY, 0, 1);
    h->layout.primitive_static_top = 4096; /* VM scheduler/compiler statics precede Java fields. */
}

static void compile_image(Host *h, bool methods_only)
{
    Type *object = type_by_id(h, JBED_ROM_CLASS_OBJECT);
    if (!object || !object->defined) die("input must define java/lang/Object");
    if (!methods_only) {
        for (unsigned primitive = 4; primitive <= 11; ++primitive)
            h->pool_services.primitive_array_classes[primitive - 4] =
                get_class(h, primitive_array(h, primitive, 1));
        if (!type_by_id(h, JBED_ROM_CLASS_CLASS)) die("input must define java/lang/Class");
        array_of(h, JBED_ROM_CLASS_CLASS);
        Type *string = type_by_id(h, JBED_ROM_CLASS_STRING);
        if (string && string->defined) array_of(h, JBED_ROM_CLASS_STRING);
        if (h->property_count) array_of(h, array_of(h, JBED_ROM_CLASS_STRING));
    }
    for (size_t i = 0; i < h->type_count; ++i)
        if (!h->types[i]->signature_only) prepare(h, h->types[i]);
    for (size_t i = 0; i < h->type_count; ++i)
        if (!h->types[i]->signature_only) jbed_reader_fixup_fields(&h->layout, &h->types[i]->klass);
    uint32_t statics_size = jbed_reader_relative_statics_size(&h->layout);
    if (h->statics_size < statics_size) h->statics_size = statics_size;
    for (size_t i = 0; i < h->type_count; ++i) apply_field_layout(h, h->types[i], true);
    for (size_t i = 0; i < h->type_count; ++i) bind_fields(h, h->types[i]);
    if (h->statics_size > UINT32_MAX - 7) die("isolate statics exceed address space");
    h->statics_size = (h->statics_size + 7) & ~7u;
    JbedThumbRuntimeAddresses thumb_helpers = {0};
    JbedCoderRuntimeAddresses helpers = {0};
#define THUMB(field) thumb_helpers.field = native(h, "jbed_arm32_" #field)
    THUMB(throw_null); THUMB(throw_index); THUMB(throw_stack); THUMB(throw_large_stack);
    THUMB(throw_abstract); THUMB(throw_no_class); THUMB(interface_stub); THUMB(initialize);
    THUMB(monitor_enter); THUMB(monitor_exit); THUMB(checkpoint); THUMB(save_frame);
    THUMB(integer_divide); THUMB(integer_remainder);
    thumb_helpers.compiler_code = native(h, "jbed_arm32_call");
#undef THUMB
#define CALL(field) helpers.field = native(h, "jbed_arm32_" #field)
    CALL(new_object); CALL(new_array); CALL(new_array_n); CALL(array_store); CALL(check_cast);
    CALL(instance_of); CALL(throw_exception); CALL(monitor_enter); CALL(monitor_exit);
    CALL(class_for_name); CALL(checked_class_for_name); CALL(class_new_instance);
    CALL(checked_class_new_instance);
#undef CALL
#define ARITH(upper, lower) helpers.arithmetic[JBED_BC_##upper] = native(h, "jbed_arm32_" #lower)
    ARITH(LADD, ladd); ARITH(LSUB, lsub); ARITH(LMUL, lmul); ARITH(LDIV, ldiv); ARITH(LREM, lrem);
    ARITH(LNEG, lneg); ARITH(LSHL, lshl); ARITH(LSHR, lshr); ARITH(LUSHR, lushr);
    ARITH(LAND, land); ARITH(LOR, lor); ARITH(LXOR, lxor); ARITH(LCMP, lcmp);
    ARITH(FADD, fadd); ARITH(FSUB, fsub); ARITH(FMUL, fmul); ARITH(FDIV, fdiv); ARITH(FREM, frem);
    ARITH(FNEG, fneg); ARITH(I2F, i2f); ARITH(L2F, l2f); ARITH(F2I, f2i); ARITH(F2L, f2l);
    ARITH(FCMPL, fcmpl); ARITH(FCMPG, fcmpg); ARITH(DADD, dadd); ARITH(DSUB, dsub);
    ARITH(DMUL, dmul); ARITH(DDIV, ddiv); ARITH(DREM, drem); ARITH(DNEG, dneg);
    ARITH(I2D, i2d); ARITH(L2D, l2d); ARITH(F2D, f2d); ARITH(D2I, d2i); ARITH(D2L, d2l);
    ARITH(D2F, d2f); ARITH(DCMPL, dcmpl); ARITH(DCMPG, dcmpg);
#undef ARITH
    h->pool_services.throw_no_class_address = thumb_helpers.throw_no_class;
    h->pool_services.throw_abstract_address = thumb_helpers.throw_abstract;
    JbedCoderServices cs = {.context = h, .class_object_address = class_address};
    Type *class_type = type_by_id(h, JBED_ROM_CLASS_CLASS);
    for (JbedMethod *m = class_type ? class_type->klass.methods : NULL; m; m = m->next) {
        const char *name = method_name(h, m->name_id);
        const char *descriptor = signature_name(h, m->signature_id);
        if (!strcmp(name, "forName") && !strcmp(descriptor, "(Ljava/lang/String;)Ljava/lang/Class;"))
            cs.class_for_name_method = m;
        else if (!strcmp(name, "newInstance") && !strcmp(descriptor, "()Ljava/lang/Object;"))
            cs.class_new_instance_method = m;
    }
    JbedCoder coder;
    jbed_coder_init(&coder, &h->runtime, &cs, &h->emitter, &h->writer, &helpers);
    JbedThumbCoder thumb;
    jbed_thumb_init(&thumb, &coder, &h->runtime, &thumb_helpers, false);
    JbedVerifierServices vs = {.context = h, .emitter = &h->emitter, .class_object = get_class,
        .array_of_class = array_of, .array_level = array_level, .signature_encoder = &h->signatures,
        .name_first_byte = name_first};
    JbedVerifier verifier;
    jbed_verifier_init(&verifier, &h->runtime, &vs);
    size_t prepared_types = h->type_count;
    for (size_t i = 0; i < h->type_count; ++i) {
        Type *t = h->types[i];
        for (JbedMethod *m = t->klass.methods; m; m = m->next)
            if (m->flags & JBED_ACC_NATIVE) {
                const NativeBinding *bound = binding(h, t->name, method_name(h, m->name_id),
                                                      signature_name(h, m->signature_id));
                if (!bound) {
                    fprintf(stderr, "jbedrom: native binding required: %s.%s%s\n", t->name,
                            method_name(h, m->name_id), signature_name(h, m->signature_id));
                    exit(EXIT_FAILURE);
                }
                uint32_t size = bound->convention < 0 ? 16 : 20;
                uint32_t entry = allocate_data(&h->writer, NULL, size);
                word(&h->writer, entry, 0x4b02b408); /* push r3; ldr r3, literal */
                if (bound->convention < 0) {
                    /* Preserve argument four while tail-calling a managed-ABI gate. */
                    word(&h->writer, entry + 4, 0xbc08469c); /* mov ip,r3; pop r3 */
                    word(&h->writer, entry + 8, 0x46c04760); /* bx ip; nop */
                    pointer(&h->writer, entry + 12, native(h, bound->symbol));
                } else {
                    /* native_call restores r3 before capturing its managed frame. */
                    word(&h->writer, entry + 4, 0x4b02469c); /* mov ip,r3; ldr r3,target */
                    word(&h->writer, entry + 8, 0x46c04718); /* bx r3; nop */
                    word(&h->writer, entry + 12, (uint32_t)h->native_method_count);
                    pointer(&h->writer, entry + 16, native(h, "jbed_arm32_native_call"));
                    h->native_methods = resize(h->native_methods,
                        (h->native_method_count + 1) * sizeof(*h->native_methods));
                    h->native_methods[h->native_method_count++] = (BoundNative){bound, m->flags};
                }
                m->code_address = entry | 1;
                m->generated_size = (uint16_t)size;
                if (m->flags & JBED_METHOD_CLASS_INITIALIZER) t->klass.initializer_address = entry | 1;
            }
        if (t->klass.pool) jbed_verifier_verify_class(&verifier, &t->klass);
    }
    /* Verification discovers array classes used only by anewarray or stack maps. */
    for (size_t i = prepared_types; i < h->type_count; ++i) {
        prepare(h, h->types[i]);
        jbed_reader_fixup_fields(&h->layout, &h->types[i]->klass);
    }
    statics_size = jbed_reader_relative_statics_size(&h->layout);
    if (h->statics_size < statics_size) h->statics_size = (statics_size + 7) & ~7u;
    if (!methods_only)
        for (size_t i = 0; i < h->type_count; ++i)
            if (!h->types[i]->signature_only) class_address(h, &h->types[i]->klass);
    h->generating_code = true;
    for (size_t i = 0; i < h->type_count; ++i) {
        Type *t = h->types[i];
        if (t->klass.pool) jbed_coder_translate(&coder, &t->klass);
        if (t->klass.has_error) raise_error(h, &t->klass.error);
        for (JbedMethod *m = t->klass.methods; m; m = m->next)
            if (!(m->flags & JBED_ACC_ABSTRACT) && m->code_address >= NATIVE_BASE)
                raise_error(h, &h->error);
        if (t->klass.initializer_address >= NATIVE_BASE) raise_error(h, &h->error);
    }
    h->generating_code = false;
    for (size_t i = 0; i < h->fixup_count; ++i) {
        LabelFixup *f = &h->fixups[i];
        if (f->label >= h->writer.label_capacity || !h->writer.labels[f->label])
            die("undefined code label");
        uint32_t address = h->writer.labels[f->label];
        if (f->call) {
            uint32_t instruction;
            if (!jbed_thumb_call_encode(f->site, address, &instruction)) die("call exceeds Thumb range");
            put_call(&h->writer, f->site, instruction, false);
        } else pointer(&h->writer, f->site, address);
    }
    if (!methods_only) {
        h->sync_slots = (uint32_t)(h->type_count + h->string_count);
        Type *class_class = type_by_id(h, JBED_ROM_CLASS_CLASS);
        if (!class_class || !class_class->defined) die("input must define java/lang/Class");
        for (size_t i = 0; i < h->type_count; ++i)
            if (!h->types[i]->signature_only) class_address(h, &h->types[i]->klass);
        JbedPool metadata = {.services = &h->pool_services};
        for (size_t i = 0; i < h->type_count; ++i) {
            if (h->types[i]->signature_only) continue;
            JbedClass *c = &h->types[i]->klass;
            JbedReaderLayoutServices ls = {.pool = c->pool ? c->pool : &metadata,
                .array_base_class = &object->klass, .throw_abstract_address = thumb_helpers.throw_abstract};
            jbed_reader_layout_use_writer(&ls, &h->writer);
            ls.put_class = put_class;
            JbedError error = {0};
            if (!jbed_reader_allocate_descriptor(&h->layout, &ls, c, &error)) raise_error(h, &error);
        }
        for (size_t i = 0; i < h->type_count; ++i) {
            if (h->types[i]->signature_only) continue;
            JbedClass *c = &h->types[i]->klass;
            uint32_t address = c->guest_address;
            pointer(&h->writer, address, class_class->klass.descriptor_address);
            word(&h->writer, address + 4, 7);
            word(&h->writer, address + 8, (uint32_t)(2 * i + 1));
            word(&h->writer, address + 12, (c->flags & ~JBED_CLASS_DYNAMIC) |
                JBED_ACC_IN_PROFILE | JBED_CLASS_VERIFIED | JBED_CLASS_TRANSLATED);
            word(&h->writer, address + 16, c->id);
            pointer(&h->writer, address + 20, c->superclass ? c->superclass->guest_address : 0);
            if (c->interface_count) {
                uint32_t interfaces = allocate_data(&h->writer, NULL, 16 + 4 * (uint32_t)c->interface_count);
                JbedClass *array_class = get_class(h, array_of(h, JBED_ROM_CLASS_CLASS));
                pointer(&h->writer, interfaces, array_class->descriptor_address);
                word(&h->writer, interfaces + 4, 7);
                word(&h->writer, interfaces + 8, 2 * h->sync_slots++ + 1);
                word(&h->writer, interfaces + 12, (uint32_t)c->interface_count);
                for (size_t j = 0; j < c->interface_count; ++j)
                    pointer(&h->writer, interfaces + 16 + 4 * (uint32_t)j, c->interfaces[j]->guest_address);
                pointer(&h->writer, address + 24, interfaces);
            }
            word(&h->writer, address + 28, (uint32_t)c->instance_size);
            half(&h->writer, address + 32, (uint16_t)c->depth);
            half(&h->writer, address + 34, (uint16_t)c->vtable_size);
            pointer(&h->writer, address + 36, c->descriptor_address);
            pointer(&h->writer, address + 40, c->default_constructor_address);
            pointer(&h->writer, address + 44, c->initializer_address);
            word(&h->writer, address + 48, c->init_flags);
            half(&h->writer, address + 52, (uint16_t)c->method_count);
            half(&h->writer, address + 54, (uint16_t)c->field_count);
            uint32_t record = address + 56;
            size_t remaining = c->method_count;
            for (JbedMethod *m = c->methods; m && remaining; m = m->next, record += 16, --remaining) {
                word(&h->writer, record, m->flags | JBED_ACC_IN_PROFILE);
                half(&h->writer, record + 4, m->name_id);
                half(&h->writer, record + 6, m->signature_id);
                pointer(&h->writer, record + 8, m->code_address);
                half(&h->writer, record + 12, (uint16_t)m->dispatch_slot);
                half(&h->writer, record + 14, m->generated_size);
            }
            record += 16 * (uint32_t)remaining;
            for (JbedField *f = c->fields; f; f = f->next, record += 16) {
                word(&h->writer, record, f->flags | JBED_ACC_IN_PROFILE);
                half(&h->writer, record + 4, f->name_id);
                half(&h->writer, record + 6, (uint16_t)f->type_id);
                if ((f->flags & (JBED_ACC_STATIC | JBED_FIELD_CONSTANT | JBED_FIELD_RELATIVE_STATIC)) ==
                    JBED_ACC_STATIC)
                    pointer(&h->writer, record + 8, f->offset);
                else if (!(f->flags & JBED_FIELD_CONSTANT)) word(&h->writer, record + 8, f->offset);
                else if (!(f->type_id >> 4)) {
                    word(&h->writer, record + 8, (uint32_t)f->constant_value);
                    if ((f->type_id & 3) == 3)
                        word(&h->writer, record + 12, (uint32_t)(f->constant_value >> 32));
                }
            }
        }
        h->class_index = emit_class_index(h);
        h->package_table = emit_names(h, &h->packages);
        h->base_table = emit_names(h, &h->bases);
        h->method_table = emit_names(h, &h->methods);
        h->field_table = emit_names(h, &h->fields);
        h->signature_table = emit_names(h, &h->signature_names);
        for (size_t i = 0; i < h->string_count; ++i) {
            JbedClass *string = get_class(h, JBED_ROM_CLASS_STRING);
            if (!string || !string->descriptor_address) die("String literals require a String class descriptor");
            pointer(&h->writer, h->strings[i]->address, string->descriptor_address);
            word(&h->writer, h->strings[i]->address + 8, (uint32_t)(2 * (i + h->type_count) + 1));
        }
        Type *string = type_by_id(h, JBED_ROM_CLASS_STRING);
        if (string && string->defined) {
            uint32_t buckets = 64;
            while (buckets < h->string_count) buckets *= 2;
            uint32_t *heads = allocate(NULL, buckets * sizeof(*heads));
            h->intern_table = allocate_data(&h->writer, NULL, 16 + 4 * buckets);
            JbedClass *array = get_class(h, array_of(h, JBED_ROM_CLASS_STRING));
            pointer(&h->writer, h->intern_table, array->descriptor_address);
            word(&h->writer, h->intern_table + 4, 7);
            word(&h->writer, h->intern_table + 8, 2 * h->sync_slots++ + 1);
            word(&h->writer, h->intern_table + 12, buckets);
            for (size_t i = 0; i < h->string_count; ++i) {
                JbedPoolString *s = h->strings[i];
                uint32_t hash = 0;
                for (size_t j = 0; j < s->length; ++j) hash = 31 * hash + s->characters[j];
                uint32_t bucket = hash & (buckets - 1);
                pointer(&h->writer, s->address + 24, heads[bucket]);
                heads[bucket] = s->address;
            }
            for (uint32_t i = 0; i < buckets; ++i)
                pointer(&h->writer, h->intern_table + 16 + 4 * i, heads[i]);
            free(heads);
        }
        if (h->property_count) emit_properties(h);
    } else {
        for (size_t i = 0; i < h->type_count; ++i)
            if (h->types[i]->klass.guest_address) die("--methods-only cannot emit class-object references");
    }
    for (JbedStackMapArray *m = h->writer.stack_maps; m; m = m->next) {
        uint32_t address = jbed_stack_map_write(m, &h->writer);
        if (address) {
            pointer(&h->writer, address + JBED_STACK_MAP_HEADER_NEXT, h->stack_maps);
            h->stack_maps = address;
        }
    }
}

static void emit_bundle(Host *h, const char *main_class)
{
    Type **initializers = allocate(NULL, h->type_count * sizeof(*initializers));
    size_t count = 0;
    for (size_t i = 0; i < h->type_count; ++i) {
        Type *type = h->types[i];
        if (!type->klass.initializer_address) continue;
        size_t position = count++;
        while (position && type->has_initializer_order &&
               (!initializers[position - 1]->has_initializer_order ||
                initializers[position - 1]->initializer_order > type->initializer_order)) {
            initializers[position] = initializers[position - 1];
            --position;
        }
        initializers[position] = type;
    }
    if (count) {
        h->initializers = allocate_data(&h->writer, NULL, 4 * (uint32_t)count);
        h->initializer_count = (uint32_t)count;
        for (size_t i = 0; i < count; ++i)
            pointer(&h->writer, h->initializers + 4 * (uint32_t)i,
                    initializers[i]->klass.guest_address);
    }
    free(initializers);
    if (!main_class) return;
    Type *type = NULL;
    for (size_t i = 0; i < h->type_count; ++i)
        if (!strcmp(h->types[i]->name, main_class)) type = h->types[i];
    if (!type || !type->defined) die("main class is absent from the boot image");
    for (JbedMethod *m = type->klass.methods; m; m = m->next) {
        if (strcmp(method_name(h, m->name_id), "main")) continue;
        const char *signature = signature_name(h, m->signature_id);
        if (strcmp(signature, "([Ljava/lang/String;)V") &&
            strcmp(signature, "([Ljava.lang.String;)V")) continue;
        if ((m->flags & (JBED_ACC_PUBLIC | JBED_ACC_STATIC | JBED_ACC_ABSTRACT)) !=
                        (JBED_ACC_PUBLIC | JBED_ACC_STATIC) || !m->code_address)
            die("main must be public static void main(String[])");
        h->main_method = m->code_address;
        return;
    }
    die("main class has no public static void main(String[])");
}

int main(int argc, char **argv)
{
    const char *symbol = "jbed_boot_image";
    const char *bindings = NULL;
    const char *properties = NULL;
    const char *main_class = NULL;
    bool methods_only = false;
    bool check_bindings = false;
    const char **source_classes = allocate(NULL, (size_t)argc * sizeof(*source_classes));
    size_t source_class_count = 0;
    int arg = 1;
    for (; arg < argc && !strncmp(argv[arg], "--", 2); ++arg) {
        if (!strcmp(argv[arg], "--methods-only")) methods_only = true;
        else if (!strcmp(argv[arg], "--check-bindings")) check_bindings = true;
        else if (!strcmp(argv[arg], "--symbol") && arg + 1 < argc) symbol = argv[++arg];
        else if (!strcmp(argv[arg], "--bindings") && arg + 1 < argc) bindings = argv[++arg];
        else if (!strcmp(argv[arg], "--properties") && arg + 1 < argc) properties = argv[++arg];
        else if (!strcmp(argv[arg], "--main") && arg + 1 < argc) main_class = argv[++arg];
        else if (!strcmp(argv[arg], "--source-class") && arg + 1 < argc)
            source_classes[source_class_count++] = argv[++arg];
        else die("usage: jbedrom [--methods-only] [--symbol NAME] [--bindings FILE] [--properties FILE] [--main CLASS] [--source-class CLASS] OUTPUT.c INPUT.jar [...]");
    }
    if (argc - arg < (check_bindings ? 1 : 2))
        die("usage: jbedrom [--methods-only] [--symbol NAME] [--bindings FILE] [--properties FILE] [--main CLASS] [--source-class CLASS] OUTPUT.c INPUT.jar [...]\n"
            "       jbedrom --check-bindings [--bindings FILE] [--source-class CLASS] INPUT.jar [...]");
    if (!identifier(symbol)) die("invalid C symbol name");
    const char *output = check_bindings ? NULL : argv[arg++];
    int first_input = arg;
    Host h = {0};
    initialize(&h);
    h.check_bindings = check_bindings;
    h.source_classes = source_classes;
    h.source_class_count = source_class_count;
    if (bindings) read_bindings(&h, bindings);
    for (int input = first_input; input < argc; ++input) {
        char error[512] = {0};
        if (!jbed_host_read_jar(argv[input], declare_class, &h, error, sizeof(error))) die(error);
    }
    if (check_bindings) {
        fprintf(stderr, "jbedrom: %zu unrecovered bodies and %zu native methods require source bindings\n",
                h.missing_bodies, h.missing_natives);
        return h.missing_bodies || h.missing_natives ? EXIT_FAILURE : EXIT_SUCCESS;
    }
    for (; arg < argc; ++arg) {
        char error[512] = {0};
        if (!jbed_host_read_jar(argv[arg], define_class, &h, error, sizeof(error))) die(error);
    }
    if (properties) {
        if (methods_only) die("system properties require full boot metadata");
        read_properties(&h, properties);
    }
    compile_image(&h, methods_only);
    if (methods_only && main_class) die("main entry requires full boot metadata");
    if (!methods_only) emit_bundle(&h, main_class);
    output_image(&h, output, symbol);
    return 0;
}
