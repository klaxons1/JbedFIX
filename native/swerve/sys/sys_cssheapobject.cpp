#include "cssstatics.hpp"

void *operator new(size_t bytes, EssLeave)
{
    return CssMemoryError::LeaveIfNull(swvAllocate(bytes));
}

void *operator new(size_t bytes, EssNoLeave) noexcept
{
    return swvAllocate(bytes);
}

void *operator new[](size_t bytes, EssLeave)
{
    return CssMemoryError::LeaveIfNull(swvAllocate(bytes));
}

void *CssHeapObject::operator new(size_t bytes, EssLeave)
{
    return CssMemoryError::LeaveIfNull(swvAllocate(bytes));
}

void *CssHeapObject::operator new[](size_t bytes, EssLeave)
{
    return CssMemoryError::LeaveIfNull(swvAllocate(bytes));
}

void CssHeapObject::operator delete(void *object) noexcept
{
    swvFree(object);
}

void CssHeapObject::operator delete[](void *objects) noexcept
{
    swvFree(objects);
}
