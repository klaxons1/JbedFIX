#ifndef JBED_RECOVERED_M3G_TRANSFORM_LAYOUT_H
#define JBED_RECOVERED_M3G_TRANSFORM_LAYOUT_H

#include <stdint.h>
#include "m3g_object3d_fields.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Exact 0x44-byte state initialized by sub_2D8174 at Transform base + 0x0c.
 * The first sixteen words are IEEE-754 single-precision matrix elements in
 * the original ARM32 image.  Word 16 is a state/format flag.
 */
typedef struct JbedM3GMatrixState {
    uint32_t element_bits[16];
    uint32_t state;
} JbedM3GMatrixState;

int jbed_m3g_transform_set_identity(JbedM3GHandle handle);
int jbed_m3g_transform_get_matrix_state(JbedM3GHandle handle,
                                         JbedM3GMatrixState *out_state);

#ifdef __cplusplus
}
#endif

#endif
