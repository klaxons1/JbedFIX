#include "cssserializein.hpp"
#include "cssobjectfactory.hpp"

#include <climits>

CssSerializeObjectsIn::~CssSerializeObjectsIn()
{
    delete header;
    for (int i = 0; i < objects.size; ++i)
        if (objects[i])
            objects[i]->Release();
}

bool CssSerializeObjectsIn::BeforeBytes()
{
    if (object_phase != ObjectType)
        return 0;
    if (!objects.size) {
        objects.SetStorageSize(32, 0);
        referenced.SetStorageSize(32, 0);
        objects.Append(nullptr);
        referenced.Append(false);
    }
    return 1;
}

bool CssSerializeObjectsIn::AfterBytes()
{
    if (object_phase != ObjectType)
        return 0;
    for (int i = 1; i < objects.size; ++i)
        if (!referenced[i])
            roots.Append(i);
    return 1;
}

bool CssSerializeObjectsIn::ProcessHeaderObject()
{
    if (object_type != ObjectHeader || header)
        return false;
    CssTrapHandler frame;
    if (setjmp(frame.Trap()))
        return false;
    frame.CleanupStack();
    header = CssHeaderObject::Create();
    objects.Append(nullptr);
    referenced.Append(true);
    header->SerializeIn(reader);
    expected_size = header->GetTotalFileSize();
    CssTrapHandler::UnTrap();
    return true;
}

bool CssSerializeObjectsIn::ProcessObject()
{
    if (object_type <= ObjectHeader || object_type > (allow_extensions ? StagesetObject : WorldObject) || xrefs.size)
        return false;
    return deserializeObject(false);
}

bool CssSerializeObjectsIn::ProcessXREFObject()
{
    return object_type == XrefObject && deserializeObject(true);
}

bool CssSerializeObjectsIn::deserializeObject(bool xref)
{
    CssTrapHandler frame;
    if (setjmp(frame.Trap()))
        return false;
    frame.CleanupStack();
    auto *obj = CssObjectFactory::CreateObject(static_cast<EssObjectType>(object_type));
    CssCleanupStackManager::Push(obj);
    obj->AddRef();
    objects.Append(obj);
    CssCleanupStackManager::Pop(obj);
    referenced.Append(false);
    obj->SerializeIn(reader);
    if (xref)
        xrefs.Append(objects.size - 1);
    CssTrapHandler::UnTrap();
    return true;
}

bool CssSerializeObjectsIn::OnDecompressedData(const uint8_t *data, unsigned size)
{
    unsigned n = size;
    while (n) {
        if (object_phase == ObjectType) {
            object_start = stream->CompressedBytesRead();
            object_type = *data++;
            --n;
            object_phase = LengthFirstByte;
        } else if (object_phase <= LengthLastByte) {
            unsigned shift = 8 * (object_phase - LengthFirstByte);
            uint32_t part = (uint32_t)*data++ << shift;
            object_remaining = shift ? object_remaining | part : part;
            --n;
            if (++object_phase == ObjectPayload) {
                if (object_remaining >= GetSectionUncompressedLength() || object_remaining > INT_MAX)
                    return 0;
                reader.Reset(object_remaining, &objects, &referenced);
            }
        } else {
            unsigned amount = object_remaining < n ? object_remaining : n;
            reader.Write(data, amount);
            if (n < object_remaining) {
                object_remaining -= n;
                n = 0;
            } else {
                bool ok;
                if (GetiSection() == 0)
                    ok = ProcessHeaderObject();
                else if (GetiSection() == 1 && header && header->GetbExternalLinks())
                    ok = ProcessXREFObject();
                else
                    ok = ProcessObject();
                if (!ok || !reader.bEndOfBuffer())
                    return 0;
                object_phase = ObjectType;
                object_remaining = 0;
                data += amount;
                n -= amount;
            }
        }
    }
    ProcessedUncompressedBytes(size);
    return 1;
}

int CssSerializeObjectsIn::GetAuthoringField(int size, uint8_t *out) const
{
    return header ? header->GetAuthoringField(size, out) : 0;
}

int CssSerializeObjectsIn::GetXREFName(int size, uint8_t *out) const
{
    if (!xrefs.size)
        return -1;
    auto *xref = static_cast<const CssXREF *>(objects[xrefs[xrefs.size - 1]]);
    return xref->GetName(size, out);
}

void CssSerializeObjectsIn::ResolveXREF(CssObject3D *replacement)
{
    if (!xrefs.size)
        return;
    int top = xrefs.size - 1;
    auto &slot = objects[xrefs[top]];
    slot = static_cast<IssSerializable *>(CssRefCount::Assign(slot, replacement));
    --xrefs.size;
}
