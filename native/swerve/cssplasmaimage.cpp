#include "cssplasmaimage.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "cssfixed1616.hpp"

using namespace plasma_fixed;

namespace {
constexpr uint32_t DefaultSeed = 826374438;
constexpr unsigned ShiftLimit = 16;
constexpr int AreaShiftLimit = 29;
constexpr int FixedOneThird = 21845;
constexpr int FixedInverseSqrtTwo = 46341;
constexpr int FixedInverseTwoPi = 10430;
constexpr int FixedTwoSqrtTwo = 185336;
constexpr int HexTileVScale = 3449;
constexpr int HexTileEdgeScale = 5958;
constexpr int NoiseNormalizationNumerator = 0x7d710000;
enum Feature {
    U,
    V,
    CURVE_U,
    CURVE_V,
    WARP_U,
    WARP_V,
    TILE_U,
    TILE_V,
    TILE_RADIUS,
    TILE_EDGE,
    TILE_ANGLE,
    TILE_NOISE,
    NOISE,
    REFLECTED_NOISE,
    TILE_RANDOM,
    PIXEL_RANDOM,
    FEATURE_COUNT
};
constexpr int TileFeatureMask = (1 << TILE_U) | (1 << TILE_V) | (1 << TILE_RADIUS) |
    (1 << TILE_EDGE) | (1 << TILE_ANGLE) | (1 << TILE_NOISE) | (1 << TILE_RANDOM);
}

CssPlasmaImage::CssPlasmaImage()
{
    seed = DefaultSeed;
    weights[0][NOISE] = weights[1][WARP_V] = ONE;
    colors[0] = CssColor(0, 0, 0);
    colors[1] = CssColor(1, 1, 1);
    colors[2] = CssColor(0.8f, 0.8f, 0.8f);
    colors[3] = CssColor(0.3f, 0.698f, 1);
    for (int i = 0; i < 4; ++i) curve_index[i] = &curves[i];
}

void CssPlasmaImage::InsertWarpMapKnot(EssWarpMap map, int index, float x, float y)
{
    curve_index[map]->InsertKnot(index, {toFixed16(x), toFixed16(y)});
    ReCache();
}

void CssPlasmaImage::Construct()
{
    InsertWarpMapKnot(BlendU, 0, 0, 0);
    InsertWarpMapKnot(BlendU, 1, 1, 1);
    InsertWarpMapKnot(BlendV, 0, 0, 0);
    InsertWarpMapKnot(BlendV, 1, 1, 1);
}

IssSerializable *CssPlasmaImage::FactoryCreate()
{
    auto *image = new CssPlasmaImage;
    CssCleanupStackManager::Push(image);
    image->Construct();
    CssCleanupStackManager::Pop(image);
    return image;
}

CssObject3D *CssPlasmaImage::Clone() const
{
    auto *copy = static_cast<CssPlasmaImage *>(FactoryCreate());
    CssCleanupStackManager::Push(copy);
    copy->CloneHelper(*this);
    CssCleanupStackManager::Pop(copy);
    return copy;
}

void CssPlasmaImage::CloneHelper(const CssPlasmaImage &source)
{
    CssImage2D::CloneHelper(source);
    width_shift = source.width_shift;
    height_shift = source.height_shift;
    noise_shift = source.noise_shift;
    displacement = source.displacement;
    pattern = source.pattern;
    tile_x_shift = source.tile_x_shift;
    tile_y_shift = source.tile_y_shift;
    for (int i = 0; i < 4; ++i)
        curves[i].CloneHelper(source.curves[i]);
    std::memcpy(weights, source.weights, sizeof(weights));
    for (int i = 0; i < 4; ++i) colors[i] = source.colors[i];
    locks = 0;
    ReCache();
}

void CssPlasmaImage::BlockCache(bool block)
{
    if (block)
        ++locks;
    else if (--locks == 0)
        ReCache();
}

static void read_shift(int &shift, unsigned value)
{
    shift = static_cast<int>(value);
    if (value >= ShiftLimit) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
}

void CssPlasmaImage::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssObject3D::SerializeIn(reader);
    seed = reader.ReadUInt();
    read_shift(width_shift, reader.ReadByte());
    read_shift(height_shift, reader.ReadByte());
    read_shift(noise_shift, reader.ReadUInt());
    displacement = toFixed16(reader.ReadReal());
    pattern = reader.ReadEnum(Grid - 1, ConcentricRings + 1);
    read_shift(tile_x_shift, reader.ReadByte());
    read_shift(tile_y_shift, reader.ReadByte());
    for (auto &color : colors) color.SetPackedRGBA8(reader.ReadUInt());
    uint32_t mask = reader.ReadUInt();
    for (auto &axis : weights) {
        for (int &weight : axis) {
            weight = (mask & 1) ? toFixed16(reader.ReadReal()) : 0;
            mask >>= 1;
        }
    }
    for (auto &curve : curves)
        curve.SerializeIn(reader);
    ReCache();
    ReCalculate();
}

SwvFixedWord CssPlasmaImage::SeededRandom(SwvFixedWord x) const
{
    uint32_t n = x;
    for (int i = 0; i < 3; ++i)
        n = n * Multiplier + Increment;
    return n & 65535;
}

/* Three correlated samples subdivide each periodic cell. The first coarse
 * levels omit the corner average according to the noise cutoff. */
static int make_noise(const CssPlasmaImage &p, SwvFixedWord *noise, int w, int h)
{
    int sx = w, sy = h, amplitude = ONE, peak = 0;
    int cutoff = (w > h ? w : h) >> p.noise_shift;
    noise[0] = 0;
    while (sx > sy) {
        if (sx < cutoff) amplitude >>= 1;
        for (int x = 0; x < w; x += sx)
            noise[x + sx / 2] = 0;
        sx >>= 1;
    }
    while (sy > sx) {
        if (sy < cutoff) amplitude >>= 1;
        for (int y = 0; y < h; y += sy)
            noise[w * (y + sy / 2)] = 0;
        sy >>= 1;
    }
    for (int step = sx; step > 1; step >>= 1) {
        int half = step / 2;
        if (step < cutoff) amplitude >>= 1;
        for (int y = 0; y < h; y += step) {
            int top = w * y, bottom = w * ((y + step) & (h - 1)), middle = w * (y + half);
            for (int x = 0; x < w; x += step) {
                int right = (x + step) & (w - 1);
                int a = p.Random();
                int b = p.Random();
                int c = p.Random();
                int mean = mul16(FixedOneThird, a + b + c);
                a -= mean;
                b -= mean;
                c -= mean;
                if (half < cutoff) {
                    int tl = noise[top + x], tr = noise[top + right];
                    int bl = noise[bottom + x], br = noise[bottom + right];
                    a = mul16(a, amplitude) + ((tl + tr) >> 1);
                    b = mul16(b, amplitude) + ((tl + bl) >> 1);
                    c = mul16(c, amplitude) + ((tl + tr + bl + br) >> 2);
                }
                noise[top + x + half] = a;
                noise[middle + x] = b;
                noise[middle + x + half] = c;
                if (magnitude(a) > peak) peak = magnitude(a);
                if (magnitude(b) > peak) peak = magnitude(b);
                if (magnitude(c) > peak) peak = magnitude(c);
            }
        }
    }
    return peak ? NoiseNormalizationNumerator / peak : -1;
}

struct Samples {
    const SwvFixedWord *noise;
    int width, height, size, noise_scale;
    int tile_w, tile_h, inv_tile_w, inv_tile_h, inv_w, inv_h;
    int mask, weight[2], inv_weight[2], inv_all[2];
};

static void tile_features(const CssPlasmaImage &p, const Samples *s, int x, int y, int v[FEATURE_COUNT])
{
    int tw = s->tile_w, th = s->tile_h, iw = s->inv_tile_w, ih = s->inv_tile_h;
    int ox = x & -tw, oy = y & -th, cx, cy, dx, dy;
    if (p.pattern == CssPlasmaImage::StaggeredRows || p.pattern == CssPlasmaImage::HexagonalTiles) {
        int offset = ((y >> p.tile_y_shift) & 1) * (tw / 2);
        ox = offset + ((x - offset) & -tw);
    }
    if (p.pattern == CssPlasmaImage::ConcentricRings) {
        int u = (x - s->width / 2) * iw, w = (y - s->height / 2) * ih;
        int radius = g_fixed_sqrt(mul16(u, u) + mul16(w, w));
        v[TILE_EDGE] = (uint16_t)radius;
        int ring = (radius >> 16) + 1;
        cx = s->width / 2 - ring * tw;
        cy = s->height / 2 - ring * th;
        int scale = recip(ring * ONE) >> 1;
        v[TILE_U] = (x - cx) * mul16(scale, iw);
        v[TILE_V] = (y - cy) * mul16(scale, ih);
        int norm = mul16(FixedTwoSqrtTwo, scale);
        dx = mul16(u, norm);
        dy = mul16(w, norm);
    } else if (p.pattern == CssPlasmaImage::HexagonalTiles) {
        int rx = x - ox, ry = y - oy, edge = (5 * th) >> 3;
        if (ry >= edge) {
            int y4 = 4 * tw * (ry - edge);
            if (rx >= tw / 2) {
                if (y4 > -3 * th * (rx - tw)) {
                    ox += tw / 2;
                    oy += th;
                }
            } else if (y4 > 3 * th * rx) {
                ox -= tw / 2;
                oy += th;
            }
        }
        v[TILE_U] = iw * (x - ox);
        v[TILE_V] = mul16(HexTileVScale, 16 * ih * (y - oy) + 196608);
        cx = ox + tw / 2;
        cy = oy + ((5 * th) >> 4);
        int u = (x - cx) * iw, w = (y - cy) * ih;
        dx = 2 * u;
        dy = 2 * w;
        u = magnitude(u);
        w = magnitude(w);
        v[TILE_EDGE] =
            5 * u <= 8 * w ? mul16(HexTileEdgeScale, 16 * w + 12 * u) : 2 * u;
    } else {
        int u = iw * (x - ox), w = ih * (y - oy);
        int swap = p.pattern == CssPlasmaImage::AlternatingAxes && (((x >> p.tile_x_shift) ^ (y >> p.tile_y_shift)) & 1);
        v[TILE_U] = swap ? w : u;
        v[TILE_V] = swap ? u : w;
        cx = ox + tw / 2;
        cy = oy + th / 2;
        dx = 2 * iw * (x - cx);
        dy = 2 * ih * (y - cy);
        v[TILE_EDGE] = magnitude(dx) > magnitude(dy) ? magnitude(dx) : magnitude(dy);
    }
    int index = (cx & (s->width - 1)) + s->width * (cy & (s->height - 1));
    if (s->mask & (1 << TILE_RANDOM)) v[TILE_RANDOM] = p.SeededRandom(s->noise[index]);
    if (s->mask & (1 << TILE_NOISE)) v[TILE_NOISE] = mul16(s->noise_scale, s->noise[index]) + HALF;
    if (s->mask & (1 << TILE_RADIUS))
        v[TILE_RADIUS] = mul16(FixedInverseSqrtTwo, g_fixed_sqrt(mul16(dx, dx) + mul16(dy, dy)));
    if (s->mask & (1 << TILE_ANGLE)) v[TILE_ANGLE] = mul16(FixedInverseTwoPi, g_fixed_atan2(dx, dy)) + HALF;
}

static int coordinate(int value, int noise, int size, int displacement)
{
    int offset = value + (mul16(noise, displacement) >> 1);
    return (size - 1) & ((size * offset + size * ONE + HALF) >> 16);
}

static void sample(const CssPlasmaImage &p, const Samples *s, int x, int y, int v[FEATURE_COUNT])
{
    v[U] = x * s->inv_w;
    v[V] = y * s->inv_h;
    v[CURVE_U] = v[U] - p.curves[CssPlasmaImage::WarpU].Warp(v[V]) + HALF;
    v[CURVE_V] = v[V] - p.curves[CssPlasmaImage::WarpV].Warp(v[U]) + HALF;
    int pos = x + s->width * y, mask = s->size - 1;
    int xnoise = mul16(s->noise_scale, s->noise[(pos + s->size / 4) & mask]);
    int ynoise = mul16(s->noise_scale, s->noise[(pos + s->size / 2) & mask]);
    int cx = coordinate(v[CURVE_U], xnoise, s->width, p.displacement);
    int cy = coordinate(v[CURVE_V], ynoise, s->height, p.displacement);
    v[WARP_U] = cx * s->inv_w;
    v[WARP_V] = cy * s->inv_h;
    int warped = cx + s->width * cy;
    if (s->mask & TileFeatureMask) tile_features(p, s, cx, cy, v);
    if (s->mask & (1 << PIXEL_RANDOM)) v[PIXEL_RANDOM] = p.SeededRandom(s->noise[pos]);
    if (s->mask & (1 << NOISE)) v[NOISE] = mul16(s->noise_scale, s->noise[warped]) + HALF;
    if (s->mask & (1 << REFLECTED_NOISE)) {
        int reflected = (s->size + s->size / 2 - warped) & mask;
        v[REFLECTED_NOISE] = mul16(s->noise_scale, s->noise[reflected]) + HALF;
    }
}

static int blend_factor(const CssPlasmaImage &p, const Samples *s, const int v[FEATURE_COUNT], int axis)
{
    const int *weights = p.weights[axis];
    int sum = 0;
    for (int i = 0; i < TILE_RANDOM; ++i)
        if (s->mask & (1 << i)) sum += mul16(v[i] - HALF, weights[i]);
    int curved = p.curves[axis + CssPlasmaImage::BlendU].WarpClamped(mul16(sum, s->inv_weight[axis]) + HALF);
    sum = mul16(curved - HALF, s->weight[axis]);
    for (int i = TILE_RANDOM; i < FEATURE_COUNT; ++i)
        if (s->mask & (1 << i)) sum += mul16(v[i] - HALF, weights[i]);
    return clamp01(mul16(sum, s->inv_all[axis]) + HALF);
}

void CssPlasmaImage::ReCalculate() const
{
    if (!dirty || locks) return;
    if (width_shift <= 0 || height_shift <= 0) {
        dirty = 0;
        return;
    }
    if ((unsigned)width_shift >= ShiftLimit || (unsigned)height_shift >= ShiftLimit ||
        width_shift + height_shift >= AreaShiftLimit)
        g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    int w = 1 << width_shift, h = 1 << height_shift, size = w * h;
    auto *noise = new CssArray<SwvFixedWord>;
    CssCleanupStackManager::Push(noise);
    random_state = seed;
    if (CssImage2D::GetWidth() != w || CssImage2D::GetHeight() != h)
        SetSize(w, h);
    auto *out = GetpWritablePixels();
    noise->SetSize(size);
    Samples s = {};
    s.noise = &(*noise)[0];
    s.width = w;
    s.height = h;
    s.size = size;
    s.noise_scale = make_noise(*this, &(*noise)[0], w, h);
    s.tile_w = 1 << tile_x_shift;
    s.tile_h = 1 << tile_y_shift;
    for (int axis = 0; axis < 2; ++axis) {
        int n = 0;
        for (int i = 0; i < FEATURE_COUNT; ++i) {
            if (i == TILE_RANDOM) {
                s.weight[axis] = n;
                s.inv_weight[axis] = n ? recip(n) : ONE;
            }
            int weight = weights[axis][i];
            n += magnitude(weight);
            if (weight) s.mask |= 1 << i;
        }
        s.inv_all[axis] = n ? recip(n) : 0;
    }
    s.inv_tile_w = recip(s.tile_w * ONE);
    s.inv_tile_h = recip(s.tile_h * ONE);
    s.inv_w = recip(w * ONE);
    s.inv_h = recip(h * ONE);
    CssColor difference0 = colors[0], difference1 = colors[2];
    difference0 -= colors[1];
    difference1 -= colors[3];
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            int feature[FEATURE_COUNT];
            sample(*this, &s, x, y, feature);
            int u = blend_factor(*this, &s, feature, 0);
            int v = blend_factor(*this, &s, feature, 1);
            CssColor first = difference0, second = difference1;
            first.FixedScale(u);
            first += colors[1];
            second.FixedScale(u);
            second += colors[3];
            second -= first;
            second.FixedScale(v);
            second += first;
            out[x + (h - y - 1) * w] = second.GetPixel();
        }
    }
    CssCleanupStackManager::Pop(noise);
    delete noise;
    dirty = 0;
}
