#include "object_classes.hpp"


int world_create(void **result)
{
    return create_object(WorldObject, result);
}

void world_getActiveCamera(void *handle, void **result)
{
    auto *object = static_cast<CssWorld *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetpActiveCamera());
}

void world_getBackground(void *handle, void **result)
{
    auto *object = static_cast<CssWorld *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetpBackground());
}

void world_setBackground(void *handle, void *value)
{
    auto *object = static_cast<CssWorld *>(static_cast<CssRefCount *>(handle));
    object->SetpBackground(static_cast<CssBackground *>(static_cast<CssRefCount *>(value)));
}

int world_setActiveCamera(void *handle, void *camera)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssWorld *>(static_cast<CssRefCount *>(handle));
    if (!camera)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object->SetpActiveCamera(static_cast<CssCamera *>(static_cast<CssRefCount *>(camera)));
    CssTrapHandler::UnTrap();
    return 1;
}
