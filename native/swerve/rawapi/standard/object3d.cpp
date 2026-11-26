#include "object_classes.hpp"
#include "objects.h"

void object3d_getUserID(void *handle, int *id)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *id = object->GetUserID();
}

void object3d_setUserID(void *handle, int id)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    object->SetUserID(id);
}

void object3d_getUserParameter(void *handle, int id, int length, uint8_t *data, int *result)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *result = object->GetUserParameter(id, length, data);
}

int object3d_setUserParameter(void *handle, int id, int length, const uint8_t *data)
{
    SWV_BEGIN_API(frame);
    static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle))->SetUserParameter(id, length, data);
    CssTrapHandler::UnTrap();
    return 1;
}

void object3d_removeUserParameters(void *handle)
{
    static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle))->RemoveUserParameters();
}

void object3d_getUserParameterID(void *handle, int index, int *result)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *result = object->GetUserParameterID(index);
}

void object3d_getUserParameterValue(void *handle, int index, int length, uint8_t *data, int *result)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *result = object->GetUserParameterValue(index, length, data);
}

void object3d_getAnimationTrackCount(void *handle, int *count)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *count = object->GetAnimationTrackCount();
}

int object3d_getAnimationTrack(void *handle, int index, void **track)
{
    SWV_BEGIN_API(frame);
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *track = swv_retain_handle(static_cast<CssRefCount *>(object->GetAnimationTrack(index)));
    CssTrapHandler::UnTrap();
    return 1;
}

int object3d_addAnimationTrack(void *handle, void *track)
{
    SWV_BEGIN_API(frame);
    if (!track)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    object->AddAnimationTrack(static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(track)));
    CssTrapHandler::UnTrap();
    return 1;
}

void object3d_removeAnimationTrack(void *handle, void *track_handle)
{
    CssObject3D *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    CssAnimationTrack *track = static_cast<CssAnimationTrack *>(static_cast<CssRefCount *>(track_handle));
    object->RemoveAnimationTrack(track);
}

void object3d_find(void *handle, int id, void **result)
{
    auto *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *result = swv_retain_handle(static_cast<CssRefCount *>(object->Find(id)));
}

void object3d_getReferences(void *handle, int length, void **refs, int *result)
{
    auto *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *result = object->GetReferences(length, reinterpret_cast<CssRefCount **>(refs));
    for (int i = 0; i < length; ++i)
        swv_retain_handle(refs[i]);
}

int object3d_duplicate(void *handle, void **copy)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle));
    *copy = swv_retain_handle(static_cast<CssRefCount *>(object->Clone()));
    CssTrapHandler::UnTrap();
    return 1;
}

int object3d_animate(void *handle, int time, int *validity)
{
    SWV_BEGIN_API(frame);
    *validity = static_cast<CssObject3D *>(static_cast<CssRefCount *>(handle))->Animate(time, -1);
    CssTrapHandler::UnTrap();
    return 1;
}
