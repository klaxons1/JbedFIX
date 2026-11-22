/* Legacy Surface imports and the public ANativeWindow presentation bridge. */
#include <android/log.h>
#include <android/native_window_jni.h>
#include <errno.h>
#include <fcntl.h>
#include <jni.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct {
    int32_t w, h, stride, usage, format;
    void *bits;
} LegacySurfaceInfo;

static pthread_mutex_t surface_mutex = PTHREAD_MUTEX_INITIALIZER;
static ANativeWindow *window;
static char *framebuffer_path;
static const uint16_t *framebuffer;
static size_t framebuffer_size;
static int frame_width, frame_height;
static int reported_error;
static ANativeWindow_Buffer locked_buffer;

static void unmap_framebuffer(void) {
    if (framebuffer) munmap((void *)framebuffer, framebuffer_size);
    framebuffer = NULL;
    framebuffer_size = 0;
}

static void release_surface(void) {
    if (window) ANativeWindow_release(window);
    window = NULL;
    unmap_framebuffer();
    free(framebuffer_path);
    framebuffer_path = NULL;
    frame_width = frame_height = 0;
    reported_error = 0;
}

static void report_error(const char *operation, int error) {
    if (!error) error = -EIO;
    if (reported_error != error)
        __android_log_print(ANDROID_LOG_ERROR, "jbed_graphics", "%s failed: %d", operation, error);
    reported_error = error;
}

static int set_geometry(int width, int height) {
    int status = ANativeWindow_setBuffersGeometry(window, width, height, WINDOW_FORMAT_RGB_565);
    if (status < 0)
        status = ANativeWindow_setBuffersGeometry(window, width, height, WINDOW_FORMAT_RGBA_8888);
    if (status < 0) {
        report_error("Surface geometry", status);
        return status;
    }
    frame_width = width;
    frame_height = height;
    return 0;
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_app_JbedGraphics_attach(JNIEnv *env, jclass clazz,
        jobject surface, jstring path, jint width, jint height) {
    (void)clazz;
    pthread_mutex_lock(&surface_mutex);
    release_surface();
    window = ANativeWindow_fromSurface(env, surface);
    const char *chars = (*env)->GetStringUTFChars(env, path, NULL);
    if (chars) {
        framebuffer_path = strdup(chars);
        (*env)->ReleaseStringUTFChars(env, path, chars);
    }
    if (window && width > 0 && height > 0) set_geometry(width, height);
    pthread_mutex_unlock(&surface_mutex);
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_app_JbedGraphics_detach(JNIEnv *env, jclass clazz) {
    (void)env; (void)clazz;
    pthread_mutex_lock(&surface_mutex);
    release_surface();
    pthread_mutex_unlock(&surface_mutex);
}

static int map_framebuffer(size_t required) {
    if (framebuffer && framebuffer_size >= required) return 0;
    if (!framebuffer_path) return -1;
    unmap_framebuffer();
    int fd = open(framebuffer_path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    struct stat st;
    if (fstat(fd, &st) < 0 || st.st_size < 0 || (uint64_t)st.st_size < required) {
        close(fd);
        return -EIO;
    }
    void *mapped = mmap(NULL, (size_t)st.st_size, PROT_READ, MAP_SHARED, fd, 0);
    close(fd);
    if (mapped == MAP_FAILED) return -errno;
    framebuffer = mapped;
    framebuffer_size = (size_t)st.st_size;
    return 0;
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_app_JbedGraphics_repaint(JNIEnv *env, jclass clazz,
        jint width, jint height, jint stride) {
    (void)env; (void)clazz;
    pthread_mutex_lock(&surface_mutex);
    if (!window) goto done;
    if (width <= 0 || height <= 0) {
        width = frame_width;
        height = frame_height;
    }
    if (stride <= 0) stride = width;
    if (width <= 0 || height <= 0 || stride < width ||
            (uint64_t)stride * height > SIZE_MAX / sizeof(uint16_t)) goto done;
    if ((width != frame_width || height != frame_height) && set_geometry(width, height) < 0)
        goto done;
    int status = map_framebuffer((size_t)stride * height * sizeof(uint16_t));
    if (status < 0) {
        report_error("Framebuffer mapping", status);
        goto done;
    }

    ANativeWindow_Buffer buffer;
    status = ANativeWindow_lock(window, &buffer, NULL);
    if (status < 0) {
        report_error("Surface lock", status);
        goto done;
    }
    int copy_width = width < buffer.width ? width : buffer.width;
    int copy_height = height < buffer.height ? height : buffer.height;
    if (buffer.format == WINDOW_FORMAT_RGB_565) {
        for (int y = 0; y < copy_height; ++y)
            memcpy((uint16_t *)buffer.bits + y * buffer.stride,
                   framebuffer + y * stride, (size_t)copy_width * sizeof(uint16_t));
    } else if (buffer.format == WINDOW_FORMAT_RGBA_8888 || buffer.format == WINDOW_FORMAT_RGBX_8888) {
        for (int y = 0; y < copy_height; ++y) {
            const uint16_t *src = framebuffer + y * stride;
            uint32_t *dst = (uint32_t *)buffer.bits + y * buffer.stride;
            for (int x = 0; x < copy_width; ++x) {
                uint32_t c = src[x];
                uint32_t r = (c >> 11) * 255 / 31;
                uint32_t g = ((c >> 5) & 63) * 255 / 63;
                uint32_t b = (c & 31) * 255 / 31;
                dst[x] = 0xff000000u | (b << 16) | (g << 8) | r;
            }
        }
    }
    status = ANativeWindow_unlockAndPost(window);
    if (status < 0) report_error("Surface presentation", status);
    else reported_error = 0;
done:
    pthread_mutex_unlock(&surface_mutex);
}

/* Kept for the original DSO's imports. JbedView uses the JNI bridge above,
 * which obtains the Surface through ANativeWindow_fromSurface. */
int surface_lock_region(void *surface, LegacySurfaceInfo *info, void *region, int dirty)
    asm("_ZN7android7Surface4lockEPNS0_11SurfaceInfoEPNS_6RegionEb");
int surface_lock_region(void *surface, LegacySurfaceInfo *info, void *region, int dirty) {
    (void)surface; (void)region; (void)dirty;
    if (!window || !info) return -ENODEV;
    int status = ANativeWindow_lock(window, &locked_buffer, NULL);
    if (status < 0) return status;
    info->w = locked_buffer.width;
    info->h = locked_buffer.height;
    info->stride = locked_buffer.stride;
    info->usage = 0;
    info->format = locked_buffer.format;
    info->bits = locked_buffer.bits;
    return 0;
}

int surface_lock(void *surface, LegacySurfaceInfo *info, int dirty)
    asm("_ZN7android7Surface4lockEPNS0_11SurfaceInfoEb");
int surface_lock(void *surface, LegacySurfaceInfo *info, int dirty) {
    return surface_lock_region(surface, info, NULL, dirty);
}

int surface_unlock_and_post(void *surface) asm("_ZN7android7Surface13unlockAndPostEv");
int surface_unlock_and_post(void *surface) {
    (void)surface;
    return window ? ANativeWindow_unlockAndPost(window) : -ENODEV;
}
