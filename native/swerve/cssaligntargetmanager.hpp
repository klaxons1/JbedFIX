#ifndef SWERVE_CSSALIGNTARGETMANAGER_HPP
#define SWERVE_CSSALIGNTARGETMANAGER_HPP

#include "heap_object.hpp"

class CssNode;

class CssAlignTargetManager : public CssHeapObject {
public:
    static CssAlignTargetManager *GetInstance();
    static void RegisterAlignedNode(CssNode *source);
    static void RemoveAlignedNode(CssNode *source);
    static void RemoveTargetNode(const CssNode *target);
    static void Uninitialize();
    ~CssAlignTargetManager() override;

private:
    class CssAlignTarget : public CssHeapObject {
    public:
        const CssNode *target = nullptr;
        CssArray<CssNode *> sources;

        void Construct(const CssNode *node);
        void Destroy();
        void AddSource(CssNode *source);
        void RemoveSource(CssNode *source);
        bool IsEmpty() const { return sources.Size() == 0; }
        ~CssAlignTarget() override { Destroy(); }
    };
    CssArray<CssAlignTarget *> targets;
    void SetAlignmentInArray(CssNode *source, const CssNode *target);
};

#endif
