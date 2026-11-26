#ifndef JBED_VM_OS_H
#define JBED_VM_OS_H

#include <stdint.h>

extern int jbed_foreground_display, jbed_foreground_isolate;
void CPL_os_setHeapSize(int size);
void CPL_os_setHeapIncrementSize(int size);
void CPL_os_setHeapFirstChunkSize(int size);
int JbniS_com_jbed_ams_NativeAms_nativeGetHeapSize(void);
void OPL_os_getHeapBlock(void **address, uint32_t *size);
void OPL_os_freeHeapBlock(void *address);
int64_t CPL_os_getMillisElapsed(void);
int64_t CPL_os_getMillisSince1970(void);
int64_t OPL_os_getElapsedMicros(void);
int OPL_os_initTimer(int micros);
int OPL_os_startTimer(void);
int OPL_os_resetTimer(void);
void updateSystemTime(void);
void jbed_os_initialize(void);
void jbed_os_finalize(void);
void Jbed_props_startup(void);
void Jbed_props_shutdown(void);
const char *Jbed_getProperty(const char *key);
const char *Jbed_setProperty(const char *key, const char *value);
const char *Jbed_setPropertyDefault(const char *key, const char *value);
const char *getStorageRoot(void);
int processMemorySizeValue(const char *value);
void setupMidpHome(const char *home);
char **jbed_processCmdLine(int argc, char **argv, int *count, const char *home);

#endif
