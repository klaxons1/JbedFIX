#ifdef NDEBUG
#undef NDEBUG
#endif
#include "vm_mark.h"
#include "vm_compactor.h"
#include "vm_words.h"

#include <assert.h>
#include <string.h>

int main(void)
{
    uint8_t data[0x2400] = {0}, expected[sizeof data];
    JbedBuffer mem = {.data = data, .size = sizeof data, .address = 0x1000};
    JbedVmHeap heap = {.memory = mem};
    JbedVmMarker marker = {.heap = &heap};
    enum {
        META_TAG = 0x1040,
        NODE_TAG = 0x1080,
        ARRAY_TAG = 0x10c0,
        META = 0x1100,
        NODE_CLASS = 0x1140,
        ARRAY_CLASS = 0x1180,
        ROOT = 0x1200,
        ARRAY = 0x1240,
        LOCK = 0x1280,
        LAST = 0x12c0,
        EMPTY = 0x1300,
        DEAD = 0x1340,
        SLOTS = 0x1380,
        STATICS = 0x1800,
        SOFT = 0x1400,
        WEAK = 0x1440,
        SOFT_VALUE = 0x1480,
        WEAK_VALUE = 0x14c0
    };
    jbed_vm_put_word(mem, META_TAG, META);
    jbed_vm_put_word(mem, META + 4, 1);
    jbed_vm_put_word(mem, NODE_TAG, NODE_CLASS);
    jbed_vm_put_word(mem, NODE_CLASS, META_TAG);
    jbed_vm_put_word(mem, NODE_CLASS + 36, NODE_TAG);
    jbed_vm_put_word(mem, ARRAY_TAG, ARRAY_CLASS);
    jbed_vm_put_word(mem, ARRAY_CLASS, META_TAG);
    jbed_vm_put_word(mem, ARRAY_CLASS + 36, ARRAY_TAG);
    jbed_vm_put_word(mem, ARRAY_TAG - 4, UINT32_C(0x80000102));
    jbed_vm_put_word(mem, NODE_TAG - 24, 16 | (12u << 16));
    jbed_vm_put_word(mem, NODE_TAG - 28, 0xfffcu << 16);
    jbed_vm_put_word(mem, ROOT, NODE_TAG);
    jbed_vm_put_word(mem, ROOT + 8, LOCK);
    jbed_vm_put_word(mem, ROOT + 12, ARRAY);
    jbed_vm_put_word(mem, ROOT + 16, EMPTY);
    jbed_vm_put_word(mem, LOCK, NODE_TAG);
    jbed_vm_put_word(mem, LOCK + 12, ROOT);
    jbed_vm_put_word(mem, EMPTY, ARRAY_TAG);
    jbed_vm_put_word(mem, ARRAY, ARRAY_TAG);
    jbed_vm_put_word(mem, ARRAY + 12, 4);
    jbed_vm_put_word(mem, ARRAY + 16, LAST);
    jbed_vm_put_word(mem, ARRAY + 24, ROOT);
    jbed_vm_put_word(mem, ARRAY + 28, LAST);
    jbed_vm_put_word(mem, LAST, NODE_TAG);
    jbed_vm_put_word(mem, LAST + 16, ARRAY);
    jbed_vm_put_word(mem, DEAD, NODE_TAG);
    jbed_vm_put_word(mem, SLOTS + 4, ROOT);

    JbedAddress alive[] = {ROOT, LOCK, LAST, ARRAY, EMPTY, NODE_CLASS, ARRAY_CLASS};
    for (size_t i = 0; i < sizeof alive / sizeof *alive; ++i)
        jbed_vm_put_word(mem, alive[i] + 4, 0x54);
    memcpy(expected, data, sizeof data);
    for (size_t i = 0; i < sizeof alive / sizeof *alive; ++i)
        expected[alive[i] - mem.address + 4] |= 1;
    jbed_vm_mark_internal_pointer(&marker, SLOTS | 1);
    assert(memcmp(expected, data, sizeof data) == 0);

    jbed_vm_put_word(mem, STATICS + 1512, SOFT);
    jbed_vm_put_word(mem, SOFT + 12, SOFT_VALUE);
    jbed_vm_put_word(mem, SOFT + 16, WEAK);
    jbed_vm_put_word(mem, SOFT + 4, 1);
    jbed_vm_put_word(mem, SOFT + 28, 1);
    jbed_vm_put_word(mem, WEAK + 12, WEAK_VALUE);
    jbed_vm_put_word(mem, WEAK + 4, 1);
    jbed_vm_put_word(mem, SOFT_VALUE, NODE_TAG);
    jbed_vm_put_word(mem, WEAK_VALUE, NODE_TAG);
    jbed_vm_hide_special_references(&marker, STATICS);
    assert(jbed_vm_word(mem, STATICS + 1512) == 0);
    assert(jbed_vm_word(mem, STATICS + 2320) == SOFT && jbed_vm_word(mem, SOFT + 24) == WEAK);
    assert(jbed_vm_word(mem, SOFT + 16) == 0 && jbed_vm_word(mem, WEAK + 12) == 0);
    jbed_vm_process_references(&marker, STATICS, false);
    assert(heap.soft_references == 1 && jbed_vm_word(mem, SOFT + 28) == 0);
    assert(jbed_vm_word(mem, STATICS + 1512) == SOFT);
    assert(jbed_vm_word(mem, SOFT + 12) == SOFT_VALUE && jbed_vm_word(mem, SOFT_VALUE + 4) == 1);
    assert(!jbed_vm_word(mem, WEAK + 12) && !jbed_vm_word(mem, WEAK_VALUE + 4));

    jbed_vm_put_word(mem, SOFT_VALUE + 4, 0);
    jbed_vm_put_word(mem, SOFT + 28, 9);
    jbed_vm_hide_special_references(&marker, STATICS);
    jbed_vm_process_references(&marker, STATICS, true);
    assert(!heap.soft_references && !jbed_vm_word(mem, STATICS + 1512));
    assert(!jbed_vm_word(mem, SOFT + 12) && !jbed_vm_word(mem, SOFT_VALUE + 4));
    assert(jbed_vm_word(mem, SOFT + 28) == 9);
    JbedVmNativeFrames frames = {.base = SLOTS, .frame = SLOTS + 48};
    JbedVmCollector gc = {.marker = marker, .stacks.native_frames = &frames};
    JbedVmCompactor compactor;
    jbed_vm_compactor_init(&compactor, &gc, 0);
    JbedVmRootVisitor roots = jbed_vm_compact_root_visitor(&compactor);

    jbed_vm_put_word(mem, SLOTS, LAST);
    jbed_vm_put_word(mem, SLOTS + 4, LAST);
    jbed_vm_put_word(mem, LAST + 4, 0x41);
    roots.stack_reference(roots.context, SLOTS);
    assert(jbed_vm_word(mem, LAST + 4) == SLOTS);
    roots.stack_reference(roots.context, (SLOTS + 4) | 1);
    assert(jbed_vm_word(mem, SLOTS) == LAST && jbed_vm_word(mem, LAST + 4) == 0x43);
    assert(compactor.stack_locked == 1);

    jbed_vm_put_word(mem, SLOTS + 24, UINT32_MAX);
    jbed_vm_put_word(mem, SLOTS + 28, SLOTS + 8);
    jbed_vm_put_word(mem, SLOTS + 32, ROOT);
    jbed_vm_put_word(mem, SLOTS + 8, ROOT + 14);
    jbed_vm_put_word(mem, ROOT + 4, 1);
    roots.internal_pointer(roots.context, SLOTS + 28);
    assert(jbed_vm_word(mem, SLOTS + 8) == 14 && jbed_vm_word(mem, ROOT + 4) == SLOTS + 32);
    jbed_vm_put_word(mem, SLOTS + 32, DEAD);
    jbed_vm_compact_fix_interior(&compactor);
    assert(jbed_vm_word(mem, SLOTS + 8) == DEAD + 14);
    return 0;
}
