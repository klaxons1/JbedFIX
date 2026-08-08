/*
 * Loader compatibility shim for the pre-NDK libpng ABI imported by
 * libjbedvm.so. Android 11's app linker does not export those symbols.
 *
 * It permits the VM to load and report the next compatibility gap. PNG decode
 * is deliberately not implemented in this first stage: constructors return
 * null and callers must treat that as a decode failure.
 */
#include <stddef.h>

void *png_create_info_struct() { return NULL; }
void *png_create_read_struct() { return NULL; }
void png_destroy_read_struct() { }
void png_error() { }
unsigned int png_get_IHDR() { return 0; }
void *png_get_PLTE() { return NULL; }
void *png_get_tRNS() { return NULL; }
unsigned int png_get_valid() { return 0; }
void png_read_end() { }
void png_read_image() { }
void png_read_info() { }
void png_set_packing() { }
void png_set_read_fn() { }
void png_set_strip_16() { }
int png_sig_cmp() { return 1; }
