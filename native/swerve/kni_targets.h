#ifndef JBED_SWERVE_KNI_TARGETS_H
#define JBED_SWERVE_KNI_TARGETS_H

#include "engine.h"
#include "objects.h"
#include "loader.h"
#include "geometry.h"
#include "image2d.h"

SWV_EXTERN_C_BEGIN

/* Native entry points used by the KNI adapters. */
int camera_create(void **);
int camera_getProjectionParams(void *, int, float *, int *);
int camera_getProjectionTransform(void *, void *, int *);
int camera_setGeneric(void *, void *);
int camera_setParallel(void *, float, float, float, float);
int camera_setPerspective(void *, float, float, float, float);
int graphics3d_addLight(void *, void *, void *, int *);
int graphics3d_clear(void *, void *);
int graphics3d_create(void **);
int graphics3d_getCamera(void *, void *, void **);
void graphics3d_getWidth(void *, int *);
void graphics3d_getHeight(void *, int *);
void graphics3d_getPitch(void *, int *);
void graphics3d_getPixels(void *, void **);
void graphics3d_getDepthRangeFar(void *, float *);
void graphics3d_getDepthRangeNear(void *, float *);
void graphics3d_getHints(void *, int *);
int graphics3d_getLight(void *, int, void *, void **);
void graphics3d_getLightCount(void *, int *);
void graphics3d_isDepthBufferEnabled(void *, int *);
int graphics3d_renderNode(void *, void *, void *);
int graphics3d_renderPrimitive(void *, void *, void *, void *, void *, int);
int graphics3d_renderWorld(void *, void *);
int graphics3d_resetLights(void *);
int graphics3d_setBackBufferData(void *, int, int, int, void *);
int graphics3d_setCroppedBackBufferData(void *, int, int, int, void *, int, int, int, int);
void graphics3d_updateBackBufferData(void *, void *);
int graphics3d_setBackBufferImage2D(void *, void *);
int graphics3d_setCamera(void *, void *, void *);
int graphics3d_setDepthRange(void *, float, float);
int graphics3d_setHints(void *, int, int);
int graphics3d_setLight(void *, int, void *, void *);
int graphics3d_setViewport(void *, int, int, int, int);
int group_addChild(void *, void *);
int group_create(void **);
int group_getChild(void *, int, void **);
void group_getChildCount(void *, int *);
int group_pickCamera(void *, int, float, float, void *, void *, int *);
int group_pickNode(void *, int, const float *, const float *, void *, int *);
int group_removeChild(void *, void *);
int node_align(void *, void *);
int node_getTransformTo(void *, void *, void *, int *);
int object3d_animate(void *, int, int *);
int transform_create(void **);
int transform_createCopy(void *, void **);
int transform_get(void *, int, float *);
int transform_invert(void *);
int transform_postMultiply(void *, void *);
int transform_postRotate(void *, const float *);
int transform_postRotateQuat(void *, const float *);
int transform_postScale(void *, const float *);
int transform_postTranslate(void *, const float *);
void transform_setIdentity(void *);
int transform_setMatrix(void *, int, const float *);
int transform_setTransform(void *, void *);
int transform_transform(void *, void *, int, float *, int);
int transform_transformPoints(void *, int, float *);
void transform_transpose(void *);
int transformable_getCompositeTransform(void *, void *);
void transformable_getOrientation(void *, float *);
void transformable_getScale(void *, float *);
int transformable_getTransform(void *, void *);
void transformable_getTranslation(void *, float *);
int transformable_postRotate(void *, const float *);
int transformable_preRotate(void *, const float *);
int transformable_scale(void *, const float *);
int transformable_setOrientation(void *, const float *);
int transformable_setScale(void *, const float *);
int transformable_setTransform(void *, void *);
int transformable_setTranslation(void *, const float *);
int transformable_translate(void *, const float *);

SWV_EXTERN_C_END
#endif
