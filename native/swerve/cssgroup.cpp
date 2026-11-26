#include "cssserializebufferobjectsin.hpp"
#include "math_pick.h"
#include <cfloat>
#include "object_classes.hpp"

void CssGroup::AddChild(CssNode *node)
{
    if (!node) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    if (node->GetParent() == this) return;
    if (node == this || node->Type() == WorldObject || node->GetParent() || node->IsAncestorOf(this))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (CssNode *last = pFirstChild()) {
        while (last->pNextSibling()) last = last->pNextSibling();
        node->LinkAfter(last);
    } else {
        node->LinkAsFirstChildOf(this);
    }
}

CssNode *CssGroup::GetChildIfExists(int &index)
{
    CssNode *child = pFirstChild();
    while (child && index-- != 0)
        child = child->pNextSibling();
    return child;
}

CssNode *CssGroup::GetChild(int index)
{
    if (index < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    CssNode *child = GetChildIfExists(index);
    if (!child) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return child;
}

int CssGroup::GetChildCount() const
{
    int count = 0;
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling())
        ++count;
    return count;
}

void CssGroup::RemoveChild(CssNode *node)
{
    if (!node) return;
    if (node->GetUnlinkable()) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling()) {
        if (node == child) {
            child->UnLink();
            return;
        }
    }
}

IssSerializable *CssGroup::FactoryCreate()
{
    return new CssGroup;
}

void CssGroup::CloneHelper(const CssGroup &source)
{
    CssNode::CloneHelper(source);
}

CssObject3D *CssGroup::Clone() const
{
    CssHeapPtr<CssGroup> copy(static_cast<CssGroup *>(FactoryCreate()));
    copy->CloneHelper(*this);
    copy->FixupAlignmentReferences(this, this, copy.get());
    return copy.release();
}

void CssGroup::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssNode::SerializeIn(reader);
    int n = reader.ReadCount(4);
    for (int i = 0; i < n; ++i)
        AddChild(reader.ReadObjectRefNode(false));
}

void *CssGroup::GetpRef(int index)
{
    if (CssNode *child = GetChildIfExists(index))
        return child;
    return CssObject3D::GetpRef(index);
}

int CssGroup::AnimateRefs(int time, int validity, int stamp)
{
    for (CssNode *child = pFirstChild(); child; child = child->pNextSibling()) {
        int interval = child->Animate(time, stamp);
        if (interval < validity) validity = interval;
    }
    return CssObject3D::AnimateRefs(time, validity, stamp);
}

static void setup_hit(CssPickData &data, const CssVector3D &origin, const CssVector3D &direction)
{
    data.hit = CssRayIntersection::GetInstance();
    data.hit->SetIntersected(nullptr);
    data.hit->distance = FLT_MAX;
    data.hit->SetRay(origin, direction);
}

static bool finish_hit(CssPickData &data, CssRayIntersection *out)
{
    CssRayIntersection &hit = *data.hit;
    bool found = hit.GetIntersected() != nullptr;
    if (found && out)
        *out = hit;
    hit.SetIntersected(nullptr);
    return found;
}

static bool pick_node(CssPick &picker, const CssNode *group, int scope, const CssVector3D &from,
                      const CssVector3D &delta, CssRayIntersection *out)
{
    if (nearZero(delta[0]) && nearZero(delta[1]) && nearZero(delta[2]))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    CssPickData &data = *CssPickData::GetInstance();
    data.scope = scope;
    data.camera = nullptr;
    data.saved.items.SetSize(0);
    data.ray.start = from;
    data.ray.end = from + delta;
    setup_hit(data, from, delta);
    picker.PickNode(&data, group);
    return finish_hit(data, out);
}

bool CssGroup::Pick(int scope, const CssVector3D &from, const CssVector3D &delta, CssRayIntersection *out)
{
    return pick_node(*this, this, scope, from, delta, out);
}

bool swv_pick_empty_group(int scope, const CssVector3D &from, const CssVector3D &delta, CssRayIntersection *out)
{
    CssPick picker;
    return pick_node(picker, nullptr, scope, from, delta, out);
}

bool CssGroup::Pick(int scope, float x, float y, CssCamera *camera, CssRayIntersection *out)
{
    if (!HaveCommonAncestor(this, camera))
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    CssPickData &data = *CssPickData::GetInstance();
    data.saved.items.SetSize(0);
    data.camera = camera;
    data.scope = scope;
    CssMatrix inverse(camera->GetMatrixSafe());
    if (!inverse.Invert())
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    x = x * 2.0f - 1;
    y = 1 - y * 2.0f;
    data.ray = {{x, y, -1}, {x, y, 1}};
    PushInternalState(&data);
    data.ray.start = inverse.Transform4Dto3D(data.ray.start, 1);
    data.ray.end = inverse.Transform4Dto3D(data.ray.end, 1);
    PushInternalState(&data);
    CssMatrix transform;
    BuildTransformMatrix(camera, this, &transform);
    transform.ResetMatrixType();
    TransformRay(&data, transform);
    CssVector3D direction = data.ray.end - data.ray.start;
    setup_hit(data, data.ray.start, direction);
    PickNode(&data, this);
    PopInternalState(&data);
    PopInternalState(&data);
    return finish_hit(data, out);
}
