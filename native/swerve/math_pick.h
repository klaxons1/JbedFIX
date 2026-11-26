#ifndef JBED_SWERVE_PICK_H
#define JBED_SWERVE_PICK_H
#include "engine.h"
#include "heap_object.hpp"

class CssRayIntersection;
class CssCamera;

class CssPickData : public CssHeapObject {
public:
    struct SssPickRay {
        CssVector3D start, end;
    };

    static void Initialize();
    static CssPickData *GetInstance();
    static void Uninitialize();
    CssStack<SssPickRay> saved;
    SssPickRay ray;
    CssCamera *camera;
    CssRayIntersection *hit;
    int scope;
};

bool swv_pick_empty_group(int scope, const CssVector3D &, const CssVector3D &, CssRayIntersection *);

#endif
