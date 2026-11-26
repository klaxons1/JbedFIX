#include "image.h"

#include <stdlib.h>
#include <string.h>

enum {
    GIF_COLOR_TABLE_PRESENT = 0x80, GIF_INTERLACED = 0x40,
    GIF_COLOR_TABLE_SIZE_MASK = 7, GIF_TRANSPARENCY_PRESENT = 1,
    GIF_IMAGE_SEPARATOR = 0x2c, GIF_TRAILER = 0x3b, GIF_EXTENSION = 0x21,
    GIF_GRAPHIC_CONTROL = 0xf9, GIF_PLAIN_TEXT = 1, GIF_COMMENT = 0xfe,
    GIF_APPLICATION = 0xff, GIF_APPLICATION_ID_BYTES = 11,
    GIF_LZW_MAX_BITS = 12, GIF_LZW_CODES = 1 << GIF_LZW_MAX_BITS
};

typedef struct {
    const uint8_t **cursor;
    size_t left;
} Reader;

static const uint8_t *take(Reader *r, size_t n)
{
    if (n > r->left)
        return NULL;
    const uint8_t *p = *r->cursor;
    *r->cursor += n;
    r->left -= n;
    return p;
}

static unsigned byte(Reader *r)
{
    const uint8_t *p = take(r, 1);
    return p ? *p : 0;
}

static unsigned little16(const uint8_t *p)
{
    return p[0] | (unsigned)p[1] << 8;
}

typedef struct {
    uint32_t *rgb;
    unsigned count;
} Palette;

static bool read_palette(Reader *r, Palette *palette, unsigned flags)
{
    palette->count = 2u << (flags & GIF_COLOR_TABLE_SIZE_MASK);
    palette->rgb = malloc(palette->count * sizeof(*palette->rgb));
    const uint8_t *p;
    if (!palette->rgb || !(p = take(r, 3 * palette->count)))
        return false;
    for (unsigned i = 0; i < palette->count; ++i, p += 3)
        palette->rgb[i] = ((uint32_t)p[0] << 16) | ((uint32_t)p[1] << 8) | p[2];
    return true;
}

/* Jbed reads the length of the following subblock together with its payload. */
typedef struct {
    Reader *r;
    unsigned available, next_size;
    uint32_t bits;
    unsigned bit_count;
} Blocks;

static bool load_block(Blocks *b)
{
    unsigned n = b->next_size;
    if (!n)
        return false;
    const uint8_t *p = take(b->r, n + 1);
    if (!p)
        return false;
    b->available = n;
    b->next_size = p[n];
    return true;
}

static bool read_code(Blocks *b, unsigned width, unsigned *code)
{
    while (b->bit_count < width) {
        if (!b->available && !load_block(b))
            return false;
        const uint8_t *next_byte = *b->r->cursor - 1 - b->available;
        b->bits |= (uint32_t)*next_byte << b->bit_count;
        --b->available;
        b->bit_count += 8;
    }
    *code = b->bits & ((1u << width) - 1);
    b->bits >>= width;
    b->bit_count -= width;
    return true;
}

static uint16_t prefix[GIF_LZW_CODES];
static uint8_t suffix[GIF_LZW_CODES];
static uint8_t expansion[GIF_LZW_CODES + 1];

static bool decode_codes(Blocks *blocks, uint8_t *row, DstImage *dst,
                         unsigned min_bits, unsigned colors, unsigned width, unsigned height,
                         bool interlaced)
{
    const unsigned clear = 1u << min_bits, end = clear + 1;
    unsigned bits = min_bits + 1, next = clear + 2;
    unsigned previous = 0, first = 0, x = 0, y = 0;
    unsigned pass_step = interlaced ? 8 : 1, step = pass_step;
    unsigned code;
    while (read_code(blocks, bits, &code)) {
        if (code == end)
            return true;
        if (code == clear) {
            if (y >= height)
                return true;
            bits = min_bits + 1;
            /* The first literal after clear fills the unused end-code slot. */
            next = end;
            continue;
        }
        if (code > next || !colors || !width || next >= GIF_LZW_CODES)
            return false;

        unsigned cursor = code, top = sizeof(expansion);
        if (code == next) {
            expansion[--top] = first;
            cursor = previous;
        }
        /* The active palette defines the literal range, including for GIFs
           with a larger minimum code size than their palette needs. */
        while (cursor >= colors) {
            if (top <= 1 || cursor >= GIF_LZW_CODES)
                return false;
            expansion[--top] = suffix[cursor];
            cursor = prefix[cursor];
        }
        first = cursor;
        expansion[--top] = first;
        while (top < sizeof(expansion)) {
            row[x++] = expansion[top++];
            if (x == width) {
                dst->row(dst, y, row, NULL, 0);
                x = 0;
                y += step;
                while (y >= height) {
                    step = pass_step;
                    pass_step >>= 1;
                    if (!pass_step)
                        return true;
                    y = pass_step;
                }
            }
        }
        prefix[next] = previous;
        suffix[next] = first;
        previous = code;
        if (++next >= (1u << bits)) {
            if (bits < GIF_LZW_MAX_BITS)
                ++bits;
            else
                next = GIF_LZW_CODES - 1;
        }
    }
    return false;
}

/* gif_decode_lzw_scanlines, 0x2c9bac */
static bool scanlines(Reader *r, DstImage *dst, const Palette *palette,
                      int transparent, unsigned width, unsigned height, bool interlaced,
                      unsigned screen_width)
{
    unsigned min_bits = byte(r);
    uint8_t *row = malloc(screen_width);
    if (!row)
        return false;
    if (width < screen_width)
        memset(row + width, 0, screen_width - width);
    /* The Thumb decoder clears 4096 bytes of the 16-bit prefix table. */
    memset(prefix, 0, GIF_LZW_CODES);
    memset(suffix, 0, sizeof(suffix));
    memset(expansion, 0, sizeof(expansion));
    dst->palette(dst, palette->rgb, palette->count);
    bool ok = false;
    if (transparent >= 0) {
        if ((unsigned)transparent >= palette->count)
            goto done;
        dst->transparent(dst, palette->rgb[transparent], transparent);
    }

    Blocks blocks = {.r = r, .next_size = byte(r)};
    if (!blocks.next_size || blocks.next_size > r->left) {
        ok = true;
        goto done;
    }
    if (min_bits >= GIF_LZW_MAX_BITS || !load_block(&blocks))
        goto done;
    ok = decode_codes(&blocks, row, dst, min_bits, palette->count, width, height, interlaced);
    while (blocks.next_size) {
        if (!load_block(&blocks)) {
            ok = false;
            break;
        }
    }
done:
    free(row);
    return ok;
}

/* gif_decode_image_descriptor, 0x2c9fd4 */
static bool image(Reader *r, DstImage *dst, const Palette *global, Palette *local,
                  int transparent, unsigned screen_width, unsigned screen_height)
{
    const uint8_t *p = take(r, 9);
    if (!p)
        return false;
    unsigned width = little16(p + 4), height = little16(p + 6), flags = p[8];
    if (little16(p) + width > screen_width || little16(p + 2) + height > screen_height)
        return false;
    bool has_local = (flags & GIF_COLOR_TABLE_PRESENT) != 0;
    if (has_local && !read_palette(r, local, flags))
        return false;
    return scanlines(r, dst, has_local ? local : global, transparent,
                     width, height, (flags & GIF_INTERLACED) != 0, screen_width);
}

static bool skip_blocks(Reader *r)
{
    unsigned n;
    do {
        n = byte(r);
        if (!take(r, n))
            return false;
    } while (n);
    return true;
}

static bool application(Reader *r)
{
    unsigned n = byte(r);
    if (n > r->left)
        return false;
    if (n != GIF_APPLICATION_ID_BYTES)
        return take(r, n) != NULL;
    /* The ARM code compares the ID in place. Its subblock reader starts at
       the ID itself. NETSCAPE2.0 therefore starts with size 'N', type 'E'&7. */
    if (memcmp(*r->cursor, "NETSCAPE2.0", GIF_APPLICATION_ID_BYTES))
        return skip_blocks(r);
    n = byte(r);
    (void)byte(r);
    while (n && r->left > n) {
        take(r, n);
        n = byte(r);
    }
    return true;
}

/* GIFdecodeImage, 0x2ca0fc */
int GIFdecodeImage(const uint8_t **data, int32_t size, DstImage *dst)
{
    if (!data || !*data || !dst || size < 6 ||
        (memcmp(*data, "GIF87a", 6) && memcmp(*data, "GIF89a", 6)))
        return false;
    Reader r = {data, size};
    take(&r, 6);
    const uint8_t *p = take(&r, 7);
    if (!p)
        return false;
    unsigned width = little16(p), height = little16(p + 2), flags = p[4];
    Palette global = {0}, local = {0};
    bool ok = false;
    int transparent = -1;
    if (!jbed_image_plane(dst, dst->storage_size(dst, width, height), false) ||
        !dst->dimensions(dst, width, height))
        goto finish;
    if ((flags & GIF_COLOR_TABLE_PRESENT) && !read_palette(&r, &global, flags))
        goto finish;
    while (r.left) {
        switch (byte(&r)) {
        case GIF_IMAGE_SEPARATOR:
            ok = image(&r, dst, &global, &local, transparent, width, height);
            goto finish;
        case GIF_TRAILER:
            ok = true;
            goto finish;
        case GIF_EXTENSION:
            switch (byte(&r)) {
            case GIF_GRAPHIC_CONTROL:
                if (byte(&r) != 4 || !(p = take(&r, 4)))
                    goto cleanup;
                transparent = (p[0] & GIF_TRANSPARENCY_PRESENT) ? p[3] : -1;
                if (!r.left || byte(&r) != 0)
                    goto cleanup;
                break;
            case GIF_PLAIN_TEXT:
            case GIF_COMMENT:
                if (!skip_blocks(&r))
                    goto cleanup;
                break;
            case GIF_APPLICATION:
                if (!application(&r))
                    goto cleanup;
                break;
            default:
                goto cleanup;
            }
            break;
        default:
            goto cleanup;
        }
    }
    goto cleanup;
finish:
    dst->finish(dst);
cleanup:
    free(global.rgb);
    free(local.rgb);
    return ok;
}
