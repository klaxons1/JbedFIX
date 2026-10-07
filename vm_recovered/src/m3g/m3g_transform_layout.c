/*
 * Transform layout and identity operation.
 *
 * Original functions:
 *   0x002f86bc transform_setIdentity
 *   0x002d8174 sub_2D8174
 *
 * `transform_setIdentity` passes object_base + 0x0c to sub_2D8174.  The
 * latter writes a 4x4 single-precision identity matrix followed by state 63.
 * No guessed fixed-point scale is used here: the original constants are the
 * IEEE-754 bits for 1.0f (0x3f800000).
 */
#include "m3g_transform_layout.h"

#include <stddef.h>
#include <string.h>

static JbedM3GMatrixState *matrix_state(JbedM3GHandle handle)
{
    if (handle == NULL) {
        return NULL;
    }
    return (JbedM3GMatrixState *)((unsigned char *)handle - 4u + 0x0cu);
}

int jbed_m3g_transform_set_identity(JbedM3GHandle handle)
{
    JbedM3GMatrixState *state = matrix_state(handle);
    if (state == NULL) {
        return 0;
    }

    memset(state, 0, sizeof(*state));
    state->element_bits[0] = UINT32_C(0x3f800000);
    state->element_bits[5] = UINT32_C(0x3f800000);
    state->element_bits[10] = UINT32_C(0x3f800000);
    state->element_bits[15] = UINT32_C(0x3f800000);
    state->state = 63u;
    return 1;
}

int jbed_m3g_transform_get_matrix_state(JbedM3GHandle handle,
                                         JbedM3GMatrixState *out_state)
{
    JbedM3GMatrixState *state = matrix_state(handle);
    if (state == NULL || out_state == NULL) {
        return 0;
    }
    memcpy(out_state, state, sizeof(*out_state));
    return 1;
}
