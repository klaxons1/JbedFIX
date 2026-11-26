#include "geometry.h"
#include "geometry_class.hpp"
#include "image_class.hpp"
#include "object_classes.hpp"
#include <algorithm>
#include "graphics3d_state.h"
#include "platform.h"
#include "cssfixed1616.hpp"
#include <stdlib.h>
#include <string.h>
#include <bit>
#include <cmath>

namespace {
enum ClipPlane { ClipRight, ClipLeft, ClipTop, ClipBottom, ClipFar, ClipNear, ClipPlaneCount };
constexpr int MaxProjectedDepth = 0x0fffffff;
constexpr int ReciprocalRescaleThreshold = 0x100000;
constexpr int MaxSpriteCoordinate = 0x800000;
constexpr unsigned OrientationOperandLimit = 1u << 14;
constexpr int QueueDepthBits = 24;
constexpr int QueueDepthMask = (1 << QueueDepthBits) - 1;
constexpr int QueueTransparencyBit = QueueDepthBits;
constexpr int QueueLayerShift = QueueTransparencyBit + 1;
}

static float fog_fraction(const CssFog *fog, float eye_distance, float w)
{
    float fraction = 0;
    if (fog->mode == SWV_FOG_LINEAR) {
        float span = w * (fog->far_distance - fog->near_distance);
        float offset = eye_distance - w * fog->near_distance;
        fraction = span ? offset / span : 1;
    } else if (fog->mode == SWV_FOG_EXPONENTIAL) {
        float z = eye_distance / w;
        fraction = 1 - g_float_exp(-z * fog->density);
    }
    return fraction < 0 ? 0 : fraction > 1 ? 1 : fraction;
}
void CssRendererStandard::ClearCache()
{
    positions.Clear();
    eye_positions.Clear();
    normals.Clear();
    for (auto &uv : texcoords)
        uv.Clear();
}

void CssRendererStandard::TransformAndClipVertices(const CssMatrix &model)
{
    auto &v = *vertex_buffer;
    CssMatrix transform = view_projection;
    transform *= model;
    bool visible;
    const CssVector3D bias{v.position_bias[0], v.position_bias[1], v.position_bias[2]};
    positions.Initialize(v.positions, transform, v.position_scale, bias, &visible);
    if (!visible) {
        clip_intersection = clip_union = 1u << ClipRight;
        return;
    }
    positions.TransformAll4D();
    clip_flags.SetSize(v.count);
    clip_intersection = UINT8_MAX;
    clip_union = 0;
    for (int i = 0; i < v.count; ++i) {
        const CssFixedVector3D *p;
        SwvFixedWord w;
        positions.GetVector4D(i, &p, &w);
        unsigned f = 0;
        if (p->z > w) f |= 1u << ClipFar;
        if (p->z < -w) f |= 1u << ClipNear;
        if (p->x > w) f |= 1u << ClipRight;
        if (p->x < -w) f |= 1u << ClipLeft;
        if (p->y > w) f |= 1u << ClipTop;
        if (p->y < -w) f |= 1u << ClipBottom;
        clip_flags[i] = f;
        clip_union |= f;
        clip_intersection &= f;
    }
    if (!clip_intersection) {
        model_view = view;
        model_view *= model;
        normal_transform_valid = false;
        eye_positions.InitializeLazy(v.positions, model_view, v.position_scale, bias);
    }
}

static int mul_fixed(int a, int b)
{
    return int64_t(a) * b >> 16;
}

void CssRendererStandard::ProjectVertex(SssProjectedVertex *out, const CssFixedVector3D *p,
                                        SwvFixedWord reciprocal)
{
    int x = std::clamp<SwvFixedWord>(65536 + p->x, 0, 131072), y = std::clamp<SwvFixedWord>(65536 - p->y, 0, 131072);
    if (graphics->dirty)
        graphics->UpdateIntersection();
    out->x = 16 * graphics->relative.x + ((mul_fixed(viewport_scale[0], x) + 32768) >> 16);
    out->y = 16 * graphics->relative.y + ((mul_fixed(viewport_scale[1], y) + 32768) >> 16);
    int z = (depth_scale >> 3) * ((p->z + 65536) >> 2) + depth_bias;
    out->z = std::clamp(z, 0, MaxProjectedDepth);
    for (int unit = 0; unit < texture_units; ++unit)
        out->tex[unit].q = texture_projective[unit] ? mul_fixed(reciprocal, out->tex[unit].r) : reciprocal;
}

void CssClipVertex::SetPosition(const SssLitVertex &v, const SssTLTexCoordsStd *uv, int units)
{
    position = *v.clip_position;
    w = v.clip_w;
    rgb[0] = v.color.RedInt();
    rgb[1] = v.color.GreenInt();
    rgb[2] = v.color.BlueInt();
    alpha = v.alpha;
    fog = v.fog;
    textures = units;
    for (int i = units - 1; i >= 0; --i)
        tex[i] = uv[i];
}

void CssClipVertex::SetClipPosition(const CssClipVertex &inside, const CssClipVertex &outside,
                                    SwvFixedWord fraction)
{
    *this = inside;
    auto mix = [](int a, int b, int f) {
        return a + mul_fixed(b - a, f);
    };
    position.x = mix(position.x, outside.position.x, fraction);
    position.y = mix(position.y, outside.position.y, fraction);
    position.z = mix(position.z, outside.position.z, fraction);
    w = mix(w, outside.w, fraction);
    for (int unit = 0; unit < textures; ++unit) {
        auto &t = tex[unit];
        const auto &end = outside.tex[unit];
        SwvFixedWord amount = fraction;
        if (t.r != end.r) {
            t.r = mix(t.r, end.r, fraction);
            int divisor = t.r, numerator = end.r;
            while (divisor > ReciprocalRescaleThreshold || divisor < -ReciprocalRescaleThreshold) {
                divisor >>= 6;
                numerator >>= 6;
            }
            amount = mul_fixed(fraction, mul_fixed(g_fixed_reciprocal(divisor), numerator));
        }
        t.s = mix(t.s, end.s, amount);
        t.t = mix(t.t, end.t, amount);
    }
    for (int i = 0; i < 3; ++i)
        rgb[i] = mix(rgb[i], outside.rgb[i], fraction);
    alpha = mix(alpha, outside.alpha, fraction);
    fog = mix(fog, outside.fog, fraction);
}

void CssClipVertex::DivideByW()
{
    int shift = 0;
    reciprocal_w = w;
    while (reciprocal_w > ReciprocalRescaleThreshold) {
        reciprocal_w >>= 4;
        shift += 4;
    }
    while (reciprocal_w > 0x10000) {
        reciprocal_w >>= 1;
        ++shift;
    }
    reciprocal_w = g_fixed_reciprocal(reciprocal_w);
    position.x = mul_fixed(position.x >> shift, reciprocal_w);
    position.y = mul_fixed(position.y >> shift, reciprocal_w);
    position.z = mul_fixed(position.z >> shift, reciprocal_w);
    reciprocal_w >>= shift;
}

int CssRendererStandard::ClipPolygon(int first, int plane)
{
    int end = clipped_vertices.size;
    auto distance = [plane](const CssClipVertex &v) {
        int p = plane < ClipTop ? v.position.x : plane < ClipFar ? v.position.y : v.position.z;
        return (plane & 1) ? v.w + p : v.w - p;
    };
    int prev = end - 1;
    int dp = distance(clipped_vertices[prev]);
    for (int i = first; i < end; ++i) {
        int dc = distance(clipped_vertices[i]);
        if ((dp ^ dc) < 0) {
            int slot = clipped_vertices.size;
            clipped_vertices.SetSizeDoubling(slot + 1);
            bool prev_inside = dp >= 0;
            int in = prev_inside ? dp : dc, out = prev_inside ? dc : dp;
            int fraction = g_divide_int64_int64(int64_t(in) * 65536, in - out) + 1;
            clipped_vertices[slot].SetClipPosition(clipped_vertices[prev_inside ? prev : i],
                                                   clipped_vertices[prev_inside ? i : prev], fraction);
        }
        if (dc >= 0) {
            int slot = clipped_vertices.size;
            clipped_vertices.SetSizeDoubling(slot + 1);
            clipped_vertices[slot] = clipped_vertices[i];
        }
        prev = i;
        dp = dc;
    }
    return end;
}

void CssRendererStandard::DrawClippedTriangle()
{
    int first = 0, count = 3;
    for (int plane = 0; plane < ClipPlaneCount && count; ++plane) {
        if (clip_planes & (1 << plane)) {
            first = ClipPolygon(first, plane);
            count = clipped_vertices.size - first;
        }
    }
    for (int i = 0; i < count; ++i) {
        auto &v = clipped_vertices[first + i];
        auto &p = projected[i];
        std::copy_n(v.tex, texture_units, p.tex);
        v.DivideByW();
        ProjectVertex(&p, &v.position, v.reciprocal_w);
        std::copy_n(v.rgb, 3, p.rgb);
        p.alpha = v.alpha;
        p.fog = v.fog;
    }
    DrawTriangleFan(count - 2);
}

void CssRendererStandard::DrawTriangleFan(int count)
{
    for (int i = 0; i < count; ++i)
        raster->DrawTriangleFast(projected, &projected[i + 1], &projected[i + 2]);
}

static int trim(int positive)
{
    unsigned n = (unsigned)positive;
    if (!n)
        return 0;
    int k = 0;
    while (n >= OrientationOperandLimit) {
        n >>= 1;
        ++k;
    }
    return k;
}
static int orientation(const SssLitVertex v[3])
{
    int x = 0, y = 0, w = 0;
    for (int i = 0; i < 3; ++i) {
        x = std::max<int>(x, abs(v[i].clip_position->x));
        y = std::max<int>(y, abs(v[i].clip_position->y));
        w = std::max(w, abs(static_cast<int>(v[i].clip_w)));
    }
    x = trim(x);
    y = trim(y);
    int edge[3], m = 0;
    for (int i = 0; i < 3; ++i) {
        const auto &a = *v[i].clip_position, &b = *v[(i + 1) % 3].clip_position;
        edge[i] = (a.y >> y) * (b.x >> x) - (a.x >> x) * (b.y >> y);
        m = std::max(m, abs(edge[i]));
    }
    if (v[0].clip_w == v[1].clip_w && v[0].clip_w == v[2].clip_w)
        return edge[0] + edge[1] + edge[2];
    m = trim(m);
    w = trim(w);
    return (edge[0] >> m) * (v[2].clip_w >> w) + (edge[1] >> m) * (v[0].clip_w >> w) +
           (edge[2] >> m) * (v[1].clip_w >> w);
}

void CssRendererStandard::RenderVerticesScope(const CssVertexBuffer *vertices, CssIndexBuffer *indices,
                                              CssAppearance *appearance, int scope)
{
    uint32_t default_color = vertices->GetDefaultColor();
    uint8_t component_alpha = 0;
    int opacity256 = 0;
    vertex_color = vertices->colors && vertices->colors->count > 0;
    if (vertex_color) {
        colors = static_cast<const uint8_t *>(vertices->colors->bytes.data);
        color_components = vertices->colors->components;
        component_alpha = saturatingTruncate(opacity * 255 + .5f);
        opacity256 = saturatingTruncate(opacity * 256.0f + .5f);
    }

    const auto *fog = appearance->fog;
    if (fog)
        fog_color.SetPackedRGBA8(fog->GetColor());
    raster->SetFog(fog);
    const auto *material = appearance->material;
    CssColor ambient_surface;
    if (material && !material->GetbVertexColorTracking()) {
        default_color = material->GetColor(CssMaterial::Diffuse);
        ambient_surface.SetPackedRGBA8(material->GetColor(CssMaterial::Ambient));
    }
    raster->SetCompositingMode(appearance->compositing ? appearance->compositing : default_compositing);
    polygon_flags = appearance->polygon ? appearance->polygon->flags & CssPolygonMode::AllFlags : CssPolygonMode::DefaultFlags;
    texture_units = 0;
    for (int unit = 0; unit < 2; ++unit) {
        auto *texture = appearance->textures[unit];
        const auto *uv = vertices->texcoords[unit];
        texture_enabled[unit] = texture_projective[unit] = false;
        if (texture && texture->GetImage() && uv) {
            const CssMatrix &transform = texture->matTransform();
            texture_projective[unit] = !(transform.flags & MatrixAffineFlag);
            const float *b = vertex_buffer->texture_bias[unit];
            CssVector3D bias{std::clamp(b[0], -100.f, 100.f), std::clamp(b[1], -100.f, 100.f),
                             std::clamp(b[2], -100.f, 100.f)};
            texcoords[unit].Initialize(uv, transform, std::min(vertex_buffer->texture_scale[unit], 100.f), bias, nullptr);
            texture_units = unit + 1;
            texture_enabled[unit] = true;
        }
        raster->SetTexture(unit, texture, polygon_flags);
    }

    CssColor ambient_light;
    bool directional = false;
    if (material)
        for (int i = 0; i < active_lights.size; ++i)
            directional |= active_lights[i].SetSurfaceParameters(material, polygon_flags, scope, &ambient_light);
    ambient_surface *= ambient_light;
    shade_normals = directional && vertex_buffer->normals;
    if (shade_normals) {
        if (!normal_transform_valid) {
            normal_transform = model_view;
            normal_transform.m[12] = normal_transform.m[13] = normal_transform.m[14] = 0;
            normal_transform.InverseTranspose();
            float largest = 0;
            for (int i = 0; i < 3; ++i)
                for (int j = 0; j < 3; ++j)
                    largest = std::max(largest, std::abs(normal_transform.m[4 * i + j]));
            if (!nearZero(largest)) {
                normal_transform.Scale(1 / largest);
            }
            normal_transform_valid = true;
        }
        const float *b = vertex_buffer->normal_bias;
        normals.Initialize(vertex_buffer->normals, normal_transform, vertex_buffer->normal_scale,
                           {b[0], b[1], b[2]}, nullptr);
    }

    auto &strips = *static_cast<CssTriangleStripArray *>(indices);
    const auto *explicit_indices = strips.implicit ? nullptr : static_cast<const uint16_t *>(strips.indices.data);
    int base = explicit_indices ? 0 : strips.first;
    SssProjectedVertex screen[3];
    SssTLTexCoordsStd uv[3][2];
    int ids[3];
    for (int strip = 0; strip < strips.lengths.size; ++strip) {
        const int count = strips.lengths[strip];
        int previous_face = 0;
        for (int j = 0; j < count; ++j) {
            int slot = j % 3;
            int index = explicit_indices ? explicit_indices[base + j] : base + j;
            ids[slot] = index;
            auto &incoming = lit_vertices[slot];
            incoming.lit = incoming.have_position = incoming.have_eye = incoming.projected = false;
            incoming.clip_flags = clip_flags[index];
            if (j < 2) {
                positions.GetVector4D(index, &incoming.clip_position, &incoming.clip_w);
                incoming.have_position = true;
                continue;
            }
            if (explicit_indices && (ids[0] == ids[1] || ids[0] == ids[2] || ids[1] == ids[2]))
                continue;
            clip_planes = lit_vertices[0].clip_flags | lit_vertices[1].clip_flags | lit_vertices[2].clip_flags;
            bool clipped = clip_union && clip_planes;
            if (clipped && (lit_vertices[0].clip_flags & lit_vertices[1].clip_flags & lit_vertices[2].clip_flags))
                continue;
            for (int i = 0; i < 3; ++i) {
                auto &v = lit_vertices[i];
                if (!v.have_position) {
                    positions.GetVector4D(ids[i], &v.clip_position, &v.clip_w);
                    v.have_position = true;
                }
            }
            int sign = orientation(lit_vertices);
            bool flip = ((j & 1) != 0) ^ ((polygon_flags & CssPolygonMode::ClockwiseWinding) != 0);
            int face = flip ? -sign : sign;
            if (!face || ((polygon_flags & CssPolygonMode::BackFaceCulling) && face >= 0) || ((polygon_flags & CssPolygonMode::FrontFaceCulling) && face <= 0))
                continue;
            if ((previous_face ^ face) < 0)
                for (auto &v : lit_vertices)
                    v.projected = v.lit = false;
            previous_face = face;

            for (int i = 0; i < 3; ++i) {
                auto &v = lit_vertices[i];
                if (v.lit)
                    continue;
                if (shade_normals)
                    v.normal = normals.GetNormalisedVector3D(ids[i]);
                auto set_color = [&](CssColor &color, bool tracking) {
                    if (tracking && vertex_color) {
                        const uint8_t *c = colors + ids[i] * color_components;
                        color.SetRGB8(c[0], c[1], c[2]);
                        v.alpha = color_components == 3 ? component_alpha : (opacity256 * c[3]) >> 8;
                    } else {
                        color.SetPackedRGBA8(default_color);
                        v.alpha = saturatingTruncate(static_cast<float>(default_color >> 24) * opacity);
                    }
                };
                auto get_eye = [&]() {
                    if (!v.have_eye) {
                        const CssFixedVector3D *p;
                        eye_positions.GetShiftedVector4D(ids[i], &p, &v.eye_w, &v.w_shift);
                        v.eye = *p;
                        v.have_eye = true;
                    }
                };
                if (material) {
                    v.color.SetPackedRGBA8(material->GetColor(CssMaterial::Emissive));
                    v.specular.SetPackedRGBA8(material->GetColor(CssMaterial::Specular));
                    set_color(v.diffuse, material->GetbVertexColorTracking());
                    if (material->GetbVertexColorTracking()) {
                        CssColor ambient = ambient_light;
                        ambient *= v.diffuse;
                        v.color += ambient;
                    } else {
                        v.color += ambient_surface;
                    }
                    if (shade_normals) {
                        get_eye();
                        for (int light = active_lights.size - 1; light >= 0; --light)
                            active_lights[light].LightVertex(&v, face >= 0 && (polygon_flags & CssPolygonMode::TwoSidedLighting));
                    }
                    v.color.Clamp();
                } else {
                    set_color(v.color, true);
                }

                v.fog = 0;
                if (fog && fog->GetMode() != SWV_FOG_NONE) {
                    get_eye();
                    float eye_w = static_cast<float>(v.eye_w) / 65536.0f;
                    float distance = std::ldexp(static_cast<float>(-v.eye.z), v.w_shift - 16);
                    float fraction = fog_fraction(fog, distance, eye_w);
                    if (texture_units) {
                        v.fog = std::clamp(saturatingTruncate(fraction * 255), 0, 255);
                    } else {
                        CssColor delta = v.color;
                        delta -= fog_color;
                        delta *= fraction;
                        v.color -= delta;
                    }
                }
                v.lit = true;
            }

            auto write_color = [](SssProjectedVertex &out, const SssLitVertex &v) {
                out.rgb[0] = v.color.RedInt();
                out.rgb[1] = v.color.GreenInt();
                out.rgb[2] = v.color.BlueInt();
                out.alpha = v.alpha;
                out.fog = v.fog;
            };
            if (polygon_flags & CssPolygonMode::FlatShading) {
                for (int i = 0; i < 3; ++i) {
                    if (i == slot)
                        continue;
                    auto &v = lit_vertices[i];
                    v.color = incoming.color;
                    v.fog = incoming.fog;
                    if (v.projected)
                        write_color(screen[i], v);
                }
            }
            for (int unit = texture_units - 1; unit >= 0; --unit)
                if (texture_enabled[unit])
                    for (int i = 0; i < 3; ++i) {
                        const auto &t = *texcoords[unit].GetProjectedVector2D(ids[i]);
                        uv[i][unit].s = t.x;
                        uv[i][unit].t = t.y;
                        uv[i][unit].r = t.z;
                    }

            int first = sign > 0, second = !first;
            if (clipped) {
                clipped_vertices.SetSize(3);
                clipped_vertices[0].SetPosition(lit_vertices[first], uv[first], texture_units);
                clipped_vertices[1].SetPosition(lit_vertices[second], uv[second], texture_units);
                clipped_vertices[2].SetPosition(lit_vertices[2], uv[2], texture_units);
                DrawClippedTriangle();
            } else {
                for (int i = 0; i < 3; ++i) {
                    auto &v = lit_vertices[i];
                    if (!v.projected) {
                        std::copy_n(uv[i], texture_units, screen[i].tex);
                        SwvFixedWord reciprocal;
                        v.divided_position = positions.DivideByW(ids[i], &reciprocal);
                        ProjectVertex(&screen[i], v.divided_position, reciprocal);
                        write_color(screen[i], v);
                        v.projected = true;
                    }
                }
                raster->DrawTriangleFast(&screen[first], &screen[second], &screen[2]);
            }
        }
        base += count;
    }
}

void CssRendererStandard::RenderVertices(CssVertexBuffer *vertices, CssIndexBuffer *indices,
                                         CssAppearance *appearance, CssTransform *model, int scope)
{
    if (empty_projection || !vertices || !appearance)
        return;
    if (graphics->dirty)
        graphics->UpdateIntersection();
    if (!graphics->drawable)
        return;
    if (!vertices->positions || vertices->count <= indices->max_index)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    vertex_buffer = vertices;
    ClearCache();
    depth_scale = toFixed16(graphics->DepthRangeFar() - graphics->DepthRangeNear());
    depth_bias = static_cast<int>(graphics->DepthRangeNear() * (4095.0f * 65536.0f));
    opacity = 1;
    TransformAndClipVertices(model ? model->GetMatrix() : *swv_identity_matrix());
    if (!clip_intersection)
        RenderVerticesScope(vertices, indices, appearance, scope);
}

using QueuedState = CssRendererStandard::SssQueuedState;

static bool transparent(const CssMesh &mesh, const CssAppearance &appearance, int blending, float alpha)
{
    if (blending == SWV_BLEND_REPLACE)
        return false;
    if (blending != SWV_BLEND_ALPHA || alpha < 1)
        return true;
    const CssMaterial *material = appearance.GetMaterial();
    if (material && (material->GetColor(CssMaterial::Diffuse) >> 24) != 255)
        return true;
    const CssVertexBuffer *vertices = mesh.GetVertexBuffer();
    const CssVertexArray *colors = vertices->GetColors();
    if ((colors && colors->cEntries() > 0 && colors->cComponents() == 4) ||
        (vertices->GetDefaultColor() >> 24) != 255)
        return true;
    for (int unit = 0; unit < 2; ++unit) {
        const CssTexture2D *texture = appearance.GetTexture(unit);
        if (texture && texture->GetImage()) {
            const auto format = texture->GetImage()->GetFormat();
            if (format == CssImage2D::Alpha || format == CssImage2D::LuminanceAlpha || format == CssImage2D::RGBA)
                return true;
        }
    }
    return false;
}

void CssRendererStandard::AddSortedQueueElement(const CssNode *node, int submesh, int transparent,
                                                 int layer, int &depth_key)
{
    int order = 0;
    if (transparent) {
        if (!depth_key) {
            const CssMatrix &model = node->GetMatrixWorld();
            float z = model.m[12] * view.m[2] + model.m[13] * view.m[6] +
                      model.m[14] * view.m[10] + view.m[14];
            int bits = std::bit_cast<int32_t>(-z) >> 8;
            depth_key = bits < 0 ? 0 : bits > QueueDepthMask ? QueueDepthMask : bits;
        }
        order = QueueDepthMask - depth_key;
    }
    const int key = static_cast<int32_t>((static_cast<unsigned>(layer) << QueueLayerShift) |
                                         (static_cast<unsigned>(transparent) << QueueTransparencyBit) | (order & QueueDepthMask));
    int i = queue.Size();
    queue.SetSizeDoubling(i + 1);
    auto &item = queue[i];
    item.key = key;
    item.submesh = submesh;
    item.alpha = opacity;
    item.node = node;
    int previous = queue_cursor;
    if (!previous || queue[previous].key != key) {
        previous = 0;
        while (queue[previous].next && queue[queue[previous].next].key <= key)
            previous = queue[previous].next;
    }
    item.next = queue[previous].next;
    queue[previous].next = i;
    queue_cursor = i;
}

void CssRendererStandard::RenderSetupScene(const CssNode *root)
{
    opacity = 1;
    queue.SetSize(1);
    queue[0] = {0, 0, 0, 1, nullptr};
    queue_cursor = 0;
    if (!empty_projection)
        RenderSetupSceneRecursive(root);
}

void CssRendererStandard::RenderSetupSceneRecursive(const CssNode *node)
{
    if (!node->GetRenderingEnabled())
        return;
    const float previous_opacity = opacity;
    const float alpha = node->GetAlphaFactor();
    if (alpha != 1)
        opacity *= alpha;
    int depth_key = 0;
    switch (node->Type()) {
    case GroupObject:
    case WorldObject:
        for (const CssNode *child = node->pFirstChild(); child; child = child->pNextSibling())
            RenderSetupSceneRecursive(child);
        break;
    case SkinnedMeshObject: {
        const auto *skin = static_cast<const CssSkinnedMesh *>(node);
        skin->ResetCache();
        if (auto *skeleton = skin->GetSkeleton())
            RenderSetupSceneRecursive(skeleton);
        [[fallthrough]];
    }
    case MeshObject:
    case MorphingMeshObject: {
        const auto *mesh = static_cast<const CssMesh *>(node);
        if (!(mesh->GetScope() & camera_scope) || !mesh->GetVertexBuffer())
            break;
        const int count = mesh->GetIndexBufferCount();
        for (int i = 0; i < count; ++i) {
            const CssAppearance *app = mesh->GetAppearance(i);
            if (!app || !mesh->GetIndexBuffer(i))
                continue;
            const CssCompositingMode *mode = app->GetCompositingMode();
            if (!mode) mode = default_compositing;
            AddSortedQueueElement(node, i, transparent(*mesh, *app, mode->GetBlending(), opacity),
                                  app->GetLayer(), depth_key);
        }
        break;
    }
    case SpriteObject: {
        const auto *sprite = static_cast<const CssSprite *>(node);
        const CssAppearance *app = sprite->GetpAppearance();
        if ((sprite->GetScope() & camera_scope) && app && sprite->GetpImage()) {
            const CssCompositingMode *mode = app->GetCompositingMode();
            if (!mode) mode = default_compositing;
            AddSortedQueueElement(node, 0, mode->GetBlending() != SWV_BLEND_REPLACE, app->GetLayer(), depth_key);
        }
        break;
    }
    }
    opacity = previous_opacity;
}

static bool clip_sprite_texture(int &lo, int &other_lo, int &hi, int &other_hi,
                                SwvFixedWord &start, SwvFixedWord &end)
{
    if ((start < 0 && end < 0) || (start > 65536 && end > 65536))
        return false;
    if (start < 0 || start > 65536) {
        int bound = start < 0 ? 0 : 65536;
        int fraction = g_divide_int64_int64(int64_t(bound - start) * 65536, end - start);
        lo += ((hi - lo) * fraction + 32768) >> 16;
        other_lo = lo;
        start = bound;
    }
    if (end > 65536) {
        int fraction = g_divide_int64_int64(int64_t(65536 - end) * 65536, end - start);
        hi += ((hi - lo) * fraction + 32768) >> 16;
        other_hi = hi;
        end = 65536;
    } else if (end < 0) {
        int fraction = g_divide_int64_int64(int64_t(-end) * 65536, start - end);
        hi -= ((hi - lo) * fraction + 32768) >> 16;
        other_hi = hi;
        end = 0;
    }
    return true;
}

void CssRendererStandard::ProjectSpriteVertex(SssProjectedVertex *out, const CssFixedVector3D *p)
{
    int x = std::clamp<SwvFixedWord>(65536 + p->x, -MaxSpriteCoordinate, MaxSpriteCoordinate);
    int y = std::clamp<SwvFixedWord>(65536 - p->y, -MaxSpriteCoordinate, MaxSpriteCoordinate);
    if (graphics->dirty)
        graphics->UpdateIntersection();
    out->x = ((int64_t(viewport_scale[0]) * x) >> 32) + 16 * graphics->relative.x;
    out->y = ((int64_t(viewport_scale[1]) * y) >> 32) + 16 * graphics->relative.y;
    int z = (depth_scale >> 3) * ((p->z + 65536) >> 2) + depth_bias;
    out->z = std::clamp(z, 0, MaxProjectedDepth);
    out->tex[0].q = 65536;
}

void CssRendererStandard::RenderSprite(const CssSprite *s)
{
    auto *g = graphics;
    auto *app = s->appearance;
    auto *im = s->image;
    if (!app || s->width == 0 || s->height == 0)
        return;
    for (int i = 0; i < 2; ++i)
        texture_enabled[i] = texture_projective[i] = false;
    texture_units = 1;
    auto *r = raster;
    r->SetCompositingMode(app->compositing ? app->compositing : default_compositing);
    polygon_flags = CssPolygonMode::DefaultFlags;
    r->SetSpriteImage(im, im->GetpAlpha() && opacity < 1 ? CssTexture2D::Modulate : CssTexture2D::Replace);
    CssMatrix full = view_projection;
    full *= s->GetMatrixWorld();
    if (nearZero(full.m[15]))
        return;
    CssVector3D origin{full.m[12], full.m[13], full.m[14]};
    if (!nearZero(full.m[15] - 1)) {
        float reciprocal = 1 / full.m[15];
        origin.x *= reciprocal;
        origin.y *= reciprocal;
        origin.z *= reciprocal;
    }
    CssFixedVector3D center{toFixed16(origin.x), toFixed16(origin.y), toFixed16(origin.z)};
    if (center.z < -65536 || center.z > 65536)
        return;
    auto *corners = projected;
    ProjectSpriteVertex(&corners[0], &center);
    corners[0].alpha = opacity < 1 ? static_cast<int>(255 * opacity) : 255;
    for (int i = 1; i < 4; ++i)
        corners[i] = corners[0];
    CssMatrix eye;
    if (s->isScaled()) {
        eye = view;
        eye *= s->GetMatrixWorld();
        CssVector3D origin_eye{eye.m[12], eye.m[13], eye.m[14]};
        CssVector3D right{eye.m[0], eye.m[1], eye.m[2]};
        CssVector3D down{eye.m[4], eye.m[5], eye.m[6]};
        if (!(eye.flags & MatrixAffineFlag)) {
            float w = eye.m[15], reciprocal = 1 / w;
            for (int i = 0; i < 3; ++i) {
                right[i] += origin_eye[i];
                down[i] += origin_eye[i];
                origin_eye[i] *= reciprocal;
            }
            float right_w = w + eye.m[3];
            if (right_w != w)
                reciprocal = 1 / right_w;
            for (int i = 0; i < 3; ++i)
                right[i] = right[i] * reciprocal - origin_eye[i];
            float down_w = w + eye.m[7];
            if (down_w != right_w)
                reciprocal = 1 / down_w;
            for (int i = 0; i < 3; ++i)
                down[i] = down[i] * reciprocal - origin_eye[i];
        }
        auto length = [](const CssVector3D &v) { return std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z); };
        right = {origin_eye.x + length(right), origin_eye.y, origin_eye.z};
        down = {origin_eye.x, origin_eye.y - length(down), origin_eye.z};
        auto project = [&](CssVector3D v, SssProjectedVertex &corner) {
            if (camera_type == CssCamera::Parallel || camera_type == CssCamera::Perspective) {
                float w = camera_type == CssCamera::Parallel ? projection.m[15] : v.z * projection.m[11];
                v = {v.x * projection.m[0], v.y * projection.m[5], v.z * projection.m[10] + projection.m[14]};
                if (!nearZero(w - 1) && !nearZero(w)) {
                    float reciprocal = 1 / w;
                    v.x *= reciprocal;
                    v.y *= reciprocal;
                    v.z *= reciprocal;
                }
            } else
                v = projection.Transform4Dto3D(v, 1);
            CssFixedVector3D p{toFixed16(v.x), toFixed16(v.y), toFixed16(v.z)};
            ProjectSpriteVertex(&corner, &p);
        };
        project(origin_eye, corners[0]);
        project(down, corners[1]);
        project(right, corners[2]);
        if (corners[2].y != corners[0].y) {
            float dx = corners[2].x - corners[0].x, dy = corners[2].y - corners[0].y;
            corners[2].x = corners[0].x + saturatingTruncate(std::sqrt(dx * dx + dy * dy));
            corners[2].y = corners[0].y;
        }
        if (corners[1].x != corners[0].x) {
            float dx = corners[1].x - corners[0].x, dy = corners[1].y - corners[0].y;
            corners[1].x = corners[0].x;
            corners[1].y = corners[0].y + saturatingTruncate(std::sqrt(dx * dx + dy * dy));
        }
        corners[3] = corners[1];
        corners[3].x = corners[2].x;
    } else {
        corners[2].x += std::abs(int64_t(saturatingTruncate(s->width * 16.0f)));
        corners[1].y += std::abs(int64_t(saturatingTruncate(s->height * 16.0f)));
        corners[3].x = corners[2].x;
        corners[3].y = corners[1].y;
    }
    int width = corners[2].x - corners[0].x, height = corners[1].y - corners[0].y;
    if (!(width >> 4) || !(height >> 4))
        return;
    for (int i = 0; i < 4; ++i) {
        corners[i].x = (corners[i].x - (width >> 1)) & ~15;
        corners[i].y = (corners[i].y - (height >> 1)) & ~15;
    }
    int left = 16 * g->relative.x, right = left + 16 * g->visible.w;
    int top = 16 * g->relative.y, bottom = top + 16 * g->visible.h;
    if (corners[2].x < left || corners[0].x > right || corners[1].y < top || corners[0].y > bottom)
        return;
    if (app->fog && app->fog->GetMode() != SWV_FOG_NONE) {
        fog_color.SetPackedRGBA8(app->fog->GetColor());
        r->SetFog(app->fog);
        if (eye.flags == MatrixIdentityFlag) {
            eye = view;
            eye *= s->GetMatrixWorld();
        }
        float fog = fog_fraction(app->fog, -eye.m[14], eye.m[15]);
        for (int i = 0; i < 4; ++i)
            corners[i].fog = std::clamp(saturatingTruncate(fog * 255), 0, 255);
    } else
        r->SetFog(nullptr);

    for (int i = 0; i < 4; ++i) {
        corners[i].tex[0].q = corners[i].tex[1].q = 32768;
        corners[i].rgb[0] = corners[i].rgb[1] = corners[i].rgb[2] = 65280;
    }
    SwvFixedWord s0, t0, s1, t1;
    s->CalcCropRectangle(s0, t0, s1, t1);
    if (!clip_sprite_texture(corners[0].x, corners[1].x, corners[2].x, corners[3].x, s0, s1) ||
        !clip_sprite_texture(corners[0].y, corners[2].y, corners[1].y, corners[3].y, t0, t1))
        return;
    width = (corners[2].x - corners[0].x) >> 4;
    height = (corners[1].y - corners[0].y) >> 4;
    if (!width || !height)
        return;
    SwvFixedWord ds = g_divide_int32_int32(s1 - s0, width) >> 1;
    SwvFixedWord dt = g_divide_int32_int32(t1 - t0, height) >> 1;
    s0 += ds;
    s1 += ds;
    t0 += dt;
    t1 += dt;
    int &x0 = corners[0].x, &x1 = corners[2].x, &y0 = corners[0].y, &y1 = corners[1].y;
    if (x0 < left) {
        s0 -= g_divide_int32_int32((x0 - left) * (s1 - s0), x1 - x0);
        corners[1].x = x0 = left;
    }
    if (y0 < top) {
        t0 -= g_divide_int32_int32((y0 - top) * (t1 - t0), y1 - y0);
        corners[2].y = y0 = top;
    }
    if (x1 > right) {
        s1 += g_divide_int32_int32((right - x1) * (s1 - s0), x1 - x0);
        corners[3].x = x1 = right;
    }
    if (y1 > bottom) {
        t1 += g_divide_int32_int32((bottom - y1) * (t1 - t0), y1 - y0);
        corners[3].y = y1 = bottom;
    }
    corners[0].tex[0].s = corners[1].tex[0].s = s0;
    corners[2].tex[0].s = corners[3].tex[0].s = s1;
    corners[0].tex[0].t = corners[2].tex[0].t = t0;
    corners[1].tex[0].t = corners[3].tex[0].t = t1;
    r->DrawSprite(s->scaled, corners, corners + 1, corners + 2, corners + 3);
}
void CssRendererStandard::RenderNode(const CssNode *scene, const CssTransform *model)
{
    if (empty_projection)
        return;
    if (graphics->dirty)
        graphics->UpdateIntersection();
    if (!graphics->drawable)
        return;
    opacity = 1;
    scene->SetWorldMatrixCache(model ? model->GetMatrix() : *swv_identity_matrix());
    RenderSetupScene(scene);
    RenderStateQueue();
    scene->SetWorldMatrixCacheDirty();
}

void CssRendererStandard::RenderStateQueue()
{
    ClearCache();
    depth_scale = toFixed16(graphics->DepthRangeFar() - graphics->DepthRangeNear());
    depth_bias = static_cast<int>(graphics->DepthRangeNear() * (4095.0f * 65536.0f));
    const CssMesh *previous_mesh = nullptr;
    for (int i = queue[0].next; i; i = queue[i].next) {
        const QueuedState &item = queue[i];
        const CssNode *node = item.node;
        int kind = node->Type();
        opacity = item.alpha;
        if (kind == SpriteObject)
            RenderSprite(static_cast<const CssSprite *>(node));
        else if (kind == MeshObject || kind == MorphingMeshObject || kind == SkinnedMeshObject) {
            const auto *mesh = static_cast<const CssMesh *>(node);
            vertex_buffer = mesh->GetRenderingVertexBuffer(nonambient_lights);
            auto *index = mesh->GetIndexBuffer(item.submesh);
            if (vertex_buffer->GetVertexCount() <= index->GetMaxIndex())
                g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
            auto *appearance = mesh->GetAppearance(item.submesh);
            if (kind == SkinnedMeshObject) {
                const auto *skin = static_cast<const CssSkinnedMesh *>(mesh);
                skin->GetRenderingVertexBuffer(false);
                skin->SetScaleBias(1, {0, 0, 0});
                if (vertex_buffer->GetVertexCount() <= skin->GetMaxIndex())
                    g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
                positions.SetSkinnedMesh(skin);
                eye_positions.SetSkinnedMesh(skin);
                normals.SetSkinnedMesh(skin);
            }
            if (mesh != previous_mesh) {
                TransformAndClipVertices(mesh->GetMatrixWorld());
                previous_mesh = mesh;
            }
            if (!clip_intersection)
                RenderVerticesScope(vertex_buffer, index, appearance, node->GetScope());
            positions.SetSkinnedMesh(nullptr);
            eye_positions.SetSkinnedMesh(nullptr);
            normals.SetSkinnedMesh(nullptr);
        }
    }
}

struct BackgroundAxis {
    int position, length, start, step;
};

static BackgroundAxis map_background_axis(float origin, float size, int position, int length,
                                          int extent, int mode, int limit, bool clipped)
{
    int step = toFixed16(size) / length;
    if (mode == CssBackground::Border) {
        float end = origin + size;
        if (end < 0 || origin >= extent || size == 0) {
            origin = extent;
            position += length;
            length = 0;
        } else {
            if (origin < 0) {
                int skip = saturatingTruncate(length * (-origin / size));
                position += skip;
                length -= skip;
                origin = 0;
                size = end;
            }
            end = origin + size;
            if (end >= extent)
                length = saturatingTruncate(length - length * ((end - extent) / size));
        }
    }
    int start = toFixed16(std::clamp(origin, -32767.f, 32767.f));
    if (clipped) {
        if (position < 0) {
            start -= step * position;
            length += position;
            position = 0;
        }
        length = std::min(length, limit - position);
    }
    start %= extent << 16;
    if (start < 0)
        start += extent << 16;
    return {position, length, start, step};
}

void CssRendererStandard::ClearZBuffer()
{
    swvMemSet(pZbuffer(), 255, graphics->Width() * graphics->Height() * sizeof(uint16_t));
}

void CssRendererStandard::ClearZBufferRect(int x, int y, int width, int height)
{
    auto *out = pZbuffer() + y * graphics->Width() + x;
    for (int row = 0; row < height; ++row, out += graphics->Width())
        swvMemSet(out, 255, width * sizeof(uint16_t));
}

void CssRendererStandard::CopyZRect(int x, int y, int width, int height, int s, int t, int ds, int dt,
                                    int pitch, int source_width, int source_height)
{
    auto *out = pZbuffer() + y * pitch + x;
    for (int row = 0; row < height; ++row, out += pitch) {
        auto *src = stage_values + (t >> 16) * static_cast<int16_t>(source_width);
        if (ds == 65536) {
            swvMemCpy(out, src + (s >> 16), width * sizeof(uint16_t));
        } else {
            int u = s;
            for (int col = 0; col < width; ++col) {
                out[col] = src[u >> 16];
                u += ds;
                if (u >= source_width * 65536)
                    u -= source_width * 65536;
            }
        }
        t += dt;
        if (t >= source_height * 65536)
            t -= source_height * 65536;
    }
}

CssRendererStandard *CssRendererStandard::Create()
{
    auto *renderer = new CssRendererStandard;
    CssCleanupStackManager::Push(renderer);
    renderer->Construct();
    CssCleanupStackManager::Pop(renderer);
    return renderer;
}

CssRendererStandard::CssRendererStandard() = default;

void CssRendererStandard::Construct()
{
    raster = new CssRasterizerStandard;
    raster->Construct();
    default_compositing = static_cast<CssCompositingMode *>(CssCompositingMode::FactoryCreate());
    view.Identity();
    view_projection.Identity();
    projection.Identity();
}

CssRendererStandard::~CssRendererStandard()
{
    delete raster;
    delete default_compositing;
}

uint16_t *CssRendererStandard::pZbuffer()
{
    if (graphics && graphics->stage_depth)
        return graphics->stage_depth;
    return depth.size ? static_cast<uint16_t *>(depth.data) : nullptr;
}

void CssRendererStandard::SetpBackBuffer(CssGraphics3D *target)
{
    graphics = target;
    depth.SetSize(target->stage_depth ? 0 : target->crop.w * target->crop.h);
    raster->SetupBackBuffer(reinterpret_cast<uint16_t *>(target->pixels), target->crop.w,
                            target->crop.h, target->pitch, pZbuffer(), target->depth_enabled);
    raster->SetupAlphaBuffer(target->alpha, target->alpha_pitch);
    raster->SetHints(target->depth_enabled);
}

void CssRendererStandard::SetViewport(int, int, int width, int height)
{
    viewport_scale[0] = width << 19;
    viewport_scale[1] = height << 19;
}

void CssRendererStandard::UpdatepBackBuffer(CssGraphics3D *)
{
    raster->UpdateBackBuffer(reinterpret_cast<uint16_t *>(graphics->pixels));
}

void CssRendererStandard::ClearBackgroundAndZBuffer(CssBackground *background, const CssCamera *camera_object)
{
    auto &g = *graphics;
    if (g.dirty)
        g.UpdateIntersection();
    if (!g.drawable)
        return;

    auto area = g.visible;
    area.x -= g.crop.x;
    area.y -= g.crop.y;
    int pitch = g.Pitch();
    auto *pixels = reinterpret_cast<uint8_t *>(g.pPixels());
    auto fill_alpha = [&](uint8_t alpha) {
        if (g.alpha) {
            auto *row = g.alpha + area.y * g.alpha_pitch + area.x;
            for (int i = 0; i < area.h; ++i, row += g.alpha_pitch)
                swvMemSet(row, alpha, area.w);
        }
    };
    if (!background) {
        auto *row = pixels + area.y * pitch + area.x * sizeof(uint16_t);
        for (int i = 0; i < area.h; ++i, row += pitch)
            swvMemSet(row, 0, area.w * sizeof(uint16_t));
        fill_alpha(0);
        ClearZBuffer();
        return;
    }

    bool color = background->GetbColorClear(), depth = background->GetbDepthClear();
    auto *image = background->image;
    bool stage = depth && camera_object && !empty_projection && image && image->Type() == StagesetObject;
    if (!color && !stage) {
        if (depth)
            ClearZBuffer();
        return;
    }
    if (!image) {
        unsigned argb = background->GetColor();
        auto *first = reinterpret_cast<uint16_t *>(pixels + area.y * pitch) + area.x;
        std::fill_n(first, area.w, CssColor(argb).GetPixel());
        auto *row = reinterpret_cast<uint8_t *>(first);
        for (int i = 1; i < area.h; ++i) {
            row += pitch;
            swvMemCpy(row, first, area.w * sizeof(uint16_t));
        }
        fill_alpha(argb >> 24);
        if (depth) ClearZBuffer();
        return;
    }

    auto &viewport = g.relative;
    auto prepare_depth = [&] {
        auto *stageset = static_cast<CssStageset *>(image);
        stageset->Rescale(camera_object);
        stage_values = stageset->GetZData();
    };
    if (!image->GetpPalette() && image->GetHeight() == g.Height() && image->GetWidth() == g.Width() &&
        background->GetImageCropX() == 0 && background->GetImageCropY() == 0 &&
        background->GetImageCropWidth() == image->GetWidth() && background->GetImageCropHeight() == image->GetHeight() &&
        viewport.x == 0 && viewport.y == 0 && viewport.w == g.Width() && viewport.h == g.Height() &&
        image->GetFormat() == CssImage2D::RGB && pitch == int(sizeof(uint16_t)) * g.Width()) {
        if (color)
            swvMemCpy(pixels, image->GetpPixels(), pitch * g.Height());
        if (stage) {
            prepare_depth();
            swvMemCpy(pZbuffer(), stage_values, g.Width() * g.Height() * sizeof(uint16_t));
        } else if (depth) {
            ClearZBuffer();
        }
        return;
    }

    auto x = map_background_axis(background->GetImageCropXReal(), background->GetImageCropWidthReal(),
                                 viewport.x, viewport.w, image->GetWidth(), background->GetImageModeX(),
                                 g.Width(), g.clipped);
    auto y = map_background_axis(background->GetImageCropYReal(), background->GetImageCropHeightReal(),
                                 viewport.y, viewport.h, image->GetHeight(), background->GetImageModeY(),
                                 g.Height(), g.clipped);
    int right = x.position + x.length, bottom = y.position + y.length;
    int area_right = area.x + area.w, area_bottom = area.y + area.h;
    bool intersects = x.position < area_right && right > area.x && y.position < area_bottom && bottom > area.y;
    auto fill_borders = [&](auto fill) {
        if (y.position > area.y) fill(area.x, area.y, area.w, y.position - area.y);
        if (bottom < area_bottom) fill(area.x, bottom, area.w, area_bottom - bottom);
        if (x.position > area.x) fill(area.x, y.position, x.position - area.x, y.length);
        if (right < area_right) fill(right, y.position, area_right - right, y.length);
    };
    if (color) {
        unsigned argb = background->GetColor();
        auto pixel = CssColor(argb).GetPixel();
        auto fill = [&](int left, int top, int w, int h) { raster->FillRect(left, top, w, h, pixel, argb >> 24); };
        if (intersects) {
            fill_borders(fill);
            raster->SetSpriteImage(image, CssTexture2D::Replace);
            raster->TexRect(x.position, y.position, x.length, y.length, x.start, y.start, x.step, y.step);
        } else {
            fill(area.x, area.y, area.w, area.h);
        }
    }
    if (stage) {
        if (intersects) {
            fill_borders([&](int left, int top, int w, int h) { ClearZBufferRect(left, top, w, h); });
            prepare_depth();
            CopyZRect(x.position, y.position, x.length, y.length, x.start, y.start, x.step, y.step,
                      g.Width(), image->GetWidth(), image->GetHeight());
            return;
        }
        ClearZBuffer();
    }
    if (depth)
        ClearZBuffer();
}

void CssRendererStandard::SetCamera(const CssCamera *camera_object, const CssMatrix *transform)
{
    if (!camera_object)
        return;
    view = transform ? *transform : camera_object->GetMatrixWorld();
    CssVector3D position = view * CssVector3D{};
    camera_position[0] = position.x;
    camera_position[1] = position.y;
    camera_position[2] = position.z;
    if (!view.Invert())
        g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
    camera_scope = camera_object->GetScope();
    camera_type = camera_object->GetProjectionType();
    empty_projection = (camera_type == CssCamera::Parallel || camera_type == CssCamera::Perspective) && camera_object->GetNear() == camera_object->GetFar();
    if (!empty_projection)
        projection = camera_object->GetMatrix();
    view_projection = projection;
    view_projection *= view;
}

void CssRendererStandard::RenderWorld(const CssWorld *world_object)
{
    if (graphics->dirty)
        graphics->UpdateIntersection();
    if (!graphics->drawable)
        return;
    const auto *camera = world_object->camera;
    if (!camera || camera->Type() != CameraObject || !camera->IsDescendantOf(world_object))
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    auto *background = world_object->background;
    if (background && background->image &&
        background->image->GetFormat() != (graphics->alpha ? CssImage2D::RGBA : CssImage2D::RGB))
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    if (camera->GetProjectionType() != CssCamera::Generic && camera->GetNear() == camera->GetFar())
        return;
    world = world_object;
    SetCamera(camera, nullptr);
    ClearBackgroundAndZBuffer(background, camera);
    SetLights(world_object->GetapLights().Size(), world_object->GetapLights().Pointer(), nullptr);
    RenderSetupScene(world_object);
    RenderStateQueue();
}

void CssRendererStandard::SetLights(int count, const CssLight *const *lights,
                                    const CssMatrix *transforms)
{
    if (active_lights.size)
        std::memset(active_lights.data, 0, active_lights.size * sizeof(CssActiveLightStandard));
    active_lights.SetSize(0);
    active_lights.Reserve(count);
    nonambient_lights = false;
    for (int i = 0; i < count; ++i) {
        const CssLight *light = lights[i];
        if (!light)
            continue;
        if (light->mode != SWV_LIGHT_AMBIENT)
            nonambient_lights = true;
        CssMatrix transform = view;
        transform *= transforms ? transforms[i] : light->GetMatrixWorld();
        RenderLight(*light, transform);
    }
}

void CssRendererStandard::RenderLight(const CssLight &light, const CssMatrix &transform)
{
    if (!active_lights.append().Initialize(light, transform))
        --active_lights.size;
}
