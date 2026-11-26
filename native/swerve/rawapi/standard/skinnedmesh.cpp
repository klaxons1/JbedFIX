#include "cssobjectfactory.hpp"
#include "geometry_internal.hpp"

int skinnedmesh_createMultiSubmesh(void *v, int ni, void *const *ib, int na, void *const *a, void *sk, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ib) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssSkinnedMesh *>(CssObjectFactory::CreateObject(SkinnedMeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), ni, reinterpret_cast<CssRefCount *const *>(ib), na, reinterpret_cast<CssRefCount *const *>(a), lookup<CssGroup>(sk));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}
int skinnedmesh_createSingleSubmesh(void *v, void *ix, void *ap, void *sk, void **out)
{
    SWV_BEGIN_API(frame);
    if (!v || !ix) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *mesh = static_cast<CssSkinnedMesh *>(CssObjectFactory::CreateObject(SkinnedMeshObject));
    CssCleanupStackManager::Push(mesh);
    mesh->Construct(lookup<CssVertexBuffer>(v), lookup<CssIndexBuffer>(ix), lookup<CssAppearance>(ap), lookup<CssGroup>(sk));
    CssCleanupStackManager::Pop(mesh);
    *out = handle_for(mesh);
    CssTrapHandler::UnTrap();
    return 1;
}

void skinnedmesh_getSkeleton(void *h, void **out) { *out = handle_for(lookup<CssSkinnedMesh>(h)->GetSkeleton()); }
int skinnedmesh_addTransform(void *h, void *bone, int weight, int first, int count)
{
    SWV_BEGIN_API(frame);
    lookup<CssSkinnedMesh>(h)->AddTransform(lookup<CssNode>(bone), weight, first, count);
    CssTrapHandler::UnTrap();
    return 1;
}
int skinnedmesh_getBoneTransform(void *h, void *bone, void *transform)
{
    SWV_BEGIN_API(frame);
    lookup<CssSkinnedMesh>(h)->GetBoneTransform(lookup<CssNode>(bone), lookup<CssTransform>(transform));
    CssTrapHandler::UnTrap();
    return 1;
}

int skinnedmesh_getBoneVertices(void *h, void *bone, int nidx, SwvVertexIndex *indices, int nw, float *weights, int *out)
{
    SWV_BEGIN_API(frame);
    *out = lookup<CssSkinnedMesh>(h)->GetBoneVertices(lookup<CssNode>(bone), nidx, indices, nw, weights);
    CssTrapHandler::UnTrap();
    return 1;
}
