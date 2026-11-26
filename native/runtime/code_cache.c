#include "code_cache.h"
#include "compiler.h"
#include "../compiler/rom_objects.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

typedef struct CodeBuffer {
    JbedBuffer buffer;
    size_t mapped_size;
    bool published;
    struct CodeBuffer *next;
} CodeBuffer;

struct JbedCodeCache {
    JbedVm *vm;
    JbedWriter writer;
    JbedWriterServices services;
    JbedRomServices rom;
    CodeBuffer *buffers;
    JbedExtendStatics extend_statics;
    void *statics_context;
    uint32_t map_id;
    size_t page_size;
};

static void fault(void *context, JbedWriterFault kind, const char *message)
{
    JbedVm *vm = ((JbedCodeCache *)context)->vm;
    if (kind == JBED_WRITER_OUT_OF_MEMORY || kind == JBED_WRITER_OUT_OF_CODE)
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, message);
    if (kind == JBED_WRITER_ARRAY_INDEX)
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, message);
    if (kind == JBED_WRITER_JAVA_ERROR)
        jbed_vm_raise(vm, JBED_ERROR_ERROR, message);
    jbed_vm_fatal(vm, message);
}

static JbedBuffer *new_buffer(void *context, uint32_t size)
{
    JbedCodeCache *cache = context;
    CodeBuffer *block = calloc(1, sizeof(*block));
    if (!block) return NULL;
    size_t rounded = ((size_t)size + cache->page_size - 1) & ~(cache->page_size - 1);
    if (rounded < size) {
        free(block);
        return NULL;
    }
    void *data = mmap(NULL, rounded, PROT_READ | PROT_WRITE,
                      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (data == MAP_FAILED) {
        free(block);
        return NULL;
    }
    block->buffer = (JbedBuffer){data, size, (JbedAddress)(uintptr_t)data};
    block->mapped_size = rounded;
    block->next = cache->buffers;
    cache->buffers = block;
    return &block->buffer;
}

static JbedBuffer *resize_buffer(void *context, JbedBuffer *buffer, uint32_t size)
{
    if (size > buffer->size)
        fault(context, JBED_WRITER_ASSERTION, "Code buffer grew while being finalized");
    buffer->size = size;
    return buffer;
}

static void attach_code(void *context, JbedCodeOwner *owner, JbedBuffer *buffer)
{
    /* The cache retains code until isolate teardown, including blocks shared
     * by several methods. No managed object can move or free these mappings. */
    (void)context;
    (void)owner;
    (void)buffer;
}

static void flush_cache(void *context, JbedAddress address, uint32_t size)
{
    (void)context;
    char *start = (char *)(uintptr_t)address;
    __builtin___clear_cache(start, start + size);
}

static void extend_statics(void *context, uint32_t size, const uint32_t *ranges, uint32_t count)
{
    JbedCodeCache *cache = context;
    cache->extend_statics(cache->statics_context, size, ranges, count);
}

static uint32_t stack_map_id(void *context)
{
    return ((JbedCodeCache *)context)->map_id;
}

static void add_stack_map(void *context, JbedAddress address, uint32_t id)
{
    JbedCodeCache *cache = context;
    jbed_vm_stack_map_add(&cache->vm->stack_maps, address, id);
}

JbedCodeCache *jbed_code_cache_create(JbedVm *vm, JbedExtendStatics extend, void *context)
{
    if (!extend) return NULL;
    jbed_vm_compiler_driver(vm);
    JbedCodeCache *cache = calloc(1, sizeof(*cache));
    if (!cache) return NULL;
    cache->vm = vm;
    cache->extend_statics = extend;
    cache->statics_context = context;
    cache->page_size = (size_t)sysconf(_SC_PAGESIZE);
    cache->map_id = jbed_vm_stack_map_id(&vm->stack_maps);
    cache->rom = (JbedRomServices){.runtime = &vm->services,
        .class_access = jbed_vm_compiler_classes(vm)};
    cache->services = (JbedWriterServices){.context = cache, .fault = fault,
        .new_code_buffer = new_buffer, .resize_code_buffer = resize_buffer,
        .attach_code = attach_code, .flush_cache = flush_cache,
        .extend_statics = extend_statics, .stack_map_id = stack_map_id,
        .add_stack_map = add_stack_map, .rom_services = &cache->rom};
    jbed_writer_init(&cache->writer, &cache->services);
    return cache;
}

JbedWriter *jbed_code_cache_writer(JbedCodeCache *cache)
{
    return &cache->writer;
}

bool jbed_code_cache_publish(JbedCodeCache *cache, char *error, size_t error_size)
{
    if (cache->writer.buffer) {
        if (error && error_size)
            snprintf(error, error_size, "Compiler has not finalized its code buffers");
        return false;
    }
    for (CodeBuffer *block = cache->buffers; block; block = block->next) {
        if (block->published) continue;
        flush_cache(cache, block->buffer.address, block->buffer.size);
        if (mprotect(block->buffer.data, block->mapped_size, PROT_READ | PROT_EXEC)) {
            if (error && error_size)
                snprintf(error, error_size, "Cannot publish compiled code: %s", strerror(errno));
            return false;
        }
        block->published = true;
    }
    return true;
}

void jbed_code_cache_destroy(JbedCodeCache *cache)
{
    if (!cache) return;
    jbed_vm_stack_maps_remove(&cache->vm->stack_maps, cache->map_id);
    jbed_writer_dispose(&cache->writer);
    CodeBuffer *block = cache->buffers;
    while (block) {
        CodeBuffer *next = block->next;
        munmap(block->buffer.data, block->mapped_size);
        free(block);
        block = next;
    }
    free(cache);
}
