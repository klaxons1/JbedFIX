#ifndef JBED_SWERVE_KNI_H
#define JBED_SWERVE_KNI_H

#include "swv_kni_helpers.h"
#include <string.h>

JbRef JbedKNI_VerifyObject(JbRef ref, int kind);
JbRef JbedKNI_NewUtfString(const char *bytes, int replace_slashes);
int JbedKNI_ThrowNew(const char *class_name, JbRef message);
void JbedKNI_FatalError(const char *message);

/* The native-call stack contains addresses of local Java references. */
static inline void **kni_push_roots(JbRef *roots, unsigned count)
{
    void **saved = Jbed_nativeCallStateAdr;
    for (unsigned i = 0; i < count; ++i)
        *Jbed_nativeCallStateAdr++ = &roots[i];
    return saved;
}

static inline void *kni_peer(JbRef *root, unsigned slot, swvBaseClassFIDs field)
{
    *root = JbedKNI_VerifyObject(Jbed_ParamPtr[slot], slot ? 'o' : 'O');
    return SWV_GetSwerveHandleFromPeer(root, field);
}

static inline float kni_float(unsigned slot)
{
    float result;
    memcpy(&result, &Jbed_ParamPtr[slot], sizeof(result));
    return result;
}

static inline uint32_t kni_float_result(float value)
{
    uint32_t result;
    memcpy(&result, &value, sizeof(result));
    return result;
}

typedef struct {
    void *data;
    unsigned count;
} KniArray;

static inline void copy_back(JbRef *root, unsigned element_size, KniArray *array)
{
    if (array->data)
        SWV_RestoreArrayBytes(root, element_size, array->data, array->count);
}

#define KNI_ROOTS(count) \
    JbRef roots[count] = {0}; \
    void **saved_roots = kni_push_roots(roots, count)

#define M3G_ENTRY(name) Java_javax_microedition_m3g_##name
#endif
