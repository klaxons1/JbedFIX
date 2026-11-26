#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "geometry_class.hpp"
#include <new>
#include <climits>

using UserParameter = CssObject3D::SssUserParameter;

struct CssObject3D::CssAnimTrackManager {
    CssArray<CssAnimationTrack *> tracks;
    CssArray<int> bucket_sizes;

    ~CssAnimTrackManager();
    static void operator delete(void *p) noexcept { swvFree(p); }
    void AddAnimationTrack(CssAnimationTrack *track);
    void RemoveAnimationTrack(CssAnimationTrack *track);
    CssAnimationTrack *GetAnimationTrack(int index) const;
    int GetAnimationTrackCount() const;
    int GetBucketCount() const { return bucket_sizes.Size(); }
    int GetBucketSize(int bucket) const { return bucket_sizes[bucket]; }
};

CssAnimationTrack *CssObject3D::CssAnimTrackManager::GetAnimationTrack(int index) const
{
    return tracks[index];
}

int CssObject3D::CssAnimTrackManager::GetAnimationTrackCount() const
{
    return tracks.Size();
}

void CssObject3D::RemoveUserParameters()
{
    if (parameters) {
        UserParameter *items = static_cast<UserParameter *>(parameters->data);
        for (int i = 0; i < parameters->size; ++i)
            swvFree(items[i].data);
        delete parameters;
        parameters = nullptr;
    }
}

CssObject3D::CssAnimTrackManager::~CssAnimTrackManager()
{
    for (int i = 0; i < tracks.Size(); ++i)
        tracks[i]->Release();
}

CssObject3D::~CssObject3D()
{
    RemoveUserParameters();
    delete tracks;
}

static UserParameter *resize_parameters(CssObject3D *object, int count)
{
    if (!object->parameters)
        object->parameters = new CssArray<UserParameter>;
    auto *parameters = object->parameters;
    parameters->SetSize(count);
    return static_cast<UserParameter *>(parameters->data);
}

static int parameter_index(const CssArray<UserParameter> *parameters, int id)
{
    if (parameters) {
        const UserParameter *items = static_cast<const UserParameter *>(parameters->data);
        for (int i = 0; i < parameters->size; ++i)
            if (items[i].id == id)
                return i;
    }
    return -1;
}

void CssObject3D::SetUserParameter(int id, int length, const uint8_t *data)
{
    int index = parameter_index(parameters, id);
    UserParameter *items;
    if (index < 0) {
        index = parameters ? parameters->size : 0;
        items = resize_parameters(this, index + 1);
    } else {
        items = static_cast<UserParameter *>(parameters->data);
        swvFree(items[index].data);
    }
    UserParameter *entry = &items[index];
    entry->data = NULL;
    entry->id = id;
    if (data && length > 0) {
        entry->data = new (ELeave) uint8_t[length];
        memcpy(entry->data, data, (size_t)length);
        entry->length = length;
    } else {
        entry->length = 0;
    }
}

static int parameter_value(const CssArray<UserParameter> *parameters, int index, uint8_t *data)
{
    if (!parameters || (unsigned)index >= (unsigned)parameters->size)
        return -1;
    const UserParameter *items = static_cast<const UserParameter *>(parameters->data);
    const UserParameter *item = &items[index];
    if (data && item->length > 0)
        memcpy(data, item->data, (size_t)item->length);
    return item->length;
}

void CssObject3D::AddAnimationTrack(CssAnimationTrack *track)
{
    if (!track || !HasAnimatableProperty(track->GetTargetProperty()))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!tracks) tracks = new (ELeave) CssAnimTrackManager;
    tracks->AddAnimationTrack(track);
}

void CssObject3D::CssAnimTrackManager::AddAnimationTrack(CssAnimationTrack *track)
{
    int count = tracks.Size();
    for (int i = 0; i < count; ++i)
        if (tracks[i] == track) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);

    int insert_at = count, insert_bucket = bucket_sizes.Size();
    int bucket = -1, property = CssAnimationTrack::None;
    for (int i = 0; i < count; ++i) {
        CssAnimationTrack *existing = tracks[i];
        int target = existing->GetTargetProperty();
        if (property != target) {
            property = target;
            ++bucket;
        }
        if (target == track->GetTargetProperty()) {
            auto *before = existing->GetKeyframeSequence();
            auto *added = track->GetKeyframeSequence();
            if ((before ? before->GetcComponents() : 0) != (added ? added->GetcComponents() : 0))
                g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
            insert_at = i;
            insert_bucket = bucket;
            break;
        }
    }
    tracks.Insert(insert_at, track);
    track->AddRef();
    if (insert_bucket < bucket_sizes.Size())
        ++bucket_sizes[insert_bucket];
    else
        bucket_sizes.Append(1);
}

void CssObject3D::CssAnimTrackManager::RemoveAnimationTrack(CssAnimationTrack *track)
{
    int bucket = -1, property = CssAnimationTrack::None;
    for (int i = 0; i < tracks.Size(); ++i) {
        CssAnimationTrack *existing = tracks[i];
        if (property != existing->GetTargetProperty()) {
            property = existing->GetTargetProperty();
            ++bucket;
        }
        if (existing == track) {
            existing->Release();
            tracks.RemoveRetainOrder(i);
            if (--bucket_sizes[bucket] == 0) bucket_sizes.RemoveRetainOrder(bucket);
            return;
        }
    }
}

void CssObject3D::CloneHelper(const CssObject3D &source)
{
    user_id = source.user_id;
    delete tracks;
    tracks = nullptr;
    if (source.tracks) {
        int count = source.GetAnimationTrackCount();
        for (int i = 0; i < count; ++i)
            AddAnimationTrack(source.GetAnimationTrack(i));
    }
    RemoveUserParameters();
    if (source.parameters && source.parameters->size) {
        int count = source.parameters->size;
        const UserParameter *items = static_cast<const UserParameter *>(source.parameters->data);
        UserParameter *copies = resize_parameters(this, count);
        for (int i = 0; i < count; ++i)
            copies[i].data = NULL;
        for (int i = 0; i < count; ++i) {
            copies[i].id = items[i].id;
            if (items[i].length > 0) {
                copies[i].data = new (ELeave) uint8_t[items[i].length];
                memcpy(copies[i].data, items[i].data, (size_t)items[i].length);
            }
            copies[i].length = items[i].length;
        }
    }
}

IssSerializable *CssObject3D::FactoryCreate()
{
    return new CssObject3D;
}

CssObject3D *CssObject3D::Clone() const
{
    CssHeapPtr<CssObject3D> copy(static_cast<CssObject3D *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

int CssObject3D::AnimateRefs(int, int validity, int) { return validity; }
void CssObject3D::SetProperty(int, int, float *) {}
bool CssObject3D::HasAnimatableProperty(int) const { return 0; }

void *CssObject3D::GetpRef(int index)
{
    if (tracks && static_cast<unsigned>(index) < static_cast<unsigned>(tracks->GetAnimationTrackCount()))
        return tracks->GetAnimationTrack(index);
    return SWV_REFERENCE_END;
}

CssObject3D *CssObject3D::Find(int id)
{
    if (user_id == id)
        return this;
    for (int i = 0;; ++i) {
        void *ref = GetpRef(i);
        if (ref == SWV_REFERENCE_END)
            return nullptr;
        if (ref == SWV_REFERENCE_ARRAY) {
            auto *array = static_cast<CssArrayBase *>(GetpRef(++i));
            auto **items = static_cast<CssObject3D **>(array->data);
            for (int j = 0; j < array->size; ++j)
                if (items[j])
                    if (CssObject3D *found = items[j]->Find(id)) return found;
        } else if (ref) {
            if (CssObject3D *found = static_cast<CssObject3D *>(ref)->Find(id)) return found;
        }
    }
}

int CssObject3D::GetReferences(int length, CssRefCount **refs)
{
    int count = 0;
    for (int i = 0;; ++i) {
        void *ref = GetpRef(i);
        if (ref == SWV_REFERENCE_END)
            break;
        if (ref == SWV_REFERENCE_ARRAY) {
            auto *array = static_cast<CssArrayBase *>(GetpRef(++i));
            auto **items = static_cast<CssObject3D **>(array->data);
            int limit = array->size;
            if (refs && length - count < limit)
                limit = length - count;
            for (int j = 0; j < limit; ++j) {
                if (!items[j])
                    continue;
                if (refs)
                    refs[count] = static_cast<CssRefCount *>(items[j]);
                ++count;
            }
        } else if (ref) {
            if (refs && count < length)
                refs[count] = static_cast<CssRefCount *>(static_cast<CssObject3D *>(ref));
            ++count;
        }
    }
    return count;
}

void CssObject3D::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    user_id = reader.ReadInt();
    int tracks = reader.ReadCount(4);
    for (int i = 0; i < tracks; ++i)
        AddAnimationTrack(static_cast<CssAnimationTrack *>(reader.ReadObjectRefTypeChecked(AnimationTrackObject)));

    int count = reader.ReadCount(8);
    if (count > 0) {
        UserParameter *items = resize_parameters(this, count);
        for (int i = 0; i < count; ++i)
            items[i].data = NULL;
        for (int i = 0; i < count; ++i) {
            UserParameter *param = &items[i];
            param->id = reader.ReadInt();
            param->length = reader.ReadCount(1);
            if (param->length > 0) {
                param->data = new (ELeave) uint8_t[param->length];
                for (int j = 0; j < param->length; ++j)
                    param->data[j] = reader.ReadByte();
            }
        }
    }
}

int CssObject3D::Animate(int time, int stamp)
{
    if (stamp == -1) stamp = swv_next_animation_stamp();
    if (animation_stamp == stamp) return INT_MAX;
    animation_stamp = stamp;
    int validity = INT_MAX;
    int index = 0;
    for (int bucket = 0; tracks && bucket < tracks->GetBucketCount(); ++bucket) {
        const int size = tracks->GetBucketSize(bucket);
        const int property = tracks->GetAnimationTrack(index)->GetTargetProperty();
        float local[4], *sum = local;
        int capacity = 4;
        if (property == CssAnimationTrack::MorphWeights)
            static_cast<CssMorphingMesh *>(this)->GetWeightsRef(&capacity, &sum);

        int components = 0;
        bool started = false;
        for (int i = 0; i < size; ++i, ++index) {
            CssAnimationTrack *track = tracks->GetAnimationTrack(index);
            float weight = track->GetWeight();
            if (!(weight > 0) || !track->IsActive(time)) continue;
            components = track->GetKeyframeSequence()->GetcComponents();
            if (!started && capacity) swvMemSet(sum, 0, sizeof(float) * capacity);
            started = true;
            int valid;
            switch (property) {
            case CssAnimationTrack::Crop:
                if (components == 2) {
                    int width, height;
                    if (Type() == SpriteObject) {
                        auto *sprite = static_cast<CssSprite *>(this);
                        width = sprite->GetCropWidth();
                        height = sprite->GetCropHeight();
                    } else {
                        auto *background = static_cast<CssBackground *>(this);
                        width = background->GetImageCropWidth();
                        height = background->GetImageCropHeight();
                    }
                    if (weight == 1) {
                        sum[2] = static_cast<float>(width) + sum[2];
                        sum[3] = static_cast<float>(height) + sum[3];
                    } else {
                        sum[2] = static_cast<float>(width) * weight + sum[2];
                        sum[3] = static_cast<float>(height) * weight + sum[3];
                    }
                }
                valid = track->GetValueForTime(time, capacity, sum, weight);
                components = 4;
                break;
            case CssAnimationTrack::MorphWeights:
                valid = track->GetValueForTime(time, capacity, sum, weight);
                components = capacity;
                break;
            case CssAnimationTrack::Scale:
                if (components == 1) {
                    float previous = sum[0];
                    valid = track->GetValueForTime(time, capacity, sum, weight);
                    float delta = sum[0] - previous;
                    sum[1] += delta;
                    sum[2] += delta;
                } else {
                    valid = track->GetValueForTime(time, capacity, sum, weight);
                }
                components = 3;
                break;
            default:
                valid = track->GetValueForTime(time, capacity, sum, weight);
                break;
            }
            if (valid < validity) validity = valid;
        }
        if (started) SetProperty(property, components, sum);
    }
    return AnimateRefs(time, validity, stamp);
}


int CssObject3D::GetUserParameter(int id, int, uint8_t *data) const
{
    return parameter_value(parameters, parameter_index(parameters, id), data);
}

int CssObject3D::GetUserParameterValue(int index, int, uint8_t *data) const
{
    return parameter_value(parameters, index, data);
}

int CssObject3D::GetAnimationTrackCount() const
{
    return tracks ? tracks->GetAnimationTrackCount() : 0;
}

CssAnimationTrack *CssObject3D::GetAnimationTrack(int index) const
{
    if (index < 0 || index >= GetAnimationTrackCount())
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return tracks->GetAnimationTrack(index);
}

void CssObject3D::RemoveAnimationTrack(CssAnimationTrack *track)
{
    if (tracks && track)
        tracks->RemoveAnimationTrack(track);
}
