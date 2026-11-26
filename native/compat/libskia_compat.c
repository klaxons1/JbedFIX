/* The Skia ABI imported by Jbed, backed by Android Paint and Bitmap APIs.
 * Jbed allocates 60-byte paints, 40-byte bitmaps and 212-byte canvases itself.
 * These small adapter records fit those allocations without a C++ runtime. */
#include <android/bitmap.h>
#include <android/log.h>
#include <dlfcn.h>
#include <jni.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum {
    kUTF16_TextEncoding = 1,
    kRGB_565_Config = 4
};

/* Matches the Font constructor and metrics array in JbedGraphics. */
enum { FONT_SANS_SERIF, FONT_MONOSPACE, FONT_SERIF };
enum { FONT_TOP, FONT_ASCENT, FONT_DESCENT, FONT_BOTTOM, FONT_LEADING, FONT_METRIC_COUNT };
enum { FONT_STYLE_COUNT = 4, FONT_STYLE_MASK = FONT_STYLE_COUNT - 1 };

typedef struct {
    int family, style;
    float size, skew;
    int underline, antialias;
} FontKey;

typedef struct NativeFont {
    FontKey key;
    jobject object;
    float metrics[FONT_METRIC_COUNT];
    struct NativeFont *next;
} NativeFont;

typedef struct {
    FontKey key;
    int encoding;
    uint32_t color;
    NativeFont *font;
} Paint;

typedef struct {
    int config, width, height, row_bytes;
    void *pixels;
} Bitmap;

typedef struct {
    Bitmap bitmap;
    int left, top, right, bottom;
} Canvas;

_Static_assert(sizeof(Paint) <= 60, "legacy SkPaint allocation");
_Static_assert(sizeof(Bitmap) <= 40, "legacy SkBitmap allocation");
_Static_assert(sizeof(Canvas) <= 212, "legacy SkCanvas allocation");

static JavaVM *java_vm;
static jclass graphics_class;
static jmethodID create_font, measure_font, rasterize_font;
static jfieldID font_metrics, glyph_bitmap, glyph_left, glyph_top;
static pthread_key_t attached_thread;
static pthread_mutex_t fonts_mutex = PTHREAD_MUTEX_INITIALIZER;
static NativeFont *fonts;
typedef void (*HostCall)(JNIEnv *, void (*)(JNIEnv *, void *), void *);
static HostCall host_call;
static pthread_once_t host_call_once = PTHREAD_ONCE_INIT;

static void resolve_host_call(void) {
    void *library = dlopen("libjbedcompat.so", RTLD_NOW | RTLD_NOLOAD);
    if (library) {
        host_call = (HostCall)dlsym(library, "jbedcompat_call_host");
        dlclose(library);
    }
}

static void run_on_host(JNIEnv *env, void (*callback)(JNIEnv *, void *), void *argument) {
    pthread_once(&host_call_once, resolve_host_call);
    if (host_call) host_call(env, callback, argument);
    else callback(env, argument);
}

static void detach_thread(void *unused) {
    (void)unused;
    if (java_vm) (*java_vm)->DetachCurrentThread(java_vm);
}

static JNIEnv *get_env(void) {
    JNIEnv *env = NULL;
    if (!java_vm) return NULL;
    jint status = (*java_vm)->GetEnv(java_vm, (void **)&env, JNI_VERSION_1_6);
    if (status == JNI_EDETACHED) {
        if ((*java_vm)->AttachCurrentThread(java_vm, &env, NULL) != JNI_OK) return NULL;
        pthread_setspecific(attached_thread, (void *)1);
    } else if (status != JNI_OK) {
        return NULL;
    }
    return env;
}

static int clear_exception(JNIEnv *env) {
    if (!(*env)->ExceptionCheck(env)) return 0;
    (*env)->ExceptionDescribe(env);
    (*env)->ExceptionClear(env);
    __android_log_print(ANDROID_LOG_ERROR, "jbed_graphics", "Android font operation failed");
    return 1;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void)reserved;
    JNIEnv *env;
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;
    java_vm = vm;
    jclass local = (*env)->FindClass(env, "com/esmertec/android/jbed/app/JbedGraphics");
    if (!local) return JNI_ERR;
    graphics_class = (*env)->NewGlobalRef(env, local);
    (*env)->DeleteLocalRef(env, local);
    jclass font_class = (*env)->FindClass(env, "com/esmertec/android/jbed/app/JbedGraphics$Font");
    jclass glyph_class = (*env)->FindClass(env, "com/esmertec/android/jbed/app/JbedGraphics$Glyph");
    if (!graphics_class || !font_class || !glyph_class) return JNI_ERR;
    create_font = (*env)->GetStaticMethodID(env, graphics_class, "createFont",
            "(IIFFZZ)Lcom/esmertec/android/jbed/app/JbedGraphics$Font;");
    measure_font = (*env)->GetMethodID(env, font_class, "measure", "(Ljava/lang/String;)F");
    rasterize_font = (*env)->GetMethodID(env, font_class, "rasterize",
            "(Ljava/lang/String;IIII)Lcom/esmertec/android/jbed/app/JbedGraphics$Glyph;");
    font_metrics = (*env)->GetFieldID(env, font_class, "metrics", "[F");
    glyph_bitmap = (*env)->GetFieldID(env, glyph_class, "bitmap", "Landroid/graphics/Bitmap;");
    glyph_left = (*env)->GetFieldID(env, glyph_class, "left", "I");
    glyph_top = (*env)->GetFieldID(env, glyph_class, "top", "I");
    (*env)->DeleteLocalRef(env, font_class);
    (*env)->DeleteLocalRef(env, glyph_class);
    if ((*env)->ExceptionCheck(env) || !create_font || !measure_font || !rasterize_font ||
            !font_metrics || !glyph_bitmap || !glyph_left || !glyph_top) return JNI_ERR;
    if (pthread_key_create(&attached_thread, detach_thread) != 0) return JNI_ERR;
    return JNI_VERSION_1_6;
}

/* The VM releases paints with operator delete, without a destructor. Font
 * objects therefore belong to this pool, shared by identical font settings.
 * The VM's face/style/size combinations are fixed at font initialization. */
static NativeFont *get_font(Paint *paint, JNIEnv *env) {
    if (paint->font) return paint->font;
    if (!env) return NULL;
    pthread_mutex_lock(&fonts_mutex);
    NativeFont *font;
    for (font = fonts; font; font = font->next) {
        if (memcmp(&font->key, &paint->key, sizeof(FontKey)) == 0) break;
    }
    if (!font) {
        jobject object = (*env)->CallStaticObjectMethod(env, graphics_class, create_font,
                paint->key.family, paint->key.style, (jfloat)paint->key.size,
                (jfloat)paint->key.skew, (jboolean)paint->key.underline,
                (jboolean)paint->key.antialias);
        if (clear_exception(env) || !object) goto done;
        font = calloc(1, sizeof(*font));
        if (font) {
            font->key = paint->key;
            font->object = (*env)->NewGlobalRef(env, object);
            jfloatArray metrics = (*env)->GetObjectField(env, object, font_metrics);
            if (metrics) {
                (*env)->GetFloatArrayRegion(env, metrics, 0, FONT_METRIC_COUNT, font->metrics);
                (*env)->DeleteLocalRef(env, metrics);
            }
            if (clear_exception(env) || !font->object || !metrics) {
                if (font->object) (*env)->DeleteGlobalRef(env, font->object);
                free(font);
                font = NULL;
            } else {
                font->next = fonts;
                fonts = font;
            }
        }
        (*env)->DeleteLocalRef(env, object);
    }
done:
    paint->font = font;
    pthread_mutex_unlock(&fonts_mutex);
    return font;
}

static jstring make_text(JNIEnv *env, const Paint *paint, const void *text, uint32_t length) {
    if (paint->encoding == kUTF16_TextEncoding)
        return (*env)->NewString(env, text, (jsize)(length / sizeof(jchar)));
    /* The VM selects UTF-16 when creating every target font. */
    return NULL;
}

void sk_paint_ctor(void *self) asm("_ZN7SkPaintC1Ev");
void sk_paint_ctor(void *self) {
    Paint *p = self;
    memset(p, 0, sizeof(*p));
    p->key.size = 12.0f;
    p->color = 0xff000000u;
}
void sk_paint_set_text_size(void *self, float size) asm("_ZN7SkPaint11setTextSizeEf");
void sk_paint_set_text_size(void *self, float size) { Paint *p = self; p->key.size = size; p->font = NULL; }
void *sk_paint_set_typeface(void *self, void *typeface) asm("_ZN7SkPaint11setTypefaceEP10SkTypeface");
void *sk_paint_set_typeface(void *self, void *typeface) {
    Paint *p = self;
    void *old = (void *)(uintptr_t)(1 + p->key.family * FONT_STYLE_COUNT + p->key.style);
    uintptr_t value = typeface ? (uintptr_t)typeface - 1 : 0;
    p->key.family = value / FONT_STYLE_COUNT;
    p->key.style = value % FONT_STYLE_COUNT;
    p->font = NULL;
    return old;
}
void sk_paint_set_antialias(void *self, int enabled) asm("_ZN7SkPaint12setAntiAliasEb");
void sk_paint_set_antialias(void *self, int enabled) { Paint *p = self; p->key.antialias = !!enabled; p->font = NULL; }
void sk_paint_set_skew(void *self, float skew) asm("_ZN7SkPaint12setTextSkewXEf");
void sk_paint_set_skew(void *self, float skew) { Paint *p = self; p->key.skew = skew; p->font = NULL; }
void sk_paint_set_encoding(void *self, int encoding) asm("_ZN7SkPaint15setTextEncodingENS_12TextEncodingE");
void sk_paint_set_encoding(void *self, int encoding) { ((Paint *)self)->encoding = encoding; }
void sk_paint_set_underline(void *self, int enabled) asm("_ZN7SkPaint16setUnderlineTextEb");
void sk_paint_set_underline(void *self, int enabled) { Paint *p = self; p->key.underline = !!enabled; p->font = NULL; }
void sk_paint_set_color(void *self, uint32_t color) asm("_ZN7SkPaint8setColorEj");
void sk_paint_set_color(void *self, uint32_t color) { ((Paint *)self)->color = color; }

float sk_paint_measure_text(const void *self, const void *text, uint32_t length, void *bounds, float scale)
    asm("_ZNK7SkPaint11measureTextEPKvjP6SkRectf");
typedef struct {
    Paint *paint;
    const void *text;
    uint32_t length;
    float width;
} MeasureText;

static void measure_text_host(JNIEnv *env, void *argument) {
    MeasureText *measure = argument;
    NativeFont *font = get_font(measure->paint, env);
    if (!font) return;
    jstring string = make_text(env, measure->paint, measure->text, measure->length);
    if (!string) { clear_exception(env); return; }
    float width = (*env)->CallFloatMethod(env, font->object, measure_font, string);
    (*env)->DeleteLocalRef(env, string);
    if (!clear_exception(env)) measure->width = width;
}

float sk_paint_measure_text(const void *self, const void *text, uint32_t length, void *bounds, float scale) {
    (void)scale;
    if (bounds) memset(bounds, 0, sizeof(float) * 4);
    if (!text || !length) return 0.0f;
    JNIEnv *env = get_env();
    if (!env) return 0.0f;
    MeasureText measure = {(Paint *)self, text, length, 0.0f};
    run_on_host(env, measure_text_host, &measure);
    return measure.width;
}
float sk_paint_get_metrics(const void *self, void *metrics, float scale)
    asm("_ZNK7SkPaint14getFontMetricsEPNS_11FontMetricsEf");

typedef struct {
    Paint *paint;
    NativeFont *font;
} GetFont;

static void get_font_host(JNIEnv *env, void *argument) {
    GetFont *request = argument;
    request->font = get_font(request->paint, env);
}

float sk_paint_get_metrics(const void *self, void *metrics, float scale) {
    (void)scale;
    GetFont request = {(Paint *)self, ((Paint *)self)->font};
    if (!request.font) {
        JNIEnv *env = get_env();
        if (env) run_on_host(env, get_font_host, &request);
    }
    NativeFont *font = request.font;
    if (!font) {
        if (metrics) memset(metrics, 0, sizeof(float) * FONT_METRIC_COUNT);
        return 0.0f;
    }
    if (metrics) memcpy(metrics, font->metrics, sizeof(font->metrics));
    return font->metrics[FONT_DESCENT] - font->metrics[FONT_ASCENT] + font->metrics[FONT_LEADING];
}

void *sk_typeface_create(const char *name, int style) asm("_ZN10SkTypeface14CreateFromNameEPKcNS_5StyleE");
void *sk_typeface_create(const char *name, int style) {
    int family = name && !strcmp(name, "monospace") ? FONT_MONOSPACE
               : name && !strcmp(name, "serif") ? FONT_SERIF : FONT_SANS_SERIF;
    return (void *)(uintptr_t)(1 + family * FONT_STYLE_COUNT + (style & FONT_STYLE_MASK));
}

void sk_bitmap_ctor(void *self) asm("_ZN8SkBitmapC1Ev");
void sk_bitmap_ctor(void *self) { memset(self, 0, sizeof(Bitmap)); }
void sk_bitmap_dtor(void *self) asm("_ZN8SkBitmapD1Ev");
void sk_bitmap_dtor(void *self) { (void)self; }
void sk_bitmap_set_config(void *self, int config, int width, int height, int row_bytes)
    asm("_ZN8SkBitmap9setConfigENS_6ConfigEiii");
void sk_bitmap_set_config(void *self, int config, int width, int height, int row_bytes) {
    Bitmap *bitmap = self;
    bitmap->config = config;
    bitmap->width = width;
    bitmap->height = height;
    bitmap->row_bytes = row_bytes ? row_bytes : width * 2;
}
void sk_bitmap_set_pixels(void *self, void *pixels, void *color_table) asm("_ZN8SkBitmap9setPixelsEPvP12SkColorTable");
void sk_bitmap_set_pixels(void *self, void *pixels, void *color_table) {
    (void)color_table;
    ((Bitmap *)self)->pixels = pixels;
}

void sk_canvas_ctor(void *self, void *device) asm("_ZN8SkCanvasC1EP8SkDevice");
void sk_canvas_ctor(void *self, void *device) { (void)device; memset(self, 0, sizeof(Canvas)); }
void sk_canvas_dtor(void *self) asm("_ZN8SkCanvasD1Ev");
void sk_canvas_dtor(void *self) { (void)self; }
void sk_canvas_set_bitmap_device(void *self, const void *bitmap) asm("_ZN8SkCanvas15setBitmapDeviceERK8SkBitmap");
void sk_canvas_set_bitmap_device(void *self, const void *bitmap) {
    Canvas *canvas = self;
    canvas->bitmap = *(const Bitmap *)bitmap;
    canvas->left = canvas->top = 0;
    canvas->right = canvas->bitmap.width;
    canvas->bottom = canvas->bitmap.height;
}
int sk_canvas_clip_rect(void *self, const void *rect, int op) asm("_ZN8SkCanvas8clipRectERK6SkRectN8SkRegion2OpE");
int sk_canvas_clip_rect(void *self, const void *rect, int op) {
    (void)op; /* Jbed uses kIntersect_Op. */
    Canvas *canvas = self;
    const float *r = rect;
    if (r[0] > canvas->left) canvas->left = (int)r[0];
    if (r[1] > canvas->top) canvas->top = (int)r[1];
    if (r[2] < canvas->right) canvas->right = (int)r[2];
    if (r[3] < canvas->bottom) canvas->bottom = (int)r[3];
    return canvas->right > canvas->left && canvas->bottom > canvas->top;
}

void sk_canvas_draw_text(void *self, const void *text, uint32_t length, float x, float y, const void *paint_arg)
    asm("_ZN8SkCanvas8drawTextEPKvjffRK7SkPaint");
typedef struct {
    Canvas *canvas;
    Paint *paint;
    const void *text;
    uint32_t length;
    float x, y;
} DrawText;

static void draw_text_host(JNIEnv *env, void *argument) {
    DrawText *draw = argument;
    Canvas *canvas = draw->canvas;
    Paint *paint = draw->paint;
    NativeFont *font = get_font(paint, env);
    if (!font) return;
    jstring string = make_text(env, paint, draw->text, draw->length);
    if (!string) { clear_exception(env); return; }
    int origin_x = (int)draw->x, origin_y = (int)draw->y;
    jobject glyph = (*env)->CallObjectMethod(env, font->object, rasterize_font, string,
            canvas->left - origin_x, canvas->top - origin_y,
            canvas->right - origin_x, canvas->bottom - origin_y);
    (*env)->DeleteLocalRef(env, string);
    if (clear_exception(env) || !glyph) return;
    jobject bitmap = (*env)->GetObjectField(env, glyph, glyph_bitmap);
    int left = origin_x + (*env)->GetIntField(env, glyph, glyph_left);
    int top = origin_y + (*env)->GetIntField(env, glyph, glyph_top);
    AndroidBitmapInfo info;
    void *pixels;
    if (!bitmap || AndroidBitmap_getInfo(env, bitmap, &info) != ANDROID_BITMAP_RESULT_SUCCESS ||
            info.format != ANDROID_BITMAP_FORMAT_RGBA_8888 ||
            AndroidBitmap_lockPixels(env, bitmap, &pixels) != ANDROID_BITMAP_RESULT_SUCCESS) goto done;
    int start_x = left > canvas->left ? left : canvas->left;
    int start_y = top > canvas->top ? top : canvas->top;
    int end_x = left + (int)info.width < canvas->right ? left + (int)info.width : canvas->right;
    int end_y = top + (int)info.height < canvas->bottom ? top + (int)info.height : canvas->bottom;
    unsigned color_alpha = paint->color >> 24;
    unsigned red = (paint->color >> 19) & 31;
    unsigned green = (paint->color >> 10) & 63;
    unsigned blue = (paint->color >> 3) & 31;
    for (int row = start_y; row < end_y; ++row) {
        const uint8_t *src = (const uint8_t *)pixels + (row - top) * info.stride + (start_x - left) * 4;
        uint16_t *dst = (uint16_t *)((uint8_t *)canvas->bitmap.pixels + row * canvas->bitmap.row_bytes) + start_x;
        for (int col = start_x; col < end_x; ++col, src += 4, ++dst) {
            unsigned alpha = (src[3] * color_alpha + 127) / 255;
            if (!alpha) continue;
            unsigned old = *dst, inverse = 255 - alpha;
            unsigned r = (red * alpha + (old >> 11) * inverse + 127) / 255;
            unsigned g = (green * alpha + ((old >> 5) & 63) * inverse + 127) / 255;
            unsigned b = (blue * alpha + (old & 31) * inverse + 127) / 255;
            *dst = (uint16_t)((r << 11) | (g << 5) | b);
        }
    }
    AndroidBitmap_unlockPixels(env, bitmap);
done:
    clear_exception(env);
    if (bitmap) (*env)->DeleteLocalRef(env, bitmap);
    (*env)->DeleteLocalRef(env, glyph);
}

void sk_canvas_draw_text(void *self, const void *text, uint32_t length, float x, float y, const void *paint_arg) {
    Canvas *canvas = self;
    if (!text || !length || !canvas->bitmap.pixels || canvas->bitmap.config != kRGB_565_Config ||
            canvas->right <= canvas->left || canvas->bottom <= canvas->top) return;
    JNIEnv *env = get_env();
    if (!env) return;
    DrawText draw = {canvas, (Paint *)paint_arg, text, length, x, y};
    run_on_host(env, draw_text_host, &draw);
}
