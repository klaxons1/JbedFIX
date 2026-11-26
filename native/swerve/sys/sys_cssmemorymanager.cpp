#include "cssstatics.hpp"
#include <new>

CssMemoryManager::CssMemoryManager() = default;

CssMemoryManager *CssMemoryManager::Initialize()
{
    if (!CssTrapManager::Initialize() || !CssCleanupStackManager::Initialize())
        return nullptr;
    CssStatics *statics = g_pStaticsNoLeave();
    if (!statics) return nullptr;
    statics->memory = new (ENoLeave) CssMemoryManager;
    return statics->memory;
}

CssMemoryManager *CssMemoryManager::GetInstance()
{
    return g_Statics().memory;
}

CssMemoryManager *CssMemoryManager::GetInstanceNoLeave()
{
    CssStatics *statics = g_pStaticsNoLeave();
    return statics ? statics->memory : nullptr;
}

void CssMemoryManager::Uninitialize()
{
    if (CssCleanupStackManager::GetInstanceNoLeave())
        CssCleanupStackManager::DestroyInstance();
    if (CssTrapManager::GetInstanceNoLeave())
        CssTrapManager::DestroyInstance();
    delete GetInstanceNoLeave();
}
