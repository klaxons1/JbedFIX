#include "geometry_internal.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "engine.h"
#include "cssfixed1616.hpp"

void *CssMorphingMesh::GetpRef(int i)
{
    if (i == 0) return SWV_REFERENCE_ARRAY;
    if (i == 1) return &targets;
    return CssMesh::GetpRef(i - 2);
}

int CssMorphingMesh::AnimateRefs(int time, int valid, int stamp)
{
    for (int i = 0; i < targets.size; ++i)
        valid = animate_ref(targets[i], time, valid, stamp);
    return CssMesh::AnimateRefs(time, valid, stamp);
}

void CssMorphingMesh::Construct(CssVertexBuffer *vertices, int target_count, CssRefCount *const *targets, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances)
{
    if (target_count <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    CssMesh::Construct(vertices, index_count, indices, appearance_count, appearances);
    zero_pointers(this->targets, target_count);
    weights.SetSize(target_count);
    for (int i = 0; i < target_count; ++i) {
        if (!targets[i]) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
        this->targets[i] = retain(lookup<CssVertexBuffer>(targets[i]));
        weights[i] = 0;
    }
}

void CssMorphingMesh::Construct(CssVertexBuffer *vertices, int target_count, CssRefCount *const *targets, CssIndexBuffer *indices, CssAppearance *appearance)
{
    auto *ib = static_cast<CssRefCount *>(indices);
    auto *app = static_cast<CssRefCount *>(appearance);
    Construct(vertices, target_count, targets, 1, &ib, 1, &app);
}

void CssMorphingMesh::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssMesh::SerializeIn(r);
    int n = r.ReadCount(8);
    zero_pointers(targets, n);
    weights.SetSize(n);
    for (int i = 0; i < n; ++i) {
        targets[i] = retain(static_cast<CssVertexBuffer *>(r.ReadObjectRefTypeChecked(VertexBufferObject)));
        if (!targets[i]) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        weights[i] = r.ReadReal();
    }
}
CssObject3D *CssMorphingMesh::Clone() const
{
    CssHeapPtr<CssMorphingMesh> out(static_cast<CssMorphingMesh *>(FactoryCreate()));
    out->CloneHelper(*this);
    out->FixupAlignmentReferences(this, this, out.get());
    return out.release();
}

void CssMorphingMesh::CloneHelper(const CssMorphingMesh &source)
{
    CssMesh::CloneHelper(source);
    copy_pointers(targets, source.targets);
    weights = source.weights;
}
CssMorphingMesh::~CssMorphingMesh()
{
    if (morphed) morphed->Release();
    release_pointers(targets);
}
bool CssMorphingMesh::HasAnimatableProperty(int id) const { return id == 266 || CssNode::HasAnimatableProperty(id); }
void CssMorphingMesh::SetProperty(int id, int n, float *v)
{
    if (id != 266) CssNode::SetProperty(id, n, v);
    dirty = 1;
}

CssVertexArray *CssMorphingMesh::GetVertexArrayOfType(CssVertexBuffer *b, EssVertexArrayType id)
{
    switch (id) {
    case 0: return b->positions;
    case 1: return b->colors;
    case 2: return b->normals;
    default: return b->texcoords[id - 3];
    }
}

void CssMorphingMesh::AddMorphedTarget(const CssVertexArray *a, int n, float weight, int offset, int width) const
{
    float bias = (float)saturatingTruncate((float)(offset << 8) * weight);
    for (int i = 0; i < n; ++i) {
        unsigned raw = width == 1 ? (uint8_t)(a->bytes[i] + offset)
                                     : (uint16_t)(((uint16_t *)a->bytes.data)[i] + offset);
        float contribution = (float)saturatingTruncate((float)(raw << 8) * weight) - bias;
        work[i] = saturatingTruncate((float)work[i] + contribution);
    }
}
CssVertexArray *CssMorphingMesh::GetMorphedVertexArray(EssVertexArrayType id) const
{
    CssVertexArray *base = GetVertexArrayOfType(vertices, id);
    if (!base) {
        for (int i = 0; i < targets.size; ++i)
            if (GetVertexArrayOfType(targets[i], id)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        return NULL;
    }
    if (!targets.size || !GetVertexArrayOfType(targets[0], id)) return base;
    int n = base->count * base->components;
    unsigned bias = id == 1 ? 0 : 1u << (8 * base->width - 1);
    work.SetSize(n);
    memset(work.data, 0, (size_t)n * sizeof(int32_t));
    float sum = 0;
    for (int i = 0; i < targets.size; ++i) {
        float w = weights[i];
        if (!w) continue;
        CssVertexArray *a = GetVertexArrayOfType(targets[i], id);
        if (!a || base->width != a->width || base->count != a->count || base->components != a->components)
            g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        if (a != base) {
            sum += w;
            AddMorphedTarget(a, n, w, bias, base->width);
        }
    }
    if (sum != 1) AddMorphedTarget(base, n, 1.f - sum, bias, base->width);
    CssVertexArray *out = GetVertexArrayOfType(morphed, id);
    if (!out) out = make_vertex_array(base->count, base->components, base->width);
    out->Set24(0, base->count, n, static_cast<const int *>(work.data), id == Colors);
    return out;
}
CssVertexBuffer *CssMorphingMesh::GetRenderingVertexBuffer(bool normals) const
{
    (void)normals;
    if (!dirty) return morphed;
    CssVertexBuffer *v = CssMesh::GetRenderingVertexBuffer(0);
    if (!morphed) morphed = retain(new CssVertexBuffer);
    SetMorphedDefaultColor();
    CssHeapPtr<CssVertexArray> positions(GetMorphedVertexArray(Positions));
    morphed->SetPositions(positions.get(), v->position_scale, 3, v->position_bias);
    positions.release();
    CssHeapPtr<CssVertexArray> normals_array(GetMorphedVertexArray(Normals));
    morphed->SetNormals(normals_array.get());
    normals_array.release();
    CssHeapPtr<CssVertexArray> colors(GetMorphedVertexArray(Colors));
    morphed->SetColors(colors.get());
    colors.release();
    for (int i = 0; i < 2; ++i) {
        CssHeapPtr<CssVertexArray> texcoords(GetMorphedVertexArray(static_cast<EssVertexArrayType>(TexCoords0 + i)));
        morphed->SetTexCoords(i, texcoords.get(), v->texture_scale[i], 3, v->texture_bias[i]);
        texcoords.release();
    }
    dirty = 0;
    return morphed;
}

void CssMorphingMesh::GetWeightsRef(int *count, float **out)
{
    if (count) *count = weights.Size();
    if (out) *out = static_cast<float *>(weights.data);
}

void CssMorphingMesh::GetWeights(int n, float *out) const
{
    if (n < weights.size) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    memcpy(out, weights.data, (size_t)weights.size * sizeof(float));
}

void CssMorphingMesh::SetWeights(int n, const float *in)
{
    if (n < weights.size) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (int i = 0; i < weights.size; ++i) weights[i] = g_ValidateFloat(in[i]);
    dirty = 1;
}

void CssMorphingMesh::SetMorphedDefaultColor() const
{
    uint32_t original = vertices->GetDefaultColor();
    int channels[4];
    for (int j = 0; j < 4; ++j) channels[j] = (original >> (8 * j)) & 255;
    for (int i = 0; i < targets.size; ++i) {
        float w = weights[i];
        if (!w) continue;
        for (int j = 0; j < 4; ++j) {
            int source = (original >> (8 * j)) & 255;
            int target = (targets[i]->GetDefaultColor() >> (8 * j)) & 255;
            channels[j] += saturatingTruncate((target - source) * w);
        }
    }
    uint32_t result = 0;
    for (int j = 0; j < 4; ++j) {
        unsigned value = channels[j] < 0 ? 0 : channels[j] > 255 ? 255 : static_cast<unsigned>(channels[j]);
        result |= value << (8 * j);
    }
    morphed->SetDefaultColor(result);
}
