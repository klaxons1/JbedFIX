#ifndef SWERVE_CSSSERIALIZEBUFFEROBJECTSIN_HPP
#define SWERVE_CSSSERIALIZEBUFFEROBJECTSIN_HPP

#include "heap_object.hpp"

class IssSerializable;
class CssNode;
class CssImage2D;
class CssPackedColor;

struct CssSerializeBufferObjectsIn : public CssHeapObject {
    CssArray<uint8_t> buffer;
    unsigned read = 0, written = 0;
    CssArray<IssSerializable *> *objects = nullptr;
    CssArray<bool> *referenced = nullptr;

    void Reset(unsigned length);
    void Reset(unsigned length, CssArray<IssSerializable *> *table, CssArray<bool> *flags);
    void Write(uint8_t byte);
    void Write(const uint8_t *data, unsigned count);
    bool bEndOfBuffer() const { return read >= (unsigned)buffer.size; }
    uint8_t Read();
    uint8_t Input() { return Read(); }
    uint8_t ReadByte() { return Input(); }
    bool ReadBool();
    uint16_t ReadUInt16();
    int16_t ReadInt16() { return static_cast<int16_t>(ReadUInt16()); }
    uint32_t ReadUInt();
    int32_t ReadInt() { return static_cast<int32_t>(ReadUInt()); }
    int ReadCount(int width);
    uint8_t ReadEnum(uint8_t low, uint8_t high);
    uint16_t ReadGeometryIndex() { return static_cast<uint16_t>(ReadUInt()); }
    float ReadReal();
    void ReadVector3D(CssVector3D &vector);
    void ReadColorRGBA(CssPackedColor &color, bool alpha);
    void ReadMatrix(CssMatrix &matrix);
    void ReadBuffer(void *out, unsigned size);
    void ReadUTF8String(CssArray<uint8_t> &out);
    void ReadByteArray(CssArray<uint8_t> &out, int count);
    void ReadInt16Array(CssArray<int16_t> &out, int count);
    void ReadGeometryIndexArray(CssArray<uint16_t> &out, int count);
    void ReadRealArray(CssArray<float> &out, int count);
    IssSerializable *ReadObjectRef();
    IssSerializable *ReadObjectRefTypeChecked(EssObjectType type);
    CssNode *ReadObjectRefNode(bool allow_world);
    CssImage2D *ReadObjectRefImage2D(bool allow_stageset);
};

#endif
