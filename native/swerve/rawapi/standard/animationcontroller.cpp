#include "object_classes.hpp"

void animationcontroller_getPosition(void *handle, int time, float *position)
{
    *position = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle))->GetPosition(time);
}

int animationcontroller_create(void **result)
{
    return create_object(AnimationControllerObject, result);
}

void animationcontroller_getWeight(void *handle, float *result)
{
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    *result = object->GetWeight();
}

int animationcontroller_setWeight(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetWeight(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void animationcontroller_getActiveIntervalStart(void *handle, int *result)
{
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    *result = object->GetActiveIntervalStart();
}

void animationcontroller_getActiveIntervalEnd(void *handle, int *result)
{
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    *result = object->GetActiveIntervalEnd();
}

void animationcontroller_getRefWorldTime(void *handle, int *result)
{
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    *result = object->GetRefWorldTime();
}

void animationcontroller_getSpeed(void *handle, float *result)
{
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    *result = object->GetSpeed();
}

int animationcontroller_setActiveInterval(void *handle, int start, int end)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    object->SetActiveInterval(start, end);
    CssTrapHandler::UnTrap();
    return 1;
}

int animationcontroller_setPosition(void *handle, float position, int world_time)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    object->SetPosition(g_ValidateFloat(position), world_time);
    CssTrapHandler::UnTrap();
    return 1;
}

int animationcontroller_setSpeed(void *handle, float speed, int world_time)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAnimationController *>(static_cast<CssRefCount *>(handle));
    object->SetSpeed(g_ValidateFloat(speed), world_time);
    CssTrapHandler::UnTrap();
    return 1;
}
