/*
 * Recovered M3G slice: Object3D.userID accessors.
 *
 * Original ARM functions:
 *   0x002f67a8 object3d_getUserID
 *   0x002f67bc object3d_setUserID
 *
 * Confidence: high.  The original decompilation contains only the two
 * pointer-normalization operations and the field accesses reproduced below.
 */
#include "m3g_object3d_fields.h"

#include <stddef.h>

static JbedM3GObjectHeader *object_base(JbedM3GHandle handle)
{
    if (handle == NULL) {
        return NULL;
    }

    /* The original code uses `handle -= 4` on a 32-bit ARM pointer. */
    return (JbedM3GObjectHeader *)((unsigned char *)handle - 4u);
}

int jbed_m3g_object3d_get_user_id(JbedM3GHandle handle, int32_t *out_user_id)
{
    JbedM3GObjectHeader *object = object_base(handle);
    if (object == NULL || out_user_id == NULL) {
        return 0;
    }

    *out_user_id = object->user_id;
    return 1;
}

int jbed_m3g_object3d_set_user_id(JbedM3GHandle handle, int32_t user_id)
{
    JbedM3GObjectHeader *object = object_base(handle);
    if (object == NULL) {
        return 0;
    }

    object->user_id = user_id;
    return 1;
}
