#include "geometry_class.hpp"
#include "cssserializebufferobjectsin.hpp"

void CssTriangleStripArray::Construct(int first_index, int strip_count, const SwvVertexIndex *strip_lengths)
{
    if (first_index < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    if (strip_count <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    implicit = true;
    first = static_cast<uint16_t>(first_index);
    lengths.SetSize(strip_count);
    uint32_t end = first_index;
    for (int i = 0; i < strip_count; ++i) {
        end += strip_lengths[i];
        if (strip_lengths[i] < 3) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        lengths[i] = static_cast<uint16_t>(strip_lengths[i]);
    }
    if (end - 1 >= 65536) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    max_index = end - 1;
}

void CssTriangleStripArray::Construct(int index_count, const SwvVertexIndex *vertices,
                                      int strip_count, const SwvVertexIndex *strip_lengths)
{
    if (strip_count <= 0 || index_count < 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    implicit = false;
    indices.SetSize(index_count);
    max_index = 0;
    for (int i = 0; i < index_count; ++i) {
        if (static_cast<unsigned>(vertices[i]) >= 65536) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
        if (vertices[i] > max_index) max_index = vertices[i];
        indices[i] = static_cast<uint16_t>(vertices[i]);
    }
    lengths.SetSize(strip_count);
    uint32_t total = 0;
    for (int i = 0; i < strip_count; ++i) {
        if (strip_lengths[i] < 3) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        lengths[i] = static_cast<uint16_t>(strip_lengths[i]);
        total += strip_lengths[i];
    }
    if (static_cast<int32_t>(total) > index_count) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}

int CssTriangleStripArray::GetStrip(int strip, int capacity, SwvVertexIndex *out) const
{
    if (static_cast<unsigned>(strip) >= static_cast<unsigned>(lengths.size)) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    const int length = lengths[strip];
    if (out) {
        if (capacity < length) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        int start = 0;
        for (int i = 0; i < strip; ++i)
            start += lengths[i];
        if (implicit) {
            start += first;
            for (int i = 0; i < length; ++i)
                out[i] = start + i;
        } else {
            if (start > indices.size - length) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
            for (int i = 0; i < length; ++i)
                out[i] = indices[start + i];
        }
    }
    return length;
}

int CssTriangleStripArray::GetIndexCount() const
{
    unsigned triangles = 0;
    for (int i = 0; i < lengths.size; ++i)
        triangles += lengths[i] - 2;
    return static_cast<int>(triangles * 3);
}

void CssTriangleStripArray::GetIndices(int capacity, SwvVertexIndex *out) const
{
    int required = 0;
    if (implicit) {
        int start = first;
        for (int i = 0; i < lengths.size; ++i) {
            int length = lengths[i];
            required += 3 * (length - 2);
            if (required > capacity) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
            for (int j = 2; j < length; ++j) {
                *out++ = start + j + (j & 1) - 2;
                *out++ = start + j - (j & 1) - 1;
                *out++ = start + j;
            }
            start += length;
        }
    } else {
        int start = 0;
        for (int i = 0; i < lengths.size; ++i) {
            int length = lengths[i];
            required += 3 * (length - 2);
            if (required > capacity) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
            if (start > indices.size - length) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
            for (int j = 2; j < length; ++j) {
                *out++ = indices[start + j + (j & 1) - 2];
                *out++ = indices[start + j - (j & 1) - 1];
                *out++ = indices[start + j];
            }
            start += length;
        }
    }
}

void CssTriangleStripArray::StitchAll()
{
    const uint16_t strips = static_cast<uint16_t>(lengths.Size());
    if (strips < 2) return;
    CssHeapPtr<CssArray<uint16_t>> joined(new CssArray<uint16_t>);
    joined->Reserve(indices.Size() + 3 * strips);
    uint16_t start = 0;
    for (uint16_t i = 0; i < strips; ++i) {
        uint16_t length = lengths[i], last = 0;
        for (uint16_t j = 0; j < length; ++j) {
            last = static_cast<uint16_t>(start + j);
            joined->Append(indices[last]);
        }
        if (i + 1 < strips) {
            joined->Append(indices[last]);
            uint16_t next = indices[last + 1];
            joined->Append(next);
            if (length & 1) joined->Append(next);
        }
        start += length;
    }
    indices = *joined;
    lengths.SetSize(1);
    lengths[0] = static_cast<uint16_t>(indices.Size());
}

CssObject3D *CssTriangleStripArray::Clone() const
{
    CssHeapPtr<CssTriangleStripArray> out(static_cast<CssTriangleStripArray *>(FactoryCreate()));
    out->CloneHelper(*this);
    return out.release();
}

void CssTriangleStripArray::CloneHelper(const CssTriangleStripArray &source)
{
    CssIndexBuffer::CloneHelper(source);
    implicit = source.implicit;
    first = source.first;
    indices = source.indices;
    lengths = source.lengths;
}

void CssTriangleStripArray::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssIndexBuffer::SerializeIn(reader);
    enum IndexEncoding {
        ImplicitInt, ImplicitByte, ImplicitShort,
        ExplicitFlag = 128, ExplicitInt = ExplicitFlag, ExplicitByte, ExplicitShort
    };
    int encoding = reader.ReadByte();
    if (encoding > ImplicitShort && (encoding < ExplicitInt || encoding > ExplicitShort)) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    implicit = (encoding & ExplicitFlag) == 0;
    max_index = 0;
    switch (encoding) {
    case ImplicitInt: {
        uint32_t index = reader.ReadUInt();
        if (index >= 65536) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
        first = static_cast<uint16_t>(index);
        break;
    }
    case ImplicitByte: first = reader.ReadByte(); break;
    case ImplicitShort: first = reader.ReadUInt16(); break;
    case ExplicitInt: {
        int count = reader.ReadCount(4);
        indices.SetSize(count);
        for (int i = 0; i < count; ++i) {
            uint32_t index = reader.ReadUInt();
            if (index >= 65536) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
            if (index > static_cast<unsigned>(max_index)) max_index = index;
            indices[i] = static_cast<uint16_t>(index);
        }
        break;
    }
    case ExplicitByte: {
        int count = reader.ReadCount(1);
        indices.SetSize(count);
        for (int i = 0; i < count; ++i) {
            indices[i] = reader.ReadByte();
            if (indices[i] > max_index) max_index = indices[i];
        }
        break;
    }
    case ExplicitShort: {
        int count = reader.ReadCount(2);
        indices.SetSize(count);
        for (int i = 0; i < count; ++i) {
            indices[i] = reader.ReadUInt16();
            if (indices[i] > max_index) max_index = indices[i];
        }
        break;
    }
    }
    reader.ReadGeometryIndexArray(lengths, -1);
    int total = 0;
    for (int i = 0; i < lengths.size; ++i) {
        if (lengths[i] < 3) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        total += lengths[i];
    }
    if (indices.size > total) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    if (implicit) max_index = first + total - 1;
}
