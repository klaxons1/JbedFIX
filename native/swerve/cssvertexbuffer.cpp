#include "geometry_internal.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "engine.h"
#include <initializer_list>

bool CssVertexBuffer::IsSoleArray(const CssVertexArray *array) const
{
    const CssVertexArray *only = nullptr;
    int active = 0;
    for (const auto *slot : {positions, normals, colors, texcoords[0], texcoords[1]}) {
        if (slot) { only = slot; ++active; }
    }
    return !active || (active == 1 && array == only);
}

void CssVertexBuffer::UpdateVertexCount()
{
    if (!positions && !colors && !normals && !texcoords[0] && !texcoords[1]) count = 0;
}

void CssVertexBuffer::SetVertexArray(CssVertexArray **slot, CssVertexArray *array)
{
    if (array && !IsSoleArray(*slot) && count && count != array->count) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (*slot != array) {
        retain(array);
        if (*slot) (*slot)->Release();
        *slot = array;
        if (array) count = array->count;
        else UpdateVertexCount();
    }
}

void CssVertexBuffer::SetNormals(CssVertexArray *a)
{
    if (a && a->components != 3) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    SetVertexArray(&normals, a);
    normal_scale = a ? 1.0f / (a->width == 1 ? 127.5f : 32767.5f) : 1.0f;
    for (unsigned i = 0; i < 3; ++i) normal_bias[i] = a ? normal_scale * 0.5f : 0;
}
CssVertexBuffer::~CssVertexBuffer()
{
    if (positions) positions->Release();
    if (normals) normals->Release();
    if (colors) colors->Release();
    for (int i = 0; i < 2; ++i) if (texcoords[i]) texcoords[i]->Release();
}
void *CssVertexBuffer::GetpRef(int i)
{
    void *slots[] = {positions, normals, colors, texcoords[0], texcoords[1]};
    return (unsigned)i < 5 ? slots[i] : CssObject3D::GetpRef(i - 5);
}
CssObject3D *CssVertexBuffer::Clone() const
{
    CssHeapPtr<CssVertexBuffer> out(static_cast<CssVertexBuffer *>(FactoryCreate()));
    out->CloneHelper(*this);
    return out.release();
}

void CssVertexBuffer::CloneHelper(const CssVertexBuffer &source)
{
    CssObject3D::CloneHelper(source);
    count = source.count;
    color = source.color;
    positions = retain(source.positions);
    colors = retain(source.colors);
    normals = retain(source.normals);
    for (unsigned unit = 0; unit < 2; ++unit) {
        texcoords[unit] = retain(source.texcoords[unit]);
        texture_scale[unit] = source.texture_scale[unit];
        memcpy(texture_bias[unit], source.texture_bias[unit], sizeof texture_bias[unit]);
    }
    position_scale = source.position_scale;
    normal_scale = source.normal_scale;
    memcpy(position_bias, source.position_bias, sizeof position_bias);
    memcpy(normal_bias, source.normal_bias, sizeof normal_bias);
}
void CssVertexBuffer::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssObject3D::SerializeIn(reader);
    reader.ReadColorRGBA(color, true);
    bool have_count = false;
    auto check_count = [&](const CssVertexArray *array) {
        if (have_count && count != array->cEntries()) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        count = array->cEntries();
        have_count = true;
    };
    auto read_array = [&]() {
        return static_cast<CssVertexArray *>(reader.ReadObjectRefTypeChecked(VertexArrayObject));
    };
    positions = static_cast<CssVertexArray *>(CssRefCount::Assign(positions, read_array()));
    if (positions) check_count(positions);
    for (float &component : position_bias) component = reader.ReadReal();
    position_scale = reader.ReadReal();
    if (auto *normal = read_array()) {
        check_count(normal);
        SetNormals(normal);
    }
    colors = static_cast<CssVertexArray *>(CssRefCount::Assign(colors, read_array()));
    if (colors) check_count(colors);
    int units = reader.ReadInt();
    for (int i = 0; i < units; ++i) {
        CssVertexArray *tex = read_array();
        if (!tex) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        float bias[] = {reader.ReadReal(), reader.ReadReal(), reader.ReadReal()};
        float scale = reader.ReadReal();
        if (i >= 2) continue;
        texcoords[i] = static_cast<CssVertexArray *>(CssRefCount::Assign(texcoords[i], tex));
        check_count(tex);
        memcpy(texture_bias[i], bias, sizeof bias);
        texture_scale[i] = scale;
    }
}
bool CssVertexBuffer::HasAnimatableProperty(int id) const
{
    return id == CssAnimationTrack::Alpha || id == CssAnimationTrack::Color || CssObject3D::HasAnimatableProperty(id);
}

void CssVertexBuffer::SetProperty(int id, int n, float *v)
{
    switch (id) {
    case CssAnimationTrack::Alpha: color.SetAlpha(clamp(v[0], 1)); break;
    case CssAnimationTrack::Color: color.SetReals(v[0], v[1], v[2]); break;
    default: CssObject3D::SetProperty(id, n, v); break;
    }
}

void CssVertexBuffer::SetColors(CssVertexArray *a)
{
    if (a && (a->width != 1 || (a->components != 3 && a->components != 4))) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    SetVertexArray(&colors, a);
}

void CssVertexBuffer::SetPositions(CssVertexArray *a, float scale, int n, const float *bias)
{
    if (a) {
        if (a->components != 3 || (bias && n < 3)) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        position_scale = scale;
        for (int i = 0; i < 3; ++i) position_bias[i] = bias ? g_ValidateFloat(bias[i]) : 0;
    }
    SetVertexArray(&positions, a);
}

void CssVertexBuffer::SetTexCoords(int unit, CssVertexArray *a, float scale, int n, const float *bias)
{
    if ((unsigned)unit >= 2) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    if (a) {
        if ((a->components != 2 && a->components != 3) || (bias && n < a->components)) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        texture_scale[unit] = scale;
        for (int i = 0; i < 3; ++i)
            texture_bias[unit][i] = bias && i < a->components ? g_ValidateFloat(bias[i]) : 0;
    }
    SetVertexArray(&texcoords[unit], a);
}

CssVertexArray *CssVertexBuffer::GetPositions(int n, float *scale_bias) const
{
    if (scale_bias && n < 4) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (scale_bias && positions) {
        *scale_bias = position_scale;
        memcpy(scale_bias + 1, position_bias, sizeof position_bias);
    }
    return positions;
}

CssVertexArray *CssVertexBuffer::GetTexCoords(int unit, int n, float *scale_bias) const
{
    if ((unsigned)unit >= 2) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    CssVertexArray *a = texcoords[unit];
    if (scale_bias && n < (a ? a->components + 1 : 3)) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (scale_bias && a) {
        *scale_bias = texture_scale[unit];
        memcpy(scale_bias + 1, texture_bias[unit], a->components * sizeof(float));
    }
    return a;
}
