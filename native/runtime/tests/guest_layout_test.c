#include "guest_writer.h"
#include "guest_rom.h"
#include "guest_call.h"
#include "guest_blocks.h"
#include "guest_queue.h"
void StackMapBlock_init(JbRef, JbedAddress);
#include "execution.h"
#include "memory.h"
#include "vm_words.h"

#include <assert.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint8_t bytes[131072];
static JbedVm vm;
static jmp_buf boundary;
static int fault, invoke_count, allocation_count, lock_count;
static unsigned expected_width;
static JbedAddress expected_address;
static bool move_receiver, fail_callback, expect_failure;
static JbedAddress next_array = 0x5000, allocated_class;
static JbedMethod check_method, wrong_overload;
static JbedClass writer_class, writer_subclass;

JbedClass *jbed_class_from_target(JbedClassAccess *access, JbedAddress address)
{
    assert(access == &vm.classes && address == 0x1600);
    return &writer_subclass;
}

uint16_t jbed_reflection_id(JbedReflectionTable *table, const uint8_t *text, size_t length, bool create)
{
    assert(table == &vm.method_names && length == 8 && !memcmp(text, "checkAdr", 8) && !create);
    return 42;
}

enum { SELF = 0x1100, MOVED = 0x1300, TAG = 0x1500,
       BUFFER = 0x2000, NEW_BUFFER = 0x2400, SOURCE = 0x2800,
       BASES = 0x3000, ARRAYS = 0x3100, LARGE = 0x3200 };
#define BASE UINT32_C(0xd0000000)

static uint32_t word(uint32_t address) { return jbed_vm_word(vm.heap.memory, address); }
static void put(uint32_t address, uint32_t value) { jbed_vm_put_word(vm.heap.memory, address, value); }
JbedVm *jbed_vm_current(void) { return &vm; }

_Noreturn void jbed_vm_raise(JbedVm *v, JbedErrorKind kind, const char *message)
{
    (void)message;
    assert(v == &vm && expect_failure);
    fault = kind;
    longjmp(boundary, 1);
}

_Noreturn void jbed_vm_fatal(JbedVm *v, const char *message)
{
    (void)message;
    assert(v == &vm && expect_failure);
    fault = -1;
    longjmp(boundary, 1);
}

static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    assert(error->kind == JBED_ERROR_THROWABLE);
    assert(error->runtime_throwable == jbed_vm_at(vm.heap.memory, 0x4500));
    jbed_vm_raise(&vm, error->kind, NULL);
}

/* Managed callbacks used by the additional writer/isolate bindings. */
static unsigned guest_mode;
static bool rom_mode;
static unsigned virtual_count, bundle_loads;
uint32_t Jbed_noAllocation;
uint64_t jbed_vm_guest_call(JbedVm *v, JbedGuestCallKind kind, const char *owner,
    const char *name, const char *descriptor, uint32_t *args, size_t count)
{
    assert(v == &vm);
    if (rom_mode) {
        if (!strcmp(name, "getSyncTableSize")) return 16;
        if (!strcmp(name, "extendSynchArray")) { assert(args[0] == word(SELF + 28) - 16); return 0; }
        if (!strcmp(name, "extendStatics")) { assert(args[0] == 128 && args[1] == ARRAYS); return 0; }
        if (!strcmp(name, "getMapId")) return 7;
        if (!strcmp(name, "add")) { assert(args[1] == 7); return 0; }
        if (!strcmp(name, "setParams")) { assert(args[0] == SOURCE && args[1] == 7 && args[2] == LARGE); return 0; }
        if (!strcmp(name, "hashCode")) return 0x123456;
        if (kind == JBED_GUEST_VIRTUAL) {
            assert(!strcmp(name, "writeInt") || !strcmp(name, "writeReloc") || !strcmp(name, "writeLabel"));
            assert(args[0] == NEW_BUFFER);
            put(args[1], args[2]); ++virtual_count; return 0;
        }
    }
    if (!strcmp(name, "allocCodeSpace")) {
        assert(kind == JBED_GUEST_DIRECT && !strcmp(owner, "com/jbed/tbcc/DirectCodeBlockWriter"));
        assert(!strcmp(descriptor, "(I)V") && count == 2 && args[1] == 2);
        put(args[0] + 172, 2);
        return 0;
    }
    if (!strcmp(name, "readInt") || !strcmp(name, "writeInt")) {
        assert(kind == JBED_GUEST_DIRECT && !strcmp(owner, "com/jbed/tbcc/ArchCodeBlockWriter"));
        assert(count == (!strcmp(name, "readInt") ? 2u : 3u));
        ++guest_mode;
        return 0x87654321;
    }
    if (!strcmp(name, "notify")) {
        assert(count == 5 && args[1] == 0 && args[2] == 3 && args[3] == 2 && args[4] == 17);
        ++guest_mode;
        return 1;
    }
    if (!strcmp(name, "addEvent")) {
        assert(count == 2 && args[0] == LARGE && args[1] == 99);
        ++guest_mode;
        return 0;
    }
    if (!strcmp(name, "getHandler")) return NEW_BUFFER;
    if (!strcmp(name, "send")) { ++guest_mode; return 0; }
    if (!strcmp(name, "finishBlock")) { Writer_finishBlock(args[0]); return 0; }
    if (!strcmp(name, "flushCode")) { put(args[0] + 12, args[2]); return 0; }
    fprintf(stderr, "Unexpected guest callback: %s %s\n", name, descriptor);
    abort();
}
JbedAddress jbed_vm_find_class(JbedVm *v, const char *name) { (void)v; (void)name; return 0x1600; }
bool Memory_isReadOnlyObject(JbedAddress object) { return (word(object + 4) & 3) == 3; }
void jbed_arm32_throw_abstract(void) { abort(); }
void jbed_arm32_throw_no_class(void) { abort(); }
JbedAddress Memory_resize(JbedAddress array, int32_t length) { put(array + 12, (uint32_t)length); return array; }
JbedClass *jbed_vm_class_at(const JbedVmClassTable *t, JbedAddress address) { (void)t; (void)address; return &writer_class; }
bool jbed_vm_instance_of(const JbedVmClassTable *t, uint32_t tag, const JbedClass *klass)
{ (void)t; (void)tag; (void)klass; return false; }
JbedAddress jbed_vm_static_field_slot(JbedVm *v, const char *owner, const char *name)
{
    (void)owner; assert(v == &vm);
    if (!strcmp(name, "lastAddr")) return 0x1814;
    if (!strcmp(name, "lastMap")) return 0x1818;
    if (!strcmp(name, "blocks")) return 0x1800;
    if (!strcmp(name, "blockIds")) return 0x1804;
    if (!strcmp(name, "blocksUsed")) return 0x1808;
    if (!strcmp(name, "handler")) return vm.isolate_statics + 40;
    if (!strcmp(name, "hashtable")) return 0x180c;
    if (!strcmp(name, "loadedClassesAnchor")) return 0x1810;
    abort();
}
JbedAddress jbed_vm_switch_statics(JbedVm *v, JbedAddress address)
{ JbedAddress old = v->isolate_statics; v->isolate_statics = address; return old; }
JbedAddress jbed_vm_allocate_object(JbedVm *v, JbedAddress klass, bool kni)
{ (void)v; (void)klass; (void)kni; abort(); }
void ClassAccess_loadDynamicBundle(int32_t bundle, JbedAddress image, JbedAddress packages, JbedAddress bases)
{ assert(bundle == 3 && image == 0x6000 && packages == 0x6100 && bases == 0x6200); ++bundle_loads; }
void ReflectionTable_referenceDynamicTable(JbRef table, const uint8_t *image)
{ (void)table; (void)image; abort(); }
void System_arraycopy(JbedAddress from, int32_t offset, JbedAddress to, int32_t index, int32_t count)
{
    if (!from || !to) jbed_vm_raise(&vm, JBED_ERROR_NULL_POINTER, NULL);
    if (offset < 0 || index < 0 || count < 0 || (uint32_t)(offset + count) > word(from + 12) ||
        (uint32_t)(index + count) > word(to + 12)) jbed_vm_raise(&vm, JBED_ERROR_ARRAY_INDEX, NULL);
    unsigned width = (from == BASES || from == ARRAYS || to == BASES || to == ARRAYS) ? 4 : 1;
    memmove(jbed_vm_at(vm.heap.memory, to + 16 + width * (uint32_t)index),
        jbed_vm_at(vm.heap.memory, from + 16 + width * (uint32_t)offset), width * (uint32_t)count);
}


/* Stub only the managed execution boundary, not the implementation under test.
 * Simulate a moving GC and replacement buffer inside virtual checkAdr. */
bool jbed_vm_invoke(JbedVm *v, JbedAddress entry, const uint32_t *args,
                    size_t count, uint64_t *result)
{
    assert(v == &vm && entry == 0x7771 && count == 3 && result == NULL);
    assert(args[0] == SELF && args[1] == expected_address && args[2] == expected_width);
    assert(vm.heap.temporary_roots && vm.heap.temporary_roots->value == SELF);
    ++invoke_count;
    if (move_receiver) {
        memcpy(jbed_vm_at(vm.heap.memory, MOVED), jbed_vm_at(vm.heap.memory, SELF), 128);
        vm.heap.temporary_roots->value = MOVED;
        put(MOVED + 72, NEW_BUFFER);
        put(SELF + 72, 0); /* A stale receiver would read/write the wrong bytes. */
    }
    if (fail_callback) vm.pending_exception = 0x4500;
    return !fail_callback;
}

void Memory_nextAllocateLocked(void) { ++lock_count; }
JbedAddress jbed_vm_allocate_array(JbedVm *v, JbedAddress klass, int32_t length, bool kni)
{
    assert(v == &vm && length >= 0 && !kni);
    assert(vm.heap.temporary_roots);
    ++allocation_count;
    allocated_class = klass;
    if (move_receiver) {
        memcpy(jbed_vm_at(vm.heap.memory, MOVED), jbed_vm_at(vm.heap.memory, SELF), 128);
        vm.heap.temporary_roots->value = MOVED;
    }
    JbedAddress result = next_array;
    next_array += ((uint32_t)length * 4 + 47) & ~31u;
    put(result + 12, (uint32_t)length);
    return result;
}

static void reset(void)
{
    memset(bytes, 0, sizeof bytes);
    memset(&vm, 0, sizeof vm);
    vm.heap.memory = (JbedBuffer){bytes, sizeof bytes, 0x1000};
    vm.services.raise_error = raise_error;
    vm.object_array_class = 0x6000;
    vm.primitive_array_classes[JBED_TYPE_BYTE] = 0x6100;
    put(SELF, TAG);
    put(TAG, 0x1600);
    check_method = (JbedMethod){.name_id = 42, .signature_id = 0xfdaa, .dispatch_slot = 7};
    wrong_overload = (JbedMethod){.name_id = 42, .signature_id = 0xf0da, .dispatch_slot = 2};
    writer_class = (JbedClass){.methods = &check_method};
    writer_subclass = (JbedClass){.methods = &wrong_overload, .superclass = &writer_class};
    put(TAG + 8 + 4 * 7, 0x7771); /* Deliberately not original ROM slot 41. */
    put(SELF + 48, BASE);
    put(SELF + 72, BUFFER);
    put(BUFFER + 12, 256);
    invoke_count = allocation_count = lock_count = fault = 0;
    move_receiver = fail_callback = expect_failure = rom_mode = false;
    next_array = 0x8000; virtual_count = bundle_loads = 0; Jbed_noAllocation = 0;
}

#define EXPECT_FAULT(expression, code) do { \
    expect_failure = true; \
    if (!setjmp(boundary)) { expression; assert(!"expected exception/fatal"); } \
    assert(fault == (code)); expect_failure = false; \
} while (0)

static void stores(void)
{
    reset();
    memset(jbed_vm_at(vm.heap.memory, SOURCE), 0xa5, 12);
    Writer_writeByte(SELF, SOURCE + 1, 0x1234);
    Writer_writeShort(SELF, SOURCE + 3, 0x87654321);
    Writer_writeInt(SELF, SOURCE + 7, (int32_t)0x89abcdef);
    const uint8_t expected[] = {0xa5, 0x34, 0xa5, 0x21, 0x43, 0xa5, 0xa5,
                                0xef, 0xcd, 0xab, 0x89, 0xa5};
    assert(!memcmp(jbed_vm_at(vm.heap.memory, SOURCE), expected, sizeof expected));
    assert(!invoke_count);
}

static void buffered(void)
{
    reset();
    expected_address = BASE + 3; expected_width = 1;
    CodeBlockWriter_writeByte(SELF, expected_address, 0x1234);
    assert(*jbed_vm_at(vm.heap.memory, BUFFER + 19) == 0x34);
    expected_address = BASE + 6; expected_width = 2;
    CodeBlockWriter_writeShort(SELF, expected_address, 0x180ff);
    assert(CodeBlockWriter_readShort(SELF, expected_address) == (int16_t)0x80ff);
    expected_address = BASE + 12; expected_width = 4;
    CodeBlockWriter_writeInt(SELF, expected_address, (int32_t)0x89abcdef);
    assert(CodeBlockWriter_readInt(SELF, expected_address) == (int32_t)0x89abcdef);
    assert(invoke_count == 5 && !vm.heap.temporary_roots);

    move_receiver = true;
    CodeBlockWriter_writeInt(SELF, expected_address, 0x10203040);
    assert(word(NEW_BUFFER + 28) == 0x10203040);
    assert(word(BUFFER + 28) == 0x89abcdef && !vm.heap.temporary_roots);

    reset(); expected_address = BASE; expected_width = 4; fail_callback = true;
    EXPECT_FAULT(CodeBlockWriter_writeInt(SELF, BASE, 5), JBED_ERROR_THROWABLE);
    assert(!word(BUFFER + 16) && !vm.heap.temporary_roots && !vm.pending_exception);
    *jbed_vm_at(vm.heap.memory, SELF + 76) = 1;
    EXPECT_FAULT(CodeBlockWriter_writeInt(SELF, BASE, 5), -1);
    EXPECT_FAULT(CodeBlockWriter_readShort(0, BASE), JBED_ERROR_NULL_POINTER);
}

static void blocks(void)
{
    reset();
    for (unsigned i = 0; i < 16; ++i) *jbed_vm_at(vm.heap.memory, SOURCE + i) = (uint8_t)(i + 1);
    expected_address = BASE + 17; expected_width = 9;
    CodeBlockWriter_writeBlock(SELF, expected_address, 9, SOURCE);
    assert(!memcmp(jbed_vm_at(vm.heap.memory, BUFFER + 33), jbed_vm_at(vm.heap.memory, SOURCE), 9));
    put(SELF + 84, 2); put(SELF + 88, BASES); put(SELF + 92, ARRAYS);
    put(BASES + 12, 2); put(ARRAYS + 12, 2);
    put(BASES + 16, 0xe0000000); put(BASES + 20, 0xe0001000);
    put(ARRAYS + 16, LARGE); put(LARGE + 12, 32);
    CodeBlockWriter_writeBlock(SELF, 0xe0000003, 9, SOURCE);
    assert(!memcmp(jbed_vm_at(vm.heap.memory, LARGE + 19), jbed_vm_at(vm.heap.memory, SOURCE), 9));
    assert(invoke_count == 1); /* Large blocks only perform checkAccess(). */
    CodeBlockWriter_writeBlock(SELF, 0xe0000017, 9, SOURCE); /* Exact end is valid. */
    EXPECT_FAULT(CodeBlockWriter_writeBlock(SELF, 0xe0000018, 9, SOURCE), -1);
    put(BASES + 16, 0xe0000010);
    EXPECT_FAULT(CodeBlockWriter_writeBlock(SELF, 0xe0000000, 1, SOURCE), -1);
    put(BASES + 12, 0);
    EXPECT_FAULT(CodeBlockWriter_writeBlock(SELF, 0xe0000000, 1, SOURCE), JBED_ERROR_ARRAY_INDEX);
}

static void statics_and_context(void)
{
    reset();
    JbedAddress base = RomObjects_getPrimStaticsBase(SELF);
    assert(base == word(SELF + 76) + 16 && allocated_class == 0x6100);
    assert(RomObjects_getPrimStaticsBase(SELF) == base && allocation_count == 1);
    base = RomObjects_getPtrStaticsBase(SELF);
    assert(base == word(SELF + 80) + 16 && allocated_class == 0x6000);
    base = RomObjects_getInitFlagsBase(SELF);
    assert(base == word(SELF + 84) + 16 && allocated_class == 0x6100);
    assert(allocation_count == 3 && lock_count == 3 && !vm.heap.temporary_roots);
    reset(); move_receiver = true;
    base = RomObjects_getPrimStaticsBase(SELF);
    assert(word(MOVED + 76) + 16 == base && !word(SELF + 76));
    assert(!vm.heap.temporary_roots);

    put(SELF + 96, 0x4560); put(SELF + 80, 0x3800); put(0x3800 + 980, 0x4570);
    for (unsigned state = 0; state < 6; ++state) {
        put(SELF + 20, state);
        assert(Isolate_getContext(SELF) == (state == 2 ? 0x4570u : 0x4560u));
    }
    EXPECT_FAULT(Isolate_getContext(0), JBED_ERROR_NULL_POINTER);
    EXPECT_FAULT(RomObjects_getInitFlagsBase(0), JBED_ERROR_NULL_POINTER);
}

static void direct_and_events(void)
{
    reset();
    put(SELF + 48, BASE + 8192);
    put(SELF + 160, ARRAYS); put(SELF + 172, 2);
    put(ARRAYS + 12, 2); put(ARRAYS + 16, BUFFER); put(ARRAYS + 20, NEW_BUFFER);
    DirectCodeBlockWriter_writeByte(SELF, BASE + 1, 0x1234);
    assert(*jbed_vm_at(vm.heap.memory, BUFFER + 1) == 0x34);
    DirectCodeBlockWriter_writeShort(SELF, BASE + 2, 0x80ff);
    assert(DirectCodeBlockWriter_readShort(SELF, BASE + 2) == (int16_t)0x80ff);
    DirectCodeBlockWriter_writeInt(SELF, BASE + 4, 0x76543210);
    assert(DirectCodeBlockWriter_readInt(SELF, BASE + 4) == 0x76543210);
    put(SELF + 172, 1);
    assert(DirectCodeBlockWriter_relocateAdr(SELF, BASE + 8192 + 7) == NEW_BUFFER + 7);
    assert(word(SELF + 172) == 2);
    guest_mode = 0;
    DirectCodeBlockWriter_writeInt(SELF, BASE + 8192, 5);
    assert(DirectCodeBlockWriter_readInt(SELF, BASE + 8192) == (int32_t)0x87654321);
    assert(guest_mode == 2);
    put(SELF + 84, 1); put(SELF + 88, BASES); put(SELF + 92, ARRAYS);
    put(BASES + 12, 1); put(BASES + 16, 0xe0000000); put(ARRAYS + 16, LARGE);
    assert(DirectCodeBlockWriter_relocateAdr(SELF, 0xe0000003) == LARGE + 19);
    put(SOURCE, 0x12345678);
    CodeBlock_readBlock(SELF, SOURCE, LARGE, 3, 4);
    assert(word(LARGE + 19) == 0x12345678);

    reset(); guest_mode = 0;
    put(SELF + 124, 3);
    assert(Isolate_startTransition(SELF, 3, 17) == 1 && word(SELF + 128) == 3);
    assert(Isolate_startTransition(SELF, 5, 17) == 2 && guest_mode == 0);
    assert(Isolate_startTransition(SELF, 2, 17) == 0 && word(SELF + 128) == 2 && guest_mode == 1);
    Isolate_deliverEvent(SELF, 0, 99); assert(guest_mode == 1);
    put(SELF + 20, 2); put(SELF + 80, 0x3800); put(0x3800 + 984, ARRAYS);
    put(ARRAYS + 12, 1); put(ARRAYS + 16, LARGE);
    Isolate_deliverEvent(SELF, 0, 99); assert(guest_mode == 2);
    Isolate_deliverEvent(SELF, 1, 99); assert(guest_mode == 2);
    EXPECT_FAULT(Isolate_deliverEvent(SELF, -1, 99), JBED_ERROR_ARRAY_INDEX);
}

static void heap_cache_and_queue(void)
{
    reset();
    put(SELF + 16, 11);
    put(0x1800, BASES); put(0x1804, ARRAYS); put(BASES + 12, 4); put(ARRAYS + 12, 4);
    put(BASES + 16, LARGE); put(LARGE + 12, 32); /* Reusable free entry. */
    put(SOURCE + 12, 2);
    assert(HeapCodeBlocks_getCodeBlocks(SELF, 1, SOURCE, 32));
    assert(word(SOURCE + 16) == LARGE + 16 && word(ARRAYS + 16) == 11 && !allocation_count);
    assert(HeapCodeBlocks_getArrayForBlock(SELF, LARGE + 16) == LARGE);
    assert(HeapCodeBlocks_getCodeBlocks(SELF, 1, SOURCE, 24));
    assert(allocation_count == 1 && lock_count == 1 && word(0x1808) == 2);
    put(NEW_BUFFER + 12, 8); put(NEW_BUFFER + 16, 0x10203040);
    HeapCodeBlocks_writeBlock(SELF, LARGE + 17, NEW_BUFFER, 0, 4);
    assert(word(LARGE + 17) == 0x10203040);
    EXPECT_FAULT(HeapCodeBlocks_writeBlock(SELF, LARGE + 47, NEW_BUFFER, 0, 4), -1);
    EXPECT_FAULT(HeapCodeBlocks_getArrayForBlock(SELF, LARGE + 17), -1);
    put(0x1808, 1024);
    assert(!HeapCodeBlocks_getCodeBlocks(SELF, 1, SOURCE, 32));

    reset(); *jbed_vm_at(vm.heap.memory, SELF + 24) = 1;
    put(NEW_BUFFER + 24, ARRAYS); put(ARRAYS + 12, 4);
    assert(GlobalCallHandler_tryAddEntry(SELF, LARGE, 0) == 0);
    assert(word(ARRAYS + 16) == LARGE && word(NEW_BUFFER + 28) == 1 && !Jbed_noAllocation);
    put(NEW_BUFFER + 28, 3); put(NEW_BUFFER + 32, 0);
    assert(GlobalCallHandler_tryAddEntry(SELF, LARGE, 0) == 8 && !Jbed_noAllocation);
    put(NEW_BUFFER + 28, 1); put(NEW_BUFFER + 32, 2);
    put(ARRAYS + 16, 10); put(ARRAYS + 24, 12); put(ARRAYS + 28, 13);
    put(BASES + 12, 8);
    assert(GlobalCallHandler_tryAddEntry(SELF, LARGE, BASES) == 0);
    assert(word(BASES + 24) == 12 && word(BASES + 28) == 13 && word(BASES + 32) == 10);
    assert(word(BASES + 36) == LARGE && word(NEW_BUFFER + 28) == 6);
    *jbed_vm_at(vm.heap.memory, SELF + 24) = 0; put(SELF + 20, 4);
    assert(GlobalCallHandler_tryAddEntry(SELF, LARGE, 0) == -1);
    assert(!vm.heap.temporary_roots);
}

static void base_writer_and_rom(void)
{
    reset();
    put(SELF + 12, BUFFER + 16); put(SELF + 16, BUFFER); put(SELF + 20, BUFFER + 256);
    assert(Writer_allocIntern(SELF, LARGE, 9, true) == BUFFER + 16);
    assert(word(SELF + 12) == BUFFER + 16 && word(SELF + 24) == LARGE);
    assert(Writer_allocIntern(SELF, LARGE, 9, false) == BUFFER + 16);
    assert(word(SELF + 12) == BUFFER + 25);
    Writer_finishBlock(SELF);
    assert(word(BUFFER + 12) == 9 && word(LARGE + 76) == BUFFER && !word(SELF + 16));
    assert(!vm.heap.temporary_roots);

    reset(); rom_mode = true;
    put(SELF + 96, NEW_BUFFER); put(SELF + 28, 20);
    put(LARGE, TAG);
    RomObjects_genObjectHeader(SELF, SOURCE, LARGE, true, true);
    assert(word(SOURCE) == TAG && word(SOURCE + 4) == 0x12345607 && word(SOURCE + 8) == 41);
    assert(word(SELF + 28) == 21 && virtual_count == 3);
    put(LARGE + 4, 3);
    RomObjects_writeClassObj(SELF, SOURCE, LARGE); assert(word(SOURCE) == LARGE);
    put(LARGE + 4, 0); put(LARGE + 68, 4);
    RomObjects_writeClassObj(SELF, SOURCE, LARGE); assert(word(SOURCE) == 4);
    RomObjects_writeCodeAdr(SELF, SOURCE, 0); assert(!word(SOURCE));
    put(SELF + 64, 128); put(SELF + 72, ARRAYS); put(SELF + 32, BASES); put(BASES + 12, 2);
    put(BASES + 16, LARGE); put(BASES + 20, BUFFER);
    put(SELF + 60, 3); put(SELF + 44, 0x6000); put(SELF + 36, 0x6100); put(SELF + 40, 0x6200);
    put(SELF + 20, LARGE); put(0x1810, SOURCE);
    RomObjects_prepareCommon(SELF, LARGE);
    JbRef strings = word(0x180c);
    assert(word(strings + 12) == 2 && word(strings + 16) == LARGE && word(strings + 20) == BUFFER);
    assert(bundle_loads == 1 && !vm.heap.temporary_roots);
}

static void stack_map_init(void)
{
    reset();
    put(SOURCE, 0x7001); put(SOURCE + 8, 0x100); put(SOURCE + 12, 3); put(SOURCE + 16, 8);
    StackMapBlock_init(SELF, SOURCE | 1);
    assert(word(SELF + 12) == 0x7000 && word(SELF + 16) == 0x7100);
    assert(word(SELF + 20) == 3 && word(SELF + 24) == SOURCE + 20 && word(SELF + 28) == SOURCE + 32);
    assert(word(0x1814) == UINT32_MAX && word(word(0x1818) + 12) == 8);
    unsigned allocations = allocation_count;
    StackMapBlock_init(SELF, SOURCE);
    assert(allocation_count == (int)allocations);
    put(SOURCE + 16, 16); StackMapBlock_init(SELF, SOURCE);
    assert(allocation_count == (int)allocations + 1 && word(word(0x1818) + 12) == 16);
    EXPECT_FAULT(StackMapBlock_init(0, SOURCE), JBED_ERROR_NULL_POINTER);
    EXPECT_FAULT(StackMapBlock_init(SELF, SOURCE + 2), -1);
}

int main(void)
{
    stack_map_init(); stores(); buffered(); blocks(); statics_and_context(); direct_and_events(); heap_cache_and_queue(); base_writer_and_rom();
    puts("Guest writer stores, virtual checks, moving roots, large blocks, pinned statics, and isolate contexts passed");
    return 0;
}
