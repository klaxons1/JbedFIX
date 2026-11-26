#include "display.h"

#include <android/bitmap.h>
#include <android/log.h>
#include <android/native_window_jni.h>
#include <algorithm>
#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <limits>
#include <mutex>
#include <new>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

extern "C" {
#include "android_jni.h"
#include "android_methods.h"
}

namespace {
constexpr char log_tag[] = "jbed.graphics";
enum { FONT_SANS_SERIF, FONT_MONOSPACE, FONT_SERIF };
enum { FONT_TOP, FONT_ASCENT, FONT_DESCENT, FONT_BOTTOM, FONT_LEADING, FONT_METRIC_COUNT };
JavaVM *java_vm;
jclass graphics_class;
jmethodID create_font, measure_font, rasterize_font, get_font_size;
jfieldID font_metrics, glyph_bitmap, glyph_left, glyph_top;

JNIEnv *current_env()
{
    JNIEnv *env = nullptr;
    return java_vm && java_vm->GetEnv(reinterpret_cast<void **>(&env), JNI_VERSION_1_6) == JNI_OK
               ? env : nullptr;
}

bool font_exception(JNIEnv *env)
{
    if (!env->ExceptionCheck()) return false;
    env->ExceptionDescribe();
    env->ExceptionClear();
    __android_log_print(ANDROID_LOG_ERROR, log_tag, "Android font operation failed");
    return true;
}
}

struct JbedTargetFont {
    jobject object;
    float metrics[FONT_METRIC_COUNT];
};

extern "C" int android_lcdui_getFontSize(void)
{
    JNIEnv *env = current_env();
    return env ? env->CallStaticIntMethod(graphics_class, get_font_size) : 0;
}

extern "C" JbedTargetFont *JbedGFX_createTargFont(int face, int style, int pixels)
{
    JNIEnv *env = current_env();
    if (!env) return nullptr;
    int family = face == MIDP_FONT_FACE_MONOSPACE ? FONT_MONOSPACE :
                 face == MIDP_FONT_FACE_PROPORTIONAL ? FONT_SERIF : FONT_SANS_SERIF;
    jobject object = env->CallStaticObjectMethod(graphics_class, create_font,
        family, (style & MIDP_FONT_STYLE_BOLD) ? 1 : 0, float(pixels),
        (style & MIDP_FONT_STYLE_ITALIC) ? -0.3f : 0.0f,
        jboolean((style & MIDP_FONT_STYLE_UNDERLINED) != 0), JNI_TRUE);
    if (font_exception(env) || !object) return nullptr;
    auto *font = new (std::nothrow) JbedTargetFont{};
    if (font) {
        font->object = env->NewGlobalRef(object);
        auto metrics = static_cast<jfloatArray>(env->GetObjectField(object, font_metrics));
        if (metrics) {
            env->GetFloatArrayRegion(metrics, 0, FONT_METRIC_COUNT, font->metrics);
            env->DeleteLocalRef(metrics);
        }
        if (font_exception(env) || !font->object || !metrics) {
            if (font->object) env->DeleteGlobalRef(font->object);
            delete font;
            font = nullptr;
        }
    }
    env->DeleteLocalRef(object);
    return font;
}

extern "C" void JbedGFX_releaseTargFont(JbedTargetFont *font)
{
    if (!font) return;
    if (JNIEnv *env = current_env()) env->DeleteGlobalRef(font->object);
    delete font;
}

extern "C" int JbedGFX_getFontInfo(const JbedTargetFont *font, int *ascent, int *descent, int *leading)
{
    if (!font) {
        *ascent = *descent = *leading = 0;
        return -1;
    }
    *ascent = std::abs(int(font->metrics[FONT_ASCENT]));
    *descent = std::abs(int(font->metrics[FONT_DESCENT]));
    *leading = int(font->metrics[FONT_LEADING]);
    return *leading;
}

extern "C" unsigned JbedGFX_charsWidth(const JbedTargetFont *font, const uint16_t *chars, int count)
{
    JNIEnv *env = current_env();
    if (!font || !env) return std::numeric_limits<unsigned>::max();
    if (!chars || count <= 0) return 0;
    jstring text = env->NewString(chars, count);
    if (!text) { font_exception(env); return 0; }
    float width = env->CallFloatMethod(font->object, measure_font, text);
    env->DeleteLocalRef(text);
    if (font_exception(env) || !(width > 0)) return 0;
    if (width >= float(std::numeric_limits<unsigned>::max()))
        return std::numeric_limits<unsigned>::max();
    return unsigned(width);
}

extern "C" void JbedGFX_drawChars(const JbedFontTarget *target, JbedTargetFont *font,
                                   const uint16_t *chars, int count, int x, int baseline)
{
    JNIEnv *env = current_env();
    if (!font || !env || !chars || count <= 0 || !target->pixels) return;
    int clip_left = std::max(0, target->clip[0]);
    int clip_top = std::max(0, target->clip[1]);
    int clip_right = std::min(target->width, target->clip[2]);
    int clip_bottom = std::min(target->height, target->clip[3]);
    if (clip_left >= clip_right || clip_top >= clip_bottom) return;
    jstring text = env->NewString(chars, count);
    if (!text) { font_exception(env); return; }
    jobject glyph = env->CallObjectMethod(font->object, rasterize_font, text,
        clip_left - x, clip_top - baseline, clip_right - x, clip_bottom - baseline);
    env->DeleteLocalRef(text);
    if (font_exception(env) || !glyph) return;
    jobject bitmap = env->GetObjectField(glyph, glyph_bitmap);
    int left = x + env->GetIntField(glyph, glyph_left);
    int top = baseline + env->GetIntField(glyph, glyph_top);
    AndroidBitmapInfo info{};
    void *pixels;
    if (bitmap && AndroidBitmap_getInfo(env, bitmap, &info) == ANDROID_BITMAP_RESULT_SUCCESS &&
        info.format == ANDROID_BITMAP_FORMAT_RGBA_8888 &&
        AndroidBitmap_lockPixels(env, bitmap, &pixels) == ANDROID_BITMAP_RESULT_SUCCESS) {
        int start_x = std::max(left, clip_left), start_y = std::max(top, clip_top);
        int end_x = std::min(left + int(info.width), clip_right);
        int end_y = std::min(top + int(info.height), clip_bottom);
        unsigned color_alpha = target->argb >> 24;
        unsigned red = (target->argb >> 19) & 31;
        unsigned green = (target->argb >> 10) & 63;
        unsigned blue = (target->argb >> 3) & 31;
        for (int row = start_y; row < end_y; ++row) {
            const auto *src = static_cast<const uint8_t *>(pixels) +
                             (row - top) * info.stride + (start_x - left) * 4;
            auto *dst = reinterpret_cast<uint16_t *>(reinterpret_cast<uint8_t *>(target->pixels) +
                                                    row * target->stride) + start_x;
            for (int col = start_x; col < end_x; ++col, src += 4, ++dst) {
                unsigned alpha = (src[3] * color_alpha + 127) / 255;
                if (!alpha) continue;
                unsigned old = *dst, inverse = 255 - alpha;
                unsigned r = (red * alpha + (old >> 11) * inverse + 127) / 255;
                unsigned g = (green * alpha + ((old >> 5) & 63) * inverse + 127) / 255;
                unsigned b = (blue * alpha + (old & 31) * inverse + 127) / 255;
                *dst = uint16_t((r << 11) | (g << 5) | b);
            }
        }
        AndroidBitmap_unlockPixels(env, bitmap);
    }
    font_exception(env);
    if (bitmap) env->DeleteLocalRef(bitmap);
    env->DeleteLocalRef(glyph);
}

namespace {
std::mutex view_mutex;
ANativeWindow *window;
char *framebuffer_path;
const uint16_t *framebuffer;
size_t framebuffer_size;
int frame_width, frame_height;

void unmap_framebuffer()
{
    if (framebuffer) munmap(const_cast<uint16_t *>(framebuffer), framebuffer_size);
    framebuffer = nullptr;
    framebuffer_size = 0;
}

void release_surface()
{
    if (window) ANativeWindow_release(window);
    window = nullptr;
    unmap_framebuffer();
    std::free(framebuffer_path);
    framebuffer_path = nullptr;
    frame_width = frame_height = 0;
}

int set_geometry(int width, int height)
{
    int result = ANativeWindow_setBuffersGeometry(window, width, height, WINDOW_FORMAT_RGB_565);
    if (result < 0)
        result = ANativeWindow_setBuffersGeometry(window, width, height, WINDOW_FORMAT_RGBA_8888);
    if (result < 0) return result;
    frame_width = width;
    frame_height = height;
    return 0;
}

int map_framebuffer(size_t required)
{
    if (framebuffer && framebuffer_size >= required) return 0;
    if (!framebuffer_path) return -ENOENT;
    unmap_framebuffer();
    int fd = open(framebuffer_path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    struct stat st;
    if (fstat(fd, &st) < 0 || st.st_size < 0 || uint64_t(st.st_size) < required) {
        close(fd);
        return -EIO;
    }
    void *mapped = mmap(nullptr, size_t(st.st_size), PROT_READ, MAP_SHARED, fd, 0);
    int error = errno;
    close(fd);
    if (mapped == MAP_FAILED) return -error;
    framebuffer = static_cast<uint16_t *>(mapped);
    framebuffer_size = size_t(st.st_size);
    return 0;
}

void attach_surface(JNIEnv *env, jclass, jobject surface, jstring path, jint width, jint height)
{
    ANativeWindow *next = ANativeWindow_fromSurface(env, surface);
    const char *text = path ? env->GetStringUTFChars(path, nullptr) : nullptr;
    char *next_path = text ? strdup(text) : nullptr;
    if (text) env->ReleaseStringUTFChars(path, text);
    std::lock_guard<std::mutex> lock(view_mutex);
    release_surface();
    window = next;
    framebuffer_path = next_path;
    if (window && width > 0 && height > 0) set_geometry(width, height);
}

void detach_surface(JNIEnv *, jclass)
{
    std::lock_guard<std::mutex> lock(view_mutex);
    release_surface();
}

int repaint(int width, int height, int stride)
{
    std::lock_guard<std::mutex> lock(view_mutex);
    if (!window) return -ENODEV;
    if (width <= 0 || height <= 0) { width = frame_width; height = frame_height; }
    if (stride <= 0) stride = width;
    if (width <= 0 || height <= 0 || stride < width ||
        uint64_t(stride) * height > SIZE_MAX / sizeof(uint16_t)) return -EINVAL;
    if (width != frame_width || height != frame_height) {
        int error = set_geometry(width, height);
        if (error < 0) return error;
    }
    int result = map_framebuffer(size_t(stride) * height * sizeof(uint16_t));
    if (result < 0) return result;
    ANativeWindow_Buffer buffer;
    result = ANativeWindow_lock(window, &buffer, nullptr);
    if (result < 0) return result;
    int copy_width = std::min(width, buffer.width), copy_height = std::min(height, buffer.height);
    if (buffer.format == WINDOW_FORMAT_RGB_565) {
        for (int y = 0; y < copy_height; ++y)
            std::memcpy(static_cast<uint16_t *>(buffer.bits) + y * buffer.stride,
                        framebuffer + y * stride, size_t(copy_width) * sizeof(uint16_t));
    } else if (buffer.format == WINDOW_FORMAT_RGBA_8888 || buffer.format == WINDOW_FORMAT_RGBX_8888) {
        for (int y = 0; y < copy_height; ++y) {
            const uint16_t *src = framebuffer + y * stride;
            auto *dst = static_cast<uint32_t *>(buffer.bits) + y * buffer.stride;
            for (int x = 0; x < copy_width; ++x) {
                uint32_t c = src[x];
                uint32_t r = (c >> 11) * 255 / 31, g = ((c >> 5) & 63) * 255 / 63;
                uint32_t b = (c & 31) * 255 / 31;
                dst[x] = 0xff000000u | (b << 16) | (g << 8) | r;
            }
        }
    } else {
        result = -EINVAL;
    }
    int posted = ANativeWindow_unlockAndPost(window);
    return result < 0 ? result : posted;
}

void repaint_surface(JNIEnv *, jclass, jint width, jint height, jint stride)
{
    int error = repaint(width, height, stride);
    if (error < 0 && error != -ENODEV)
        __android_log_print(ANDROID_LOG_ERROR, log_tag, "Surface presentation failed: %d", error);
}
}

extern "C" int jbed_android_graphics_initialize(JNIEnv *env)
{
    if (env->GetJavaVM(&java_vm) != JNI_OK) return 0;
    jclass local = env->FindClass("org/jbed/source/JbedGraphics");
    if (!local) return 0;
    graphics_class = static_cast<jclass>(env->NewGlobalRef(local));
    env->DeleteLocalRef(local);
    jclass font_class = env->FindClass("org/jbed/source/JbedGraphics$Font");
    jclass glyph_class = env->FindClass("org/jbed/source/JbedGraphics$Glyph");
    if (!graphics_class || !font_class || !glyph_class) return 0;
    create_font = env->GetStaticMethodID(graphics_class, "createFont",
        "(IIFFZZ)Lorg/jbed/source/JbedGraphics$Font;");
    get_font_size = env->GetStaticMethodID(graphics_class, "getFontSize", "()I");
    measure_font = env->GetMethodID(font_class, "measure", "(Ljava/lang/String;)F");
    rasterize_font = env->GetMethodID(font_class, "rasterize",
        "(Ljava/lang/String;IIII)Lorg/jbed/source/JbedGraphics$Glyph;");
    font_metrics = env->GetFieldID(font_class, "metrics", "[F");
    glyph_bitmap = env->GetFieldID(glyph_class, "bitmap", "Landroid/graphics/Bitmap;");
    glyph_left = env->GetFieldID(glyph_class, "left", "I");
    glyph_top = env->GetFieldID(glyph_class, "top", "I");
    env->DeleteLocalRef(font_class);
    env->DeleteLocalRef(glyph_class);
    if (env->ExceptionCheck() || !create_font || !get_font_size || !measure_font || !rasterize_font ||
        !font_metrics || !glyph_bitmap || !glyph_left || !glyph_top) return 0;
    const JNINativeMethod methods[] = {
        {"attach", "(Landroid/view/Surface;Ljava/lang/String;II)V", reinterpret_cast<void *>(attach_surface)},
        {"detach", "()V", reinterpret_cast<void *>(detach_surface)},
        {"repaint", "(III)V", reinterpret_cast<void *>(repaint_surface)}
    };
    if (env->RegisterNatives(graphics_class, methods, sizeof(methods) / sizeof(*methods)) != JNI_OK)
        return 0;
    InitializeWindowSystem();
    return 1;
}

extern "C" void Java_android_jbed_app_JbedView_nativeInitializeAppView(JNIEnv *env, jobject,
                                                                       jobject surface)
{
    jstring path = env->NewStringUTF(JBED_FRAMEBUFFER_PATH);
    if (!path) return;
    ANativeWindow *native = ANativeWindow_fromSurface(env, surface);
    if (native) {
        int width = ANativeWindow_getWidth(native), height = ANativeWindow_getHeight(native);
        ANativeWindow_release(native);
        attach_surface(env, nullptr, surface, path, width, height);
    }
    env->DeleteLocalRef(path);
}

extern "C" void Java_android_jbed_app_JbedView_nativeFinalizeAppView(JNIEnv *env, jobject, jobject)
{
    detach_surface(env, nullptr);
}

extern "C" void Java_android_jbed_app_JbedView_nativeRepaint(JNIEnv *env, jobject, jint, jint,
    jint, jint, jint width, jint height, jfloat, jfloat)
{
    repaint_surface(env, nullptr, width, height, width);
}
