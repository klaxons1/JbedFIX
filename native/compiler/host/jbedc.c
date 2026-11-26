#include "class_access.h"
#include "coder.h"
#include "compiler.h"
#include "host_inputs.h"
#include "rom_objects.h"
#include "thumb.h"
#include "verifier.h"
#include "vm_monitor.h"
#include "vm_strings.h"
#include "vm_words.h"

#include <errno.h>
#include <limits.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zip.h>

typedef struct Host {
    JbedRuntime runtime;
    JbedAndroidRomTables tables;
    JbedSignatureEncoder signatures;
    JbedCompiler compiler;
    JbedVmStrings strings;
    jmp_buf *handler;
    JbedError error;
    int32_t prefix;
    unsigned classes;
    bool failed;
} Host;

static zip_source_t *pending_output;

static void discard_output(void)
{
    if (pending_output) {
        zip_source_rollback_write(pending_output);
        zip_source_free(pending_output);
    }
}

static void die(const char *message)
{
    fprintf(stderr, "jbedc: %s\n", message);
    exit(EXIT_FAILURE);
}

/* Compiler allocations live for this one invocation, including all class reads. */
static void *allocate(void *ctx, size_t n)
{
    (void)ctx;
    return calloc(1, n ? n : 1);
}

static void *allocate_for_driver(void *ctx, size_t n, JbedError *error)
{
    void *p = allocate(ctx, n);
    if (!p)
        *error = (JbedError){.kind = JBED_ERROR_OUT_OF_MEMORY, .is_java_error = true};
    return p;
}

static void throw_error(void *ctx, const JbedError *error)
{
    Host *h = ctx;
    h->error = *error;
    if (h->handler)
        longjmp(*h->handler, 1);
    fprintf(stderr, "jbedc: VM error %d%s%s\n", error->kind, error->message ? ": " : "",
            error->message ? error->message : "");
    exit(EXIT_FAILURE);
}

static bool protect(void *ctx, void (*body)(void *), void *arg, JbedError *error)
{
    Host *h = ctx;
    jmp_buf local;
    jmp_buf *outer = h->handler;
    h->handler = &local;
    if (setjmp(local)) {
        h->handler = outer;
        *error = h->error;
        return false;
    }
    body(arg);
    h->handler = outer;
    return true;
}

static void writer_fault(void *ctx, JbedWriterFault kind, const char *message)
{
    JbedError error = {.message = message, .is_java_error = true};
    switch (kind) {
    case JBED_WRITER_OUT_OF_CODE: /* OutOfCodeSpaceError extends OutOfMemoryError. */
    case JBED_WRITER_OUT_OF_MEMORY:
        error.kind = JBED_ERROR_OUT_OF_MEMORY;
        break;
    case JBED_WRITER_JAVA_ERROR:
        error.kind = JBED_ERROR_ERROR;
        break;
    case JBED_WRITER_ARRAY_INDEX:
        error.kind = JBED_ERROR_ARRAY_INDEX;
        error.is_java_error = false;
        break;
    default:
        die(message);
    }
    throw_error(ctx, &error);
}

static void vm_halt(void *ctx, int32_t code, const char *message)
{
    (void)ctx;
    (void)code;
    die(message);
}

static const char *class_name(void *ctx, JbedTypeId id)
{
    const char *name = jbed_class_name(&((Host *)ctx)->tables.access, id);
    return name ? name : "<unknown class>";
}

static const char *member_name(JbedReflectionTable *table, JbedNameId id)
{
    int32_t length = jbed_reflection_data(table, id, NULL, 0);
    if (length < 0)
        return "<unknown member>";
    uint8_t *name = jbed_alloc(table->runtime, (size_t)length + 1);
    jbed_reflection_data(table, id, name, (size_t)length);
    return (const char *)name;
}

static const char *method_name(void *ctx, JbedNameId id)
{
    return member_name(&((Host *)ctx)->tables.method_names, id);
}

static const char *field_name(void *ctx, JbedNameId id)
{
    return member_name(&((Host *)ctx)->tables.field_names, id);
}

static const char *signature_name(void *ctx, JbedSignatureId id)
{
    return jbed_signature_descriptor(jbed_signature_copy_if_busy(&((Host *)ctx)->signatures), id);
}

static void report_error(void *ctx, const JbedError *error, const JbedClass *klass,
                         const char *phase)
{
    Host *h = ctx;
    h->failed = true;
    fprintf(stderr, "%s: %s: %s\n", phase, class_name(h, klass ? klass->id : error->class_id),
            error->message ? error->message : "compiler error");
}

static void unresolved(void *ctx, JbedTypeId id, const char *name)
{
    (void)ctx;
    fprintf(stderr, "unresolved class 0x%x (%s)\n", id, name ? name : "?");
}

static void report_oom(void *ctx, JbedTypeId id)
{
    fprintf(stderr, "out of memory reading %s\n", class_name(ctx, id));
}

static void idle(void *ctx) { (void)ctx; }
static void stats(void *ctx, bool final)
{
    (void)ctx;
    (void) final;
}
static int32_t allocation_prefix(void *ctx) { return ((Host *)ctx)->prefix; }
static uint32_t string_buckets(void *ctx)
{
    return jbed_vm_string_table_size(&((Host *)ctx)->strings);
}

static void flush_fixups(void *ctx, JbedAddress end)
{
    Host *h = ctx;
    JbedError error = {0};
    if (!jbed_compiler_flush_fixups(&h->compiler, end, &error))
        throw_error(h, &error);
}

static bool write_bytes(void *f, const void *bytes, uint32_t size)
{
    return zip_source_write(f, bytes, size) == (zip_int64_t)size;
}

static bool seek_output(void *f, uint32_t pos)
{
    return zip_source_seek_write(f, pos, SEEK_SET) == 0;
}

static uint32_t output_position(void *f)
{
    zip_int64_t pos = zip_source_tell_write(f);
    if (pos < 0 || (uint64_t)pos > UINT32_MAX)
        die("output exceeds the compiled-suite format");
    return (uint32_t)pos;
}

static bool define_class(void *ctx, const char *name, const uint8_t *bytes, size_t length)
{
    Host *h = ctx;
    const char *slash = strrchr(name, '/');
    JbedTypeId id = jbed_class_name_id(&h->tables.access, (const uint8_t *)name, 0, strlen(name),
                                       slash ? (size_t)(slash - name) : 0, 0);
    ++h->classes;
    if ((id >> 16) != h->tables.access.dynamic_bundle)
        return true;
    if (!jbed_compiler_define(&h->compiler, id, bytes, length, &h->error))
        return false;
    return !h->failed;
}

static JbedBuffer map_heap(JbedBuffer image, JbedVmHeap *heap, JbedAddress *statics)
{
    const uint32_t heap_bytes = 16u << 20;
    uint64_t boundary = ((uint64_t)image.size + 4095) & ~UINT64_C(4095);
    uint64_t size = boundary + 4096 + heap_bytes;
    if (image.address + size > UINT32_MAX)
        die("insufficient target address space after the ROM");
    uint8_t *data = realloc(image.data, (size_t)size);
    if (!data)
        die("cannot allocate guest memory");
    memset(data + image.size, 0, (size_t)size - image.size);
    JbedBuffer map = {data, (uint32_t)size, image.address};
    *statics = map.address + (uint32_t)boundary;
    jbed_vm_heap_init(heap, map, image.address);
    if (!jbed_vm_heap_add_chunk(heap, *statics + 4096, heap_bytes, true))
        die("cannot initialize the guest heap");
    return map;
}

static void compile(Host *h, JbedBuffer elf, const char *jar, zip_source_t *output,
                    uint32_t hash_state)
{
    JbedVmHeap heap;
    JbedAddress statics;
    JbedBuffer memory = map_heap(elf, &heap, &statics);
    JbedImageView image = {memory.data, elf.size, elf.address};
    if (image.size < 0x3202fcu || jbed_vm_word(memory, elf.address + 0xab364) != 0x018463b3u)
        die("expected the bundled Android Jbed ROM");
    heap.identity_hash_state = hash_state;
    h->runtime = (JbedRuntime){.context = h,
                               .allocate_zeroed = allocate,
                               .raise_error = throw_error,
                               .halt = vm_halt,
                               .protected_call = protect};
    jbed_android_rom_tables_init(&h->tables, &h->runtime, image, false);
    JbedClassAccess *classes = &h->tables.access;
    jbed_class_bind_heap(classes, &heap, statics);
    JbedVmMonitors monitors;
    if (!jbed_vm_monitors_init(&monitors, &heap, elf.address, statics) ||
        !jbed_vm_strings_init(&h->strings, &heap, elf.address, statics, statics + 4092))
        die("cannot initialize isolate tables");

    JbedSignatureServices signature_services = {.runtime = &h->runtime,
                                                .class_access = classes,
                                                .types = jbed_signature_rom_types(),
                                                .reflection_table = &h->tables.signatures};
    jbed_signature_init(&h->signatures, &signature_services);
    JbedEmitterNames names = {h, class_name, method_name, field_name, signature_name};
    JbedEmitter emitter = {.runtime = &h->runtime, .names = &names};
    JbedThumbRuntimeAddresses thumb_helpers = jbed_thumb_rom_helpers(elf.address);
    JbedPoolServices ps = {.runtime = &h->runtime,
                           .emitter = &emitter,
                           .class_access = classes,
                           .method_names = &h->tables.method_names,
                           .field_names = &h->tables.field_names,
                           .signature_encoder = &h->signatures,
                           .vm_strings = &h->strings,
                           .throw_no_class_address = thumb_helpers.throw_no_class,
                           .throw_abstract_address = thumb_helpers.throw_abstract};
    JbedPool metadata = {.services = &ps};
    JbedClass *class_array = jbed_class_object(classes, jbed_class_array_of(classes, 38));
    JbedRomServices rs = {.context = h,
                          .runtime = &h->runtime,
                          .class_access = classes,
                          .class_array_header = class_array->descriptor_address,
                          .int_array_header =
                              jbed_vm_class_by_id(&h->tables.classes, 463)->descriptor_address,
                          .string_table_size = string_buckets,
                          .monitors = &monitors,
                          .throw_abstract = thumb_helpers.throw_abstract,
                          .throw_no_class = thumb_helpers.throw_no_class};
    rs.reflection_tables[JBED_ROM_PACKAGES] = &h->tables.packages;
    rs.reflection_tables[JBED_ROM_BASE_NAMES] = &h->tables.base_names;
    rs.reflection_tables[JBED_ROM_FIELDS] = &h->tables.field_names;
    rs.reflection_tables[JBED_ROM_METHODS] = &h->tables.method_names;
    rs.reflection_tables[JBED_ROM_SIGNATURES] = &h->tables.signatures;
    JbedWriterServices ws = {.context = h,
                             .fault = writer_fault,
                             .full_debug_info = true,
                             .allocation_test_property = allocation_prefix,
                             .rom_services = &rs};
    JbedBlockServices blocks = {.context = h, .rom_services = &rs, .flush_fixups = flush_fixups};
    JbedBlockIdentity identity = {.fingerprint = jbed_vm_word(memory, elf.address + 0xab364),
                                  .system_info_address = elf.address + 0xab338,
                                  .full_debug_info = true};
    JbedBlockIo io = {
        .context = output, .write = write_bytes, .position = output_position, .seek = seek_output};
    JbedFileBlockWriter file;
    jbed_file_writer_init(&file, &ws, &blocks, io, &identity);
    JbedWriter *writer = &file.stream.base.writer;
    JbedCoder coder;
    JbedCoderRuntimeAddresses calls = jbed_coder_rom_helpers(elf.address);
    jbed_coder_init(&coder, &h->runtime, NULL, &emitter, writer, &calls);
    JbedThumbCoder thumb;
    jbed_thumb_init(&thumb, &coder, &h->runtime, &thumb_helpers, false);
    JbedVerifierServices vs = {.emitter = &emitter, .signature_encoder = &h->signatures};
    JbedVerifier verifier;
    jbed_verifier_init(&verifier, &h->runtime, &vs);
    JbedCompilerLayout layout;
    if (!jbed_compiler_layout_android(&layout, &metadata, writer, &h->tables.classes, elf.address))
        die("invalid Android compiler layout");
    JbedCompilerServices services = {.context = h,
                                     .class_access = classes,
                                     .class_layout = &layout,
                                     .emitter = &emitter,
                                     .verifier = &verifier,
                                     .coder = &coder,
                                     .enter = idle,
                                     .leave = idle,
                                     .checkpoint = idle,
                                     .report_statistics = stats,
                                     .allocate = allocate_for_driver,
                                     .report_error = report_error,
                                     .report_unresolved = unresolved,
                                     .report_oom_define = report_oom};
    jbed_compiler_init(&h->compiler, &services, false);
    if (!jbed_compiler_start(&h->compiler, 4, false, NULL, NULL, 0, 30, &h->error))
        throw_error(h, &h->error);
    char diagnostic[256] = {0};
    if (!jbed_host_read_jar(jar, define_class, h, diagnostic, sizeof diagnostic)) {
        if (h->error.kind)
            throw_error(h, &h->error);
        die(diagnostic);
    }
    if (!h->classes)
        die("the JAR contains no classes");
    if (!jbed_compiler_compile(&h->compiler, &h->error))
        throw_error(h, &h->error);
    if (h->failed)
        die("class compilation failed");
    jbed_block_stream_store(&file.stream);
    if (!jbed_compiler_done(&h->compiler, false, &h->error))
        throw_error(h, &h->error);
    jbed_file_writer_dispose(&file);
    free(memory.data);
}

static uint32_t number(const char *s)
{
    char *end;
    errno = 0;
    unsigned long long value = strtoull(s, &end, 0);
    if (errno || !*s || *s == '-' || *end || value > UINT32_MAX)
        die("expected a 32-bit unsigned integer");
    return (uint32_t)value;
}

int main(int argc, char **argv)
{
    uint32_t base = 0, hash_state = 0x0f123456;
    Host h = {.prefix = -1};
    const char *usage = "usage: jbedc [--rom-base ADDRESS] [--prefix BYTES] [--hash-state WORD] "
                        "ROM INPUT.jar OUTPUT.obj";
    int i = 1;
    for (; i < argc && !strncmp(argv[i], "--", 2); ++i) {
        const char *option = argv[i];
        if (!strcmp(option, "--help")) {
            puts(usage);
            return 0;
        }
        if (++i == argc)
            die(usage);
        uint32_t value = number(argv[i]);
        if (!strcmp(option, "--rom-base"))
            base = value;
        else if (!strcmp(option, "--prefix") && value < JBED_BLOCK_SIZE)
            h.prefix = value ? (int32_t)value : -1;
        else if (!strcmp(option, "--hash-state"))
            hash_state = value;
        else
            die(usage);
    }
    if (argc - i != 3)
        die(usage);
    JbedBuffer elf;
    char message[256] = {0};
    if (!jbed_host_read_rom(argv[i], base, &elf, message, sizeof message))
        die(message);

    zip_error_t zip_error;
    zip_error_init(&zip_error);
    zip_source_t *output = zip_source_file_create(argv[i + 2], 0, -1, &zip_error);
    if (!output)
        die(zip_error_strerror(&zip_error));
    if (zip_source_begin_write(output) < 0)
        die(zip_error_strerror(zip_source_error(output)));
    pending_output = output;
    atexit(discard_output);
    compile(&h, elf, argv[i + 1], output, hash_state);
    if (zip_source_commit_write(output) < 0)
        die(zip_error_strerror(zip_source_error(output)));
    pending_output = NULL;
    zip_source_free(output);
    zip_error_fini(&zip_error);
    return 0;
}
