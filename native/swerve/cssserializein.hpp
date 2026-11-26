#ifndef SWERVE_CSSSERIALIZEIN_HPP
#define SWERVE_CSSSERIALIZEIN_HPP

#include "cssserializebufferobjectsin.hpp"
#include "loader.h"
#include "object_class.hpp"

class CssFileHeader : public CssHeapObject {
protected:
    CssFileHeader(const uint8_t *bytes, unsigned size) : data(bytes), length(size) {}
public:
    ~CssFileHeader() override;
    const uint8_t *data;
    unsigned length;
    unsigned Length() const { return length; }
    uint8_t HeaderByte(unsigned index) const { return data[index]; }
};

class CssFileHeaderM3G : public CssFileHeader {
public:
    CssFileHeaderM3G();
};

class CssFileHeaderSWV : public CssFileHeader {
public:
    CssFileHeaderSWV();
};

class CssHeaderObject : public IssSerializable {
public:
    static CssHeaderObject *Create() { return new CssHeaderObject; }
    int GetAuthoringField(int size, uint8_t *out) const;
    uint32_t GetTotalFileSize() const { return file_size; }
    bool GetbExternalLinks() const { return external; }
    bool external = false;
    uint32_t file_size = 0, content_size = 0;
    CssArray<uint8_t> author;

    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
};

class CssXREF final : public IssSerializable {
public:
    CssArray<uint8_t> uri;
    int index = 0;
    CssObject3D *resolved = nullptr;

    ~CssXREF() override;
    static IssSerializable *FactoryCreate() { return new CssXREF; }
    void SerializeIn(CssSerializeBufferObjectsIn &reader) override;
    int Type() const override { return XrefObject; }
    int GetName(int size, uint8_t *out) const;
};

class CssSerializeIn;

class CssDecompress : public CssHeapObject {
public:
    ~CssDecompress() override;
    void Construct(CssSerializeIn *loader) { owner = loader; }
    CssSerializeIn *owner = nullptr;
    virtual bool Decompress(const void *data, unsigned count) = 0;
    virtual int CompressedBytesRead() = 0;
};

class CssDecompressNone : public CssDecompress {
public:
    static CssDecompressNone *Create(CssSerializeIn *loader);
    int position = 0;
    bool Decompress(const void *data, unsigned count) override;
    int CompressedBytesRead() override { return position; }
};

class CssDecompressZLib : public CssDecompress {
public:
    static CssDecompressZLib *Create(CssSerializeIn *loader);
    SwvInflater *inflater = nullptr;
    int position = 0;
    ~CssDecompressZLib() override;
    void Construct(CssSerializeIn *loader);
    bool Decompress(const void *data, unsigned count) override;
    int CompressedBytesRead() override { return position; }
};

class CssSerializeIn : public CssHeapObject, public CssRefCount {
public:
    enum EssError : int {
        None = LoaderError_Error_None, UnableToCreate = LoaderError_Error_UnableToCreate,
        InvalidHeader = LoaderError_Error_InvalidHeader, InvalidBody = LoaderError_Error_InvalidBody,
        InvalidChecksum = LoaderError_Error_InvalidChecksum, Unknown = LoaderError_Error_Unknown,
        DataPastEOF = LoaderError_Error_DataPastEOF
    };
    enum Status : int { NotStarted, Started, Receiving, Finished, Failed };
    enum SectionPhase : int {
        Signature = 1, Compression = 2, LengthFirstByte = 3, LengthLastByte = 6,
        PlainSizeFirstByte = 7, PlainSizeLastByte = 10, Payload = 11,
        ChecksumFirstByte = 12, ChecksumLastByte = 15
    };
    EssError error = None;
    CssDecompress *stream = nullptr;
    uint8_t extended = 1, allow_extensions = 1;
    uint32_t expected_size = UINT32_MAX, signature_pos = 0;
    int phase = Signature, section = -1;
    uint32_t file_pos = 0, section_length = 0, plain_size = 0, checksum = 0;
    uint32_t adler = 0, remaining = 0, produced = 0;
    CssFileHeaderM3G m3g;
    CssFileHeaderSWV swerve;
    const CssFileHeader *signature = nullptr;
    int state = NotStarted;
    // The buffer API resumes an external reference with size zero and the original pointer.
    const uint8_t *suspended_input = nullptr;
    int suspended_size = 0;

    ~CssSerializeIn() override;
    virtual int OnDataStart(bool extensions);
    virtual int OnData(int size, const uint8_t *data, int offset, int length);
    virtual int OnDataEnd();
    virtual void OnError(EssError error_code);
    virtual int GetStatus() const { return state; }
    virtual bool OnDecompressedData(const uint8_t *data, unsigned count) = 0;
    virtual bool BeforeBytes() = 0;
    virtual bool AfterBytes() = 0;
    virtual bool bUnresolvedXREFs() = 0;

    unsigned GetSectionUncompressedLength() const { return plain_size; }
    int GetiSection() const { return section; }
    void ProcessedUncompressedBytes(unsigned count) { produced += count; }
    void UpdateSectionChecksum(const uint8_t *bytes, unsigned count);
    void closeStream();
    EssError readSignature(uint8_t byte);
    void checksumWord(const uint8_t *begin, const uint8_t *last, uint32_t value);
};

class CssSerializeObjectsIn : public CssSerializeIn {
public:
    enum ObjectPhase : int { ObjectType, LengthFirstByte, LengthLastByte = 4, ObjectPayload };
    int object_phase = ObjectType;
    uint32_t object_remaining = 0;
    int object_type = 0;
    CssSerializeBufferObjectsIn reader;
    CssArray<IssSerializable *> objects;
    CssArray<bool> referenced;
    CssArray<int> roots, xrefs;
    CssHeaderObject *header = nullptr;
    int object_start;

    ~CssSerializeObjectsIn() override;
    bool OnDecompressedData(const uint8_t *data, unsigned count) override;
    bool BeforeBytes() override;
    bool AfterBytes() override;
    bool bUnresolvedXREFs() override { return xrefs.size > 0; }
    int Type() const override { return LoaderObject; }
    static CssSerializeObjectsIn *Create() { return new CssSerializeObjectsIn; }
    bool ProcessHeaderObject();
    bool ProcessObject();
    bool ProcessXREFObject();
    int GetcRoots() const { return roots.size; }
    IssSerializable *GetRoot(int index) const { return objects[roots[index]]; }
    bool GetbContainsExtensions() const { return extended; }
    int GetXREFName(int size, uint8_t *out) const;
    void ResolveXREF(CssObject3D *replacement);
    int GetAuthoringField(int size, uint8_t *out) const;

private:
    bool deserializeObject(bool xref);
};

#endif
