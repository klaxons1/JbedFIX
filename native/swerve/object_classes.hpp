#ifndef SWERVE_OBJECT_CLASSES_HPP
#define SWERVE_OBJECT_CLASSES_HPP

#include "object_class.hpp"
#include "image2d.h"
#include "engine.h"
#include "objects.h"
#include "csscolor.hpp"
#include "cssobjectfactory.hpp"

int real_roundnearestclamp(float value, int minimum, int maximum);

class CssCamera;
class CssFog;
class CssImage2D;
class CssCompositingMode;
class CssMaterial;
class CssPolygonMode;
class CssTexture2D;

class CssAppearance final : public CssObject3D {
public:
    static constexpr int MaxLayer = 63;
    int layer = 0;
    CssCompositingMode *compositing = nullptr;
    CssFog *fog = nullptr;
    CssPolygonMode *polygon = nullptr;
    CssMaterial *material = nullptr;
    CssTexture2D *textures[2] = {};

    int GetLayer() const { return layer; }
    void SetLayer(int value) { layer = value; }
    CssCompositingMode *GetCompositingMode() const { return compositing; }
    CssFog *GetFog() const { return fog; }
    CssMaterial *GetMaterial() const { return material; }
    CssPolygonMode *GetPolygonMode() const { return polygon; }
    CssTexture2D *GetTexture(int unit) const;
    void SetCompositingMode(CssCompositingMode *mode);
    void SetFog(CssFog *value);
    void SetMaterial(CssMaterial *value);
    void SetPolygonMode(CssPolygonMode *mode);
    void SetTexture(int unit, CssTexture2D *texture);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssAppearance &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    int AnimateRefs(int time, int validity, int stamp) override;
    ~CssAppearance() override;
    int Type() const override { return AppearanceObject; }
};

class CssBackground final : public CssObject3D {
public:
    enum EssImageMode : int { Border = 32, Repeat };
    CssPackedColor color{0};
    CssImage2D *image = nullptr;
    int mode_x = Border, mode_y = Border;
    float x = 0, y = 0, width = 0, height = 0;
    uint8_t color_clear = 1, depth_clear = 1;

    uint32_t GetColor() const { return color.GetPackedRGBA8(); }
    void SetColor(unsigned int value) { color.SetPackedRGBA8(value); }
    int GetImageModeX() const { return mode_x; }
    int GetImageModeY() const { return mode_y; }
    bool GetbColorClear() const { return color_clear; }
    void SetbColorClear(bool value) { color_clear = value; }
    bool GetbDepthClear() const { return depth_clear; }
    void SetbDepthClear(bool value) { depth_clear = value; }
    int GetImageCropX() const { return real_roundnearestclamp(x, INT32_MIN, INT32_MAX); }
    int GetImageCropY() const { return real_roundnearestclamp(y, INT32_MIN, INT32_MAX); }
    int GetImageCropWidth() const { return real_roundnearestclamp(width, 0, INT32_MAX); }
    int GetImageCropHeight() const { return real_roundnearestclamp(height, 0, INT32_MAX); }
    float GetImageCropXReal() const { return x; }
    float GetImageCropYReal() const { return y; }
    float GetImageCropWidthReal() const { return width; }
    float GetImageCropHeightReal() const { return height; }
    void SetImageCrop(int x, int y, int width, int height);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssBackground &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override
    {
        return p == CssAnimationTrack::Alpha || p == CssAnimationTrack::Color || p == CssAnimationTrack::Crop ||
               CssObject3D::HasAnimatableProperty(p);
    }
    ~CssBackground() override;
    int Type() const override { return BackgroundObject; }
};

class CssCompositingMode final : public CssObject3D {
public:
    uint8_t color_write = 1, alpha_write = 1, depth_test = 1, depth_write = 1;
    int blending = SWV_BLEND_REPLACE;
    float threshold = 0, depth_factor = 0, depth_units = 0;

    enum EssBlending : int { Alpha = 64, AlphaAdd, Modulate, ModulateX2, Replace };
    float GetAlphaThreshold() const { return threshold; }
    void SetAlphaThreshold(float value) { threshold = value; }
    int GetBlending() const { return blending; }
    void SetBlending(EssBlending value) { blending = value; }
    bool GetColorWrite() const { return color_write; }
    void SetColorWrite(bool value) { color_write = value; }
    bool GetAlphaWrite() const { return alpha_write; }
    void SetAlphaWrite(bool value) { alpha_write = value; }
    bool GetDepthWrite() const { return depth_write; }
    void SetDepthWrite(bool value) { depth_write = value; }
    bool GetDepthTest() const { return depth_test; }
    void SetDepthTest(bool value) { depth_test = value; }
    float GetDepthOffsetFactor() const { return depth_factor; }
    float GetDepthOffsetUnits() const { return depth_units; }
    void SetDepthOffset(float factor, float units);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssCompositingMode &source);
    CssObject3D *Clone() const override;
    int Type() const override { return CompositingModeObject; }
};

class CssFog final : public CssObject3D {
public:
    CssPackedColor color{0};
    float density = 1, near_distance = 0, far_distance = 1;
    int mode = SWV_FOG_LINEAR;

    enum EssMode : int { Exponential = 80, Linear };
    uint32_t GetColor() const { return color.GetPackedRGBA8() & 0xffffff; }
    void SetColor(unsigned int value) { color.SetPackedRGBA8(value & 0xffffff); }
    float GetDensity() const { return density; }
    void SetDensity(float value) { density = value; }
    int GetMode() const { return mode; }
    void SetMode(EssMode value) { mode = value; }
    float GetNearDistance() const { return near_distance; }
    float GetFarDistance() const { return far_distance; }
    void SetLinear(float near_distance, float far_distance);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssFog &source);
    CssObject3D *Clone() const override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override
    {
        return p == CssAnimationTrack::Color || p == CssAnimationTrack::Density ||
               p == CssAnimationTrack::FarDistance || p == CssAnimationTrack::NearDistance ||
               CssObject3D::HasAnimatableProperty(p);
    }
    int Type() const override { return FogObject; }
};

class CssPolygonMode final : public CssObject3D {
public:
    enum PolygonFlags : unsigned {
        BackFaceCulling = 0x1, FrontFaceCulling = 0x2, NoCulling = 0x4,
        CounterClockwiseWinding = 0x8, ClockwiseWinding = 0x10,
        FlatShading = 0x20, SmoothShading = 0x40,
        OneSidedLighting = 0x80, TwoSidedLighting = 0x100,
        LocalCameraLighting = 0x200, PerspectiveCorrection = 0x400,
        CullMask = BackFaceCulling | FrontFaceCulling | NoCulling,
        WindingMask = CounterClockwiseWinding | ClockwiseWinding,
        ShadingMask = FlatShading | SmoothShading,
        LightingMask = OneSidedLighting | TwoSidedLighting,
        AllFlags = CullMask | WindingMask | ShadingMask | LightingMask |
                   LocalCameraLighting | PerspectiveCorrection,
        DefaultFlags = BackFaceCulling | CounterClockwiseWinding | SmoothShading | OneSidedLighting
    };
    unsigned flags = DefaultFlags;

    enum EssCulling : int { CullBack = 160, CullFront, CullNone };
    enum EssShading : int { Flat = 164, Smooth };
    enum EssWinding : int { CounterClockwise = 168, Clockwise };
    int GetCulling() const { return flags & BackFaceCulling ? CullBack : flags & FrontFaceCulling ? CullFront : CullNone; }
    void SetCulling(EssCulling mode);
    int GetShading() const { return flags & FlatShading ? Flat : Smooth; }
    void SetShading(EssShading mode);
    int GetWinding() const { return flags & CounterClockwiseWinding ? CounterClockwise : Clockwise; }
    void SetWinding(EssWinding mode);
    bool GetLocalCameraLighting() const { return (flags & LocalCameraLighting) != 0; }
    void EnableLocalCameraLighting(bool value) { flags = (flags & ~LocalCameraLighting) | (value ? LocalCameraLighting : 0); }
    bool GetPerspectiveCorrection() const { return (flags & PerspectiveCorrection) != 0; }
    void EnablePerspectiveCorrection(bool value) { flags = (flags & ~PerspectiveCorrection) | (value ? PerspectiveCorrection : 0); }
    bool GetbTwoSidedLighting() const { return (flags & TwoSidedLighting) != 0; }
    void SetbTwoSidedLighting(bool value) { flags = (flags & ~LightingMask) | (value ? TwoSidedLighting : OneSidedLighting); }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssPolygonMode &source);
    CssObject3D *Clone() const override;
    int Type() const override { return PolygonModeObject; }
};

class CssLight final : public CssNode {
public:
    float constant = 1, linear = 0, quadratic = 0;
    CssPackedColor color{0xffffff};
    float intensity = 1, spot_angle = 45, spot_exponent = 0;
    int mode = SWV_LIGHT_DIRECTIONAL;
    mutable uint8_t dirty = 1;

    enum EssMode : int { Ambient = 128, Directional, Omni, Spot };
    bool ParametersChanged() const { return dirty; }
    int GetMode() const { return mode; }
    void SetMode(EssMode value);
    uint32_t GetColor() const { return color.GetPackedRGBA8() & 0xffffff; }
    void SetColor(unsigned int value);
    float GetIntensity() const { return intensity; }
    void SetIntensity(float value);
    float GetSpotAngle() const { return spot_angle; }
    void SetSpotAngle(float value);
    float GetSpotExponent() const { return spot_exponent; }
    void SetSpotExponent(float value);
    float GetConstantAttenuation() const { return constant; }
    float GetLinearAttenuation() const { return linear; }
    float GetQuadraticAttenuation() const { return quadratic; }
    void SetAttenuation(float constant, float linear, float quadratic);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssLight &source);
    CssObject3D *Clone() const override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override;
    void SetMatrixCacheDirty() const override;
    void SetScope(int new_scope) override;
    void SetRenderingEnabled(bool enabled) override;
    int Type() const override { return LightObject; }
};

class CssMaterial final : public CssObject3D {
public:
    CssPackedColor ambient{0x333333}, diffuse{0xffcccccc}, emissive{0}, specular{0};
    uint8_t vertex_tracking = 0;
    float shininess = 0;

    float GetShininess() const { return shininess; }
    void SetShininess(float value) { shininess = value; }
    enum EssColorTarget : int { Ambient = 1024, Diffuse = 2048, Emissive = 4096, Specular = 8192 };
    uint32_t GetColor(EssColorTarget target) const;
    void SetColor(EssColorTarget targets, uint32_t color);
    bool GetbVertexColorTracking() const { return vertex_tracking; }
    void SetbVertexColorTracking(bool value) { vertex_tracking = value; }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssMaterial &source);
    CssObject3D *Clone() const override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override;
    int Type() const override { return MaterialObject; }
};

class CssTexture2D : public CssTransformable {
public:
    enum EssBlending : int { Add = 224, Blend, Decal, Modulate, Replace };
    enum EssWrap : int { Clamp = 240, Repeat };
    enum EssFilter : int { BaseLevel = 208, Linear, Nearest };

    void Construct(CssImage2D *image);
    void SetImage(CssImage2D *image);
    static bool IsPowerOfTwo(int value);
    const CssMatrix &matTransform() const { return GetCompositeMatrix(); }
    SwvImageFormat GetDataFormat() const;
    void SetBlendColor(unsigned int color) { blend_color.SetPackedRGBA8(color & 0xffffff); }
    void SetBlending(EssBlending mode) { blending = mode; }
    void SetWrapping(EssWrap s, EssWrap t);
    void SetFiltering(EssFilter level, EssFilter image);
    EssBlending GetBlending() const { return blending; }
    uint32_t GetBlendColor() const { return blend_color.GetPackedRGBA8(); }
    EssWrap GetWrappingS() const { return wrap_s; }
    EssWrap GetWrappingT() const { return wrap_t; }
    CssImage2D *GetImage() const { return image; }
    EssFilter GetImageFiltering() const { return image_filter; }
    EssFilter GetLevelFiltering() const { return level_filter; }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssTexture2D &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override { return p == CssAnimationTrack::Color || CssTransformable::HasAnimatableProperty(p); }
    ~CssTexture2D() override;
    int Type() const override { return Texture2DObject; }
    virtual void ReCacheBoundingBox(bool) const {}
private:
    CssPackedColor blend_color{0};
    EssBlending blending = Modulate;
    CssImage2D *image = nullptr;
    EssWrap wrap_s = Repeat, wrap_t = Repeat;
    EssFilter level_filter = BaseLevel, image_filter = Nearest;
};

class CssSprite final : public CssNode {
public:
    float height = 0, width = 0, x = 0, y = 0;
    CssImage2D *image = nullptr;
    CssAppearance *appearance = nullptr;
    uint8_t scaled = 0;

    CssAppearance *GetpAppearance() const { return appearance; }
    CssImage2D *GetpImage() const { return image; }
    void Construct(bool scaled, CssImage2D *image, CssAppearance *appearance);
    void SetpImage(CssImage2D *value);
    void SetpAppearance(CssAppearance *value);
    bool isScaled() const { return scaled; }
    int GetCropX() const { return real_roundnearestclamp(x, INT32_MIN, INT32_MAX); }
    int GetCropY() const { return real_roundnearestclamp(y, INT32_MIN, INT32_MAX); }
    int GetCropWidth() const { return real_roundnearestclamp(width, INT32_MIN, INT32_MAX); }
    int GetCropHeight() const { return real_roundnearestclamp(height, INT32_MIN, INT32_MAX); }
    void CalcCropRectangle(SwvFixedWord &s0, SwvFixedWord &t0, SwvFixedWord &s1, SwvFixedWord &t1) const;
    void SetCrop(int x, int y, int width, int height);

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssSprite &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    int AnimateRefs(int time, int validity, int stamp) override;
    void SetProperty(int p, int components, float *v) override;
    bool HasAnimatableProperty(int p) const override { return p == CssAnimationTrack::Crop || CssNode::HasAnimatableProperty(p); }
    ~CssSprite() override;
    int Type() const override { return SpriteObject; }
};

class CssWorld final : public CssGroup {
public:
    CssCamera *camera = nullptr;
    CssBackground *background = nullptr;
    mutable CssArray<const CssLight *> lights;

    CssCamera *GetpActiveCamera() const { return camera; }
    CssBackground *GetpBackground() const { return background; }
    void SetpActiveCamera(CssCamera *value);
    void SetpBackground(CssBackground *value);
    static void SetLightsCacheDirty(const CssNode *node);
    const CssArray<const CssLight *> &GetapLights() const;
    void RecacheLightsRecursive(const CssNode *node) const;
    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssWorld &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    bool HasAnimatableProperty(int property) const override;
    void SetProperty(int property, int count, float *values) override;
    int AnimateRefs(int time, int validity, int stamp) override;
    ~CssWorld() override;
    int Type() const override { return WorldObject; }
};

class CssCamera final : public CssNode {
public:
    enum EssProjection : int { Generic = 48, Parallel, Perspective };
    int projection_type = Generic;
    mutable uint8_t projection_dirty = 1, view_dirty = 1;
    mutable CssMatrix projection;
    float field_of_view = 57.29578f, height = 2, aspect = 1, near_plane = 1, far_plane = -1;

    CssCamera() { projection.Identity(); }
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssCamera &source);
    CssObject3D *Clone() const override;
    void SetMatrixCacheDirty() const override { CssNode::SetMatrixCacheDirty(); view_dirty = 1; }
    void SetProperty(int prop, int count, float *v) override;
    bool HasAnimatableProperty(int prop) const override;
    int Type() const override { return CameraObject; }
    int GetProjectionType() const { return projection_type; }
    float GetNear() const { return near_plane; }
    float GetFar() const { return far_plane; }
    bool ParametersChanged() const { return view_dirty; }
    const CssMatrix &GetMatrix() const;
    const CssMatrix &GetMatrixSafe() const;
    int GetProjection(CssTransform *transform) const;
    int GetProjection(int count, float *params) const;
    void SetGeneric(const CssTransform *transform);
    void SetParallel(float height, float aspect, float near_plane, float far_plane);
    void SetPerspective(float fovy, float aspect, float near_plane, float far_plane);
    void RecacheProjectionMatrix() const;
};

class CssRayIntersection final : public IssSerializable {
public:
    CssNode *intersected = nullptr;
    int submesh = 0;
    float distance = 0, s[2] = {}, t[2] = {};
    CssVector3D normal{0, 0, 1}, origin{}, direction{0, 0, 1};

    void SetRay(const CssVector3D &start, CssVector3D delta) { origin = start; direction = delta; }
    void SetIntersected(CssNode *node)
    {
        intersected = static_cast<CssNode *>(CssRefCount::Assign(intersected, node));
    }
    CssRayIntersection &operator=(const CssRayIntersection &source);
    static CssRayIntersection *Create();
    static IssSerializable *FactoryCreate();
    static void Initialize();
    static void Uninitialize();
    static CssRayIntersection *GetInstance();
    float GetDistance() const { return distance; }
    int GetSubmeshIndex() const { return submesh; }
    CssNode *GetIntersected() const { return intersected; }
    float GetNormalX() const { return normal.x; }
    float GetNormalY() const { return normal.y; }
    float GetNormalZ() const { return normal.z; }
    float GetTextureS(int unit) const;
    float GetTextureT(int unit) const;
    void GetRay(int count, float *values) const;

    ~CssRayIntersection() override
    {
        if (intersected)
            intersected->Release();
    }
    void SerializeIn(CssSerializeBufferObjectsIn &) override {}
    int Type() const override { return RayIntersectionObject; }
};

class CssVertexArray;
class CssQuaternion;

class CssTransform final : public IssSerializable {
public:
    CssMatrix matrix;
    static IssSerializable *FactoryCreate();
    CssTransform() { matrix.Identity(); }
    void Construct(const CssTransform *from);
    void Get(int count, float *values) const;
    void Set(int count, const float *values);
    void Set(const CssTransform *from);
    void SetMatrix(const CssMatrix &value) { matrix = value; }
    CssMatrix &GetMatrix() { return matrix; }
    const CssMatrix &GetMatrix() const { return matrix; }
    bool bInvertible() const;
    void Invert();
    void Transpose();
    void SetIdentity();
    void PostMultiply(CssTransform *right);
    void PostScale(const CssVector3D &scale);
    void PostTranslate(const CssVector3D &translation);
    void PostRotate(const CssQuaternion &rotation);
    void Transform(int count, float *points) const;
    void Transform(const CssVertexArray *vertices, int count, float *out, bool use_w) const;
    void SerializeIn(CssSerializeBufferObjectsIn &) override {}
    int Type() const override { return TransformObject; }
};

template<class T> inline T *assign_ref(T *previous, IssSerializable *next)
{
    return static_cast<T *>(CssRefCount::Assign(previous, next));
}

inline int limit_validity(int validity, CssObject3D *ref, int time, int stamp)
{
    if (ref) {
        int ref_validity = ref->Animate(time, stamp);
        if (ref_validity < validity)
            return ref_validity;
    }
    return validity;
}

inline float clamp(float value, float high)
{
    return value < 0 ? 0 : value > high ? high : value;
}

inline void *reference_handle(CssRefCount *object)
{
    if (object) object->AddRef();
    return object;
}

template<class T> inline T *replace_reference(T *previous, void *new_handle)
{
    return assign_ref(previous, static_cast<T *>(static_cast<CssRefCount *>(new_handle)));
}

inline int create_object(EssObjectType type, void **result)
{
    SWV_BEGIN_API(frame);
    *result = reference_handle(CssObjectFactory::CreateObject(type));
    CssTrapHandler::UnTrap();
    return 1;
}


#endif
