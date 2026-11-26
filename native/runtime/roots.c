#include "roots.h"
#include "arm32.h"
#include "scheduler.h"
#include "../compiler/vm/vm_words.h"

#include <stddef.h>
#include <stdlib.h>

bool jbed_vm_next_native_root(JbedVm *vm, void ***cursor, void **end, JbedVmNativeRoot *root)
{
    void **record = *cursor;
    if (record == end) return false;
    JbedAddress entry = (JbedAddress)(uintptr_t)*record;
    root->record = record;
    root->interior = NULL;
    if (entry == JBED_NATIVE_ROOT_INTERIOR) {
        if (end - record < 3)
            jbed_vm_fatal(vm, "Truncated native interior-pointer root");
        root->slot = (JbedAddress *)&record[2];
        root->interior = record[1];
        *cursor = record + 3;
    } else {
        if (entry == JBED_NATIVE_ROOT_INVALID)
            jbed_vm_fatal(vm, "Unexpected native root marker");
        root->slot = *record;
        *cursor = record + 1;
    }
    return true;
}

void jbed_vm_fix_native_pointers(JbedVm *vm, void **begin, void **end)
{
    JbedVmNativeRoot root;
    void **cursor = begin;
    while (jbed_vm_next_native_root(vm, &cursor, end, &root)) {
        if (!root.interior) continue;
        JbedVmNativeRoot earlier;
        void **previous = begin;
        bool duplicate = false;
        while (jbed_vm_next_native_root(vm, &previous, root.record, &earlier)) {
            if (earlier.interior != root.interior) continue;
            *root.slot = *earlier.slot;
            duplicate = true;
            break;
        }
        if (!duplicate) *root.interior += *root.slot;
    }
}

static void visit_activation(JbedVm *vm, JbedArm32Frame *saved, const JbedVmRootVisitor *visitor)
{
    if (!saved)
        return;
    JbedAddress address = vm->heap.memory.address +
        (uint32_t)((uintptr_t)saved - (uintptr_t)vm->heap.memory.data);
    JbedVmStackRoots frame = {.sp = saved->sp, .fp = saved->r[7], .pc = saved->lr,
        .register_slots = {
            address + offsetof(JbedArm32Frame, r[4]),
            address + offsetof(JbedArm32Frame, r[5]),
            address + offsetof(JbedArm32Frame, r[6])
        }};
    jbed_vm_traverse_frames(&vm->stack_maps, frame, visitor);
}

void jbed_vm_visit_arm_roots(JbedVm *vm, JbedArm32Context *arm, const JbedVmRootVisitor *visitor)
{
    if (!arm)
        return;
    visit_activation(vm, arm->frame, visitor);
    for (JbedArm32Activation *activation = arm->activations;
         activation; activation = activation->previous)
        visit_activation(vm, activation->caller_frame, visitor);
}

void jbed_vm_visit_managed_roots(JbedVm *vm, const JbedVmRootVisitor *visitor)
{
    jbed_vm_visit_arm_roots(vm, vm->arm, visitor);
}

void jbed_vm_visit_source_stacks(void *context, const JbedVmRootVisitor *local,
                                const JbedVmRootVisitor *global)
{
    JbedVm *vm = context;
    bool in_isolate = vm->heap.current_isolate &&
        *jbed_vm_at(vm->heap.memory, vm->heap.current_isolate + JBED_ISOLATE_ACTIVE);
    const JbedVmRootVisitor *active = in_isolate ? local : global;
    jbed_vm_visit_arm_roots(vm, vm->arm, active);
    jbed_vm_scheduler_visit_roots(vm, local, global);
}

static int compare_root(const void *left, const void *right)
{
    JbedAddress a = ((const JbedVmStaticRoot *)left)->slot;
    JbedAddress b = ((const JbedVmStaticRoot *)right)->slot;
    return (a > b) - (a < b);
}

void jbed_vm_bind_static_roots(JbedVm *vm, const JbedBootImage *image)
{
    size_t capacity = 0;
    for (size_t i = 0; i < image->class_count; ++i) {
        JbedClass *klass = jbed_class_object(&vm->classes, image->classes[i].id);
        if (klass) capacity += klass->field_count;
    }
    vm->static_roots = jbed_alloc(&vm->services, capacity * sizeof(*vm->static_roots));
    vm->native_static_roots = jbed_alloc(&vm->services, capacity * sizeof(*vm->native_static_roots));
    vm->static_root_count = 0;
    vm->native_static_root_count = 0;
    for (size_t i = 0; i < image->class_count; ++i) {
        JbedClass *klass = jbed_class_object(&vm->classes, image->classes[i].id);
        for (JbedField *field = klass ? klass->fields : NULL; field; field = field->next) {
            if ((field->flags & (JBED_ACC_STATIC | JBED_FIELD_CONSTANT)) != JBED_ACC_STATIC ||
                field->type_id < 16)
                continue;
            bool global = !(field->flags & JBED_FIELD_RELATIVE_STATIC);
            if (!global && vm->isolate_roots_owned)
                continue;
            JbedAddress slot = field->offset + (global ? 0 : vm->isolate_statics);
            if (slot >= vm->heap.memory.address &&
                (uint64_t)slot + sizeof(JbedAddress) <=
                    (uint64_t)vm->heap.memory.address + vm->heap.memory.size)
                vm->static_roots[vm->static_root_count++] = (JbedVmStaticRoot){slot, global};
            else
                vm->native_static_roots[vm->native_static_root_count++] = (JbedAddress *)(uintptr_t)slot;
        }
    }
    qsort(vm->static_roots, vm->static_root_count, sizeof(*vm->static_roots), compare_root);
    size_t count = 0;
    for (size_t i = 0; i < vm->static_root_count; ++i)
        if (!count || vm->static_roots[i].slot != vm->static_roots[count - 1].slot)
            vm->static_roots[count++] = vm->static_roots[i];
    vm->static_root_count = count;
}

void jbed_vm_bind_global_roots(JbedVm *vm, const JbedBootImage *image)
{
    vm->isolate_roots_owned = true;
    jbed_vm_bind_static_roots(vm, image);
}

void jbed_vm_visit_runtime_roots(void *context, const JbedVmRootVisitor *local,
                               const JbedVmRootVisitor *global)
{
    JbedVm *vm = context;
    for (size_t i = 0; i < vm->static_root_count; ++i) {
        const JbedVmStaticRoot *root = &vm->static_roots[i];
        const JbedVmRootVisitor *visitor = root->global ? global : local;
        visitor->stack_reference(visitor->context, root->slot);
    }
    if (vm->strings.character_root)
        local->stack_reference(local->context, vm->strings.character_root);
}
