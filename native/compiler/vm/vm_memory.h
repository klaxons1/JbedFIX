#ifndef JBED_VM_MEMORY_H
#define JBED_VM_MEMORY_H

#include "writer.h"

typedef struct JbedVmHeap JbedVmHeap;
struct JbedVmCollector;
struct JbedVmCompactor;

#define JBED_ARRAY_TAG UINT32_C(0x80000000)
#define JBED_HEAP_BLOCK_MASK UINT32_C(31)

enum {
    JBED_HEAP_BLOCK_SHIFT = 5,
    JBED_HEAP_BLOCK_BYTES = 1 << JBED_HEAP_BLOCK_SHIFT,
    JBED_TAG_POINTER_MAP_OFFSET = 22,
    JBED_TAG_SUPERCLASS_SLOTS = 4,
    JBED_ISOLATE_ID = 16,
    JBED_ISOLATE_STATE = 20,
    JBED_ISOLATE_ACTIVE = 24,
    JBED_ISOLATE_STATICS = 80,
    JBED_ISOLATE_POINTER_RANGES = 84,
    JBED_ISOLATE_FINALIZERS = 104,
    JBED_ISOLATE_FINALIZER_QUEUES = 108
};

enum {
    JBED_ISOLATE_STATE_CREATED = 0,
    JBED_ISOLATE_STATE_REGISTERED = 1,
    JBED_ISOLATE_STATE_INITIALIZED = 2,
    JBED_ISOLATE_STATE_EXITING = 3,
    JBED_ISOLATE_STATE_EXITED = 4,
    JBED_ISOLATE_STATE_REMOVED = 5
};

enum {
    JBED_OBJECT_MARKED = 1,
    JBED_OBJECT_PINNED = 2,
    JBED_OBJECT_LOCK_UNIT = 0x10,
    JBED_OBJECT_LOCK_MASK = 0xf0,
    JBED_ARRAY_ELEMENT_SHIFT_MASK = 3,
    JBED_ARRAY_REFERENCES = 0x100
};

/* C call-frame roots, corresponding to live Java stack slots in the ROM. */
typedef struct JbedVmHeapRoot {
    JbedAddress value, relocated;
    struct JbedVmHeapRoot *previous;
} JbedVmHeapRoot;

/* Services outside Memory: the collector's root set and soft references, the
 * compactor, OS heap reservation, and Throwable's saved Java frames. */
typedef struct JbedVmHeapServices {
    void *context;
    void (*collect)(void *, JbedVmHeap *, bool clear_soft_references);
    void (*compact)(void *, JbedVmHeap *);
    bool (*reserve_chunk)(void *, uint32_t requested, JbedAddress *raw, uint32_t *size);
    void (*release_chunk)(void *, JbedAddress raw, uint32_t size);
    void (*fill_trace)(void *, JbedAddress *throwable);
} JbedVmHeapServices;

typedef enum JbedHeapFault {
    JBED_HEAP_OK,
    JBED_HEAP_OUT_OF_MEMORY,
    JBED_HEAP_NEGATIVE_ARRAY,
    JBED_HEAP_NULL_POINTER,
    JBED_HEAP_INSTANTIATION_ERROR,
    JBED_HEAP_BAD_CLASS_TAG,
    JBED_HEAP_ALLOCATION_DISABLED,
    JBED_HEAP_MISSING_TRACE,
    JBED_HEAP_LOCK_COUNT,
    JBED_HEAP_PIN_ALREADY_PENDING,
    JBED_HEAP_BAD_FREE_LIST
} JbedHeapFault;

struct JbedVmHeap {
    JbedBuffer memory; /* Mapped target data, including classes, tags and heap chunks. */
    JbedVmHeapServices services;
    struct JbedVmCollector *collector;
    struct JbedVmCompactor *compactor;
    JbedVmHeapRoot *temporary_roots;
    JbedAddress chunk_tag, int_array_tag, sentinel;
    JbedAddress first_chunk, heap_start, heap_end, free_list;
    JbedAddress last_predecessor; /* Zero denotes the free_list head slot. */
    uint32_t last_size, failed_size, free_count;
    uint32_t heap_size, allocated, usage, max_allocated, max_total_usage, max_vm_usage;
    uint32_t freed_objects, live_objects, soft_references, allocation_failures;
    JbedAddress current_isolate, finalized;
    int allocation_end; /* -1 allocates from the end; +1 pins the next allocation. */
    bool collecting, accounting_disabled, trace_usage;
    int32_t no_allocation, collector_test_threshold;
    int32_t runtime_collector_test_threshold;
    bool collector_test_initialized;
    uint32_t trace_allocations;
    uint32_t identity_hash_state;
    uint64_t collector_test_seed;
    JbedHeapFault fault;
};

typedef struct JbedVmHeapImage {
    JbedAddress chunk_tag, int_array_tag, free_list_sentinel;
} JbedVmHeapImage;

void jbed_vm_heap_init_image(JbedVmHeap *, JbedBuffer, JbedVmHeapImage);
void jbed_vm_heap_init(JbedVmHeap *, JbedBuffer, JbedAddress rom_base);
bool jbed_vm_heap_add_chunk(JbedVmHeap *, JbedAddress raw, uint32_t size, bool lockable);
bool jbed_vm_heap_sort_chunks(JbedVmHeap *, bool locked_first);
bool jbed_vm_heap_release_empty_chunk(JbedVmHeap *, JbedAddress chunk);
void jbed_vm_heap_shutdown(JbedVmHeap *);
JbedAddress jbed_vm_heap_try_alloc(JbedVmHeap *, uint32_t bytes);
void jbed_vm_collector_test(JbedVmHeap *, int32_t threshold);
JbedAddress jbed_vm_heap_find_table(const JbedVmHeap *, JbedAddress object);
int32_t jbed_vm_identity_hash(JbedVmHeap *, JbedAddress object);
uint32_t jbed_vm_heap_largest_free(const JbedVmHeap *);
uint32_t jbed_vm_object_size(const JbedVmHeap *, JbedAddress object);
JbedAddress jbed_vm_finalizer_link(const JbedVmHeap *, JbedAddress object);
void jbed_vm_heap_sweep(JbedVmHeap *);

/* Class addresses are resident or pinned throughout allocation. KNI entry points
 * return null on a size/allocation error. Managed calls expose the Java error
 * through heap->fault so the hosting VM can throw in its own execution frame. */
JbedAddress jbed_vm_new_object(JbedVmHeap *, JbedAddress klass);
JbedAddress jbed_vm_new_array(JbedVmHeap *, int32_t length, JbedAddress klass);
JbedAddress jbed_vm_kni_new_object(JbedVmHeap *, JbedAddress klass);
JbedAddress jbed_vm_kni_new_array(JbedVmHeap *, int32_t length, JbedAddress klass);
/* Memory.resize is used for primitive scratch arrays in the pool, reader,
 * writer and string code. Growth across a block boundary returns an empty array. */
JbedAddress jbed_vm_resize_array(JbedVmHeap *, JbedAddress array, uint32_t length);
JbedAddress jbed_vm_struct_copy(JbedVmHeap *, JbedAddress prototype);
JbedAddress jbed_vm_new_array_n(JbedVmHeap *, int32_t length, JbedAddress prototype,
                               JbedAddress array_class);
bool jbed_vm_next_allocate_locked(JbedVmHeap *);
bool jbed_vm_lock_object(JbedVmHeap *, JbedAddress object);
bool jbed_vm_unlock_object(JbedVmHeap *, JbedAddress object);

#endif
