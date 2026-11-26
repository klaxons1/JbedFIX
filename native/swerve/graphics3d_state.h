#ifndef SWV_GRAPHICS3D_STATE_H
#define SWV_GRAPHICS3D_STATE_H
#include "image2d.h"
#include "engine.h"
#include "render.h"

struct CssGraphics3D;
#include "cssrasterizerstandard.hpp"
#include "object_class.hpp"
#include "geometry.h"
#include <climits>

struct CssIntMatrix {
    int m[16], shift, w_shift, fraction;
    uint8_t affine;
    bool SetScaledMatrix(const CssMatrix &, int magnitude, bool test_bounds, bool early_out);
    void Transform3Fixed(const int8_t *, SwvFixedWord *xyz) const;
    void Transform3NFixed(const int8_t *, SwvFixedWord *xyz) const;
    void Transform3Fixed4(const int8_t *, SwvFixedWord *xyz, SwvFixedWord *w, int count) const;
    void Transform2Fixed(const int8_t *, SwvFixedWord *xy, SwvFixedWord *w) const;
    void Transform3Fixed(const int16_t *, SwvFixedWord *xyz) const;
    void Transform3NFixed(const int16_t *, SwvFixedWord *xyz) const;
    void Transform3Fixed4(const int16_t *, SwvFixedWord *xyz, SwvFixedWord *w, int count) const;
    void Transform2Fixed(const int16_t *, SwvFixedWord *xy, SwvFixedWord *w) const;
};
#include "csscolor.hpp"

class CssLight;
class CssMaterial;

struct SssLitVertex {
    CssColor color, diffuse, specular;
    CssFixedVector3D eye;
    SwvFixedWord eye_w;
    int w_shift;
    const CssFixedVector3D *clip_position;
    const CssFixedVector3D *divided_position;
    SwvFixedWord clip_w;
    const CssFixedVector3D *normal;
    uint8_t alpha, fog, clip_flags;
    bool lit, have_position, have_eye, projected;
};
struct CssClipVertex {
    CssFixedVector3D position;
    SwvFixedWord w, reciprocal_w;
    int rgb[3];
    uint8_t alpha, fog, textures;
    SssTLTexCoordsStd tex[2];

    void SetPosition(const SssLitVertex &, const SssTLTexCoordsStd *, int units);
    void SetClipPosition(const CssClipVertex &, const CssClipVertex &, SwvFixedWord amount);
    void DivideByW();
};

struct CssActiveLightStandard {
    using Shader = void (CssActiveLightStandard::*)(SssLitVertex *);
    Shader shade = nullptr;
    bool Initialize(const CssLight &, const CssMatrix &);
    bool SetSurfaceParameters(const CssMaterial *, int flags, int scope, CssColor *ambient);
    void LightVertex(SssLitVertex *, bool reverse_normal);
    void LightVertexParallel(SssLitVertex *);
    void LightVertexOmni(SssLitVertex *);
    void LightVertexSpot(SssLitVertex *);
    void LightSpecular(SssLitVertex *, const CssFixedVector3D &, SwvFixedWord attenuation);
    void ReCacheVertexScale(SssLitVertex *);

    uint8_t diffuse_enabled = 0, specular_enabled = 0, ambient = 0, enabled = 0;
    int half_shininess = 0, polygon = 0;
    CssFixedVector3D direction, position;
    CssVector3D center;
    int exponent = 0;
    float position_scale = 1;
    CssColor color;
    int cutoff = 0, spot_power = 0, attenuation[3] = {};
    float constant, linear, quadratic_root;
    uint8_t attenuated = 0, valid = 0;
    int scope = -1;
    uint8_t reverse_normal = 0;
    int last_w = 0, last_shift = 0, eye_scale;
};


class CssVertexArray;
class CssSkinnedMesh;

class CssFixedVectorCache
{
public:
    enum CachedValue : uint8_t { Transformed = 1, DividedByW = 2 };
    virtual ~CssFixedVectorCache() = default;
    const CssVertexArray *source = nullptr;
    CssMatrix matrix = {}, previous_matrix = {};
    CssArray<CssFixedVector3D> xyz, normalized_xyz;
    CssArray<SwvFixedWord> w, normalized_w;
    CssArray<uint8_t> valid;
    CssArray<CssIntMatrix> transforms;
    const CssSkinnedMesh *skin = nullptr;
    float scale = 0;
    CssVector3D bias = {};
    SwvFixedWord previous_w = 0, reciprocal_w = 0;
    int reciprocal_shift = 0;
    bool prepared = false;

    void SetSkinnedMesh(const CssSkinnedMesh *mesh) { skin = mesh; }
    bool DoInitialize(const CssMatrix &transform, bool test_bounds);
    void Initialize(const CssVertexArray *, const CssMatrix &, float scale, const CssVector3D &bias, bool *visible);
    void InitializeLazy(const CssVertexArray *, const CssMatrix &, float scale, const CssVector3D &bias);
    void TransformAll4D();
    const CssFixedVector3D *DivideByW(int index, SwvFixedWord *reciprocal);
    void GetVector4D(int index, const CssFixedVector3D **position, SwvFixedWord *w);
    void GetShiftedVector4D(int index, const CssFixedVector3D **position, SwvFixedWord *w, int *shift);
    const CssFixedVector3D *GetNormalisedVector3D(int index);
    const CssFixedVector3D *GetProjectedVector2D(int index);
    void Clear();
};

struct CssRectangle {
    int x, y, w, h;
    bool Intersect(const CssRectangle &other);
};

class CssImage2D;
class CssWorld;
class CssSprite;
class CssCamera;
class CssAppearance;
class CssBackground;
class CssTransform;
class CssVertexBuffer;
class CssIndexBuffer;

class CssRenderer : public CssHeapObject
{
public:
    virtual void ClearCache() = 0;
    virtual void SetpBackBuffer(CssGraphics3D *) = 0;
    virtual void UpdatepBackBuffer(CssGraphics3D *) = 0;
    virtual void SetViewport(int, int, int, int) = 0;
    virtual void ClearBackgroundAndZBuffer(CssBackground *, const CssCamera *) = 0;
    virtual void SetCamera(const CssCamera *, const CssMatrix *) = 0;
    virtual void SetLights(int, const CssLight *const *, const CssMatrix *) = 0;
    virtual void RenderVertices(CssVertexBuffer *, CssIndexBuffer *, CssAppearance *, CssTransform *, int) = 0;
    virtual void RenderNode(const CssNode *, const CssTransform *) = 0;
    virtual void RenderWorld(const CssWorld *) = 0;
    virtual int GetBytesZBufferDepth() const = 0;
    virtual void RenderSprite(const CssSprite *) = 0;
};

CssRenderer *g_ssCreateEditionRenderer();

struct CssRendererStandard : public CssRenderer {
    struct SssQueuedState {
        int key, next, submesh;
        float alpha;
        const CssNode *node;
    };
    CssGraphics3D *graphics = nullptr;
    CssRasterizerStandard *raster = nullptr;
    float opacity = 1;
    CssArray<SssQueuedState> queue;
    int queue_cursor = 0;
    CssMatrix view = {}, view_projection = {}, projection = {};
    int viewport_scale[2] = {65536, 65536}, viewport_shift = 0, depth_scale = 65536, depth_bias = 0;
    bool empty_projection = false;
    int camera_scope = -1, camera_type = CssCamera::Generic;
    CssArray<CssClipVertex> clipped_vertices;
    SssProjectedVertex projected[9] = {};
    unsigned clip_intersection = 0, clip_union = 0, clip_planes = 0;
    uint8_t vertex_color = 0, vertex_alpha = 0, vertex_opaque = 1, shade_normals = 0;
    int polygon_flags = 0, texture_units = 0;
    uint8_t texture_enabled[2] = {}, texture_projective[2] = {};
    const CssVertexBuffer *vertex_buffer = nullptr;
    CssVertexArray *color_array = nullptr;
    const uint8_t *colors = nullptr;
    int color_components = 0;
    CssMatrix model_view = {}, normal_transform = {};
    bool normal_transform_valid = false;
    CssFixedVectorCache positions, eye_positions, normals, texcoords[2];
    CssArray<uint8_t> clip_flags;
    CssArray<CssVector3D> vertex_normals;
    CssArray<CssActiveLightStandard> active_lights;
    CssColor fog_color;
    CssCompositingMode *default_compositing = nullptr;
    CssArray<uint16_t> depth;
    uint16_t *stage_values = nullptr;
    const CssWorld *world = nullptr;
    SssLitVertex lit_vertices[3] = {};
    float camera_position[3] = {};
    bool nonambient_lights = true;

    CssRendererStandard();
    ~CssRendererStandard() override;
    void ClearCache() override;
    void SetpBackBuffer(CssGraphics3D *) override;
    void UpdatepBackBuffer(CssGraphics3D *) override;
    void SetViewport(int, int, int, int) override;
    void ClearBackgroundAndZBuffer(CssBackground *, const CssCamera *) override;
    void SetCamera(const CssCamera *, const CssMatrix *) override;
    void SetLights(int, const CssLight *const *, const CssMatrix *) override;
    void RenderVertices(CssVertexBuffer *, CssIndexBuffer *, CssAppearance *, CssTransform *, int) override;
    void RenderNode(const CssNode *, const CssTransform *) override;
    void RenderWorld(const CssWorld *) override;
    int GetBytesZBufferDepth() const override { return sizeof(uint16_t); }
    void RenderSprite(const CssSprite *) override;
    static CssRendererStandard *Create();
    void Construct();
    uint16_t *pZbuffer();
    void ClearZBuffer();
    void ClearZBufferRect(int x, int y, int width, int height);
    void CopyZRect(int x, int y, int width, int height, int s, int t, int ds, int dt,
                   int pitch, int source_width, int source_height);
    void AddSortedQueueElement(const CssNode *, int submesh, int transparent, int layer, int &depth_key);
    void RenderSetupScene(const CssNode *);
    void RenderSetupSceneRecursive(const CssNode *);
    void RenderStateQueue();
    void TransformAndClipVertices(const CssMatrix &);
    void RenderVerticesScope(const CssVertexBuffer *, CssIndexBuffer *, CssAppearance *, int scope);
    void ProjectVertex(SssProjectedVertex *, const CssFixedVector3D *, SwvFixedWord reciprocal);
    void ProjectSpriteVertex(SssProjectedVertex *, const CssFixedVector3D *);
    int ClipPolygon(int first, int plane);
    void DrawClippedTriangle();
    void DrawTriangleFan(int count);
    void RenderLight(const CssLight &, const CssMatrix &);
};

struct CssGraphics3D : public CssHeapObject, public CssRefCount {
    enum Hint : int { HintAntialias = 2, HintDither = 4, HintTrueColor = 8, HintOverwrite = 16 };
    CssRectangle target = {};
    int pitch = 0;
    uint8_t *base = nullptr;
    CssRectangle requested_crop = {}, crop = {};
    uint8_t *pixels = nullptr;
    CssRectangle viewport = {};
    mutable CssRectangle relative = {};
    mutable uint8_t clipped = 0;
    mutable CssRectangle visible = {};
    mutable uint8_t dirty = 1, drawable = 0;
    uint8_t has_alpha = 0;
    int alpha_pitch = 0;
    uint8_t *alpha = nullptr;
    uint16_t *stage_depth = nullptr;
    float near_depth = 0, far_depth = 1;
    uint8_t depth_enabled = 1, antialias = 0, dither = 0, true_color = 0, overwrite = 0;
    CssRenderer *renderer = nullptr;
    CssCamera *camera = nullptr;
    CssMatrix camera_transform = {};
    CssArray<CssLight *> lights;
    CssArray<CssMatrix> light_xform;
    uint8_t scene_dirty = 1;

    CssGraphics3D() { camera_transform.flags = 32; }
    ~CssGraphics3D() override;
    CssGraphics3D(const CssGraphics3D &) = delete;
    CssGraphics3D &operator=(const CssGraphics3D &) = delete;
    int Type() const override { return 25; }
    static CssGraphics3D *Create();
    enum EssCapabilities {
        SupportAntialiasing, SupportTrueColor, SupportDithering, SupportMipmap,
        SupportPerspectiveCorrection, SupportLocalCameraLighting, MaxLights, MaxViewportDimension,
        MaxTextureDimension, MaxSpriteCropDimension, NumTextureUnits, MaxTransformsPerVertex,
        MaxViewportWidthCapability, MaxViewportHeightCapability
    };
    static int GetCapability(EssCapabilities capability);
    void Construct();
    void ResetLights();
    void SetupCameraAndLights();
    void UpdateIntersection() const;
    void SetViewport(int x, int y, int width, int height);
    void SetHints(bool enable_depth, int flags);
    void SetCrop(int x, int y, int width, int height);
    void SetDepthRange(float, float);
    void ResetState();
    void SetBackBufferData(int width, int height, int pitch, uint16_t *pixels);
    void SetBackBufferData(int width, int height, int pitch, uint16_t *pixels, int x, int y, int w, int h);
    void UpdateBackBufferData(uint16_t *);
    void SetBackBufferImage2D(CssImage2D *);
    void SetCamera(CssCamera *, CssTransform *);
    CssCamera *GetCamera(CssTransform *);
    void SetLight(int, CssLight *, CssTransform *);
    CssLight *GetLight(int, CssTransform *);
    int AddLight(CssLight *, CssTransform *);
    void CopyWorldCameraAndLights(const CssWorld *);
    void Clear(CssBackground *);
    void RenderPrimitive(CssVertexBuffer *, CssIndexBuffer *, CssAppearance *, CssTransform *, int);
    void RenderNode(CssNode *, CssTransform *);
    void RenderWorld(CssWorld *);
    int Width() const { return crop.w; }
    int Height() const { return crop.h; }
    int Pitch() const { return pitch; }
    uint16_t *pPixels() const { return reinterpret_cast<uint16_t *>(pixels); }
    float DepthRangeNear() const { return near_depth; }
    float DepthRangeFar() const { return far_depth; }
    bool DepthBufferEnabled() const { return depth_enabled; }
    int GetLightCount() const { return lights.size; }
    int GetHints() const;
    void ClearRendererCache() { if (renderer) renderer->ClearCache(); }
};
#endif
