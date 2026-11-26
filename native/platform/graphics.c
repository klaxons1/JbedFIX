#include "graphics.h"
#include "display.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>

extern void Jbni_intern_raiseCommonException(int);
JbedBitmap *currentScreenBitmap, *screenBitmap;

/* Inclusive dirty bounds, zero-initialized with the original BSS. */
static int dirty_left, dirty_top, dirty_right, dirty_bottom;
static int min(int a, int b)
{
    return a < b ? a : b;
}
static int max(int a, int b)
{
    return a > b ? a : b;
}

JbedBitmap *getActiveScreenBitmap(void)
{
    return currentScreenBitmap;
}

void RB_regionIsDirty(int x1, int y1, int x2, int y2)
{
    dirty_left = min(dirty_left, x1);
    dirty_right = max(dirty_right, x2);
    dirty_top = min(dirty_top, y1);
    dirty_bottom = max(dirty_bottom, y2);
}

void LCDUIrefresh(int x1, int y1, int x2, int y2)
{
    JbedBitmap *b = getActiveScreenBitmap();
    if (dirty_left == INT_MAX || !b)
        return;
    int xmax = (int)b->width - 1, ymax = (int)b->height - 1;
    dirty_left = max(0, min(dirty_left, xmax));
    dirty_right = max(0, min(dirty_right, xmax));
    dirty_top = max(0, min(dirty_top, ymax));
    dirty_bottom = max(0, min(dirty_bottom, ymax));
    x1 = max(x1, dirty_left);
    x2 = min(x2, dirty_right);
    y1 = max(y1, dirty_top);
    y2 = min(y2, dirty_bottom);
    refreshPaintWindow(x1, y1, x2 + 1, y2 + 1);
    if (x1 <= dirty_left && y1 <= dirty_top && x2 >= dirty_right && y2 >= dirty_bottom) {
        dirty_left = dirty_top = INT_MAX;
        dirty_right = dirty_bottom = INT_MIN;
    }
}

void GUI_checkPostponedRefresh(void)
{
    LCDUIrefresh(0, 0, screenBitmap->width, screenBitmap->height);
}

int LCDUIgetKeyCode(int action)
{
    static const int keys[110] = {[1] = -1,   [2] = -3,    [5] = -4,   [6] = -2,   [8] = -5,
                                  [9] = '1',  [10] = '3',  [11] = '7', [12] = '9', [100] = -1,
                                  [101] = -2, [102] = -3,  [103] = -4, [104] = -5, [105] = -6,
                                  [106] = -7, [107] = -11, [108] = -8, [109] = -10};
    return (unsigned)action < 110 ? keys[action] : 0;
}

int LCDUIgetGameAction(int key)
{
    static const int8_t special[] = {0, 0, 0, -1, 0, 0, 0, 8, 5, 2, 6, 1};
    static const int8_t digits[] = {0, 9, 1, 10, 2, 8, 5, 11, 6, 12};
    if (key >= -12 && key < 0)
        return special[key + 12];
    if (key >= '0' && key <= '9')
        return digits[key - '0'];
    return key == '#' || key == '*' ? 0 : -1;
}

const char *LCDUIgetKeyName(int key)
{
    static const char *const special[] = {"Power", "End",    "SEND",  NULL,   "Clear", "Soft2",
                                          "Soft1", "Select", "Right", "Left", "Down",  "Up"};
    static const char digits[][2] = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
    if (key >= -12 && key < 0)
        return special[key + 12];
    if (key >= '0' && key <= '9')
        return digits[key - '0'];
    if (key == '#')
        return "#";
    if (key == '*')
        return "*";
    return key == -82 ? "Back" : NULL;
}

static JbedBitmap *target(const JbedGraphics *g)
{
    return g->bitmap ? g->bitmap : getActiveScreenBitmap();
}

static uint16_t *pixel(const JbedBitmap *b, int x, int y)
{
    return jbed_bitmap_row(b, (unsigned)y) + x;
}

static void dirty(const JbedGraphics *g, int x1, int y1, int x2, int y2)
{
    if (!g->bitmap)
        RB_regionIsDirty(x1, y1, x2, y2);
}

static int inside(const JbedGraphics *g, int x, int y)
{
    return x >= g->clip_x && x < g->clip_right && y >= g->clip_y && y < g->clip_bottom;
}

static int dash(int *phase)
{
    int old = *phase;
    *phase = old < -2 ? 3 : old - 1;
    return old >= 0;
}

static void fill_pixels(uint16_t *dst, int count, uint16_t color)
{
    for (int i = 0; i < count; ++i)
        dst[i] = color;
}

static void span(const JbedGraphics *g, JbedBitmap *b, int x1, int x2, int y, int *phase)
{
    if (y < g->clip_y || y >= g->clip_bottom)
        return;
    int first = max(min(x1, x2), g->clip_x), last = min(max(x1, x2), g->clip_right - 1);
    if (first > last)
        return;
    uint16_t *dst = pixel(b, first, y);
    if (!phase) {
        fill_pixels(dst, last - first + 1, (uint16_t)g->pixel);
        return;
    }
    for (int x = first; x <= last; ++x, ++dst) {
        if (dash(phase))
            *dst = (uint16_t)g->pixel;
    }
}

void LCDUIfillRect(JbedGraphics *g, int x, int y, int w, int h)
{
    if (w <= 0 || h <= 0)
        return;
    JbedBitmap *b = target(g);
    if (x < g->clip_x) {
        w += x - g->clip_x;
        x = g->clip_x;
    }
    if (y < g->clip_y) {
        h += y - g->clip_y;
        y = g->clip_y;
    }
    w = min(w, g->clip_right - x);
    h = min(h, g->clip_bottom - y);
    if (w <= 0 || h <= 0)
        return;
    for (int i = 0; i < h; ++i)
        fill_pixels(pixel(b, x, y + i), w, (uint16_t)g->pixel);
    dirty(g, x, y, x + w - 1, y + h - 1);
}

void LCDUIdrawLine(JbedGraphics *g, int x1, int y1, int x2, int y2)
{
    int phase = 3;
    JbedBitmap *b = target(g);
    if (y1 == y2) {
        if (y1 < g->clip_y || y1 >= g->clip_bottom || max(x1, x2) < g->clip_x ||
            min(x1, x2) >= g->clip_right)
            return;
        span(g, b, x1, x2, y1, g->stroke ? &phase : NULL);
        dirty(g, min(x1, x2), y1, max(x1, x2), y1);
        return;
    }
    if (x1 == x2) {
        int first = max(min(y1, y2), g->clip_y), last = min(max(y1, y2), g->clip_bottom - 1);
        if (x1 < g->clip_x || x1 >= g->clip_right || first > last)
            return;
        for (int y = first; y <= last; ++y)
            if (!g->stroke || dash(&phase))
                *pixel(b, x1, y) = g->pixel;
        dirty(g, x1, first, x1, last);
        return;
    }
    int steep = abs(y2 - y1) >= abs(x2 - x1);
    int a = steep ? y1 : x1, end = steep ? y2 : x2;
    int z = steep ? x1 : y1, z_end = steep ? x2 : y2;
    if (a > end) {
        int tmp = a;
        a = end;
        end = tmp;
        tmp = z;
        z = z_end;
        z_end = tmp;
    }
    int low = steep ? g->clip_y : g->clip_x, high = steep ? g->clip_bottom : g->clip_right;
    int lower_z = steep ? g->clip_x : g->clip_y, upper_z = steep ? g->clip_right : g->clip_bottom;
    if (a >= high || end < low || min(z, z_end) >= upper_z || max(z, z_end) < lower_z)
        return;
    int major = end - a, minor = abs(z_end - z), step = z < z_end ? 1 : -1;
    int error = major;
    for (; a <= min(end, high - 1); ++a) {
        if (a >= low && z >= lower_z && z < upper_z) {
            /* The diagonal path decrements before checking its dash phase. */
            if (!g->stroke || --phase >= 0)
                *pixel(b, steep ? z : a, steep ? a : z) = g->pixel;
            else if (phase < -2)
                phase = 3;
        }
        error -= 2 * minor;
        if (error < 0) {
            error += 2 * major;
            z += step;
        }
    }
    dirty(g, min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2));
}

void LCDUIdrawRect(JbedGraphics *g, int x, int y, int w, int h)
{
    if (w < 0 || h < 0)
        return;
    if (!w || !h) {
        LCDUIdrawLine(g, x, y, x + w, y + h);
        return;
    }
    if ((w == 1 || h == 1) && (!g->stroke || (w == 1 && h == 1))) {
        LCDUIfillRect(g, x, y, w + 1, h + 1);
        return;
    }
    LCDUIdrawLine(g, x, y, x + w, y);
    LCDUIdrawLine(g, x + w, y, x + w, y + h);
    LCDUIdrawLine(g, x + w, y + h, x, y + h);
    LCDUIdrawLine(g, x, y + h, x, y);
}

typedef struct {
    int x, y;
} Point;
typedef struct {
    int x, error, twice_dy, correction, slope;
} Edge;

static Edge edge(Point a, Point b, bool left)
{
    Edge e = {.x = a.x};
    int dy = b.y - a.y;
    if (!dy)
        return e;
    int dx = b.x - a.x, slope = dx / dy, rest = dx % dy;
    if (rest > 0) {
        ++slope;
        rest -= dy;
    }
    e.slope = slope;
    e.error = dy;
    e.twice_dy = 2 * dy;
    e.correction = -2 * rest;
    e.x += (left ? -1 : 1) * abs(slope / 2);
    return e;
}

static void advance_edge(Edge *e)
{
    e->x += e->slope;
    e->error -= e->correction;
    if (e->error < 0) {
        --e->x;
        e->error += e->twice_dy;
    }
}

void LCDUIfillTriangle(JbedGraphics *g, int x1, int y1, int x2, int y2, int x3, int y3)
{
    Point a = {x1, y1}, b = {x2, y2}, c = {x3, y3}, tmp;
    if (a.y >= b.y) {
        tmp = a;
        a = b;
        b = tmp;
    }
    if (b.y >= c.y) {
        tmp = b;
        b = c;
        c = tmp;
    }
    if (a.y >= b.y) {
        tmp = a;
        a = b;
        b = tmp;
    }
    int first = max(min(a.x, min(b.x, c.x)), g->clip_x);
    int last = min(max(a.x, max(b.x, c.x)), g->clip_right - 1);
    if (first > last || a.y >= g->clip_bottom || c.y < g->clip_y)
        return;
    JbedBitmap *bmp = target(g);
    Edge left, right;
    bool split_left = false;
    if (a.y == b.y) {
        if (a.x > b.x) {
            tmp = a;
            a = b;
            b = tmp;
        }
        if (a.y == c.y) {
            a.x = first;
            b.x = last;
        }
        left = edge(a, c, true);
        right = edge(b, c, false);
    } else {
        int32_t long_side = (int32_t)(((uint32_t)b.y - a.y) * ((uint32_t)c.x - a.x));
        int32_t short_side = (int32_t)(((uint32_t)c.y - a.y) * ((uint32_t)b.x - a.x));
        split_left = long_side >= short_side;
        left = edge(a, split_left ? b : c, true);
        right = edge(a, split_left ? c : b, false);
    }
    int xmin = first, xmax = last;
    for (int y = a.y; y <= c.y && y < g->clip_bottom; ++y) {
        if (y == b.y && a.y != b.y && b.y != c.y) {
            if (split_left) {
                left = edge(b, c, true);
                if (b.x < c.x)
                    xmin = max(xmin, b.x);
            } else {
                right = edge(b, c, false);
                if (b.x > c.x)
                    xmax = min(xmax, b.x);
            }
        }
        int start = max(xmin, left.x), end = min(xmax, right.x);
        if (start <= end && y >= g->clip_y)
            fill_pixels(pixel(bmp, start, y), end - start + 1, (uint16_t)g->pixel);
        advance_edge(&left);
        advance_edge(&right);
    }
    dirty(g, first, max(a.y, g->clip_y), last, min(c.y, g->clip_bottom));
}

static void anchor_position(int *x, int *y, int w, int h, int anchor)
{
    switch (anchor & (LCDUI_LEFT | LCDUI_RIGHT | LCDUI_HCENTER)) {
    case LCDUI_HCENTER:
        *x -= w / 2;
        break;
    case LCDUI_RIGHT:
        *x -= w;
        break;
    }
    switch (anchor & (LCDUI_TOP | LCDUI_BOTTOM | LCDUI_VCENTER)) {
    case LCDUI_VCENTER:
        *y -= h / 2;
        break;
    case LCDUI_BOTTOM:
        *y -= h;
        break;
    }
}

static uint16_t blend565(uint16_t src, uint16_t dst, unsigned alpha)
{
    const uint32_t mask = 0x07e0f81f;
    uint32_t d = (dst | ((uint32_t)dst << 16)) & mask;
    uint32_t s = (src | ((uint32_t)src << 16)) & mask;
    uint32_t mixed = (d + (((alpha >> 3) * (s - d)) >> 5)) & mask;
    return (uint16_t)(mixed | (mixed >> 16));
}

void LCDUIdrawRGB(JbedGraphics *g, const JbArray *array, int offset, int stride, int x, int y,
                  int w, int h, int process_alpha)
{
    int n = array->length;
    int64_t final = (int64_t)offset + (int64_t)stride * (h - 1LL);
    if (w < 0 || h < 0 || offset < 0 || offset >= n || final < 0 || final + w > n ||
        n < (int64_t)offset + w || stride > n || stride < -(int64_t)n) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ARRAY_BOUNDS);
        return;
    }
    int x1 = max(x, g->clip_x), y1 = max(y, g->clip_y);
    int x2 = min(x + w, g->clip_right), y2 = min(y + h, g->clip_bottom);
    if (x2 <= x1 || y2 <= y1)
        return;
    JbedBitmap *dst = target(g);
    for (int row = y1; row < y2; ++row) {
        const uint32_t *src = array->data + offset + (ptrdiff_t)(row - y) * stride + (x1 - x);
        uint16_t *out = pixel(dst, x1, row);
        for (int col = x1; col < x2; ++col, ++src, ++out) {
            uint32_t rgb = *src;
            unsigned alpha = rgb >> 24;
            uint16_t c =
                (uint16_t)(((rgb >> 8) & 0xf800) | ((rgb >> 5) & 0x7e0) | ((rgb >> 3) & 31));
            if (!process_alpha || alpha >= 248)
                *out = c;
            else if (alpha >= 8)
                *out = blend565(c, *out, alpha);
        }
    }
    dirty(g, x1, y1, x2 - 1, y2 - 1);
}

static bool valid_region(const JbedBitmap *b, int x, int y, int w, int h)
{
    return x >= 0 && y >= 0 && w >= 0 && h >= 0 && (int64_t)x + w <= b->width &&
           (int64_t)y + h <= b->height;
}

void LCDUIcopyArea(JbedGraphics *g, int sx, int sy, int w, int h, int x, int y, int anchor)
{
    JbedBitmap *b = g->bitmap;
    if (!b || !valid_region(b, sx, sy, w, h)) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return;
    }
    anchor_position(&x, &y, w, h, anchor);
    int x1 = max(x, g->clip_x), y1 = max(y, g->clip_y);
    int x2 = min(x + w, g->clip_right), y2 = min(y + h, g->clip_bottom);
    if (x2 <= x1 || y2 <= y1)
        return;
    sx += x1 - x;
    sy += y1 - y;
    int rows = y2 - y1;
    int step = sy > y1 ? 1 : -1;
    int row = step == 1 ? 0 : rows - 1;
    for (int i = 0; i < rows; ++i, row += step)
        memmove(pixel(b, x1, y1 + row), pixel(b, sx, sy + row), (size_t)(x2 - x1) * 2);
}

void LCDUIdrawRegion(JbedGraphics *g, const JbedBitmap *src, int x, int y, int anchor, int sx,
                     int sy, int w, int h, unsigned transform, int process_alpha, int copy_alpha,
                     const uint8_t *src_alpha, uint8_t *dst_alpha)
{
    if (!valid_region(src, sx, sy, w, h)) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return;
    }
    /* Anchoring uses the source dimensions before the transpose. */
    anchor_position(&x, &y, w, h, anchor);
    int rotated = transform & TRANSFORM_SWAP_AXES;
    int x1 = max(x, g->clip_x), x2 = min(x + (rotated ? h : w), g->clip_right);
    int y1 = max(y, g->clip_y), y2 = min(y + (rotated ? w : h), g->clip_bottom);
    if (x2 <= x1 || y2 <= y1)
        return;
    JbedBitmap *dst = target(g);
    int du = rotated ? y1 - y : x1 - x, dv = rotated ? x1 - x : y1 - y;
    int source_x = sx + ((transform & TRANSFORM_FLIP_X) ? w - 1 - du : du);
    int source_y = sy + ((transform & TRANSFORM_FLIP_Y) ? h - 1 - dv : dv);
    int x_step = (transform & TRANSFORM_FLIP_X) ? -1 : 1, y_step = (transform & TRANSFORM_FLIP_Y) ? -1 : 1;
    ptrdiff_t pixel_step = rotated ? y_step * (src->stride_bytes / 2) : x_step;
    ptrdiff_t alpha_step = rotated ? y_step * (ptrdiff_t)src->width : x_step;
    int row_x_step = rotated ? x_step : 0, row_y_step = rotated ? 0 : y_step;
    if (transform > TRANSFORM_MASK) {
        source_x = source_y = 0;
        pixel_step = alpha_step = row_x_step = row_y_step = 0;
    }
    unsigned flags = src->flags;
    bool composite = process_alpha && (flags & BITMAP_ALPHA);
    bool copy_plane = copy_alpha && (flags & (BITMAP_ALPHA | BITMAP_COLOR_KEY)) == BITMAP_ALPHA;
    int count = x2 - x1;
    for (int row = y1; row < y2; ++row, source_x += row_x_step, source_y += row_y_step) {
        const uint16_t *in = pixel(src, source_x, source_y);
        uint16_t *out = pixel(dst, x1, row);
        if (composite && (flags & BITMAP_COLOR_KEY)) {
            for (int i = 0; i < count; ++i) {
                uint16_t c = in[i * pixel_step];
                if (c != src->transparent_pixel)
                    out[i] = c;
            }
        } else if (composite || copy_plane) {
            const uint8_t *alpha = src_alpha + (size_t)source_y * src->width + source_x;
            if (!composite) {
                uint8_t *out_alpha = dst_alpha + (size_t)row * dst->width + x1;
                for (int i = 0; i < count; ++i) {
                    out[i] = in[i * pixel_step];
                    out_alpha[i] = alpha[i * alpha_step];
                }
            } else if (flags & BITMAP_FRACTIONAL_ALPHA) {
                for (int i = 0; i < count; ++i) {
                    unsigned a = alpha[i * alpha_step];
                    if (a == 255)
                        out[i] = in[i * pixel_step];
                    else if (a)
                        out[i] = blend565(in[i * pixel_step], out[i], a);
                }
            } else {
                for (int i = 0; i < count; ++i)
                    if (alpha[i * alpha_step])
                        out[i] = in[i * pixel_step];
            }
        } else if (transform <= TRANSFORM_FLIP_Y && count > 1) {
            memcpy(out, in, (size_t)count * sizeof(*out));
        } else {
            for (int i = 0; i < count; ++i)
                out[i] = in[i * pixel_step];
        }
    }
    dirty(g, x1, y1, x2 - 1, y2 - 1);
}

void LCDUIdrawImage(JbedGraphics *g, int x, int y, int anchor, const JbedBitmap *b,
                    const uint8_t *alpha)
{
    LCDUIdrawRegion(g, b, x, y, anchor, 0, 0, b->width, b->height, 0, 1, 0, alpha, NULL);
}

/* Fixed-point sin(1..89 degrees), 0x312e30. */
static const uint16_t sine[] = {
    1144,  2287,  3430,  4572,  5712,  6850,  7987,  9121,  10252, 11380, 12505, 13626, 14742,
    15855, 16962, 18064, 19161, 20252, 21336, 22415, 23486, 24550, 25607, 26656, 27697, 28729,
    29753, 30767, 31772, 32768, 33754, 34729, 35693, 36647, 37590, 38521, 39441, 40348, 41243,
    42126, 42995, 43852, 44695, 45525, 46341, 47143, 47930, 48703, 49461, 50203, 50931, 51643,
    52339, 53020, 53684, 54332, 54963, 55578, 56175, 56756, 57319, 57865, 58393, 58903, 59396,
    59870, 60326, 60764, 61183, 61584, 61966, 62328, 62672, 62997, 63303, 63589, 63856, 64104,
    64332, 64540, 64729, 64898, 65048, 65177, 65287, 65376, 65446, 65496, 65526};

typedef struct {
    int ex, ey, x, y, previous_x, error, straight, diagonal;
    bool x_major, test_x;
} Ray;

enum Sector { EMPTY, FULL, BEFORE, AFTER, OUTSIDE, BETWEEN };
typedef struct {
    enum Sector mode;
    Ray a, b;
} Quadrant;
typedef struct {
    JbedGraphics *g;
    JbedBitmap *bitmap;
    int cx, cy, padx, pady, oddx, oddy, phase, other_phase;
    bool fill;
    Quadrant q[4];
} Ellipse;

/* The endpoint test chooses the coordinate on the steeper part of the
 * ellipse. The radial line itself is walked only by the filled-arc path. */
static bool ray_init(Ray *r, int angle, int quadrant, int w, int h)
{
    int local = angle - quadrant * 90;
    if (local < 0 || local > 90)
        return false;
    if (quadrant & 1)
        local = 90 - local;
    if (!local)
        r->ex = w / 2;
    else if (local == 90) {
        r->ey = h / 2;
        r->test_x = true;
    } else {
        r->ex = (int)(((uint32_t)w * sine[89 - local]) >> 17);
        r->ey = (int)(((uint32_t)h * sine[local - 1]) >> 17);
        int32_t w2 = (int32_t)((uint32_t)w * w) >> 2;
        int32_t h2 = (int32_t)((uint32_t)h * h) >> 2;
        int32_t a = (int32_t)((uint32_t)w2 * (2 * r->ey - 1)) >> 1;
        int32_t b = (int32_t)((uint32_t)(r->ex + 1) * h2);
        r->test_x = a > b;
    }
    r->x = r->previous_x = r->ex;
    r->y = r->ey;
    r->x_major = r->x > r->y;
    if (!r->x || !r->y) {
        r->error = -1;
        return true;
    }
    int minor = min(r->x, r->y), major = max(r->x, r->y);
    r->straight = 2 * minor;
    r->diagonal = 2 * (minor - major);
    r->error = 2 * minor - major;
    return true;
}

static int ray_at(Ray *r, int row, bool inner)
{
    r->previous_x = r->x;
    while (inner ? r->y > row : r->y >= row) {
        if (r->x <= 0)
            return 0;
        r->previous_x = r->x;
        bool both = r->error >= 0;
        r->error += both ? r->diagonal : r->straight;
        if (both || r->x_major)
            --r->x;
        if (both || !r->x_major)
            --r->y;
    }
    return inner ? r->x : r->previous_x;
}

static void prepare_quadrants(Ellipse *e, int start, int end, int w, int h)
{
    for (int i = 0; i < 4; ++i) {
        Quadrant *q = &e->q[i];
        if (start == end) {
            q->mode = FULL;
            continue;
        }
        int lo = 90 * i, hi = lo + 90;
        bool in = start <= end ? lo >= start && lo <= end : lo >= start || lo <= end;
        q->mode = in ? FULL : EMPTY;
        bool a = ray_init(&q->a, start, i, w, h);
        bool b = ray_init(a ? &q->b : &q->a, end, i, w, h);
        if (a && b) {
            if (in && start == hi && end == lo)
                q->mode = EMPTY;
            else if (in && start == lo && end == hi)
                q->mode = FULL;
            else {
                q->mode = in && start != lo ? OUTSIDE : BETWEEN;
                if (((i & 1) != 0) == (q->mode == OUTSIDE)) {
                    Ray tmp = q->a;
                    q->a = q->b;
                    q->b = tmp;
                }
            }
        } else if (a || b) {
            if (in) {
                if (start != lo && end != hi)
                    q->mode = start == hi || end == lo ? EMPTY : (i & 1 ? BEFORE : AFTER);
            } else if (start != hi)
                q->mode = i & 1 ? AFTER : BEFORE;
        }
    }
}

static bool before(const Ray *r, int x, int y)
{
    return r->test_x ? x <= r->ex : y >= r->ey;
}
static bool after(const Ray *r, int x, int y)
{
    return r->test_x ? x >= r->ex : y <= r->ey;
}

static bool on_arc(const Quadrant *q, int x, int y)
{
    switch (q->mode) {
    case FULL:
        return true;
    case BEFORE:
        return before(&q->a, x, y);
    case AFTER:
        return after(&q->a, x, y);
    case OUTSIDE:
        return before(&q->a, x, y) || after(&q->b, x, y);
    case BETWEEN:
        return after(&q->a, x, y) && before(&q->b, x, y);
    default:
        return false;
    }
}

static void quadrant_span(Ellipse *e, int quadrant, int y, int left, int right)
{
    bool positive = quadrant == 0 || quadrant == 3;
    int first = e->cx + (positive ? left + (left ? e->oddx : 0) : -left);
    int last = e->cx + (positive ? right + e->oddx : -right);
    span(e->g, e->bitmap, first, last, y, e->g->stroke ? &e->phase : NULL);
}

static void fill_quadrant(Ellipse *e, int i, int x, int y, int row)
{
    Quadrant *q = &e->q[i];
    Ray *a = &q->a, *b = &q->b;
    int left = 0, right = x;
    switch (q->mode) {
    case EMPTY:
        return;
    case FULL:
        break;
    case BEFORE:
        if (!before(a, x, y) && y <= a->y)
            right = ray_at(a, y, true);
        break;
    case AFTER:
        if (!after(a, x, y))
            return;
        left = y <= a->y + 1 ? ray_at(a, y, false) : a->previous_x;
        break;
    case OUTSIDE:
        if (before(a, x, y))
            break;
        if (y <= a->y)
            quadrant_span(e, i, row, 0, ray_at(a, y, true));
        if (!after(b, x, y))
            return;
        left = y <= b->y + 1 ? ray_at(b, y, false) : b->previous_x;
        break;
    case BETWEEN:
        if (!after(a, x, y))
            return;
        if (before(b, x, y)) {
            left = y <= a->y + 1 ? ray_at(a, y, false) : a->previous_x;
        } else {
            if (y > a->y + 1 && y > b->y)
                return;
            left = y <= a->y + 1 ? ray_at(a, y, false) : a->previous_x;
            right = y <= b->y ? ray_at(b, y, true) : b->x;
        }
        break;
    }
    quadrant_span(e, i, row, left, right);
}

static void ellipse_points(Ellipse *e, int x, int y)
{
    int right = e->cx + e->padx + e->oddx + x, left = e->cx - e->padx - x;
    int top = e->cy - e->pady - y, bottom = e->cy + e->pady + e->oddy + y;
    int *phase = e->g->stroke ? &e->phase : NULL;
    if (e->fill) {
        if (e->q[3].mode == FULL && e->q[2].mode == FULL)
            span(e->g, e->bitmap, left, right, bottom, phase);
        else {
            fill_quadrant(e, 3, x, y, bottom);
            fill_quadrant(e, 2, x, y, bottom);
        }
        if (e->q[0].mode == FULL && e->q[1].mode == FULL)
            span(e->g, e->bitmap, left, right, top, phase);
        else {
            fill_quadrant(e, 0, x, y, top);
            fill_quadrant(e, 1, x, y, top);
        }
    } else {
        const int xs[] = {right, left, left, right}, ys[] = {top, top, bottom, bottom};
        bool odd = !phase || dash(phase);
        bool even = !phase || dash(&e->other_phase);
        for (int i = 0; i < 4; ++i)
            if ((i & 1 ? odd : even) && on_arc(&e->q[i], x, y) && inside(e->g, xs[i], ys[i]))
                *pixel(e->bitmap, xs[i], ys[i]) = e->g->pixel;
    }
}

/* Shared midpoint ellipse used for arcs and rounded corners (0x2c2b24).
 * The unclipped direct-pixel loop at 0x2c2c24 uses the same recurrence. */
static void ellipse(Ellipse *e, int rx, int ry)
{
    int x = 0, y = ry;
    /* Large offscreen ellipses wrap the ARM accumulator before clipping. */
    uint32_t a = (uint32_t)rx * rx, b = (uint32_t)ry * ry;
    uint32_t dx = b, dy = a - 2 * a * y, ex = 0, ey = 2 * a * y, error = 0;
    ellipse_points(e, x, y);
    while ((int32_t)ey > (int32_t)ex) {
        error += dx;
        ++x;
        ex += 2 * b;
        dx += 2 * b;
        if ((int32_t)(2 * error + dy) > 0) {
            error += dy;
            --y;
            ey -= 2 * a;
            dy += 2 * a;
        }
        ellipse_points(e, x, y);
    }
    while (y > 0) {
        error += dy;
        --y;
        dy += 2 * a;
        if ((int32_t)(2 * error + dx) < 0) {
            ++x;
            error += dx;
            dx += 2 * b;
        }
        ellipse_points(e, x, y);
    }
    while (x < rx)
        ellipse_points(e, ++x, 0);
}

static void arc(JbedGraphics *g, int x, int y, int w, int h, int start, int sweep, bool fill)
{
    if (w <= 1 || h <= 1) {
        if (fill) {
            if (w == 1 && h == 1)
                LCDUIdrawLine(g, x, y, x, y);
        } else if (w >= 0 && h >= 0)
            LCDUIdrawLine(g, x, y, x + w, y + h);
        return;
    }
    if (!sweep)
        return;
    int end = 0;
    if (sweep >= -360 && sweep <= 360) {
        end = (int32_t)((uint32_t)start + sweep);
        if (end < 0) {
            int tmp = end;
            end = start;
            start = tmp;
        }
        start = (start % 360 + 360) % 360;
        end = (end % 360 + 360) % 360;
    } else
        start = 0;
    w -= fill;
    h -= fill;
    Ellipse e = {.g = g,
                 .bitmap = target(g),
                 .cx = x + w / 2,
                 .cy = y + h / 2,
                 .oddx = w & 1,
                 .oddy = h & 1,
                 .phase = 3,
                 .fill = fill};
    prepare_quadrants(&e, start, end, w, h);
    ellipse(&e, w / 2, h / 2);
    dirty(g, x, y, x + w - fill, y + h - fill);
}

void LCDUIdrawArc(JbedGraphics *g, int x, int y, int w, int h, int start, int sweep)
{
    arc(g, x, y, w, h, start, sweep, false);
}

void LCDUIfillArc(JbedGraphics *g, int x, int y, int w, int h, int start, int sweep)
{
    arc(g, x, y, w, h, start, sweep, true);
}

static void round_rect(JbedGraphics *g, int x, int y, int w, int h, int aw, int ah, bool fill)
{
    if (w <= 1 || h <= 1) {
        if (fill) {
            if (w == 1 && h == 1)
                LCDUIdrawLine(g, x, y, x, y);
        } else if (w >= 0 && h >= 0)
            LCDUIdrawLine(g, x, y, x + w, y + h);
        return;
    }
    int fw = w - fill, fh = h - fill;
    int rx = max(0, min(aw, fw)) / 2, ry = max(0, min(ah, fh)) / 2;
    Ellipse e = {.g = g,
                 .bitmap = target(g),
                 .cx = x + fw / 2,
                 .cy = y + fh / 2,
                 .padx = fw / 2 - rx,
                 .pady = fh / 2 - ry,
                 .oddx = fw & 1,
                 .oddy = fh & 1,
                 .phase = 3,
                 .fill = fill};
    prepare_quadrants(&e, 0, 0, fw, fh);
    ellipse(&e, rx, ry);
    if (fill) {
        LCDUIfillRect(g, x, y + ry + 1, w, h - 2 * (ry + 1));
    } else {
        LCDUIdrawLine(g, x + rx + 1, y, x + w - rx, y);
        LCDUIdrawLine(g, x + rx + 1, y + h, x + w - rx, y + h);
        LCDUIdrawLine(g, x, y + ry + 1, x, y + h - ry - 1);
        LCDUIdrawLine(g, x + w, y + ry + 1, x + w, y + h - ry - 1);
    }
    dirty(g, x, y, x + fw - 1, y + fh - 1);
}

void LCDUIdrawRoundRect(JbedGraphics *g, int x, int y, int w, int h, int aw, int ah)
{
    round_rect(g, x, y, w, h, aw, ah, false);
}

void LCDUIfillRoundRect(JbedGraphics *g, int x, int y, int w, int h, int aw, int ah)
{
    round_rect(g, x, y, w, h, aw, ah, true);
}
