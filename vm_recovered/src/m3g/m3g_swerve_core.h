#ifndef JBED_RECOVERED_M3G_SWERVE_CORE_H
#define JBED_RECOVERED_M3G_SWERVE_CORE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Swerve core ABI recovered from the exported symbols of libjbedvm.so.
 * These are not JNI functions. Handles are VM-owned and are normally passed
 * after the JNI adapter has called SWV_GetSwerveHandleFromPeer.
 */
typedef int32_t JbedM3GResult;
typedef int32_t JbedM3GHandle;

/* graphics3d_* core: original addresses 0x2f3bd8..0x2f4550 */
JbedM3GResult graphics3d_create(int32_t *out_graphics);
JbedM3GResult graphics3d_getWidth(JbedM3GHandle graphics, int32_t *out_width);
JbedM3GResult graphics3d_getHeight(JbedM3GHandle graphics, int32_t *out_height);
JbedM3GResult graphics3d_getPitch(JbedM3GHandle graphics, int32_t *out_pitch);
JbedM3GResult graphics3d_getPixels(JbedM3GHandle graphics, int32_t *out_pixels);
JbedM3GResult graphics3d_setViewport(JbedM3GHandle graphics, int32_t x,
                                      int32_t y, int32_t width, int32_t height);
JbedM3GResult graphics3d_setDepthRange(JbedM3GHandle graphics, int32_t near_w,
                                        int32_t far_w);
JbedM3GResult graphics3d_clear(JbedM3GHandle graphics, JbedM3GHandle background);
JbedM3GResult graphics3d_renderWorld(JbedM3GHandle graphics,
                                     JbedM3GHandle world);
JbedM3GResult graphics3d_renderNode(JbedM3GHandle graphics, JbedM3GHandle node,
                                    JbedM3GHandle transform);
JbedM3GResult graphics3d_renderPrimitive(JbedM3GHandle graphics,
                                          JbedM3GHandle vertex_buffer,
                                          JbedM3GHandle index_buffer,
                                          JbedM3GHandle appearance,
                                          JbedM3GHandle transform,
                                          int32_t scope);
JbedM3GResult graphics3d_setCamera(JbedM3GHandle graphics,
                                   JbedM3GHandle camera,
                                   JbedM3GHandle transform);
JbedM3GResult graphics3d_getCamera(JbedM3GHandle graphics,
                                   JbedM3GHandle transform,
                                   int32_t *out_camera);
JbedM3GResult graphics3d_addLight(JbedM3GHandle graphics, int32_t index,
                                  JbedM3GHandle light, int32_t *out_transform);
JbedM3GResult graphics3d_resetLights(JbedM3GHandle graphics);

/* transform_* core: original addresses 0x2f8420..0x2f8c28 */
JbedM3GResult transform_create(int32_t *out_transform);
JbedM3GResult transform_createCopy(JbedM3GHandle source,
                                   int32_t *out_transform);
void *transform_setIdentity(JbedM3GHandle transform);
JbedM3GResult transform_setMatrix(JbedM3GHandle transform, int32_t matrix_kind,
                                  int32_t matrix_ptr);
JbedM3GResult transform_get(JbedM3GHandle transform, int32_t matrix_kind,
                            int32_t *out_matrix);
JbedM3GResult transform_invert(JbedM3GHandle transform);
JbedM3GResult transform_transpose(JbedM3GHandle transform);
JbedM3GResult transform_transform(JbedM3GHandle transform, int32_t vector_ptr,
                                  int32_t vector_kind, int32_t out_ptr,
                                  uint32_t normalize);
JbedM3GResult transform_transformPoints(JbedM3GHandle transform,
                                        int32_t count, int32_t points_ptr);

/* Native loader core: original addresses 0x2cb11c..0x2cc500. */
JbedM3GResult swvLoaderCreate(int32_t io_a, int32_t io_b, int32_t io_c,
                              void **out_loader);
JbedM3GResult swvLoaderLoadNamed(int32_t loader, int32_t name_ptr,
                                 int32_t name_length, int32_t *out_status);
JbedM3GResult swvLoaderLoadBuffer(int32_t *loader, int32_t io_a,
                                  int32_t buffer_ptr, int32_t buffer_length,
                                  int32_t *out_status);
JbedM3GResult swvLoaderGetRootCount(int32_t *loader);
JbedM3GResult swvLoaderGetRoot(int32_t *loader, int32_t index);

#ifdef __cplusplus
}
#endif

#endif
