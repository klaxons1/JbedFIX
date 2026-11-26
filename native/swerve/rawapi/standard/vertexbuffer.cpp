#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"
#include "engine.h"

int vertexbuffer_create(void **out)
{
    SWV_BEGIN_API(frame);
    *out = handle_for(CssObjectFactory::CreateObject(VertexBufferObject));
    CssTrapHandler::UnTrap();
    return 1;
}
void vertexbuffer_getVertexCount(void *h, int *out) { *out = lookup<CssVertexBuffer>(h)->GetVertexCount(); }
void vertexbuffer_getDefaultColor(void *h, int *out) { *out = (int)lookup<CssVertexBuffer>(h)->GetDefaultColor(); }
void vertexbuffer_setDefaultColor(void *h, int value) { lookup<CssVertexBuffer>(h)->SetDefaultColor(value); }
void vertexbuffer_getNormals(void *h, void **out) { *out = handle_for(lookup<CssVertexBuffer>(h)->normals); }
void vertexbuffer_getColors(void *h, void **out) { *out = handle_for(lookup<CssVertexBuffer>(h)->GetColors()); }
int vertexbuffer_setNormals(void *h, void *array)
{
    SWV_BEGIN_API(frame);
    lookup<CssVertexBuffer>(h)->SetNormals(lookup<CssVertexArray>(array));
    CssTrapHandler::UnTrap();
    return 1;
}
int vertexbuffer_setColors(void *h, void *array)
{
    SWV_BEGIN_API(frame);
    lookup<CssVertexBuffer>(h)->SetColors(lookup<CssVertexArray>(array));
    CssTrapHandler::UnTrap();
    return 1;
}
int vertexbuffer_getPositions(void *h, int n, float *scale_bias, void **out)
{
    SWV_BEGIN_API(frame);
    *out = handle_for(lookup<CssVertexBuffer>(h)->GetPositions(n, scale_bias));
    CssTrapHandler::UnTrap();
    return 1;
}
int vertexbuffer_getTexCoords(void *h, int unit, int n, float *scale_bias, void **out)
{
    SWV_BEGIN_API(frame);
    *out = handle_for(lookup<CssVertexBuffer>(h)->GetTexCoords(unit, n, scale_bias));
    CssTrapHandler::UnTrap();
    return 1;
}
int vertexbuffer_setPositions(void *h, void *array, float scale, int n, const float *bias)
{
    SWV_BEGIN_API(frame);
    lookup<CssVertexBuffer>(h)->SetPositions(lookup<CssVertexArray>(array), g_ValidateFloat(scale), n, bias);
    CssTrapHandler::UnTrap();
    return 1;
}
int vertexbuffer_setTexCoords(void *h, int unit, void *array, float scale, int n, const float *bias)
{
    SWV_BEGIN_API(frame);
    lookup<CssVertexBuffer>(h)->SetTexCoords(unit, lookup<CssVertexArray>(array), g_ValidateFloat(scale), n, bias);
    CssTrapHandler::UnTrap();
    return 1;
}
