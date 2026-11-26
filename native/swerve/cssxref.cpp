#include "cssserializein.hpp"

CssXREF::~CssXREF()
{
    if (resolved)
        resolved->Release();
}

void CssXREF::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    reader.ReadUTF8String(uri);
}

int CssXREF::GetName(int size, uint8_t *out) const
{
    if (out && size >= uri.size && uri.size > 0)
        std::memcpy(out, uri.data, uri.size);
    return uri.size;
}
