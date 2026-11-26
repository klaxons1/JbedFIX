#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"

int trianglestriparray_createImplicit(int first, int count, const SwvVertexIndex *lengths, void **out)
{
    SWV_BEGIN_API(frame);
    if (!lengths) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    CssHeapPtr<CssTriangleStripArray> strips(static_cast<CssTriangleStripArray *>(CssObjectFactory::CreateObject(TriangleStripArrayObject)));
    strips->Construct(first, count, lengths);
    *out = handle_for(strips.release());
    CssTrapHandler::UnTrap();
    return 1;
}

int trianglestriparray_createExplicit(int n, const SwvVertexIndex *indices, int count,
                                     const SwvVertexIndex *lengths, void **out)
{
    SWV_BEGIN_API(frame);
    if (!indices || !lengths) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    CssHeapPtr<CssTriangleStripArray> strips(static_cast<CssTriangleStripArray *>(CssObjectFactory::CreateObject(TriangleStripArrayObject)));
    strips->Construct(n, indices, count, lengths);
    *out = handle_for(strips.release());
    CssTrapHandler::UnTrap();
    return 1;
}
