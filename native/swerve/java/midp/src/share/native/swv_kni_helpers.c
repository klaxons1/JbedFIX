#include "kni_fields.h"
#include "engine.h"
#include "platform.h"
#include "loader.h"
#include <limits.h>

extern JbRef JbedKNI_LookupClass(const char *name);
extern void *JbedKNI_VerifyArray(JbRef array, int index, int kind, JbRef value);
extern void JbedKNI_VerifyArraySetObj(JbRef array, int index, int kind, JbRef value);
extern void JbedKNI_VerifyArrayCopy(JbRef array, unsigned offset, unsigned size, void *native, int to_java);

static FieldId handle_field[swvBaseClassFIDs_Max];
static FieldId xot, xot_length, tmp_xot, clean_peer_table;

int swvEngineInitialize(void) { return swvGetGlobalDataPointer() || engine_initialize() == 1; }
void swvEngineUninitialize(void) { if (swvGetGlobalDataPointer()) engine_uninitialize(); }
int SWV_Engine_getHandleSize(void) { return 0; }
int SWV_Engine_initialize(void) { return swvEngineInitialize(); }
static swvEngineVersion engine_version(void)
{
    swvEngineVersion version;
    engine_getVersion(&version);
    return version;
}

int SWV_Engine_getVersionMajor(void) { return engine_version().m_Major; }
int SWV_Engine_getVersionMinor(void) { return engine_version().m_Minor; }
int SWV_Engine_getRevisionMajor(void) { return engine_version().m_RevisionMajor; }
int SWV_Engine_getRevisionMinor(void) { return engine_version().m_RevisionMinor; }
int SWV_Engine_getBranchNumber(void) { return engine_version().m_Branch; }

int SWV_Engine_getHandleType(void)
{
    int type;
    engine_getHandleType((void *)(uintptr_t)Jbed_ParamPtr[1], &type);
    return type;
}
void SWV_Engine_releaseHandle(void) { engine_releaseHandle((void *)(uintptr_t)Jbed_ParamPtr[1]); }

static int throw_error(int code)
{
    static const char *const classes[] = {
        NULL, "java/lang/RuntimeException", "java/lang/OutOfMemoryError",
        "java/lang/ArithmeticException", "java/lang/RuntimeException", "java/lang/ArithmeticException",
        "java/lang/ArithmeticException", "java/lang/ArithmeticException", "java/lang/IndexOutOfBoundsException",
        "java/io/IOException", "java/io/IOException", "java/io/IOException", "java/io/IOException",
        "java/io/IOException", "java/lang/IllegalStateException", "java/lang/IllegalArgumentException",
        "java/lang/NullPointerException"
    };
    if (code <= 0 || (unsigned)code >= sizeof classes / sizeof *classes) return code;
    int rc = JbedKNI_ThrowNew(classes[code], JbedKNI_NewUtfString("", 0));
    if (rc == -1) JbedKNI_FatalError("Failed to throw exception");
    return rc + 1;
}
int ThrowSwerveAPIException(void)
{
    int code;
    engine_getLastError(&code);
    return throw_error(code);
}
void *SWV_Constructor_HandleReturn(int (*fn)(void **))
{
    void *handle = NULL;
    if (!fn(&handle)) ThrowSwerveAPIException();
    return handle;
}

void SWV_Engine_cacheFID(void)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    root = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    unsigned index = Jbed_ParamPtr[2];
    if (index < sizeof handle_field / sizeof *handle_field)
        handle_field[index] = find_field(root, "swerveHandle", "I", 0);
    Jbed_nativeCallStateAdr = saved;
}
void *SWV_GetSwerveHandleFromPeer(JbRef *root, swvBaseClassFIDs cls)
{
    if (!*root || (unsigned)cls >= sizeof handle_field / sizeof *handle_field) return NULL;
    uint32_t *word = JbedKNI_VerifyField(*root, handle_field[cls], KNI_FIELD_INT, 0);
    return (void *)(uintptr_t)*word;
}
int SWV_UnSafeMethod_Handle(int (*fn)(void *, void *), swvBaseClassFIDs cls, swvBaseClassFIDs arg_cls)
{
    JbRef roots[2] = {0};
    void **saved = kni_push_roots(roots, 2);
    void *self = kni_peer(&roots[0], 0, cls);
    void *other = kni_peer(&roots[1], 1, arg_cls);
    int rc = fn(self, other);
    if (!rc) rc = ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved;
    return rc;
}
void SWV_UnSafeSetter_Handle(int (*fn)(void *, void *), swvBaseClassFIDs cls, swvBaseClassFIDs arg_cls)
{
    SWV_UnSafeMethod_Handle(fn, cls, arg_cls);
}
void SWV_Setter_Handle(void (*fn)(void *, void *), swvBaseClassFIDs cls, swvBaseClassFIDs arg_cls)
{
    JbRef roots[2] = {0};
    void **saved = kni_push_roots(roots, 2);
    void *self = kni_peer(&roots[0], 0, cls);
    void *other = kni_peer(&roots[1], 1, arg_cls);
    fn(self, other);
    Jbed_nativeCallStateAdr = saved;
}
void *SWV_Getter_Handle(void (*fn)(void *, void **), swvBaseClassFIDs cls)
{
    void *result = NULL;
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    fn(kni_peer(&root, 0, cls), &result);
    Jbed_nativeCallStateAdr = saved;
    return result;
}
int SWV_Getter_Integer(void (*fn)(void *, int *), swvBaseClassFIDs cls)
{
    int result;
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    fn(kni_peer(&root, 0, cls), &result);
    Jbed_nativeCallStateAdr = saved;
    return result;
}
int SWV_Getter_Boolean(void (*fn)(void *, int *), swvBaseClassFIDs cls) { return !!SWV_Getter_Integer(fn, cls); }
uint32_t SWV_Getter_Float(void (*fn)(void *, float *), swvBaseClassFIDs cls)
{
    float result;
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    fn(kni_peer(&root, 0, cls), &result);
    Jbed_nativeCallStateAdr = saved;
    return kni_float_result(result);
}
void SWV_Setter_Integer(void (*fn)(void *, int), swvBaseClassFIDs cls)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    void *self = kni_peer(&root, 0, cls);
    fn(self, (int)Jbed_ParamPtr[1]);
    Jbed_nativeCallStateAdr = saved;
}
void SWV_Setter_Boolean(void (*fn)(void *, int), swvBaseClassFIDs cls)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    void *self = kni_peer(&root, 0, cls);
    fn(self, (uint8_t)Jbed_ParamPtr[1] != 0);
    Jbed_nativeCallStateAdr = saved;
}
void SWV_UnSafeSetter_Integer(int (*fn)(void *, int), swvBaseClassFIDs cls)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    void *self = kni_peer(&root, 0, cls);
    if (!fn(self, (int)Jbed_ParamPtr[1])) ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved;
}
void SWV_UnSafeSetter_Float(int (*fn)(void *, float), swvBaseClassFIDs cls)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    void *self = kni_peer(&root, 0, cls);
    if (!fn(self, kni_float(1))) ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved;
}

void SWV_Finalize(swvBaseClassFIDs cls)
{
    JbRef roots[3] = {0};
    void **saved = kni_push_roots(roots, 1);
    void *handle = kni_peer(&roots[0], 0, cls);
    if (handle) {
        engine_releaseHandle(handle);
        *(uint32_t *)JbedKNI_VerifyField(roots[0], handle_field[cls], KNI_FIELD_INT, 0) = 0;
    }
    roots[0] = 0;
    kni_push_roots(roots + 1, 2);
    roots[0] = JbedKNI_LookupClass("javax/microedition/m3g/Engine");
    if (!xot) {
        xot = find_field(roots[0], "XOT", "[Ljavax/microedition/m3g/Object3D;", 8);
        xot_length = find_field(roots[0], "XOTlength", "I", 8);
        tmp_xot = find_field(roots[0], "tmpXOT", "[Ljavax/microedition/m3g/Object3D;", 8);
        clean_peer_table = find_field(roots[0], "cleanPeerTable", "Z", 8);
    }
    *(uint8_t *)JbedKNI_VerifyField(0, clean_peer_table, KNI_FIELD_BOOLEAN, 0) = 1;
    if (!*(JbRef *)JbedKNI_VerifyField(0, tmp_xot, KNI_FIELD_REFERENCE, 0)) {
        int original = *(int *)JbedKNI_VerifyField(0, xot_length, KNI_FIELD_INT, 0), length = original;
        roots[1] = *(JbRef *)JbedKNI_VerifyField(0, xot, KNI_FIELD_REFERENCE, 0);
        for (int i = 0; i < length;) {
            roots[2] = *(JbRef *)JbedKNI_VerifyArray(roots[1], i, 2, 0);
            void *peer = SWV_GetSwerveHandleFromPeer(&roots[2], swvBaseClassFIDs_Object3D);
            int count = 0;
            if (peer) engine_getRefCount(peer, &count);
            if (count != 1) {
                ++i;
                continue;
            }
            roots[2] = 0;
            if (--length > i) {
                roots[2] = *(JbRef *)JbedKNI_VerifyArray(roots[1], length, 2, 0);
                JbedKNI_VerifyArraySetObj(roots[1], i, 2, roots[2]);
                roots[2] = 0;
            }
            JbedKNI_VerifyArraySetObj(roots[1], length, 2, 0);
        }
        if (length < original) *(int *)JbedKNI_VerifyField(0, xot_length, KNI_FIELD_INT, 0) = length;
    }
    Jbed_nativeCallStateAdr = saved;
}

int SWV_GetArrayBytes(JbRef *root, unsigned element_size, unsigned limit, void **bytes, unsigned *count)
{
    *bytes = NULL;
    if (!*root) return 1;
    JbArray *array = (JbArray *)(uintptr_t)JbedKNI_VerifyObject(*root, 'A');
    unsigned n = array->length;
    *count = n < limit ? n : limit;
    if (!element_size || *count <= UINT_MAX / element_size) {
        unsigned size = *count * element_size;
        *bytes = swvAllocate(size ? size : 1);
        if (*bytes) {
            JbedKNI_VerifyArrayCopy(*root, 0, size, *bytes, 0);
            return 1;
        }
    }
    JbRef message = JbedKNI_NewUtfString("SWV_GetArrayBytes", 0);
    if (JbedKNI_ThrowNew("java/lang/OutOfMemoryError", message) == -1)
        JbedKNI_FatalError("Failed to throw out of memory error");
    return 0;
}
void SWV_FreeArrayBytes(JbRef *root, void *bytes)
{
    (void)root;
    swvFree(bytes);
}
void SWV_SetArrayBytes(JbRef *root, unsigned element_size, void *bytes, unsigned count)
{
    JbedKNI_VerifyArrayCopy(*root, 0, element_size * count, bytes, 1);
}
void SWV_RestoreArrayBytes(JbRef *root, unsigned element_size, void *bytes, unsigned count)
{
    SWV_SetArrayBytes(root, element_size, bytes, count);
}

void *SWV_Image2D_createPNG(void)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    root = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    void *image = NULL, *bytes = NULL;
    unsigned n = 0;
    if (SWV_GetArrayBytes(&root, 1, UINT_MAX, &bytes, &n)) {
        unsigned offset = Jbed_ParamPtr[2], length = Jbed_ParamPtr[3];
        if (!bytes || offset > n || length > n - offset || length > INT_MAX ||
            !swvPNGLoadBuffer(length, (uint8_t *)bytes + offset, &image)) {
            int code;
            engine_getLastError(&code);
            throw_error(code ? code : 12);
        }
    }
    SWV_FreeArrayBytes(&root, bytes);
    Jbed_nativeCallStateAdr = saved;
    return image;
}
