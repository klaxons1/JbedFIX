#include "swvloader.h"
#include "platform.h"
#include "engine.h"
#include "loader.h"
#include <limits.h>

struct SwvLoader {
    void *hLoader;
    SwvURIRead fpURIRead;
    SwvURIIsRelative fpURIIsRelative;
    SwvURIResolve fpURIResolve;
    void *hImage2D;
    int bLoaded;
};

int swvLoaderCreate(SwvURIRead fpURIRead, SwvURIIsRelative fpURIIsRelative, SwvURIResolve fpURIResolve, SwvLoader **ppLoader)
{
    *ppLoader = swvAllocate(sizeof **ppLoader);
    if (!*ppLoader) return 0;
    SwvLoader *pLoader = *ppLoader;
    pLoader->bLoaded = 0;
    pLoader->hImage2D = NULL;
    if (loader_create(&pLoader->hLoader)) {
        pLoader->fpURIRead = fpURIRead;
        pLoader->fpURIIsRelative = fpURIIsRelative;
        pLoader->fpURIResolve = fpURIResolve;
        return 1;
    }
    swvFree(pLoader);
    *ppLoader = NULL;
    return 0;
}
void swvLoaderFree(SwvLoader *pLoader)
{
    engine_releaseHandle(pLoader->hLoader);
    if (pLoader->hImage2D) engine_releaseHandle(pLoader->hImage2D);
    swvFree(pLoader);
}
int swvLoaderGetRootCount(SwvLoader *pLoader)
{
    if (pLoader->hImage2D) return 1;
    int cRoots = 0;
    loader_getRootCount(pLoader->hLoader, &cRoots);
    return cRoots;
}
void *swvLoaderGetRoot(SwvLoader *pLoader, int iRoot)
{
    void *hRoot = pLoader->hImage2D;
    if (hRoot) {
        pLoader->hImage2D = NULL;
        pLoader->bLoaded = 0;
    } else {
        loader_getRoot(pLoader->hLoader, iRoot, &hRoot);
    }
    return hRoot;
}
static void *GetFirstRoot(SwvLoader *loader, int bMustBeWorld)
{
    int cRoots = swvLoaderGetRootCount(loader);
    for (int iRoot = 0; iRoot < cRoots; ++iRoot) {
        void *hRoot = swvLoaderGetRoot(loader, iRoot);
        int type;
        engine_getHandleType(hRoot, &type);
        if (!bMustBeWorld || type == EngineNodeType_World) return hRoot;
        engine_releaseHandle(hRoot);
    }
    return NULL;
}
void *swvLoadNamed(SwvURIRead fpURIRead, SwvURIIsRelative fpURIIsRelative, SwvURIResolve fpURIResolve,
                   const uint16_t *URI, int bPermitExtensions, int bMustBeWorld)
{
    SwvLoader *loader;
    int error;
    if (!swvLoaderCreate(fpURIRead, fpURIIsRelative, fpURIResolve, &loader)) return NULL;
    void *hRoot0 = NULL;
    if (swvLoaderLoadNamed(loader, URI, bPermitExtensions, &error) && error == LoaderError_Error_None)
        hRoot0 = GetFirstRoot(loader, bMustBeWorld);
    swvLoaderFree(loader);
    return hRoot0;
}
void *swvLoadBuffer(SwvURIRead fpURIRead, SwvURIIsRelative fpURIIsRelative, SwvURIResolve fpURIResolve,
                    int cBufferBytes, const uint8_t *pBufferBytes, int bPermitExtensions, int bMustBeWorld)
{
    SwvLoader *loader;
    int error;
    if (!swvLoaderCreate(fpURIRead, fpURIIsRelative, fpURIResolve, &loader)) return NULL;
    void *hRoot0 = NULL;
    if (swvLoaderLoadBuffer(loader, cBufferBytes, pBufferBytes, bPermitExtensions, &error) && error == LoaderError_Error_None)
        hRoot0 = GetFirstRoot(loader, bMustBeWorld);
    swvLoaderFree(loader);
    return hRoot0;
}

static uint16_t *swvDecodeUTF8(unsigned UTF8Length, const uint8_t *UTF8)
{
    uint16_t *name = swvAllocate(((size_t)UTF8Length + 1) * sizeof *name);
    if (name) {
        for (unsigned i = 0; i < UTF8Length; ++i)
            name[i] = UTF8[i];
        name[UTF8Length] = 0;
    }
    return name;
}

static int swvLoaderProcessXREFs(SwvLoader *pLoader, const uint16_t *BaseURI)
{
    uint8_t *xrefNameUTF8 = NULL;
    int xrefNameUTF8Length = 0;
    int success = 0;
    for (;;) {
        int len = -1;
        loader_getXREFName(pLoader->hLoader, 0, NULL, &len);
        if (len == -1) {
            success = 1;
            break;
        }
        if (len < 0) break;
        if (!xrefNameUTF8 || len > xrefNameUTF8Length) {
            swvFree(xrefNameUTF8);
            xrefNameUTF8 = swvAllocate(len);
            if (!xrefNameUTF8) break;
            xrefNameUTF8Length = len;
        }
        loader_getXREFName(pLoader->hLoader, len, xrefNameUTF8, &len);
        if (len < 0 || len > xrefNameUTF8Length || (unsigned)len >= UINT_MAX / sizeof(uint16_t)) break;
        uint16_t *xrefName = swvDecodeUTF8(len, xrefNameUTF8);
        if (!xrefName) break;
        if (!pLoader->fpURIIsRelative || !pLoader->fpURIRead) {
            swvFree(xrefName);
            break;
        }
        if (pLoader->fpURIIsRelative(xrefName)) {
            unsigned units = BaseURI && pLoader->fpURIResolve ? pLoader->fpURIResolve(BaseURI, xrefName, NULL) : 0;
            uint16_t *absolute = units && units <= UINT_MAX / sizeof *xrefName ?
                                 swvAllocate(units * sizeof *xrefName) : NULL;
            if (!absolute) {
                swvFree(xrefName);
                break;
            }
            pLoader->fpURIResolve(BaseURI, xrefName, absolute);
            swvFree(xrefName);
            xrefName = absolute;
        }
        int bPermitExtensions = 1;
        loader_getbContainsExtensions(pLoader->hLoader, &bPermitExtensions);
        void *hRoot0 = swvLoadNamed(pLoader->fpURIRead, pLoader->fpURIIsRelative, pLoader->fpURIResolve, xrefName, bPermitExtensions, 0);
        swvFree(xrefName);
        if (!hRoot0) break;
        loader_resolveXREF(pLoader->hLoader, hRoot0);
        engine_releaseHandle(hRoot0);
    }
    swvFree(xrefNameUTF8);
    return success;
}

int swvLoaderLoadNamed(SwvLoader *pLoader, const uint16_t *URI, int bPermitExtensions, int *pError)
{
    int api_success = loader_onDataStart(pLoader->hLoader, bPermitExtensions, pError);
    if (api_success && *pError == LoaderError_Error_None) {
        uint8_t block[1024];
        void *udata = NULL;
        unsigned cBytes = 0;
        int external_failure = 0;
        const uint16_t *open_name = URI;
        while (pLoader->fpURIRead) {
            if (!pLoader->fpURIRead(&udata, open_name, sizeof block, block, &cBytes) || cBytes > sizeof block) {
                external_failure = 1;
                break;
            }
            open_name = NULL;
            if (*pError != LoaderError_Error_None || !cBytes) break;
            api_success = loader_onData(pLoader->hLoader, cBytes, block, 0, cBytes, pError);
            if (api_success && *pError >= 0) {
                int offset = *pError;
                if (!swvLoaderProcessXREFs(pLoader, URI)) {
                    external_failure = 1;
                    break;
                }
                api_success = loader_onData(pLoader->hLoader, cBytes, block, offset, (int)cBytes - offset, pError);
            }
            if (!api_success || *pError != LoaderError_Error_None) break;
        }
        if (pLoader->fpURIRead) pLoader->fpURIRead(&udata, NULL, 0, NULL, &cBytes);
        if (external_failure || !pLoader->fpURIRead) {
            api_success = loader_onError(pLoader->hLoader, LoaderError_Error_Unknown);
            *pError = LoaderError_Error_Unknown;
        } else if (api_success && *pError == LoaderError_Error_None) {
            api_success = loader_onDataEnd(pLoader->hLoader, pError);
        }
    }
    if (!api_success || *pError != LoaderError_Error_None) {
        api_success = swvPNGLoadNamed(pLoader->fpURIRead, URI, &pLoader->hImage2D);
        *pError = api_success && pLoader->hImage2D ? LoaderError_Error_None : LoaderError_Error_Unknown;
    }
    if (api_success && *pError == LoaderError_Error_None) pLoader->bLoaded = 1;
    return api_success;
}

int swvLoaderLoadBuffer(SwvLoader *pLoader, int cBufferBytes, const uint8_t *pBufferBytes, int bPermitExtensions, int *pError)
{
    static const uint16_t empty_base[] = {0};
    int api_success = loader_onDataStart(pLoader->hLoader, bPermitExtensions, pError);
    if (api_success && *pError == LoaderError_Error_None) {
        api_success = loader_onData(pLoader->hLoader, cBufferBytes, pBufferBytes, 0, cBufferBytes, pError);
        if (api_success && *pError >= 0) {
            int offset = *pError;
            if (swvLoaderProcessXREFs(pLoader, empty_base)) {
                /* The buffer path resumes with an empty span at the reported offset. */
                api_success = loader_onData(pLoader->hLoader, 0, pBufferBytes, offset, -offset, pError);
            } else {
                api_success = loader_onError(pLoader->hLoader, LoaderError_Error_Unknown);
                *pError = LoaderError_Error_Unknown;
            }
        }
    }
    if (api_success && (*pError == LoaderError_Error_DataPastEOF || *pError == LoaderError_Error_None)) {
        *pError = LoaderError_Error_None;
        api_success = loader_onDataEnd(pLoader->hLoader, pError);
    }
    if (!api_success || *pError != LoaderError_Error_None) {
        api_success = swvPNGLoadBuffer(cBufferBytes, pBufferBytes, &pLoader->hImage2D);
        if (api_success && pLoader->hImage2D) *pError = LoaderError_Error_None;
    }
    if (api_success && *pError == LoaderError_Error_None) pLoader->bLoaded = 1;
    return api_success;
}
