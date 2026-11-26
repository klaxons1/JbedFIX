#include "vm_stackmap.h"
#include "vm_words.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

static uint32_t read_word(void *context, JbedAddress address)
{
    return jbed_vm_word(*(JbedBuffer *)context, address);
}

static void *allocate(void *context, size_t size)
{
    (void)context;
    return calloc(1, size);
}

typedef struct Visits {
    uint32_t slots[10], count, interior;
} Visits;

static void record_slot(void *context, JbedAddress slot)
{
    Visits *v = context;
    assert(v->count < sizeof(v->slots) / sizeof(v->slots[0]));
    v->slots[v->count++] = slot;
}

static void record_interior(void *context, JbedAddress slot)
{
    Visits *v = context;
    assert(!v->interior);
    v->interior = slot;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "usage: %s libjbedvm.so\n", argv[0]);
        return 2;
    }
    JbedBuffer memory = {.size = 0x340000};
    memory.data = calloc(1, memory.size);
    assert(memory.data);
    FILE *image = fopen(argv[1], "rb");
    assert(image && fread(memory.data, 1, memory.size, image) >= 0x2bd180);
    fclose(image);
    JbedRuntime rt = {.allocate_zeroed = allocate};
    JbedVmStackMaps maps;
    jbed_vm_stack_maps_init(&maps, &rt, (JbedVmMemoryReader){&memory, read_word});
    jbed_vm_stack_maps_add_resident(&maps, 0x2bd178);

    /* Words returned by the Android Thumb getStackMap at these PCs. */
    assert(jbed_vm_stack_map_word(&maps, 0xab439, 0) == 1);
    assert(jbed_vm_stack_map_word(&maps, 0xab43a, 0) == 0);
    assert(jbed_vm_stack_map_word(&maps, 0xad93e, 0) == 0xc080000);
    assert(jbed_vm_stack_map_word(&maps, 0x16ed72, 0) == 0xc0000000);
    assert(jbed_vm_stack_map_word(&maps, 0x16ed72, 1) == 0x2000);
    assert(jbed_vm_stack_map_word(&maps, 0x1b135e, 0) == 0x803c0000);
    assert(jbed_vm_stack_map_word(&maps, 0x1b135e, 1) == 0x80000002);
    assert(jbed_vm_stack_map_word(&maps, 0x1b135e, 2) == 0xc0);

    enum { HEADER = 0x331000, PC = 0x332000, SCHEDULED = 0x333000, CTX = 0x334000,
           SP = CTX + 24, FP = SP + 24, KNI = FP + 32, BASE = 0x335000, NATIVE = BASE + 48 };
    jbed_vm_put_word(memory, HEADER, PC);
    jbed_vm_put_word(memory, HEADER + 8, 12);
    jbed_vm_put_word(memory, HEADER + 12, 3);
    jbed_vm_put_word(memory, HEADER + 16, 1);
    jbed_vm_put_word(memory, HEADER + 20, 9u << 22);           /* r4, SP[0] */
    jbed_vm_put_word(memory, HEADER + 24, (2u << 22) | 1);     /* r5 */
    jbed_vm_put_word(memory, HEADER + 28, (4u << 22) | 2);     /* r6 */
    uint32_t id = jbed_vm_stack_map_id(&maps);
    jbed_vm_stack_map_add(&maps, HEADER, id);
    jbed_vm_put_word(memory, SCHEDULED + 84, 2);
    jbed_vm_put_word(memory, SCHEDULED + 20, CTX);
    jbed_vm_put_word(memory, CTX + 16, FP | 4);
    jbed_vm_put_word(memory, CTX + 20, PC | 1);
    jbed_vm_put_word(memory, FP - 8, FP); /* FP == caller SP is the KNI frame. */
    jbed_vm_put_word(memory, FP - 4, PC + 5);
    jbed_vm_put_word(memory, FP, KNI - FP);
    jbed_vm_put_word(memory, NATIVE - 8, BASE);
    jbed_vm_put_word(memory, BASE, KNI);
    jbed_vm_put_word(memory, BASE + 4, PC + 9);
    jbed_vm_put_word(memory, BASE + 20, KNI + 24);
    jbed_vm_put_word(memory, BASE + 24, 0x336010);
    jbed_vm_put_word(memory, BASE + 28, UINT32_MAX);
    JbedVmNativeFrames native = {.base = BASE, .frame = NATIVE};
    Visits result = {0};
    JbedVmRootVisitor visitor = {&result, record_slot, record_interior};
    jbed_vm_traverse_stack(&maps, SCHEDULED, SCHEDULED, &native, &visitor);
    const JbedAddress expected[] = {CTX + 4, SP, FP - 16, 0x336010, (BASE + 16) | 1u};
    assert(result.count == sizeof(expected) / sizeof(expected[0]));
    for (size_t i = 0; i < result.count; ++i)
        assert(expected[i] == result.slots[i]);
    assert(result.interior == BASE + 32);
    jbed_vm_stack_maps_remove(&maps, id);

    /* StackMapBlock.find stops on an exact match at the current midpoint. */
    jbed_vm_put_word(memory, HEADER + 28, (4u << 22) | 1);
    jbed_vm_stack_map_add(&maps, HEADER, id);
    assert(jbed_vm_stack_map_word(&maps, PC + 5, 0) == 2);
    assert(jbed_vm_stack_map_word(&maps, PC + 9, 0) == 4);
    free(memory.data);
    puts("resident stack maps, managed spills and KNI roots passed");
    return 0;
}
