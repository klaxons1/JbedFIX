/* Compile the built-in Calc fixture or a supplied one-method Calc.class. */
#include "class_access.h"
#include "compiler.h"
#include "coder.h"
#include "pool.h"
#include "thumb.h"
#include "verifier.h"
#include "vm_stackmap.h"

#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>

#define ROM_BASE UINT32_C(0x1000000)

static bool fail_next_allocation;
static jmp_buf *exception_handler;
static JbedError thrown;

static void *allocate(void *context, size_t size)
{
    (void)context;
    if (fail_next_allocation) {
        fail_next_allocation = false;
        return NULL;
    }
    return calloc(1, size);
}

static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    if (exception_handler) {
        thrown = *error;
        longjmp(*exception_handler, 1);
    }
    fprintf(stderr, "compiler error: %s\n", error->message ? error->message : "unknown");
    exit(2);
}

static void halt(void *context, int32_t code, const char *message)
{
    (void)context;
    fprintf(stderr, "compiler halt %d: %s\n", code, message);
    exit(2);
}

static bool protected_call(void *context, void (*body)(void *), void *argument, JbedError *caught)
{
    (void)context;
    jmp_buf handler;
    jmp_buf *outer = exception_handler;
    exception_handler = &handler;
    if (setjmp(handler) != 0) {
        *caught = thrown;
        exception_handler = outer;
        return false;
    }
    body(argument);
    exception_handler = outer;
    return true;
}

static void writer_fault(void *context, JbedWriterFault kind, const char *message)
{
    (void)context;
    fprintf(stderr, "writer fault %d: %s\n", (int)kind, message);
    exit(2);
}

static JbedBuffer *new_buffer(void *context, uint32_t size)
{
    (void)context;
    JbedBuffer *buffer = calloc(1, sizeof(*buffer));
    if (!buffer)
        return NULL;
    buffer->data = calloc(1, size);
    if (!buffer->data) {
        free(buffer);
        return NULL;
    }
    buffer->size = size;
    buffer->address = ROM_BASE + UINT32_C(0x380000);
    return buffer;
}

static JbedBuffer *output;
static JbedBuffer *resize_buffer(void *ctx, JbedBuffer *buffer, uint32_t used)
{
    (void)ctx;
    if (used > buffer->size)
        abort();
    buffer->size = used;
    return buffer;
}
static void attach_buffer(void *ctx, JbedCodeOwner *owner, JbedBuffer *buffer)
{
    (void)ctx;
    (void)owner;
    output = buffer;
}
static void flush_cache(void *ctx, uint32_t start, uint32_t size)
{
    (void)ctx;
    if (!start || !size)
        abort();
}
static uint32_t map_word(void *ctx, uint32_t address)
{
    return jbed_writer_get_word(ctx, address);
}
static void extend_statics(void *ctx, uint32_t size, const uint32_t *ranges, uint32_t count)
{
    (void)ctx;
    if (size != 0x95c || count != 2 || ranges[0] != 0x100 || ranges[1] != 0x6fc)
        abort();
}
static void idle(void *ctx)
{
    (void)ctx;
}
static void stats(void *ctx, bool final)
{
    (void)ctx;
    (void)final;
}
static void report_error(void *ctx, const JbedError *error, const JbedClass *klass, const char *phase)
{
    (void)klass;
    fprintf(stderr, "%s: ", phase);
    raise_error(ctx, error);
}
static void write_u32(uint32_t value)
{
    const unsigned char bytes[4] = {(unsigned char)value, (unsigned char)(value >> 8),
                                    (unsigned char)(value >> 16), (unsigned char)(value >> 24)};
    if (fwrite(bytes, 1, 4, stdout) != 4)
        exit(3);
}

static uint8_t *read_file(const char *path, size_t *size)
{
    FILE *file = fopen(path, "rb");
    if (!file)
        return NULL;
    long length = fseek(file, 0, SEEK_END) == 0 ? ftell(file) : -1;
    uint8_t *bytes = NULL;
    if (length > 0 && !fseek(file, 0, SEEK_SET)) {
        bytes = malloc((size_t)length);
        if (bytes && fread(bytes, 1, (size_t)length, file) != (size_t)length) {
            free(bytes);
            bytes = NULL;
        }
    }
    fclose(file);
    if (bytes)
        *size = (size_t)length;
    return bytes;
}

int main(int argc, char **argv)
{
    static const uint8_t classfile[] = {
        0xca,0xfe,0xba,0xbe,0,0,0,48,0,12,1,0,4,'C','a','l','c',7,0,1,
        1,0,16,'j','a','v','a','/','l','a','n','g','/','O','b','j','e','c','t',7,0,3,
        1,0,3,'r','u','n',1,0,3,'(',')','I',1,0,4,'C','o','d','e',
        1,0,8,'S','t','a','c','k','M','a','p',
        1,0,3,'s','u','m',12,0,9,0,6,10,0,2,0,10,
        0,0x21,0,2,0,4,0,0,0,0,0,2,
        0,9,0,5,0,6,0,1,0,7,0,0,0,24,0,1,0,0,0,0,0,4,
        0xb8,0,11,0xac, /* invokestatic Calc.sum; ireturn */
        0,0,0,1,0,8,0,0,0,2,0,0,
        0,9,0,9,0,6,0,1,0,7,0,0,0,25,0,4,0,0,0,0,0,5,
        0x0a,0x0a,0x61,0x88,0xac, /* 1L + 1L, l2i, ireturn */
        0,0,0,1,0,8,0,0,0,2,0,0,0,0};
    if (argc != 2 && argc != 3)
        return 1;
    size_t length, class_size = sizeof classfile;
    uint8_t *bytes = read_file(argv[1], &length);
    const uint8_t *input = argc == 3 ? read_file(argv[2], &class_size) : classfile;
    if (!bytes || !input)
        return 1;
    JbedRuntime runtime = {.allocate_zeroed = allocate,
                           .raise_error = raise_error,
                           .halt = halt,
                           .protected_call = protected_call};
    JbedAndroidRomTables tables;
    jbed_android_rom_tables_init(&tables, &runtime, (JbedImageView){bytes, (size_t)length, 0}, false);
    JbedEmitter emitter = {.runtime = &runtime};
    JbedSignatureServices signatures = {.runtime = &runtime, .types = jbed_signature_rom_types(),
                                        .reflection_table = &tables.signatures, .class_access = &tables.access};
    JbedSignatureEncoder encoder;
    jbed_signature_init(&encoder, &signatures);
    JbedPoolServices pool_services = {.runtime = &runtime, .signature_encoder = &encoder,
        .emitter = &emitter, .class_access = &tables.access, .method_names = &tables.method_names,
        .field_names = &tables.field_names};
    JbedPool metadata = {.services = &pool_services};
    JbedWriter writer;
    JbedVmStackMaps maps;
    jbed_vm_stack_maps_init(&maps, &runtime, (JbedVmMemoryReader){&writer, map_word});
    JbedWriterServices writer_services = {.fault = writer_fault, .new_code_buffer = new_buffer,
        .resize_code_buffer = resize_buffer, .attach_code = attach_buffer, .flush_cache = flush_cache,
        .extend_statics = extend_statics, .stack_map_registry = &maps};
    jbed_writer_init(&writer, &writer_services);
    JbedCoderRuntimeAddresses calls = jbed_coder_rom_helpers(ROM_BASE);
    JbedCoder coder;
    jbed_coder_init(&coder, &runtime, NULL, &emitter, &writer, &calls);
    JbedThumbRuntimeAddresses helpers = jbed_thumb_rom_helpers(ROM_BASE);
    JbedThumbCoder thumb;
    jbed_thumb_init(&thumb, &coder, &runtime, &helpers, false);
    JbedVerifierServices verifier_services = {.emitter = &emitter, .signature_encoder = &encoder};
    JbedVerifier verifier;
    jbed_verifier_init(&verifier, &runtime, &verifier_services);
    JbedCompilerLayout layout;
    if (!jbed_compiler_layout_android(&layout, &metadata, &writer, &tables.classes, ROM_BASE))
        return 1;
    JbedCompilerServices services = {.context = &tables.access, .emitter = &emitter, .enter = idle,
        .leave = idle, .checkpoint = idle, .report_error = report_error, .report_statistics = stats,
        .class_layout = &layout, .class_access = &tables.access, .verifier = &verifier, .coder = &coder};
    JbedCompiler driver;
    jbed_compiler_init(&driver, &services, false);
    JbedError error = {0};
    if (!jbed_compiler_start(&driver, 0, false, NULL, NULL, 1, 0, &error))
        raise_error(NULL, &error);
    JbedTypeId id = jbed_class_name_id(&tables.access, (const uint8_t *)"Calc", 0, 4, 0, 0);
    if (!jbed_compiler_define(&driver, id, input, class_size, &error))
        raise_error(NULL, &error);
    if (argc == 2) {
        JbedClass probe = *jbed_class_object(&tables.access, id);
        probe.superclass = jbed_vm_class_by_id(&tables.classes, 462);
        JbedMethod probe_method = *probe.methods;
        probe_method.owner = &probe;
        probe.methods = &probe_method;
        fail_next_allocation = true;
        if (jbed_compiler_verify(&driver, &probe, &error) || error.kind != JBED_ERROR_OUT_OF_MEMORY ||
            probe.has_error)
            return 5;
    }
    if (!jbed_compiler_compile(&driver, &error) ||
        !jbed_compiler_flush_fixups(&driver, writer.cursor, &error) ||
        !jbed_compiler_done(&driver, true, &error))
        raise_error(NULL, &error);
    if (runtime.registered_classes != &tables.access || !tables.access.all_classes)
        return 4;
    JbedClass *owner = jbed_class_object(runtime.registered_classes, id);
    JbedMethod *method = owner->methods;
    if (!output || !method || !method->code_address || !method->generated_size || coder.writer)
        return 4;
    uint32_t start = method->code_address & ~UINT32_C(1);
    JbedMethod *sum = method->next;
    uint32_t count = method->generated_size;
    if (argc == 2) {
        if (!sum || !sum->generated_size || sum->next)
            return 4;
        count = (sum->code_address & ~UINT32_C(1)) + sum->generated_size - start;
    } else if (sum) {
        return 4;
    }
    write_u32(start);
    write_u32(count);
    write_u32(argc == 2 ? 2 : 0);
    write_u32(ROM_BASE);
    if (fwrite(output->data + start - output->address, 1, count, stdout) != count)
        return 3;
    if (!jbed_compiler_start(&driver, 4, true, NULL, NULL, 1, 0, &error) ||
        !driver.has_coder || !coder.long_jumps || coder.debug_mode != 4 ||
        owner->dynamic_class_access != runtime.registered_classes ||
        jbed_class_object(runtime.registered_classes, id) != owner ||
        jbed_class_next(&tables.access, NULL) ||
        !jbed_compiler_reset(&driver, &error) || driver.has_coder)
        return 5;
    jbed_writer_dispose(&writer);
    return 0;
}
