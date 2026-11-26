#ifndef JBED_SWERVE_OBJECT_CLASS_HPP
#define JBED_SWERVE_OBJECT_CLASS_HPP

#include "heap_object.hpp"
#include "pick_class.hpp"

struct CssSerializeBufferObjectsIn;

// Swerve exposes the CssRefCount subobject as the opaque handle.
class CssRefCount {
public:
    virtual ~CssRefCount() = default;
    virtual int Type() const { return 0; }
    void AddRef() { ++references; }
    void Release() { if (--references == 0) delete this; }
    int cReferences() const { return static_cast<int>(references); }
    static CssRefCount *Assign(CssRefCount *previous, CssRefCount *next)
    {
        if (next) next->AddRef();
        if (previous) previous->Release();
        return next;
    }
    uint32_t references = 0;
};

class IssSerializable : public CssHeapObject, public CssRefCount {
public:
    virtual void SerializeIn(CssSerializeBufferObjectsIn &reader) = 0;
};

#define SWV_REFERENCE_END ((void *)(intptr_t)-1)
#define SWV_REFERENCE_ARRAY ((void *)(intptr_t)-2)

class CssAnimationTrack;

class CssObject3D : public IssSerializable {
public:
    struct CssAnimTrackManager;
    struct SssUserParameter {
        int id;
        uint8_t *data;
        int length;
    };
    int user_id = 0;
    CssAnimTrackManager *tracks = nullptr;
    CssArray<SssUserParameter> *parameters = nullptr;
    int animation_stamp = -1;
    static IssSerializable *FactoryCreate();
    ~CssObject3D() override;
    void CloneHelper(const CssObject3D &source);
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    int Animate(int time, int stamp);
    int GetUserParameter(int id, int capacity, uint8_t *data) const;
    int GetUserParameterValue(int index, int capacity, uint8_t *data) const;
    int GetUserParameterID(int index) const { return (*parameters)[index].id; }
    int GetUserID() const { return user_id; }
    void SetUserID(int id) { user_id = id; }
    void SetUserParameter(int id, int length, const uint8_t *data);
    void RemoveUserParameters();
    int GetAnimationTrackCount() const;
    CssAnimationTrack *GetAnimationTrack(int index) const;
    void RemoveAnimationTrack(CssAnimationTrack *track);
    int GetReferences(int length, CssRefCount **references);
    void AddAnimationTrack(CssAnimationTrack *track);
    CssObject3D *Find(int id);
    virtual CssObject3D *Clone() const;
    virtual int AnimateRefs(int time, int validity, int stamp);
    virtual void *GetpRef(int index);
    virtual void SetProperty(int property, int components, float *values);
    virtual bool HasAnimatableProperty(int property) const;
};

class CssTransform;
class CssQuaternion;

class CssTransformable : public CssObject3D {
public:
    enum TransformFlags {
        CompositeDirty = 1,
        SkinningDirty = 2,
        SharedComponents = 4,
        SharedGeneralMatrix = 8
    };
    mutable uint8_t transform_flags = SharedComponents | SharedGeneralMatrix;
    SssTransformComponents *state = swv_default_transform();

    void AllocateTransformComponents();
    void SetTranslation(const CssVector3D &translation);
    void Translate(const CssVector3D &offset);
    void SetScale(const CssVector3D &scale);
    void Scale(const CssVector3D &factor);
    void SetOrientation(const CssQuaternion &q);
    void PreRotate(const CssQuaternion &q);
    void PostRotate(const CssQuaternion &q);
    void SetGeneralMatrix(const CssMatrix &matrix);
    void SetTransform(const CssTransform *transform);
    void GetTransform(CssTransform *out) const;
    void GetCompositeTransform(CssTransform *out) const;
    void ReCache() const;
    CssMatrix &GetCompositeMatrix() const { ReCache(); return state->composite; }
    ~CssTransformable() override;
    void CloneHelper(const CssTransformable &source);
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    void SetProperty(int property, int components, float *values) override;
    bool HasAnimatableProperty(int property) const override;
    virtual void SetMatrixCacheDirty() const;
};

class CssNode : public CssTransformable {
public:
    enum EssOrientationReference { None = 144, Origin, XAxis, YAxis, ZAxis };
    enum NodeFlags : unsigned {
        RenderingEnabled = 1, PickingEnabled = 2, Unlinkable = 4, WorldMatrixDirty = 8
    };
    struct Alignment {
        EssOrientationReference z_target, y_target;
        CssNode *z_reference, *y_reference;
    };
    Alignment *alignment = nullptr;
    float alpha = 1.0f;
    int scope = -1;
    CssNode *parent = nullptr, *next_sibling = nullptr, *first_child = nullptr;
    uint8_t depth = 0;
    mutable uint8_t flags = RenderingEnabled | PickingEnabled | WorldMatrixDirty;
    mutable CssMatrix world_transform;
    mutable float world_matrix_scale;
    uint32_t cache;
    CssVector3D world_origin;

    CssNode *pParent() const { return parent; }
    float GetAlphaFactor() const { return alpha; }
    int GetScope() const { return scope; }
    CssNode *GetParent() const { return pParent(); }
    bool GetUnlinkable() const { return (flags & Unlinkable) != 0; }
    void SetUnlinkable() { flags |= Unlinkable; }
    void LinkAfter(CssNode *sibling);
    void LinkAsFirstChildOf(CssNode *node);
    void UnLink();
    int GetTreeDepth() const;
    CssMatrix &GetMatrixWorld() const;
    float GetWorldMatrixScale() const { return world_matrix_scale; }
    CssMatrix &GetMatrixParent() const { return GetCompositeMatrix(); }
    static bool HaveCommonAncestor(const CssNode *a, const CssNode *b);
    CssVector3D GetAxis(const CssMatrix &matrix, EssOrientationReference axis) const;
    bool IsAncestorOf(const CssNode *node) const;
    bool IsDescendantOf(const CssNode *node) const;
    static const CssNode *BuildTransformMatrix(const CssNode *from, const CssNode *to, CssMatrix *out);
    bool GetTransformTo(const CssNode *target, CssTransform *transform) const;
    void SetWorldMatrixCacheDirty() const;
    void SetWorldMatrixCache(const CssMatrix &matrix) const;
    void SetPickingEnabled(bool enabled);
    void SetAlphaFactor(float value) { alpha = value; }
    bool GetPickingEnabled() const { return (flags & PickingEnabled) != 0; }
    bool GetRenderingEnabled() const { return (flags & RenderingEnabled) != 0; }
    void UpdateTreeDepth(int parent_depth);
    CssNode *pFirstChild() const { return first_child; }
    CssNode *pNextSibling() const { return next_sibling; }
    CssNode *GetAlignmentReferenceUnsafe(EssOrientationReference axis) const;
    CssNode *GetAlignmentReference(EssOrientationReference axis) const;
    EssOrientationReference GetAlignmentTarget(EssOrientationReference axis) const;
    void NullReferencesOf(const CssNode *target);
    static CssNode *FindCorresponding(const CssNode *wanted, const CssNode *source, const CssNode *copy);
    void FixupAlignmentReferences(const CssNode *source, const CssNode *source_root, const CssNode *copy_root);
    void SetAlignment(CssNode *z_node, EssOrientationReference z_target, CssNode *y_node, EssOrientationReference y_target);
    void DoAlignment(const CssNode *reference);
    void AlignRecursively(CssNode *reference);
    void Align(CssNode *reference);
    CssNode();
    ~CssNode() override;
    void CloneHelper(const CssNode &source);
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    void SetProperty(int property, int components, float *values) override;
    bool HasAnimatableProperty(int property) const override;
    void SetMatrixCacheDirty() const override;
    virtual void SetRenderingEnabled(bool enabled);
    virtual void SetScope(int new_scope);
    virtual int GetPosScaleBias(float *scale, CssVector3D *bias) const;
};

class CssCamera;
class CssRayIntersection;

class CssGroup : public CssNode, public CssPick {
public:
    void AddChild(CssNode *node);
    void RemoveChild(CssNode *node);
    CssNode *GetChildIfExists(int &index);
    CssNode *GetChild(int index);
    int GetChildCount() const;
    bool Pick(int scope, const CssVector3D &origin, const CssVector3D &direction, CssRayIntersection *out);
    bool Pick(int scope, float x, float y, CssCamera *camera, CssRayIntersection *out);
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssGroup &source);
    CssObject3D *Clone() const override;
    int AnimateRefs(int time, int validity, int stamp) override;
    void *GetpRef(int index) override;
    int Type() const override { return GroupObject; }
};

class CssAnimationController final : public CssObject3D {
public:
    int start = 0, end = 0;
    float position = 0;
    int reference_time = 0;
    float speed = 1, weight = 1;

    bool IsActive(int time) { return start == end || (time >= start && time < end); }
    float GetPosition(int time) const;
    float GetPositionLooped(int time, int duration) const;
    float GetWeight() const { return weight; }
    void SetWeight(float value) { weight = value; }
    void SetActiveInterval(int start, int end);
    void SetPosition(float position, int world_time);
    void SetSpeed(float speed, int world_time);
    int GetActiveIntervalStart() const { return start; }
    int GetActiveIntervalEnd() const { return end; }
    int GetRefWorldTime() const { return reference_time; }
    float GetSpeed() const { return speed; }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssAnimationController &source);
    CssObject3D *Clone() const override;
    int Type() const override { return AnimationControllerObject; }
};

class CssKeyframeSequence final : public CssObject3D {
public:
    enum EssInterpolation { Linear = 176, Slerp, Spline, Squad, Step };
    enum EssRepeatMode { Constant = 192, Loop };
    EssInterpolation interpolation = Linear;
    EssRepeatMode repeat = Constant;
    float duration_float = 0;
    int duration = 0, first = 0, last = 0, components = 0, count = 0;
    mutable CssArray<float> keys;
    mutable uint8_t validated = 0;

    void Construct(int frames, int components, EssInterpolation mode);
    int CalcStride() const { return int(1u + (interpolation == Spline || interpolation == Squad ? 3u : 1u) * components); }
    int CalcRangeKeyFrames() const;
    float *KeyData(int index, int stride) const { return &keys[index * stride]; }
    int GetiKeyframeSucc(int index) const;
    int GetiKeyframePred(int index) const;
    void CalculateTangents(bool squad) const;
    void Validate() const;
    void SetDuration(int value);
    void SetRepeatMode(EssRepeatMode mode) { repeat = mode; }
    void SetValidRange(int first, int last);
    int GetKeyframe(int index, int length, float *value);
    void SetKeyframe(int index, int time, int length, const float *value);
    float GetWeightedValue(int time, const CssAnimationTrack *track, int capacity, float *sum, float weight) const;
    int GetDuration() const { return duration; }
    int GetRepeatMode() const { return repeat; }
    int GetValidRangeFirst() const { return first; }
    int GetValidRangeLast() const { return last; }
    int GetcKeyframes() const { return count; }
    int GetcComponents() const { return components; }
    int GetInterpolationType() const { return interpolation; }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssKeyframeSequence &source);
    CssObject3D *Clone() const override;
    int Type() const override { return KeyframeSequenceObject; }
};

class CssAnimationTrack final : public CssObject3D {
public:
    enum EssTargetProperty : int {
        None = 255, Alpha, AmbientColor, Color, Crop, Density, DiffuseColor,
        EmissiveColor, FarDistance, FieldOfView, Intensity, MorphWeights,
        NearDistance, Orientation, Pickability, Scale, Shininess, SpecularColor,
        SpotAngle, SpotExponent, Translation, Visibility
    };
    CssKeyframeSequence *sequence = nullptr;
    CssAnimationController *controller = nullptr;
    EssTargetProperty property = None;
    static constexpr int AnyComponentCount = -1;

    void Construct(CssKeyframeSequence *keys, int target);
    int GetValidPropertyComponents(EssTargetProperty target) const;
    void SetController(CssAnimationController *value);
    CssAnimationController *GetController() const { return controller; }
    CssKeyframeSequence *GetKeyframeSequence() const { return sequence; }
    float GetWeight() const { return controller ? controller->GetWeight() : 0; }
    float GetTime(int time) const { return controller ? controller->GetPosition(time) : 0; }
    bool IsActive(int time) const { return controller && controller->IsActive(time); }
    int GetValueForTime(int time, int capacity, float *sum, float weight) const;
    int GetTargetProperty() const { return property; }

    void SerializeIn(CssSerializeBufferObjectsIn &r) override;
    static IssSerializable *FactoryCreate();
    void CloneHelper(const CssAnimationTrack &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int index) override;
    ~CssAnimationTrack() override;
    int Type() const override { return AnimationTrackObject; }
};


#endif
