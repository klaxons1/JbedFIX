#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "cssfixed1616.hpp"
#include <climits>
#include <cfloat>
#include <cmath>

int CssAnimationTrack::GetValidPropertyComponents(EssTargetProperty target) const
{
    enum ComponentMask {
        Scalar = 1 << 1, Vector2 = 1 << 2, Vector3 = 1 << 3, Vector4 = 1 << 4
    };
    const int masks[] = {
        0, Scalar, Vector3, Vector3, Vector2 | Vector4, Scalar, Vector3,
        Vector3, Scalar, Scalar, Scalar, AnyComponentCount, Scalar, Vector4,
        Scalar, Scalar | Vector3, Scalar, Vector3, Scalar, Scalar, Vector3, Scalar
    };
    return masks[target - None];
}

// Component counts 256 apart select the same mask bit in this build.
static unsigned component_bit(int components)
{
    const unsigned shift = static_cast<uint8_t>(components);
    return shift < 32 ? 1u << shift : 0;
}

void CssAnimationTrack::Construct(CssKeyframeSequence *keys, int target)
{
    sequence = static_cast<CssKeyframeSequence *>(CssRefCount::Assign(sequence, keys));
    property = static_cast<EssTargetProperty>(target);
    const int mask = GetValidPropertyComponents(property);
    if (mask != AnyComponentCount && !(mask & component_bit(keys->GetcComponents())))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}

void CssAnimationTrack::SetController(CssAnimationController *value)
{
    controller = static_cast<CssAnimationController *>(CssRefCount::Assign(controller, value));
}

void CssAnimationTrack::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    sequence = assign_ref(sequence, r.ReadObjectRefTypeChecked(KeyframeSequenceObject));
    if (!sequence) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    controller = assign_ref(controller, r.ReadObjectRefTypeChecked(AnimationControllerObject));
    property = static_cast<EssTargetProperty>(r.ReadUInt());
    if (property < Alpha || property > Visibility)
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    const int mask = GetValidPropertyComponents(property);
    if (mask != AnyComponentCount && !(mask & component_bit(sequence->GetcComponents())))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
}

IssSerializable *CssAnimationTrack::FactoryCreate()
{
    return new CssAnimationTrack;
}

void CssAnimationTrack::CloneHelper(const CssAnimationTrack &source)
{
    CssObject3D::CloneHelper(source);
    sequence = assign_ref(sequence, source.sequence);
    controller = assign_ref(controller, source.controller);
    property = source.property;
}

CssObject3D *CssAnimationTrack::Clone() const
{
    CssHeapPtr<CssAnimationTrack> copy(static_cast<CssAnimationTrack *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void *CssAnimationTrack::GetpRef(int index)
{
    void *refs[] = {sequence, controller};
    return index < 2 ? refs[index] : CssObject3D::GetpRef(index - 2);
}

CssAnimationTrack::~CssAnimationTrack()
{
    if (sequence) sequence->Release();
    if (controller) controller->Release();
}

int CssAnimationTrack::GetValueForTime(int time, int capacity, float *sum, float weight) const
{
    if (!controller->IsActive(time)) return INT_MAX;
    float duration = sequence->GetWeightedValue(time, this, capacity, sum, weight);
    if (duration == FLT_MAX) return INT_MAX;
    const float speed = controller->GetSpeed();
    if (speed != 1.0f) duration /= speed;
    return saturatingTruncate(duration);
}

int real_roundnearestclamp(float value, int minimum, int maximum)
{
    int rounded;
    if (std::isnan(value))
        rounded = std::signbit(value) ? INT32_MIN : INT32_MAX;
    else
        rounded = saturatingTruncate(value + std::copysign(0.5f, value));
    return rounded <= minimum ? minimum : rounded >= maximum ? maximum : rounded;
}
