#include "vm_monitor.h"
#include "vm_words.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>

enum {
    STATICS = 0x220000, READY = 0x221100,
    LOW = 0x221200, MID = 0x221300, HIGH = 0x221400, PEER = 0x221500,
    RAM_LOCK = 0x221600, ROM_LOCK = 0x221620
};

typedef struct WaitSwitch {
    JbedVmMonitors *vm;
    JbedAddress sync;
    unsigned switches;
} WaitSwitch;

static uint64_t clock_micros(void *context)
{
    (void)context;
    return UINT64_C(0x100000005);
}

/* The waiter resumes while the notifier still owns the lock. Its second
 * context switch is the contested JEnter0 inside Synchronizer.Wait. */
static void switch_thread(void *context)
{
    WaitSwitch *s = context;
    JbedBuffer m = s->vm->heap->memory;
    switch (++s->switches) {
    case 1:
        assert(jbed_vm_word(m, s->sync + 20) == MID);
        assert(jbed_vm_word(m, MID + 88) == 23010 && jbed_vm_word(m, MID + 92) == 1);
        assert(jbed_vm_word(m, READY + 132) == MID);
        jbed_vm_put_word(m, STATICS + 976, LOW);
        assert(jbed_vm_monitor_enter(s->vm, ROM_LOCK) == JBED_MONITOR_DONE);
        assert(jbed_vm_monitor_notify(s->vm, ROM_LOCK, true) == JBED_MONITOR_DONE);
        assert(!jbed_vm_word(m, READY + 132) && !jbed_vm_word(m, MID + 164));
        assert(jbed_vm_word(m, LOW + 72) == 5);
        break;
    case 2:
        assert(jbed_vm_word(m, MID + 160) == s->sync);
        jbed_vm_put_word(m, STATICS + 976, LOW);
        assert(jbed_vm_monitor_exit(s->vm, ROM_LOCK) == JBED_MONITOR_DONE);
        assert(jbed_vm_word(m, s->sync + 16) == MID && jbed_vm_word(m, LOW + 72) == 1);
        break;
    case 3: /* Notifier's xYield. */
        return;
    default:
        assert(0);
    }
    jbed_vm_put_word(m, STATICS + 976, MID);
    jbed_vm_put_word(m, MID + 84, 3);
}

int main(void)
{
    static uint8_t bytes[0x321000];
    JbedBuffer m = {bytes, sizeof bytes, 0};
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, m, 0);
    const JbedAddress klass = 0x2105a0, tag = 0x210060;
    jbed_vm_put_word(m, klass + 28, 32);
    jbed_vm_put_word(m, klass + 36, tag);
    jbed_vm_put_word(m, 0x320100, tag); /* Base.synchronizerTag. */
    jbed_vm_put_word(m, tag - 4, 32);
    jbed_vm_put_word(m, tag, klass);
    assert(jbed_vm_heap_add_chunk(&heap, 0x225000, 1024, true));
    const JbedAddress array = 0x25e580, array_tag = 0x2100c0;
    jbed_vm_put_word(m, array + 20, klass);
    jbed_vm_put_word(m, array + 36, array_tag);
    jbed_vm_put_word(m, array_tag - 4, 0x80000102u);
    jbed_vm_put_word(m, array_tag, array);
    jbed_vm_put_word(m, 0xab394, 3);
    JbedVmMonitors vm;
    assert(jbed_vm_monitors_init(&vm, &heap, 0, STATICS));
    JbedAddress table = jbed_vm_word(m, STATICS + 952);
    assert(jbed_vm_word(m, table + 12) == 3);
    jbed_vm_put_word(m, STATICS + 972, READY);
    const JbedAddress threads[] = {HIGH, PEER, MID, LOW};
    const unsigned priorities[] = {9, 9, 5, 1};
    for (unsigned i = 0; i < 4; ++i) {
        JbedAddress th = threads[i], prev = i ? threads[i - 1] : READY;
        jbed_vm_put_word(m, th + 68, priorities[i]);
        jbed_vm_put_word(m, th + 72, priorities[i]);
        jbed_vm_put_word(m, th + 84, 3);
        *jbed_vm_at(m, th + 108) = 1;
        jbed_vm_put_word(m, th + 144, prev);
        jbed_vm_put_word(m, prev + 140, th);
    }
    jbed_vm_put_word(m, ROM_LOCK + 8, 5); /* Isolate table slot 2. */
    jbed_vm_put_word(m, STATICS + 976, LOW);
    assert(jbed_vm_monitor_enter(&vm, ROM_LOCK) == JBED_MONITOR_DONE);
    assert(jbed_vm_word(m, table + 24) == LOW);
    jbed_vm_put_word(m, STATICS + 976, MID);
    assert(jbed_vm_monitor_enter(&vm, RAM_LOCK) == JBED_MONITOR_DONE);
    assert(jbed_vm_monitor_enter(&vm, RAM_LOCK) == JBED_MONITOR_DONE);
    JbedAddress ram_sync = jbed_vm_word(m, RAM_LOCK + 8);
    assert(jbed_vm_half(m, ram_sync + 14) == 1);
    assert(jbed_vm_monitor_exit(&vm, RAM_LOCK) == JBED_MONITOR_DONE);
    assert(jbed_vm_monitor_enter(&vm, ROM_LOCK) == JBED_MONITOR_BLOCKED);
    assert(jbed_vm_word(m, LOW + 72) == 5);
    jbed_vm_put_word(m, STATICS + 976, HIGH);
    assert(jbed_vm_monitor_enter(&vm, RAM_LOCK) == JBED_MONITOR_BLOCKED);
    assert(jbed_vm_word(m, LOW + 72) == 9 && jbed_vm_word(m, MID + 72) == 9);
    jbed_vm_put_word(m, STATICS + 976, PEER);
    assert(jbed_vm_monitor_enter(&vm, RAM_LOCK) == JBED_MONITOR_BLOCKED);
    assert(jbed_vm_word(m, ram_sync + 24) == HIGH && jbed_vm_word(m, HIGH + 156) == PEER);
    assert(jbed_vm_word(m, READY + 140) == LOW);
    jbed_vm_put_word(m, STATICS + 976, LOW);
    assert(jbed_vm_monitor_exit(&vm, ROM_LOCK) == JBED_MONITOR_YIELD);
    assert(jbed_vm_word(m, LOW + 72) == 1 && jbed_vm_word(m, READY + 140) == MID);
    jbed_vm_put_word(m, STATICS + 976, MID);
    assert(jbed_vm_monitor_exit(&vm, RAM_LOCK) == JBED_MONITOR_YIELD);
    assert(jbed_vm_word(m, ram_sync + 16) == HIGH && jbed_vm_word(m, ram_sync + 24) == PEER);
    JbedAddress rom_sync = jbed_vm_word(m, table + 24);
    assert(jbed_vm_word(m, MID + 72) == 5 && jbed_vm_word(m, MID + 168) == rom_sync);
    jbed_vm_put_word(m, 0x320050, 0x221800);
    jbed_vm_put_word(m, 0x320078, 0x221820);
    JbedVmExceptionTransfer unwind = {.action = JBED_VM_RELEASE_MONITOR, .handler_or_monitor = RAM_LOCK,
                                     .throwable = 0x221840};
    assert(jbed_vm_monitor_unwind(&vm, &unwind) == JBED_MONITOR_DONE && unwind.throwable == 0x221800);
    unwind.throwable = 0x221820;
    assert(jbed_vm_monitor_unwind(&vm, &unwind) == JBED_MONITOR_DONE && unwind.throwable == 0x221820);
    assert(jbed_vm_monitor_enter(&vm, 0) == JBED_MONITOR_NULL_POINTER);
    assert(jbed_vm_monitor_extend_table(&vm, 4) == JBED_ERROR_NONE);
    JbedAddress expanded = jbed_vm_word(m, STATICS + 952);
    assert(expanded != table && jbed_vm_word(m, expanded + 12) == 7);
    assert(jbed_vm_word(m, expanded + 24) == rom_sync);
    assert(jbed_vm_monitor_extend_table(&vm, -1) == JBED_ERROR_ARRAY_INDEX);
    assert(jbed_vm_monitor_extend_table(&vm, -9) == JBED_ERROR_NEGATIVE_ARRAY_SIZE);
    assert(jbed_vm_word(m, STATICS + 952) == expanded);
    assert(jbed_vm_monitor_enter(&vm, ROM_LOCK) == JBED_MONITOR_DONE);
    WaitSwitch switches = {&vm, rom_sync, 0};
    vm.scheduling.context = &switches;
    vm.scheduling.elapsed_micros = clock_micros;
    vm.scheduling.yield_to_scheduler = switch_thread;
    assert(jbed_vm_monitor_wait(&vm, ROM_LOCK, 23, 5500) == JBED_MONITOR_DONE);
    assert(switches.switches == 3 && jbed_vm_half(m, rom_sync + 14) == 1);
    assert(jbed_vm_word(m, STATICS + 2040) == 1 && !*jbed_vm_at(m, MID + 111));
    *jbed_vm_at(m, MID + 110) = 1;
    assert(jbed_vm_monitor_wait(&vm, ROM_LOCK, 0, 0) == JBED_MONITOR_INTERRUPTED);
    assert(!*jbed_vm_at(m, MID + 110) && switches.switches == 3);
    return 0;
}
