#ifndef SWV_PICK_CLASS_HPP
#define SWV_PICK_CLASS_HPP

#include "geometry.h"

class CssPickData;
class CssMesh;
class CssNode;
class CssSprite;

class CssPick {
public:
    void PickNode(CssPickData *, const CssNode *);
    void PickMesh(CssPickData *, const CssMesh *);
    void PickSprite(CssPickData *, const CssSprite *);
    void PushInternalState(CssPickData *);
    void PopInternalState(CssPickData *);
    void TransformRay(CssPickData *, const CssMatrix &);
    bool TriangleHit(const CssVector3D &direction, const CssVector3D &first,
                     const CssVector3D &second, const CssVector3D &third, int flags,
                     float *distance, float *u, float *v);
    bool PickBoundingBox(CssPickData *, const CssVector3D &minimum, const CssVector3D &maximum) const;
};

#endif
