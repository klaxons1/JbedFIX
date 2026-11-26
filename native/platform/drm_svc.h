#ifndef JBED_PLATFORM_DRM_SVC_H
#define JBED_PLATFORM_DRM_SVC_H

#include "drm.h"

/* Recovered libdrm1 import ABI, shared by callers and the deny-only shim. */
int SVC_drm_openSession(DrmSvcInput);
int SVC_drm_closeSession(int);
int SVC_drm_installRights(DrmSvcInput, DrmSvcRights *);
int SVC_drm_deleteRights(const char *);
int SVC_drm_getDeliveryMethod(int);
int SVC_drm_getRightsIssuer(int, char *);
int SVC_drm_getRightsInfo(int, DrmSvcRights *);
int SVC_drm_checkRights(int, int);
int SVC_drm_consumeRights(int, int);
int SVC_drm_getContentType(int, char *);
int SVC_drm_getContent(int, int, void *, int);

#endif
