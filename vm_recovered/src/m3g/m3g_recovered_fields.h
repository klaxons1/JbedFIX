#ifndef JBED_RECOVERED_M3G_FIELDS_H
#define JBED_RECOVERED_M3G_FIELDS_H

#include "m3g_object3d_fields.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Direct field accessors normalized from Swerve core methods. */
int jbed_m3g_mesh_get_submesh_count(JbedM3GHandle, int32_t *);
int jbed_m3g_morphingmesh_get_morph_target_count(JbedM3GHandle, int32_t *);

int jbed_m3g_node_get_scope(JbedM3GHandle, int32_t *);
int jbed_m3g_node_is_picking_enabled(JbedM3GHandle, int32_t *);
int jbed_m3g_node_is_rendering_enabled(JbedM3GHandle, int32_t *);
int jbed_m3g_node_get_alpha_factor(JbedM3GHandle, int32_t *);
int jbed_m3g_world_get_active_camera(JbedM3GHandle, int32_t *);
int jbed_m3g_world_get_background(JbedM3GHandle, int32_t *);

int jbed_m3g_light_get_mode(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_color(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_intensity(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_spot_angle(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_spot_exponent(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_constant_attenuation(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_linear_attenuation(JbedM3GHandle, int32_t *);
int jbed_m3g_light_get_quadratic_attenuation(JbedM3GHandle, int32_t *);

int jbed_m3g_sprite3d_get_crop_x(JbedM3GHandle, int32_t *);
int jbed_m3g_sprite3d_get_crop_y(JbedM3GHandle, int32_t *);
int jbed_m3g_sprite3d_get_crop_width(JbedM3GHandle, int32_t *);
int jbed_m3g_sprite3d_get_crop_height(JbedM3GHandle, int32_t *);
int jbed_m3g_sprite3d_is_scaled(JbedM3GHandle, int32_t *);

int jbed_m3g_texture2d_get_blending(JbedM3GHandle, int32_t *);
int jbed_m3g_texture2d_get_blend_color(JbedM3GHandle, int32_t *);
int jbed_m3g_texture2d_get_image_filter(JbedM3GHandle, int32_t *);
int jbed_m3g_texture2d_get_level_filter(JbedM3GHandle, int32_t *);
int jbed_m3g_texture2d_get_wrapping_s(JbedM3GHandle, int32_t *);
int jbed_m3g_texture2d_get_wrapping_t(JbedM3GHandle, int32_t *);

int jbed_m3g_material_get_shininess(JbedM3GHandle, int32_t *);
int jbed_m3g_material_is_vertex_color_tracking_enabled(JbedM3GHandle, int32_t *);
int jbed_m3g_fog_get_density(JbedM3GHandle, int32_t *);
int jbed_m3g_fog_get_mode(JbedM3GHandle, int32_t *);
int jbed_m3g_background_get_color(JbedM3GHandle, int32_t *);

int jbed_m3g_graphics3d_get_width(JbedM3GHandle, int32_t *);
int jbed_m3g_graphics3d_get_height(JbedM3GHandle, int32_t *);
int jbed_m3g_graphics3d_get_pitch(JbedM3GHandle, int32_t *);
int jbed_m3g_graphics3d_get_depth_range_near(JbedM3GHandle, int32_t *);
int jbed_m3g_graphics3d_get_depth_range_far(JbedM3GHandle, int32_t *);
int jbed_m3g_graphics3d_is_depth_buffer_enabled(JbedM3GHandle, int32_t *);

int jbed_m3g_keyframesequence_get_duration(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_repeat_mode(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_keyframe_count(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_component_count(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_interpolation_type(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_valid_range_first(JbedM3GHandle, int32_t *);
int jbed_m3g_keyframesequence_get_valid_range_last(JbedM3GHandle, int32_t *);

#ifdef __cplusplus
}
#endif

#endif
