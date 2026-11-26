#include "reader.h"
#include "verifier.h"
#include "compiler.h"
#include "rom_objects.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Handwritten classfile: public C extends Object, a non-final static int with
 * ConstantValue 42, and public static foo()V with an empty CLDC StackMap. */
static const uint8_t classfile[] = {
    0xca, 0xfe, 0xba, 0xbe, 0,   0,   0,   48,  0,   15,  1,   0,   1,    'C', 7,    0,   1,
    1,    0,    16,   'j',  'a', 'v', 'a', '/', 'l', 'a', 'n', 'g', '/',  'O', 'b',  'j', 'e',
    'c',  't',  7,    0,    3,   1,   0,   3,   'f', 'o', 'o', 1,   0,    3,   '(',  ')', 'V',
    1,    0,    4,    'C',  'o', 'd', 'e', 1,   0,   8,   'S', 't', 'a',  'c', 'k',  'M', 'a',
    'p',  1,    0,    1,    'x', 1,   0,   1,   'I', 1,   0,   13,  'C',  'o', 'n',  's', 't',
    'a',  'n',  't',  'V',  'a', 'l', 'u', 'e', 3,   0,   0,   0,   42,
    9, 0, 2, 0, 14, 12, 0, 9, 0, 10, /* #13 Fieldref C.x, #14 x:I */
    0,   0x21, 0,   2,
    0,    4,    0,    0,    0,   1,   0,   8,   0,   9,   0,   10,  0,    1,   0,    11,  0,
    0,    0,    2,    0,    12,  0,   1,   0,   9,   0,   5,   0,   6,    0,   1,    0,   7,
    0, 0, 0, 25, 0, 1, 0, 0, 0, 0, 0, 5,
    0x04, 0xb3, 0, 13, 0xb1, /* iconst_1; putstatic C.x; return */
    0, 0, 0, 1,
    0,    8,    0,    0,    0,   2,   0,   0,   0,   0};

typedef struct TestContext {
    unsigned registrations;
    uint8_t swap[512 * 1024];
    size_t size, position;
    JbedClass *compile_class, *base;
    const uint32_t *ranges;
    uint32_t static_size, range_count;
} TestContext;

static void *allocate(void *context, size_t size)
{
    (void)context;
    return calloc(1, size);
}
static void fail_raise(void *context, const JbedError *error)
{
    (void)context;
    fprintf(stderr, "unexpected raised error %d: %s\n", error->kind, error->message);
    abort();
}
static void fail_phase(void *context, const JbedError *error, const JbedClass *klass,
                       const char *phase)
{
    (void)klass;
    fprintf(stderr, "unexpected error in %s: ", phase);
    fail_raise(context, error);
}
static const char *class_name(void *opaque, JbedTypeId type)
{
    (void)opaque;
    return type == 0x12345 ? "C" : "java.lang.Object";
}
static const char *method_name(void *opaque, JbedNameId name)
{
    (void)opaque;
    (void)name;
    return "foo";
}
static const char *field_name(void *opaque, JbedNameId name)
{
    (void)opaque;
    (void)name;
    return "x";
}
static const char *signature_name(void *opaque, JbedSignatureId signature)
{
    (void)opaque;
    (void)signature;
    return "()V";
}
static bool name_id(void *opaque, bool method, const uint8_t *data, size_t size, bool create,
                    JbedNameId *name, JbedError *error)
{
    (void)opaque;
    (void)error;
    *name = 0;
    if (create && method && size == 3 && !memcmp(data, "foo", 3))
        *name = 8;
    if (create && !method && size == 1 && data[0] == 'x')
        *name = 7;
    return true;
}
static bool class_id(void *opaque, const uint8_t *data, size_t start, size_t end, size_t slash,
                     uint16_t dimensions, JbedTypeId *id, JbedError *error)
{
    (void)opaque;
    (void)error;
    assert(!dimensions);
    if (end - start == 1 && data[start] == 'C') {
        assert(!slash);
        *id = 0x12345;
    } else {
        assert(end - start == 16 && !memcmp(data + start, "java/lang/Object", 16));
        assert(slash == 9);
        *id = 22;
    }
    return true;
}
static bool register_class(void *opaque, JbedClass *klass, JbedError *error)
{
    (void)klass;
    (void)error;
    ++((TestContext *)opaque)->registrations;
    return true;
}
static bool find_method(void *opaque, JbedClass *klass, JbedNameId name, JbedSignatureId signature,
                        JbedMethod **method, JbedError *error)
{
    (void)opaque;
    (void)klass;
    (void)name;
    (void)signature;
    (void)error;
    *method = NULL;
    return true;
}
static bool visible(void *opaque, const JbedMethod *method)
{
    (void)opaque;
    (void)method;
    return true;
}
static bool write_swap(void *opaque, const void *data, size_t size, JbedError *error)
{
    (void)error;
    TestContext *context = opaque;
    assert(context->position + size <= sizeof(context->swap));
    memcpy(context->swap + context->position, data, size);
    context->position += size;
    if (context->position > context->size)
        context->size = context->position;
    return true;
}
static bool read_swap(void *opaque, void *data, size_t size, JbedError *error)
{
    (void)error;
    TestContext *context = opaque;
    assert(context->position + size <= context->size);
    memcpy(data, context->swap + context->position, size);
    context->position += size;
    return true;
}
static bool swap_length(void *ctx, int32_t *length, JbedError *error)
{
    (void)error;
    *length = (int32_t)((TestContext *)ctx)->size;
    return true;
}
static bool swap_seek(void *ctx, int32_t offset, JbedError *error)
{
    (void)error;
    ((TestContext *)ctx)->position = (size_t)offset;
    return true;
}
static void *compiler_allocate(void *ctx, size_t size, JbedError *error)
{
    (void)error;
    return allocate(ctx, size);
}
static JbedClass *get_class(void *ctx, JbedTypeId id, JbedError *error)
{
    (void)error;
    JbedClass *klass = ((TestContext *)ctx)->compile_class;
    assert(klass && klass->id == id);
    return klass;
}

static bool protected_call(void *ctx, void (*body)(void *), void *argument, JbedError *error)
{
    (void)ctx;
    (void)error;
    body(argument);
    return true;
}
static JbedClass *next_class(void *ctx, JbedClass *previous)
{
    return previous ? NULL : ((TestContext *)ctx)->compile_class;
}
static JbedClass *lookup_class(void *ctx, JbedTypeId id)
{
    JbedClass *base = ((TestContext *)ctx)->base;
    return id == base->id ? base : NULL;
}
static JbedTypeId no_unresolved(void *ctx, JbedTypeId previous)
{
    (void)ctx;
    (void)previous;
    return 0;
}
static void idle(void *ctx)
{
    (void)ctx;
}
static bool detached(void *ctx)
{
    (void)ctx;
    return false;
}
static void statistics(void *ctx, bool final)
{
    (void)ctx;
    (void)final;
}
static uint32_t target_class(void *ctx, const JbedClass *klass)
{
    (void)ctx;
    return klass->id * 0x100;
}
static void extend_statics(void *ctx, uint32_t size, const uint32_t *ranges, uint32_t count)
{
    TestContext *test = ctx;
    test->static_size = size;
    test->range_count = count;
    test->ranges = ranges;
}

static void descriptor_gc_map(TestContext *ctx, JbedPool *pool)
{
    JbedClass root = {.id = 16};
    JbedField inherited = {.type_id = 80, .offset = 12};
    JbedClass base = {.id = 17, .flags = 0x40001, .depth = 1, .instance_size = 16,
                      .superclass = &root, .fields = &inherited};
    JbedField static_ref = {.type_id = 0x10056, .flags = JBED_ACC_STATIC};
    JbedField primitive = {.type_id = 8, .next = &static_ref};
    JbedField ref = {.type_id = 0x10057, .next = &primitive};
    JbedClass child = {.id = 0x10058, .flags = 0xc90001, .unresolved_super_id = base.id,
                       .fields = &ref};
    ctx->base = &base;
    ctx->compile_class = &child;

    JbedRomServices rom = {.class_address = target_class};
    JbedWriterServices ws = {.context = ctx, .rom_services = &rom, .extend_statics = extend_statics};
    uint8_t bytes[64] = {0};
    JbedBuffer buffer = {.data = bytes, .address = 0x800, .size = sizeof(bytes)};
    JbedWriter writer;
    jbed_writer_init(&writer, &ws);
    writer.buffer = &buffer;
    writer.cursor = buffer.address;
    writer.limit = buffer.address + buffer.size;

    JbedCompilerLayout binding = {.pool = pool, .writer = &writer};
    jbed_reader_layout_init(&binding.layout, 64, 16, 0, 1);
    JbedCompilerServices cs = {.context = ctx, .class_layout = &binding,
                               .lookup_class = lookup_class, .enter = idle, .leave = idle,
                               .checkpoint = idle, .next_class = next_class,
                               .next_unresolved = no_unresolved, .report_statistics = statistics,
                               .coder_has_writer = detached};
    JbedCompiler compiler;
    JbedError error = {0};
    jbed_compiler_init(&compiler, &cs, true);
    compiler.method_offset = 1;
    assert(jbed_compiler_compile(&compiler, &error));
    assert(child.depth == 2 && child.instance_size == 21 && child.init_flags == 1);
    assert(ref.offset == 16 && primitive.offset == 20 && static_ref.offset == 12);
    assert(ctx->static_size == 64 && ctx->range_count == 2 && ctx->ranges[0] == 12 &&
           ctx->ranges[1] == 16);
    assert(child.descriptor_address == 0x81c && writer.cursor == 0x824);
    assert(jbed_writer_get_halfword(&writer, 0x802) == -4);
    assert(jbed_writer_get_halfword(&writer, 0x804) == 16);
    assert(jbed_writer_get_halfword(&writer, 0x806) == 12);
    assert(jbed_writer_get_word(&writer, 0x810) == target_class(ctx, &child));
    assert(jbed_writer_get_word(&writer, 0x814) == target_class(ctx, &base));
    assert(jbed_writer_get_word(&writer, 0x818) == 21);
    assert(jbed_writer_get_word(&writer, 0x81c) == target_class(ctx, &child));
    assert(jbed_writer_get_word(&writer, 0x820) == 0);
}

int main(void)
{
    TestContext context = {0};
    JbedRuntime runtime = {.context = &context, .allocate_zeroed = allocate,
                           .raise_error = fail_raise, .protected_call = protected_call};
    JbedEmitterNames names = {.class_name = class_name,
                              .method_name = method_name,
                              .field_name = field_name,
                              .signature = signature_name};
    JbedEmitter emitter = {.runtime = &runtime, .names = &names};
    JbedSignatureServices signature_services = {.runtime = &runtime, .types = jbed_signature_rom_types()};
    JbedSignatureEncoder signature_encoder;
    jbed_signature_init(&signature_encoder, &signature_services);
    JbedPoolServices services = {.runtime = &runtime,
                                 .context = &context,
                                 .emitter = &emitter,
                                 .name_id = name_id,
                                 .class_id = class_id,
                                 .signature_encoder = &signature_encoder,
                                 .find_method = find_method,
                                 .method_visible = visible};
    JbedReader reader;
    JbedError error = {0};
    JbedClass klass = {.id = 0x12345};
    context.compile_class = &klass;
    JbedPool metadata = {.services = &services};
    JbedCompilerLayout binding = {.pool = &metadata};
    JbedCompilerServices cs = {.context = &context, .class_layout = &binding,
                               .get_or_create_class = get_class, .report_error = fail_phase,
                               .allocate = compiler_allocate, .enter = idle, .leave = idle,
                               .checkpoint = idle};
    JbedCompiler driver;
    jbed_compiler_init(&driver, &cs, true);
    JbedCompilerSwap stream = {.context = &context, .read = read_swap, .write = write_swap,
                               .length = swap_length, .seek = swap_seek};
    jbed_compiler_enable_swapping(&driver, &stream, &stream);
    assert(jbed_compiler_define(&driver, klass.id, classfile, sizeof(classfile), &error));
    assert(!klass.pool && klass.methods && !klass.methods->code && context.size > 0);
    assert(jbed_compiler_restore_class(&driver, &klass, &error));
    assert(context.position == context.size);
    assert(!emitter.import_class && klass.unresolved_super_id == 22);
    assert(klass.field_count == 1 && klass.fields->name_id == 7 && klass.fields->type_id == 10);
    assert(klass.fields->constant_value == 42 && klass.fields->flags == 0x4000008);
    assert(klass.method_count == 1 && klass.methods->name_id == 8);
    assert(klass.methods->code_length == 5 && klass.methods->code[1] == 0xb3);
    assert(klass.methods->stack_maps.word_count == 1 && !klass.methods->stack_maps.words[0]);
    JbedMethod *initializer = klass.methods->next;
    assert(initializer && !initializer->next && initializer->name_id == 27281);
    assert(initializer->signature_id == 61453 && initializer->dispatch_slot == -1);
    assert(initializer->flags == 0x10000008 && initializer->code[0] == 0xb1);
    assert(!klass.static_initializer_count && !klass.pool->utf8_info);

    JbedVerifierServices verify_services = {.emitter = &emitter, .signature_encoder = &signature_encoder};
    JbedVerifier verifier;
    jbed_verifier_init(&verifier, &runtime, &verify_services);
    jbed_verifier_verify_class(&verifier, &klass);
    assert(!emitter.import_class && !verifier.stack_depth);

    JbedClass truncated = {.id = 0x12345};
    assert(jbed_reader_init(&reader, &runtime, classfile, sizeof(classfile) - 1, 0,
                            sizeof(classfile), &error));
    assert(!jbed_reader_class(&reader, &services, &truncated, &error));
    assert(error.kind == JBED_ERROR_ERROR && !strcmp(error.message, "class format error in C"));

    static const uint8_t maps[] = {0, 2, 0, 0, 0, 2, 1, 4, 0, 0, 0, 5, 0, 2, 1, 4, 0, 1, 7, 0, 2};
    static const uint32_t expected[] = {2, 0, 5, 7, 0, 7, 10, 2, 1, 4, 1, 9};
    JbedMethod method = {.max_locals = 3, .max_stack = 1};
    JbedStackMaps packed;
    assert(jbed_reader_init(&reader, &runtime, maps, sizeof(maps), 0, sizeof(maps), &error));
    assert(jbed_reader_maps(&reader, &emitter, &method, &packed, &error));
    assert(!jbed_reader_close(&reader));
    assert(packed.word_count == sizeof(expected) / sizeof(*expected));
    assert(!memcmp(packed.words, expected, sizeof(expected)));
    method.max_locals = 2;
    assert(jbed_reader_init(&reader, &runtime, maps, sizeof(maps), 0, sizeof(maps), &error));
    assert(!jbed_reader_maps(&reader, &emitter, &method, &packed, &error));
    assert(error.kind == JBED_ERROR_ERROR && !strcmp(error.message, "class format error in C"));

    /* Wire u2 PCs/counts do not imply u2 offsets in the expanded table.
     * This reproduces lifted methods with >64K words of distinct maps. */
    enum { FRAME_COUNT = 80, LOCAL_COUNT = 1024, FRAME_BYTES = 2 + 2 + LOCAL_COUNT + 2 + 1 };
    size_t large_size = 2 + FRAME_COUNT * FRAME_BYTES;
    uint8_t *large_maps = calloc(1, large_size);
    assert(large_maps);
    large_maps[1] = FRAME_COUNT;
    for (unsigned i = 0; i < FRAME_COUNT; ++i) {
        uint8_t *f = large_maps + 2 + i * FRAME_BYTES;
        f[1] = (uint8_t)i;
        f[2] = LOCAL_COUNT >> 8; f[3] = LOCAL_COUNT & 255;
        memset(f + 4, 1, LOCAL_COUNT);
        f[4 + i] = 2;
        f[4 + LOCAL_COUNT + 1] = 1;
        f[4 + LOCAL_COUNT + 2] = 1;
    }
    method.max_locals = LOCAL_COUNT;
    assert(jbed_reader_init(&reader, &runtime, large_maps, large_size, 0, (int32_t)large_size, &error));
    assert(jbed_reader_maps(&reader, &emitter, &method, &packed, &error));
    assert(packed.word_count > UINT16_MAX);
    uint32_t last_locals = packed.words[FRAME_COUNT + 1 + 2 * (FRAME_COUNT - 1)];
    assert(last_locals > UINT16_MAX && packed.words[last_locals] == LOCAL_COUNT);
    assert(packed.words[last_locals + FRAME_COUNT] == 2);
    free(large_maps);

    JbedClass base = {.flags = JBED_ACC_PUBLIC, .instance_size = 12, .vtable_size = 1};
    klass.superclass = &base;
    JbedReaderLayout layout;
    jbed_reader_layout_init(&layout, 0x100, 2, 0, 1);
    JbedReaderLayoutServices layout_services = {
        .pool = klass.pool, .context = &context, .register_class = register_class};
    assert(jbed_reader_prepare(&layout, &layout_services, &klass, &error));
    assert(context.registrations == 1 && !emitter.import_class);
    assert(klass.fields->offset == 0x800000 && layout.first_pointer_range == 2);
    assert(klass.instance_size == 12 && klass.depth == 1 && klass.vtable_size == 1);
    assert(klass.methods->dispatch_slot == -1 && initializer->dispatch_slot == -2);
    jbed_reader_fixup_fields(&layout, &klass);
    assert(klass.fields->offset == 0x100 && (klass.fields->flags & 0x10000));
    assert(klass.init_flags == 0x104 && jbed_reader_relative_statics_size(&layout) == 0x105);
    uint32_t ranges[4];
    assert(jbed_reader_pointer_ranges(&layout, ranges) == 4);
    assert(ranges[0] == 2 && ranges[1] == 2 && ranges[2] == 0x100 && ranges[3] == 0x100);

    /* Cache C in its pool, then require swapOut to restore the class ID. */
    klass.pool->tags[2] = 23;
    klass.pool->values[2] = 0;
    klass.pool->objects[0].class_object = &klass;
    klass.pool->object_position = 1;
    context.size = context.position = 0;
    assert(jbed_pool_swap_out(klass.pool, &stream, &error));
    assert(klass.pool->tags[2] == 7 && klass.pool->values[2] == 0x12345);
    assert(context.swap[0] == 15 && context.swap[1] == 0);
    static const uint8_t class_id_le[] = {0x45, 0x23, 1, 0};
    assert(!memcmp(context.swap + 2 + 15 + 2 * 4, class_id_le, 4));
    context.position = 0;
    JbedPool restored;
    jbed_pool_init(&restored, &services, &klass);
    assert(jbed_pool_swap_in(&restored, &stream, &error));
    assert(context.position == context.size && restored.count == 15);
    assert(restored.tags[2] == 7 && restored.values[2] == 0x12345 && restored.values[12] == 42);
    assert(restored.object_count == 2 && restored.object_position == 0);
    /* Constructor0x149510 defers invalid slices, using wrapping Java ints. */
    assert(jbed_reader_init(&reader, &runtime, classfile, 2, -1, 1, &error));
    assert(reader.offset == -1 && reader.bytes_left == 1);
    assert(jbed_reader_init(&reader, &runtime, classfile, 2, 3, 1, &error));
    assert(reader.offset == 3 && reader.bytes_left == -1);
    assert(jbed_reader_init(&reader, &runtime, classfile, 2, 0, -3, &error));
    assert(reader.bytes_left == -3);
    assert(jbed_reader_init(&reader, &runtime, classfile, 2, INT32_MAX, 2, &error));
    assert(reader.offset == INT32_MAX && reader.bytes_left == 2);
    assert(!jbed_reader_init(&reader, &runtime, NULL, 0, 0, 0, &error));
    assert(error.kind == JBED_ERROR_NULL_POINTER);

    jbed_emitter_set_import(&emitter, 0x12345, 8, 61453);
    error = jbed_emitter_error(&emitter, JBED_EMITTER_NO_METHOD, 22, 8, 61453, 0);
    assert(error.kind == JBED_ERROR_ERROR);
    assert(!strcmp(error.message, "method not found: java.lang.Object.foo()V(used in C.foo()V)"));
    error = jbed_emitter_error(&emitter, JBED_EMITTER_VERIFY, 0, 0, 0, 0);
    assert(error.kind == JBED_ERROR_ERROR &&
           !strcmp(error.message, "verify error (used in C.foo()V)"));
    error = jbed_emitter_error(&emitter, JBED_EMITTER_VERIFY_AT, 0, 0, 0, 120);
    assert(error.kind == JBED_ERROR_NO_CLASS_DEF && error.detail_code == 120);
    assert(!strcmp(error.message, "verify error 120 (used in C.foo()V)"));
    /* Wide packed-map offsets must also survive Compiler's swap stream. */
    uint32_t *wide_words = calloc(70000, sizeof *wide_words);
    assert(wide_words);
    wide_words[0] = 1; wide_words[1] = 4; wide_words[2] = 69998;
    wide_words[69998] = 1; wide_words[69999] = 2;
    JbedStackMaps ordinary_maps = klass.methods->stack_maps;
    klass.methods->stack_maps = (JbedStackMaps){wide_words, 70000};
    context.size = context.position = 0;
    assert(jbed_compiler_swap_class(&driver, &klass, &error));
    klass.methods->stack_maps = (JbedStackMaps){0};
    assert(jbed_compiler_restore_class(&driver, &klass, &error));
    assert(klass.methods->stack_maps.word_count == 70000);
    assert(!memcmp(klass.methods->stack_maps.words, wide_words, 70000 * sizeof *wide_words));
    free(wide_words);
    klass.methods->stack_maps = ordinary_maps;
    descriptor_gc_map(&context, klass.pool);
    puts("Reader/Pool semantic checks passed");
    return 0;
}
