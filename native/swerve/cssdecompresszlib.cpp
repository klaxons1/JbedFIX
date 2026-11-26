#include "cssserializein.hpp"

CssDecompressZLib *CssDecompressZLib::Create(CssSerializeIn *loader)
{
    auto *stream = new CssDecompressZLib;
    CssCleanupStackManager::Push(stream);
    stream->Construct(loader);
    CssCleanupStackManager::Pop(stream);
    return stream;
}

void CssDecompressZLib::Construct(CssSerializeIn *loader)
{
    CssDecompress::Construct(loader);
    if (!swvDecompressOnDataStart(SWV_ZLIB, loader, &inflater))
        swvDecompressError(&inflater);
}

CssDecompressZLib::~CssDecompressZLib()
{
    if (!swvDecompressOnDataEnd(&inflater))
        swvDecompressError(&inflater);
}

bool CssDecompressZLib::Decompress(const void *data, unsigned count)
{
    swv_record_error(0);
    if (swvDecompressOnData(static_cast<const uint8_t *>(data), count, &inflater))
        return 1;
    swvDecompressError(&inflater);
    int error = swv_raw_error();
    if (error)
        g_ssThrowLeave(error);
    return 0;
}
