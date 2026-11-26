#include "drm.h"
#include "io_files.h"
#include "vm_helpers.h"
#include "jbni_objects.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

extern int SVC_drm_openSession(DrmSvcInput);
extern int SVC_drm_closeSession(int);
extern int SVC_drm_installRights(DrmSvcInput, DrmSvcRights *);
extern int SVC_drm_deleteRights(const char *);
extern int SVC_drm_getDeliveryMethod(int);
extern int SVC_drm_getRightsIssuer(int, char *);
extern int SVC_drm_getRightsInfo(int, DrmSvcRights *);
extern int SVC_drm_checkRights(int, int);
extern int SVC_drm_consumeRights(int, int);
extern int SVC_drm_getContentType(int, char *);
extern int SVC_drm_getContent(int, int, void *, int);

extern int android_LOGD(const char *, ...);
extern int android_midp_platformRequest(const uint16_t *, int);

_Static_assert(sizeof(DrmSvcRights) == 384, "SVC rights information layout");
_Static_assert(sizeof(DrmContent) == 272, "DRM session allocation");

static int source_length(int fd)
{
    struct stat st;
    return fstat(fd, &st) == -1 ? 0 : (int32_t)st.st_size;
}

static int source_read(int fd, void *bytes, int length)
{
    ssize_t n = CPL_file_read(fd, bytes, (unsigned)length, NULL);
    if (n == -3) return -1;
    return n == -1 ? 0 : (int)n;
}

static int source_seek(int fd, int offset)
{
    return CPL_file_setPosition(fd, offset, NULL);
}

static DrmSvcInput source(int fd, int mime)
{
    return (DrmSvcInput){fd, mime, source_length, source_read, source_seek};
}

int openDrmFile(const uint16_t *path, int length)
{
    int fd = -1;
    if (CPL_file_open(path, length, 1, 0, &fd, NULL)) return -1;
    if (fd != 0) return fd;
    fd = dup(0);
    if (fd == -1) android_LOGD("ERROR : cpl_file openDrmFile fail to duplicate handle\n");
    else CPL_file_close(0, NULL);
    return fd;
}

DrmContent *CPL_drm_openDrmContent(const uint16_t *path, int length)
{
    int fd = openDrmFile(path, length);
    if (fd == -1) {
        android_LOGD("ERROR: CPL_drm_openDrmContent() fail: install - open file\n");
        return DRM_FAILED;
    }
    int session = SVC_drm_openSession(source(fd, 255));
    if (session < 0) {
        android_LOGD("ERROR: CPL_drm_openDrmContent() fail to call SVC_drm_openSession ret=%d\n", session);
    } else {
        DrmContent *c = malloc(sizeof(*c));
        if (c) {
            c->source_fd = fd;
            c->session = session;
            c->raw_length = -1;
            c->raw_path[0] = '\0';
            return c;
        }
        android_LOGD("ERROR: CPL_drm_openDrmContent() fail to malloc\n");
    }
    CPL_file_close(fd, NULL);
    return DRM_FAILED;
}

int CPL_drm_closeDrmContent(DrmContent *c)
{
    unlink(c->raw_path);
    CPL_file_close(c->source_fd, NULL);
    int status = SVC_drm_closeSession(c->session);
    free(c);
    return status == 0 ? 0 : -1;
}

int CPL_drm_isDrmContent(const uint16_t *path, int length)
{
    DrmContent *c = CPL_drm_openDrmContent(path, length);
    if (!c) return 0;
    if ((intptr_t)c > 0) CPL_drm_closeDrmContent(c);
    return -1;
}

int CPL_drm_installDrmContent(const uint16_t *path, int length, int mime)
{
    DrmSvcRights rights;
    int fd = openDrmFile(path, length);
    if (fd == -1) {
        android_LOGD("ERROR: CPL_drm_installDrmContent() fail: install - open file\n");
        return -1;
    }
    int type = mime >= 1 && mime <= 4 ? 71 + mime : 255;
    int status = SVC_drm_installRights(source(fd, type), &rights);
    CPL_file_close(fd, NULL);
    return status == -1 ? -1 : 0;
}

int CPL_drm_deleteDrmContent(const uint16_t *path, int length)
{
    DrmSvcRights rights;
    DrmContent *c = CPL_drm_openDrmContent(path, length);
    int status = (int)(intptr_t)c;
    if ((intptr_t)c > 0) {
        status = SVC_drm_getRightsInfo(c->session, &rights);
        CPL_drm_closeDrmContent(c);
    }
    if (status == 0 && SVC_drm_deleteRights(rights.uid) == 0) return 0;
    android_LOGD("ERROR: CPL_drm_deleteDrmContent() failed to call SVC_drm_deleteRights() ret=%d\n", status);
    return -1;
}

int CPL_drm_isForwardLocked(const DrmContent *c)
{
    return SVC_drm_getDeliveryMethod(c->session) == 3 ? -1 : 0;
}

static int permission_bit(int permission)
{
    return permission >= 1 && permission <= 4 ? 1 << (permission - 1) : -1;
}

int CPL_drm_hasRights(const DrmContent *c, int permission)
{
    return SVC_drm_checkRights(c->session, permission_bit(permission)) == 0 ? 0 : -1;
}

int CPL_drm_consumeRights(const DrmContent *c, int permission)
{
    return SVC_drm_consumeRights(c->session, permission_bit(permission)) == 0 ? 0 : -1;
}

static int clamp(int value, int low, int high)
{
    return value < low ? low : value > high ? high : value;
}

static int64_t date_millis(int date, int time)
{
    int year = date / 10000;
    return 1000 * jbed_mkgmtime(year < 1970 ? 1970u : (unsigned)year,
        clamp(date / 100 % 100, 1, 12), clamp(date % 100, 1, 31),
        clamp(time / 10000, 0, 23), clamp(time / 100 % 100, 0, 59), clamp(time % 100, 0, 59));
}

static int64_t interval_millis(int date, int time)
{
    int days = 365 * (date / 10000) + 30 * (date / 100 % 100) + date % 100;
    int32_t daytime = (int32_t)(3600000u * (time / 10000) + 60000u * (time / 100 % 100)
                                + 1000u * (time % 100));
    return (int64_t)days * 86400000 + daytime;
}

int CPL_drm_getConstraint(const DrmContent *c, int permission, DrmConstraint *result)
{
    DrmSvcRights rights;
    if (SVC_drm_getRightsInfo(c->session, &rights)) {
        android_LOGD("ERROR: CPL_drm_getConstraint() failed to call SVC_drm_getRightsInfo\n");
        return -1;
    }
    if (permission < 1 || permission > 4) return -1;
    const DrmSvcConstraint *r = &rights.permission[permission - 1];
    if (!r->indicator) return -1;
    int fields = 0;
    if (r->indicator & 4) {
        result->interval = interval_millis(r->duration_date, r->duration_time);
        fields |= 8;
    }
    if (r->indicator & 8) {
        result->end_date = date_millis(r->end_date, r->end_time);
        fields |= 4;
    }
    if (r->indicator & 1) {
        result->start_date = date_millis(r->start_date, r->start_time);
        fields |= 2;
    }
    if (r->indicator & 2) {
        result->count = r->count;
        fields |= 1;
    }
    result->fields = fields;
    return 0;
}

int CPL_drm_canRequestRights(const DrmContent *c)
{
    char issuer[256];
    return SVC_drm_getRightsIssuer(c->session, issuer) == 0 ? 0 : -1;
}

int CPL_drm_requestRights(const DrmContent *c)
{
    char issuer[257] = {0};
    uint16_t url[256];
    int status = SVC_drm_getRightsIssuer(c->session, issuer);
    for (char *p = issuer; *p; ++p) if (*p == '\\') *p = '/';
    int n = Jbni_convertAsciiToUcs2(issuer, -1, url, sizeof(url));
    if (n == -1) {
        android_LOGD("ERROR: CPL_drm_requestRights Jbni_convertAsciiToUcs2 url array is not big enough.\n");
        return -1;
    }
    if (android_midp_platformRequest(url, n) == -1) {
        android_LOGD("ERROR: CPL_drm_requestRights android_midp_platformRequest return -1\n");
        return -1;
    }
    return status == 0 ? 0 : -1;
}

int CPL_drm_getContentType(const DrmContent *c, char *buffer, int size)
{
    if (size < 64) android_LOGD("WARNING: CPL_drm_getContentType the buffer is too small %d\n", size);
    if (SVC_drm_getContentType(c->session, buffer)) {
        android_LOGD("ERROR: CPL_drm_getContentType() failed to get contentType\n");
        return -1;
    }
    return 0;
}

int extractRawDataToTempFile(DrmContent *c)
{
    static int serial;
    snprintf(c->raw_path, sizeof(c->raw_path), "/data/data/com.esmertec.android.jbed/tmp/d_file%d", serial);
    serial = serial > 10240 ? 1 : serial + 1;
    int fd = open(c->raw_path, O_RDWR | O_CREAT | O_TRUNC, 0777);
    if (fd == -1) {
        android_LOGD("ERROR: cpl_drm extractRawDataToTempFile ,fail to create file \n");
        return -1;
    }
    uint8_t buffer[1024];
    int offset = 0, n;
    while ((n = SVC_drm_getContent(c->session, offset, buffer, sizeof(buffer))) >= 0) {
        if (n > 0) {
            offset += n;
            (void)write(fd, buffer, (size_t)n);
        }
    }
    c->raw_length = offset;
    close(fd);
    return 0;
}

int CPL_drm_getContentLength(DrmContent *c)
{
    if (c->raw_length == -1 && extractRawDataToTempFile(c) == -1)
        android_LOGD("ERROR: CPL_drm_getContentLength fail to extractRawDataToTempFile\n");
    return c->raw_length;
}

DrmContent *CPL_drm_open(DrmContent *c)
{
    if (c->raw_length == -1 && extractRawDataToTempFile(c) == -1) {
        android_LOGD("ERROR: CPL_drm_open fail to extractRawDataToTempFile\n");
        return DRM_FAILED;
    }
    int fd = open(c->raw_path, O_RDONLY);
    if (fd < 0) {
        android_LOGD("ERROR: CPL_drm_open, fail to open file\n");
        return DRM_FAILED;
    }
    c->raw_fd = fd;
    return c;
}

int CPL_drm_read(const DrmContent *c, uint8_t *buffer, int offset, int length)
{
    ssize_t n = read(c->raw_fd, buffer + offset, (size_t)length);
    if (n == 0) return -2;
    if (n < 0) android_LOGD("ERROR: CPL_drm_read() failed to call SVC_drm_getContent() errorno=%d\n", (int)n);
    return (int)n;
}

int CPL_drm_seek(const DrmContent *c, int position)
{
    if (lseek(c->raw_fd, position, SEEK_SET) >= 0) return 0;
    android_LOGD("ERROR: CPL_drm_seek, fail to seek file to %d\n", position);
    return -1;
}

int CPL_drm_close(DrmContent *c)
{
    close(c->raw_fd);
    unlink(c->raw_path);
    return 0;
}

/* Java object references and native handles occupy one ARM word. */
typedef struct { uint32_t header[3], content; } DrmObject;
typedef struct {
    uint32_t header[3];
    int32_t count;
    int64_t start_date, end_date, interval;
} DrmJavaConstraint;

static DrmContent *content_of(const DrmObject *object)
{
    return (DrmContent *)(uintptr_t)object->content;
}

void JbniV_com_jbed_drm_DrmContent_finalize(DrmObject *self)
{
    if (self->content != UINT32_MAX) CPL_drm_closeDrmContent(content_of(self));
}

int JbniV_com_jbed_drm_DrmContent_nativeCloseDrmContent(DrmObject *self)
{
    int status = CPL_drm_closeDrmContent(content_of(self));
    self->content = UINT32_MAX;
    return status;
}

int JbniV_com_jbed_drm_DrmContent_nativeGetConstraint(DrmObject *self, int permission, DrmJavaConstraint *out)
{
    DrmConstraint info;
    int status = CPL_drm_getConstraint(content_of(self), permission, &info);
    if (!status) {
        if (info.fields & 1) out->count = info.count;
        if (info.fields & 2) out->start_date = info.start_date;
        if (info.fields & 4) out->end_date = info.end_date;
        if (info.fields & 8) out->interval = info.interval;
    }
    return status;
}

int JbniV_com_jbed_drm_DrmContent_nativeIsForwardLocked(DrmObject *self)
{
    return CPL_drm_isForwardLocked(content_of(self));
}

int JbniV_com_jbed_drm_DrmContent_nativeRequestRights(DrmObject *self)
{
    return CPL_drm_requestRights(content_of(self));
}

int JbniV_com_jbed_drm_DrmContent_nativeCanRequestRights(DrmObject *self)
{
    return CPL_drm_canRequestRights(content_of(self));
}

int JbniV_com_jbed_drm_DrmContent_nativeConsumeRights(DrmObject *self, int permission)
{
    return CPL_drm_consumeRights(content_of(self), permission);
}

int JbniV_com_jbed_drm_DrmContent_nativeHasRights(DrmObject *self, int permission)
{
    return CPL_drm_hasRights(content_of(self), permission);
}

int JbniV_com_jbed_drm_DrmContent_nativeClose(DrmObject *self, DrmContent *stream)
{
    (void)self;
    return CPL_drm_close(stream);
}

int JbniV_com_jbed_drm_DrmContent_nativeSeek(DrmObject *self, DrmContent *stream, int position)
{
    (void)self;
    return CPL_drm_seek(stream, position);
}

int JbniV_com_jbed_drm_DrmContent_nativeRead(DrmObject *self, DrmContent *stream,
                                              JbArray *bytes, int offset, int length)
{
    (void)self;
    return CPL_drm_read(stream, (uint8_t *)bytes->data, offset, length);
}

DrmContent *JbniV_com_jbed_drm_DrmContent_nativeOpen(DrmObject *self)
{
    return CPL_drm_open(content_of(self));
}

JbString *JbniV_com_jbed_drm_DrmContent_nativeGetContentType(DrmObject *self)
{
    char buffer[256];
    if (CPL_drm_getContentType(content_of(self), buffer, sizeof(buffer))) return NULL;
    return Jbni_intern_newStringExc(buffer);
}

int JbniV_com_jbed_drm_DrmContent_nativeGetContentLength(DrmObject *self)
{
    return CPL_drm_getContentLength(content_of(self));
}

int JbniV_com_jbed_drm_DrmContent_nativeOpenDrmContent(DrmObject *self, const JbString *s)
{
    DrmContent *c = CPL_drm_openDrmContent(jb_string_chars(s), s->length);
    self->content = jb_ref(c);
    return c == DRM_FAILED ? -1 : 0;
}

int JbniS_com_jbed_drm_DrmContent_nativeIsDrmContent(const JbString *s)
{
    return CPL_drm_isDrmContent(jb_string_chars(s), s->length);
}

int JbniS_com_jbed_drm_DrmContent_nativeDeleteDrmContent(const JbString *s)
{
    return CPL_drm_deleteDrmContent(jb_string_chars(s), s->length);
}

int JbniS_com_jbed_drm_DrmContent_nativeInstallDrmContent(const JbString *s, int mime)
{
    return CPL_drm_installDrmContent(jb_string_chars(s), s->length, mime);
}
