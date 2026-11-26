#ifndef SWERVE_CSSSTATICS_HPP
#define SWERVE_CSSSTATICS_HPP

#include "heap_object.hpp"

class CssAlignTargetManager;
class CssPickData;
class CssRayIntersection;
class CssObjectFactory;
class CssTrapManager;
class CssCleanupStackManager;
class CssMemoryManager;

struct CssStatics {
    CssObjectFactory *factory = nullptr;
    CssMemoryManager *memory = nullptr;
    CssTrapManager *traps = nullptr;
    CssCleanupStackManager *cleanup = nullptr;
    int current_index = -1;
    uint32_t animation_stamp = 0;
    SssTransformComponents *default_transform = nullptr;
    CssMatrix *identity = nullptr;
    int error = 0;
    CssAlignTargetManager *align_targets = nullptr;
    CssPickData *pick_data = nullptr;
    CssRayIntersection *ray_intersection = nullptr;
    CssStatics();
    ~CssStatics();
};

CssStatics &g_Statics();
CssStatics *g_pStaticsNoLeave();
void g_SetStatics(CssStatics *statics);
extern "C" void g_ssAssertLeave(bool condition, int error);

class CssMemoryError {
public:
    static void *LeaveIfNull(void *address);
};

class CssCleanupStackInstance : public CssStack<CssHeapObject *> {
public:
    CssCleanupStackInstance();
    bool started = false;
    bool IsInitialised() const { return started; }
    void Initialise();
    void Push(CssHeapObject *obj);
    void Pop(CssHeapObject *obj);
    void Cleanup();
};

class CssTrapManager {
public:
    CssTrapManager();
    ~CssTrapManager();
    static CssTrapManager *Initialize();
    static CssTrapManager *GetInstance();
    static CssTrapManager *GetInstanceNoLeave();
    static void DestroyInstance();
    static void operator delete(void *address) noexcept { swvFree(address); }
    void PushTrapHandler(CssTrapHandler *handler);
    void PopTrapHandler();
    [[noreturn]] void Leave(int error);
private:
    CssTrapHandler *handlers[5] = {};
    int count = 0;
};

class CssMemoryManager {
public:
    CssMemoryManager();
    static CssMemoryManager *Initialize();
    static void Uninitialize();
    static CssMemoryManager *GetInstance();
    static CssMemoryManager *GetInstanceNoLeave();
    static void operator delete(void *address) noexcept { swvFree(address); }
};

class CssEngine {
public:
    static bool Initialize();
    static void Uninitialize();
};

#endif
