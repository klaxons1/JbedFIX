#include "cssstatics.hpp"
#include <new>

CssCleanupStackManager::CssCleanupStackManager() = default;

CssCleanupStackManager::~CssCleanupStackManager()
{
    for (int i = 0; i < lists.size; ++i)
        delete lists[i];
}

CssCleanupStackManager *CssCleanupStackManager::Initialize()
{
    CssStatics *statics = g_pStaticsNoLeave();
    if (!statics) return nullptr;
    statics->cleanup = new (ENoLeave) CssCleanupStackManager;
    return statics->cleanup;
}

CssCleanupStackManager *CssCleanupStackManager::GetInstance()
{
    return g_Statics().cleanup;
}

CssCleanupStackManager *CssCleanupStackManager::GetInstanceNoLeave()
{
    CssStatics *statics = g_pStaticsNoLeave();
    return statics ? statics->cleanup : nullptr;
}

void CssCleanupStackManager::DestroyInstance()
{
    auto &manager = g_Statics().cleanup;
    delete manager;
    manager = nullptr;
}

void CssCleanupStackManager::PushInternal(CssHeapObject *object)
{
    lists[depth - 1]->Push(object);
}

void CssCleanupStackManager::PopInternal(CssHeapObject *object)
{
    lists[depth - 1]->Pop(object);
}

void CssCleanupStackManager::PushStackFrame()
{
    live = false;
    if (lists.size == depth) {
        lists.Append(nullptr);
        lists[depth] = new CssCleanupStackInstance;
    }
    ++depth;
    live = true;
    lists[depth - 1]->Initialise();
}

void CssCleanupStackManager::Cleanup()
{
    if (live && depth > 0) {
        CssCleanupStackInstance *list = lists[depth - 1];
        if (!list) {
            --depth;
        } else if (!list->IsInitialised()) {
            delete list;
            lists[--depth] = nullptr;
        } else {
            list->Cleanup();
        }
    }
    live = true;
}

void CssCleanupStackManager::PopStackFrame()
{
    Cleanup();
    --depth;
}
