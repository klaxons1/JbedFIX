#include "cssserializebufferobjectsin.hpp"
#include "csscolor.hpp"
#include "image_class.hpp"
#include <climits>
#include <cstring>

void CssSerializeBufferObjectsIn::Reset(unsigned length)
{
    buffer.SetSize(length);
    read = written = 0;
}

void CssSerializeBufferObjectsIn::Reset(unsigned length, CssArray<IssSerializable *> *table,
                                        CssArray<bool> *flags)
{
    objects = table;
    referenced = flags;
    Reset(length);
}

void CssSerializeBufferObjectsIn::Write(uint8_t byte)
{
    if (written >= (unsigned)buffer.size)
        g_ssThrowLeave(SWV_LEAVE_BUFFER_OVERRUN);
    buffer[written++] = byte;
}

void CssSerializeBufferObjectsIn::Write(const uint8_t *data, unsigned count)
{
    if (count > (unsigned)buffer.size - written)
        g_ssThrowLeave(SWV_LEAVE_BUFFER_OVERRUN);
    if (count)
        std::memcpy(static_cast<uint8_t *>(buffer.data) + written, data, count);
    written += count;
}

uint8_t CssSerializeBufferObjectsIn::Read()
{
    if (bEndOfBuffer())
        g_ssThrowLeave(SWV_LEAVE_BUFFER_OVERRUN);
    return buffer[read++];
}

bool CssSerializeBufferObjectsIn::ReadBool()
{
    unsigned value = Input();
    if (value > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return value != 0;
}

uint16_t CssSerializeBufferObjectsIn::ReadUInt16()
{
    unsigned low = Input();
    return low | ((unsigned)Input() << 8);
}

uint32_t CssSerializeBufferObjectsIn::ReadUInt()
{
    uint32_t value = Input();
    value |= (uint32_t)Input() << 8;
    value |= (uint32_t)Input() << 16;
    return value | ((uint32_t)Input() << 24);
}

int CssSerializeBufferObjectsIn::ReadCount(int width)
{
    uint32_t count = ReadUInt();
    if ((uint64_t)count * (unsigned)width >= (unsigned)buffer.size || count > INT_MAX)
        g_ssThrowLeave(SWV_LEAVE_BUFFER_OVERRUN);
    return static_cast<int>(count);
}

uint8_t CssSerializeBufferObjectsIn::ReadEnum(uint8_t lo, uint8_t hi)
{
    uint8_t value = ReadByte();
    if (value <= lo || value >= hi)
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    return value;
}

float CssSerializeBufferObjectsIn::ReadReal()
{
    uint32_t bits = ReadUInt();
    unsigned exponent = (bits >> 23) & 255;
    if (bits && (exponent == 0 || exponent == 255))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    float f;
    std::memcpy(&f, &bits, sizeof f);
    return f;
}

void CssSerializeBufferObjectsIn::ReadVector3D(CssVector3D &out)
{
    out.x = ReadReal();
    out.y = ReadReal();
    out.z = ReadReal();
}

void CssSerializeBufferObjectsIn::ReadColorRGBA(CssPackedColor &color, bool alpha)
{
    color.SetRed8(ReadByte());
    color.SetGreen8(ReadByte());
    color.SetBlue8(ReadByte());
    if (alpha)
        color.SetAlpha8(ReadByte());
}

void CssSerializeBufferObjectsIn::ReadMatrix(CssMatrix &matrix)
{
    for (int row = 0; row < 4; ++row)
        for (int col = 0; col < 4; ++col)
            matrix.m[col * 4 + row] = ReadReal();
    matrix.ResetMatrixType();
}

void CssSerializeBufferObjectsIn::ReadBuffer(void *out, unsigned size)
{
    if (size > (unsigned)buffer.size - read)
        g_ssThrowLeave(SWV_LEAVE_BUFFER_OVERRUN);
    if (size)
        std::memcpy(out, static_cast<uint8_t *>(buffer.data) + read, size);
    read += size;
}

void CssSerializeBufferObjectsIn::ReadUTF8String(CssArray<uint8_t> &out)
{
    for (uint8_t byte; (byte = ReadByte()) != 0;) {
        if ((byte & 0xc0) == 0x80)
            g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
        out.Append(byte);
        if (byte & 0x80) {
            while ((uint8_t)(byte <<= 1) & 0x80) {
                uint8_t next = ReadByte();
                if ((next & 0xc0) != 0x80)
                    g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
                out.Append(next);
            }
        }
    }
}

template<class T, auto readValue>
static void readArray(CssSerializeBufferObjectsIn &reader, CssArray<T> &out,
                      int count, int elementSize)
{
    if (count < 0)
        count = reader.ReadCount(elementSize);
    out.SetSize(count);
    for (int i = 0; i < count; ++i)
        out[i] = (reader.*readValue)();
}

void CssSerializeBufferObjectsIn::ReadByteArray(CssArray<uint8_t> &out, int count)
{ readArray<uint8_t, &CssSerializeBufferObjectsIn::ReadByte>(*this, out, count, 1); }
void CssSerializeBufferObjectsIn::ReadInt16Array(CssArray<int16_t> &out, int count)
{ readArray<int16_t, &CssSerializeBufferObjectsIn::ReadInt16>(*this, out, count, 2); }
void CssSerializeBufferObjectsIn::ReadGeometryIndexArray(CssArray<uint16_t> &out, int count)
{ readArray<uint16_t, &CssSerializeBufferObjectsIn::ReadGeometryIndex>(*this, out, count, 4); }
void CssSerializeBufferObjectsIn::ReadRealArray(CssArray<float> &out, int count)
{ readArray<float, &CssSerializeBufferObjectsIn::ReadReal>(*this, out, count, 4); }

IssSerializable *CssSerializeBufferObjectsIn::ReadObjectRef()
{
    unsigned index = ReadUInt();
    if (index != 0 && (index == 1 || index >= (unsigned)objects->size))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    (*referenced)[index] = true;
    return (*objects)[index];
}

IssSerializable *CssSerializeBufferObjectsIn::ReadObjectRefTypeChecked(EssObjectType type)
{
    IssSerializable *obj = ReadObjectRef();
    if (obj && obj->Type() != type)
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    return obj;
}

CssNode *CssSerializeBufferObjectsIn::ReadObjectRefNode(bool allow_world)
{
    IssSerializable *obj = ReadObjectRef();
    if (obj) {
        int type = obj->Type();
        if (type != CameraObject && type != GroupObject && !(allow_world && type == WorldObject) &&
            type != LightObject && type != MeshObject && type != MorphingMeshObject &&
            type != SkinnedMeshObject && type != SpriteObject)
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    }
    return static_cast<CssNode *>(obj);
}

CssImage2D *CssSerializeBufferObjectsIn::ReadObjectRefImage2D(bool allow_stageset)
{
    IssSerializable *obj = ReadObjectRef();
    if (obj) {
        int type = obj->Type();
        if (type != Image2DObject && type != PlasmaImageObject && !(allow_stageset && type == StagesetObject))
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    }
    return static_cast<CssImage2D *>(obj);
}
