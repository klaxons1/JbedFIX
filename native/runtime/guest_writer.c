#include "guest_writer.h"
#include "execution.h"
#include "guest_call.h"
#include "memory.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum {
    ARRAY_LENGTH = 12, ARRAY_DATA = 16,
    WRITER_BASE = 48, WRITER_BUFFER = 72, WRITER_CLOSED = 76,
    LARGE_COUNT = 84, LARGE_BASES = 88, LARGE_ARRAYS = 92,
    /* SignatureEncoder's inline, low-nibble-first encoding of (II)V. */
    CHECK_ADDRESS_SIGNATURE = 0xfdaa
};

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Guest writer outside a Jbed VM");
    return vm;
}

static uint32_t field(JbedVm *vm, JbRef object, uint32_t offset)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_word(vm->heap.memory, object + offset);
}

static uint32_t element(JbedVm *vm, JbRef array, uint32_t index)
{
    if (index >= field(vm, array, ARRAY_LENGTH))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    return jbed_vm_word(vm->heap.memory, array + ARRAY_DATA + 4 * index);
}

/* Writer.write{Byte,Short,Int}, original 0x1327da/0x1327d6/0x1327d2.
 * Bytewise little-endian accesses also support unaligned patch sites. */
static void store(JbedVm *vm, JbedAddress address, uint32_t value, unsigned width)
{
    uint8_t *p = jbed_vm_span(vm->heap.memory, address, width);
    for (unsigned i = 0; i < width; ++i) p[i] = (uint8_t)(value >> (8 * i));
}

void Writer_writeByte(JbRef self, JbedAddress address, int32_t value)
{
    (void)self;
    store(active(), address, (uint32_t)value, 1);
}

void Writer_writeShort(JbRef self, JbedAddress address, int32_t value)
{
    (void)self;
    store(active(), address, (uint32_t)value, 2);
}

void Writer_writeInt(JbRef self, JbedAddress address, int32_t value)
{
    (void)self;
    store(active(), address, (uint32_t)value, 4);
}

/* checkAccess() at 0x177586; its assertion is fatal in the original VM. */
static void check_open(JbedVm *vm, JbRef self)
{
    (void)field(vm, self, 0);
    if (*jbed_vm_at(vm->heap.memory, self + WRITER_CLOSED))
        jbed_vm_fatal(vm, "Access to closed CodeBlockWriter");
}

/* checkAccess(II) at 0x17755c dispatches checkAdr virtually. A subclass may
 * flush/reallocate here, so keep the receiver rooted and reload its fields. */
static JbedAddress buffer_address(JbedVm *vm, JbRef self, JbedAddress address, uint32_t width)
{
    check_open(vm, self);
    JbedVmHeapRoot root = {self, self, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress tag = field(vm, self, 0);
    JbedClass *klass = jbed_class_from_target(&vm->classes, jbed_vm_word(vm->heap.memory, tag));
    JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)"checkAdr", 8, false);
    JbedMethod *method = NULL;
    for (; klass && !method; klass = klass->superclass)
        for (JbedMethod *candidate = klass->methods; candidate; candidate = candidate->next)
            if (candidate->name_id == name && candidate->signature_id == CHECK_ADDRESS_SIGNATURE) {
                method = candidate;
                break;
            }
    if (!method) jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, "CodeBlockWriter.checkAdr(II)V");
    /* The source ROM compiler reassigns dispatch slots; do not use original
     * slot 41 here. Resolve against the current image's method metadata. */
    JbedAddress entry = method->dispatch_slot >= 0
        ? jbed_vm_word(vm->heap.memory, tag + 8 + 4u * (unsigned)method->dispatch_slot)
        : method->code_address;
    uint32_t arguments[] = {self, address, width};
    bool success = jbed_vm_invoke(vm, entry, arguments, 3, NULL);
    self = root.value;
    vm->heap.temporary_roots = root.previous;
    if (!success) {
        JbedAddress throwable = vm->pending_exception;
        vm->pending_exception = 0;
        jbed_raise(&vm->services, &(JbedError){.kind = JBED_ERROR_THROWABLE,
            .runtime_throwable = jbed_vm_at(vm->heap.memory, throwable)});
    }
    return field(vm, self, WRITER_BUFFER) + ARRAY_DATA + address - field(vm, self, WRITER_BASE);
}

/* CodeBlockWriter 0x17654a..0x17661f. readShort sign-extends, unlike ldrh. */
void CodeBlockWriter_writeByte(JbRef self, JbedAddress address, int32_t value)
{
    JbedVm *vm = active();
    store(vm, buffer_address(vm, self, address, 1), (uint32_t)value, 1);
}

void CodeBlockWriter_writeShort(JbRef self, JbedAddress address, int32_t value)
{
    JbedVm *vm = active();
    store(vm, buffer_address(vm, self, address, 2), (uint32_t)value, 2);
}

void CodeBlockWriter_writeInt(JbRef self, JbedAddress address, int32_t value)
{
    JbedVm *vm = active();
    store(vm, buffer_address(vm, self, address, 4), (uint32_t)value, 4);
}

int32_t CodeBlockWriter_readShort(JbRef self, JbedAddress address)
{
    JbedVm *vm = active();
    return (int16_t)jbed_vm_half(vm->heap.memory, buffer_address(vm, self, address, 2));
}

int32_t CodeBlockWriter_readInt(JbRef self, JbedAddress address)
{
    JbedVm *vm = active();
    return (int32_t)jbed_vm_word(vm->heap.memory, buffer_address(vm, self, address, 4));
}

/* 0x176620. The third Java parameter is a raw source address, not an array.
 * Signed comparison separates the normal code window from large blocks. */
void CodeBlockWriter_writeBlock(JbRef self, JbedAddress address, int32_t length, JbedAddress source)
{
    JbedVm *vm = active();
    JbedAddress destination;
    if ((int32_t)address < -INT32_C(0x20000000)) {
        destination = buffer_address(vm, self, address, (uint32_t)length);
    } else {
        check_open(vm, self);
        uint32_t count = field(vm, self, LARGE_COUNT), i = 0;
        JbRef bases = field(vm, self, LARGE_BASES);
        while ((int32_t)i < (int32_t)count && (int32_t)address >= (int32_t)element(vm, bases, i)) ++i;
        if (!i) jbed_vm_fatal(vm, "CodeBlockWriter: large block not found");
        uint32_t base = element(vm, bases, i - 1);
        JbRef array = element(vm, field(vm, self, LARGE_ARRAYS), i - 1);
        if ((int32_t)(address + (uint32_t)length) > (int32_t)(base + field(vm, array, ARRAY_LENGTH)))
            jbed_vm_fatal(vm, "CodeBlockWriter: write exceeds large block");
        destination = array + ARRAY_DATA + address - base;
    }
    if (length)
        memmove(jbed_vm_span(vm->heap.memory, destination, (uint32_t)length),
                jbed_vm_span(vm->heap.memory, source, (uint32_t)length), (uint32_t)length);
}

/* DirectCodeBlockWriter 0x162614. Completed code pages are native addresses;
 * large allocations remain pinned Java byte arrays. */
JbedAddress DirectCodeBlockWriter_relocateAdr(JbRef self, JbedAddress address)
{
    JbedVm *vm = active();
    if ((int32_t)address >= -INT32_C(0x20000000)) {
        uint32_t count = field(vm, self, LARGE_COUNT), i = 0;
        JbRef bases = field(vm, self, LARGE_BASES);
        while ((int32_t)i < (int32_t)count && (int32_t)address >= (int32_t)element(vm, bases, i)) ++i;
        if (!i) jbed_vm_fatal(vm, "DirectCodeBlockWriter: large block not found");
        return element(vm, field(vm, self, LARGE_ARRAYS), i - 1) + ARRAY_DATA
            + address - element(vm, bases, i - 1);
    }
    uint32_t page = (address + UINT32_C(0x30000000)) >> 13;
    if ((int32_t)page >= (int32_t)field(vm, self, 172)) {
        uint32_t args[] = {self, page + 1};
        jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/tbcc/DirectCodeBlockWriter",
            "allocCodeSpace", "(I)V", args, 2);
        self = args[0];
    }
    return element(vm, field(vm, self, 160), page) + (address & 8191);
}

void DirectCodeBlockWriter_writeByte(JbRef self, JbedAddress address, int32_t value)
{
    if ((int32_t)address >= (int32_t)field(active(), self, WRITER_BASE))
        CodeBlockWriter_writeByte(self, address, value);
    else Writer_writeByte(self, DirectCodeBlockWriter_relocateAdr(self, address), value);
}

void DirectCodeBlockWriter_writeShort(JbRef self, JbedAddress address, int32_t value)
{
    if ((int32_t)address >= (int32_t)field(active(), self, WRITER_BASE))
        CodeBlockWriter_writeShort(self, address, value);
    else Writer_writeShort(self, DirectCodeBlockWriter_relocateAdr(self, address), value);
}

void DirectCodeBlockWriter_writeInt(JbRef self, JbedAddress address, int32_t value)
{
    JbedVm *vm = active();
    if ((int32_t)address >= (int32_t)field(vm, self, WRITER_BASE)) {
        uint32_t args[] = {self, address, (uint32_t)value};
        jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/tbcc/ArchCodeBlockWriter",
            "writeInt", "(II)V", args, 3);
    } else Writer_writeInt(self, DirectCodeBlockWriter_relocateAdr(self, address), value);
}

int32_t DirectCodeBlockWriter_readShort(JbRef self, JbedAddress address)
{
    JbedVm *vm = active();
    return (int32_t)address >= (int32_t)field(vm, self, WRITER_BASE)
        ? CodeBlockWriter_readShort(self, address)
        : (int16_t)jbed_vm_half(vm->heap.memory, DirectCodeBlockWriter_relocateAdr(self, address));
}

int32_t DirectCodeBlockWriter_readInt(JbRef self, JbedAddress address)
{
    JbedVm *vm = active();
    if ((int32_t)address >= (int32_t)field(vm, self, WRITER_BASE)) {
        uint32_t args[] = {self, address};
        return (int32_t)jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/tbcc/ArchCodeBlockWriter",
            "readInt", "(I)I", args, 2);
    }
    return (int32_t)jbed_vm_word(vm->heap.memory, DirectCodeBlockWriter_relocateAdr(self, address));
}

/* Writer.allocIntern 0x132726. Allocation reserves pinned memory; flushCode
 * advances the cursor unless allocateRaw requested a deferred commit. */
JbedAddress Writer_allocIntern(JbRef self, JbRef owner, int32_t length, bool raw)
{
    JbedVm *vm = active();
    JbedVmHeapRoot object = {self, self, vm->heap.temporary_roots};
    JbedVmHeapRoot owning = {owner, owner, &object};
    vm->heap.temporary_roots = &owning;
    if (!field(vm, object.value, 16) ||
        (int32_t)(field(vm, object.value, 20) - field(vm, object.value, 12)) < length) {
        JbRef maps = field(vm, object.value, 36);
        if (maps && (int32_t)field(vm, maps, 20) > 0) {
            uint32_t args[] = {object.value};
            jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/tbcc/Writer", "writeStackMaps", "()V", args, 1);
        }
    }
    if (!field(vm, object.value, 16) ||
        (int32_t)(field(vm, object.value, 20) - field(vm, object.value, 12)) < length) {
        uint32_t args[] = {object.value};
        jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/tbcc/Writer", "finishBlock", "()V", args, 1);
        int32_t size = length < 16000 ? 16000 : length;
        Memory_nextAllocateLocked();
        JbRef array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE], size, false);
        jbed_vm_put_word(vm->heap.memory, object.value + 16, array);
        jbed_vm_put_word(vm->heap.memory, object.value + 12, array + ARRAY_DATA);
        jbed_vm_put_word(vm->heap.memory, object.value + 20, array + ARRAY_DATA + (uint32_t)size);
    }
    jbed_vm_put_word(vm->heap.memory, object.value + 24, owning.value);
    JbedAddress result = field(vm, object.value, 12);
    if (!raw) {
        uint32_t args[] = {object.value, owning.value, result + (uint32_t)length};
        jbed_vm_guest_call(vm, JBED_GUEST_VIRTUAL, NULL, "flushCode", "(Ljava/lang/Object;I)V", args, 3);
    }
    vm->heap.temporary_roots = object.previous;
    return result;
}

/* CodeBlock.readBlock 0x157e8a calls the base readable(), which returns true;
 * unlike writeBlock, its raw address is the SOURCE, array slice the destination. */
void CodeBlock_readBlock(JbRef self, JbedAddress source, JbRef destination, int32_t offset, int32_t length)
{
    (void)self;
    JbedVm *vm = active();
    if (length)
        memmove(jbed_vm_span(vm->heap.memory, destination + ARRAY_DATA + (uint32_t)offset, (uint32_t)length),
            jbed_vm_span(vm->heap.memory, source, (uint32_t)length), (uint32_t)length);
}

/* 0x132492. Commit a pinned base-writer buffer to its class's code anchor. */
void Writer_finishBlock(JbRef self)
{
    JbedVm *vm = active();
    JbRef array = field(vm, self, 16);
    if (!array) return;
    JbedVmHeapRoot object = {self, self, vm->heap.temporary_roots};
    JbedVmHeapRoot buffer = {array, array, &object};
    JbedVmHeapRoot owner = {0, 0, &buffer};
    vm->heap.temporary_roots = &owner;
    uint32_t length = field(vm, object.value, 12) - (array + ARRAY_DATA);
    if (Memory_resize(buffer.value, (int32_t)length) != buffer.value)
        jbed_vm_raise(vm, JBED_ERROR_ERROR, "Pinned writer buffer unexpectedly moved while shrinking");
    char *start = (char *)jbed_vm_at(vm->heap.memory, buffer.value + ARRAY_DATA);
    __builtin___clear_cache(start, start + length);
    owner.value = field(vm, object.value, 24);
    JbedAddress method_class = jbed_vm_find_class(vm, "com/jbed/reflect/Method");
    if (jbed_vm_instance_of(&vm->resident, field(vm, owner.value, 0), jbed_vm_class_at(&vm->resident, method_class)))
        owner.value = field(vm, owner.value, 12);
    JbRef previous = field(vm, owner.value, 76);
    if (previous) {
        JbRef pair = jbed_vm_allocate_array(vm, vm->object_array_class, 2, false);
        jbed_vm_put_word(vm->heap.memory, pair + ARRAY_DATA, buffer.value);
        jbed_vm_put_word(vm->heap.memory, pair + ARRAY_DATA + 4, field(vm, owner.value, 76));
        buffer.value = pair;
    }
    jbed_vm_put_word(vm->heap.memory, owner.value + 76, buffer.value);
    jbed_vm_put_word(vm->heap.memory, object.value + 16, 0);
    jbed_vm_put_word(vm->heap.memory, object.value + 24, 0);
    vm->heap.temporary_roots = object.previous;
}
