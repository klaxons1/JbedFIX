#include "platform.h"
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

static void *global_data[16];
void swvExit(void) { exit(1); }
void *swvMemCpy(void *out, const void *in, size_t count) { return memcpy(out, in, count); }
void *swvMemSet(void *out, int byte, size_t count) { return memset(out, byte, count); }
void *swvAllocate(size_t size) { return malloc(size); }
void swvFree(void *pointer) { free(pointer); }
int swvGetVM_ID(void) { return 0; }
void *swvGetGlobalDataPointer(void) { return global_data[swvGetVM_ID()]; }
void swvSetGlobalDataPointer(void *data) { global_data[swvGetVM_ID()] = data; }

uint32_t swvAdler32(uint32_t sum, const uint8_t *data, unsigned count)
{
    return (uint32_t)adler32(sum, data, count);
}

struct SwvInflater {
    uint32_t type;
    void *loader;
    z_stream *stream;
    uint8_t output[1024];
};
extern int decompress_AcceptBytes(void *loader, int count, const uint8_t *bytes);

static voidpf z_alloc(voidpf opaque, uInt count, uInt size)
{
    (void)opaque;
    return calloc(count, size);
}
static void z_free(voidpf opaque, voidpf data)
{
    (void)opaque;
    free(data);
}
int swvDecompressOnDataStart(uint32_t type, void *loader, SwvInflater **out)
{
    *out = NULL;
    if (type != SWV_ZLIB) return 0;
    SwvInflater *state = swvAllocate(sizeof *state);
    if (!state) return 0;
    *out = state;
    state->type = type;
    state->loader = loader;
    memset(state->output, 0, sizeof state->output);
    state->stream = swvAllocate(sizeof *state->stream);
    if (!state->stream) return 0;
    *state->stream = (z_stream){ .zalloc = z_alloc, .zfree = z_free };
    return inflateInit_(state->stream, "1.2.3", sizeof(z_stream)) == Z_OK;
}

int swvDecompressOnData(const uint8_t *input, unsigned size, SwvInflater **handle)
{
    if (!handle || !*handle || (*handle)->type != SWV_ZLIB || !(*handle)->stream) return 0;
    SwvInflater *state = *handle;
    z_stream *stream = state->stream;
    stream->next_in = (Bytef *)input;
    stream->avail_in = size;
    for (;;) {
        stream->next_out = state->output;
        stream->avail_out = sizeof state->output;
        int rc = inflate(stream, Z_SYNC_FLUSH);
        unsigned produced = sizeof state->output - stream->avail_out;
        if (produced && !decompress_AcceptBytes(state->loader, produced, state->output)) return 0;
        if (rc == Z_OK && stream->avail_out == 0) continue;
        return rc == Z_OK || rc == Z_STREAM_END || (rc == Z_BUF_ERROR && !produced);
    }
}

int swvDecompressOnDataEnd(SwvInflater **handle)
{
    if (!handle || !*handle) return 0;
    SwvInflater *state = *handle;
    int ok = 0;
    if (state->type == SWV_ZLIB && state->stream) {
        ok = inflateEnd(state->stream) == Z_OK;
        swvFree(state->stream);
    }
    swvFree(state);
    *handle = NULL;
    return ok;
}
int swvDecompressError(SwvInflater **handle) { return swvDecompressOnDataEnd(handle); }

unsigned swvwcstombs(char *out, const uint16_t *source, unsigned limit)
{
    unsigned i = 0;
    for (; i < limit; ++i) if (!(out[i] = (char)source[i])) break;
    return i;
}
unsigned swvmbstowcs(uint16_t *out, const char *source, unsigned limit)
{
    unsigned i = 0;
    for (; i < limit; ++i) if (!(out[i] = (unsigned char)source[i])) break;
    return i;
}
unsigned swvStrLen(const uint16_t *s)
{
    unsigned n = 0;
    while (s[n]) ++n;
    return n;
}
uint16_t *swvStrCpy(uint16_t *out, const uint16_t *source)
{
    uint16_t *p = out;
    while ((*p++ = *source++)) {}
    return out;
}
uint16_t *swvStrCat(uint16_t *out, const uint16_t *source)
{
    return swvStrCpy(out + swvStrLen(out), source);
}

uint16_t *swvItoW(int value, uint16_t *out)
{
    uint16_t *p = out;
    int32_t magnitude = value;
    if (value < 0) {
        *p++ = '-';
        magnitude = (int32_t)(0u - (uint32_t)magnitude);
    }
    int32_t place = 1;
    for (;;) {
        int32_t next = (int32_t)((uint32_t)place * 10u);
        if (magnitude < next) break;
        if (!next) {
            /* The ARM loop never exits once its multiplier reaches zero. */
            place = 1000000000;
            break;
        }
        place = next;
    }
    do {
        *p++ = (uint16_t)('0' + (int64_t)magnitude / place);
        magnitude %= place;
        place /= 10;
    } while (place > 0);
    *p = 0;
    return out;
}

static int32_t double_to_int(double value)
{
    if (value != value) return 0;
    if (value >= 0x1p31) return INT32_MAX;
    if (value <= -0x1p31) return INT32_MIN;
    return (int32_t)value;
}

uint16_t *swvFtoW(double value, uint16_t *out, int digits)
{
    int32_t whole = double_to_int(value);
    swvItoW(whole, out);
    if (digits <= 0) return out;
    uint16_t *p = out + swvStrLen(out);
    *p++ = '.';
    int32_t place = 1;
    for (int i = 1; i < digits && place; ++i)
        place = (int32_t)((uint32_t)place * 10u);
    int32_t fraction = double_to_int((value - whole) * place * 10.);
    if (!place) {
        *p = 0;
        return out;
    }
    do {
        *p++ = (uint16_t)('0' + fraction / place);
        fraction %= place;
        place /= 10;
    } while (place);
    *p = 0;
    return out;
}
