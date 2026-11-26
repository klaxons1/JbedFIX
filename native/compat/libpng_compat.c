/*
 * The PNG entry points imported by this Jbed build. Its M3G loader uses the
 * libpng 1.2 jmp_buf at offset zero and io_ptr at offset 276 directly. Keep
 * that prefix, then decode with Android's public BitmapFactory API through
 * JbedGraphics.decodePng. The loader accepts straight RGBA8 scanlines.
 */
#include <limits.h>
#include <setjmp.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef JBED_PNG_HOST_TEST
#include <android/bitmap.h>
#include <android/log.h>
#include <dlfcn.h>
#include <jni.h>
#include <stdatomic.h>
#endif

enum {
    LEGACY_PNG_IO_PTR_OFFSET = 276,
    PNG_CHUNK_HEADER_BYTES = 8,
    PNG_CHUNK_CRC_BYTES = 4,
    PNG_IHDR_BYTES = 13,
    PNG_COLOR_TYPE_RGB_ALPHA = 6
};

typedef struct legacy_png legacy_png;
typedef void (*png_read_callback)(legacy_png *, unsigned char *, size_t);
typedef void (*png_error_callback)(legacy_png *, const char *);

struct legacy_png {
    jmp_buf jump;
    unsigned char reserved[LEGACY_PNG_IO_PTR_OFFSET - sizeof(jmp_buf)];
    unsigned char io_ptr[sizeof(void *)];
    png_read_callback read;
    png_error_callback error;
    size_t remaining;
    unsigned char *encoded;
    size_t encoded_size;
    size_t encoded_capacity;
    unsigned char *pixels;
    uint32_t width;
    uint32_t height;
};

typedef struct {
    uint32_t width;
    uint32_t height;
} legacy_png_info;

_Static_assert(offsetof(legacy_png, io_ptr) == LEGACY_PNG_IO_PTR_OFFSET,
               "Jbed's PNG callback reads this field directly");

static const unsigned char png_signature[8] = {137, 80, 78, 71, 13, 10, 26, 10};

__attribute__((noreturn))
void png_error(legacy_png *png, const char *message) {
    if (png->error) png->error(png, message);
#ifndef JBED_PNG_HOST_TEST
    __android_log_print(ANDROID_LOG_WARN, "JbedPNG", "%s", message);
#endif
    longjmp(png->jump, 1);
}

int png_sig_cmp(const unsigned char *signature, size_t start, size_t count) {
    if (!signature || start >= sizeof(png_signature)) return -1;
    if (count > sizeof(png_signature) - start) count = sizeof(png_signature) - start;
    return memcmp(signature + start, png_signature + start, count);
}

legacy_png *png_create_read_struct(const char *version, void *error_context,
                                   png_error_callback error, png_error_callback warning) {
    (void)version;
    (void)error_context;
    (void)warning;
    legacy_png *png = calloc(1, sizeof(*png));
    if (png) png->error = error;
    return png;
}

legacy_png_info *png_create_info_struct(legacy_png *png) {
    return png ? calloc(1, sizeof(legacy_png_info)) : NULL;
}

void png_destroy_read_struct(legacy_png **png, legacy_png_info **info,
                             legacy_png_info **end_info) {
    if (end_info && *end_info && (!info || *end_info != *info)) free(*end_info);
    if (info) {
        free(*info);
        *info = NULL;
    }
    if (end_info) *end_info = NULL;
    if (png && *png) {
        free((*png)->encoded);
        free((*png)->pixels);
        free(*png);
        *png = NULL;
    }
}

void png_set_read_fn(legacy_png *png, void *context, png_read_callback read) {
    /* swvPNGLoadBuffer supplies {current, end}; its callback reads context
     * directly from png+276. Check subtraction here before that old callback
     * can perform an overflowing current+length bounds check. */
    uintptr_t bounds[2];
    if (!context || !read) png_error(png, "Missing PNG input");
    memcpy(bounds, context, sizeof(bounds));
    if (bounds[1] < bounds[0]) png_error(png, "Invalid PNG input range");
    memcpy(png->io_ptr, &context, sizeof(context));
    png->remaining = bounds[1] - bounds[0];
    png->read = read;
}

void *png_get_io_ptr(legacy_png *png) {
    void *context = NULL;
    if (png) memcpy(&context, png->io_ptr, sizeof(context));
    return context;
}

static void read_bytes(legacy_png *png, size_t count) {
    if (!png->read || count > png->remaining || count > INT_MAX - png->encoded_size)
        png_error(png, "Truncated or oversized PNG");
    size_t required = png->encoded_size + count;
    if (required > png->encoded_capacity) {
        size_t capacity = png->encoded_capacity ? png->encoded_capacity : 256;
        while (capacity < required) {
            if (capacity > INT_MAX / 2) {
                capacity = required;
                break;
            }
            capacity *= 2;
        }
        unsigned char *buffer = realloc(png->encoded, capacity);
        if (!buffer) png_error(png, "Cannot allocate PNG input");
        png->encoded = buffer;
        png->encoded_capacity = capacity;
    }
    png->read(png, png->encoded + png->encoded_size, count);
    png->encoded_size = required;
    png->remaining -= count;
}

static uint32_t big_endian_u32(const unsigned char *p) {
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3];
}

static int valid_dimensions(uint32_t width, uint32_t height) {
    /* The original caller multiplies width*height*4 in signed ARM32 ints. */
    return width && height && width <= INT_MAX / 4 && height <= INT_MAX / (4 * width);
}

#ifdef JBED_PNG_HOST_TEST
static int decode_png(legacy_png *png);
#else
static JavaVM *java_vm;
static jclass graphics_class;
static jmethodID decode_method;
static jmethodID recycle_method;
typedef void (*CallHost)(JNIEnv *, void (*)(JNIEnv *, void *), void *);
static _Atomic(CallHost) call_host;

static CallHost get_host_bridge(void) {
    CallHost call = atomic_load_explicit(&call_host, memory_order_acquire);
    if (call) return call;
    /* PNG loads before the service's VM adapter. Cache successful lookup,
     * allowing initialization to finish before the first image is decoded. */
    void *library = dlopen("libjbedcompat.so", RTLD_NOW | RTLD_NOLOAD);
    if (!library) return NULL;
    call = (CallHost)dlsym(library, "jbedcompat_call_host");
    if (call) atomic_store_explicit(&call_host, call, memory_order_release);
    dlclose(library);
    return call;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void)reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;
    jclass local = (*env)->FindClass(env, "com/esmertec/android/jbed/app/JbedGraphics");
    if (!local) return JNI_ERR;
    decode_method = (*env)->GetStaticMethodID(env, local, "decodePng", "([B)Landroid/graphics/Bitmap;");
    if (!decode_method) {
        (*env)->DeleteLocalRef(env, local);
        return JNI_ERR;
    }
    graphics_class = (*env)->NewGlobalRef(env, local);
    (*env)->DeleteLocalRef(env, local);
    if (!graphics_class) return JNI_ERR;
    jclass bitmap = (*env)->FindClass(env, "android/graphics/Bitmap");
    if (bitmap) {
        recycle_method = (*env)->GetMethodID(env, bitmap, "recycle", "()V");
        (*env)->DeleteLocalRef(env, bitmap);
    }
    if (!decode_method || !graphics_class || !recycle_method || (*env)->ExceptionCheck(env)) {
        if (graphics_class) (*env)->DeleteGlobalRef(env, graphics_class);
        graphics_class = NULL;
        return JNI_ERR;
    }
    java_vm = vm;
    return JNI_VERSION_1_6;
}

typedef struct {
    legacy_png *png;
    int success;
} DecodeCall;

static void decode_png_on_host(JNIEnv *env, void *argument) {
    DecodeCall *call = argument;
    legacy_png *png = call->png;
    int locked = 0;
    jobject bitmap = NULL;
    if ((*env)->PushLocalFrame(env, 4) != JNI_OK) goto finish;
    jbyteArray bytes = (*env)->NewByteArray(env, (jsize)png->encoded_size);
    if (!bytes) goto done;
    (*env)->SetByteArrayRegion(env, bytes, 0, (jsize)png->encoded_size, (jbyte *)png->encoded);
    if ((*env)->ExceptionCheck(env)) goto done;
    bitmap = (*env)->CallStaticObjectMethod(env, graphics_class, decode_method, bytes);
    if ((*env)->ExceptionCheck(env) || !bitmap) goto done;

    AndroidBitmapInfo info = {0};
    void *pixels = NULL;
    if (AndroidBitmap_getInfo(env, bitmap, &info) != ANDROID_BITMAP_RESULT_SUCCESS ||
        info.format != ANDROID_BITMAP_FORMAT_RGBA_8888 ||
        info.width != png->width || info.height != png->height ||
        info.stride < 4 * png->width || info.stride > SIZE_MAX / png->height) goto done;
    if (AndroidBitmap_lockPixels(env, bitmap, &pixels) != ANDROID_BITMAP_RESULT_SUCCESS) goto done;
    locked = 1;
    size_t row_bytes = (size_t)png->width * 4;
    png->pixels = malloc(row_bytes * png->height);
    if (!png->pixels) goto done;
    for (uint32_t y = 0; y < png->height; ++y)
        memcpy(png->pixels + y * row_bytes, (unsigned char *)pixels + (size_t)y * info.stride, row_bytes);
    call->success = 1;

done:
    if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
    if (locked) AndroidBitmap_unlockPixels(env, bitmap);
    if (bitmap) (*env)->CallVoidMethod(env, bitmap, recycle_method);
    (*env)->PopLocalFrame(env, NULL);
finish:
    if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
}

static int decode_png(legacy_png *png) {
    if (!java_vm) return 0;
    CallHost host = get_host_bridge();
    if (!host) return 0;
    JNIEnv *env = NULL;
    int attached = 0;
    jint status = (*java_vm)->GetEnv(java_vm, (void **)&env, JNI_VERSION_1_6);
    if (status == JNI_EDETACHED) {
        if ((*java_vm)->AttachCurrentThread(java_vm, &env, NULL) != JNI_OK) return 0;
        attached = 1;
    } else if (status != JNI_OK) {
        return 0;
    }
    /* Platform bitmap functions need the real ART JNIEnv. Run the complete
     * operation on the pthread stack parked by Jbed's scheduler. */
    DecodeCall call = {png, 0};
    host(env, decode_png_on_host, &call);
    if (attached) (*java_vm)->DetachCurrentThread(java_vm);
    return call.success;
}
#endif

void png_read_info(legacy_png *png, legacy_png_info *info) {
    if (!info || png->encoded_size || png->pixels) png_error(png, "Invalid PNG read state");
    read_bytes(png, sizeof(png_signature));
    if (png_sig_cmp(png->encoded, 0, sizeof(png_signature))) png_error(png, "Invalid PNG signature");
    int first = 1;
    for (;;) {
        read_bytes(png, PNG_CHUNK_HEADER_BYTES);
        const unsigned char *header = png->encoded + png->encoded_size - PNG_CHUNK_HEADER_BYTES;
        uint32_t length = big_endian_u32(header);
        int ihdr = memcmp(header + 4, "IHDR", 4) == 0;
        int iend = memcmp(header + 4, "IEND", 4) == 0;
        if (length > INT_MAX - PNG_CHUNK_CRC_BYTES || (first && (!ihdr || length != PNG_IHDR_BYTES)) ||
            (!first && ihdr) || (iend && length != 0)) png_error(png, "Invalid PNG chunk");
        read_bytes(png, (size_t)length + PNG_CHUNK_CRC_BYTES);
        if (first) {
            const unsigned char *dimensions = png->encoded + sizeof(png_signature) + PNG_CHUNK_HEADER_BYTES;
            png->width = big_endian_u32(dimensions);
            png->height = big_endian_u32(dimensions + 4);
            if (!valid_dimensions(png->width, png->height)) png_error(png, "Oversized PNG image");
            first = 0;
        }
        if (iend) break;
    }
    if (!decode_png(png)) png_error(png, "Android could not decode PNG");
    info->width = png->width;
    info->height = png->height;
    free(png->encoded);
    png->encoded = NULL;
    png->encoded_size = png->encoded_capacity = 0;
}

unsigned int png_get_IHDR(legacy_png *png, legacy_png_info *info,
                          uint32_t *width, uint32_t *height, int *depth, int *color,
                          int *interlace, int *compression, int *filter) {
    (void)png;
    if (!info || !info->width || !info->height) return 0;
    if (width) *width = info->width;
    if (height) *height = info->height;
    if (depth) *depth = 8;
    if (color) *color = PNG_COLOR_TYPE_RGB_ALPHA;
    if (interlace) *interlace = 0;
    if (compression) *compression = 0;
    if (filter) *filter = 0;
    return 1;
}

/* BitmapFactory has already expanded palette entries and tRNS into RGBA. */
unsigned int png_get_valid(legacy_png *png, legacy_png_info *info, unsigned int flag) {
    (void)png; (void)info; (void)flag;
    return 0;
}

unsigned int png_get_PLTE(legacy_png *png, legacy_png_info *info, void **palette, int *count) {
    (void)png; (void)info;
    if (palette) *palette = NULL;
    if (count) *count = 0;
    return 0;
}

unsigned int png_get_tRNS(legacy_png *png, legacy_png_info *info, void **alpha,
                         int *count, void **color) {
    (void)png; (void)info;
    if (alpha) *alpha = NULL;
    if (count) *count = 0;
    if (color) *color = NULL;
    return 0;
}

void png_set_packing(legacy_png *png) { (void)png; }
void png_set_strip_16(legacy_png *png) { (void)png; }

void png_read_image(legacy_png *png, unsigned char **rows) {
    if (!rows || !png->pixels) png_error(png, "Missing decoded PNG pixels");
    size_t row_bytes = (size_t)png->width * 4;
    for (uint32_t y = 0; y < png->height; ++y) {
        if (!rows[y]) png_error(png, "Missing PNG output row");
        memcpy(rows[y], png->pixels + y * row_bytes, row_bytes);
    }
}

void png_read_end(legacy_png *png, legacy_png_info *info) { (void)png; (void)info; }
