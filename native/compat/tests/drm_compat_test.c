#include "../../platform/drm_svc.h"
#include <assert.h>
#include <string.h>

int main(void)
{
    DrmSvcInput input = {.fd = 7, .mime_type = 255};
    DrmSvcRights rights, original;
    char output[256], expected[256];
    memset(&rights, 0xa5, sizeof rights);
    original = rights;
    memset(output, 0xa5, sizeof output);
    memcpy(expected, output, sizeof output);
    assert(SVC_drm_openSession(input) == -1);
    assert(SVC_drm_closeSession(-1) == -1);
    assert(SVC_drm_installRights(input, &rights) == -1);
    assert(SVC_drm_deleteRights("invalid") == -1);
    assert(SVC_drm_getDeliveryMethod(7) == -1);
    assert(SVC_drm_getRightsIssuer(7, output) == -1);
    assert(SVC_drm_getRightsInfo(7, &rights) == -1);
    assert(SVC_drm_checkRights(7, 1) == -1);
    assert(SVC_drm_consumeRights(7, 1) == -1);
    assert(SVC_drm_getContentType(7, output) == -1);
    assert(SVC_drm_getContent(7, 0, output, sizeof output) == -1);
    assert(!memcmp(&rights, &original, sizeof rights));
    assert(!memcmp(output, expected, sizeof output));
    assert(SVC_drm_getContent(7, 0, NULL, 0) == -1);
    return 0;
}
