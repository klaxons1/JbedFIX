#include "guest_rom.h"
#include "memory.h"
#include "guest_call.h"
#include "arm32.h"
#include "rom_reflection.h"
#include "metadata_init.h"
#include <string.h>
#include "../compiler/vm/vm_words.h"

/* Original RomObjects 0x132ba0/0x132be4/0x132c28 call the lazy array
 * getters before exposing their payload addresses. The arrays must be pinned:
 * these return values are Java ints, not GC-tracked references. */
static JbedAddress statics_base(JbRef self, uint32_t offset, bool pointers)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "RomObjects outside a Jbed VM");
    if (!self) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedAddress array = jbed_vm_word(vm->heap.memory, self + offset);
    if (!array) {
        JbedVmHeapRoot root = {self, self, vm->heap.temporary_roots};
        vm->heap.temporary_roots = &root;
        Memory_nextAllocateLocked();
        array = jbed_vm_allocate_array(vm, pointers ? vm->object_array_class
            : vm->primitive_array_classes[JBED_TYPE_BYTE], 0, false);
        jbed_vm_put_word(vm->heap.memory, root.value + offset, array);
        vm->heap.temporary_roots = root.previous;
    }
    return array + 16;
}

JbedAddress RomObjects_getPrimStaticsBase(JbRef self) { return statics_base(self, 76, false); }
JbedAddress RomObjects_getPtrStaticsBase(JbRef self) { return statics_base(self, 80, true); }
JbedAddress RomObjects_getInitFlagsBase(JbRef self) { return statics_base(self, 84, false); }

/* Isolate.getContext, original 0xdc6b0. +980 is the resident isolate
 * statics slot, whereas +96 holds the context before/after activation. */
JbRef Isolate_getContext(JbRef self)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Isolate outside a Jbed VM");
    if (!self) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedAddress slot = self + 96;
    if (jbed_vm_word(vm->heap.memory, self + 20) == 2)
        slot = jbed_vm_word(vm->heap.memory, self + 80) + 980;
    return jbed_vm_word(vm->heap.memory, slot);
}

static uint32_t get(JbedVm *vm, JbRef object, uint32_t offset)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_word(vm->heap.memory, object + offset);
}

void Isolate_deliverEvent(JbRef self, int32_t index, int32_t event)
{
    JbedVm *vm = jbed_vm_current();
    if (get(vm, self, 20) != 2) return;
    JbRef signals = jbed_vm_word(vm->heap.memory, get(vm, self, 80) + 984);
    if (!signals || index >= (int32_t)get(vm, signals, 12)) return;
    if (index < 0) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    JbRef signal = get(vm, signals, 16 + 4u * (uint32_t)index);
    if (signal) {
        uint32_t args[] = {signal, (uint32_t)event};
        jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/runtime/SignalQueue", "addEvent", "(I)V", args, 2);
    }
}

int32_t Isolate_startTransition(JbRef self, int32_t requested, int32_t status)
{
    JbedVm *vm = jbed_vm_current();
    int32_t current = (int32_t)get(vm, self, 124);
    if (current == requested) {
        jbed_vm_put_word(vm->heap.memory, self + 128, (uint32_t)current);
        return 1;
    }
    if (requested > current) {
        JbedAddress control = get(vm, self, 120);
        if (control) jbed_vm_put_word(vm->heap.memory, self + 116, jbed_vm_word(vm->heap.memory, control));
        if (requested > (int32_t)get(vm, self, 116)) return 2;
    }
    jbed_vm_put_word(vm->heap.memory, self + 128, (uint32_t)requested);
    uint32_t args[] = {self, false, (uint32_t)current, (uint32_t)requested, (uint32_t)status};
    jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/runtime/Isolate", "notify", "(ZIII)Z", args, 5);
    return 0;
}

static void writer_call(JbedVm *vm, JbRef self, const char *name, const char *signature,
                        uint32_t address, uint32_t value, bool extra)
{
    uint32_t args[] = {get(vm, self, 96), address, value, false};
    jbed_vm_guest_call(vm, JBED_GUEST_VIRTUAL, NULL, name, signature, args, extra ? 4 : 3);
}

/* 0x132cb0: resident classes use absolute pointers, newly written classes use
 * Writer labels. A Java Class object must never be cast to a host JbedClass. */
void RomObjects_writeClassObj(JbRef self, JbedAddress address, JbRef klass)
{
    JbedVm *vm = jbed_vm_current();
    if (!klass || Memory_isReadOnlyObject(klass))
        writer_call(vm, self, "writeInt", "(II)V", address, klass, false);
    else {
        uint32_t label = get(vm, klass, 68);
        if (!label) jbed_vm_fatal(vm, "RomObjects: class has no writer label");
        writer_call(vm, self, "writeLabel", "(II)I", address, label, false);
    }
}

static bool exception_entry(JbedVm *vm, JbedAddress entry)
{
    if (entry == (JbedAddress)(uintptr_t)jbed_arm32_throw_abstract ||
        entry == (JbedAddress)(uintptr_t)jbed_arm32_throw_no_class) return true;
    JbedClass *klass = jbed_class_from_target(&vm->classes,
        jbed_vm_find_class(vm, "com/jbed/runtime/ArchBase"));
    const char *names[] = {"throwAbstract", "throwNoClass"};
    for (unsigned i = 0; klass && i < 2; ++i) {
        JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)names[i], strlen(names[i]), false);
        for (JbedMethod *m = klass->methods; m; m = m->next)
            if (m->name_id == name && m->signature_id == JBED_SIGNATURE_VOID_NO_ARGS &&
                (entry & ~1u) == (m->code_address & ~1u)) return true;
    }
    return false;
}

void RomObjects_writeCodeAdr(JbRef self, JbedAddress address, JbedAddress code)
{
    JbedVm *vm = jbed_vm_current();
    if (!code || exception_entry(vm, code))
        writer_call(vm, self, "writeInt", "(II)V", address, code, false);
    else writer_call(vm, self, "writeReloc", "(IIZ)V", address, code, true);
}

/* 0x132da0. Reload writer/class addresses after each managed call: the hashCode
 * override and writer overrides can allocate and move either receiver. */
void RomObjects_genObjectHeader(JbRef self, JbedAddress address, JbRef source, bool hash, bool monitor)
{
    JbedVm *vm = jbed_vm_current();
    JbedVmHeapRoot object = {self, self, vm->heap.temporary_roots};
    JbedVmHeapRoot from = {source, source, &object};
    vm->heap.temporary_roots = &from;
    writer_call(vm, object.value, "writeInt", "(II)V", address, get(vm, from.value, 0), false);
    uint32_t value = 0;
    if (hash) {
        uint32_t args[] = {from.value};
        value = (uint32_t)jbed_vm_guest_call(vm, JBED_GUEST_VIRTUAL, NULL, "hashCode", "()I", args, 1) << 8;
    }
    writer_call(vm, object.value, "writeInt", "(II)V", address + 4, value | 7, false);
    value = 1;
    if (monitor) {
        uint32_t index = get(vm, object.value, 28);
        jbed_vm_put_word(vm->heap.memory, object.value + 28, index + 1);
        value = (index * 2) | 1;
    }
    writer_call(vm, object.value, "writeInt", "(II)V", address + 8, value, false);
    vm->heap.temporary_roots = object.previous;
}

/* 0x133dec: install the newly generated bundle into the active isolate. */
void RomObjects_prepareCommon(JbRef self, JbRef code_block)
{
    JbedVm *vm = jbed_vm_current();
    JbedVmHeapRoot object = {self, self, vm->heap.temporary_roots};
    JbedVmHeapRoot block = {code_block, code_block, &object};
    JbedVmHeapRoot temporary = {0, 0, &block};
    vm->heap.temporary_roots = &temporary;
    uint32_t none[1];
    uint32_t sync = (uint32_t)jbed_vm_guest_call(vm, JBED_GUEST_STATIC,
        "com/jbed/runtime/SysInfo", "getSyncTableSize", "()I", none, 0);
    uint32_t extend[] = {get(vm, object.value, 28) - sync};
    jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/runtime/Isolate", "extendSynchArray", "(I)V", extend, 1);
    uint32_t statics[] = {get(vm, object.value, 64), get(vm, object.value, 72)};
    jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/runtime/Isolate", "extendStatics", "(I[I)V", statics, 2);
    JbRef strings = get(vm, object.value, 32);
    uint32_t count = get(vm, strings, 12);
    temporary.value = jbed_vm_allocate_array(vm, jbed_vm_find_class(vm, "[Ljava/lang/String;"), (int32_t)count, false);
    strings = get(vm, object.value, 32);
    for (uint32_t i = 0; i < count; ++i)
        jbed_vm_put_word(vm->heap.memory, temporary.value + 16 + 4 * i, get(vm, strings, 16 + 4 * i));
    JbedAddress table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "hashtable");
    jbed_vm_put_word(vm->heap.memory, table_slot, temporary.value);
    uint32_t map_id = (uint32_t)jbed_vm_guest_call(vm, JBED_GUEST_STATIC,
        "com/jbed/runtime/StackMapBlock", "getMapId", "()I", none, 0);
    for (uint32_t i = 0; (int32_t)i < (int32_t)get(vm, object.value, 92); ++i) {
        JbRef maps = get(vm, object.value, 88);
        if (i >= get(vm, maps, 12)) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
        uint32_t args[] = {get(vm, maps, 16 + 4 * i), map_id};
        jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/runtime/StackMapBlock", "add", "(II)V", args, 2);
    }
    ClassAccess_loadDynamicBundle((int32_t)get(vm, object.value, 60), get(vm, object.value, 44),
        get(vm, object.value, 36), get(vm, object.value, 40));
    if (*jbed_vm_at(vm->heap.memory, object.value + 112)) {
        const char *owners[] = {"com/jbed/reflect/Field", "com/jbed/reflect/Method", "com/jbed/reflect/SignatureEncoder"};
        const uint32_t offsets[] = {52, 48, 56};
        for (unsigned i = 0; i < 3; ++i) {
            temporary.value = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_STATIC, owners[i],
                "getReflTable", "()Lcom/jbed/reflect/ReflectionTable;", none, 0);
            ReflectionTable_referenceDynamicTable(temporary.value,
                (const uint8_t *)(uintptr_t)get(vm, object.value, offsets[i]));
        }
        if (jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/runtime/ConfigTraceBase", "traceDebugSymbols", "()Z", none, 0)) {
            JbedVmHeapRoot encoder = {0, 0, vm->heap.temporary_roots};
            JbedVmHeapRoot iterator = {0, 0, &encoder};
            JbedVmHeapRoot klass = {0, 0, &iterator};
            JbedVmHeapRoot method = {0, 0, &klass};
            vm->heap.temporary_roots = &method;
            JbedAddress class_slot = jbed_vm_static_field_slot(vm, "java/lang/Class", "classes");
            JbRef access = jbed_vm_word(vm->heap.memory, class_slot);
            encoder.value = jbed_vm_allocate_object(vm, jbed_vm_find_class(vm, "com/jbed/reflect/SignatureEncoder"), false);
            uint32_t init[] = {encoder.value, jbed_vm_word(vm->heap.memory, class_slot)};
            jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/reflect/SignatureEncoder", "<init>", "(Lcom/jbed/reflect/ClassAccess;)V", init, 2);
            access = jbed_vm_word(vm->heap.memory, class_slot);
            uint32_t classes[] = {access, get(vm, object.value, 60)};
            iterator.value = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/reflect/ClassAccess",
                "getBundleClasses", "(I)Lcom/jbed/reflect/ClassAccess$ClassIterator;", classes, 2);
            for (;;) {
                uint32_t next[] = {iterator.value};
                klass.value = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/reflect/ClassAccess$ClassIterator",
                    "nextClass", "()Ljava/lang/Class;", next, 1);
                if (!klass.value) break;
                uint32_t methods = jbed_vm_half(vm->heap.memory, klass.value + 52);
                for (uint32_t i = 0; i < methods; ++i) {
                    uint32_t get_method[] = {klass.value, i};
                    method.value = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/reflect/Method",
                        "getMethod", "(Ljava/lang/Class;I)Lcom/jbed/reflect/Method;", get_method, 2);
                    uint32_t fqn[] = {method.value, encoder.value};
                    JbRef name = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/reflect/Method",
                        "getFqn", "(Lcom/jbed/reflect/SignatureEncoder;)Ljava/lang/String;", fqn, 2);
                    uint32_t trace[] = {name, get(vm, method.value, 24)};
                    jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/runtime/Tracing", "registerDebugSymbol", "(Ljava/lang/String;I)V", trace, 2);
                }
            }
            vm->heap.temporary_roots = encoder.previous;
        }
    }
    JbedAddress anchor_slot = jbed_vm_static_field_slot(vm, "java/lang/Class", "loadedClassesAnchor");
    JbRef anchor = jbed_vm_word(vm->heap.memory, anchor_slot);
    if (!anchor) jbed_vm_fatal(vm, "RomObjects: no loaded-classes code anchor");
    uint32_t params[] = {anchor, map_id, get(vm, object.value, 20)};
    jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/runtime/CodeAnchor", "setParams", "(ILjava/lang/Object;)V", params, 3);
    vm->heap.temporary_roots = object.previous;
}
