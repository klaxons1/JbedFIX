#include "cssstatics.hpp"
#include "cssaligntargetmanager.hpp"
#include "object_class.hpp"

CssAlignTargetManager *CssAlignTargetManager::GetInstance()
{
    auto &instance = g_Statics().align_targets;
    if (!instance) {
        CssHeapPtr<CssAlignTargetManager> manager(new CssAlignTargetManager);
        instance = manager.release();
    }
    return instance;
}

void CssAlignTargetManager::Uninitialize()
{
    CssStatics *statics = g_pStaticsNoLeave();
    if (!statics) return;
    delete statics->align_targets;
    statics->align_targets = nullptr;
}

CssAlignTargetManager::~CssAlignTargetManager()
{
    for (int i = 0; i < targets.Size(); ++i) {
        delete targets[i];
        targets[i] = nullptr;
    }
}

void CssAlignTargetManager::RemoveTargetNode(const CssNode *target)
{
    auto *manager = g_Statics().align_targets;
    if (!manager) return;
    for (int i = 0; i < manager->targets.Size(); ++i) {
        CssAlignTarget *entry = manager->targets[i];
        if (entry->target == target) {
            manager->targets.Remove(i);
            delete entry;
            return;
        }
    }
}

void CssAlignTargetManager::RemoveAlignedNode(CssNode *source)
{
    auto *manager = g_Statics().align_targets;
    if (!manager) return;
    for (int i = 0; i < manager->targets.Size(); ++i) {
        CssAlignTarget *entry = manager->targets[i];
        if (entry->target == source->GetAlignmentReferenceUnsafe(CssNode::YAxis) ||
            entry->target == source->GetAlignmentReferenceUnsafe(CssNode::ZAxis)) {
            entry->RemoveSource(source);
            if (entry->IsEmpty()) {
                manager->targets.Remove(i--);
                delete entry;
            }
        }
    }
}

void CssAlignTargetManager::RegisterAlignedNode(CssNode *source)
{
    CssAlignTargetManager *manager = GetInstance();
    manager->SetAlignmentInArray(source, source->GetAlignmentReferenceUnsafe(CssNode::ZAxis));
    manager->SetAlignmentInArray(source, source->GetAlignmentReferenceUnsafe(CssNode::YAxis));
}

void CssAlignTargetManager::SetAlignmentInArray(CssNode *source, const CssNode *target)
{
    if (!target) return;
    for (int i = 0; i < targets.Size(); ++i) {
        if (targets[i]->target == target) {
            targets[i]->AddSource(source);
            return;
        }
    }
    CssHeapPtr<CssAlignTarget> entry(new CssAlignTarget);
    entry->Construct(target);
    entry->AddSource(source);
    targets.Append(entry.get());
    entry.release();
}

void CssAlignTargetManager::CssAlignTarget::Construct(const CssNode *node)
{
    target = node;
    sources.SetSize(0);
}

void CssAlignTargetManager::CssAlignTarget::Destroy()
{
    if (target) {
        for (int i = 0; i < sources.Size(); ++i)
            sources[i]->NullReferencesOf(target);
        sources.SetSize(0);
        target = nullptr;
    }
}

void CssAlignTargetManager::CssAlignTarget::AddSource(CssNode *source)
{
    if (!source) return;
    for (int i = 0; i < sources.Size(); ++i)
        if (sources[i] == source) return;
    sources.Append(source);
}

void CssAlignTargetManager::CssAlignTarget::RemoveSource(CssNode *source)
{
    if (!source) return;
    for (int i = 0; i < sources.Size(); ++i) {
        if (sources[i] == source) {
            sources.Remove(i);
            source->NullReferencesOf(target);
        }
    }
}
