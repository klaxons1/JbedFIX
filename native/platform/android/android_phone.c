#include "jbni_objects.h"
#include "vm_os.h"

#include <stdlib.h>

extern void Jbni_intern_raiseCommonException(int);
extern int android_midp_setVibrate(int);
extern int android_midp_getCurrentLanguage(char **);
extern int android_midp_getString(int, int, char **);

static JbUpcallQueue *indicator_queue;
static int indicator_users;
static int64_t last_traffic;

int JbniS_com_jbed_runtime_PhoneSystem_isSupported0(int key) { return key == 1; }

static int unsupported(void)
{
    Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
    return 0;
}

int JbniS_com_jbed_runtime_PhoneSystem_setObj0(int key, void *value)
{
    (void)key; (void)value;
    return unsupported();
}

void *JbniS_com_jbed_runtime_PhoneSystem_getObj0(int key)
{
    (void)key;
    unsupported();
    return NULL;
}

int JbniS_com_jbed_runtime_PhoneSystem_setInt0(int key, int value)
{
    (void)value;
    return key == 1 ? 1 : unsupported();
}

int JbniS_com_jbed_runtime_PhoneSystem_getInt0(int key) { (void)key; return unsupported(); }
int JbniS_com_jbed_runtime_PhoneSystem_getBool0(int key) { (void)key; return unsupported(); }

int JbniS_com_jbed_runtime_PhoneSystem_setBool0(int key, int value)
{
    if (key != 1) return 0;
    android_midp_setVibrate(value);
    return 1;
}

void CPL_os_flushCache(void *start, int size)
{
    if (size > 0) __builtin___clear_cache(start, (char *)start + size);
}

int CPL_indicator_setIndicator(int indicator, int level)
{
    Jbed_upcall_sendComplex(indicator_queue, -1, JBED_UPCALL_INDICATOR, 10, "ii", indicator, level);
    return 0;
}

int activeIndicators(int type, int connection, int direction, int level)
{
    static const int indicators[] = {1,0,0,0,0,0,0,0,2,3,0,0,0,0,0,0,0,0,4};
    (void)connection; (void)direction;
    unsigned index = (unsigned)type - 2;
    return CPL_indicator_setIndicator(index < 19 ? indicators[index] : 0, level);
}

int CPL_indicator_connectionClose(int type, int connection)
{
    activeIndicators(type, connection, 0, 0);
    return 0;
}

int CPL_indicator_connectionOpen(int type, int connection)
{
    activeIndicators(type, connection, 0, 100);
    return 0;
}

int CPL_indicator_trafficIncrement(int type, int connection, int direction, int level)
{
    if (CPL_os_getMillisElapsed() - last_traffic > 99) {
        activeIndicators(type, connection, direction, level);
        last_traffic = CPL_os_getMillisElapsed();
    }
    return 0;
}

int CPL_indicator_startup(void)
{
    if (!indicator_users)
        indicator_queue = Jbed_upcall_createQueue(1024, 0);
    ++indicator_users;
    return indicator_queue ? 0 : -1;
}

int CPL_indicator_shutdown(void)
{
    if (!--indicator_users) Jbed_upcall_deleteQueue(indicator_queue);
    return 0;
}

void JbniS_com_jbed_util_I18N_nSetCurrentLanguage(const JbString *language) { (void)language; }

JbString *JbniS_com_jbed_util_I18N_nGetAvailableLanguage(void)
{
    return Jbni_intern_newStringExc("en-US");
}

JbString *JbniS_com_jbed_util_I18N_nGetCurrentLanguage(void)
{
    char *utf = NULL;
    if (android_midp_getCurrentLanguage(&utf) == -1) return NULL;
    JbString *s = Jbni_intern_newStringExc(utf);
    free(utf);
    return s;
}

JbString *JbniS_com_jbed_util_I18N_nGet(int lang, int key)
{
    char *utf = NULL;
    if (android_midp_getString(lang, key, &utf) == -1) return NULL;
    JbString *s = Jbni_intern_newStringExc(utf);
    free(utf);
    return s;
}
