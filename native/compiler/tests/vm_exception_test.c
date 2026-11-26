#include "vm_exception.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

enum { OBJECT = 0x80, TAG = 0x100, LEAF = 0x200, CATCH_CLASS = 0x240, TABLE = 0x300 };
static uint32_t ram[1024];

static uint32_t read_ram(void *ctx, JbedAddress address)
{
    (void)ctx;
    assert(address < sizeof ram && !(address & 3));
    return ram[address / 4];
}

static void put(JbedAddress address, uint32_t value)
{
    assert(address < sizeof ram && !(address & 3));
    ram[address / 4] = value;
}

static void *allocate(void *ctx, size_t size)
{
    (void)ctx;
    return calloc(1, size);
}

static void check_frames(void)
{
    JbedVmNativeFrames native = {.base = 0x800, .frame = 0x804};
    JbedVmExceptionState vm = {.memory = {.word = read_ram}, .native_frames = &native,
                               .stack_limit = 0x3000, .reserved_stack_limit = 0x2800,
                               .stack_overflow = OBJECT};
    put(OBJECT, TAG);
    put(TAG, LEAF);
    put(LEAF + 32, 6);
    put(LEAF + 20, CATCH_CLASS);
    put(CATCH_CLASS + 32, 5);
    put(TABLE, 0x4100);
    put(TABLE + 4, 0x4120);
    put(TABLE + 8, 0x4110);
    put(TABLE + 12, CATCH_CLASS);
    put(TABLE + 16, 0x4100);
    put(TABLE + 20, 0x4124);
    put(TABLE + 24, 0x4112);
    put(TABLE + 32, 1); /* Both zero and one terminate a table. */

    put(0x474, 0xaaa);
    put(0x478, 0x504);
    put(0x47c, 0x4121);
    put(0x504 - 28, TABLE | 3);
    JbedVmArmFrame child = {.sp = 0x474, .fp = 0x480, .lr = 0x81, .r5 = 55, .r6 = 66};
    JbedVmExceptionTransfer t = jbed_vm_handle_exception(&vm, OBJECT, child);
    assert(t.action == JBED_VM_ENTER_CATCH && t.handler_or_monitor == 0x4111);
    assert(t.frame.sp == 0x480 && t.frame.fp == 0x504 && t.frame.lr == 0x4121);
    assert(t.frame.r4 == 0xaaa && t.frame.r5 == 55 && t.frame.r6 == 66);
    assert(vm.stack_limit == 0x3000);

    put(0x47c, 0x4123); /* test end of first range, still in catch-all */
    t = jbed_vm_handle_exception(&vm, OBJECT, child);
    assert(t.action == JBED_VM_ENTER_CATCH && t.handler_or_monitor == 0x4113);
    put(0x47c, 0x4141); /* neither range matches; unwind synchronized frame */
    put(0x4ec, 4);
    put(0x4f0, 5);
    put(0x4f4, 6);
    put(0x4f8, 0x584);
    put(0x4fc, 0x4105);
    put(0x584 - 28, TABLE | 1);
    t = jbed_vm_handle_exception(&vm, OBJECT, child);
    assert(t.action == JBED_VM_RELEASE_MONITOR && t.handler_or_monitor == 0xaaa);
    assert(t.frame.fp == 0x584 && t.frame.sp == 0x500 && t.frame.lr == 0x4105);
    assert(t.frame.r4 == 4 && t.frame.r5 == 5 && t.frame.r6 == 6);
    t = jbed_vm_handle_exception(&vm, OBJECT, t.frame);
    assert(t.action == JBED_VM_ENTER_CATCH && t.handler_or_monitor == 0x4111);

    /* At the end of a managed segment, pop NCSS and resume its saved frame. */
    native.frame = 0x900;
    put(0x8f8, 0x880);
    put(0x87c, 7);
    put(0x880, 0x440);
    put(0x884, 0x4105);
    put(0x888, 40);
    put(0x88c, 50);
    put(0x890, 60);
    put(0x894, 0x504);
    JbedVmArmFrame terminal = {.fp = 0x720, .sp = 0x710};
    t = jbed_vm_handle_exception(&vm, OBJECT, terminal);
    assert(t.action == JBED_VM_ENTER_CATCH && t.frame.r4 == 40 && t.frame.r6 == 60);
    assert(native.frame == 0x880 && native.address == 0x880 && native.no_allocation == 7);

    /* A trace crosses the same boundary without popping it. NCSS's saved LR
     * is retained verbatim. An upcall's equal SP and FP skips a 16-byte frame. */
    native.frame = 0x900;
    put(0x880, 0x640);
    put(0x894, 0x640);
    put(0x648, 0x688);
    put(0x64c, 0x91);
    JbedRuntime runtime = {.allocate_zeroed = allocate};
    JbedVmTrace *trace = NULL;
    jbed_vm_fill_trace(&runtime, &vm, &trace, 0x78, child.fp);
    assert(trace && trace->next && !trace->next->next);
    assert(jbed_vm_stack_pos(trace, 0) == 0x78 && jbed_vm_stack_pos(trace, 1) == 0x413e);
    assert(jbed_vm_stack_pos(trace, 2) == 0x4102 && jbed_vm_stack_pos(trace, 3) == 0x4105);
    assert(jbed_vm_stack_pos(trace, 4) == 0x8e && !jbed_vm_stack_pos(trace, 5));
    assert(!jbed_vm_stack_pos(trace, -1) && !jbed_vm_stack_pos(trace, 10));
    assert(native.frame == 0x900 && native.no_allocation == 7);
    free(trace->next);
    free(trace);

    vm.stack_overflow = 0;
    put(0x8f8, native.base); /* Restoring the last native frame resets the stack limit. */
    t = jbed_vm_handle_exception(&vm, OBJECT, terminal);
    assert(t.action == JBED_VM_UNCAUGHT && vm.stack_limit == vm.reserved_stack_limit);
    assert(native.no_allocation == 0 && native.frame == native.base);
    terminal.sp = terminal.fp;
    assert(jbed_vm_handle_exception(&vm, OBJECT, terminal).action == JBED_VM_THROW_FROM_KNI);
    vm.no_catch_tag = TAG;
    assert(jbed_vm_handle_exception(&vm, OBJECT, child).action == JBED_VM_UNCAUGHT);
    vm.native_frames = NULL;
    assert(jbed_vm_handle_exception(&vm, OBJECT, child).action == JBED_VM_NO_NATIVE_STATE);
}

typedef struct Image {
    uint8_t *bytes;
    size_t size;
} Image;

/* A synthetic throw frame on the original Jbni.newEmptyStringLen catch table.
 * The table, exception tag, descriptors and class ancestry are all read from
 * the supplied image. */
static uint32_t read_image(void *ctx, JbedAddress address)
{
    if (address < sizeof ram)
        return read_ram(NULL, address);
    Image *image = ctx;
    assert(!(address & 3) && (size_t)address + 4 <= image->size);
    const uint8_t *b = image->bytes + address;
    return b[0] | (uint32_t)b[1] << 8 | (uint32_t)b[2] << 16 | (uint32_t)b[3] << 24;
}

static void check_rom(const char *path)
{
    FILE *file = fopen(path, "rb");
    assert(file && !fseek(file, 0, SEEK_END));
    long size = ftell(file);
    assert(size > 0 && !fseek(file, 0, SEEK_SET));
    Image image = {.bytes = malloc((size_t)size), .size = (size_t)size};
    assert(image.bytes && fread(image.bytes, 1, image.size, file) == image.size);
    fclose(file);
    JbedVmNativeFrames native = {.base = 0x800, .frame = 0x804};
    JbedVmExceptionState vm = {.memory = {&image, read_image}, .native_frames = &native};
    JbedVmArmFrame frame = {.fp = 0x704, .sp = 0x680, .lr = 0xe1749};
    put(OBJECT, 0x1dda1c); /* OutOfMemoryError */
    put(frame.fp - 28, 0xe1755);
    assert(jbed_vm_exception_instance_of(vm.memory, 0x1dda1c, 0x20ff60)); /* Error */
    assert(!jbed_vm_exception_instance_of(vm.memory, 0x1dda1c, 0x2164c0)); /* RuntimeException */
    JbedVmExceptionTransfer t = jbed_vm_handle_exception(&vm, OBJECT, frame);
    assert(t.action == JBED_VM_ENTER_CATCH && t.handler_or_monitor == 0xe174d);
    put(OBJECT, 0x1de3cc); /* NullPointerException */
    assert(jbed_vm_handle_exception(&vm, OBJECT, frame).action == JBED_VM_UNCAUGHT);
    free(image.bytes);
}

int main(int argc, char **argv)
{
    check_frames();
    if (argc == 2)
        check_rom(argv[1]);
    return 0;
}
