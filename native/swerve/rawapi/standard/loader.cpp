#include "cssserializein.hpp"

int loader_create(void **result)
{
    SWV_BEGIN_API(frame);
    auto *loader = CssSerializeObjectsIn::Create();
    *result = swv_retain_handle(static_cast<CssRefCount *>(loader));
    CssTrapHandler::UnTrap();
    return 1;
}

void loader_getbContainsExtensions(void *pThis, int *result)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->GetbContainsExtensions();
}

int loader_onDataStart(void *pThis, int bPermitExtensions, int *result)
{
    SWV_BEGIN_API(frame);
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->OnDataStart(bPermitExtensions != 0);
    CssTrapHandler::UnTrap();
    return 1;
}

int loader_onData(void *pThis, unsigned dataLength, const uint8_t *data, int offset, int length, int *result)
{
    SWV_BEGIN_API(frame);
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->OnData(dataLength, data, offset, length);
    CssTrapHandler::UnTrap();
    return 1;
}

int loader_onDataEnd(void *pThis, int *result)
{
    SWV_BEGIN_API(frame);
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->OnDataEnd();
    CssTrapHandler::UnTrap();
    return 1;
}

int loader_onError(void *pThis, int error)
{
    SWV_BEGIN_API(frame);
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    loader->OnError(static_cast<CssSerializeIn::EssError>(error));
    CssTrapHandler::UnTrap();
    return 1;
}

void loader_getRootCount(void *pThis, int *result)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->GetcRoots();
}

void loader_getRoot(void *pThis, int index, void **result)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    if ((unsigned)index >= (unsigned)loader->GetcRoots()) {
        *result = NULL;
        return;
    }
    *result = swv_retain_handle(static_cast<CssRefCount *>(loader->GetRoot(index)));
}

void loader_getAuthoringField(void *pThis, unsigned nameLength, uint8_t *name, int *result)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->GetAuthoringField(nameLength, name);
}

void loader_getXREFName(void *pThis, unsigned nameLength, uint8_t *name, int *result)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    *result = loader->GetXREFName(nameLength, name);
}

void loader_resolveXREF(void *pThis, void *object)
{
    auto *loader = static_cast<CssSerializeObjectsIn *>(static_cast<CssRefCount *>(pThis));
    loader->ResolveXREF(static_cast<CssObject3D *>(static_cast<CssRefCount *>(object)));
}
