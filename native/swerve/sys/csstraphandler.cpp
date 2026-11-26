#include "cssstatics.hpp"

jmp_buf &CssTrapHandler::Trap()
{
    active = cleanup_ready = false;
    CssTrapManager::GetInstance()->PushTrapHandler(this);
    active = true;
    return jump;
}

void CssTrapHandler::CleanupStack()
{
    CssCleanupStackManager::GetInstance()->PushStackFrame();
    cleanup_ready = true;
}

void CssTrapHandler::Leave(int code)
{
    if (active) {
        CssTrapManager::GetInstance()->PopTrapHandler();
        auto *cleanup = CssCleanupStackManager::GetInstance();
        if (cleanup_ready)
            cleanup->PopStackFrame();
        else
            cleanup->Cleanup();
        error = code ? code : 1;
        longjmp(jump, code);
    }
}

void CssTrapHandler::UnTrap()
{
    CssTrapManager::GetInstance()->PopTrapHandler();
    CssCleanupStackManager::GetInstance()->PopStackFrame();
}
