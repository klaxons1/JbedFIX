#include "cssserializein.hpp"

static constexpr unsigned SectionOverhead = 1 + 4 + 4 + 4; // compression, lengths, checksum

CssSerializeIn::~CssSerializeIn() { delete stream; }

void CssSerializeIn::UpdateSectionChecksum(const uint8_t *bytes, unsigned count)
{
    adler = swvAdler32(adler, bytes, count);
}

void CssSerializeIn::closeStream()
{
    delete stream;
    stream = nullptr;
}

void CssSerializeIn::OnError(EssError error_code)
{
    state = Failed;
    if (error == None)
        error = error_code;
}

int CssSerializeIn::OnDataStart(bool extensions)
{
    if (error != None)
        g_ssThrowLeave(SWV_LEAVE_DATA_SINK_INVALID_STATE);
    allow_extensions = extensions;
    if (signature_pos)
        return UnableToCreate;
    state = Started;
    closeStream();
    return None;
}

CssSerializeIn::EssError CssSerializeIn::readSignature(uint8_t byte)
{
    if (!signature) {
        if (byte == m3g.HeaderByte(0)) {
            signature = &m3g;
            extended = 0;
        } else if (allow_extensions && byte == swerve.HeaderByte(0)) {
            signature = &swerve;
            extended = 1;
        } else {
            return InvalidHeader;
        }
    } else if (byte != signature->HeaderByte(signature_pos)) {
        return InvalidHeader;
    }
    if (++signature_pos == signature->Length())
        phase = Compression;
    return None;
}

void CssSerializeIn::checksumWord(const uint8_t *begin, const uint8_t *last, uint32_t value)
{
    // The engine hashes the four bytes ending at the current cursor.
    if (last - begin >= 3)
        UpdateSectionChecksum(last - 3, 4);
    else {
        uint8_t bytes[] = {uint8_t(value), uint8_t(value >> 8), uint8_t(value >> 16), uint8_t(value >> 24)};
        UpdateSectionChecksum(bytes, sizeof bytes);
    }
}

int CssSerializeIn::OnData(int size, const uint8_t *data, int offset, int length)
{
    if (error != None || (state != Started && state != Receiving))
        g_ssThrowLeave(SWV_LEAVE_DATA_SINK_INVALID_STATE);
    state = Receiving;
    // The memory loader requests the rest of the file with an negative length.
    bool to_file_end = offset > 0 && length == -offset;
    if (to_file_end && size == 0 && data == suspended_input && (unsigned)offset == file_pos)
        size = suspended_size;
    suspended_input = nullptr;
    suspended_size = 0;
    if (offset < 0 || offset > size || (!to_file_end && (length < 0 || length > size - offset)) || (!data && length)) {
        OnError(Unknown);
        return Unknown;
    }
    const uint8_t *buffer = data;
    unsigned available = to_file_end ? size - offset : length;
    unsigned left = available;
    if (left)
        data += offset;
    EssError status = None;
    while (left && status == None) {
        if (file_pos == expected_size)
            return DataPastEOF;
        if (phase == Payload) {
            unsigned take = remaining < left ? remaining : left;
            if (take) {
                UpdateSectionChecksum(data, take);
                if (!stream->Decompress(data, take)) {
                    status = InvalidBody;
                    break;
                }
            }
            left -= take;
            data += take;
            file_pos += take;
            remaining -= take;
            if (!remaining) {
                if (plain_size != produced)
                    g_ssThrowLeave(SWV_LEAVE_BAD_BUFFER_LENGTH);
                closeStream();
                phase = ChecksumFirstByte;
            }
            continue;
        }
        uint8_t byte = *data;
        int pause = 0;
        switch (phase) {
        case Signature:
            status = readSignature(byte);
            break;
        case Compression:
            if (!BeforeBytes()) {
                status = Unknown;
            } else {
                ++section;
                adler = swvAdler32(1, &byte, 1);
                if (byte > 1)
                    status = InvalidBody;
                else
                    stream = byte ? static_cast<CssDecompress *>(CssDecompressZLib::Create(this))
                                  : CssDecompressNone::Create(this);
            }
            phase = LengthFirstByte;
            break;
        case LengthFirstByte: case LengthFirstByte+1: case LengthFirstByte+2: case LengthLastByte:
            if (phase == LengthFirstByte)
                section_length = byte;
            else
                section_length |= (uint32_t)byte << (8 * (phase - LengthFirstByte));
            if (phase == LengthLastByte) {
                checksumWord(buffer, data, section_length);
                remaining = section_length;
                if (remaining < SectionOverhead)
                    g_ssThrowLeave(SWV_LEAVE_BAD_BUFFER_LENGTH);
                remaining -= SectionOverhead;
            }
            ++phase;
            break;
        case PlainSizeFirstByte: case PlainSizeFirstByte+1: case PlainSizeFirstByte+2: case PlainSizeLastByte:
            if (phase == PlainSizeFirstByte)
                plain_size = byte;
            else
                plain_size |= (uint32_t)byte << (8 * (phase - PlainSizeFirstByte));
            if (phase == PlainSizeLastByte) {
                produced = 0;
                checksumWord(buffer, data, plain_size);
            }
            ++phase;
            break;
        case ChecksumFirstByte: case ChecksumFirstByte+1: case ChecksumFirstByte+2: case ChecksumLastByte:
            if (phase == ChecksumFirstByte)
                checksum = byte;
            else
                checksum |= (uint32_t)byte << (8 * (phase - ChecksumFirstByte));
            if (phase != ChecksumLastByte) {
                ++phase;
                break;
            }
            phase = Compression;
            if (checksum != adler)
                status = InvalidChecksum;
            else
                pause = bUnresolvedXREFs();
            break;
        default:
            status = InvalidBody;
            break;
        }
        ++data;
        --left;
        ++file_pos;
        if (pause) {
            suspended_input = buffer;
            suspended_size = size;
            return (int)(available - left);
        }
    }
    if (to_file_end && status == None) {
        if (file_pos == expected_size)
            return DataPastEOF;
        status = Unknown;
    }
    if (status != None)
        OnError(status);
    return status;
}

int CssSerializeIn::OnDataEnd()
{
    if (error != None || (state != Started && state != Receiving) || phase != Compression)
        g_ssThrowLeave(SWV_LEAVE_DATA_SINK_INVALID_STATE);
    state = Finished;
    EssError status = None;
    if (!AfterBytes()) {
        status = Unknown;
        OnError(status);
    }
    closeStream();
    return status;
}
