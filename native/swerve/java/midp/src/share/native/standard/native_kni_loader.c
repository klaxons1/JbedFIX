#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Loader_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Loader);
}

/* 0x304c50  ()I */
uint32_t M3G_ENTRY(Loader_createImpl)(void)
{
    void *result = NULL;
    if (!loader_create(&result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

/* 0x304bec  ()Z */
uint32_t M3G_ENTRY(Loader_getbContainsExtensions)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    int result = 0;
    loader_getbContainsExtensions(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}

/* 0x304b6c  (Z)I */
uint32_t M3G_ENTRY(Loader_onDataStart)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    int result = 0;
    if (!loader_onDataStart(self, (uint8_t)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x304afc  ()I */
uint32_t M3G_ENTRY(Loader_onDataEnd)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    int result = 0;
    if (!loader_onDataEnd(self, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x304a18  ([BII)I */
uint32_t M3G_ENTRY(Loader_onData)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray bytes = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &bytes.data, &bytes.count);
    if (ready && !loader_onData(self, bytes.count, bytes.data, (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], &result))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], bytes.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x3049a0  (I)V */
void M3G_ENTRY(Loader_onError)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    if (!loader_onError(self, (int)Jbed_ParamPtr[1]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x304940  ()I */
uint32_t M3G_ENTRY(Loader_getRootCount)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    int result = 0;
    loader_getRootCount(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x3048d0  (I)I */
uint32_t M3G_ENTRY(Loader_getRootImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    void *result = NULL;
    loader_getRoot(self, (int)Jbed_ParamPtr[1], &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3047f0  ([B)I */
uint32_t M3G_ENTRY(Loader_getXREFName)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray name = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &name.data, &name.count);
    if (ready) {
        loader_getXREFName(self, name.count, name.data, &result);
        copy_back(&roots[1], 1, &name);
    }
    SWV_FreeArrayBytes(&roots[1], name.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x30475c  (Ljavax/microedition/m3g/Object3D;)V */
void M3G_ENTRY(Loader_resolveXREF)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Loader);
    void *object3D = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    loader_resolveXREF(self, object3D);
    Jbed_nativeCallStateAdr = saved_roots;
}

uint32_t M3G_ENTRY(Loader_getImage2DEncoding)(void)
{
    return (uint32_t)SWV_GetImage2DEncoding();
}
