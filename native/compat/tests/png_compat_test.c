/* Host contract tests for the legacy PNG ABI. Android supplies the decoder. */
#define JBED_PNG_HOST_TEST
#include "../libpng_compat.c"
#include <assert.h>
#include <stdio.h>

static const unsigned char fixture[] = {
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
    0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x99, 0x81, 0xb6, 0x27,
    0x00, 0x00, 0x00, 0x12, 0x49, 0x44, 0x41, 0x54,
    0x78, 0x9c, 0x63, 0x60, 0x64, 0x62, 0x66, 0x61,
    0xe0, 0xe4, 0x60, 0x67, 0x03, 0x00, 0x00, 0xa0,
    0x00, 0x29, 0x07, 0x95, 0xf3, 0xf8,
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44,
    0xae, 0x42, 0x60, 0x82
};
static const unsigned char expected_pixels[] = {1, 2, 3, 4, 9, 8, 7, 6};
static unsigned decoder_calls;

static int decode_png(legacy_png *png) {
    ++decoder_calls;
    assert(png->encoded_size == sizeof(fixture));
    assert(memcmp(png->encoded, fixture, sizeof(fixture)) == 0);
    png->pixels = malloc(sizeof(expected_pixels));
    assert(png->pixels);
    memcpy(png->pixels, expected_pixels, sizeof(expected_pixels));
    return 1;
}

static void legacy_read(legacy_png *png, unsigned char *out, size_t count) {
    const unsigned char **context;
    /* Mirror the original callback's hard-coded offset, including on hosts
     * where an eight-byte pointer would otherwise be padded to offset 280. */
    memcpy(&context, (unsigned char *)png + 276, sizeof(context));
    assert(count <= (size_t)(context[1] - context[0]));
    memcpy(out, context[0], count);
    context[0] += count;
}

static void expect_rejected(const unsigned char *data, size_t size) {
    legacy_png *png = png_create_read_struct("1.2.16", NULL, NULL, NULL);
    legacy_png_info *info = png_create_info_struct(png);
    const unsigned char *context[] = {data, data + size};
    unsigned calls_before = decoder_calls;
    assert(png && info);
    if (!setjmp(*(jmp_buf *)png)) {
        png_set_read_fn(png, context, legacy_read);
        png_read_info(png, info);
        assert(!"malformed PNG accepted");
    }
    assert(decoder_calls == calls_before);
    png_destroy_read_struct(&png, &info, NULL);
    assert(!png && !info);
}

int main(void) {
    assert(!png_sig_cmp(fixture, 0, 8));
    assert(!png_sig_cmp(fixture, 3, 100));
    assert(png_sig_cmp(fixture, 8, 1));
    assert(png_sig_cmp(NULL, 0, 8));

    legacy_png *png = png_create_read_struct("1.2.16", NULL, NULL, NULL);
    legacy_png_info *info = png_create_info_struct(png);
    unsigned char with_trailer[sizeof(fixture) + 4];
    memcpy(with_trailer, fixture, sizeof(fixture));
    memset(with_trailer + sizeof(fixture), 0xff, 4);
    const unsigned char *context[] = {with_trailer, with_trailer + sizeof(with_trailer)};
    assert(png && info);
    if (setjmp(*(jmp_buf *)png)) assert(!"valid PNG rejected");
    png_set_read_fn(png, context, legacy_read);
    png_read_info(png, info);
    assert(decoder_calls == 1 && png->remaining == 4);
    assert(context[0] == with_trailer + sizeof(fixture));
    uint32_t width = 0, height = 0;
    int depth = 0, color = 0;
    assert(png_get_IHDR(png, info, &width, &height, &depth, &color, NULL, NULL, NULL));
    assert(width == 1 && height == 2 && depth == 8 && color == 6);
    assert(!png_get_valid(png, info, 16));
    unsigned char output[12];
    memset(output, 0xee, sizeof(output));
    unsigned char *rows[] = {output, output + 8};
    png_read_image(png, rows);
    assert(!memcmp(output, expected_pixels, 4));
    assert(!memcmp(output + 8, expected_pixels + 4, 4));
    for (unsigned i = 4; i < 8; ++i) assert(output[i] == 0xee);
    png_read_end(png, info);
    png_destroy_read_struct(&png, &info, &info);
    assert(!png && !info);

    for (size_t size = 0; size < sizeof(fixture); ++size) expect_rejected(fixture, size);
    unsigned char malformed[sizeof(fixture)];
    memcpy(malformed, fixture, sizeof(fixture));
    malformed[0] = 0;
    expect_rejected(malformed, sizeof(malformed));
    memcpy(malformed, fixture, sizeof(fixture));
    memset(malformed + 33, 0xff, 4); /* overflowing IDAT length */
    expect_rejected(malformed, sizeof(malformed));
    memcpy(malformed, fixture, sizeof(fixture));
    memset(malformed + 16, 0xff, 4); /* overflowing RGBA output size */
    expect_rejected(malformed, sizeof(malformed));
    memcpy(malformed, fixture, sizeof(fixture));
    memset(malformed + 20, 0, 4); /* zero height */
    expect_rejected(malformed, sizeof(malformed));
    puts("PNG compatibility contract tests passed");
    return 0;
}
