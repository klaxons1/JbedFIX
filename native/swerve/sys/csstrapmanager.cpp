#include "cssstatics.hpp"
#include <cstdlib>
#include <new>

CssTrapManager::CssTrapManager() = default;
CssTrapManager::~CssTrapManager() = default;

CssTrapManager *CssTrapManager::Initialize()
{
    CssStatics *statics = g_pStaticsNoLeave();
    if (!statics) return nullptr;
    statics->traps = new (ENoLeave) CssTrapManager;
    return statics->traps;
}

CssTrapManager *CssTrapManager::GetInstance()
{
    return g_Statics().traps;
}

CssTrapManager *CssTrapManager::GetInstanceNoLeave()
{
    CssStatics *statics = g_pStaticsNoLeave();
    return statics ? statics->traps : nullptr;
}

void CssTrapManager::DestroyInstance()
{
    auto &manager = g_Statics().traps;
    delete manager;
    manager = nullptr;
}

void CssTrapManager::PushTrapHandler(CssTrapHandler *handler)
{
    handlers[count++] = handler;
}

void CssTrapManager::PopTrapHandler()
{
    --count;
}

void CssTrapManager::Leave(int error)
{
    if (count) {
        handlers[count - 1]->Leave(error);
        if (count)
            handlers[count - 1]->Leave(error);
    }
    swvExit();
    std::abort();
}
