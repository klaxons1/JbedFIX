#ifndef JBED_IO_ZLIB_H
#define JBED_IO_ZLIB_H

#include <stdint.h>
#include <zlib.h>

int CPL_inflate_start(z_stream *stream, int wrapped);
int CPL_inflate(z_stream *stream, const uint8_t *input, unsigned input_size,
                uint8_t *output, unsigned output_size, unsigned *consumed, unsigned *produced);
int CPL_inflate_end(z_stream *stream);
int CPL_deflate_start(z_stream *stream, int level);
int CPL_deflate(z_stream *stream, const uint8_t *input, unsigned input_size,
                uint8_t *output, unsigned output_size, int flush, unsigned *consumed, unsigned *produced);
int CPL_deflate_end(z_stream *stream);

#endif
