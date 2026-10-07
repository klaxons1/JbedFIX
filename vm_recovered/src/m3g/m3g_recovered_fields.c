/*
 * Normalized direct-field accessors for several JSR-184 objects.
 *
 * All offsets below are relative to the internal ARM32 object base.  The
 * original core receives a public handle and subtracts four bytes before
 * accessing the object.  These accessors are intentionally safe on a host and
 * return 0 for a null handle/output pointer.
 *
 * Proven source addresses:
 *   Mesh                 0x2f5e44
 *   MorphingMesh         0x2f6200
 *   Sprite3D             0x2f7640..0x2f76e0
 *   Texture2D            0x2f8210..0x2f82f4
 *   Material             0x2f5ab4, 0x2f5b60
 *   Fog                  0x2f3a18, 0x2f3aac
 *   Background           0x2cf1f0
 *   Graphics3D           0x2f3bd8..0x2f3c50
 *   KeyframeSequence     0x2f5050..0x2f51a4
 */
#include "m3g_recovered_fields.h"

#include <stddef.h>
#include <stdint.h>

static unsigned char *object_base(JbedM3GHandle handle)
{
    return handle == NULL ? NULL : (unsigned char *)handle - 4u;
}

static int read_u32(JbedM3GHandle handle, size_t offset, int32_t *out)
{
    unsigned char *base = object_base(handle);
    if (base == NULL || out == NULL) {
        return 0;
    }
    *out = *(const int32_t *)(base + offset);
    return 1;
}

static int read_u8(JbedM3GHandle handle, size_t offset, int32_t *out)
{
    unsigned char *base = object_base(handle);
    if (base == NULL || out == NULL) {
        return 0;
    }
    *out = base[offset];
    return 1;
}

#define U32_ACCESSOR(fn, offset) \
    int fn(JbedM3GHandle h, int32_t *out) { return read_u32(h, offset, out); }
#define U8_ACCESSOR(fn, offset) \
    int fn(JbedM3GHandle h, int32_t *out) { return read_u8(h, offset, out); }

U32_ACCESSOR(jbed_m3g_mesh_get_submesh_count, 164u)
U32_ACCESSOR(jbed_m3g_morphingmesh_get_morph_target_count, 220u)

U32_ACCESSOR(jbed_m3g_node_get_scope, 44u)
U8_ACCESSOR(jbed_m3g_node_is_picking_enabled, 61u)
U8_ACCESSOR(jbed_m3g_node_is_rendering_enabled, 61u)
U32_ACCESSOR(jbed_m3g_node_get_alpha_factor, 40u)
U32_ACCESSOR(jbed_m3g_world_get_active_camera, 152u)
U32_ACCESSOR(jbed_m3g_world_get_background, 156u)

U32_ACCESSOR(jbed_m3g_light_get_mode, 180u)
int jbed_m3g_light_get_color(JbedM3GHandle handle, int32_t *out)
{
    if (!read_u32(handle, 164u, out)) {
        return 0;
    }
    *out &= INT32_C(0x00ffffff);
    return 1;
}
U32_ACCESSOR(jbed_m3g_light_get_intensity, 168u)
U32_ACCESSOR(jbed_m3g_light_get_spot_angle, 172u)
U32_ACCESSOR(jbed_m3g_light_get_spot_exponent, 176u)
U32_ACCESSOR(jbed_m3g_light_get_constant_attenuation, 152u)
U32_ACCESSOR(jbed_m3g_light_get_linear_attenuation, 156u)
U32_ACCESSOR(jbed_m3g_light_get_quadratic_attenuation, 160u)

U32_ACCESSOR(jbed_m3g_sprite3d_get_crop_x, 160u)
U32_ACCESSOR(jbed_m3g_sprite3d_get_crop_y, 164u)
U32_ACCESSOR(jbed_m3g_sprite3d_get_crop_width, 156u)
U32_ACCESSOR(jbed_m3g_sprite3d_get_crop_height, 152u)
U8_ACCESSOR(jbed_m3g_sprite3d_is_scaled, 176u)

U32_ACCESSOR(jbed_m3g_texture2d_get_blending, 40u)
U32_ACCESSOR(jbed_m3g_texture2d_get_blend_color, 36u)
U32_ACCESSOR(jbed_m3g_texture2d_get_image_filter, 60u)
U32_ACCESSOR(jbed_m3g_texture2d_get_level_filter, 56u)
U32_ACCESSOR(jbed_m3g_texture2d_get_wrapping_s, 48u)
U32_ACCESSOR(jbed_m3g_texture2d_get_wrapping_t, 52u)

U32_ACCESSOR(jbed_m3g_material_get_shininess, 48u)
U8_ACCESSOR(jbed_m3g_material_is_vertex_color_tracking_enabled, 44u)
U32_ACCESSOR(jbed_m3g_fog_get_density, 32u)
U32_ACCESSOR(jbed_m3g_fog_get_mode, 44u)
U32_ACCESSOR(jbed_m3g_background_get_color, 28u)

U32_ACCESSOR(jbed_m3g_graphics3d_get_width, 60u)
U32_ACCESSOR(jbed_m3g_graphics3d_get_height, 64u)
U32_ACCESSOR(jbed_m3g_graphics3d_get_pitch, 28u)
U32_ACCESSOR(jbed_m3g_graphics3d_get_depth_range_near, 140u)
U32_ACCESSOR(jbed_m3g_graphics3d_get_depth_range_far, 144u)
U8_ACCESSOR(jbed_m3g_graphics3d_is_depth_buffer_enabled, 148u)

U32_ACCESSOR(jbed_m3g_keyframesequence_get_duration, 40u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_repeat_mode, 32u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_keyframe_count, 56u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_component_count, 52u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_interpolation_type, 28u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_valid_range_first, 44u)
U32_ACCESSOR(jbed_m3g_keyframesequence_get_valid_range_last, 48u)

#undef U32_ACCESSOR
#undef U8_ACCESSOR
