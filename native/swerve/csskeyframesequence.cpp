#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "cssquaternion.hpp"
#include "engine.h"
#include "cssfixed1616.hpp"
#include <cfloat>
#include <bit>

// Each key starts with an integer timestamp stored in one word of the float array.
static int keyTime(const float *key)
{
    return std::bit_cast<int32_t>(*key);
}

void CssKeyframeSequence::Construct(int frames, int channels, EssInterpolation mode)
{
    if ((mode == Slerp || mode == Squad) && channels != 4)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    count = frames;
    last = frames - 1;
    components = channels;
    interpolation = mode;
    uint64_t stride = 1 + uint64_t(channels) * ((mode == Spline || mode == Squad) ? 3 : 1);
    if (stride * frames > INT32_MAX || stride * frames > SIZE_MAX / sizeof(float))
        g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    int words = CalcStride() * frames;
    keys.SetSize(words);
    if (words > 0)
        memset(keys.data, 0, sizeof(float) * words);
    validated = false;
}

void CssKeyframeSequence::SetDuration(int value)
{
    duration = value;
    duration_float = static_cast<float>(value);
}

void CssKeyframeSequence::SetValidRange(int begin, int end)
{
    if (static_cast<unsigned>(begin) >= static_cast<unsigned>(count) ||
        static_cast<unsigned>(end) >= static_cast<unsigned>(count))
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    first = begin;
    last = end;
    validated = false;
}

int CssKeyframeSequence::GetKeyframe(int index, int length, float *value)
{
    if (static_cast<unsigned>(index) >= static_cast<unsigned>(count)) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    if (value && length < components) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    const float *key = KeyData(index, CalcStride());
    if (value) {
        for (int i = 0; i < components; ++i)
            value[i] = key[i + 1];
    }
    return keyTime(key);
}

void CssKeyframeSequence::SetKeyframe(int index, int time, int length, const float *value)
{
    if (static_cast<unsigned>(index) >= static_cast<unsigned>(count)) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    if (length < components) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    float *key = KeyData(index, CalcStride());
    *key = std::bit_cast<float>(time);
    for (int i = 0; i < components; ++i)
        key[i + 1] = g_ValidateFloat(value[i]);
    if (validated && (first <= last ? first <= index && index <= last : first <= index || index <= last))
        validated = false;
}

void CssKeyframeSequence::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    interpolation = static_cast<EssInterpolation>(r.ReadEnum(Linear - 1, Step + 1));
    repeat = static_cast<EssRepeatMode>(r.ReadEnum(Constant - 1, Loop + 1));
    enum KeyEncoding { FloatComponents, QuantizedByteComponents, QuantizedShortComponents };
    int encoding = r.ReadByte();
    if (encoding > QuantizedShortComponents) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    duration = r.ReadInt();
    if (duration <= 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    duration_float = static_cast<float>(duration);
    int begin = r.ReadInt();
    int end = r.ReadInt();
    components = r.ReadInt();
    if (components < 1 || ((interpolation == Slerp || interpolation == Squad) && components != 4))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    count = r.ReadInt();
    if (count <= 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    uint64_t words = (1 + uint64_t(components) * ((interpolation == Spline || interpolation == Squad) ? 3 : 1)) * count;
    if (words > INT32_MAX || words > SIZE_MAX / sizeof(float)) g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    int stride = CalcStride();
    keys.SetSize(count * stride);
    if (encoding != FloatComponents) {
        CssHeapPtr<CssArray<float>> bias(new CssArray<float>);
        CssHeapPtr<CssArray<float>> scale(new CssArray<float>);
        r.ReadRealArray(*bias, components);
        r.ReadRealArray(*scale, components);
        for (int frame = 0; frame < count; ++frame) {
            float *key = KeyData(frame, stride);
            int time = r.ReadInt();
            *key = std::bit_cast<float>(time);
            if (time < 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
            for (int i = 0; i < components; ++i) {
                int value = encoding == QuantizedByteComponents ? r.ReadByte() : r.ReadUInt16();
                float fraction = static_cast<float>(value) / (encoding == QuantizedByteComponents ? 255.0f : 65535.0f);
                key[i + 1] = (*scale)[i] * fraction + (*bias)[i];
            }
        }
    } else {
        for (int frame = 0; frame < count; ++frame) {
            float *key = KeyData(frame, stride);
            int time = r.ReadInt();
            *key = std::bit_cast<float>(time);
            if (time < 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
            for (int i = 0; i < components; ++i)
                key[i + 1] = r.ReadReal();
        }
    }
    SetValidRange(begin, end);
}

IssSerializable *CssKeyframeSequence::FactoryCreate()
{
    return new CssKeyframeSequence;
}

void CssKeyframeSequence::CloneHelper(const CssKeyframeSequence &source)
{
    CssObject3D::CloneHelper(source);
    interpolation = source.interpolation;
    repeat = source.repeat;
    duration_float = source.duration_float;
    duration = source.duration;
    first = source.first;
    last = source.last;
    components = source.components;
    count = source.count;
    keys = source.keys;
    validated = source.validated;
}

CssObject3D *CssKeyframeSequence::Clone() const
{
    CssHeapPtr<CssKeyframeSequence> copy(static_cast<CssKeyframeSequence *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

int CssKeyframeSequence::CalcRangeKeyFrames() const
{
    return last - first + 1 + (last < first ? count : 0);
}

int CssKeyframeSequence::GetiKeyframeSucc(int index) const
{
    if (first <= last)
        return index < last ? index + 1 : first;
    if (index >= first && index < count)
        return index + 1 < count ? index + 1 : 0;
    index -= count;
    return index < last ? index + 1 : first;
}

int CssKeyframeSequence::GetiKeyframePred(int index) const
{
    if (first <= last || (index >= first && index < count))
        return index > first ? index - 1 : last;
    index -= count;
    return index > 0 ? index - 1 : count - 1;
}

void CssKeyframeSequence::CalculateTangents(bool squad) const
{
    const int stride = CalcStride();
    const int end = first + CalcRangeKeyFrames() - 1;
    const int period = saturatingTruncate(duration_float + 0.5f);
    for (int frame = first; frame <= end; ++frame) {
        float *key = KeyData(frame % count, stride);
        bool endpoint = repeat == Constant && (frame == first || frame == end);
        float *out = key + 1 + components;
        float *in = out + components;
        if (endpoint && !squad) {
            for (int j = 0; j < components; ++j)
                out[j] = in[j] = 0;
            continue;
        }

        const float *before = KeyData(GetiKeyframePred(frame), stride);
        const float *after = KeyData(GetiKeyframeSucc(frame), stride);
        float incoming = 0, outgoing = 0;
        if (!endpoint) {
            uint32_t t0 = keyTime(before), t1 = keyTime(key), t2 = keyTime(after);
            if (frame == first)
                t0 -= period;
            else if (frame == end)
                t2 += period;
            float span = static_cast<float>(static_cast<int32_t>(t2 - t0));
            incoming = static_cast<float>(static_cast<int32_t>(t1 - t0)) / span;
            outgoing = static_cast<float>(static_cast<int32_t>(t2 - t1)) / span;
        }
        if (squad) {
            CssQuaternion left, right, out_delta, in_delta;
            CssQuaternion::SquadLogDiff(left.q, before + 1, key + 1);
            CssQuaternion::SquadLogDiff(right.q, key + 1, after + 1);
            for (int j = 0; j < 4; ++j) {
                float sum = left.q[j] + right.q[j];
                out_delta.q[j] = (outgoing * sum - right.q[j]) * 0.5f;
                in_delta.q[j] = (left.q[j] - incoming * sum) * 0.5f;
            }
            out_delta.Exp();
            in_delta.Exp();
            CssQuaternion out_q, in_q;
            memcpy(out_q.q, key + 1, sizeof out_q.q);
            in_q = out_q;
            out_q *= out_delta;
            in_q *= in_delta;
            memcpy(out, out_q.q, sizeof out_q.q);
            memcpy(in, in_q.q, sizeof in_q.q);
        } else {
            for (int j = 0; j < components; ++j) {
                float difference = after[1 + j] - before[1 + j];
                out[j] = outgoing * difference;
                in[j] = incoming * difference;
            }
        }
    }
}

void CssKeyframeSequence::Validate() const
{
    const int stride = CalcStride();
    auto time = [&](int i) { return keyTime(KeyData(i, stride)); };
    if (first <= last) {
        for (int i = first; i < last; ++i)
            if (time(i) > time(i + 1)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    } else {
        for (int i = first; i < count - 1; ++i)
            if (time(i) > time(i + 1)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        if (time(count - 1) > time(0)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
        // The wrapped second segment omits its last pair.
        for (int i = 0; i < last - 1; ++i)
            if (time(i) > time(i + 1)) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    }

    const int range = CalcRangeKeyFrames();
    if (static_cast<float>(time(last)) > duration_float) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    validated = true;
    if (interpolation == Slerp || interpolation == Squad) {
        for (int i = first; i < first + range; ++i) {
            float *value = KeyData(i % count, stride) + 1;
            CssQuaternion q;
            memcpy(q.q, value, sizeof q.q);
            q.Normalize();
            memcpy(value, q.q, sizeof q.q);
        }
    }
    if (interpolation == Spline || interpolation == Squad)
        CalculateTangents(interpolation == Squad);
}

float CssKeyframeSequence::GetWeightedValue(int time, const CssAnimationTrack *track, int capacity, float *sum, float weight) const
{
    if (duration_float <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    if (!validated) Validate();

    const int end = first + CalcRangeKeyFrames();
    const int stride = CalcStride();
    auto frameTime = [&](int frame) {
        return static_cast<float>(keyTime(KeyData(frame % count, stride)));
    };
    const float start_time = frameTime(first);
    const float end_time = frameTime(end - 1);
    float position, validity = -1;
    bool before_first = false;
    if (repeat == Loop) {
        auto *controller = track->GetController();
        position = controller ? controller->GetPositionLooped(time, saturatingTruncate(duration_float)) : 0;
        int cycles = saturatingTruncate(position / duration_float);
        position -= static_cast<float>(cycles) * duration_float;
        if (position < 0) position += duration_float;
    } else {
        position = track->GetTime(time);
        if (position < start_time) {
            validity = start_time - position;
            position = start_time;
            before_first = true;
        } else {
            if (position >= duration_float) position = static_cast<float>(duration - 1);
            if (position > end_time) {
                validity = FLT_MAX;
                position = end_time;
            }
        }
    }

    int frame = first;
    bool at_key = true;
    float t = 0;
    if (end - first == 1) {
        validity = FLT_MAX;
    } else if (!before_first && position >= start_time && position < end_time) {
        float a = start_time, b = frameTime(frame + 1);
        while (frame + 1 < end && position >= b) {
            ++frame;
            a = b;
            b = frameTime(frame + 1);
        }
        at_key = position == a;
        if (!at_key) t = (position - a) / (b - a);
    } else if (repeat == Loop) {
        frame = end - 1;
        if (interpolation != Step) {
            at_key = position == end_time;
            if (!at_key) {
                float tail = duration_float - end_time;
                float elapsed = position >= start_time ? position - end_time : tail + position;
                t = elapsed / (tail + start_time);
            }
        }
    } else if (!before_first) {
        frame = end - 1;
    }

    const int n = capacity < components ? capacity : components;
    const float *a = KeyData(frame % count, stride) + 1;
    if (at_key || interpolation == Step) {
        if (weight == 1) {
            for (int i = 0; i < n; ++i)
                sum[i] += a[i];
        } else {
            for (int i = 0; i < n; ++i)
                sum[i] = weight * a[i] + sum[i];
        }
    } else {
        const float *b = KeyData(GetiKeyframeSucc(frame), stride) + 1;
        switch (interpolation) {
        case Linear:
            for (int i = 0; i < n; ++i) {
                float value = (b[i] - a[i]) * t + a[i];
                if (weight != 1) value *= weight;
                sum[i] = value + sum[i];
            }
            break;
        case Spline: {
            const float *out = a + components;
            const float *in = b + 2 * components;
            float t2 = t * t, t3 = t2 * t;
            float twice_cube = t3 * 2.0f, triple_square = t2 * 3;
            float wa = 1 - triple_square + twice_cube;
            float wb = -twice_cube + triple_square;
            float wo = t - t2 * 2.0f + t3;
            float wi = t3 - t2;
            for (int i = 0; i < n; ++i) {
                float value = wa * a[i] + wb * b[i];
                value = value + wo * out[i] + wi * in[i];
                if (weight != 1) value *= weight;
                sum[i] = value + sum[i];
            }
            break;
        }
        case Slerp:
        case Squad: {
            CssQuaternion q;
            if (interpolation == Slerp)
                CssQuaternion::Slerp(q.q, a, b, t);
            else
                CssQuaternion::Squad(q.q, a, a + components, b + 2 * components, b, t);
            if (weight != 1) q *= weight;
            for (int i = 0; i < 4; ++i)
                sum[i] += q.q[i];
            break;
        }
        default: break;
        }
    }

    if (validity < 0) {
        validity = 0;
        if (interpolation == Linear || interpolation == Slerp || interpolation == Step) {
            const float *next = KeyData(GetiKeyframeSucc(frame), stride);
            for (int i = 0; i < n; ++i)
                if (sum[i] != next[1 + i]) return 0;
            validity = static_cast<float>(keyTime(next)) - position;
            if (validity < 0) validity += duration_float;
        }
    }
    return validity;
}
