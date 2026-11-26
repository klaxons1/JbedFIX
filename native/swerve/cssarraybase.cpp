#include "heap_object.hpp"
#include <climits>

CssArrayBase::~CssArrayBase() = default;

void CssArrayBase::SetStorageSize(int count, int preserve)
{
    void *replacement = count ? Allocate(count) : nullptr;
    if (count && preserve > 0) {
        int old_size = size, old_capacity = capacity;
        size = -1;
        pending_data = replacement;
        CopyArray(data, replacement, preserve);
        size = old_size;
        capacity = old_capacity;
    }
    Destroy(data);
    data = replacement;
    capacity = count;
}

void CssArrayBase::SetSize(int count)
{
    if (size != count) {
        if (capacity < count) SetStorageSize(count, size);
        size = count;
    }
}

void CssArrayBase::Reserve(int count)
{
    if (count == capacity) return;
    int keep = size < count ? size : count;
    SetStorageSize(count, keep);
    size = keep;
}

void CssArrayBase::SetSizeDoubling(int count)
{
    if (count != size) {
        if (count > capacity)
            SetStorageSize(cActualElements(count, capacity), size);
        size = count;
    }
}

int CssArrayBase::cActualElements(int minimum, int capacity)
{
    if (minimum <= capacity) return capacity;
    if (minimum <= 2) return minimum;
    int next = 4;
    while (next < minimum) {
        if (next > INT_MAX / 2) g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
        next *= 2;
    }
    return next;
}
