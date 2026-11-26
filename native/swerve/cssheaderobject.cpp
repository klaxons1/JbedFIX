#include "cssserializein.hpp"

void CssHeaderObject::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    unsigned major = r.ReadByte();
    unsigned minor = r.ReadByte();
    if (major != 1 || minor != 0)
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    external = r.ReadBool();
    file_size = r.ReadUInt();
    content_size = r.ReadUInt();
    r.ReadUTF8String(author);
}

int CssHeaderObject::GetAuthoringField(int size, uint8_t *out) const
{
    if (out && author.size > 0 && size >= author.size)
        std::memcpy(out, author.data, author.size);
    return author.size;
}
