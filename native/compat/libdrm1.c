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

#include "../platform/drm_svc.h"

/* No proprietary provider is shipped. Never create a valid session or
 * authorize content; leave output buffers untouched on every failure. */
int SVC_drm_openSession(DrmSvcInput input) { (void)input; return -1; }
int SVC_drm_closeSession(int session) { (void)session; return -1; }
int SVC_drm_installRights(DrmSvcInput input, DrmSvcRights *rights)
{ (void)input; (void)rights; return -1; }
int SVC_drm_deleteRights(const char *uid) { (void)uid; return -1; }
int SVC_drm_getDeliveryMethod(int session) { (void)session; return -1; }
int SVC_drm_getRightsIssuer(int session, char *issuer)
{ (void)session; (void)issuer; return -1; }
int SVC_drm_getRightsInfo(int session, DrmSvcRights *rights)
{ (void)session; (void)rights; return -1; }
int SVC_drm_checkRights(int session, int permission)
{ (void)session; (void)permission; return -1; }
int SVC_drm_consumeRights(int session, int permission)
{ (void)session; (void)permission; return -1; }
int SVC_drm_getContentType(int session, char *mime)
{ (void)session; (void)mime; return -1; }
int SVC_drm_getContent(int session, int offset, void *bytes, int size)
{ (void)session; (void)offset; (void)bytes; (void)size; return -1; }
