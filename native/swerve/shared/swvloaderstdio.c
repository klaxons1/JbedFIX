#include "swvloader.h"
#include "platform.h"
#include <stdio.h>

int swvURIIsRelative_stdio(const uint16_t *name) { return !name || *name != 92; }
unsigned swvURIResolve_stdio(const uint16_t *base, const uint16_t *name, uint16_t *out)
{
    unsigned prefix = base ? swvStrLen(base) : 0;
    while (prefix && base[prefix - 1] != 92) --prefix;
    unsigned n = name ? swvStrLen(name) : 0;
    if (out) {
        if (prefix) swvMemCpy(out, base, prefix * sizeof *out);
        if (n) swvMemCpy(out + prefix, name, n * sizeof *out);
        out[prefix + n] = 0;
    }
    return prefix + n + 1;
}
int swvURIRead_stdio(void **stream, const uint16_t *name, unsigned limit, void *buffer, unsigned *actual)
{
    if (name) {
        char path[1024];
        unsigned n = swvStrLen(name);
        *stream = NULL;
        if (n >= sizeof path) return 0;
        for (unsigned i = 0; i < n; ++i) path[i] = (char)name[i];
        path[n] = 0;
        *stream = fopen(path, "rb");
        if (!*stream) return 0;
    }
    if (buffer) {
        if (!*stream) return 0;
        *actual = (unsigned)fread(buffer, 1, limit, *stream);
    } else if (*stream) {
        fclose(*stream);
    }
    return 1;
}
