#include "cssobjectfactory.hpp"
#include "object_classes.hpp"

int keyframesequence_create(int frames, int components, int interpolation, void **result)
{
    SWV_BEGIN_API(frame);
    if (frames <= 0 || components <= 0 || interpolation < CssKeyframeSequence::Linear || interpolation > CssKeyframeSequence::Step)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    auto *sequence = static_cast<CssKeyframeSequence *>(CssObjectFactory::CreateObject(KeyframeSequenceObject));
    CssHeapPtr<CssKeyframeSequence> owner(sequence);
    sequence->Construct(frames, components, static_cast<CssKeyframeSequence::EssInterpolation>(interpolation));
    *result = reference_handle(owner.release());
    CssTrapHandler::UnTrap();
    return 1;
}

void keyframesequence_getDuration(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDuration();
}

void keyframesequence_getRepeatMode(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetRepeatMode();
}

void keyframesequence_getValidRangeFirst(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetValidRangeFirst();
}

void keyframesequence_getValidRangeLast(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetValidRangeLast();
}

void keyframesequence_getKeyframeCount(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetcKeyframes();
}

void keyframesequence_getComponentCount(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetcComponents();
}

void keyframesequence_getInterpolationType(void *handle, int *result)
{
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *result = object->GetInterpolationType();
}

int keyframesequence_setDuration(void *handle, int duration)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    if (duration <= 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetDuration(duration);
    CssTrapHandler::UnTrap();
    return 1;
}

int keyframesequence_setRepeatMode(void *handle, int repeat)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    if (repeat != CssKeyframeSequence::Constant && repeat != CssKeyframeSequence::Loop)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetRepeatMode(static_cast<CssKeyframeSequence::EssRepeatMode>(repeat));
    CssTrapHandler::UnTrap();
    return 1;
}

int keyframesequence_setValidRange(void *handle, int first, int last)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    object->SetValidRange(first, last);
    CssTrapHandler::UnTrap();
    return 1;
}

int keyframesequence_getKeyframe(void *handle, int index, int length, float *value, int *time)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    *time = object->GetKeyframe(index, length, value);
    CssTrapHandler::UnTrap();
    return 1;
}

int keyframesequence_setKeyframe(void *handle, int index, int time, int length, const float *value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(handle));
    if (time < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!value)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object->SetKeyframe(index, time, length, value);
    CssTrapHandler::UnTrap();
    return 1;
}
