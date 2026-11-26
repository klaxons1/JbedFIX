#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"

int morphingmesh_createMultiSubmesh(void *v, int nt, void *const *t, int ni, void *const *ib, int na, void *const *a, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ib || !t) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssMorphingMesh *>(CssObjectFactory::CreateObject(MorphingMeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), nt, reinterpret_cast<CssRefCount *const *>(t), ni, reinterpret_cast<CssRefCount *const *>(ib), na, reinterpret_cast<CssRefCount *const *>(a));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}
int morphingmesh_createSingleSubmesh(void *v, int nt, void *const *t, void *ix, void *ap, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ix || !t) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssMorphingMesh *>(CssObjectFactory::CreateObject(MorphingMeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), nt, reinterpret_cast<CssRefCount *const *>(t), lookup<CssIndexBuffer>(ix), lookup<CssAppearance>(ap));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}

void morphingmesh_getMorphTargetCount(void *h, int *out) { *out = lookup<CssMorphingMesh>(h)->targets.size; }
int morphingmesh_getMorphTarget(void *h, int i, void **out)
{
    SWV_BEGIN_API(frame);
    CssMorphingMesh *m = lookup<CssMorphingMesh>(h);
    check_index(i, m->targets.size);
    *out = handle_for(m->targets[i]);
    CssTrapHandler::UnTrap();
    return 1;
}
int morphingmesh_getWeights(void *h, int n, float *out)
{
    SWV_BEGIN_API(frame);
    CssMorphingMesh *m = lookup<CssMorphingMesh>(h);
    if (!out) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    m->GetWeights(n, out);
    CssTrapHandler::UnTrap();
    return 1;
}
int morphingmesh_setWeights(void *h, int n, const float *in)
{
    SWV_BEGIN_API(frame);
    CssMorphingMesh *m = lookup<CssMorphingMesh>(h);
    if (!in) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    m->SetWeights(n, in);
    CssTrapHandler::UnTrap();
    return 1;
}
