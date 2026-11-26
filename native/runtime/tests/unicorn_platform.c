/* Test-only adapters for console logging and the timer callback. */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

extern void Jbed_timerEntry(void);
void doTimer(void) { Jbed_timerEntry(); }
int android_LOGD(const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    int result = vprintf(format, arguments);
    va_end(arguments);
    return result;
}
_Noreturn void jbed_unicorn_unavailable(const char *name)
{
    fprintf(stderr, "UNAVAILABLE ANDROID SERVICE: %s\n", name);
    exit(125);
}
