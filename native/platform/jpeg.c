#include "image.h"

#include <setjmp.h>
#include <stdio.h>
#include <string.h>

#include "jpeg6b/jpeglib.h"
#include "jpeg6b/jerror.h"

enum { INPUT_BUF_SIZE = 4096 };

typedef struct {
    struct jpeg_source_mgr pub;
    const uint8_t **cursor;
    int32_t remaining;
    JOCTET *buffer;
    boolean start_of_file;
} my_source_mgr;

struct my_error_mgr {
    struct jpeg_error_mgr pub;
    jmp_buf setjmp_buffer;
};

#if defined(__ANDROID__) && defined(__arm__)
_Static_assert(sizeof(my_source_mgr) == 44 && offsetof(my_source_mgr, buffer) == 36,
               "Jbed JPEG source manager");
_Static_assert(offsetof(struct my_error_mgr, setjmp_buffer) == 132 &&
               sizeof(struct jpeg_decompress_struct) == 464, "Jbed JPEG decompressor ABI");
#endif

/* The callbacks follow IJG 6b's jdatasrc.c, with a moving Jbed array cursor
 * in place of the file stream. */
static void init_source(j_decompress_ptr cinfo)
{
    my_source_mgr *src = (my_source_mgr *)cinfo->src;
    src->start_of_file = TRUE;
}

/* 0x2c9a28 */
static boolean fill_input_buffer(j_decompress_ptr cinfo)
{
    my_source_mgr *src = (my_source_mgr *)cinfo->src;
    int32_t nbytes = src->remaining;
    if (nbytes > INPUT_BUF_SIZE)
        nbytes = INPUT_BUF_SIZE;
    memcpy(src->buffer, *src->cursor, nbytes);
    src->remaining -= nbytes;
    *src->cursor += nbytes;
    if (nbytes == 0) {
        if (src->start_of_file)
            ERREXIT(cinfo, JERR_INPUT_EMPTY);
        WARNMS(cinfo, JWRN_JPEG_EOF);
        src->buffer[0] = 0xff;
        src->buffer[1] = JPEG_EOI;
        nbytes = 2;
    }
    src->pub.next_input_byte = src->buffer;
    src->pub.bytes_in_buffer = (size_t)nbytes;
    src->start_of_file = FALSE;
    return TRUE;
}

/* 0x2c9acc */
static void skip_input_data(j_decompress_ptr cinfo, long num_bytes)
{
    my_source_mgr *src = (my_source_mgr *)cinfo->src;
    if (num_bytes > 0) {
        while (num_bytes > (long)src->pub.bytes_in_buffer) {
            num_bytes -= (long)src->pub.bytes_in_buffer;
            fill_input_buffer(cinfo);
        }
        src->pub.next_input_byte += num_bytes;
        src->pub.bytes_in_buffer -= (size_t)num_bytes;
    }
}

static void term_source(j_decompress_ptr cinfo)
{
    (void)cinfo;
}

/* 0x2c9aac */
static void my_error_exit(j_common_ptr cinfo)
{
    struct my_error_mgr *error = (struct my_error_mgr *)cinfo->err;
    cinfo->err->output_message(cinfo);
    longjmp(error->setjmp_buffer, 1);
}

/* 0x2c9864 */
int JPEGdecodeImage(const uint8_t **cursor, int32_t size, DstImage *dst)
{
    if (!cursor || !*cursor || !dst || size < 0)
        return false;
    struct jpeg_decompress_struct cinfo;
    struct my_error_mgr jerr;
    cinfo.client_data = NULL;
    cinfo.err = jpeg_std_error(&jerr.pub);
    jerr.pub.error_exit = my_error_exit;
    if (setjmp(jerr.setjmp_buffer)) {
        jpeg_destroy_decompress(&cinfo);
        return false;
    }
    jpeg_create_decompress(&cinfo);
    j_common_ptr common = (j_common_ptr)&cinfo;
    my_source_mgr *src = cinfo.mem->alloc_small(common, JPOOL_IMAGE, sizeof(*src));
    cinfo.src = &src->pub;
    src->buffer = cinfo.mem->alloc_small(common, JPOOL_IMAGE, INPUT_BUF_SIZE);
    src->pub.init_source = init_source;
    src->pub.fill_input_buffer = fill_input_buffer;
    src->pub.skip_input_data = skip_input_data;
    src->pub.resync_to_restart = jpeg_resync_to_restart;
    src->pub.term_source = term_source;
    src->cursor = cursor;
    src->pub.bytes_in_buffer = 0;
    src->pub.next_input_byte = NULL;
    src->remaining = size;

    jpeg_read_header(&cinfo, TRUE);
    dst->color_space = cinfo.jpeg_color_space;
    dst->components = cinfo.num_components;
    cinfo.out_color_space = JCS_RGB;
    if (jbed_image_plane(dst, dst->storage_size(dst, cinfo.image_width, cinfo.image_height), false))
        dst->dimensions(dst, cinfo.image_width, cinfo.image_height);
    jpeg_start_decompress(&cinfo);
    JSAMPARRAY row = cinfo.mem->alloc_sarray(common, JPOOL_IMAGE,
                                             cinfo.output_width * cinfo.output_components, 1);
    while (cinfo.output_scanline < cinfo.output_height) {
        jpeg_read_scanlines(&cinfo, row, 1);
        dst->row(dst, cinfo.output_scanline - 1, row[0], NULL, 1);
    }
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    return true;
}
