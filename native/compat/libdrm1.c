/*
 * Compatibility shim for the proprietary pre-Android DRM1 library.
 *
 * Jbed's 2011 ARM VM declares a DT_NEEDED dependency on libdrm1.so. Android
 * 11 no longer provides it. The VM only reaches this API for OMA DRM-protected
 * content; ordinary MIDlets do not need it. These stubs deliberately deny all
 * DRM operations, allowing the dynamic linker to continue loading the VM.
 *
 * This is not a DRM implementation. A protected .dm/.drm MIDlet must fail
 * cleanly rather than have its rights checked or consumed.
 */

#include <stdarg.h>

/* The old SVC DRM API reports non-zero values for errors. Returning -1 also
 * ensures that callers which expect an integer session handle never receive a
 * valid handle from the compatibility layer. The exact old proprietary method
 * signatures are not public; varargs are intentional because ELF resolution
 * is by symbol name and every operation is rejected before arguments matter.
 */
#define DRM_STUB(name) int name(int ignored, ...) { (void) ignored; return -1; }

DRM_STUB(SVC_drm_openSession)
DRM_STUB(SVC_drm_closeSession)
DRM_STUB(SVC_drm_getDeliveryMethod)
DRM_STUB(SVC_drm_deleteRights)
DRM_STUB(SVC_drm_getRightsIssuer)
DRM_STUB(SVC_drm_getContentType)
DRM_STUB(SVC_drm_getRightsInfo)
DRM_STUB(SVC_drm_checkRights)
DRM_STUB(SVC_drm_installRights)
DRM_STUB(SVC_drm_consumeRights)
DRM_STUB(SVC_drm_getContent)
