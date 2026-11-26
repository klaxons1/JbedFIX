#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "cssfixed1616.hpp"

void CssAnimationController::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    speed = r.ReadReal();
    weight = r.ReadReal();
    if (weight < 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    start = r.ReadInt();
    end = r.ReadInt();
    if (start > end) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    position = r.ReadReal();
    reference_time = r.ReadInt();
}

IssSerializable *CssAnimationController::FactoryCreate()
{
    return new CssAnimationController;
}

void CssAnimationController::CloneHelper(const CssAnimationController &source)
{
    CssObject3D::CloneHelper(source);
    start = source.start;
    end = source.end;
    position = source.position;
    reference_time = source.reference_time;
    speed = source.speed;
    weight = source.weight;
}

CssObject3D *CssAnimationController::Clone() const
{
    CssHeapPtr<CssAnimationController> copy(static_cast<CssAnimationController *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssAnimationController::SetActiveInterval(int first, int last)
{
    if (first > last) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    start = first;
    end = last;
}

void CssAnimationController::SetPosition(float new_position, int world_time)
{
    position = new_position;
    reference_time = world_time;
}

void CssAnimationController::SetSpeed(float new_speed, int world_time)
{
    float elapsed = static_cast<float>(world_time - reference_time);
    position = elapsed * speed + position;
    speed = new_speed;
    reference_time = world_time;
}

float CssAnimationController::GetPosition(int time) const
{
    float elapsed = static_cast<float>(time - reference_time);
    if (speed != 1.0f) elapsed = speed * elapsed;
    return elapsed + position;
}

float CssAnimationController::GetPositionLooped(int time, int duration) const
{
    constexpr int LoopReductionThreshold = 10000000;
    int delta = time - reference_time;
    float offset;
    if (speed == 1.0f) {
        if ((delta < -LoopReductionThreshold || delta > LoopReductionThreshold) && duration) {
            int period = delta / duration;
            delta -= saturatingTruncate(static_cast<float>(period * duration));
        }
        offset = (float)delta;
    } else {
        offset = (float)delta * speed;
        if ((offset < -LoopReductionThreshold || offset > LoopReductionThreshold) && duration && speed != 0) {
            int periods = saturatingTruncate(offset / (float)duration);
            int span;
            if (speed <= 1) {
                int period_time = periods * duration;
                span = saturatingTruncate(static_cast<float>(period_time) / speed);
            } else {
                span = duration * saturatingTruncate(static_cast<float>(periods) / speed);
            }
            offset = static_cast<float>(delta - span) * speed;
        }
    }
    return position + offset;
}
