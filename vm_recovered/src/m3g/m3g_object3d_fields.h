#ifndef JBED_RECOVERED_M3G_OBJECT3D_FIELDS_H
#define JBED_RECOVERED_M3G_OBJECT3D_FIELDS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Recovered from libjbedvm.so ARM addresses 0x2f67a8 and 0x2f67bc.
 *
 * A public Swerve handle points at payload + 4.  The implementation subtracts
 * four before accessing the internal object.  The first words are opaque here;
 * only the fields proven by the two accessors are represented.
 */
typedef struct JbedM3GObjectHeader {
    /* uint32_t is intentional: the recovered ABI is ARM32, even on host. */
    uint32_t vtable_or_type;   /* base + 0x00; opaque */
    uint32_t ref_count;        /* base + 0x04; used by SWV glue */
    uint32_t opaque_flags;     /* base + 0x08; not assigned yet */
    int32_t user_id;           /* base + 0x0c; Object3D.userID */
    uint32_t animation_tracks; /* base + 0x10; opaque ARM32 pointer */
    uint32_t user_parameters;  /* base + 0x14; opaque ARM32 pointer */
} JbedM3GObjectHeader;

/* The API handle is the address returned to the Java peer, not the base. */
typedef void *JbedM3GHandle;

int jbed_m3g_object3d_get_user_id(JbedM3GHandle handle, int32_t *out_user_id);
int jbed_m3g_object3d_set_user_id(JbedM3GHandle handle, int32_t user_id);

#ifdef __cplusplus
}
#endif

#endif
