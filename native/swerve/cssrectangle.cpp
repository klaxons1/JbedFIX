#include "graphics3d_state.h"
#include <algorithm>

bool CssRectangle::Intersect(const CssRectangle &other)
{
    int right = x + w - 1, bottom = y + h - 1;
    int other_right = other.x + other.w - 1, other_bottom = other.y + other.h - 1;
    if (x > other_right || y > other_bottom || right < other.x || bottom < other.y) {
        *this = {};
        return false;
    }
    x = std::max(x, other.x);
    y = std::max(y, other.y);
    w = std::min(right, other_right) - x + 1;
    h = std::min(bottom, other_bottom) - y + 1;
    return true;
}
