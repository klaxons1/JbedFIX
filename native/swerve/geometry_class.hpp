#ifndef JBED_SWERVE_GEOMETRY_CLASS_HPP
#define JBED_SWERVE_GEOMETRY_CLASS_HPP

#include "geometry.h"
#include "csscolor.hpp"
#include "object_class.hpp"

class CssAppearance;
class CssTransform;
struct CssIntMatrix;

class CssVertexArray : public CssObject3D {
public:
    int count = 0, components = 0, width = 0;
    CssArray<uint8_t> bytes;
    mutable uint8_t dirty = 1;
    mutable int magnitude = 0, maximum[3] = {}, minimum[3] = {};

    int Type() const override { return VertexArrayObject; }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssVertexArray; }
    void CloneHelper(const CssVertexArray &source);
    CssObject3D *Clone() const override;
    static CssVertexArray *Create() { return new CssVertexArray; }
    void Construct(int count, int components, int width);
    void Get8(int first, int count, int capacity, int8_t *dest);
    void Get16(int first, int count, int capacity, int16_t *dest);
    void Set8(int first, int count, int capacity, const int8_t *source);
    void Set16(int first, int count, int capacity, const int16_t *source);
    void Set24(int first, int count, int capacity, const int *source, bool clamp);
    int cEntries() const { return count; }
    int cComponents() const { return components; }
    int Element(int vertex, int channel) const;
    int GetMaxNumber() const;
    void TransformVector(int, const CssIntMatrix &, CssFixedVector3D *, SwvFixedWord *) const;
    void TransformVectorsRange(int first, int end, const CssIntMatrix &, CssFixedVector3D *, SwvFixedWord *) const;
    void TransformNormal(int, const CssIntMatrix &, CssFixedVector3D *) const;
};

class CssVertexBuffer : public CssObject3D {
public:
    int count = 0;
    CssPackedColor color{UINT32_MAX};
    CssVertexArray *positions = nullptr, *normals = nullptr, *colors = nullptr, *texcoords[2] = {};
    float position_bias[3] = {}, position_scale = 1, normal_bias[3] = {}, normal_scale = 1;
    float texture_bias[2][3] = {}, texture_scale[2] = {1,1};

    ~CssVertexBuffer() override;
    int Type() const override { return VertexBufferObject; }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssVertexBuffer; }
    void CloneHelper(const CssVertexBuffer &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int) override;
    bool HasAnimatableProperty(int) const override;
    void SetProperty(int, int, float *) override;
    void SetVertexArray(CssVertexArray **slot, CssVertexArray *array);
    bool IsSoleArray(const CssVertexArray *) const;
    void UpdateVertexCount();
    void SetNormals(CssVertexArray *);
    void SetColors(CssVertexArray *);
    CssVertexArray *GetColors() const { return colors; }
    int GetVertexCount() const { return count; }
    uint32_t GetDefaultColor() const { return color.GetPackedRGBA8(); }
    void SetDefaultColor(unsigned value) { color.SetPackedRGBA8(value); }
    void SetPositions(CssVertexArray *, float scale, int count, const float *bias);
    void SetTexCoords(int unit, CssVertexArray *, float scale, int count, const float *bias);
    CssVertexArray *GetPositions(int capacity, float *scale_bias) const;
    CssVertexArray *GetTexCoords(int unit, int capacity, float *scale_bias) const;
};

class CssIndexBuffer : public CssObject3D {
public:
    int max_index = 0;
    int GetMaxIndex() const { return max_index; }
    void CloneHelper(const CssIndexBuffer &source);
    ~CssIndexBuffer() override;
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    virtual int GetIndexCount() const = 0;
    virtual void GetIndices(int capacity, SwvVertexIndex *out) const = 0;
};

class CssTriangleStripArray : public CssIndexBuffer {
public:
    uint8_t implicit = 1;
    uint16_t first = 0;
    CssArray<uint16_t> indices, lengths;

    int Type() const override { return TriangleStripArrayObject; }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssTriangleStripArray; }
    void CloneHelper(const CssTriangleStripArray &source);
    CssObject3D *Clone() const override;
    int GetIndexCount() const override;
    void GetIndices(int capacity, SwvVertexIndex *out) const override;
    void Construct(int first, int count, const SwvVertexIndex *lengths);
    void Construct(int index_count, const SwvVertexIndex *indices, int count, const SwvVertexIndex *lengths);
    void StitchAll();
    bool GetbIsImplicit() const { return implicit; }
    int GetFirstIndex() const { return first; }
    const CssArray<uint16_t> &GetaIndices() const { return indices; }
    const CssArray<uint16_t> &GetaStripLengths() const { return lengths; }
    int GetStrip(int strip, int capacity, SwvVertexIndex *out) const;
};

class CssMesh : public CssNode {
public:
    CssVertexBuffer *vertices = nullptr;
    CssArray<CssIndexBuffer *> indices;
    CssArray<CssAppearance *> appearances;

    int GetIndexBufferCount() const { return indices.Size(); }
    CssAppearance *GetAppearance(int index) const;
    CssIndexBuffer *GetIndexBuffer(int index) const;
    void SetAppearance(int index, CssAppearance *appearance);
    virtual CssVertexBuffer *GetVertexBuffer() const { return vertices; }
    int Type() const override { return MeshObject; }
    virtual CssVertexBuffer *GetRenderingVertexBuffer(bool normals) const;
    void Construct(CssVertexBuffer *vertices, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances);
    void Construct(CssVertexBuffer *vertices, CssIndexBuffer *indices, CssAppearance *appearance);
    ~CssMesh() override;
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssMesh; }
    CssObject3D *Clone() const override;
    void *GetpRef(int) override;
    int AnimateRefs(int, int, int) override;
    int GetPosScaleBias(float *, CssVector3D *) const override;
    void CloneHelper(const CssMesh &);
};

class CssMorphingMesh : public CssMesh {
public:
    mutable uint8_t dirty = 1;
    mutable CssVertexBuffer *morphed = nullptr;
    mutable CssArray<int32_t> work;
    CssArray<CssVertexBuffer *> targets;
    CssArray<float> weights;

    void Construct(CssVertexBuffer *vertices, int target_count, CssRefCount *const *targets, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances);
    void Construct(CssVertexBuffer *vertices, int target_count, CssRefCount *const *targets, CssIndexBuffer *indices, CssAppearance *appearance);
    ~CssMorphingMesh() override;
    int Type() const override { return MorphingMeshObject; }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssMorphingMesh; }
    void CloneHelper(const CssMorphingMesh &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int) override;
    int AnimateRefs(int, int, int) override;
    bool HasAnimatableProperty(int) const override;
    void SetProperty(int, int, float *) override;
    CssVertexBuffer *GetRenderingVertexBuffer(bool normals) const override;
    enum EssVertexArrayType { Positions, Colors, Normals, TexCoords0, TexCoords1 };
    void AddMorphedTarget(const CssVertexArray *, int count, float weight, int bias, int width) const;
    CssVertexArray *GetMorphedVertexArray(EssVertexArrayType) const;
    static CssVertexArray *GetVertexArrayOfType(CssVertexBuffer *, EssVertexArrayType);
    void SetMorphedDefaultColor() const;
    void GetWeightsRef(int *count, float **out);
    void GetWeights(int, float *) const;
    void SetWeights(int, const float *);
};

class CssSkinnedMesh : public CssMesh {
public:
    struct SssBoneNode {
        CssNode *node;
        CssMatrix bind;
        mutable CssMatrix current;
        mutable uint8_t dirty;
        SssBoneNode() { bind.flags = current.flags = MatrixIdentityFlag; }
    };
    struct SssBoneData {
        int weight;
        uint16_t first, count, bone;
    };
    struct SssPaletteEntry {
        uint16_t range[2];
        CssMatrix matrix;
        float reciprocal;
        uint8_t dirty, normals_dirty;
        int32_t fixed[12];
        SssPaletteEntry() { matrix.flags = MatrixIdentityFlag; }
    };
    unsigned last_vertex = 0;
    uint16_t GetMaxIndex() const { return static_cast<uint16_t>(last_vertex); }
    CssArray<SssBoneNode> bones;
    CssArray<SssBoneData> ranges;
    mutable float precision, bound = 0;
    mutable CssArray<SssPaletteEntry> blends;
    mutable CssArray<uint16_t> vertex_blends;
    mutable uint8_t mapped = 0, matrices_dirty = 1, vertices_dirty = 1, have_normals = 0;
    mutable CssVertexBuffer *deformed = nullptr;
    mutable float scale = 1, bias[3] = {};
    mutable CssMatrix position_matrix;

    CssSkinnedMesh();
    void Construct(CssVertexBuffer *vertices, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances, CssGroup *skeleton);
    void Construct(CssVertexBuffer *vertices, CssIndexBuffer *indices, CssAppearance *appearance, CssGroup *skeleton);
    ~CssSkinnedMesh() override;
    int Type() const override { return SkinnedMeshObject; }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssSkinnedMesh; }
    void CloneHelper(const CssSkinnedMesh &source);
    CssObject3D *Clone() const override;
    void *GetpRef(int) override;
    int AnimateRefs(int, int, int) override;
    int GetPosScaleBias(float *, CssVector3D *) const override;
    void SetSkeleton(CssGroup *);
    CssGroup *GetSkeleton() { return static_cast<CssGroup *>(first_child); }
    const CssGroup *GetSkeleton() const { return static_cast<const CssGroup *>(first_child); }
    void checkBone(const CssNode *) const;
    int AddBone(CssNode *);
    void AddTransform(CssNode *, int, int, int);
    void GetBoneTransform(CssNode *, CssTransform *) const;
    int GetBoneVertices(CssNode *, int, SwvVertexIndex *, int, float *) const;
    bool ArePaletteEntriesEqual(const SssPaletteEntry &, const SssPaletteEntry &) const;
    int AddUniquePaletteEntry(const SssPaletteEntry &) const;
    int FindHeaviestBones(uint16_t vertex, int selected[2]) const;
    void Prepare() const;
    void ResetCache() const;
    const CssMatrix &GetCachedMatrix(const SssBoneNode &) const;
    const CssMatrix &GetCachedMatrix(const SssBoneData &) const;
    const CssMatrix &GetPaletteMatrix(int) const;
    void SetScaleBias(float, const CssVector3D &) const;
    void ComputePreScaledMatVertices(int magnitude) const;
    void ComputeIntArrayVertices(CssVertexArray *, const CssVertexArray *) const;
    void ComputeIntArrayNormals(CssVertexArray *, const CssVertexArray *, int, int) const;
    CssVertexBuffer *GetTransformedVertexBuffer(bool normals) const;
};

#endif
