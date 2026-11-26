#ifndef JBED_SWERVE_GEOMETRY_H
#define JBED_SWERVE_GEOMETRY_H
#include "engine.h"
#include <limits.h>

#if LONG_MAX == INT32_MAX
typedef long SwvVertexIndex;
#else
typedef int32_t SwvVertexIndex;
#endif

SWV_EXTERN_C_BEGIN
void vertexarray_getVertexCount(void *, int *);
void vertexarray_getComponentCount(void *, int *);
void vertexarray_getComponentType(void *, int *);
int vertexarray_create(int, int, int, void **);
int vertexarray_get8(void *, int, int, int, int8_t *);
int vertexarray_set8(void *, int, int, int, const int8_t *);
int vertexarray_get16(void *, int, int, int, int16_t *);
int vertexarray_set16(void *, int, int, int, const int16_t *);
int vertexbuffer_create(void **);
void vertexbuffer_getVertexCount(void *, int *);
void vertexbuffer_getDefaultColor(void *, int *);
void vertexbuffer_setDefaultColor(void *, int);
void vertexbuffer_getNormals(void *, void **);
void vertexbuffer_getColors(void *, void **);
int vertexbuffer_setNormals(void *, void *);
int vertexbuffer_setColors(void *, void *);
int vertexbuffer_getPositions(void *, int, float *, void **);
int vertexbuffer_getTexCoords(void *, int, int, float *, void **);
int vertexbuffer_setPositions(void *, void *, float, int, const float *);
int vertexbuffer_setTexCoords(void *, int, void *, float, int, const float *);
int trianglestriparray_createImplicit(int, int, const SwvVertexIndex *, void **);
int trianglestriparray_createExplicit(int, const SwvVertexIndex *, int, const SwvVertexIndex *, void **);
void indexbuffer_getIndexCount(void *, int *);
int indexbuffer_getIndices(void *, int, SwvVertexIndex *);
int mesh_createMultiSubmesh(void *, int, void *const *, int, void *const *, void **);
int mesh_createSingleSubmesh(void *, void *, void *, void **);
int mesh_getAppearance(void *, int, void **);
int mesh_getIndexBuffer(void *, int, void **);
void mesh_getSubmeshCount(void *, int *);
void mesh_getVertexBuffer(void *, void **);
int mesh_setAppearance(void *, int, void *);
int morphingmesh_createMultiSubmesh(void *, int, void *const *, int, void *const *, int, void *const *, void **);
int morphingmesh_createSingleSubmesh(void *, int, void *const *, void *, void *, void **);
int morphingmesh_getMorphTarget(void *, int, void **);
void morphingmesh_getMorphTargetCount(void *, int *);
int morphingmesh_getWeights(void *, int, float *);
int morphingmesh_setWeights(void *, int, const float *);
int skinnedmesh_addTransform(void *, void *, int, int, int);
int skinnedmesh_createMultiSubmesh(void *, int, void *const *, int, void *const *, void *, void **);
int skinnedmesh_createSingleSubmesh(void *, void *, void *, void *, void **);
int skinnedmesh_getBoneTransform(void *, void *, void *);
int skinnedmesh_getBoneVertices(void *, void *, int, SwvVertexIndex *, int, float *, int *);
void skinnedmesh_getSkeleton(void *, void **);

SWV_EXTERN_C_END
#endif
