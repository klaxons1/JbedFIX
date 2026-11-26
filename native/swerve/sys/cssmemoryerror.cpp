#include "cssstatics.hpp"

void *CssMemoryError::LeaveIfNull(void *address)
{
    if (!address)
        g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    return address;
}
