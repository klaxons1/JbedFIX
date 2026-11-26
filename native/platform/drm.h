#ifndef JBED_PLATFORM_DRM_H
#define JBED_PLATFORM_DRM_H

#include <stdint.h>

typedef struct {
    int32_t session, source_fd, raw_fd, raw_length;
    char raw_path[256];
} DrmContent;

typedef struct {
    int32_t fields, count;
    int64_t start_date, end_date, interval;
} DrmConstraint;

typedef struct {
    uint8_t indicator;
    uint8_t reserved[3];
    int32_t count, start_date, start_time, end_date, end_time, duration_date, duration_time;
} DrmSvcConstraint;

typedef struct {
    char uid[256];
    DrmSvcConstraint permission[4];
} DrmSvcRights;

/* The original libdrm1 API takes this entire input record by value. */
typedef struct {
    int fd;
    int mime_type;
    int (*length)(int fd);
    int (*read)(int fd, void *buffer, int count);
    int (*seek)(int fd, int position);
} DrmSvcInput;

#define DRM_FAILED ((DrmContent *)(intptr_t)-1)

DrmContent *CPL_drm_openDrmContent(const uint16_t *path, int length);
int CPL_drm_closeDrmContent(DrmContent *content);
int CPL_drm_installDrmContent(const uint16_t *path, int length, int mime);
int CPL_drm_deleteDrmContent(const uint16_t *path, int length);
int CPL_drm_isDrmContent(const uint16_t *path, int length);
int CPL_drm_isForwardLocked(const DrmContent *content);
int CPL_drm_hasRights(const DrmContent *content, int permission);
int CPL_drm_consumeRights(const DrmContent *content, int permission);
int CPL_drm_getConstraint(const DrmContent *content, int permission, DrmConstraint *result);
int CPL_drm_canRequestRights(const DrmContent *content);
int CPL_drm_requestRights(const DrmContent *content);
int CPL_drm_getContentType(const DrmContent *content, char *buffer, int size);
int CPL_drm_getContentLength(DrmContent *content);
DrmContent *CPL_drm_open(DrmContent *content);
int CPL_drm_read(const DrmContent *content, uint8_t *buffer, int offset, int length);
int CPL_drm_seek(const DrmContent *content, int position);
int CPL_drm_close(DrmContent *content);

#endif
