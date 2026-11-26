#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(World_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(World_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(world_create);
}

uint32_t M3G_ENTRY(World_getActiveCameraImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(world_getActiveCamera, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(World_getBackgroundImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(world_getBackground, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(World_setActiveCameraImpl)(void)
{
    SWV_UnSafeSetter_Handle(world_setActiveCamera, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(World_setBackgroundImpl)(void)
{
    SWV_Setter_Handle(world_setBackground, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}
