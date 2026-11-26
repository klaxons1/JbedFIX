#include "io_zlib.h"
#include "jbni_objects.h"
#include "vm_helpers.h"

#include <stddef.h>
#include <stdlib.h>

extern void Jbni_intern_raiseCommonException(int);
extern uint32_t Jbed_noAllocation;

typedef struct {
    uint32_t header[3];
    int32_t markPos;
    JbRef tmpBuf, fBuffer;
    int32_t fReadPos, fLimitPos, fFilledPos;
    uint8_t fOutOfReadLimit;
    JbRef inBuf;
    int32_t inPos, inCount;
    JbRef outBuf;
    int32_t outPos, outCount;
    uint8_t eof;
    JbRef in;
    uint32_t inflateStream;
    unsigned nativeRead, nativeWritten;
} Inflater;

typedef struct {
    uint32_t header[3];
    JbRef tmpBuf;
    int32_t outPos, outLen;
    JbRef outBuf, out;
    uint32_t deflateStream;
    unsigned nativeRead, nativeWritten;
} Deflater;

_Static_assert(offsetof(Inflater, inflateStream) == 72 && offsetof(Deflater, deflateStream) == 32,
               "Jbed compression stream layout");

#define INFLATER(name) JbniV_com_jbed_io_InflaterInputStream_##name
#define INFLATER_STATIC(name) JbniS_com_jbed_io_InflaterInputStream_##name
#define DEFLATER(name) JbniV_com_jbed_io_DeflaterOutputStream_##name
#define DEFLATER_STATIC(name) JbniS_com_jbed_io_DeflaterOutputStream_##name

z_stream *INFLATER_STATIC(createInflater)(void)
{
    z_stream *stream = malloc(sizeof(*stream));
    if (stream) {
        stream->opaque = NULL;
        if (CPL_inflate_start(stream, 0)) {
            free(stream);
            return NULL;
        }
    }
    return stream;
}

z_stream *DEFLATER_STATIC(createDeflater)(void)
{
    z_stream *stream = malloc(sizeof(*stream));
    if (stream) {
        stream->opaque = NULL;
        if (CPL_deflate_start(stream, 3)) {
            free(stream);
            return NULL;
        }
    }
    return stream;
}

void INFLATER_STATIC(destroyInflater)(z_stream *stream)
{
    CPL_inflate_end(stream);
    free(stream);
}

void DEFLATER_STATIC(destroyDeflater)(z_stream *stream)
{
    CPL_deflate_end(stream);
    free(stream);
}

void INFLATER(finalize)(Inflater *self)
{
    if (self->inflateStream) INFLATER_STATIC(destroyInflater)((z_stream *)(uintptr_t)self->inflateStream);
}

void DEFLATER(finalize)(Deflater *self)
{
    if (self->deflateStream) DEFLATER_STATIC(destroyDeflater)((z_stream *)(uintptr_t)self->deflateStream);
}

int INFLATER(inflate)(Inflater *self, z_stream *stream,
                      const JbArray *source, int start, unsigned length,
                      JbArray *dest, int offset, unsigned capacity)
{
    return CPL_inflate(stream, (const uint8_t *)source->data + start, length,
                       (uint8_t *)dest->data + offset, capacity,
                       &self->nativeRead, &self->nativeWritten);
}

int DEFLATER(deflate)(Deflater *self, z_stream *stream,
                      const JbArray *source, int start, unsigned length,
                      JbArray *dest, int offset, unsigned capacity, int flush)
{
    return CPL_deflate(stream, (const uint8_t *)source->data + start, length,
                       (uint8_t *)dest->data + offset, capacity, flush,
                       &self->nativeRead, &self->nativeWritten);
}

uint32_t INFLATER_STATIC(crc32)(const JbArray *array, int offset, int length)
{
    uint32_t left = (uint32_t)array->length - (uint32_t)offset;
    if ((int32_t)((uint32_t)offset | (uint32_t)length | left | (left - (uint32_t)length)) < 0)
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_INDEX_BOUNDS);
    ++Jbed_noAllocation;
    uint32_t crc = Jbed_crc32(0, (const uint8_t *)array->data + offset, length);
    --Jbed_noAllocation;
    return crc;
}
