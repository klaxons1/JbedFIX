#include "image.h"
#include "vm_helpers.h"
#include "io_zlib.h"

#include <stdlib.h>
#include <string.h>

extern uint32_t Jbed_noAllocation;
extern void Jbni_intern_raiseCommonException(int);
extern int android_LOGD(const char *, ...);

enum {
    PNG_PALETTE_FLAG = 1, PNG_RGB_FLAG = 2, PNG_ALPHA_FLAG = 4,
    PNG_GRAY = 0, PNG_RGB = 2, PNG_INDEXED = 3, PNG_GRAY_ALPHA = 4, PNG_RGBA = 6,
    PNG_FILTER_SUB = 1, PNG_FILTER_UP = 2, PNG_FILTER_AVERAGE = 3, PNG_FILTER_PAETH = 4,
    PNG_ADAM7_PASSES = 7, PNG_PALETTE_ENTRIES = 256, PNG_IHDR_BYTES = 13,
    PNG_CHUNK_HEADER_BYTES = 8, PNG_CHUNK_OVERHEAD_BYTES = 12
};

typedef struct {
    int32_t width, height, reserved;
    uint32_t full_row;
    uint16_t filter_stride;
    bool indexed_alpha;
    uint8_t last_alpha;
    uint32_t *palette;
    uint16_t colors;
    uint8_t pass, depth, type, compression, filter, interlace;
    uint16_t row_stride[PNG_ADAM7_PASSES];
    uint32_t pass_size[PNG_ADAM7_PASSES];
} Png;

#if UINTPTR_MAX == UINT32_MAX
_Static_assert(offsetof(Png, depth) == 27 && offsetof(Png, row_stride) == 32 &&
               offsetof(Png, pass_size) == 48 && sizeof(Png) == 76, "PNG decoder state");
#endif

static const uint8_t png_signature[] = {137, 80, 78, 71, 13, 10, 26, 10};
static const uint8_t x_step[] = {8, 8, 4, 4, 2, 2, 1};
static const uint8_t x_first[] = {0, 4, 0, 2, 0, 1, 0};

static uint32_t big32(const uint8_t *p)
{
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3];
}

static bool is_rgb(const Png *p)
{
    return (p->type & (PNG_PALETTE_FLAG | PNG_RGB_FLAG)) == PNG_RGB_FLAG;
}

static unsigned channels(const Png *p)
{
    return (is_rgb(p) ? 3u : 1u) + ((p->type & (unsigned)PNG_ALPHA_FLAG) >> 2);
}

static uint32_t row_size(const Png *p, uint32_t pixels)
{
    return 1u + ((int32_t)(p->depth * pixels * channels(p) + 7u) >> 3);
}

/* 0x2c18d0 */
static void png_parse_ihdr(const uint8_t *h, Png *p)
{
    ++Jbed_noAllocation;
    p->width = (int32_t)big32(h);
    p->height = (int32_t)big32(h + 4);
    p->depth = h[8];
    p->type = h[9];
    p->compression = h[10];
    p->filter = h[11];
    p->interlace = h[12];
    p->pass = p->interlace ? 0 : PNG_ADAM7_PASSES;
    switch (p->type) {
    case PNG_GRAY: case PNG_INDEXED: p->filter_stride = (p->depth + 7) >> 3; break;
    case PNG_RGB: p->filter_stride = 3 * p->depth >> 3; break;
    case PNG_GRAY_ALPHA: p->filter_stride = p->depth >> 2; break;
    case PNG_RGBA: p->filter_stride = p->depth >> 1; break;
    }
    p->full_row = p->width > 0 ? row_size(p, (uint32_t)p->width) : 0;
    --Jbed_noAllocation;
}

static bool valid_header(const Png *p)
{
    if (p->width <= 0 || p->height <= 0 || p->compression || p->filter ||
        p->interlace > 1 || p->depth > 16 || ((p->depth - 1) & p->depth))
        return false;
    switch (p->type) {
    case PNG_GRAY: return true;
    case PNG_INDEXED: return p->depth <= 8;
    case PNG_RGB: case PNG_GRAY_ALPHA: case PNG_RGBA: return p->depth >= 8;
    default: return false;
    }
}

static uint32_t layout(Png *p)
{
    if (!p->interlace) {
        p->row_stride[6] = (uint16_t)p->full_row;
        p->pass_size[6] = p->full_row * (uint32_t)p->height;
        return p->pass_size[6];
    }
    uint32_t total = 0;
    for (unsigned i = 0; i < PNG_ADAM7_PASSES; ++i) {
        unsigned w = ((uint32_t)p->width + x_step[i] - 1 - x_first[i]) / x_step[i];
        unsigned row_shift = 3 - ((int)i - 1) / 2;
        unsigned h = ((uint32_t)p->height + (7u >> (i / 2))) >> row_shift;
        uint32_t stride = w ? row_size(p, w) : 0;
        p->row_stride[i] = (uint16_t)stride;
        p->pass_size[i] = stride * h;
        total += p->pass_size[i];
    }
    return total;
}

static uint8_t paeth(int a, int b, int c)
{
    int pa = abs(b - c), pb = abs(a - c), pc = abs(a + b - 2 * c);
    if (pa <= pb && pa <= pc) return (uint8_t)a;
    return pb <= pc ? (uint8_t)b : (uint8_t)c;
}

/* 0x2c057c */
static void png_unfilter_row(int filter, uint8_t *row, int count,
                             const uint8_t *above, int stride)
{
    switch (filter) {
    case PNG_FILTER_SUB:
        for (int i = stride; i < count; ++i)
            row[i] += row[i - stride];
        break;
    case PNG_FILTER_UP:
        if (above)
            for (int i = 0; i < count; ++i)
                row[i] += above[i];
        break;
    case PNG_FILTER_AVERAGE:
        if (above) {
            for (int i = 0; i < stride && i < count; ++i)
                row[i] += above[i] >> 1;
            for (int i = stride; i < count; ++i)
                row[i] += (row[i - stride] + above[i]) >> 1;
        } else {
            for (int i = stride; i < count; ++i)
                row[i] += row[i - stride] >> 1;
        }
        break;
    case PNG_FILTER_PAETH:
        if (above) {
            for (int i = 0; i < stride && i < count; ++i)
                row[i] += above[i];
            for (int i = stride; i < count; ++i)
                row[i] += paeth(row[i - stride], above[i], above[i - stride]);
        } else {
            for (int i = stride; i < count; ++i)
                row[i] += row[i - stride];
        }
        break;
    }
}

typedef struct {
    const uint8_t *byte;
    uint8_t shift, mask;
} PackedSamples;

static inline PackedSamples packed_samples(const uint8_t *src, unsigned depth)
{
    unsigned shift = 8 - depth;
    return (PackedSamples){src, shift, (uint8_t)~(255u >> shift)};
}

static inline void put_packed(uint8_t **out, PackedSamples *src, unsigned depth)
{
    *(*out)++ = (*src->byte & src->mask) >> src->shift;
    if (src->shift) {
        src->mask >>= depth;
        src->shift -= depth;
    } else {
        *src = packed_samples(src->byte + 1, depth);
    }
}

static inline void put_gray(uint8_t **out, uint8_t **alpha, const uint8_t **src,
                            unsigned bytes, bool has_alpha)
{
    *(*out)++ = (*src)[0];
    if (has_alpha)
        *(*alpha)++ = (*src)[bytes];
    *src += bytes << has_alpha;
}

static inline void put_rgb(uint8_t **out, uint8_t **alpha, const uint8_t **src,
                           unsigned bytes, unsigned step)
{
    uint8_t *rgb = *out;
    rgb[0] = (*src)[0];
    rgb[1] = (*src)[bytes];
    rgb[2] = (*src)[2 * bytes];
    if (*alpha)
        *(*alpha)++ = (*src)[3 * bytes];
    *out += 3;
    *src += step;
}

/* 0x2c06d4 */
static void png_merge_adam7_two(uint8_t *out, uint8_t *alpha,
                                const uint8_t *even, const uint8_t *odd,
                                const Png *p)
{
    ++Jbed_noAllocation;
    if (p->depth < 8) {
        PackedSamples even_bits = packed_samples(even, p->depth);
        PackedSamples odd_bits = packed_samples(odd, p->depth);
        for (int x = 0; x < p->width; x += 2) {
            put_packed(&out, &even_bits, p->depth);
            if (x + 1 < p->width) put_packed(&out, &odd_bits, p->depth);
        }
    } else if (is_rgb(p)) {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        unsigned step = (p->type & PNG_ALPHA_FLAG ? 4 : 3) * bytes;
        for (int x = 0; x < p->width; x += 2) {
            put_rgb(&out, &alpha, &even, bytes, step);
            if (x + 1 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
        }
    } else {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        bool has_alpha = (p->type & PNG_ALPHA_FLAG) != 0;
        for (int x = 0; x < p->width; x += 2) {
            put_gray(&out, &alpha, &even, bytes, has_alpha);
            if (x + 1 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
        }
    }
    --Jbed_noAllocation;
}

/* 0x2c092c */
static void png_merge_adam7_four(uint8_t *out, uint8_t *alpha,
                                 const uint8_t *quarter0, const uint8_t *odd,
                                 const uint8_t *quarter2, const Png *p)
{
    ++Jbed_noAllocation;
    if (p->depth < 8) {
        PackedSamples quarter0_bits = packed_samples(quarter0, p->depth);
        PackedSamples odd_bits = packed_samples(odd, p->depth);
        PackedSamples quarter2_bits = packed_samples(quarter2, p->depth);
        for (int x = 0; x < p->width; x += 4) {
            put_packed(&out, &quarter0_bits, p->depth);
            if (x + 1 < p->width) put_packed(&out, &odd_bits, p->depth);
            if (x + 2 < p->width) put_packed(&out, &quarter2_bits, p->depth);
            if (x + 3 < p->width) put_packed(&out, &odd_bits, p->depth);
        }
    } else if (is_rgb(p)) {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        unsigned step = (p->type & PNG_ALPHA_FLAG ? 4 : 3) * bytes;
        for (int x = 0; x < p->width; x += 4) {
            put_rgb(&out, &alpha, &quarter0, bytes, step);
            if (x + 1 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
            if (x + 2 < p->width) put_rgb(&out, &alpha, &quarter2, bytes, step);
            if (x + 3 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
        }
    } else {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        bool has_alpha = (p->type & PNG_ALPHA_FLAG) != 0;
        for (int x = 0; x < p->width; x += 4) {
            put_gray(&out, &alpha, &quarter0, bytes, has_alpha);
            if (x + 1 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
            if (x + 2 < p->width) put_gray(&out, &alpha, &quarter2, bytes, has_alpha);
            if (x + 3 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
        }
    }
    --Jbed_noAllocation;
}

/* 0x2c0cb8 */
static void png_merge_adam7_eight(uint8_t *out, uint8_t *alpha,
                                  const uint8_t *eighth0, const uint8_t *odd,
                                  const uint8_t *quarter2, const uint8_t *eighth4,
                                  const Png *p)
{
    ++Jbed_noAllocation;
    if (p->depth < 8) {
        PackedSamples eighth0_bits = packed_samples(eighth0, p->depth);
        PackedSamples odd_bits = packed_samples(odd, p->depth);
        PackedSamples quarter2_bits = packed_samples(quarter2, p->depth);
        PackedSamples eighth4_bits = packed_samples(eighth4, p->depth);
        for (int x = 0; x < p->width; x += 8) {
            put_packed(&out, &eighth0_bits, p->depth);
            if (x + 1 < p->width) put_packed(&out, &odd_bits, p->depth);
            if (x + 2 < p->width) put_packed(&out, &quarter2_bits, p->depth);
            if (x + 3 < p->width) put_packed(&out, &odd_bits, p->depth);
            if (x + 4 < p->width) put_packed(&out, &eighth4_bits, p->depth);
            if (x + 5 < p->width) put_packed(&out, &odd_bits, p->depth);
            if (x + 6 < p->width) put_packed(&out, &quarter2_bits, p->depth);
            if (x + 7 < p->width) put_packed(&out, &odd_bits, p->depth);
        }
    } else if (is_rgb(p)) {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        unsigned step = (p->type & PNG_ALPHA_FLAG ? 4 : 3) * bytes;
        for (int x = 0; x < p->width; x += 8) {
            put_rgb(&out, &alpha, &eighth0, bytes, step);
            if (x + 1 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
            if (x + 2 < p->width) put_rgb(&out, &alpha, &quarter2, bytes, step);
            if (x + 3 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
            if (x + 4 < p->width) put_rgb(&out, &alpha, &eighth4, bytes, step);
            if (x + 5 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
            if (x + 6 < p->width) put_rgb(&out, &alpha, &quarter2, bytes, step);
            if (x + 7 < p->width) put_rgb(&out, &alpha, &odd, bytes, step);
        }
    } else {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        bool has_alpha = (p->type & PNG_ALPHA_FLAG) != 0;
        for (int x = 0; x < p->width; x += 8) {
            put_gray(&out, &alpha, &eighth0, bytes, has_alpha);
            if (x + 1 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
            if (x + 2 < p->width) put_gray(&out, &alpha, &quarter2, bytes, has_alpha);
            if (x + 3 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
            if (x + 4 < p->width) put_gray(&out, &alpha, &eighth4, bytes, has_alpha);
            if (x + 5 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
            if (x + 6 < p->width) put_gray(&out, &alpha, &quarter2, bytes, has_alpha);
            if (x + 7 < p->width) put_gray(&out, &alpha, &odd, bytes, has_alpha);
        }
    }
    --Jbed_noAllocation;
}

static inline void unpack_scanline(uint8_t *out, uint8_t *alpha,
                                   const uint8_t *src, const Png *p)
{
    ++Jbed_noAllocation;
    if (p->depth < 8) {
        PackedSamples src_bits = packed_samples(src, p->depth);
        for (int x = 0; x < p->width; ++x) {
            put_packed(&out, &src_bits, p->depth);
        }
    } else if (is_rgb(p)) {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        unsigned step = (p->type & PNG_ALPHA_FLAG ? 4 : 3) * bytes;
        for (int x = 0; x < p->width; ++x) {
            put_rgb(&out, &alpha, &src, bytes, step);
        }
    } else {
        unsigned bytes = p->depth > 8 ? 2 : 1;
        bool has_alpha = (p->type & PNG_ALPHA_FLAG) != 0;
        for (int x = 0; x < p->width; ++x) {
            put_gray(&out, &alpha, &src, bytes, has_alpha);
        }
    }
    --Jbed_noAllocation;
}

/* 0x2c12cc */
static bool png_render_scanlines(uint8_t *raw, uint32_t size, DstImage *dst, const Png *p)
{
    (void)size;
    bool rgb = is_rgb(p);
    bool has_alpha = (p->type & PNG_ALPHA_FLAG) || p->indexed_alpha;
    uint8_t *pass[PNG_ADAM7_PASSES];

    ++Jbed_noAllocation;
    if (p->interlace) {
        uint8_t *begin = raw;
        for (int i = 0; i < PNG_ADAM7_PASSES; ++i) {
            uint8_t *end = begin + p->pass_size[i];
            int stride = p->row_stride[i];
            const uint8_t *above = NULL;
            for (uint8_t *row = begin; stride && row < end; row += stride) {
                png_unfilter_row(row[0], row + 1, stride - 1, above, p->filter_stride);
                above = row + 1;
            }
            begin = end;
        }
    } else {
        int stride = p->row_stride[6];
        uint8_t *row = raw;
        const uint8_t *above = NULL;
        for (int y = 0; y < p->height; ++y, row += stride) {
            png_unfilter_row(row[0], row + 1, stride - 1, above, p->filter_stride);
            above = row + 1;
        }
    }
    --Jbed_noAllocation;

    bool direct = p->depth == 8 && p->type <= PNG_INDEXED && !p->indexed_alpha;
    bool packed = !direct && p->type == PNG_GRAY && p->depth == dst->packed_depth;
    uint8_t *colors = NULL, *alpha = NULL;
    if (p->interlace || !(direct || packed)) {
        colors = malloc((uint32_t)p->width * (rgb ? 3u : 1u));
        if (!colors) return false;
        if (has_alpha) {
            alpha = malloc((uint32_t)p->width);
            if (!alpha) { free(colors); return false; }
        }
    }
    if (p->interlace) {
        pass[0] = raw;
        for (int i = 0; i < 6; ++i)
            pass[i + 1] = pass[i] + p->pass_size[i];
    } else {
        pass[6] = raw;
    }

    ++Jbed_noAllocation;
    for (int y = 0; y < p->height; ++y) {
        if (p->interlace && !(y & 1)) {
            switch (y & 6) {
            case 0:
                png_merge_adam7_eight(colors, alpha, pass[0] + 1, pass[5] + 1,
                                      pass[3] + 1, pass[1] + 1, p);
                pass[0] += p->row_stride[0];
                pass[5] += p->row_stride[5];
                pass[3] += p->row_stride[3];
                pass[1] += p->row_stride[1];
                break;
            case 4:
                png_merge_adam7_four(colors, alpha, pass[2] + 1, pass[5] + 1,
                                     pass[3] + 1, p);
                pass[2] += p->row_stride[2];
                pass[5] += p->row_stride[5];
                pass[3] += p->row_stride[3];
                break;
            case 2: case 6:
                png_merge_adam7_two(colors, alpha, pass[4] + 1, pass[5] + 1, p);
                pass[4] += p->row_stride[4];
                pass[5] += p->row_stride[5];
                break;
            }
        } else {
            const uint8_t *row = pass[6] + 1;
            pass[6] += p->row_stride[6];
            if (direct) {
                dst->row(dst, y, row, NULL, rgb);
                continue;
            }
            if (packed) {
                dst->packed_row(dst, y, row);
                continue;
            }
            unpack_scanline(colors, alpha, row, p);
        }
        if (p->indexed_alpha) {
            for (int x = 0; x < p->width; ++x) {
                unsigned index = colors[x];
                alpha[x] = index > p->last_alpha ? 255 : (uint8_t)(~p->palette[index] >> 24);
            }
        }
        dst->row(dst, y, colors, alpha, rgb);
    }
    if (colors) {
        free(colors);
        if (alpha) free(alpha);
    }
    --Jbed_noAllocation;
    return true;
}

static inline bool collides(const Png *p, unsigned index, uint32_t rgb)
{
    unsigned pixel = LCDUIgetPixel(rgb, 0, 0);
    for (unsigned i = 0; i < p->colors; ++i) {
        uint32_t other = p->palette[i];
        if (i != index && !(other >> 24) && LCDUIgetPixel(other, 0, 0) == pixel)
            return true;
    }
    return false;
}

/* 0x2c19ac. Search individual B,G,R channels first, then all three
 * together. An out-of-range channel contributes zero in the second search. */
static void png_find_unused_color_key(unsigned index, Png *p)
{
    for (unsigned i = 8; i < 2048; ++i) {
        if ((i & 3) == 3) continue;
        unsigned shift = 8 * (i & 3);
        uint32_t old = p->palette[index];
        int value = (old >> shift) & 255;
        int offset = (int)(i >> 3);
        value += (i & 4) ? -offset : offset;
        if ((unsigned)value > 255) continue;

        uint32_t candidate = (old & ~(255u << shift)) | ((uint32_t)value << shift);
        if (!collides(p, index, candidate)) {
            p->palette[index] = candidate;
            return;
        }
    }

    uint32_t candidate = p->palette[index] & 0xff000000;
    for (unsigned i = 8; i < 2048; ++i) {
        if ((i & 3) == 3) {
            if (!collides(p, index, candidate)) {
                p->palette[index] = candidate;
                return;
            }
            candidate = p->palette[index] & 0xff000000;
        } else {
            unsigned shift = 8 * (i & 3);
            int value = (p->palette[index] >> shift) & 255;
            int offset = (int)(i >> 3);
            value += (i & 4) ? -offset : offset;
            if ((unsigned)value <= 255)
                candidate += (uint32_t)value << shift;
        }
    }
    android_LOGD("ALWAYS We still haven't found the correct alternate value\n");
}

static void gray_palette(Png *p, uint32_t *palette, DstImage *dst)
{
    p->palette = palette;
    p->colors = p->depth == 1 || p->depth == 2 || p->depth == 4 ? 1u << p->depth : 256;
    unsigned increment = 255 / (p->colors - 1);
    for (unsigned i = 0; i < p->colors; ++i)
        p->palette[i] = i * increment * 0x010101u;
    dst->palette(dst, p->palette, p->colors);
}

/* 0x2c1ba0. Palette opacity is stored inverted in the high byte.
 * Fully transparent entries use an RGB565 color key until fractional alpha
 * requires a separate pixel plane. Some files contain both. */
static void png_apply_transparency(const uint8_t **cursor, DstImage *dst, unsigned length, Png *p)
{
    const uint8_t *in = *cursor;
    if (p->type & PNG_PALETTE_FLAG) {
        bool clear = false, partial = false;
        for (unsigned i = 0; i < length; ++i) {
            unsigned inverse = 255 - in[i];
            p->palette[i] |= (uint32_t)inverse << 24;
            if (inverse == 255) clear = true;
            else if (inverse) partial = true;
        }
        if (partial) {
            p->indexed_alpha = true;
            p->last_alpha = (uint8_t)(length - 1);
        } else if (clear) {
            bool changed = false;
            for (unsigned i = 0; i < length; ++i) {
                uint32_t old = p->palette[i];
                if ((old >> 24) != 255 || !collides(p, i, old & 0xffffff)) continue;
                png_find_unused_color_key(i, p);
                for (unsigned j = i + 1; j < length; ++j)
                    if (p->palette[j] == old) p->palette[j] = p->palette[i];
                changed = true;
            }
            if (changed) dst->palette(dst, p->palette, p->colors);
            for (unsigned i = 0; i < length; ++i)
                if ((p->palette[i] >> 24) == 255)
                    dst->transparent(dst, p->palette[i] & 0xffffff, (int)i);
        }
        *cursor += length;
    } else if (p->type == 2) {
        unsigned byte = p->depth > 8 ? 0 : 1;
        uint32_t rgb = (unsigned)in[byte] << 16 | (unsigned)in[2 + byte] << 8 | in[4 + byte];
        dst->transparent(dst, rgb, -1);
        *cursor += 6;
    } else if (!p->type) {
        unsigned i = (unsigned)in[0] << 8 | in[1];
        *cursor += 2;
        if (i >= (1u << p->depth)) return;
        if (p->depth > 8) i >>= 8;
        uint32_t old = p->palette[i];
        unsigned pixel = LCDUIgetPixel(old, 0, 0);
        if ((i && pixel == LCDUIgetPixel(p->palette[i - 1], 0, 0)) ||
            (i + 1 < p->colors && pixel == LCDUIgetPixel(p->palette[i + 1], 0, 0))) {
            for (unsigned bit = 1; bit <= 128; bit <<= 1) {
                if (pixel != LCDUIgetPixel(old ^ bit, 0, 0)) {
                    p->palette[i] = old ^ bit;
                    dst->palette(dst, p->palette, p->colors);
                    break;
                }
            }
        }
        dst->transparent(dst, p->palette[i], (int)i);
    }
}

enum { IHDR = 0x49484452, PLTE = 0x504c5445, IDAT = 0x49444154,
       TRNS = 0x74524e53, IEND = 0x49454e44 };

typedef struct {
    uint32_t tag, length;
} Chunk;

static bool next_chunk(const uint8_t **cursor, int32_t *remaining, Chunk *chunk)
{
    if (*remaining < PNG_CHUNK_HEADER_BYTES) return false;
    const uint8_t *head = *cursor;
    chunk->length = big32(head);
    chunk->tag = big32(head + 4);
    *cursor = head + PNG_CHUNK_HEADER_BYTES;
    if (*remaining < PNG_CHUNK_OVERHEAD_BYTES ||
        chunk->length > (uint32_t)(*remaining - PNG_CHUNK_OVERHEAD_BYTES)) return false;
    *remaining -= (int32_t)chunk->length + PNG_CHUNK_OVERHEAD_BYTES;
    return Jbed_crc32(0, head + 4, (int)chunk->length + 4) == big32(*cursor + chunk->length);
}

static bool read_data(Png *p, const uint8_t **cursor, int32_t *remaining,
                      Chunk chunk, DstImage *dst,
                      bool *result)
{
    uint32_t size = layout(p);
    if ((p->type & PNG_PALETTE_FLAG) && !p->palette) return false;
    JbArray *array = Jbni_newByteArray((int32_t)size);
    ++Jbed_noAllocation;
    if (!array) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY); return false; }
    uint8_t *raw = (uint8_t *)array->data;
    z_stream stream = {0};
    if (CPL_inflate_start(&stream, 1)) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY); return false; }
    unsigned left = size;
    for (;;) {
        unsigned consumed, produced;
        int status = CPL_inflate(&stream, *cursor, chunk.length, raw + size - left, left,
                                 &consumed, &produced);
        left -= produced;
        *cursor += chunk.length;
        if (status == 1) {
            CPL_inflate_end(&stream);
            *result = png_render_scanlines(raw, size, dst, p);
            --Jbed_noAllocation;
            return true;
        }
        *cursor += 4;
        if (status < 0 || !next_chunk(cursor, remaining, &chunk) || chunk.tag != IDAT) break;
    }
    CPL_inflate_end(&stream);
    /* This exit in the original leaves the allocation counter incremented. */
    return false;
}

/* PNGdecodeImage, 0x2c1eb0, including its outlined pass loop at 0x2c289a. */
int PNGdecodeImage(const uint8_t **cursor, int32_t size, DstImage *dst)
{
    void **mark = Jbed_nativeCallStateAdr;
    JbArray *palette = Jbni_newIntArray(PNG_PALETTE_ENTRIES);
    *Jbed_nativeCallStateAdr++ = &palette;
    if (!palette) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY); return false; }
    const uint8_t *signature = *cursor;
    *cursor += 8;
    if (size <= 8 || memcmp(signature, png_signature, 8)) return false;
    int32_t remaining = size - 8;
    Png p = {0};
    bool data_seen = false, trns_seen = false, result = true;
    Chunk chunk;
    while (next_chunk(cursor, &remaining, &chunk)) {
        switch (chunk.tag) {
        case 0: return false;
        case IEND:
            *cursor += 4;
            dst->finish(dst);
            Jbed_nativeCallStateAdr = mark;
            return result;
        case IHDR:
            if (chunk.length < PNG_IHDR_BYTES || valid_header(&p)) return false;
            png_parse_ihdr(*cursor, &p);
            *cursor += chunk.length;
            if (!valid_header(&p)) return false;
            jbed_image_plane(dst, dst->storage_size(dst, p.width, p.height), false);
            if (p.type & PNG_ALPHA_FLAG) jbed_image_plane(dst, (uint32_t)p.width * p.height, true);
            dst->dimensions(dst, p.width, p.height);
            ++Jbed_noAllocation;
            if (!(p.type & PNG_RGB_FLAG)) gray_palette(&p, palette->data, dst);
            --Jbed_noAllocation;
            break;
        case PLTE:
            ++Jbed_noAllocation;
            if (chunk.length > 3 * PNG_PALETTE_ENTRIES || chunk.length % 3 || data_seen || p.colors || trns_seen)
                return false;
            p.palette = palette->data;
            p.colors = (uint16_t)(chunk.length / 3);
            for (unsigned i = 0; i < p.colors; ++i) {
                const uint8_t *entry = *cursor + i * 3;
                p.palette[i] = (unsigned)entry[0] << 16 | (unsigned)entry[1] << 8 | entry[2];
            }
            *cursor += chunk.length;
            if (p.type & PNG_PALETTE_FLAG) dst->palette(dst, p.palette, p.colors);
            --Jbed_noAllocation;
            break;
        case TRNS:
            if (data_seen || (p.type & PNG_ALPHA_FLAG)) return false;
            if ((p.type == PNG_INDEXED && (!p.palette || chunk.length > PNG_PALETTE_ENTRIES)) ||
                (p.type == PNG_GRAY && !p.palette) ||
                (p.type == PNG_RGB && chunk.length < 2)) return false;
            png_apply_transparency(cursor, dst, chunk.length, &p);
            if (p.indexed_alpha) jbed_image_plane(dst, (uint32_t)p.width * p.height, true);
            trns_seen = true;
            break;
        case IDAT:
            if (!read_data(&p, cursor, &remaining, chunk, dst, &result)) return false;
            data_seen = true;
            break;
        default:
            *cursor += chunk.length;
            break;
        }
        *cursor += 4;
    }
    return false;
}
