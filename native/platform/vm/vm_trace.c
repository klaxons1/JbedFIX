#include "jbni_objects.h"

extern int android_LOGD(const char *format, ...);
extern int Jbni_intern_getClassNameUtf8(JbRef, char *, int);
extern int Jbni_intern_getStringAscii(const JbString *, char *, int);
extern JbRef JbniF_com_jbed_runtime_Base_stackOV;
int verboseGc;

void OPL_trace_traceMethodEntry(void) {}
void OPL_trace_traceMethodExit(void) {}
void OPL_trace_traceInit(void) {}
void OPL_trace_registerDebugSymbol(const JbString *s, int address) { (void)s; (void)address; }

void OPL_trace_traceClassInit(JbRef clazz, int entering)
{
    (void)entering;
    char name[128];
    Jbni_intern_getClassNameUtf8(clazz, name, sizeof(name));
}

static const char *trace_format(const JbString *s)
{
    static char format[128];
    Jbni_intern_getStringAscii(s, format, sizeof(format));
    return format;
}

void OPL_trace_printf0(const JbString *s) { android_LOGD(trace_format(s)); }
void OPL_trace_printf1(const JbString *s, int a) { android_LOGD(trace_format(s), a); }
void OPL_trace_printf2(const JbString *s, int a, int b) { android_LOGD(trace_format(s), a, b); }
void OPL_trace_printf3(const JbString *s, int a, int b, int c) { android_LOGD(trace_format(s), a, b, c); }
void OPL_trace_printf4(const JbString *s, int a, int b, int c, int d) { android_LOGD(trace_format(s), a, b, c, d); }

void OPL_trace_traceCompactor(int free_bytes, int largest, int millis)
{
    static int pass;
    if (verboseGc) {
        const char *format = "Compact%3d:%8d free,%8d max,%4d%% after,%4d ms";
        if (millis < 0) {
            format = "Compact%3d:%8d free,%8d max,%4d%% before, %d ms";
            ++pass;
            millis = (int32_t)(0u - (unsigned)millis);
        }
        android_LOGD(format, pass, free_bytes, largest, (int32_t)(100u * largest) / free_bytes, millis);
    }
}

void OPL_trace_traceCollector(int heap, int used, int millis)
{
    static int pass;
    if (verboseGc) {
        const char *format = "GC%3d:%8d heap,%8d used,%4d%% after,%4d ms";
        if (millis < 0) {
            format = "GC%3d:%8d heap,%8d used,%4d%% before, %d ms";
            ++pass;
            millis = (int32_t)(0u - (unsigned)millis);
        }
        android_LOGD(format, pass, heap, used, (int32_t)(100u * used) / heap, millis);
    }
}

typedef struct {
    JbRef dispatch;
    uint32_t header[2];
    JbRef frames, message;
} Throwable;

typedef struct {
    uint32_t header[3];
    JbRef next;
    uint32_t words[4];
} TraceFrame;

static void print_throwable(const Throwable *e, const char *label)
{
    static char text[128];
    JbRef clazz = *(const JbRef *)(uintptr_t)e->dispatch;
    Jbni_intern_getClassNameUtf8(clazz, text, sizeof(text));
    android_LOGD("%s: %s", label, text);
    if (e->message) {
        Jbni_intern_getStringAscii((const JbString *)(uintptr_t)e->message, text, sizeof(text));
        android_LOGD("\tMsg: %s", text);
    }
    for (JbRef ref = e->frames; ref;) {
        const TraceFrame *f = (const TraceFrame *)(uintptr_t)ref;
        android_LOGD("0x%08x 0x%08x 0x%08x 0x%08x", f->words[0], f->words[1], f->words[2], f->words[3]);
        ref = f->next;
    }
}

void jbedri_trace_printThrowable(const Throwable *e, const char *label)
{
    if (jb_ref(e) == JbniF_com_jbed_runtime_Base_stackOV)
        android_LOGD("ERROR: stack overflow!!.");
    else
        print_throwable(e, label);
}

void OPL_trace_traceUncaught(const Throwable *e) { jbedri_trace_printThrowable(e, "Uncaught"); }
void OPL_trace_traceThrow(const Throwable *e, int caught, int pc)
{
    (void)pc;
    jbedri_trace_printThrowable(e, caught ? "Throw" : "Uncaught");
}

void CPL_os_logChar(int c)
{
    static int length;
    static char line[513];
    if (c != 13 && c != 10 && length <= 511) {
        line[length++] = (char)c;
        return;
    }
    line[length] = 0;
    android_LOGD("[java] %s\n", line);
    length = 0;
}
