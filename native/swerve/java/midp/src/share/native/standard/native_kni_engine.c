#include "kni.h"
#include "kni_targets.h"

uint32_t M3G_ENTRY(Engine_getVersionMajor)(void)
{
    return (uint32_t)SWV_Engine_getVersionMajor();
}

uint32_t M3G_ENTRY(Engine_getVersionMinor)(void)
{
    return (uint32_t)SWV_Engine_getVersionMinor();
}

uint32_t M3G_ENTRY(Engine_getRevisionMajor)(void)
{
    return (uint32_t)SWV_Engine_getRevisionMajor();
}

uint32_t M3G_ENTRY(Engine_getRevisionMinor)(void)
{
    return (uint32_t)SWV_Engine_getRevisionMinor();
}

uint32_t M3G_ENTRY(Engine_getBranchNumber)(void)
{
    return (uint32_t)SWV_Engine_getBranchNumber();
}

void M3G_ENTRY(Engine_releaseHandle)(void)
{
    SWV_Engine_releaseHandle();
}

uint32_t M3G_ENTRY(Engine_getHandleType)(void)
{
    return (uint32_t)SWV_Engine_getHandleType();
}

uint32_t M3G_ENTRY(Engine_getHandleSize)(void)
{
    return (uint32_t)SWV_Engine_getHandleSize();
}

void M3G_ENTRY(Engine_cacheFID)(void)
{
    SWV_Engine_cacheFID();
}

void M3G_ENTRY(Engine_initialize)(void)
{
    SWV_Engine_initialize();
}
