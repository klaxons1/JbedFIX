#include "cssstatics.hpp"

CssStatics *g_pStaticsNoLeave()
{
    return static_cast<CssStatics *>(swvGetGlobalDataPointer());
}

CssStatics &g_Statics()
{
    auto *statics = g_pStaticsNoLeave();
    CssMemoryError::LeaveIfNull(statics);
    return *statics;
}

void g_SetStatics(CssStatics *statics)
{
    swvSetGlobalDataPointer(statics);
}
