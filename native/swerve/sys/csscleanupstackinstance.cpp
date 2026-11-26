#include "cssstatics.hpp"

CssCleanupStackInstance::CssCleanupStackInstance() = default;

void CssCleanupStackInstance::Initialise()
{
    items.Append(nullptr);
    started = true;
}

void CssCleanupStackInstance::Push(CssHeapObject *object)
{
    items[items.size - 1] = object;
    items.Append(nullptr);
}

void CssCleanupStackInstance::Pop(CssHeapObject *)
{
    items.SetSize(items.size - 1);
    items[items.size - 1] = nullptr;
}

void CssCleanupStackInstance::Cleanup()
{
    while (items.size) {
        delete items[items.size - 1];
        items.SetSize(items.size - 1);
    }
}
