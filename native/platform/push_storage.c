#include "push.h"
#include "vm_os.h"
#include "io_files.h"
#include "vm_helpers.h"

#include <stdlib.h>
#include <string.h>


struct PushFile {
    int fd, position, size;
    union { char line[1024]; uint16_t path[512]; } buffer;
};

PushFile *CPL_push_open(int operation)
{
    const char *base = Jbed_getProperty("File.basedir");
    if (strlen(base) + 13 > 512) return PUSH_FILE_ERROR;
    PushFile *f = malloc(sizeof(*f));
    if (!f) return PUSH_FILE_ERROR;
    int n = Jbni_convertAsciiToUcs2(base, -1, f->buffer.path, 1024);
    int length = n + Jbni_convertAsciiToUcs2("pushlist.txt", -1, f->buffer.path + n, 24);
    int mode = operation == 0 ? CPL_FILE_READ : operation == 1 ? CPL_FILE_WRITE : 0;
    if (!CPL_file_open(f->buffer.path, length, mode, 1, &f->fd, NULL)) {
        if (mode != CPL_FILE_WRITE || !CPL_file_truncate(f->fd, 0, NULL)) {
            f->position = f->size = 0;
            return f;
        }
        CPL_file_close(f->fd, NULL);
    }
    free(f);
    return PUSH_FILE_ERROR;
}

char *CPL_push_read(PushFile *f)
{
    char *buffer = f->buffer.line;
    for (;;) {
        char *line = buffer + f->position;
        int left = f->size - f->position;
        char *newline = memchr(line, '\n', (size_t)left);
        if (newline) {
            *newline = '\0';
            f->position = (int)(newline - buffer) + 1;
            return line;
        }
        /* The capacity test precedes compaction, even after earlier complete lines. */
        if (f->size == 1024) return NULL;
        memmove(buffer, line, (size_t)left);
        f->position = 0;
        f->size = left;
        int n = CPL_file_read(f->fd, buffer + left, (unsigned)(1024 - left), NULL);
        if (n <= 0) return NULL;
        f->size += n;
    }
}

int CPL_push_write(PushFile *f, const char *line)
{
    unsigned n = (unsigned)strlen(line);
    if (CPL_file_write(f->fd, line, n, NULL) != (int)n) return -1;
    return CPL_file_write(f->fd, "\n", 1, NULL) == 1 ? 0 : -1;
}

int CPL_push_close(PushFile *f)
{
    CPL_file_close(f->fd, NULL);
    free(f);
    return 0;
}
