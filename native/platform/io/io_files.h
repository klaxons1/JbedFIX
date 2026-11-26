#ifndef JBED_IO_FILES_H
#define JBED_IO_FILES_H

#include "vm_async.h"
#include <dirent.h>
#include <stdint.h>

enum { CPL_FILE_EOF = -3, CPL_FILE_REGULAR = 1, CPL_FILE_DIRECTORY = 2 };
enum { CPL_FILE_READ = 1, CPL_FILE_WRITE = 2, CPL_FILE_READ_WRITE = 3 };

/* The last parameter is the VM's asynchronous I/O notifier. The Android file
 * backend completes its operations synchronously. */
int CPL_file_startup(void);
void CPL_file_shutdown(void);
int CPL_file_setHidden(const uint16_t *, int length, int enabled, int flags, VmNotifier *notifier);
int CPL_file_setReadable(const uint16_t *, int length, int enabled, int flags, VmNotifier *notifier);
int CPL_file_setWritable(const uint16_t *, int length, int enabled, int flags, VmNotifier *notifier);
int CPL_file_canRead(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_canWrite(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_isHidden(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_setLastModified(const uint16_t *, int length, int64_t time, int flags, VmNotifier *notifier);
int64_t CPL_file_lastModified(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_setFullPermission(const uint16_t *, int length);
int CPL_file_permission(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_validFilename(const uint16_t *, int length, int mode, int flags, VmNotifier *notifier);
int checkMode(const uint16_t *, int length, int mask);
int64_t CPL_file_totalSize64(const uint16_t *, int length, int flags, VmNotifier *notifier);
int64_t CPL_file_availableSize64(const uint16_t *, int length, int flags, VmNotifier *notifier);
int64_t CPL_file_directorySize64(const uint16_t *, int length, int recursive, int flags, VmNotifier *notifier);
int CPL_file_getFileLength(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_exists(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_open(const uint16_t *, int length, int mode, int flags, int *fd, VmNotifier *notifier);
int CPL_file_mkdir(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_delete(const uint16_t *, int length, int flags, VmNotifier *notifier);
int CPL_file_rename(const uint16_t *, int length, const uint16_t *to, int to_length, int flags, VmNotifier *notifier);
int CPL_file_listOpen(const uint16_t *, int length, int flags, DIR **directory, int *prefix, VmNotifier *notifier);
int CPL_file_listNextEntry(const uint16_t *, int length, uint16_t *out, int out_bytes,
                           DIR **directory, int *prefix, VmNotifier *notifier);
int CPL_file_listClose(DIR *, int prefix, VmNotifier *notifier);
int CPL_file_flush(int fd, VmNotifier *notifier);
int CPL_file_setPosition(int fd, int offset, VmNotifier *notifier);
int CPL_file_truncate(int fd, int length, VmNotifier *notifier);
int CPL_file_close(int fd, VmNotifier *notifier);
int CPL_file_write(int fd, const void *data, unsigned length, VmNotifier *notifier);
int CPL_file_read(int fd, void *data, unsigned length, VmNotifier *notifier);

#endif
