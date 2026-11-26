#include "cssstatics.hpp"
#include <cstdlib>

extern "C" void g_ssThrowLeave(int error)
{
    if (auto *manager = CssTrapManager::GetInstanceNoLeave())
        manager->Leave(error);
    swvExit();
    std::abort();
}

extern "C" void g_ssAssertLeave(bool condition, int error)
{
    if (!condition)
        g_ssThrowLeave(error);
}
