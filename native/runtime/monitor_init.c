#include "monitor_init.h"
#include "metadata_init.h"
#include "arm32.h"
#include "execution.h"
#include "scheduler.h"
#include "../compiler/vm/vm_scheduler.h"
#include "../platform/vm/vm_os.h"

#include <stdio.h>

static bool fail(char *error, size_t size, const char *message)
{
    if (error && size) snprintf(error, size, "%s", message);
    return false;
}

static uint64_t elapsed_micros(void *context)
{
    (void)context;
    return (uint64_t)OPL_os_getElapsedMicros();
}

bool jbed_vm_monitor_configure(JbedVm *vm, uint32_t sync_slots, char *error, size_t error_size)
{
    const char *scheduler = "com/jbed/runtime/Scheduler";
    const char *base = "com/jbed/runtime/Base";
    JbedAddress scheduled = jbed_vm_find_class(vm, "com/jbed/runtime/Scheduled");
    JbedAddress synchronizer = jbed_vm_find_class(vm, "com/jbed/runtime/Synchronizer");
    JbedAddress monitor_error = jbed_vm_find_class(vm, "java/lang/IllegalMonitorStateException");
    JbedAddress memory_error = jbed_vm_find_class(vm, "java/lang/OutOfMemoryError");
    if (!vm->arm || !scheduled || !synchronizer || !vm->object_array_class ||
        !monitor_error || !memory_error || !sync_slots)
        return fail(error, error_size, "Monitor bootstrap requires Scheduled, Synchronizer, exception classes and ROM lock slots");
    JbedBuffer memory = vm->heap.memory;
    if (jbed_vm_word(memory, scheduled + 28) != sizeof(JbedRomScheduled) ||
        jbed_vm_word(memory, synchronizer + 28) != sizeof(JbedRomSynchronizer))
        return fail(error, error_size, "Scheduled/Synchronizer layout does not match the VM runtime");

    JbedVmMonitorImage image = {
        .synchronizer_class = synchronizer,
        .synchronizer_array_class = vm->object_array_class,
        .synchronizer_tag_slot = jbed_vm_static_field_slot(vm, base, "synchronizerTag"),
        .illegal_monitor_error_slot = jbed_vm_static_field_slot(vm, base, "monitorStateEx"),
        .out_of_memory_error_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Memory", "outOfMemory"),
        .table_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Isolate", "synchArray"),
        .rom_slots = sync_slots,
        .current_slot = jbed_vm_static_field_slot(vm, scheduler, "current"),
        .ready_root_slot = jbed_vm_static_field_slot(vm, scheduler, "rtroot"),
        .time_slot = jbed_vm_static_field_slot(vm, scheduler, "time"),
        .timer_low_slot = jbed_vm_static_field_slot(vm, scheduler, "timerLow"),
        .timer_high_slot = jbed_vm_static_field_slot(vm, scheduler, "timerHigh")
    };
    if (!image.synchronizer_tag_slot || !image.illegal_monitor_error_slot ||
        !image.out_of_memory_error_slot || !image.table_slot || !image.current_slot ||
        !image.ready_root_slot || !image.time_slot || !image.timer_low_slot ||
        !image.timer_high_slot)
        return fail(error, error_size, "Monitor bootstrap is missing runtime static fields");
    jbed_vm_put_word(memory, image.synchronizer_tag_slot,
                     jbed_vm_word(memory, synchronizer + 36));
    vm->monitors = (JbedVmMonitors){.heap = &vm->heap, .isolate_statics = vm->isolate_statics,
                                   .image = image};
    vm->monitors.scheduling.runtime = &vm->services;
    vm->monitors.scheduling.elapsed_micros = elapsed_micros;
    vm->monitors.scheduling.context = vm;
    vm->monitors.scheduling.yield_to_scheduler = jbed_vm_schedule;
    vm->checkpoint = jbed_vm_scheduler_checkpoint;
    return true;
}

static JbedAddress current_scheduled(JbedVm *vm)
{
    JbedBuffer memory = vm->heap.memory;
    JbedAddress scheduled = jbed_vm_find_class(vm, "com/jbed/runtime/Scheduled");
    JbedAddress synchronizer = vm->monitors.image.synchronizer_class;
    JbedAddress ncss_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/NativeCallStateStack", "currentNcss");
    JbedAddress current = jbed_vm_new_object(&vm->heap, scheduled);
    if (!current) return 0;
    JbedVmHeapRoot root = {current, current, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(stackBase), (uint32_t)vm->arm->stack_top);
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(ofm), (uint32_t)vm->arm->stack_top);
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(ssp), (uint32_t)vm->arm->stack_top);
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(stackLimit), (uint32_t)vm->arm->stack_limit);
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(status), S_READY);
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(ncss), jbed_vm_word(memory, ncss_slot));
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(paramPtr), (uint32_t)(uintptr_t)Jbed_ParamPtr);
    JbedAddress lock = jbed_vm_new_object(&vm->heap, synchronizer);
    current = root.value;
    vm->heap.temporary_roots = root.previous;
    if (!lock) return 0;
    jbed_vm_put_word(memory, current + SCHEDULED_FIELD(synchronizer), lock);
    return current;
}

bool jbed_vm_base_bootstrap(JbedVm *vm, uint32_t sync_slots, char *error, size_t error_size)
{
    if (!jbed_vm_monitor_configure(vm, sync_slots, error, error_size)) return false;
    JbedBuffer memory = vm->heap.memory;
    JbedVmMonitorImage *image = &vm->monitors.image;
    JbedAddress exception = jbed_vm_new_throwable(vm, "java/lang/OutOfMemoryError");
    if (!exception) return fail(error, error_size, "Cannot allocate the reserved OutOfMemoryError");
    jbed_vm_put_word(memory, exception + 12, 0);
    jbed_vm_put_word(memory, image->out_of_memory_error_slot, exception);
    vm->out_of_memory = exception;
    exception = jbed_vm_new_throwable(vm, "java/lang/IllegalMonitorStateException");
    if (!exception) return fail(error, error_size, "Cannot allocate the reserved monitor exception");
    jbed_vm_put_word(memory, exception + 12, 0);
    jbed_vm_put_word(memory, image->illegal_monitor_error_slot, exception);
    if (!jbed_vm_exceptions_bootstrap(vm, error, error_size)) return false;

    enum { NCSS_BYTES = 256, BASE = 12, LIMIT = 16, ADDRESS = 20, FRAME = 24, BUFFER = 28 };
    JbedAddress klass = jbed_vm_find_class(vm, "com/jbed/runtime/NativeCallStateStack");
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/NativeCallStateStack", "currentNcss");
    JbedAddress dummy = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SuperScheduler", "dummy");
    if (!klass || !slot || !dummy)
        return fail(error, error_size, "Base bootstrap requires native state and VM scheduler classes");
    JbedAddress ncss = jbed_vm_allocate_object(vm, klass, false);
    jbed_vm_put_word(memory, slot, ncss);
    if (!jbed_vm_next_allocate_locked(&vm->heap))
        return fail(error, error_size, "Native state stack has a pending allocation pin");
    JbedAddress buffer = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE], NCSS_BYTES, false);
    ncss = jbed_vm_word(memory, slot);
    JbedAddress base = buffer + 16;
    jbed_vm_put_word(memory, ncss + BUFFER, buffer);
    jbed_vm_put_word(memory, ncss + BASE, base);
    jbed_vm_put_word(memory, ncss + LIMIT, base + NCSS_BYTES);
    jbed_vm_put_word(memory, ncss + ADDRESS, base + 4);
    jbed_vm_put_word(memory, ncss + FRAME, base + 4);
    vm->native_frames = (JbedVmNativeFrames){.base = base, .frame = base + 4,
        .address = base + 4, .limit = base + NCSS_BYTES};
    JbedAddress current = current_scheduled(vm);
    if (!current) return fail(error, error_size, "Cannot allocate the VM scheduler dummy");
    jbed_vm_put_word(memory, dummy, current);
    return true;
}

/* Diagnostic method-runner setup: a current thread and ready queue, without
 * starting the isolate's main Runnable. Full activation uses Isolate.initIsolate. */
bool jbed_vm_monitor_bootstrap(JbedVm *vm, uint32_t sync_slots, char *error, size_t error_size)
{
    if (!jbed_vm_monitor_configure(vm, sync_slots, error, error_size)) return false;
    JbedVmMonitorImage image = vm->monitors.image;
    JbedBuffer memory = vm->heap.memory;
    JbedAddress dummy_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "dummy");
    if (jbed_vm_word(memory, image.current_slot))
        return fail(error, error_size, "Scheduler is already initialized");
    JbedAddress table = jbed_vm_new_array(&vm->heap, (int32_t)sync_slots, vm->object_array_class);
    if (!table) return fail(error, error_size, "Cannot allocate the ROM monitor table");
    jbed_vm_put_word(memory, image.table_slot, table);
    JbedAddress current = current_scheduled(vm);
    if (!current) return fail(error, error_size, "Cannot allocate the initial Scheduled");
    jbed_vm_put_word(memory, image.current_slot, current);
    jbed_vm_put_word(memory, dummy_slot, current);
    JbedAddress root = jbed_vm_new_object(&vm->heap, jbed_vm_find_class(vm, "com/jbed/runtime/Scheduled"));
    if (!root) return fail(error, error_size, "Cannot allocate the scheduler queue root");
    jbed_vm_put_word(memory, image.ready_root_slot, root);
    xRTInsertSched(&vm->monitors, jbed_vm_word(memory, image.current_slot));
    uint64_t now = elapsed_micros(NULL);
    jbed_vm_put_word(memory, image.time_slot, (uint32_t)now);
    jbed_vm_put_word(memory, image.time_slot + 4, (uint32_t)(now >> 32));
    return true;
}
