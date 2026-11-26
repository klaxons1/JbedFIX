#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"

int mesh_createMultiSubmesh(void *v, int ni, void *const *ib, int na, void *const *a, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ib) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssMesh *>(CssObjectFactory::CreateObject(MeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), ni, reinterpret_cast<CssRefCount *const *>(ib), na, reinterpret_cast<CssRefCount *const *>(a));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}
int mesh_createSingleSubmesh(void *v, void *ix, void *ap, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ix) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssMesh *>(CssObjectFactory::CreateObject(MeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), lookup<CssIndexBuffer>(ix), lookup<CssAppearance>(ap));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}

void mesh_getSubmeshCount(void *h, int *out) { *out = lookup<CssMesh>(h)->GetIndexBufferCount(); }
void mesh_getVertexBuffer(void *h, void **out) { *out = handle_for(lookup<CssMesh>(h)->GetVertexBuffer()); }

int mesh_getIndexBuffer(void *h, int index, void **out)
{
    SWV_BEGIN_API(frame);
    CssMesh *m = lookup<CssMesh>(h);
    *out = handle_for(m->GetIndexBuffer(index));
    CssTrapHandler::UnTrap();
    return 1;
}
int mesh_getAppearance(void *h, int index, void **out)
{
    SWV_BEGIN_API(frame);
    CssMesh *m = lookup<CssMesh>(h);
    *out = handle_for(m->GetAppearance(index));
    CssTrapHandler::UnTrap();
    return 1;
}
int mesh_setAppearance(void *h, int index, void *appearance)
{
    SWV_BEGIN_API(frame);
    CssMesh *m = lookup<CssMesh>(h);
    m->SetAppearance(index, lookup<CssAppearance>(appearance));
    CssTrapHandler::UnTrap();
    return 1;
}
