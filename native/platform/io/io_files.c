#include "io_files.h"
#include "vm_helpers.h"
#include "vm_os.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#if defined(__APPLE__)
#include <sys/mount.h>
#else
#include <sys/vfs.h>
#endif
#include <unistd.h>

extern int android_LOGD(const char *, ...);

enum { FILE_PATH_BYTES = 4096 };
static char path[FILE_PATH_BYTES], other_path[FILE_PATH_BYTES];

static int to_path(const uint16_t *name, int length, char *out)
{
    return Jbni_convertUcs2ToUtf8(name, length, out, sizeof(path));
}

/* Flags and the async notifier are part of the exported CPL calling convention. */
#define FILE_CONTEXT int flags __attribute__((unused)), VmNotifier *notifier __attribute__((unused))
#define NOTIFIER VmNotifier *notifier __attribute__((unused))
#define NAME const uint16_t *name, int length

static void create_path(const char *base)
{
    if (!base || !*base) return;
    size_t length = strlen(base);
    if (base[length - 1] != '/') {
        android_LOGD("WARN: CPL_File the base path is not ended with /. Checkit!\n");
        return;
    }
    char *prefix = calloc(length + 1, 1);
    if (!prefix) return;
    for (size_t i = 0; i < length; ++i) {
        struct stat st;
        prefix[i] = base[i];
        if (base[i] == '/' && stat(prefix, &st) < 0) {
            int rc = mkdir(prefix, 0777);
            android_LOGD("ALWAYS: CPL_File create folder '%s' ret=%d\n", prefix, rc);
        }
    }
    free(prefix);
}

int CPL_file_startup(void)
{
    create_path(Jbed_getProperty("File.basedir"));
    create_path(getStorageRoot());
    create_path(Jbed_getProperty("Ams.local-install-dir"));
    return 0;
}

void CPL_file_shutdown(void) {}

#define FIXED_PROPERTY(fn, result) \
    int fn(NAME, FILE_CONTEXT) { (void)name; (void)length; return result; }
#define FIXED_SETTER(fn, type, result) \
    int fn(NAME, type value, FILE_CONTEXT) { (void)name; (void)length; (void)value; return result; }
FIXED_PROPERTY(CPL_file_isHidden, -1)
FIXED_PROPERTY(CPL_file_canRead, 0)
FIXED_PROPERTY(CPL_file_canWrite, 0)
FIXED_SETTER(CPL_file_setHidden, int, 0)
FIXED_SETTER(CPL_file_setReadable, int, 0)
FIXED_SETTER(CPL_file_setWritable, int, 0)
FIXED_SETTER(CPL_file_setLastModified, int64_t, -1)

int CPL_file_permission(NAME, FILE_CONTEXT)
{
    to_path(name, length, path);
    const char *root = getStorageRoot();
    if (!root || (!realpath(path, other_path) && errno != ENOENT)) return 0;
    if (!realpath(root, path)) return 0;
    if (strncmp(path, other_path, strlen(path)) == 0 ||
        strstr(other_path, "/Jbed/Installed/") || strstr(other_path, "/Jbed/PendingInstall/"))
        return 0;
    return 3;
}

int CPL_file_validFilename(NAME, int mode, FILE_CONTEXT)
{
    int bytes = to_path(name, length, path) - 1;
    if (bytes <= 0) return -1;
    for (int i = 0; i < bytes; ++i) {
        char c = path[i];
        if (!c || c == ':' || c == '\\' || (c == '*' && mode != 3)) return -1;
        if (c == '.' && ((i && path[i-1] == '/') || (i+1 < bytes && path[i+1] == '/')))
            return -1;
    }
    return 0;
}

int64_t CPL_file_lastModified(NAME, FILE_CONTEXT)
{
    struct stat st;
    if (to_path(name, length, path) <= 1 || lstat(path, &st)) return -1;
    return (int64_t)(int32_t)st.st_mtime * 1000;
}

int checkMode(NAME, int mask)
{
    struct stat st;
    if (to_path(name, length, path) <= 1 || stat(path, &st)) return -1;
    return (st.st_mode & mask) ? 0 : -1;
}

int CPL_file_setFullPermission(NAME)
{
    struct stat st;
    if (to_path(name, length, path) <= 1 || stat(path, &st)) return -1;
    return chmod(path, 0777) ? -1 : 0;
}

static int32_t directory_size(int recursive)
{
    size_t prefix = strlen(path);
    if (prefix > FILE_PATH_BYTES - 3) return -1;
    if (path[prefix-1] != '/') {
        path[prefix++] = '/';
        path[prefix] = 0;
    }
    DIR *dir = opendir(path);
    if (!dir) {
        android_LOGD("ALWAYS: cpl_file calcDirSize couldn't open dir %s\n", path);
        return -1;
    }
    uint32_t bytes = 0;
    struct dirent *entry;
    while ((entry = readdir(dir))) {
        const char *child = entry->d_name;
        if (strcmp(child, ".") == 0 || strcmp(child, "..") == 0) continue;
        path[prefix] = 0;
        size_t n = strlen(child);
        if (prefix + n + 1 > 4095) continue;
        memcpy(path + prefix, child, n + 1);
        struct stat st;
        if (stat(path, &st)) continue;
        if (st.st_mode & S_IFDIR) {
            if (recursive) {
                int32_t size = directory_size(recursive);
                if (size != -1) bytes += (uint32_t)size;
            }
        } else if (S_ISREG(st.st_mode) && st.st_blocks) {
            bytes += (uint32_t)st.st_size;
        }
    }
    closedir(dir);
    return (int32_t)bytes;
}

int64_t CPL_file_directorySize64(NAME, int recursive, FILE_CONTEXT)
{
    if (to_path(name, length, path) <= 1) return -1;
    return directory_size((uint8_t)recursive);
}

static int64_t volume_size(NAME, int available)
{
    to_path(name, length, path);
    if (strcmp(path, "/")) {
        /* Paths supplied by FileConnection start at the root. */
        char *slash = strchr(path, '/');
        slash = strchr(slash + 1, '/');
        if (slash && (slash = strchr(slash + 1, '/'))) slash[1] = 0;
    }
    struct statfs fs;
    if (statfs(path, &fs) == -1 || !fs.f_blocks) return -1;
    uint64_t blocks = available ? fs.f_bfree : fs.f_blocks;
    return (int64_t)(blocks * (uint32_t)fs.f_bsize);
}

int64_t CPL_file_availableSize64(NAME, FILE_CONTEXT) { return volume_size(name, length, 1); }
int64_t CPL_file_totalSize64(NAME, FILE_CONTEXT) { return volume_size(name, length, 0); }

int CPL_file_getFileLength(NAME, FILE_CONTEXT)
{
    struct stat st;
    if (to_path(name, length, path) <= 1 || stat(path, &st) || st.st_size > INT32_MAX-1)
        return -1;
    return (int32_t)st.st_size;
}

int CPL_file_exists(NAME, FILE_CONTEXT)
{
    while (length > 1 && name[length-1] == '/') --length;
    struct stat st;
    if (to_path(name, length, path) <= 1 || stat(path, &st)) return -1;
    if (S_ISDIR(st.st_mode)) return CPL_FILE_DIRECTORY;
    return S_ISREG(st.st_mode) ? CPL_FILE_REGULAR : -1;
}

int CPL_file_open(NAME, int mode, int flags, int *fd, NOTIFIER)
{
    (void)flags;
    static const int modes[] = {O_RDONLY, O_RDONLY, O_WRONLY | O_CREAT, O_RDWR | O_CREAT};
    if (to_path(name, length, path) <= 1) return -1;
    int opened = open(path, modes[mode & CPL_FILE_READ_WRITE], 0777);
    if (opened == -1) return -1;
    *fd = opened;
    return 0;
}

int CPL_file_flush(int fd, NOTIFIER) { return fsync(fd) ? -1 : 0; }
int CPL_file_close(int fd, NOTIFIER) { return close(fd) ? -1 : 0; }
int CPL_file_setPosition(int fd, int offset, NOTIFIER)
{
    return offset < 0 || lseek(fd, offset, SEEK_SET) == -1 ? -1 : 0;
}
int CPL_file_truncate(int fd, int length, NOTIFIER)
{
    return length < 0 || ftruncate(fd, length) < 0 ? -1 : 0;
}
int CPL_file_write(int fd, const void *data, unsigned length, NOTIFIER)
{
    return (int)write(fd, data, length);
}
int CPL_file_read(int fd, void *data, unsigned length, NOTIFIER)
{
    ssize_t count = read(fd, data, length);
    return count == 0 ? CPL_FILE_EOF : (int)count;
}

int CPL_file_mkdir(NAME, FILE_CONTEXT)
{
    if (to_path(name, length, path) <= 1) return -1;
    return mkdir(path, 0777) ? -1 : 0;
}

int CPL_file_delete(NAME, FILE_CONTEXT)
{
    struct stat st;
    if (to_path(name, length, path) <= 1 || stat(path, &st)) return -1;
    return S_ISDIR(st.st_mode) ? rmdir(path) : unlink(path);
}

static int move_across_devices(NAME, const uint16_t *to, int to_length)
{
    int src = -1, dst = -1, result = -1;
    struct stat st;
    if (to_path(name, length, path) <= 1 || to_path(to, to_length, other_path) <= 1 ||
        stat(path, &st) || !S_ISREG(st.st_mode)) return -1;
    if (CPL_file_open(to, to_length, CPL_FILE_WRITE, 0, &dst, NULL) == -1) return -1;
    if (CPL_file_open(name, length, CPL_FILE_READ, 0, &src, NULL) == -1) goto done;

    uint8_t chunk[1024] = {0};
    for (;;) {
        int n = CPL_file_read(src, chunk, sizeof(chunk), NULL);
        if (n == -3) {
            fsync(dst);
            result = 0;
            break;
        }
        if (n == -1) break;
        for (int offset = 0; offset < n;) {
            int written = CPL_file_write(dst, chunk + offset, n - offset, NULL);
            if (written <= 0) goto done;
            offset += written;
        }
    }
done:
    close(dst);
    if (src != -1) close(src);
    if (result == 0) CPL_file_delete(name, length, 0, NULL);
    return result;
}

int CPL_file_rename(NAME, const uint16_t *to, int to_length, FILE_CONTEXT)
{
    if (CPL_file_exists(to, to_length, 1, NULL) != -1 ||
        to_path(name, length, path) <= 1 || to_path(to, to_length, other_path) <= 1) return -1;
    if (!rename(path, other_path)) return 0;
    return errno == EXDEV ? move_across_devices(name, length, to, to_length) : -1;
}

int CPL_file_listOpen(NAME, int flags, DIR **directory, int *prefix, NOTIFIER)
{
    (void)flags;
    if (to_path(name, length, path) <= 1) return -1;
    char *slash = strrchr(path, '/');
    if (!slash || slash == path) {
        *prefix = length;
    } else {
        /* The listing code later treats this UTF-8 byte offset as a UCS-2 count. */
        *prefix = (int)(slash - path) + 1;
        *slash = 0;
    }
    DIR *opened = opendir(path);
    if (!opened) return -1;
    *directory = opened;
    return 0;
}

int CPL_file_listNextEntry(NAME, uint16_t *out, int out_bytes, DIR **directory, int *prefix, NOTIFIER)
{
    int capacity = out_bytes / 2;
    struct dirent *entry;
    while ((entry = readdir(*directory))) {
        const char *child = entry->d_name;
        int n = (int)strlen(child);
        if (*prefix + n > capacity || !strcmp(child, ".") || !strcmp(child, "..")) continue;
        int filter = length - *prefix;
        int i = 0;
        while (i < filter && (unsigned char)child[i] == name[*prefix+i]) ++i;
        if (i < filter) continue;
        for (i = 0; i < *prefix; ++i) out[i] = name[i];
        for (i = 0; i < n; ++i) out[*prefix+i] = (unsigned char)child[i];
        int count = *prefix + n;
        struct stat st;
        if (to_path(out, count, path) >= 2 && stat(path, &st) == 0 && S_ISDIR(st.st_mode)
            && capacity > count + 1) out[count++] = '/';
        return count;
    }
    return 0;
}

int CPL_file_listClose(DIR *directory, int prefix, NOTIFIER)
{
    (void)prefix;
    closedir(directory);
    return 0;
}
