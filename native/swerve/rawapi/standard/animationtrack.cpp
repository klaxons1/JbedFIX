#include "cssobjectfactory.hpp"
#include "object_classes.hpp"

int animationtrack_create(void *sequence, int property, void **result)
{
    SWV_BEGIN_API(frame);
    if (!sequence)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    if (property < CssAnimationTrack::Alpha || property > CssAnimationTrack::Visibility)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    CssHeapPtr<CssAnimationTrack> track(static_cast<CssAnimationTrack *>(CssObjectFactory::CreateObject(AnimationTrackObject)));
    track->Construct(static_cast<CssKeyframeSequence *>(static_cast<CssRefCount *>(sequence)), property);
    *result = reference_handle(track.release());
    CssTrapHandler::UnTrap();
    return 1;
}

void animationtrack_getController(void *handle, void **result)
{
    auto *object = static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetController());
}

void animationtrack_setController(void *handle, void *value)
{
    auto *object = static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(handle));
    object->SetController(static_cast<CssAnimationController *>(static_cast<CssRefCount *>(value)));
}

void animationtrack_getKeyframeSequence(void *handle, void **result)
{
    auto *object = static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetKeyframeSequence());
}

void animationtrack_getTargetProperty(void *handle, int *result)
{
    auto *object = static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(handle));
    *result = object->GetTargetProperty();
}
