#include "geometry_internal.hpp"

void indexbuffer_getIndexCount(void *handle, int *out)
{
    CssIndexBuffer *s = lookup<CssIndexBuffer>(handle);
    *out = s->GetIndexCount();
}
int indexbuffer_getIndices(void *handle, int capacity, SwvVertexIndex *out)
{
    SWV_BEGIN_API(frame);
    if (!out) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    CssIndexBuffer *s = lookup<CssIndexBuffer>(handle);
    s->GetIndices(capacity, out);
    CssTrapHandler::UnTrap();
    return 1;
}
