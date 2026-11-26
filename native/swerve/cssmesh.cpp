#include "geometry_internal.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssMesh::Construct(CssVertexBuffer *vertices, int index_count, CssRefCount *const *indices, int appearance_count, CssRefCount *const *appearances)
{
    if (index_count <= 0 || (appearances && appearance_count < index_count)) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    this->vertices = retain(vertices);
    zero_pointers(this->indices, index_count);
    zero_pointers(this->appearances, index_count);
    for (int i = 0; i < index_count; ++i) {
        if (!indices[i]) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
        this->indices[i] = retain(lookup<CssIndexBuffer>(indices[i]));
        if (appearances) this->appearances[i] = retain(lookup<CssAppearance>(appearances[i]));
    }
}

void CssMesh::Construct(CssVertexBuffer *vertices, CssIndexBuffer *indices, CssAppearance *appearance)
{
    auto *ib = static_cast<CssRefCount *>(indices);
    auto *app = static_cast<CssRefCount *>(appearance);
    Construct(vertices, 1, &ib, 1, &app);
}

CssIndexBuffer *CssMesh::GetIndexBuffer(int index) const
{
    check_index(index, indices.Size());
    return indices[index];
}

CssAppearance *CssMesh::GetAppearance(int index) const
{
    check_index(index, appearances.Size());
    return appearances[index];
}

void CssMesh::SetAppearance(int index, CssAppearance *appearance)
{
    check_index(index, appearances.Size());
    CssAppearance *&slot = appearances[index];
    slot = static_cast<CssAppearance *>(CssRefCount::Assign(slot, appearance));
}

void CssMesh::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssNode::SerializeIn(r);
    vertices = retain(static_cast<CssVertexBuffer *>(r.ReadObjectRefTypeChecked(VertexBufferObject)));
    if (!vertices) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    int n = r.ReadCount(8);
    zero_pointers(indices, n);
    zero_pointers(appearances, n);
    for (int i = 0; i < n; ++i) {
        indices[i] = retain(static_cast<CssIndexBuffer *>(r.ReadObjectRefTypeChecked(TriangleStripArrayObject)));
        if (!indices[i]) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        appearances[i] = retain(static_cast<CssAppearance *>(r.ReadObjectRefTypeChecked(AppearanceObject)));
    }
}
CssMesh::~CssMesh()
{
    if (vertices) vertices->Release();
    release_pointers(indices);
    release_pointers(appearances);
}
void *CssMesh::GetpRef(int i)
{
    switch (i) {
    case 0: return vertices;
    case 1: case 3: return SWV_REFERENCE_ARRAY;
    case 2: return &indices;
    case 4: return &appearances;
    default: return CssObject3D::GetpRef(i - 5);
    }
}

int CssMesh::AnimateRefs(int time, int valid, int stamp)
{
    valid = animate_ref(vertices, time, valid, stamp);
    for (int i = 0; i < appearances.size; ++i)
        valid = animate_ref(appearances[i], time, valid, stamp);
    return valid;
}

int CssMesh::GetPosScaleBias(float *scale, CssVector3D *bias) const
{
    if (!vertices) return 0;
    if (scale) *scale = vertices->position_scale;
    if (bias) memcpy(bias, vertices->position_bias, 3 * sizeof(float));
    return !!(scale || bias);
}
void CssMesh::CloneHelper(const CssMesh &source)
{
    CssNode::CloneHelper(source);
    vertices = retain(source.vertices);
    copy_pointers(indices, source.indices);
    copy_pointers(appearances, source.appearances);
}
CssObject3D *CssMesh::Clone() const
{
    CssHeapPtr<CssMesh> out(static_cast<CssMesh *>(FactoryCreate()));
    out->CloneHelper(*this);
    out->FixupAlignmentReferences(this, this, out.get());
    return out.release();
}

CssVertexBuffer *CssMesh::GetRenderingVertexBuffer(bool) const
{
    if (!vertices || !vertices->positions) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    return vertices;
}
