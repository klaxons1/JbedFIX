#include "cssstatics.hpp"

CssStatics::CssStatics() = default;

CssStatics::~CssStatics() = default;

int swv_next_animation_stamp()
{
    auto &stamp = g_Statics().animation_stamp;
    if (++stamp == UINT32_MAX)
        stamp = 0;
    return static_cast<int>(stamp);
}

int swv_raw_error() { return g_Statics().error; }
void swv_record_error(int error) { g_Statics().error = error; }
SssTransformComponents *swv_default_transform() { return g_Statics().default_transform; }
CssMatrix *swv_identity_matrix() { return g_Statics().identity; }
