#include "graphics3d_state.h"
#include "object_classes.hpp"
#include "image_class.hpp"
#include "kni_targets.h"
#include "platform.h"
#include <algorithm>
#include <math.h>
#include <string.h>

void CssGraphics3D::ResetLights()
{
    const int count = lights.Size();
    for (int i = 0; i < count; ++i)
        if (lights[i])
            lights[i]->Release();
    lights.SetSize(0);
    light_xform.SetSize(0);
    scene_dirty = 1;
}

void CssGraphics3D::Construct()
{
    renderer = g_ssCreateEditionRenderer();
}

CssGraphics3D::~CssGraphics3D()
{
    delete renderer;
    if (camera)
        camera->Release();
    ResetLights();
}

CssGraphics3D *CssGraphics3D::Create()
{
    auto *g = new CssGraphics3D;
    CssCleanupStackManager::Push(g);
    g->Construct();
    CssCleanupStackManager::Pop(g);
    return g;
}

int CssGraphics3D::GetHints() const
{
    return (antialias * HintAntialias) | (dither * HintDither) |
           (true_color * HintTrueColor) | (overwrite * HintOverwrite);
}

int CssGraphics3D::GetCapability(EssCapabilities capability)
{
    switch (capability) {
    case SupportPerspectiveCorrection:
    case SupportLocalCameraLighting:
        return 1;
    case MaxLights:
        return SWV_MAX_LIGHTS;
    case NumTextureUnits:
        return SWV_TEXTURE_UNITS;
    case MaxTransformsPerVertex:
        return SWV_MAX_TRANSFORMS_PER_VERTEX;
    case MaxTextureDimension:
        return SWV_MAX_TEXTURE_DIMENSION;
    case MaxSpriteCropDimension:
        return SWV_MAX_SPRITE_CROP_DIMENSION;
    case MaxViewportDimension:
    case MaxViewportWidthCapability:
    case MaxViewportHeightCapability:
        return SWV_MAX_VIEWPORT_DIMENSION;
    default:
        return 0;
    }
}

void CssGraphics3D::SetViewport(int x, int y, int width, int height)
{
    CssRectangle rect{x, y, width, height};
    if (rect.w < 1 || rect.w > SWV_MAX_VIEWPORT_DIMENSION ||
        rect.h < 1 || rect.h > SWV_MAX_VIEWPORT_DIMENSION)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    viewport = rect;
    dirty = 1;
    UpdateIntersection();
    renderer->SetViewport(relative.x, relative.y, relative.w, relative.h);
}

void CssGraphics3D::UpdateIntersection() const
{
    dirty = 0;
    visible = crop;
    if ((drawable = visible.Intersect(viewport))) {
        relative = viewport;
        relative.x -= crop.x;
        relative.y -= crop.y;
        clipped = visible.x != viewport.x || visible.y != viewport.y ||
                  visible.w != viewport.w || visible.h != viewport.h;
    }
}
void CssGraphics3D::SetHints(bool depth, int f)
{
    depth_enabled = depth != 0;
    antialias = (f & HintAntialias) != 0;
    dither = (f & HintDither) != 0;
    true_color = (f & HintTrueColor) != 0;
    overwrite = (f & HintOverwrite) != 0;
    renderer->SetpBackBuffer(this);
}

void CssGraphics3D::SetCrop(int x, int y, int width, int height)
{
    CssRectangle request{x, y, width, height};
    requested_crop = request;
    crop = target;
    dirty = 1;
    pixels = crop.Intersect(request) ? base + crop.y * pitch + 2 * crop.x : NULL;
}

void CssGraphics3D::ResetState()
{
    CssRectangle request = requested_crop;
    SetHints(true, 0);
    request.w = std::clamp<int>(request.w, 1, SWV_MAX_VIEWPORT_DIMENSION);
    request.h = std::clamp<int>(request.h, 1, SWV_MAX_VIEWPORT_DIMENSION);
    SetViewport(request.x, request.y, request.w, request.h);
}

void CssGraphics3D::SetBackBufferData(int width, int height, int stride, uint16_t *buffer,
                                      int x, int y, int crop_width, int crop_height)
{
    target = {0, 0, width, height};
    has_alpha = 0;
    alpha_pitch = 0;
    alpha = nullptr;
    stage_depth = nullptr;
    pitch = stride;
    base = reinterpret_cast<uint8_t *>(buffer);
    SetCrop(x, y, crop_width, crop_height);
    ResetState();
}

void CssGraphics3D::SetBackBufferData(int width, int height, int stride, uint16_t *buffer)
{
    SetBackBufferData(width, height, stride, buffer, 0, 0, width, height);
}

void CssGraphics3D::UpdateBackBufferData(uint16_t *buffer)
{
    if (base != reinterpret_cast<uint8_t *>(buffer)) {
        base = reinterpret_cast<uint8_t *>(buffer);
        if (pixels)
            pixels = base + pitch * crop.y + 2 * crop.x;
        renderer->UpdatepBackBuffer(this);
    }
}

void CssGraphics3D::SetBackBufferImage2D(CssImage2D *image)
{
    if (image) {
        if (!image->GetbMutable() || (image->GetFormat() != CssImage2D::RGB && image->GetFormat() != CssImage2D::RGBA))
            g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        int w = image->GetWidth(), height = image->GetHeight();
        if (w > SWV_MAX_VIEWPORT_DIMENSION || height > SWV_MAX_VIEWPORT_DIMENSION)
            g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        target = {0, 0, w, height};
        has_alpha = image->GetFormat() == CssImage2D::RGBA;
        pitch = image->GetPitch();
        base = static_cast<uint8_t *>(image->GetpPixels());
        alpha_pitch = image->GetAlphaPitch();
        alpha = image->GetpAlpha();
        stage_depth = nullptr;
        if (image->Type() == StagesetObject) {
            auto *stage = static_cast<CssStageset *>(image);
            stage_depth = static_cast<uint16_t *>(stage->depth.data);
            stage->dirty = 0;
        }
        SetCrop(0, 0, w, height);
        ResetState();
    }
}

void CssGraphics3D::SetDepthRange(float near, float far)
{
    near_depth = near;
    far_depth = far;
}

void CssGraphics3D::SetCamera(CssCamera *new_camera, CssTransform *transform)
{
    camera = static_cast<CssCamera *>(CssRefCount::Assign(camera, new_camera));
    if (transform) {
        if (!transform->bInvertible())
            g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
        camera_transform = transform->GetMatrix();
    } else {
        camera_transform.Identity();
    }
    scene_dirty = 1;
}

CssCamera *CssGraphics3D::GetCamera(CssTransform *transform)
{
    if (transform)
        transform->GetMatrix() = camera_transform;
    return camera;
}

CssLight *CssGraphics3D::GetLight(int i, CssTransform *transform)
{
    if (i < 0 || i >= lights.Size())
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    CssLight *light = lights[i];
    if (transform)
        transform->GetMatrix() = light_xform[i];
    return light;
}

void CssGraphics3D::SetLight(int i, CssLight *light, CssTransform *transform)
{
    if (i < 0 || i >= lights.Size())
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    lights[i] = static_cast<CssLight *>(CssRefCount::Assign(lights[i], light));
    if (transform && light)
        light_xform[i] = transform->GetMatrix();
    else
        light_xform[i].Identity();
    scene_dirty = 1;
}

int CssGraphics3D::AddLight(CssLight *light, CssTransform *transform)
{
    int i = light_xform.Size();
    lights.Append(light);
    light->AddRef();
    light_xform.Append(transform ? transform->GetMatrix() : CssMatrix(MatrixIdentity));
    scene_dirty = 1;
    return i;
}

template<class Draw>
static void drawWithTrap(CssGraphics3D &graphics, Draw draw)
{
    CssTrapHandler frame;
    if (setjmp(frame.Trap())) {
        graphics.ClearRendererCache();
        g_ssThrowLeave(frame.error);
    }
    frame.CleanupStack();
    draw();
    CssTrapHandler::UnTrap();
}

void CssGraphics3D::Clear(CssBackground *bg)
{
    const auto *image = bg ? bg->image : nullptr;
    if (image && image->GetFormat() != (has_alpha ? CssImage2D::RGBA : CssImage2D::RGB))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    drawWithTrap(*this, [&] { renderer->ClearBackgroundAndZBuffer(bg, nullptr); });
}

void CssGraphics3D::RenderPrimitive(CssVertexBuffer *vertices, CssIndexBuffer *indices,
                                    CssAppearance *appearance, CssTransform *transform, int scope)
{
    if (!camera)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    drawWithTrap(*this, [&] {
        SetupCameraAndLights();
        renderer->RenderVertices(vertices, indices, appearance, transform, scope);
    });
}

void CssGraphics3D::RenderNode(CssNode *node, CssTransform *transform)
{
    if (!camera)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    int cls = node->Type();
    if (cls != MeshObject && cls != MorphingMeshObject && cls != SkinnedMeshObject &&
        cls != GroupObject && cls != SpriteObject && cls != WorldObject)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    drawWithTrap(*this, [&] {
        SetupCameraAndLights();
        renderer->RenderNode(node, transform);
    });
}
void CssGraphics3D::RenderWorld(CssWorld *world)
{
    CssCamera *active = world->GetpActiveCamera();
    if (!active || !active->IsDescendantOf(world))
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    drawWithTrap(*this, [&] {
        CopyWorldCameraAndLights(world);
        renderer->RenderWorld(world);
    });
}

void CssGraphics3D::CopyWorldCameraAndLights(const CssWorld *world)
{
    const auto &world_lights = world->GetapLights();
    ResetLights();
    const int count = world_lights.Size();
    if (count) {
        lights.SetSize(count);
        swvMemSet(&lights[0], 0, count * sizeof(CssLight *));
        light_xform.SetSize(count);
        for (int i = 0; i < count; ++i) {
            lights[i] = static_cast<CssLight *>(CssRefCount::Assign(lights[i], const_cast<CssLight *>(world_lights[i])));
            CssNode::BuildTransformMatrix(world_lights[i], world, &light_xform[i]);
        }
    }
    camera = static_cast<CssCamera *>(CssRefCount::Assign(camera, world->GetpActiveCamera()));
    CssNode::BuildTransformMatrix(camera, world, &camera_transform);
}

void CssGraphics3D::SetupCameraAndLights()
{
    if (camera && (camera->ParametersChanged() || scene_dirty))
        renderer->SetCamera(camera, &camera_transform);

    const int count = lights.Size();
    bool changed = false;
    for (int i = 0; i < count; ++i) {
        if (lights[i] && lights[i]->ParametersChanged()) {
            changed = true;
            break;
        }
    }
    if (changed || scene_dirty)
        renderer->SetLights(count, static_cast<CssLight **>(lights.data),
                            static_cast<CssMatrix *>(light_xform.data));
}
