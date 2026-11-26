#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssWorld::SetpActiveCamera(CssCamera *value)
{
    camera = static_cast<CssCamera *>(CssRefCount::Assign(camera, value));
}

void CssWorld::SetpBackground(CssBackground *value)
{
    background = static_cast<CssBackground *>(CssRefCount::Assign(background, value));
}

void CssWorld::SetLightsCacheDirty(const CssNode *node)
{
    while (node->pParent())
        node = node->pParent();
    if (node->Type() == WorldObject)
        static_cast<const CssWorld *>(node)->lights.SetSize(0);
}

const CssArray<const CssLight *> &CssWorld::GetapLights() const
{
    if (!lights.Size())
        RecacheLightsRecursive(this);
    return lights;
}

void CssWorld::RecacheLightsRecursive(const CssNode *node) const
{
    if (!node || !node->GetRenderingEnabled())
        return;
    if (node->Type() == LightObject)
        lights.Append(static_cast<const CssLight *>(node));
    for (const CssNode *child = node->pFirstChild(); child; child = child->pNextSibling())
        RecacheLightsRecursive(child);
}

void CssWorld::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssGroup::SerializeIn(r);
    camera = static_cast<CssCamera *>(CssRefCount::Assign(camera, r.ReadObjectRefTypeChecked(CameraObject)));
    background = static_cast<CssBackground *>(CssRefCount::Assign(background, r.ReadObjectRefTypeChecked(BackgroundObject)));
    UpdateTreeDepth(-1);
}

IssSerializable *CssWorld::FactoryCreate()
{
    return new CssWorld;
}

void CssWorld::CloneHelper(const CssWorld &source)
{
    CssGroup::CloneHelper(source);
    if (source.camera)
        SetpActiveCamera(static_cast<CssCamera *>(FindCorresponding(source.camera, &source, this)));
    background = static_cast<CssBackground *>(CssRefCount::Assign(background, source.background));
}

CssObject3D *CssWorld::Clone() const
{
    CssHeapPtr<CssWorld> copy(static_cast<CssWorld *>(FactoryCreate()));
    copy->CloneHelper(*this);
    copy->FixupAlignmentReferences(this, this, copy.get());
    return copy.release();
}

void *CssWorld::GetpRef(int index)
{
    void *refs[] = {camera, background};
    return index < 2 ? refs[index] : CssGroup::GetpRef(index - 2);
}

bool CssWorld::HasAnimatableProperty(int property) const
{
    return CssNode::HasAnimatableProperty(property);
}

void CssWorld::SetProperty(int property, int count, float *values)
{
    CssNode::SetProperty(property, count, values);
}

int CssWorld::AnimateRefs(int time, int validity, int stamp)
{
    CssObject3D *refs[] = {camera, background};
    for (auto *ref : refs) {
        if (!ref) continue;
        int interval = ref->Animate(time, stamp);
        if (interval < validity) validity = interval;
    }
    return CssGroup::AnimateRefs(time, validity, stamp);
}

CssWorld::~CssWorld()
{
    if (camera) camera->Release();
    if (background) background->Release();
}
