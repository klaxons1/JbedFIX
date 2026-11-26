#include "vm_os.h"
#include "vm_helpers.h"
#include "jbni_objects.h"

#include <signal.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/time.h>

extern void CPL_os_flushCache(void *start, int size);
extern void doTimer(void);
extern int android_LOGD(const char *format, ...);
extern void setUpExistingRoots(void);
extern void destoryExistingRoots(void);
extern void Jbed_doRawEvent(void *signal, int event);

enum { HEAP_CHUNK_SHIFT = 18, HEAP_CHUNK_HEADER_BYTES = 4, NATIVE_STACK_RESERVE_BYTES = 4096 };
static int32_t heap_limit = 4 * 1024 * 1024;
static uint32_t mapped_size;
static int64_t base_micros;
struct itimerval timerPeriod;
int jbed_foreground_isolate = -1;
int jbed_foreground_display = -1;
static void *event_signal;

void OPL_os_showLED(void) {}
void CPL_os_setHeapSize(int size) { heap_limit = size; }
int JbniS_com_jbed_ams_NativeAms_nativeGetHeapSize(void) { return heap_limit; }
void CPL_os_setHeapIncrementSize(int size) { (void)size; }
void CPL_os_setHeapFirstChunkSize(int size) { (void)size; }
int OPL_os_getStackSpace(void) { return NATIVE_STACK_RESERVE_BYTES; }

void OPL_os_getHeapBlock(void **address, uint32_t *size)
{
    uint32_t requested = *size ? *size : (uint32_t)(heap_limit / 2);
    uint32_t chunk = (((requested + HEAP_CHUNK_HEADER_BYTES) >> HEAP_CHUNK_SHIFT) + 1) << HEAP_CHUNK_SHIFT;
    *address = NULL;
    *size = 0;
    if ((int32_t)(mapped_size + chunk) > heap_limit) return;
    uint32_t *mapping = mmap(NULL, chunk, PROT_READ | PROT_WRITE | PROT_EXEC,
                             MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    /* 0xa2ab0 compares the mapping with NULL. */
    if (mapping) {
        mapped_size += chunk;
        *mapping = chunk;
        *address = mapping + 1;
        *size = chunk - HEAP_CHUNK_HEADER_BYTES;
    }
}

void OPL_os_freeHeapBlock(void *address)
{
    uint32_t *mapping = (uint32_t *)address - 1;
    uint32_t chunk = *mapping;
    mapped_size -= chunk;
    munmap(mapping, chunk);
}

void OPL_os_intern_getHeapBlock(void **address, uint32_t *size) { OPL_os_getHeapBlock(address, size); }
void OPL_os_intern_freeHeapBlock(void *address) { OPL_os_freeHeapBlock(address); }
void OPL_os_intern_flushCache(void *start, int size) { CPL_os_flushCache(start, size); }

static int64_t wall_micros(void)
{
    struct timeval t;
    gettimeofday(&t, NULL);
    return (int64_t)(int32_t)t.tv_sec * 1000000 + t.tv_usec;
}

void updateSystemTime(void) { base_micros = wall_micros(); }
int64_t OPL_os_getElapsedMicros(void) { return wall_micros() - base_micros; }

int64_t CPL_os_getMillisElapsed(void)
{
    struct timeval t;
    gettimeofday(&t, NULL);
    return (int64_t)(int32_t)t.tv_sec * 1000 + t.tv_usec / 1000;
}

int64_t CPL_os_getMillisSince1970(void) { return CPL_os_getMillisElapsed(); }

static void timer_tick(int sig) { (void)sig; doTimer(); }

int OPL_os_initTimer(int micros)
{
    updateSystemTime();
    timerPeriod.it_value.tv_sec = micros / 1000000;
    timerPeriod.it_value.tv_usec = 1000 * (micros / 1000 - 1000 * timerPeriod.it_value.tv_sec);
    struct sigaction action = {.sa_handler = timer_tick, .sa_flags = SA_RESTART};
    sigemptyset(&action.sa_mask);
    return sigaction(SIGVTALRM, &action, NULL);
}

int OPL_os_resetTimer(void) { return setitimer(ITIMER_VIRTUAL, &timerPeriod, NULL); }
int OPL_os_startTimer(void) { return setitimer(ITIMER_VIRTUAL, &timerPeriod, NULL); }

void OPL_os_fatalError(const JbString *message)
{
    char buffer[1024];
    Jbni_convertUcs2ToAscii(jb_string_chars(message), message->length, buffer, sizeof(buffer));
    android_LOGD("Fatal Error: %s\n", buffer);
    exit(1);
}

void jbed_os_initialize(void) { setUpExistingRoots(); }
void jbed_os_finalize(void) { destoryExistingRoots(); }

void OPL_event_start(void *signal) { event_signal = signal; }
void OPL_event_stop(void) { event_signal = NULL; }

void jbedPostRawEvent(int event)
{
    android_LOGD("jbedPostRawEvent() eventsHandle=%p\n", event_signal);
    if (event_signal) Jbed_doRawEvent(event_signal, event);
}

void JbniS_com_jbed_midp_lcdui_toolkit_peer_StandardDisplayPeer_nSetForeground(int display, int isolate)
{
    jbed_foreground_isolate = isolate;
    jbed_foreground_display = display;
}
