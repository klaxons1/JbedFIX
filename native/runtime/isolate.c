#include "isolate.h"
#include "arithmetic.h"
#include "execution.h"
#include "metadata_init.h"
#include "monitor_init.h"
#include "compiler.h"
#include "scheduler.h"
#include "bundle.h"
#include "rom_reflection.h"
#include "../compiler/vm/vm_words.h"

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

enum {
    ISOLATE_CAPACITY = 25,
    SIGNAL_FLAGS_PER_ISOLATE = 2,
    DEFAULT_PRIORITY = 5, MIN_PRIORITY = 1, MAX_PRIORITY = 10,
    ARRAY_LENGTH = 12, ARRAY_DATA = 16,
    SCHEDULER_CYCLE_US = 500000, MIN_TIME_SLICE_US = 20000, MAX_TIME_SLICE_US = 200000,
    MICROS_PER_MILLI = 1000
};

_Static_assert(sizeof(JbedRomIsolate) == 132, "Isolate fields");
_Static_assert(offsetof(JbedRomIsolate, statics) == JBED_ISOLATE_STATICS, "Isolate statics");
_Static_assert(offsetof(JbedRomIsolate, ptrRanges) == JBED_ISOLATE_POINTER_RANGES, "Isolate roots");
_Static_assert(offsetof(JbedRomIsolate, finList) == JBED_ISOLATE_FINALIZERS, "Isolate finalizers");

typedef struct Registry {
    JbedAddress isolates, ready, signalFlags, signalFlagsAdr;
    JbedAddress isolateCount, idShift, indexMask, IDcounter;
    JbedAddress minPriority, maxPriority, prioritySum;
    JbedAddress baseTimeSlice, extraTimeSlice, allocExtraTime;
} Registry;

static Registry registry(JbedVm *vm)
{
    Registry result;
#define SLOT(name) do { \
    result.name = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SuperScheduler", #name); \
    if (!result.name) jbed_vm_fatal(vm, "SuperScheduler static field is absent: " #name); \
} while (0)
    SLOT(isolates); SLOT(ready); SLOT(signalFlags); SLOT(signalFlagsAdr);
    SLOT(isolateCount); SLOT(idShift); SLOT(indexMask); SLOT(IDcounter);
    SLOT(minPriority); SLOT(maxPriority); SLOT(prioritySum);
    SLOT(baseTimeSlice); SLOT(extraTimeSlice); SLOT(allocExtraTime);
#undef SLOT
    return result;
}

static JbedRomIsolate *isolate_object(JbedVm *vm, JbedAddress object)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return (JbedRomIsolate *)jbed_vm_at(vm->heap.memory, object);
}

static JbedAddress required_class(JbedVm *vm, const char *name)
{
    JbedAddress klass = jbed_vm_find_class(vm, name);
    if (!klass) jbed_vm_fatal(vm, "Isolate startup class is absent");
    return klass;
}

static JbedAddress callback(JbedVm *vm, const char *owner, const char *name,
                             JbedSignatureId signature)
{
    JbedAddress address = required_class(vm, owner);
    JbedClass *klass = jbed_class_object(&vm->classes, jbed_vm_word(vm->heap.memory, address + 16));
    JbedNameId id = jbed_reflection_id(&vm->method_names, (const uint8_t *)name, strlen(name), false);
    for (JbedMethod *method = klass ? klass->methods : NULL; method; method = method->next)
        if (method->name_id == id && (!signature || method->signature_id == signature) &&
            method->code_address)
            return method->code_address;
    jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, name);
}

JbedAddress Isolate_switchTo(JbedAddress address)
{
    JbedVm *vm = jbed_vm_current();
    return jbed_vm_switch_statics(vm, isolate_object(vm, address)->statics + ARRAY_DATA);
}

static void initialize_bundle(void *context)
{
    JbedVm *vm = context;
    ClassAccess_initClassAccess();
    if (!vm->pending_exception) Isolate_initBundle(0);
}

void Isolate_run(JbedAddress address)
{
    JbedVm *vm = jbed_vm_current();
    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedError error;
    bool initialized = vm->services.protected_call(vm->services.context, initialize_bundle, vm, &error);
    vm->heap.temporary_roots = &root;
    if (!initialized || vm->pending_exception) {
        JbedAddress throwable = initialized ? vm->pending_exception : jbed_vm_error_throwable(vm, &error);
        JbedVmHeapRoot exception = {throwable, throwable, &root};
        vm->heap.temporary_roots = &exception;
        vm->pending_exception = 0;
        isolate_object(vm, root.value)->isExceptionThrown = true;
        uint64_t ignored;
        JbedAddress print = callback(vm, "java/lang/Throwable", "printStackTrace", JBED_SIGNATURE_VOID_NO_ARGS);
        if (jbed_vm_invoke(vm, print, &exception.value, 1, &ignored)) {
            JbedAddress quit = callback(vm, "com/jbed/runtime/Isolate", "quit", 0);
            uint32_t status = UINT32_MAX;
            (void)jbed_vm_invoke(vm, quit, &status, 1, &ignored);
        }
        vm->heap.temporary_roots = root.previous;
        return;
    }
    JbedAddress context_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Isolate", "context");
    JbedAddress context = jbed_vm_word(vm->heap.memory, context_slot);
    if (context) {
        enum { CONTEXT_RUN_SLOT = 20 };
        JbedAddress entry = jbed_vm_word(vm->heap.memory,
            jbed_vm_word(vm->heap.memory, context) + CONTEXT_RUN_SLOT);
        if (!entry) jbed_vm_raise(vm, JBED_ERROR_ABSTRACT_METHOD, "IsolateContext.run");
        uint64_t ignored;
        (void)jbed_vm_invoke(vm, entry, &context, 1, &ignored);
    } else {
        JbedAddress arguments = isolate_object(vm, root.value)->argv;
        if (!arguments) {
            arguments = jbed_vm_allocate_array(vm, required_class(vm, "[Ljava/lang/String;"), 0, false);
            isolate_object(vm, root.value)->argv = arguments;
        } else {
            static const uint16_t option[] = {'-', 'X', 'e', 'x', 'c', 'e', 'p', 't'};
            uint32_t count = jbed_vm_word(vm->heap.memory, arguments + ARRAY_LENGTH);
            for (uint32_t i = 0; i < count; ++i) {
                JbedAddress argument = jbed_vm_word(vm->heap.memory, arguments + ARRAY_DATA + 4 * i);
                if (!argument) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
                const JbString *text = (const JbString *)jbed_vm_at(vm->heap.memory, argument);
                if (text->length == (int32_t)(sizeof(option) / sizeof(*option)) &&
                    !memcmp(jb_string_chars(text), option, sizeof(option))) {
                    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduled", "printExceptions");
                    *jbed_vm_at(vm->heap.memory, slot) = 1;
                }
            }
        }
        Isolate_runMain(root.value, arguments);
    }
    vm->heap.temporary_roots = root.previous;
}

static JbedAddress pinned_array(JbedVm *vm, JbedAddress klass, int32_t count)
{
    if (!jbed_vm_next_allocate_locked(&vm->heap))
        jbed_vm_fatal(vm, "Isolate allocation already has a pending pin");
    return jbed_vm_allocate_array(vm, klass, count, false);
}

void jbed_vm_isolate_registry_init(JbedVm *vm)
{
    Registry r = registry(vm);
    JbedBuffer memory = vm->heap.memory;
    if (jbed_vm_word(memory, r.isolates))
        jbed_vm_fatal(vm, "SuperScheduler is already initialized");
    JbedAddress table = jbed_vm_allocate_array(vm,
        required_class(vm, "[Lcom/jbed/runtime/Isolate;"), ISOLATE_CAPACITY, false);
    jbed_vm_put_word(memory, r.isolates, table);
    unsigned shift = 0;
    while ((1u << shift) < ISOLATE_CAPACITY) ++shift;
    jbed_vm_put_word(memory, r.idShift, shift);
    jbed_vm_put_word(memory, r.indexMask, (1u << shift) - 1);
    JbedAddress flags = pinned_array(vm, vm->primitive_array_classes[JBED_TYPE_BOOLEAN],
                                      SIGNAL_FLAGS_PER_ISOLATE * ISOLATE_CAPACITY);
    jbed_vm_put_word(memory, r.signalFlags, flags);
    jbed_vm_put_word(memory, r.signalFlagsAdr, flags + ARRAY_DATA);
    jbed_vm_put_word(memory, r.minPriority, MAX_PRIORITY);
    jbed_vm_put_word(memory, r.maxPriority, MIN_PRIORITY);
}

static int compare_offset(const void *left, const void *right)
{
    uint32_t a = *(const uint32_t *)left, b = *(const uint32_t *)right;
    return (a > b) - (a < b);
}

/* ptrRanges replaces the ROM's contiguous default reference range when the
 * source compiler assigns additional statics beyond the recovered offsets. */
static JbedAddress pointer_ranges(JbedVm *vm, const JbedBootImage *image)
{
    size_t capacity = 0;
    for (size_t i = 0; i < image->class_count; ++i) {
        JbedClass *klass = jbed_class_object(&vm->classes, image->classes[i].id);
        if (klass) capacity += klass->field_count;
    }
    uint32_t *offsets = jbed_alloc(&vm->services, capacity * sizeof(*offsets));
    size_t count = 0;
    for (size_t i = 0; i < image->class_count; ++i) {
        JbedClass *klass = jbed_class_object(&vm->classes, image->classes[i].id);
        for (JbedField *field = klass ? klass->fields : NULL; field; field = field->next) {
            if ((field->flags & (JBED_ACC_STATIC | JBED_FIELD_RELATIVE_STATIC | JBED_FIELD_CONSTANT)) !=
                (JBED_ACC_STATIC | JBED_FIELD_RELATIVE_STATIC) || field->type_id < 16)
                continue;
            if ((field->offset & 3) || (uint64_t)field->offset + 4 > image->statics_size)
                jbed_vm_fatal(vm, "Isolate reference field lies outside its statics");
            offsets[count++] = field->offset;
        }
    }
    qsort(offsets, count, sizeof(*offsets), compare_offset);
    size_t ranges = 0;
    for (size_t i = 0; i < count; ++i)
        if (!i || offsets[i] > offsets[i - 1] + 4) ++ranges;
    JbedAddress array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_INT],
                                               (int32_t)(2 * ranges), false);
    JbedAddress slot = array + ARRAY_DATA;
    for (size_t i = 0; i < count;) {
        uint32_t first = offsets[i], end = first + 4;
        while (++i < count && offsets[i] <= end) end = offsets[i] + 4;
        jbed_vm_put_word(vm->heap.memory, slot, first);
        jbed_vm_put_word(vm->heap.memory, slot + 4, end);
        slot += 8;
    }
    return array;
}

JbedAddress jbed_vm_isolate_new(JbedVm *vm, const JbedBootImage *image,
                               int32_t priority, bool native_notify)
{
    if (!image || !image->statics_size || image->statics_size > INT32_MAX)
        jbed_vm_fatal(vm, "Isolate requires a generated statics layout");
    JbedAddress klass = required_class(vm, "com/jbed/runtime/Isolate");
    if (jbed_vm_word(vm->heap.memory, klass + 28) != sizeof(JbedRomIsolate))
        jbed_vm_fatal(vm, "Isolate fields do not match the runtime");
    JbedAddress address = jbed_vm_allocate_object(vm, klass, false);
    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedRomIsolate *isolate = isolate_object(vm, root.value);
    isolate->state = JBED_ISOLATE_STATE_CREATED;
    isolate->nativeNotify = native_notify;
    isolate->priority = priority;
    JbedAddress statics = pinned_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE],
                                       (int32_t)image->statics_size);
    isolate_object(vm, root.value)->statics = statics;
    JbedAddress ranges = pointer_ranges(vm, image);
    isolate_object(vm, root.value)->ptrRanges = ranges;
    vm->heap.temporary_roots = root.previous;
    return root.value;
}

static int32_t multiply(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a * (uint32_t)b);
}

static void set_priority(JbedVm *vm, const Registry *r, JbedAddress address, int32_t priority)
{
    JbedBuffer memory = vm->heap.memory;
    JbedRomIsolate *isolate = isolate_object(vm, address);
    int32_t old = isolate->priority;
    isolate->priority = priority;
    int32_t maximum = (int32_t)jbed_vm_word(memory, r->maxPriority);
    if (priority >= maximum) maximum = priority;
    else if (old == maximum) {
        maximum = 0;
        JbedAddress head = jbed_vm_word(memory, r->ready), node = head;
        do {
            JbedRomIsolate *item = isolate_object(vm, node);
            if (item->priority > maximum) maximum = item->priority;
            node = item->nextIsolate;
        } while (node != head);
    }
    jbed_vm_put_word(memory, r->maxPriority, (uint32_t)maximum);
    int32_t minimum = (int32_t)jbed_vm_word(memory, r->minPriority);
    if (priority > 0 && priority <= minimum) minimum = priority;
    else if (old == minimum) {
        minimum = MAX_PRIORITY;
        if (!isolate->priority) isolate->priority = MAX_PRIORITY;
        JbedAddress head = jbed_vm_word(memory, r->ready), node = head;
        do {
            JbedRomIsolate *item = isolate_object(vm, node);
            if (item->priority < minimum) minimum = item->priority;
            node = item->nextIsolate;
        } while (node != head);
    }
    jbed_vm_put_word(memory, r->minPriority, (uint32_t)minimum);
    int32_t sum = (int32_t)(jbed_vm_word(memory, r->prioritySum) - (uint32_t)old + (uint32_t)priority);
    jbed_vm_put_word(memory, r->prioritySum, (uint32_t)sum);
    int32_t base = 0, extra = 0;
    bool allocate_extra = false;
    if (sum) {
        base = jbed_arm32_integer_divide(SCHEDULER_CYCLE_US, sum);
        if (multiply(base, minimum) >= MIN_TIME_SLICE_US) {
            if (multiply(base, maximum) > MAX_TIME_SLICE_US)
                base = jbed_arm32_integer_divide(MAX_TIME_SLICE_US, maximum);
        } else {
            base = MIN_TIME_SLICE_US;
            int32_t count = (int32_t)jbed_vm_word(memory, r->isolateCount);
            int32_t excess = (int32_t)((uint32_t)sum - (uint32_t)multiply(count, minimum));
            int32_t remaining = (int32_t)(SCHEDULER_CYCLE_US / MICROS_PER_MILLI -
                (uint32_t)multiply(MIN_TIME_SLICE_US / MICROS_PER_MILLI, count));
            if (excess && remaining)
                extra = jbed_arm32_integer_divide(multiply(MICROS_PER_MILLI, remaining), excess);
            allocate_extra = true;
        }
    }
    jbed_vm_put_word(memory, r->baseTimeSlice, (uint32_t)base);
    if (!sum || allocate_extra) jbed_vm_put_word(memory, r->extraTimeSlice, (uint32_t)extra);
    *jbed_vm_at(memory, r->allocExtraTime) = allocate_extra;
}

static void give_more_time(JbedVm *vm, const Registry *r, JbedRomIsolate *isolate)
{
    JbedBuffer memory = vm->heap.memory;
    int32_t allocation = (int32_t)jbed_vm_word(memory, r->baseTimeSlice);
    if (*jbed_vm_at(memory, r->allocExtraTime)) {
        int32_t extra = (int32_t)jbed_vm_word(memory, r->extraTimeSlice);
        int32_t delta = (int32_t)((uint32_t)isolate->priority - jbed_vm_word(memory, r->minPriority));
        if (extra > 0 && delta > 0)
            allocation = (int32_t)((uint32_t)allocation + (uint32_t)multiply(extra, delta));
    } else {
        allocation = multiply(allocation, isolate->priority);
    }
    isolate->allocation = allocation / MICROS_PER_MILLI;
    isolate->remainingAllocation = (int32_t)((uint32_t)isolate->remainingAllocation +
                                            (uint32_t)isolate->allocation);
}

int32_t jbed_vm_isolate_register(JbedVm *vm, JbedAddress address)
{
    Registry r = registry(vm);
    JbedBuffer memory = vm->heap.memory;
    JbedAddress table = jbed_vm_word(memory, r.isolates);
    if (!table) jbed_vm_fatal(vm, "SuperScheduler is not initialized");
    uint32_t count = jbed_vm_word(memory, r.isolateCount);
    uint32_t capacity = jbed_vm_word(memory, table + ARRAY_LENGTH);
    if (count == capacity) {
        vm->pending_exception = jbed_vm_new_throwable(vm, "com/jbed/runtime/NoMoreIsolatesException");
        return -1;
    }
    uint32_t index = 0;
    for (; index < capacity; ++index) {
        JbedAddress entry = jbed_vm_word(memory, table + ARRAY_DATA + 4 * index);
        if (!entry || isolate_object(vm, entry)->state == JBED_ISOLATE_STATE_REMOVED) break;
    }
    if (index == capacity) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    JbedRomIsolate *isolate = isolate_object(vm, address);
    int32_t priority = isolate->priority;
    jbed_vm_put_word(memory, table + ARRAY_DATA + 4 * index, address);
    isolate->listIndex = (int32_t)index;
    jbed_vm_put_word(memory, r.isolateCount, count + 1);
    JbedAddress head = jbed_vm_word(memory, r.ready);
    if (head) {
        JbedRomIsolate *first = isolate_object(vm, head);
        JbedAddress tail_address = first->prevIsolate;
        JbedRomIsolate *tail = isolate_object(vm, tail_address);
        isolate->prevIsolate = tail_address;
        if (tail->nextRunIsolate == tail->nextIsolate) tail->nextRunIsolate = address;
        tail->nextIsolate = address;
        first->prevIsolate = address;
        isolate->nextIsolate = head;
    } else {
        jbed_vm_put_word(memory, r.ready, address);
        isolate->nextIsolate = isolate->prevIsolate = address;
    }
    isolate->nextRunIsolate = isolate->nextIsolate;
    isolate->state = JBED_ISOLATE_STATE_REGISTERED;
    isolate->priority = 0;
    set_priority(vm, &r, address, priority);
    give_more_time(vm, &r, isolate);
    uint32_t shift = jbed_vm_word(memory, r.idShift) & 31;
    do {
        uint32_t counter = jbed_vm_word(memory, r.IDcounter);
        jbed_vm_put_word(memory, r.IDcounter, counter + 1);
        isolate->id = (int32_t)(index | counter << shift);
    } while (isolate->id == -1);
    return isolate->id;
}

JbedAddress jbed_vm_isolate_start_root(JbedVm *vm, const JbedBootImage *image, JbedAddress arguments)
{
    JbedVmHeapRoot argv = {arguments, arguments, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &argv;
    JbedAddress address = jbed_vm_isolate_new(vm, image, DEFAULT_PRIORITY, true);
    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedRomIsolate *isolate = isolate_object(vm, root.value);
    isolate->argv = argv.value;
    isolate->rootIsolate = true;
    int32_t id = jbed_vm_isolate_register(vm, root.value);
    vm->heap.temporary_roots = argv.previous;
    return id == -1 ? 0 : root.value;
}

static bool failed(char *error, size_t size, const char *message)
{
    if (error && size) snprintf(error, size, "%s", message);
    return false;
}

bool jbed_vm_isolate_activate_first(JbedVm *vm, JbedAddress address, uint32_t sync_slots,
                                    JbedAddress intern_table, JbedAddress character_root,
                                    char *error, size_t error_size)
{
    JbedRomIsolate *isolate = isolate_object(vm, address);
    if (isolate->state != JBED_ISOLATE_STATE_REGISTERED)
        return failed(error, error_size, "First activation requires a registered isolate");
    JbedAddress klass_address = required_class(vm, "com/jbed/runtime/Isolate");
    JbedClass *klass = jbed_class_object(&vm->classes, jbed_vm_word(vm->heap.memory, klass_address + 16));
    JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)"initIsolate", 11, false);
    JbedMethod *initializer = klass ? klass->methods : NULL;
    while (initializer && (initializer->name_id != name ||
                            initializer->signature_id != JBED_SIGNATURE_VOID_NO_ARGS))
        initializer = initializer->next;
    if (!initializer || !initializer->code_address)
        return failed(error, error_size, "Isolate.initIsolate is absent from the source image");

    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    isolate->oldStatics = jbed_vm_switch_statics(vm, isolate->statics + ARRAY_DATA);
    vm->heap.current_isolate = address;
    vm->isolate_id = isolate->id;
    if (vm->signals.hub)
        vm->signals.hub->isolates[isolate->listIndex] = vm;
    if (!jbed_vm_monitor_configure(vm, sync_slots, error, error_size)) {
        vm->heap.temporary_roots = root.previous;
        return false;
    }
    vm->strings = (JbedVmStrings){.heap = &vm->heap, .character_root = character_root,
        .image = {.string_class = vm->string_class,
            .char_array_class = vm->primitive_array_classes[JBED_TYPE_CHAR],
            .string_array_class = required_class(vm, "[Ljava/lang/String;"),
            .intern_table = intern_table,
            .static_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "staticHashtable"),
            .dynamic_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "hashtable")}};
    jbed_vm_put_word(vm->heap.memory, character_root, 0);
    vm->signals.queue_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "signalList");
    vm->signals.pending_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "signalPending");
    vm->signals.current_thread_slot = vm->monitors.image.current_slot;
    uint64_t ignored;
    bool returned = jbed_vm_invoke(vm, initializer->code_address, &root.value, 1, &ignored);
    address = root.value;
    vm->heap.temporary_roots = root.previous;
    if (!returned) return failed(error, error_size, "Isolate initialization threw a Java exception");
    if (isolate_object(vm, address)->state != JBED_ISOLATE_STATE_INITIALIZED)
        return failed(error, error_size, "Isolate initialization did not complete");
    return true;
}

typedef struct PointerRange { uint32_t first, end; } PointerRange;

static int compare_range(const void *left, const void *right)
{
    const PointerRange *a = left, *b = right;
    return (a->first > b->first) - (a->first < b->first);
}

static JbedAddress merge_pointer_ranges(JbedVm *vm, JbedAddress old,
                                         const uint32_t *ranges, uint32_t words)
{
    uint32_t old_words = old ? jbed_vm_word(vm->heap.memory, old + ARRAY_LENGTH) : 0;
    if ((old_words | words) & 1)
        jbed_vm_fatal(vm, "Static reference ranges require start/end pairs");
    size_t count = ((size_t)old_words + words) / 2;
    PointerRange *merged = jbed_alloc(&vm->services, count * sizeof(*merged));
    for (uint32_t i = 0; i < old_words; i += 2)
        merged[i / 2] = (PointerRange){jbed_vm_word(vm->heap.memory, old + ARRAY_DATA + 4 * i),
                                       jbed_vm_word(vm->heap.memory, old + ARRAY_DATA + 4 * (i + 1))};
    for (uint32_t i = 0; i < words; i += 2)
        merged[(old_words + i) / 2] = (PointerRange){ranges[i], ranges[i + 1]};
    qsort(merged, count, sizeof(*merged), compare_range);
    size_t used = 0;
    for (size_t i = 0; i < count; ++i) {
        if (used && merged[i].first <= merged[used - 1].end) {
            if (merged[i].end > merged[used - 1].end) merged[used - 1].end = merged[i].end;
        } else merged[used++] = merged[i];
    }
    JbedAddress array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_INT],
                                               (int32_t)(used * 2), false);
    for (size_t i = 0; i < used; ++i) {
        jbed_vm_put_word(vm->heap.memory, array + ARRAY_DATA + (uint32_t)i * 8, merged[i].first);
        jbed_vm_put_word(vm->heap.memory, array + ARRAY_DATA + (uint32_t)i * 8 + 4, merged[i].end);
    }
    return array;
}

void jbed_vm_isolate_extend_statics(JbedVm *vm, uint32_t bytes,
                                    const uint32_t *pointer_ranges, uint32_t range_words)
{
    JbedAddress address = vm->heap.current_isolate;
    JbedRomIsolate *isolate = isolate_object(vm, address);
    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress old = isolate->statics;
    uint32_t length = jbed_vm_word(vm->heap.memory, old + ARRAY_LENGTH);
    if (bytes > length) {
        if (bytes > INT32_MAX) jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
        JbedAddress replacement = pinned_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE], (int32_t)bytes);
        isolate = isolate_object(vm, root.value);
        old = isolate->statics;
        memcpy(jbed_vm_at(vm->heap.memory, replacement + ARRAY_DATA),
               jbed_vm_at(vm->heap.memory, old + ARRAY_DATA), length);
        isolate->statics = replacement;
        jbed_vm_compiler_rebase_statics(vm, old + ARRAY_DATA, replacement + ARRAY_DATA);
        jbed_vm_scheduler_rebase_statics(vm, old + ARRAY_DATA, replacement + ARRAY_DATA);
        for (JbedArm32Activation *activation = vm->arm ? vm->arm->activations : NULL;
             activation; activation = activation->previous)
            if (activation->caller_frame && activation->caller_frame->r[9] == old + ARRAY_DATA)
                activation->caller_frame->r[9] = replacement + ARRAY_DATA;
        jbed_vm_switch_statics(vm, replacement + ARRAY_DATA);
    }
    JbedAddress ranges = merge_pointer_ranges(vm, isolate_object(vm, root.value)->ptrRanges,
                                               pointer_ranges, range_words);
    isolate_object(vm, root.value)->ptrRanges = ranges;
    vm->heap.temporary_roots = root.previous;
}
