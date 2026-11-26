#include "cssplasmaimage.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "cssfixed1616.hpp"

using namespace plasma_fixed;

/* The smooth interpolation uses the preceding control point starting at
 * segment 2. For segments 0 and 1 its first tangent is extrapolated. */
SwvFixedWord CssWarpMap::Warp(SwvFixedWord value) const
{
    int32_t x = static_cast<int32_t>(value);
    int n = points.size;
    if (!n) return HALF;
    if (n == 1) return points[0].y;
    const SssKnot *first = &points[0], *last = &points[n - 1];
    if (x < first->x) {
        if (!smooth) return first->y;
        int change = mul16(first->x - x, first[1].y - first->y);
        return first->y - div16(change, clampWarpSpan(first[1].x - first->x));
    }
    if (x > last->x) {
        if (!smooth) return last->y;
        int change = mul16(x - last->x, last->y - last[-1].y);
        return last->y + div16(change, clampWarpSpan(last->x - last[-1].x));
    }
    for (int i = 0; i < n - 1; ++i) {
        const SssKnot *a = &points[i], *b = a + 1;
        if (x < a->x || x > b->x || a->x == b->x) continue;
        int span = b->x - a->x, rise = b->y - a->y;
        int t = div16(x - a->x, span);
        if (!smooth) return a->y + mul16(rise, t);
        int before_y = i > 1 ? a[-1].y : a->y - rise;
        int before_width = i > 1 ? a->x - a[-1].x : span;
        int after_y = i < n - 2 ? b[1].y : b->y + rise;
        int after_width = i < n - 2 ? b[1].x - b->x : span;
        int left = div16(mul16(a->y - before_y, span), clampWarpSpan(before_width));
        int mid = div16(mul16(rise, span), span);
        int right = div16(mul16(after_y - b->y, span), clampWarpSpan(after_width));
        int t2 = mul16(t, t), t3 = mul16(t, t2);
        int y = mul16(2 * t3 - 3 * t2 + ONE, a->y) + mul16(3 * t2 - 2 * t3, b->y);
        y += mul16(t3 - 2 * t2 + t, (left + mid) >> 1);
        return y + mul16(t3 - t2, (mid + right) >> 1);
    }
    return smooth ? 0 : last->y;
}

SwvFixedWord CssWarpMap::WarpClamped(SwvFixedWord x) const
{
    return clamp01(Warp(x));
}

void CssWarpMap::CloneHelper(const CssWarpMap &source)
{
    smooth = source.smooth;
    points = source.points;
}

void CssWarpMap::InsertKnot(int index, const SssKnot &knot)
{
    points.Insert(index, knot);
}

void CssWarpMap::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    smooth = reader.ReadBool();
    int count = reader.ReadCount(sizeof(SssKnot));
    points.SetSize(count);
    for (int i = 0; i < count; ++i) {
        points[i].x = toFixed16(reader.ReadReal());
        points[i].y = toFixed16(reader.ReadReal());
    }
}
