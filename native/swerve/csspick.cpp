#include "geometry_class.hpp"
#include "image_class.hpp"
#include "math_pick.h"
#include "cssstatics.hpp"
#include "cssobjectfactory.hpp"
#include "platform.h"

#include "object_classes.hpp"
#include "cssfixed1616.hpp"
#include <new>
#include <cmath>

void CssPickData::Initialize()
{
    g_Statics().pick_data = new CssPickData;
}

CssPickData *CssPickData::GetInstance()
{
    if (!g_Statics().pick_data) Initialize();
    return g_Statics().pick_data;
}

void CssPickData::Uninitialize()
{
    if (CssStatics *statics = g_pStaticsNoLeave()) {
        delete statics->pick_data;
        statics->pick_data = nullptr;
    }
}

void CssPick::PushInternalState(CssPickData *data)
{
    data->saved.items.Append(data->ray);
}

void CssPick::PopInternalState(CssPickData *data)
{
    int top = data->saved.items.size - 1;
    data->ray = data->saved.items[top];
    data->saved.items.SetSize(top);
}

void CssPick::TransformRay(CssPickData *data, const CssMatrix &matrix)
{
    data->ray.start = matrix * data->ray.start;
    data->ray.end = matrix * data->ray.end;
}

void CssPick::PickNode(CssPickData *data, const CssNode *node)
{
    while (node && node->GetPickingEnabled()) {
        switch (node->Type()) {
        case GroupObject:
        case WorldObject:
            for (CssNode *child = node->pFirstChild(); child; child = child->pNextSibling()) {
                PushInternalState(data);
                CssMatrix inverse = child->GetCompositeMatrix();
                if (!inverse.Invert())
                    g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
                TransformRay(data, inverse);
                PickNode(data, child);
                PopInternalState(data);
            }
            return;
        case MeshObject:
        case MorphingMeshObject:
            PickMesh(data, static_cast<const CssMesh *>(node));
            return;
        case SkinnedMeshObject:
            PickMesh(data, static_cast<const CssMesh *>(node));
            node = node->pFirstChild();
            break;
        case SpriteObject:
            PickSprite(data, static_cast<const CssSprite *>(node));
            return;
        default:
            return;
        }
    }
}

/* Positions are already relative to the ray origin. u and v weight the
 * first two vertices. The third vertex supplies the interpolation origin. */
bool CssPick::TriangleHit(const CssVector3D &ray, const CssVector3D &v0, const CssVector3D &v1,
                          const CssVector3D &v2, int flags, float *distance, float *u, float *v)
{
    CssVector3D a = v0 - v2;
    CssVector3D b = v1 - v2;
    CssVector3D h = ray % b;
    float det = a * h;
    if (std::abs(det) < realEpsilon || (det > 0 && (flags & CssPolygonMode::FrontFaceCulling)) || (det < 0 && (flags & CssPolygonMode::BackFaceCulling)))
        return 0;
    CssVector3D origin{-v2.x, -v2.y, -v2.z};
    float first = origin * h;
    if (det > 0 && (first < 0 || first > det))
        return 0;
    if (det < 0 && (first > 0 || first < det))
        return 0;
    CssVector3D q = origin % a;
    float second = ray * q;
    constexpr float BarycentricTolerance = 1.000015f;
    float tolerance = det * BarycentricTolerance;
    float sum = first + second;
    if (det > 0 && (second < 0 || sum > tolerance))
        return 0;
    if (det < 0 && (second > 0 || sum < tolerance))
        return 0;
    float inverse = 1 / det;
    *distance = (b * q) * inverse;
    *u = first * inverse;
    *v = second * inverse;
    return *distance >= 0;
}

static bool pick_bounds(const CssPickData::SssPickRay *ray, const CssVector3D &minimum, const CssVector3D &maximum)
{
    const CssVector3D &start = ray->start;
    int inside = 1;
    float d[3];
    for (int i = 0; i < 3; ++i) {
        inside &= start[i] >= minimum[i] && start[i] <= maximum[i];
        d[i] = ray->end[i] - start[i];
    }
    if (inside)
        return 1;
    for (int i = 2; i >= 0; --i) {
        if (nearZero(d[i]))
            continue;
        float plane = d[i] < 0 ? maximum[i] : minimum[i];
        float t = (plane - start[i]) / d[i];
        if (t < 0)
            continue;
        int hit = 1;
        for (int j = 0; j < 3; ++j) {
            if (i == j)
                continue;
            float point = start[j] + d[j] * t;
            hit &= point >= minimum[j] && point <= maximum[j];
        }
        if (hit)
            return 1;
    }
    return 0;
}

bool CssPick::PickBoundingBox(CssPickData *data, const CssVector3D &minimum, const CssVector3D &maximum) const
{
    return pick_bounds(&data->ray, minimum, maximum);
}

static CssVector3D read_vertex(const CssVertexArray *array, int index, int dimensions)
{
    CssVector3D v;
    for (int i = 0; i < dimensions && i < 3; ++i)
        v[i] = static_cast<float>(array->Element(index, i));
    return v;
}

static float interpolate(float a, float b, float c, float u, float v)
{
    return c + (a - c) * u + (b - c) * v;
}

static void record_triangle(CssRayIntersection *hit, const CssMesh *mesh, int submesh,
                            const CssVertexBuffer *vb, const CssAppearance *app, const int index[3],
                            const CssVector3D p[3], float distance, float u, float v)
{
    hit->SetIntersected(const_cast<CssMesh *>(mesh));
    hit->submesh = submesh;
    hit->distance = distance;
    /* Both stores target unit zero in the ARM routine. Unit one survives
     * the preceding hit when this appearance omits its second texture. */
    hit->s[0] = hit->t[0] = 0;
    for (int unit = 0; unit < 2; ++unit) {
        auto *texture = app->GetTexture(unit);
        const CssVertexArray *coords = vb->texcoords[unit];
        if (!texture || !texture->GetImage() || !coords)
            continue;
        float scale = vb->texture_scale[unit];
        CssMatrix matrix(scale, scale, scale);
        const float *bias = vb->texture_bias[unit];
        matrix.Translate(bias[0], bias[1], bias[2]);
        matrix.PreMultiply(texture->matTransform());
        CssVector3D st[3];
        float w[3];
        for (int i = 0; i < 3; ++i)
            st[i] = matrix.Transform3Dto4D(read_vertex(coords, index[i], coords->components), &w[i]);
        float divisor = interpolate(w[0], w[1], w[2], u, v);
        hit->s[unit] = interpolate(st[0].x, st[1].x, st[2].x, u, v) / divisor;
        hit->t[unit] = interpolate(st[0].y, st[1].y, st[2].y, u, v) / divisor;
    }
    if (vb->normals) {
        CssVector3D n[3];
        for (int i = 0; i < 3; ++i) {
            n[i] = read_vertex(vb->normals, index[i], 3);
            n[i].Unit();
        }
        for (int i = 0; i < 3; ++i)
            hit->normal[i] = interpolate(n[0][i], n[1][i], n[2][i], u, v);
    } else {
        hit->normal = (p[0] - p[2]) % (p[1] - p[2]);
    }
    hit->normal.Unit();
}

void CssPick::PickMesh(CssPickData *data, const CssMesh *mesh)
{
    if (!(mesh->scope & data->scope))
        return;
    CssVertexBuffer *vb = mesh->Type() == SkinnedMeshObject
        ? static_cast<const CssSkinnedMesh *>(mesh)->GetTransformedVertexBuffer(false)
        : mesh->GetRenderingVertexBuffer(false);
    CssVertexArray *positions = vb->positions;
    if (!positions)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    positions->GetMaxNumber();
    CssVector3D lo, hi, offset;
    for (int i = 0; i < 3; ++i) {
        hi[i] = (float)positions->maximum[i] * vb->position_scale + vb->position_bias[i];
        lo[i] = (float)positions->minimum[i] * vb->position_scale + vb->position_bias[i];
        offset[i] = -vb->position_bias[i];
    }
    if (!PickBoundingBox(data, lo, hi))
        return;
    PushInternalState(data);
    CssMatrix matrix(offset);
    matrix.Scale(1.0f / vb->position_scale);
    TransformRay(data, matrix);
    CssVector3D direction = data->ray.end - data->ray.start;
    for (int part = 0; part < mesh->indices.size; ++part) {
        const auto *app = mesh->GetAppearance(part);
        if (!app)
            continue;
        unsigned flags = app->polygon ? app->polygon->flags & CssPolygonMode::AllFlags : CssPolygonMode::DefaultFlags;
        const auto *strip = static_cast<CssTriangleStripArray *>(mesh->indices[part]);
        if (vb->count <= strip->max_index)
            g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        const uint16_t *indices = strip->implicit ? nullptr : static_cast<const uint16_t *>(strip->indices.data);
        int base = indices ? 0 : strip->first;
        for (int s = 0; s < strip->lengths.size; ++s) {
            int reverse = (flags & CssPolygonMode::ClockwiseWinding) != 0;
            int index[3];
            index[reverse] = indices ? indices[base] : base;
            index[2] = indices ? indices[base + 1] : base + 1;
            CssVector3D p[3];
            for (int k = reverse; k < 3; k += 2 - reverse)
                p[k] = read_vertex(positions, index[k], 3) - data->ray.start;
            int count = strip->lengths[s];
            for (int j = 2; j < count; ++j) {
                int slot = ((j ^ reverse) & 1) == 0;
                index[slot] = index[2];
                index[2] = indices ? indices[base + j] : base + j;
                if (indices &&
                    (index[2] == index[0] || index[2] == index[1] || index[1] == index[0]))
                    continue;
                p[slot] = p[2];
                p[2] = read_vertex(positions, index[2], 3) - data->ray.start;
                float distance, u, v;
                if (TriangleHit(direction, p[0], p[1], p[2], flags, &distance, &u, &v) &&
                    distance < data->hit->distance)
                    record_triangle(data->hit, mesh, part, vb, app, index, p, distance, u, v);
            }
            base += count;
        }
    }
    PopInternalState(data);
}

static void crop_interval(float start, float span, int image_size, int32_t *first, int32_t *last)
{
    int32_t a = toFixed16(start), size = toFixed16(span);
    int32_t b = size > 0 ? a + size : a - size;
    int32_t unit = (int32_t)g_divide_int64_int64(65536, image_size);
    int32_t lo = (int32_t)(((int64_t)unit * a) >> 16);
    int32_t hi = (int32_t)(((int64_t)unit * b) >> 16);
    *first = size > 0 ? lo : hi;
    *last = size > 0 ? hi : lo;
}

static int32_t sample_coordinate(float v, float a, float b, int32_t lo, int32_t hi)
{
    int32_t pos = toFixed16((v - a) / (b - a));
    return lo + ((int64_t(hi - lo) * pos) >> 16);
}

static int sample_visible(const CssSprite *sprite, int32_t u, int32_t v)
{
    const auto *mode = sprite->GetpAppearance()->GetCompositingMode();
    if (!mode || mode->threshold <= 0)
        return 1;
    auto *image = sprite->GetpImage();
    if (image->GetFormat() != CssImage2D::Alpha && image->GetFormat() != CssImage2D::LuminanceAlpha &&
        image->GetFormat() != CssImage2D::RGBA)
        return 1;
    int width = image->GetWidth(), height = image->GetHeight();
    int x = (u * width) >> 16;
    int y = (v * height) >> 16;
    int index = x + width * y;
    if (image->GetpPalette())
        index = static_cast<const uint8_t *>(image->GetpPixels())[index];
    const uint8_t *alpha = image->GetpAlpha();
    return static_cast<int>(mode->threshold * 255) <= alpha[index];
}

static float axis_size(const CssMatrix &matrix, const CssVector3D &origin, int dimension)
{
    CssVector3D axis;
    axis[dimension] = 1;
    return (matrix * axis - origin).Magnitude() * 0.5f;
}

void CssPick::PickSprite(CssPickData *data, const CssSprite *sprite)
{
    if (!data->camera || !(sprite->GetScope() & data->scope) || !sprite->scaled ||
        !sprite->appearance || !sprite->image)
        return;
    if (std::abs(sprite->width) + 0.5f < 1 || std::abs(sprite->height) + 0.5f < 1)
        return;
    CssMatrix view;
    if (!CssNode::BuildTransformMatrix(sprite, data->camera, &view))
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    CssVector3D origin = view.Transform4Dto3D({}, 1);
    const auto &camera_ray = data->saved.items[1];
    float distance = (origin[2] - camera_ray.start[2]) / (camera_ray.end[2] - camera_ray.start[2]);
    if (distance < 0 || !(data->hit->distance > distance))
        return;

    auto *projection = static_cast<CssTransform *>(CssObjectFactory::CreateObject(TransformObject));
    CssCleanupStackManager::Push(projection);
    data->camera->GetProjection(projection);
    float w = axis_size(view, origin, 0), h = axis_size(view, origin, 1);
    CssVector3D tl = projection->matrix.Transform4Dto3D({origin.x - w, origin.y + h, origin.z}, 1);
    CssVector3D br = projection->matrix.Transform4Dto3D({origin.x + w, origin.y - h, origin.z}, 1);
    float x = data->saved.items[0].start[0], y = data->saved.items[0].start[1];
    if (x >= tl[0] && x < br[0] && y < tl[1] && y >= br[1]) {
        auto *image = sprite->GetpImage();
        int32_t left, right, top, bottom;
        crop_interval(sprite->x, sprite->width, image->GetWidth(), &left, &right);
        crop_interval(sprite->y, sprite->height, image->GetHeight(), &top, &bottom);
        int32_t u = sample_coordinate(x, tl[0], br[0], left, right);
        int32_t v = sample_coordinate(y, tl[1], br[1], top, bottom);
        if ((uint32_t)u < 65536 && (uint32_t)v < 65536 && sample_visible(sprite, u, v)) {
            CssRayIntersection *hit = data->hit;
            hit->SetIntersected(const_cast<CssSprite *>(sprite));
            hit->submesh = 0;
            hit->distance = distance;
            hit->s[0] = (float)u / 65536.0f;
            hit->t[0] = (float)v / 65536.0f;
            hit->s[1] = hit->t[1] = 0;
            hit->normal = {0, 0, 1};
        }
    }
    CssCleanupStackManager::Pop(projection);
    delete projection;
}
