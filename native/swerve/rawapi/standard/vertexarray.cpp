#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"

int vertexarray_create(int count, int components, int width, void **out)
{
    SWV_BEGIN_API(frame);
    if (count < 1 || count > 65535 || components < 2 || components > 4 || width < 1 || width > 2)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    CssVertexArray *a = static_cast<CssVertexArray *>(CssObjectFactory::CreateObject(VertexArrayObject));
    CssCleanupStackManager::Push(a);
    a->Construct(count, components, width);
    CssCleanupStackManager::Pop(a);
    *out = handle_for(a);
    CssTrapHandler::UnTrap();
    return 1;
}
void vertexarray_getVertexCount(void *h, int *out) { *out = lookup<CssVertexArray>(h)->cEntries(); }
void vertexarray_getComponentCount(void *h, int *out) { *out = lookup<CssVertexArray>(h)->cComponents(); }
void vertexarray_getComponentType(void *h, int *out) { *out = lookup<CssVertexArray>(h)->width; }


int vertexarray_get8(void *handle, int first, int count, int capacity, int8_t *dest)
{
    SWV_BEGIN_API(frame);
    if (count < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!dest) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    lookup<CssVertexArray>(handle)->Get8(first, count, capacity, dest);
    CssTrapHandler::UnTrap();
    return 1;
}

int vertexarray_set8(void *handle, int first, int count, int capacity, const int8_t *source)
{
    SWV_BEGIN_API(frame);
    if (count < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!source) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    lookup<CssVertexArray>(handle)->Set8(first, count, capacity, source);
    CssTrapHandler::UnTrap();
    return 1;
}

int vertexarray_get16(void *handle, int first, int count, int capacity, int16_t *dest)
{
    SWV_BEGIN_API(frame);
    if (count < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!dest) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    lookup<CssVertexArray>(handle)->Get16(first, count, capacity, dest);
    CssTrapHandler::UnTrap();
    return 1;
}

int vertexarray_set16(void *handle, int first, int count, int capacity, const int16_t *source)
{
    SWV_BEGIN_API(frame);
    if (count < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!source) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    lookup<CssVertexArray>(handle)->Set16(first, count, capacity, source);
    CssTrapHandler::UnTrap();
    return 1;
}
