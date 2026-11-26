#include "geometry_internal.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "engine.h"
#include "cssfixed1616.hpp"
#include <cmath>
#include <new>

void *CssSkinnedMesh::GetpRef(int i)
{
    return i ? CssMesh::GetpRef(i - 1) : first_child;
}

int CssSkinnedMesh::AnimateRefs(int time, int valid, int stamp)
{
    return CssMesh::AnimateRefs(time, animate_ref(first_child, time, valid, stamp), stamp);
}

void CssSkinnedMesh::SetSkeleton(CssGroup *skeleton)
{
    if (!skeleton) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    if (skeleton->Type() != GroupObject) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (skeleton->pParent()) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (skeleton->IsAncestorOf(this)) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    skeleton->LinkAsFirstChildOf(this);
    mapped = 0;
    vertices_dirty = 1;
}
void CssSkinnedMesh::checkBone(const CssNode *node) const
{
    if (!node) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    if (node != GetSkeleton() && !node->IsDescendantOf(GetSkeleton())) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}
int CssSkinnedMesh::AddBone(CssNode *bone)
{
    for (int i = 0; i < bones.size; ++i)
        if (bones[i].node == bone) return i;
    for (CssNode *ancestor = bone;; ancestor = ancestor->pParent()) {
        ancestor->SetUnlinkable();
        if (ancestor == pFirstChild()) break;
    }
    SssBoneNode &entry = bones.append();
    entry.node = bone;
    entry.dirty = 1;
    return bones.size - 1;
}
void CssSkinnedMesh::AddTransform(CssNode *bone, int weight, int first, int count)
{
    if (!bone) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    if (weight <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    checkBone(bone);
    if (count <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    int end = first + count;
    if (first < 0 || end >= 65536) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    int i = AddBone(bone);
    ranges.Append({weight, static_cast<uint16_t>(first), static_cast<uint16_t>(count),
                       static_cast<uint16_t>(i)});
    CssMatrix *bind = &bones[i].bind;
    BuildTransformMatrix(this, bone, bind);
    bind->m[3] = bind->m[7] = bind->m[11] = 0;
    bind->m[15] = 1;
    unsigned last = static_cast<uint16_t>(end - 1);
    if (last > last_vertex) last_vertex = last;
    mapped = 0;
    vertices_dirty = 1;
}
void CssSkinnedMesh::GetBoneTransform(CssNode *bone, CssTransform *transform) const
{
    checkBone(bone);
    if (!transform) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    for (int i = 0; i < bones.size; ++i) {
        if (bones[i].node == bone) {
            transform->matrix = bones[i].bind;
            break;
        }
    }
}

int CssSkinnedMesh::GetBoneVertices(CssNode *bone, int index_capacity, SwvVertexIndex *indices,
                                    int weight_capacity, float *weights) const
{
    checkBone(bone);
    Prepare();
    int count = 0;
    for (int i = 0; i < vertex_blends.size; ++i) {
        const SssPaletteEntry &entry = blends[vertex_blends[i]];
        for (int j = 0; j < 2; ++j) {
            if (entry.range[j] == UINT16_MAX) continue;
            const SssBoneData &range = ranges[entry.range[j]];
            if (bones[range.bone].node != bone) continue;
            if (indices && weights) {
                if (count >= index_capacity || count >= weight_capacity) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
                indices[count] = i;
                weights[count] = range.weight * entry.reciprocal;
            }
            ++count;
        }
    }
    return count;
}

void CssSkinnedMesh::Construct(CssVertexBuffer *vertices, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances, CssGroup *skeleton)
{
    CssMesh::Construct(vertices, index_count, indices, appearance_count, appearances);
    SetSkeleton(skeleton);
}

void CssSkinnedMesh::Construct(CssVertexBuffer *vertices, CssIndexBuffer *indices, CssAppearance *appearance, CssGroup *skeleton)
{
    auto *ib = static_cast<CssRefCount *>(indices);
    auto *app = static_cast<CssRefCount *>(appearance);
    Construct(vertices, 1, &ib, 1, &app, skeleton);
}

void CssSkinnedMesh::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssMesh::SerializeIn(r);
    SetSkeleton(static_cast<CssGroup *>(r.ReadObjectRefTypeChecked(GroupObject)));
    int n = r.ReadCount(16);
    for (int i = 0; i < n; ++i) {
        CssNode *bone = r.ReadObjectRefNode(false);
        unsigned first = r.ReadUInt(), count = r.ReadUInt();
        int weight = (int)r.ReadUInt();
        AddTransform(bone, weight, (int)first, (int)count);
    }
}
CssObject3D *CssSkinnedMesh::Clone() const
{
    CssHeapPtr<CssSkinnedMesh> out(static_cast<CssSkinnedMesh *>(FactoryCreate()));
    out->CloneHelper(*this);
    out->FixupAlignmentReferences(this, this, out.get());
    return out.release();
}

void CssSkinnedMesh::CloneHelper(const CssSkinnedMesh &source)
{
    CssMesh::CloneHelper(source);
    const CssGroup *skeleton = source.GetSkeleton();
    if (skeleton) {
        auto *copy = static_cast<CssGroup *>(skeleton->Clone());
        copy->UnLink();
        SetSkeleton(copy);
    } else {
        SetSkeleton(nullptr);
    }
    ranges.SetSize(0);
    bones.SetSize(0);
    blends.SetSize(0);
    vertex_blends.SetSize(0);
    for (int i = 0; i < source.ranges.Size(); ++i) {
        const SssBoneData &range = source.ranges[i];
        const CssNode *bone = source.bones[range.bone].node;
        CssNode *copy = FindCorresponding(bone, source.GetSkeleton(), GetSkeleton());
        AddTransform(copy, range.weight, range.first, range.count);
    }
    mapped = 0;
    matrices_dirty = 1;
    vertices_dirty = 1;
    last_vertex = source.last_vertex;
}
CssSkinnedMesh::~CssSkinnedMesh()
{
    if (deformed) deformed->Release();
}

CssSkinnedMesh::CssSkinnedMesh() : precision(1e+36f)
{
    position_matrix.Identity();
}

bool CssSkinnedMesh::ArePaletteEntriesEqual(const SssPaletteEntry &left, const SssPaletteEntry &right) const
{
    // The original compares four halfwords, including the first word of the identity matrix.
    uint16_t a[4], b[4];
    memcpy(a, &left, sizeof a);
    memcpy(b, &right, sizeof b);
    for (int i = 0; i < 4; ++i) {
        if (a[i] == b[i]) continue;
        if (a[i] == UINT16_MAX || b[i] == UINT16_MAX) return false;
        const auto &x = ranges[a[i]], &y = ranges[b[i]];
        if (x.weight != y.weight || x.bone != y.bone) return false;
    }
    return true;
}

int CssSkinnedMesh::AddUniquePaletteEntry(const SssPaletteEntry &entry) const
{
    for (int i = 1; i < blends.size; ++i)
        if (ArePaletteEntriesEqual(blends[i], entry)) return i;
    int index = blends.size;
    blends.Append(entry);
    return index;
}

/* 0x2ed548 retains two influences. Once full, a new range must exceed
 * the running maximum before it may replace the weaker of the pair. */
int CssSkinnedMesh::FindHeaviestBones(uint16_t vertex, int selected[2]) const
{
    int found = 0, highest = 0;
    for (int i = 0; i < ranges.size; ++i) {
        const SssBoneData &r = ranges[i];
        if (r.first >= vertices->count || !r.count || r.first + r.count > vertices->count)
            g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        if (vertex < r.first || vertex >= r.first + r.count) continue;
        int slot;
        if (found < 2) {
            slot = found++;
        } else {
            if (r.weight <= highest) continue;
            slot = ranges[selected[1]].weight < ranges[selected[0]].weight;
        }
        selected[slot] = i;
        if (r.weight > highest) highest = r.weight;
    }
    return found;
}
void CssSkinnedMesh::Prepare() const
{
    if (mapped || !vertices || !vertices->positions || !first_child) return;
    blends.SetSize(0);
    SssPaletteEntry empty;
    empty.range[0] = empty.range[1] = UINT16_MAX;
    empty.reciprocal = 1;
    empty.dirty = empty.normals_dirty = 1;
    memset(empty.fixed, 0, sizeof empty.fixed);
    empty.matrix.Identity();
    blends.Append(empty);
    vertex_blends.SetSize(vertices->count);
    memset(vertex_blends.data, 0, vertex_blends.size * sizeof(uint16_t));
    for (int v = 0; v < vertices->count; ++v) {
        int selected[2] = {};
        int count = FindHeaviestBones(static_cast<uint16_t>(v), selected);
        SssPaletteEntry entry = empty;
        uint32_t weight = 0;
        for (int i = 0; i < count; ++i) {
            entry.range[i] = static_cast<uint16_t>(selected[i]);
            weight += ranges[selected[i]].weight;
        }
        if (static_cast<int32_t>(weight) > 0) entry.reciprocal = 1.0f / static_cast<int32_t>(weight);
        if (count) vertex_blends[v] = static_cast<uint16_t>(AddUniquePaletteEntry(entry));
    }
    mapped = matrices_dirty = vertices_dirty = 1;
    have_normals = 0;
}

void CssSkinnedMesh::ResetCache() const
{
    for (int i = 0; i < bones.size; ++i) {
        const SssBoneNode *bone = &bones[i];
        for (CssNode *p = bone->node; p && p != this; p = p->pParent())
            if (p->transform_flags & SkinningDirty) { bone->dirty = 1; break; }
    }
    for (int i = 0; i < blends.size; ++i) {
        SssPaletteEntry *b = &blends[i];
        for (int j = 0; j < 2 && b->range[j] != UINT16_MAX; ++j)
            if (bones[ranges[b->range[j]].bone].dirty) b->dirty = 1;
        if (b->dirty) matrices_dirty = 1;
    }
    vertices_dirty |= matrices_dirty;
}
const CssMatrix &CssSkinnedMesh::GetCachedMatrix(const SssBoneNode &bone) const
{
    if (bone.dirty) {
        BuildTransformMatrix(bone.node, this, &bone.current);
        bone.current *= bone.bind;
        bone.dirty = 0;
        for (CssNode *p = bone.node; p != this; p = p->pParent()) p->transform_flags &= ~SkinningDirty;
    }
    return bone.current;
}

const CssMatrix &CssSkinnedMesh::GetCachedMatrix(const SssBoneData &range) const
{
    return GetCachedMatrix(bones[range.bone]);
}

const CssMatrix &CssSkinnedMesh::GetPaletteMatrix(int index) const
{
    Prepare();
    SssPaletteEntry &blend = blends[index];
    CssMatrix &matrix = blend.matrix;
    if (!blend.dirty) return matrix;
    if (index == 0) {
        matrix.Identity();
    } else {
        const SssBoneData &first = ranges[blend.range[0]];
        matrix = GetCachedMatrix(first);
        if (blend.range[1] != UINT16_MAX) {
            const SssBoneData &second = ranges[blend.range[1]];
            CssMatrix other = GetCachedMatrix(second);
            float a = static_cast<float>(first.weight) * blend.reciprocal;
            float b = static_cast<float>(second.weight) * blend.reciprocal;
            matrix.Scale(a, a, a);
            other.Scale(b, b, b);
            matrix += other;
            matrix.m[3] = matrix.m[7] = matrix.m[11] = 0;
            matrix.m[15] = 1;
            matrix.ResetMatrixType();
        }
    }
    matrix *= position_matrix;
    matrices_dirty = 0;
    return matrix;
}

void CssSkinnedMesh::SetScaleBias(float next_scale, const CssVector3D &next_bias) const
{
    if (scale == next_scale && fabsf(bias[0] - next_bias.x) <= realEpsilon &&
        fabsf(bias[1] - next_bias.y) <= realEpsilon && fabsf(bias[2] - next_bias.z) <= realEpsilon)
        return;
    matrices_dirty = 1;
    scale = next_scale;
    memcpy(bias, &next_bias, sizeof bias);
    position_matrix = CssMatrix(scale, scale, scale);
    memcpy(position_matrix.m + 12, bias, sizeof bias);
    position_matrix.ResetMatrixType();
    for (int i = 0; i < blends.size; ++i) blends[i].dirty = blends[i].normals_dirty = 1;
}

void CssSkinnedMesh::ComputePreScaledMatVertices(int magnitude) const
{
    bound = 0;
    for (int i = 0; i < blends.size; ++i) {
        SssPaletteEntry *b = &blends[i];
        if (!b->dirty) continue;
        GetPaletteMatrix(i);
        for (int row = 0; row < 3; ++row) {
            const float *m = b->matrix.m + row;
            float candidate = magnitude * (fabsf(m[0]) + fabsf(m[4]) + fabsf(m[8])) + fabsf(m[12]);
            if (candidate > bound) bound = candidate * 1.25f;
        }
    }
    float next_precision = bound ? 32000.f / bound : precision;
    bool rescale = next_precision < precision;
    if (rescale) precision = next_precision;
    for (int i = 0; i < blends.size; ++i) {
        SssPaletteEntry *b = &blends[i];
        if (!b->dirty && !rescale) continue;
        for (int c = 0; c < 4; ++c)
            for (int r = 0; r < 3; ++r)
                b->fixed[3*c+r] = toFixed16(b->matrix.m[4 * c + r] * precision);
        b->dirty = b->normals_dirty = 1;
    }
}
void CssSkinnedMesh::ComputeIntArrayVertices(CssVertexArray *dest, const CssVertexArray *source) const
{
    Prepare();
    const uint16_t *ids = static_cast<uint16_t *>(vertex_blends.data);
    int16_t *dst = (int16_t *)dest->bytes.data;
    for (int i = 0; i < vertex_blends.size; ++i) {
        SssPaletteEntry *b = &blends[ids[i]];
        if (!b->dirty) continue;
        int x = source->Element(i, 0);
        int y = source->Element(i, 1);
        int z = source->Element(i, 2);
        for (int r = 0; r < 3; ++r) {
            const int32_t *f = b->fixed + r;
            int32_t sum = x * f[0] + y * f[3] + z * f[6] + f[9];
            dst[3 * i + r] = static_cast<int16_t>(sum >> 16);
        }
    }
}

void CssSkinnedMesh::ComputeIntArrayNormals(CssVertexArray *dest, const CssVertexArray *source,
                                           int matrix_shift, int vector_shift) const
{
    Prepare();
    auto *dst = static_cast<int16_t *>(dest->bytes.data);
    for (int i = 0; i < vertices->count; ++i) {
        const auto &entry = blends[vertex_blends[i]];
        if (!entry.dirty && !entry.normals_dirty) continue;
        int32_t normal[3];
        for (int c = 0; c < 3; ++c)
            normal[c] = source->Element(i, c) << vector_shift;
        for (int r = 0; r < 3; ++r) {
            int32_t sum = 0;
            for (int c = 0; c < 3; ++c)
                sum += normal[c] * (entry.fixed[c * 3 + r] >> matrix_shift);
            dst[3 * i + r] = static_cast<int16_t>(sum >> 16);
        }
    }
}

CssVertexBuffer *CssSkinnedMesh::GetTransformedVertexBuffer(bool normals) const
{
    Prepare();
    if (!vertices_dirty && (!normals || have_normals)) return deformed;
    CssVertexBuffer *v = CssMesh::GetRenderingVertexBuffer(0);
    if (!deformed) deformed = retain(new CssVertexBuffer);
    CssVertexBuffer *out = deformed;
    if (!out->positions) {
        CssHeapPtr<CssVertexArray> positions(CssVertexArray::Create());
        positions->Construct(v->positions->count, v->positions->components, 2);
        out->SetPositions(positions.get(), v->position_scale, 3, v->position_bias);
        positions.release();
        if (v->colors) out->SetColors(v->colors);
        for (int unit = 0; unit < 2; ++unit) {
            if (v->texcoords[unit])
                out->SetTexCoords(unit, v->texcoords[unit], v->texture_scale[unit], 3, v->texture_bias[unit]);
        }
    }
    out->color = v->color;
    SetScaleBias(v->position_scale, {v->position_bias[0], v->position_bias[1], v->position_bias[2]});
    ComputePreScaledMatVertices(v->positions->GetMaxNumber());
    ComputeIntArrayVertices(out->positions, v->positions);
    float next_scale = 1.f / precision;
    out->positions->dirty = 1;
    bool scale_changed = out->position_scale != next_scale;
    out->position_scale = next_scale;
    memset(out->position_bias, 0, sizeof out->position_bias);
    vertices_dirty = 0;
    if (scale_changed) SetMatrixCacheDirty();
    for (int i = 0; i < blends.size; ++i) blends[i].dirty = 0;
    return out;
}
int CssSkinnedMesh::GetPosScaleBias(float *out_scale, CssVector3D *out_bias) const
{
    if (!deformed) return 0;
    if (out_scale) *out_scale = deformed->position_scale;
    if (out_bias) memcpy(out_bias, deformed->position_bias, 3 * sizeof(float));
    return out_scale || out_bias;
}
