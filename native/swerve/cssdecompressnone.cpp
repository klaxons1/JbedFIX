#include "cssserializein.hpp"

CssDecompressNone *CssDecompressNone::Create(CssSerializeIn *loader)
{
    auto *stream = new CssDecompressNone;
    CssCleanupStackManager::Push(stream);
    stream->Construct(loader);
    CssCleanupStackManager::Pop(stream);
    return stream;
}

bool CssDecompressNone::Decompress(const void *data, unsigned count)
{
    return owner->OnDecompressedData(static_cast<const uint8_t *>(data), count);
}
