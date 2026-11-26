#include "geometry_class.hpp"
#include "graphics3d_state.h"
#include "cssserializebufferobjectsin.hpp"
#include "platform.h"

void CssVertexArray::TransformVector(int index, const CssIntMatrix &matrix,
                                     CssFixedVector3D *out, SwvFixedWord *w) const
{
    auto transform = [&](const auto *data) {
        const auto *v = data + components * index;
        if (!w && components == 3)
            matrix.Transform3Fixed(v, &out->x);
        else if (components == 2) {
            out->z = 0;
            matrix.Transform2Fixed(v, &out->x, w);
        } else
            matrix.Transform3Fixed4(v, &out->x, w, 1);
    };
    if (width == 1) transform(static_cast<const int8_t *>(bytes.data));
    else transform(static_cast<const int16_t *>(bytes.data));
}

void CssVertexArray::TransformVectorsRange(int first, int end, const CssIntMatrix &matrix,
                                           CssFixedVector3D *positions, SwvFixedWord *w) const
{
    auto transform = [&](const auto *data) {
        const auto *v = data + first * components;
        if (!w && components == 3) {
            for (int i = first; i < end; ++i, v += 3)
                matrix.Transform3Fixed(v, &positions[i].x);
        } else if (components == 2) {
            for (int i = first; i < end; ++i, v += 2) {
                positions[i].z = 0;
                matrix.Transform2Fixed(v, &positions[i].x, &w[i]);
            }
        } else
            matrix.Transform3Fixed4(v, &positions[first].x, &w[first], end - first);
    };
    if (width == 1) transform(static_cast<const int8_t *>(bytes.data));
    else transform(static_cast<const int16_t *>(bytes.data));
}

void CssVertexArray::TransformNormal(int index, const CssIntMatrix &matrix, CssFixedVector3D *out) const
{
    int offset = index * components;
    if (width == 1) matrix.Transform3NFixed(static_cast<const int8_t *>(bytes.data) + offset, &out->x);
    else matrix.Transform3NFixed(static_cast<const int16_t *>(bytes.data) + offset, &out->x);
}

int CssVertexArray::Element(int vertex, int channel) const
{
    int i = vertex * components + channel;
    return width == 1 ? ((const int8_t *)bytes.data)[i] : ((const int16_t *)bytes.data)[i];
}

int CssVertexArray::GetMaxNumber() const
{
    if (dirty) {
        magnitude = 0;
        for (unsigned c = 0; c < 3; ++c) {
            minimum[c] = 65535;
            maximum[c] = -65535;
        }
        for (int v = 0; v < count; ++v) {
            for (int c = 0; c < components; ++c) {
                int x = Element(v, c);
                if (components == 3) {
                    if (x < minimum[c]) minimum[c] = x;
                    if (x > maximum[c]) maximum[c] = x;
                }
                int mag = x < 0 ? -x : x;
                if (mag > magnitude) magnitude = mag;
            }
        }
        dirty = 0;
    }
    return magnitude;
}

CssObject3D *CssVertexArray::Clone() const
{
    CssHeapPtr<CssVertexArray> out(static_cast<CssVertexArray *>(FactoryCreate()));
    out->CloneHelper(*this);
    return out.release();
}

void CssVertexArray::CloneHelper(const CssVertexArray &source)
{
    CssObject3D::CloneHelper(source);
    count = source.count;
    components = source.components;
    width = source.width;
    bytes = source.bytes;
}
void CssVertexArray::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssObject3D::SerializeIn(reader);
    width = reader.ReadByte();
    if (width != 1 && width != 2) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    components = reader.ReadByte();
    if (components < 2 || components > 4) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    enum VertexEncoding { AbsoluteComponents, DeltaComponents };
    int encoding = reader.ReadByte();
    if (encoding > DeltaComponents) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    count = reader.ReadUInt16();
    int n = count * components;
    bytes.SetSize(n * width);
    unsigned previous = 0;
    for (int i = 0; i < n; ++i) {
        unsigned x = width == 1 ? reader.ReadByte() : reader.ReadUInt16();
        previous = encoding != AbsoluteComponents ? previous + x : x;
        if (width == 1) bytes[i] = (uint8_t)previous;
        else ((uint16_t *)bytes.data)[i] = (uint16_t)previous;
    }
    dirty = 1;
}


void CssVertexArray::Construct(int vertex_count, int component_count, int component_size)
{
    count = vertex_count;
    components = component_count;
    width = component_size;
    bytes.SetSize(count * components * width);
    if (bytes.size) memset(bytes.data, 0, bytes.size);
}

static uint8_t *vertex_span(CssVertexArray &array, int first, int count, int capacity, int width)
{
    if (width != array.width) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    if (count * array.components > capacity) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (static_cast<unsigned>(first) >= static_cast<unsigned>(array.count) || count > array.count - first)
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return static_cast<uint8_t *>(array.bytes.data) + first * array.components * width;
}

void CssVertexArray::Get8(int first, int count, int capacity, int8_t *dest)
{
    auto *storage = vertex_span(*this, first, count, capacity, 1);
    swvMemCpy(dest, storage, static_cast<size_t>(count) * components);
}

void CssVertexArray::Set8(int first, int count, int capacity, const int8_t *source)
{
    auto *storage = vertex_span(*this, first, count, capacity, 1);
    swvMemCpy(storage, source, static_cast<size_t>(count) * components);
    dirty = 1;
}

void CssVertexArray::Get16(int first, int count, int capacity, int16_t *dest)
{
    auto *storage = vertex_span(*this, first, count, capacity, 2);
    swvMemCpy(dest, storage, static_cast<size_t>(count) * components * 2);
}

void CssVertexArray::Set16(int first, int count, int capacity, const int16_t *source)
{
    auto *storage = vertex_span(*this, first, count, capacity, 2);
    swvMemCpy(storage, source, static_cast<size_t>(count) * components * 2);
    dirty = 1;
}

void CssVertexArray::Set24(int first, int count, int, const int *source, bool clamp)
{
    int n = count * components;
    if (width == 1) {
        auto *out = static_cast<uint8_t *>(bytes.data) + first;
        for (int i = 0; i < n; ++i) {
            uint32_t value = (static_cast<uint32_t>(source[i]) + 127) >> 8;
            out[i] = clamp && value > 255 ? 255 : static_cast<uint8_t>(value);
        }
    } else {
        auto *out = static_cast<uint16_t *>(bytes.data) + first;
        for (int i = 0; i < n; ++i)
            out[i] = static_cast<uint16_t>((static_cast<uint32_t>(source[i]) + 127) >> 8);
    }
    dirty = 1;
}
