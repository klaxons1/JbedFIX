#include "cssstatics.hpp"
#include "cssobjectfactory.hpp"
#include "cssaligntargetmanager.hpp"
#include "object_classes.hpp"
#include "math_pick.h"
#include <new>

bool CssEngine::Initialize()
{
    auto *statics = new (ENoLeave) CssStatics;
    if (!statics) {
        Uninitialize();
        return false;
    }
    g_SetStatics(statics);
    if (!CssMemoryManager::Initialize()) {
        Uninitialize();
        return false;
    }

    CssTrapHandler frame;
    if (setjmp(frame.Trap())) {
        statics->error = frame.error;
        Uninitialize();
        return false;
    }
    frame.CleanupStack();
    statics->identity = new (ELeave) CssMatrix;
    statics->identity->Identity();
    auto *state = new (ELeave) SssTransformComponents{};
    state->scale = {1, 1, 1};
    state->general = statics->identity;
    state->composite.Identity();
    statics->default_transform = state;
    CssObjectFactory::Create();
    CssTrapHandler::UnTrap();
    return true;
}

void CssEngine::Uninitialize()
{
    CssRayIntersection::Uninitialize();
    CssPickData::Uninitialize();
    CssAlignTargetManager::Uninitialize();
    CssObjectFactory::Destroy();
    CssStatics *statics = g_pStaticsNoLeave();
    if (statics) {
        if (statics->identity) {
            statics->identity->~CssMatrix();
            swvFree(statics->identity);
            statics->identity = nullptr;
        }
        if (statics->default_transform) {
            statics->default_transform->~SssTransformComponents();
            swvFree(statics->default_transform);
            statics->default_transform = nullptr;
        }
    }
    CssMemoryManager::Uninitialize();
    if (statics) {
        statics->~CssStatics();
        swvFree(statics);
        g_SetStatics(nullptr);
    }
}
