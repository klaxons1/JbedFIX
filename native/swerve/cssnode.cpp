#include "cssaligntargetmanager.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "objects.h"
#include "object_class.hpp"
#include "object_classes.hpp"
#include "engine.h"
#include "platform.h"
#include <string.h>
#include <cmath>

CssNode *CssNode::GetAlignmentReferenceUnsafe(EssOrientationReference axis) const
{
    if (!alignment) return nullptr;
    if (axis == YAxis) return alignment->y_reference;
    if (axis == ZAxis) return alignment->z_reference;
    return nullptr;
}

CssNode *CssNode::GetAlignmentReference(EssOrientationReference axis) const
{
    if (axis != YAxis && axis != ZAxis) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    return GetAlignmentReferenceUnsafe(axis);
}

CssNode::EssOrientationReference CssNode::GetAlignmentTarget(EssOrientationReference axis) const
{
    if (axis != YAxis && axis != ZAxis) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!alignment) return None;
    return axis == YAxis ? alignment->y_target : alignment->z_target;
}

void CssNode::NullReferencesOf(const CssNode *target)
{
    if (!alignment) return;
    if (alignment->z_reference == target)
        alignment->z_reference = reinterpret_cast<CssNode *>(-1);
    if (alignment->y_reference == target)
        alignment->y_reference = reinterpret_cast<CssNode *>(-1);
}

void CssNode::SetAlignment(CssNode *z_node, EssOrientationReference z_target,
                           CssNode *y_node, EssOrientationReference y_target)
{
    if (z_node == this || y_node == this || (z_node == y_node && z_target != None && z_target == y_target))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (alignment) {
        CssAlignTargetManager::RemoveAlignedNode(this);
        swvFree(alignment);
        alignment = nullptr;
    }
    if (z_node || z_target != None || y_node || y_target != None) {
        alignment = new (ELeave) Alignment{z_target, y_target, z_node, y_node};
        CssAlignTargetManager::RegisterAlignedNode(this);
    }
}

CssNode::CssNode() = default;
void CssNode::SetScope(int new_scope) { scope = new_scope; }
int CssNode::GetPosScaleBias(float *, CssVector3D *) const { return 0; }

bool CssNode::HaveCommonAncestor(const CssNode *a, const CssNode *b)
{
    if (!a || !b) return false;
    while (a->pParent()) a = a->pParent();
    while (b->pParent()) b = b->pParent();
    return a == b;
}

void CssNode::UpdateTreeDepth(int parent_depth)
{
    depth = parent_depth < 255 ? parent_depth + 1 : 255;
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling())
        child->UpdateTreeDepth(depth);
}

void CssNode::SetWorldMatrixCache(const CssMatrix &matrix) const
{
    SetWorldMatrixCacheDirty();
    world_transform = matrix;
    world_matrix_scale = world_transform.GetMaxScale();
    flags &= ~WorldMatrixDirty;
}

void CssNode::SetWorldMatrixCacheDirty() const
{
    flags |= WorldMatrixDirty;
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling())
        child->SetWorldMatrixCacheDirty();
}

void CssNode::UnLink()
{
    if (!pParent()) return;
    CssWorld::SetLightsCacheDirty(this);
    CssNode *previous = pParent()->pFirstChild();
    if (previous == this) {
        pParent()->first_child = next_sibling;
    } else {
        while (previous->pNextSibling() && previous->pNextSibling() != this)
            previous = previous->pNextSibling();
        previous->next_sibling = next_sibling;
    }
    next_sibling = nullptr;
    parent = nullptr;
    SetWorldMatrixCacheDirty();
    UpdateTreeDepth(-1);
    Release();
}

void CssNode::LinkAfter(CssNode *sibling)
{
    AddRef();
    UnLink();
    if (sibling->next_sibling)
        next_sibling = sibling->next_sibling;
    sibling->next_sibling = this;
    parent = sibling->parent;
    UpdateTreeDepth(parent->GetTreeDepth());
    SetWorldMatrixCacheDirty();
    CssWorld::SetLightsCacheDirty(this);
}

void CssNode::LinkAsFirstChildOf(CssNode *node)
{
    AddRef();
    UnLink();
    if (node->pFirstChild())
        next_sibling = node->pFirstChild();
    node->first_child = this;
    parent = node;
    UpdateTreeDepth(node->GetTreeDepth());
    SetWorldMatrixCacheDirty();
    CssWorld::SetLightsCacheDirty(this);
}

CssNode::~CssNode()
{
    if (alignment) CssAlignTargetManager::RemoveAlignedNode(this);
    CssAlignTargetManager::RemoveTargetNode(this);
    swvFree(alignment);
    while (pFirstChild())
        pFirstChild()->UnLink();
}

void CssNode::CloneHelper(const CssNode &source)
{
    CssTransformable::CloneHelper(source);
    flags = (source.flags & (RenderingEnabled | PickingEnabled)) | WorldMatrixDirty;
    alpha = source.alpha;
    scope = source.scope;
    SetAlignment(source.GetAlignmentReferenceUnsafe(ZAxis), source.GetAlignmentTarget(ZAxis),
                 source.GetAlignmentReferenceUnsafe(YAxis), source.GetAlignmentTarget(YAxis));
    parent = next_sibling = nullptr;
    if (CssNode *child = source.pFirstChild()) {
        CssHeapPtr<CssNode> first(static_cast<CssNode *>(child->Clone()));
        CssNode *previous = first.get();
        previous->parent = this;
        for (child = child->pNextSibling(); child; child = child->pNextSibling()) {
            CssHeapPtr<CssNode> copy(static_cast<CssNode *>(child->Clone()));
            copy->LinkAfter(previous);
            previous = copy.release();
        }
        first_child = static_cast<CssNode *>(CssRefCount::Assign(first_child, first.release()));
    }
}

void CssNode::SetMatrixCacheDirty() const
{
    CssTransformable::SetMatrixCacheDirty();
    if (!(flags & WorldMatrixDirty))
        SetWorldMatrixCacheDirty();
}

void CssNode::SetRenderingEnabled(bool enabled)
{
    if ((flags & RenderingEnabled) != enabled) {
        flags = (flags & ~RenderingEnabled) | (enabled ? RenderingEnabled : 0);
        SetMatrixCacheDirty();
        CssWorld::SetLightsCacheDirty(this);
    }
}

void CssNode::SetPickingEnabled(bool enabled)
{
    if (GetPickingEnabled() != enabled) {
        flags = (flags & ~PickingEnabled) | (enabled ? PickingEnabled : 0);
        SetMatrixCacheDirty();
    }
}

void CssNode::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssTransformable::SerializeIn(reader);
    if (!(state->general->flags & MatrixAffineFlag))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    SetRenderingEnabled(reader.ReadBool());
    SetPickingEnabled(reader.ReadBool());
    alpha = reader.ReadByte() * (1.0f / 255.0f);
    scope = reader.ReadInt();
    if (reader.ReadBool()) {
        int z_target = reader.ReadEnum(None - 1, ZAxis + 1);
        int y_target = reader.ReadEnum(None - 1, ZAxis + 1);
        CssNode *z_ref = reader.ReadObjectRefNode(true);
        CssNode *y_ref = reader.ReadObjectRefNode(true);
        SetAlignment(z_ref, static_cast<EssOrientationReference>(z_target),
                     y_ref, static_cast<EssOrientationReference>(y_target));
    }
}

bool CssNode::HasAnimatableProperty(int property) const
{
    return property == CssAnimationTrack::Alpha || property == CssAnimationTrack::Pickability ||
           property == CssAnimationTrack::Visibility || CssTransformable::HasAnimatableProperty(property);
}

void CssNode::SetProperty(int property, int components, float *value)
{
    if (property == CssAnimationTrack::Alpha) {
        alpha = value[0] < 0 ? 0 : value[0] > 1 ? 1 : value[0];
    } else if (property == CssAnimationTrack::Pickability) {
        SetPickingEnabled(value[0] >= 0.5f);
    } else if (property == CssAnimationTrack::Visibility) {
        SetRenderingEnabled(value[0] >= 0.5f);
    } else {
        CssTransformable::SetProperty(property, components, value);
    }
}

CssNode *CssNode::FindCorresponding(const CssNode *wanted, const CssNode *source, const CssNode *copy)
{
    if (wanted == source) return const_cast<CssNode *>(copy);
    CssNode *copy_child = copy->pFirstChild();
    for (CssNode *child = source->pFirstChild(); child; child = child->pNextSibling()) {
        if (CssNode *found = FindCorresponding(wanted, child, copy_child)) return found;
        copy_child = copy_child->pNextSibling();
    }
    return nullptr;
}

void CssNode::FixupAlignmentReferences(const CssNode *source, const CssNode *source_root, const CssNode *copy_root)
{
    const CssNode *invalid = reinterpret_cast<CssNode *>(-1);
    CssNode *z = source->GetAlignmentReferenceUnsafe(ZAxis);
    CssNode *y = source->GetAlignmentReferenceUnsafe(YAxis);
    if ((z && z != invalid) || (y && y != invalid)) {
        CssNode *copy_z = GetAlignmentReferenceUnsafe(ZAxis);
        CssNode *copy_y = GetAlignmentReferenceUnsafe(YAxis);
        if (z && z != invalid && z->IsDescendantOf(source_root))
            copy_z = FindCorresponding(z, source_root, copy_root);
        if (y && y != invalid && y->IsDescendantOf(source_root))
            copy_y = FindCorresponding(y, source_root, copy_root);
        SetAlignment(copy_z, source->GetAlignmentTarget(ZAxis), copy_y, source->GetAlignmentTarget(YAxis));
    }
    CssNode *copy_child = pFirstChild();
    for (CssNode *child = source->pFirstChild(); child; child = child->pNextSibling()) {
        copy_child->FixupAlignmentReferences(child, source_root, copy_root);
        copy_child = copy_child->pNextSibling();
    }
}

CssVector3D CssNode::GetAxis(const CssMatrix &matrix, EssOrientationReference axis) const
{
    if (axis < Origin || axis > ZAxis) return {};
    int column = axis == Origin ? 3 : axis - XAxis;
    const float *v = matrix.m + 4 * column;
    return {v[0], v[1], v[2]};
}

void CssNode::DoAlignment(const CssNode *reference)
{
    EssOrientationReference z_target = GetAlignmentTarget(ZAxis);
    EssOrientationReference y_target = GetAlignmentTarget(YAxis);
    const CssVector3D &translation = state->translation;
    CssMatrix offset(CssVector3D{-translation.x, -translation.y, -translation.z});
    auto referenceFor = [&](EssOrientationReference axis) {
        const CssNode *ref = GetAlignmentReferenceUnsafe(axis);
        if (ref == reinterpret_cast<const CssNode *>(-1)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        return ref ? ref : reference;
    };
    auto matrixFor = [&](const CssNode *ref) {
        CssMatrix matrix(MatrixIdentity);
        const CssNode *ancestor = BuildTransformMatrix(ref, pParent(), &matrix);
        if (!ancestor || ref == this || (ancestor == pParent() && IsAncestorOf(ref)))
            g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        matrix.PreMultiply(offset);
        return matrix;
    };

    CssQuaternion rotation;
    if (z_target != None && y_target != None) {
        const CssNode *z_ref = referenceFor(ZAxis);
        const CssNode *y_ref = referenceFor(YAxis);
        CssMatrix z_matrix = matrixFor(z_ref);
        CssVector3D z = GetAxis(z_matrix, z_target);
        CssVector3D y = GetAxis(y_ref == z_ref ? z_matrix : matrixFor(y_ref), y_target);
        z.Unit();
        y.Unit();
        CssVector3D x = y % z;
        x.Unit();
        y = z % x;
        rotation = CssQuaternion(CssMatrix(x.x, x.y, x.z, 0, y.x, y.y, y.z, 0,
                                           z.x, z.y, z.z, 0, 0, 0, 0, 1));
    } else {
        bool align_z = z_target != None;
        const CssNode *ref = referenceFor(align_z ? ZAxis : YAxis);
        CssVector3D v = GetAxis(matrixFor(ref), align_z ? z_target : y_target);
        float length = std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
        rotation = align_z ? CssQuaternion(length + v.z, -v.y, v.x, 0)
                           : CssQuaternion(length + v.y, v.z, 0, -v.x);
    }
    rotation.Normalize();
    SetOrientation(rotation);
}

void CssNode::AlignRecursively(CssNode *reference)
{
    if (GetAlignmentTarget(ZAxis) != None || GetAlignmentTarget(YAxis) != None)
        DoAlignment(reference);
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling())
        child->AlignRecursively(reference);
}

void CssNode::Align(CssNode *reference)
{
    if (reference && !HaveCommonAncestor(this, reference))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    AlignRecursively(reference ? reference : this);
}

CssMatrix &CssNode::GetMatrixWorld() const
{
    if (flags & WorldMatrixDirty) {
        if (const CssNode *parent = pParent()) {
            world_transform = GetCompositeMatrix();
            world_transform.PreMultiply(parent->GetMatrixWorld());
        } else {
            world_transform.Identity();
        }
        flags &= ~WorldMatrixDirty;
        world_matrix_scale = world_transform.GetMaxScale();
    }
    return world_transform;
}

int CssNode::GetTreeDepth() const
{
    if (depth != 255)
        return depth;
    int n = 0;
    for (auto *node = pParent(); node; node = node->pParent())
        ++n;
    return n;
}

bool CssNode::IsAncestorOf(const CssNode *node) const
{
    return node && node->IsDescendantOf(this);
}

bool CssNode::IsDescendantOf(const CssNode *ancestor) const
{
    for (const CssNode *node = pParent(); node; node = node->pParent())
        if (node == ancestor)
            return true;
    return false;
}

const CssNode *CssNode::BuildTransformMatrix(const CssNode *from, const CssNode *to, CssMatrix *out)
{
    if (!from || !to)
        return nullptr;
    out->Identity();
    if (from == to)
        return from;
    if (to->Type() == WorldObject) {
        *out = from->GetMatrixWorld();
        return to->IsAncestorOf(from) ? to : nullptr;
    }

    int a = from->GetTreeDepth(), b = to->GetTreeDepth();
    const CssNode *left = from, *right = to;
    CssMatrix local;
    local.Identity();
    while (a > b && left != right) {
        local.PreMultiply(left->GetMatrixParent());
        left = left->pParent();
        --a;
    }
    while (b > a && right != from) {
        out->PreMultiply(right->GetMatrixParent());
        right = right->pParent();
        --b;
    }
    while (a > 0 && left != right) {
        local.PreMultiply(left->GetMatrixParent());
        out->PreMultiply(right->GetMatrixParent());
        left = left->pParent();
        right = right->pParent();
        --a;
    }
    if (!out->Invert())
        g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
    *out *= local;
    return left == right ? left : nullptr;
}

bool CssNode::GetTransformTo(const CssNode *target, CssTransform *transform) const
{
    CssMatrix out;
    if (!BuildTransformMatrix(this, target, &out))
        return false;
    transform->matrix = out;
    return true;
}
