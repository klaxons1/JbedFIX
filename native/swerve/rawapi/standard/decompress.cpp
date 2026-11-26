#include "cssserializein.hpp"

extern "C" int decompress_AcceptBytes(void *base, int count, const uint8_t *bytes)
{
    SWV_BEGIN_API(frame);
    int ok = static_cast<CssSerializeIn *>(base)->OnDecompressedData(bytes, count);
    CssTrapHandler::UnTrap();
    return ok != 0;
}
