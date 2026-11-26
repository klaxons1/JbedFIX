#ifndef JBED_PLATFORM_JBNI_OBJECTS_H
#define JBED_PLATFORM_JBNI_OBJECTS_H

#include <stdint.h>
#include "vm/vm_async.h"

typedef uint32_t JbRef;

typedef struct JbArray {
    uint32_t header[3];
    int32_t length;
    uint32_t data[];
} JbArray;

typedef struct {
    uint32_t header[3];
    JbRef chars;
    int32_t offset, length;
} JbString;

static inline const uint16_t *jb_string_chars(const JbString *s)
{
    return (const uint16_t *)(uintptr_t)(s->chars + (uint32_t)s->offset);
}

static inline JbRef jb_ref(const void *object)
{
    return (JbRef)(uintptr_t)object;
}

extern JbArray *Jbni_newIntArray(int count);
extern JbArray *Jbni_newByteArray(int count);
extern JbArray *Jbni_newObjectArray(int count);
extern JbString *Jbni_intern_newString(const char *utf8);
extern JbString *Jbni_intern_newStringExc(const char *utf8);

/* Each entry on the VM's native root stack points to a movable local reference. */
extern void **Jbed_nativeCallStateAdr;
static inline int *jb_current_notifier(void)
{
    return &vm_current_notifier()->state;
}

enum JbCommonException {
    JBED_EXCEPTION_NULL_POINTER = 0, JBED_EXCEPTION_ARRAY_BOUNDS = 1,
    JBED_EXCEPTION_STRING_BOUNDS = 16, JBED_EXCEPTION_ILLEGAL_ARGUMENT = 17,
    JBED_EXCEPTION_OUT_OF_MEMORY = 18, JBED_EXCEPTION_IO = 19,
    JBED_EXCEPTION_INDEX_BOUNDS = 20
};

enum JbUpcallCode {
    JBED_UPCALL_AMS = 210,
    JBED_UPCALL_FILE_SYSTEM = 300,
    JBED_UPCALL_SMS = 501,
    JBED_UPCALL_PUSH = 1100,
    JBED_UPCALL_INDICATOR = 1600,
    JBED_UPCALL_JAVA_UI = 2500
};

typedef struct JbUpcallQueue JbUpcallQueue;
extern JbUpcallQueue *Jbed_upcall_createQueue(int capacity, int priority);
extern void Jbed_upcall_deleteQueue(JbUpcallQueue *);
extern int Jbed_upcall_sendSimple(JbUpcallQueue *, int isolate, int code, int value);
extern int Jbed_upcall_sendComplex(JbUpcallQueue *, int isolate, int code, int value,
                                   const char *format, ...);
#endif
