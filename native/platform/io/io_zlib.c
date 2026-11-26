#include "io_zlib.h"
#include <stdlib.h>

extern int android_LOGD(const char *format, ...);

enum { INFLATE_WINDOW_BITS = 15, DEFLATE_WINDOW_BITS = 14, DEFLATE_MEMORY_LEVEL = 7 };

static voidpf stream_calloc(voidpf opaque, uInt count, uInt size)
{
    (void)opaque;
    return calloc(count, size);
}

static void stream_free(voidpf opaque, voidpf block)
{
    (void)opaque;
    free(block);
}

static void prepare(z_stream *stream)
{
    stream->zalloc = stream_calloc;
    stream->zfree = stream_free;
    stream->next_in = stream->next_out = Z_NULL;
    stream->avail_in = stream->avail_out = 0;
    stream->data_type = Z_BINARY;
}

int CPL_inflate_start(z_stream *stream, int wrapped)
{
    prepare(stream);
    int error = wrapped == 1 ? inflateInit_(stream, "1.2.3", sizeof(*stream))
                             : inflateInit2_(stream, -INFLATE_WINDOW_BITS, "1.2.3", sizeof(*stream));
    if (error != Z_OK)
        android_LOGD("ERROR: cpl_inflate.c: inflateInit failed (%d).\n\n", error);
    return error == Z_OK ? 0 : -1;
}

int CPL_deflate_start(z_stream *stream, int level)
{
    prepare(stream);
    int error = deflateInit2_(stream, level, Z_DEFLATED, -DEFLATE_WINDOW_BITS, DEFLATE_MEMORY_LEVEL, Z_DEFAULT_STRATEGY,
                              "1.2.3", sizeof(*stream));
    if (error != Z_OK)
        android_LOGD("ERROR: cpl_deflate.c: deflateInit2 failed (%d).\n\n", error);
    return error == Z_OK ? 0 : -1;
}

static void buffers(z_stream *stream, const uint8_t *input, unsigned input_size,
                    uint8_t *output, unsigned output_size)
{
    stream->next_in = (Bytef *)input;
    stream->avail_in = input_size;
    stream->next_out = output;
    stream->avail_out = output_size;
}

int CPL_inflate(z_stream *stream, const uint8_t *input, unsigned input_size,
                uint8_t *output, unsigned output_size, unsigned *consumed, unsigned *produced)
{
    buffers(stream, input, input_size, output, output_size);
    int status;
    do {
        status = inflate(stream, Z_NO_FLUSH);
    } while (status == Z_OK && stream->avail_in && stream->avail_out);
    int result = status == Z_STREAM_END ? 1 : 0;
    if (status != Z_OK && status != Z_BUF_ERROR && status != Z_STREAM_END) {
        android_LOGD("ERROR: cpl_inflate.c: inflate failed (%d).\n\n", status);
        result = -1;
    }
    *consumed = input_size - stream->avail_in;
    *produced = output_size - stream->avail_out;
    return result;
}

int CPL_deflate(z_stream *stream, const uint8_t *input, unsigned input_size,
                uint8_t *output, unsigned output_size, int flush, unsigned *consumed, unsigned *produced)
{
    buffers(stream, input, input_size, output, output_size);
    int status = deflate(stream, flush);
    int result = status == Z_STREAM_END ? 1 : 0;
    if (status != Z_OK && status != Z_STREAM_END) {
        android_LOGD("ERROR: cpl_deflate.c: deflate failed (%d).\n\n", status);
        result = -1;
    }
    *consumed = input_size - stream->avail_in;
    *produced = output_size - stream->avail_out;
    return result;
}

int CPL_inflate_end(z_stream *stream)
{
    int error = inflateEnd(stream);
    if (error != Z_OK)
        android_LOGD("ERROR: cpl_inflate.c: inflateEnd failed (%d).\n\n", error);
    return error == Z_OK ? 0 : -1;
}

int CPL_deflate_end(z_stream *stream)
{
    if (!stream || !stream->state) {
        android_LOGD("ERROR: cpl_deflate.c: CPL_deflate_end failed, strm or strm->state null\n\n");
        return -1;
    }
    int error = deflateEnd(stream);
    if (error != Z_OK)
        android_LOGD("ERROR: cpl_deflate.c: deflateEnd failed (%d).\n\n", error);
    return error == Z_OK ? 0 : -1;
}
