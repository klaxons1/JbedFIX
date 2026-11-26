#include "cssrasterizerstandard.hpp"
#include "image_class.hpp"
#include "cssfixed1616.hpp"
#include "engine.h"
#include <algorithm>
#include <limits.h>
#include <stdlib.h>
#include <string.h>

namespace {
constexpr int OpaqueAlpha = 255 << 8;
constexpr int DepthFractionBits = 12;
constexpr int MaxPerspectiveQ = 0x800000;
constexpr int MinPerspectiveQ = 0x400000;
constexpr int PerspectiveQByteShift = 8;
constexpr int MaxPerspectiveSpan = 150;
constexpr int PerspectiveSpanBias = 8;
}

static int clamp(int v, int max) { return v < 0 ? 0 : v > max ? max : v; }
static int upper(int v, int max) { return v > max ? max : v; }
static int multiplyFixed(int left, int right)
{
    return static_cast<int>((int64_t(left) * right) >> 16);
}
static int multiplyAddFixed(int a, int b, int c, int d)
{
    return static_cast<int>((int64_t(a) * b + int64_t(c) * d) >> 16);
}

void SwvRasterTexture::setExtent(int w, int h)
{
    width = w;
    height = h;
    width_shift = height_shift = 0;
    for (int n = w; n > 1; n >>= 1) ++width_shift;
    for (int n = h; n > 1; n >>= 1) ++height_shift;
    if (w != (1 << width_shift) || h != (1 << height_shift))
        width_shift = height_shift = -1;
}

CssRasterizerStandard::CssRasterizerStandard() = default;
CssRasterizerStandard::~CssRasterizerStandard() = default;

void CssRasterizerStandard::Construct()
{
    row = {};
    gradients = {};
    pixels = nullptr;
    width = height = pitch = 0;
    triangle_flags = {};
    flags = {};
    texture_count = alpha_threshold = 0;
    for (auto &unit : texture) {
        unit.format = SWV_IMAGE_NONE;
        unit.rgb = nullptr;
        unit.alpha = unit.indices = nullptr;
    }
    mode = SWV_BLEND_REPLACE;
}
void CssRasterizerStandard::SetupBackBuffer(uint16_t *buffer, int w, int h, int stride,
                                            uint16_t *zbuffer, bool enable_depth)
{
    pixels = buffer;
    width = w;
    height = h;
    pitch = stride;
    depth = zbuffer;
    depth_enabled = enable_depth;
}

void CssRasterizerStandard::UpdateBackBuffer(uint16_t *buffer)
{
    pixels = buffer;
}

void CssRasterizerStandard::SetHints(bool enable_depth)
{
    depth_enabled = enable_depth;
}

void CssRasterizerStandard::SetupAlphaBuffer(uint8_t *buffer, int stride)
{
    alpha = buffer;
    alpha_pitch = stride;
}

static bool clip(const CssRasterizerStandard *r, int *x, int *y, int *w, int *h)
{
    if (*x < 0) {
        *w += *x;
        *x = 0;
    }
    if (*y < 0) {
        *h += *y;
        *y = 0;
    }
    *w = upper(*w, r->width - *x);
    *h = upper(*h, r->height - *y);
    return *w > 0 && *h > 0;
}
void CssRasterizerStandard::FillRect(int x, int y, int w, int h, uint16_t color, int opacity)
{
    if (!clip(this, &x, &y, &w, &h))
        return;
    for (int j = 0; j < h; ++j) {
        uint16_t *p = (uint16_t *)((uint8_t *)pixels + (j + y) * pitch) + x;
        for (int i = 0; i < w; ++i)
            p[i] = color;
        if (alpha)
            memset(alpha + (j + y) * alpha_pitch + x, opacity, w);
    }
}
/* Background image transfer, 0x2e3b40. Clipping leaves the supplied source
 * origin in place. The alpha loop samples the same source column for a row. */
void CssRasterizerStandard::TexRect(int x, int y, int w, int h, int s, int t, int ds, int dt)
{
    if (!clip(this, &x, &y, &w, &h))
        return;
    const SwvRasterTexture *tex = &texture[0];
    for (int j = 0; j < h; ++j) {
        uint16_t *p = (uint16_t *)((uint8_t *)pixels + (j + y) * pitch) + x;
        int source_row = (t >> 16) * tex->width, u = s;
        for (int i = 0; i < w; ++i) {
            int k = source_row + (u >> 16);
            p[i] = tex->rgb[tex->indices ? tex->indices[k] : k];
            u += ds;
            if (u >= tex->width * 65536)
                u -= tex->width * 65536;
        }
        if (alpha) {
            int k = source_row + (s >> 16);
            /* The indexed path uses the alpha allocation itself as its lookup plane.
             */
            uint8_t a = tex->alpha ? tex->alpha[tex->indices ? tex->alpha[k] : k] : 255;
            memset(alpha + (j + y) * alpha_pitch + x, a, w);
        }
        t += dt;
        if (t >= tex->height * 65536)
            t -= tex->height * 65536;
    }
}

using enum CssRasterizerStandard::Attribute;
using Gradient = CssRasterizerStandard::Gradient;

int &CssRasterizerStandard::TextureValues::at(int k)
{
    int unit = (k - Q0) / 3;
    switch ((k - Q0) % 3) {
        case 0: return q[unit];
        case 1: return s[unit];
        default: return t[unit];
    }
}
int &CssRasterizerStandard::Values::at(int k)
{
    if (k == Z) return z;
    if (k <= BLUE) return rgb[k - RED];
    if (k == ALPHA) return alpha;
    if (k == FOG) return fog;
    return texture.at(k);
}
Gradient &CssRasterizerStandard::Gradients::at(int k)
{
    if (k == Z) return z;
    if (k <= BLUE) return rgb[k - RED];
    if (k == ALPHA) return alpha;
    if (k == FOG) return fog;
    return uv[(k - Q0) / 3].coord[(k - Q0) % 3].delta;
}
static int alpha16(int value) { return 257 * value + (value >> 7); }

void CssRasterizerStandard::SetGradients()
{
    const auto &a = *vertices[0], &b = *vertices[1], &c = *vertices[2];
    int ax = a.x - c.x, bx = b.x - c.x, ay = a.y - c.y, by = b.y - c.y;
    int area = (bx * ay - ax * by) >> 8;
    if (area >= -7 && area <= 7)
        area = area < 0 ? -8 : 8;
    int inv = g_quick_scaledreciprocal(area, 30);
    inv -= inv >> 9;
    int x0 = multiplyFixed(by, inv), x1 = multiplyFixed(ay, inv);
    int y0 = multiplyFixed(bx, -inv), y1 = multiplyFixed(ax, -inv);
    auto gradient = [&](int va, int vb, int vc, int shift_x, int shift_y) -> Gradient {
        return {multiplyAddFixed(vc - va, x0, vb - vc, x1) >> shift_x,
                multiplyAddFixed(vc - va, y0, vb - vc, y1) >> shift_y};
    };

    if (triangle_flags.smooth) {
        for (int k = 0; k < 3; ++k) {
            int va = a.rgb[k], vb = b.rgb[k], vc = c.rgb[k];
            if (!triangle_flags.textured) {
                va = upper(va, 65535);
                vb = upper(vb, 65535);
                vc = upper(vc, 65535);
            }
            gradients.rgb[k] = gradient(va, vb, vc, 2, 2);
            row.left.dx.rgb[k] = gradients.rgb[k].x;
        }
        gradients.alpha = gradient(alpha16(a.alpha), alpha16(b.alpha), alpha16(c.alpha), 2, 2);
        row.left.dx.alpha = gradients.alpha.x;
    } else {
        if (span != &CssRasterizerStandard::DrawFlatLine && span != &CssRasterizerStandard::DrawUnLitTexLine) {
            for (int k = RED; k <= ALPHA; ++k) {
                gradients.at(k) = {};
                row.left.dx.at(k) = row.left.step[0].at(k) = row.left.step[1].at(k) = 0;
            }
        }
        for (int k = 0; k < 3; ++k)
            row.left.value.rgb[k] = triangle_flags.textured ? a.rgb[k] : upper(a.rgb[k], 65535);
        row.left.value.alpha = alpha16(a.alpha);
    }
    if (triangle_flags.fog_enabled) {
        if (a.fog | b.fog | c.fog) {
            gradients.fog = gradient(257 * a.fog, 257 * b.fog, 257 * c.fog, 2, 2);
            row.left.dx.fog = gradients.fog.x;
        } else {
            triangle_flags.fog_enabled = false;
        }
    }

    for (int u = 0; triangle_flags.textured && u < texture_count; ++u) {
        const auto &ta = a.tex[u], &tb = b.tex[u], &tc = c.tex[u];
        auto &uv = gradients.uv[u];
        if (triangle_flags.affine) {
            uv.coord[1].delta = gradient(ta.s << 5, tb.s << 5, tc.s << 5, 0, 0);
            uv.coord[2].delta = gradient(ta.t << 5, tb.t << 5, tc.t << 5, 0, 0);
        } else {
            int qa = ta.q, qb = tb.q, qc = tc.q;
            int magnitude = abs(qa) | abs(qb) | abs(qc);
            while (magnitude > MaxPerspectiveQ) {
                magnitude >>= 1;
                qa >>= 1; qb >>= 1; qc >>= 1;
            }
            if (magnitude > 0) {
                while (magnitude < (MinPerspectiveQ >> PerspectiveQByteShift)) {
                    magnitude <<= PerspectiveQByteShift;
                    qa <<= PerspectiveQByteShift; qb <<= PerspectiveQByteShift; qc <<= PerspectiveQByteShift;
                }
                while (magnitude < MinPerspectiveQ) {
                    magnitude *= 2;
                    qa *= 2; qb *= 2; qc *= 2;
                }
            }
            uv.q[0] = qa; uv.q[1] = qb; uv.q[2] = qc;
            uv.coord[0].delta = gradient(qa, qb, qc, 0, 2);
            uv.coord[1].delta = gradient(multiplyFixed(qa, ta.s), multiplyFixed(qb, tb.s),
                                         multiplyFixed(qc, tc.s), 0, 2);
            uv.coord[2].delta = gradient(multiplyFixed(qa, ta.t), multiplyFixed(qb, tb.t),
                                         multiplyFixed(qc, tc.t), 0, 2);
        }
    }
    gradients.z = gradient(a.z, b.z, c.z, 2, 2);
    row.left.dx.z = gradients.z.x;
    if (triangle_flags.textured && !triangle_flags.affine) {
        int max_z = std::max({a.z, b.z, c.z});
        for (int u = 0; u < texture_count; ++u) {
            auto &uv = gradients.uv[u];
            int step = abs(multiplyFixed(uv.coord[0].delta.x, max_z) >> 15);
            uv.chunk = upper(g_quick_scaledreciprocal(step ? step : 1, 14) + PerspectiveSpanBias, MaxPerspectiveSpan);
            for (auto &coord : uv.coord) {
                coord.chunk_step = (coord.delta.x * uv.chunk) >> 2;
                coord.delta.x >>= 2;
            }
        }
    }
    if (depth_offset) {
        unsigned bias = 0;
        if (depth_factor) {
            int slope = abs(gradients.z.x) + abs(gradients.z.y);
            bias = (static_cast<unsigned>(multiplyFixed(depth_factor, slope)) + 4095) & ~4095u;
        }
        bias += ((depth_units << DepthFractionBits) + 0x8000) >> 16;
        for (int i = 0; i < 3; ++i)
            vertices[i]->z += bias;
    }
}

static int pack_dither(const int rgba[], int x, int y)
{
    int d = ((y & 1) + 1) ^ ((x & 1) * 2);
    return (clamp((d + (rgba[0] >> 9)) >> 2, 31) << 11) | (clamp((d + (rgba[1] >> 8)) >> 2, 63) << 5) |
           clamp((d + (rgba[2] >> 9)) >> 2, 31);
}
static void unpack(uint16_t pixel, int out[])
{
    out[0] = pixel & 0xf800;
    out[1] = (pixel & 0x7e0) << 5;
    out[2] = (pixel & 31) << 11;
}
static void compose(SwvBlendMode mode, int rgba[], const int dst[], bool tex)
{
    int a = rgba[3];
    for (int k = 0; k < 4; ++k) {
        int s = rgba[k], d = dst[k];
        switch (mode) {
        case SWV_BLEND_ALPHA:
            if (a < OpaqueAlpha)
                s = d + (tex ? (a * ((s - d) >> 8)) >> 8 : ((a >> 8) * (s - d)) >> 8);
            break;
        case SWV_BLEND_ALPHA_ADD:
            s = d + (a >= OpaqueAlpha ? s : ((a >> 8) * s) >> 8);
            break;
        case SWV_BLEND_MODULATE:
            s = ((d >> 8) * (s + 1)) >> 8;
            break;
        case SWV_BLEND_MODULATE_X2:
            s = tex ? ((d >> 7) * s) >> 8 : ((d >> 8) * s) >> 7;
            break;
        case SWV_BLEND_REPLACE:
            break;
        }
        rgba[k] = s;
    }
}

struct TextureSpan {
    int pos[2]{}, step[2]{}, next[2]{}, end[3]{}, remaining = 0;
};

static int perspective(int value, int reciprocal)
{
    return static_cast<int32_t>((int64_t(value >> 7) * reciprocal) >> 23);
}

static void begin_texture_span(CssRasterizerStandard &r, int u, TextureSpan &s)
{
    auto &left = r.row.left.value.texture;
    auto &uv = r.gradients.uv[u];
    if (r.triangle_flags.affine) {
        s.pos[0] = left.s[u] >> 7;
        s.pos[1] = left.t[u] >> 7;
        s.step[0] = uv.coord[1].delta.x >> 7;
        s.step[1] = uv.coord[2].delta.x >> 7;
    } else {
        s.end[0] = left.q[u] + uv.coord[0].chunk_step;
        if (r.texture[u].format != SWV_IMAGE_NONE) {
            int inv = g_quick_scaledreciprocal(left.q[u], 46);
            s.end[1] = left.s[u] + uv.coord[1].chunk_step;
            s.end[2] = left.t[u] + uv.coord[2].chunk_step;
            s.pos[0] = perspective(left.s[u], inv);
            s.pos[1] = perspective(left.t[u], inv);
        }
    }
}

static void next_texture_block(CssRasterizerStandard &r, int u, TextureSpan &s, int count, bool first, bool guard_zero)
{
    auto &uv = r.gradients.uv[u];
    if (!first) {
        for (int k = 0; k < 3; ++k)
            s.end[k] += uv.coord[k].chunk_step;
        s.pos[0] = s.next[0];
        s.pos[1] = s.next[1];
    }
    s.remaining = upper(count, uv.chunk);
    int q, st[2], intervals;
    if (count > uv.chunk) {
        q = s.end[0] >> 6;
        st[0] = s.end[1];
        st[1] = s.end[2];
        intervals = uv.chunk;
    } else {
        if (count == 1)
            return;
        auto &right = r.row.right.value;
        q = (right.q[u] - uv.coord[0].delta.x) >> 6;
        st[0] = right.s[u] - uv.coord[1].delta.x;
        st[1] = right.t[u] - uv.coord[2].delta.x;
        intervals = count - 1;
    }
    int inv = g_quick_scaledreciprocal(guard_zero && !q ? 1 : q, 40);
    int div = g_quick_scaledreciprocal(intervals, 30) + 0x4000;
    for (int k = 0; k < 2; ++k) {
        s.next[k] = perspective(st[k], inv);
        s.step[k] = multiplyFixed(s.next[k] - s.pos[k], div) >> 14;
    }
}

static void texture_color(const SwvRasterTexture *t, const TextureSpan *sample, int rgba[])
{
    int s = sample->pos[0], v = sample->pos[1];
    if (t->clamp_s)
        s = clamp(s, 65535);
    if (t->clamp_t)
        v = clamp(v, 65535);
    int i = ((t->width * (uint16_t)s) >> 16) + ((t->height * (uint16_t)v) >> 16) * t->width;
    if (t->indices)
        i = t->indices[i];
    int color[3];
    if (t->rgb)
        unpack(t->rgb[i], color);
    else
        memcpy(color, rgba, sizeof(color));
    int a = t->alpha ? alpha16(t->alpha[i]) : 65536;
    if (t->format != SWV_IMAGE_ALPHA) {
        for (int k = 0; k < 3; ++k) {
            int c = rgba[k], n = color[k];
            switch (t->function) {
            case CssTexture2D::Add:
                c = upper(c + n, 65535);
                break;
            case CssTexture2D::Blend:
                c += ((t->blend[k] - c) * (n >> 8)) >> 8;
                break;
            case CssTexture2D::Decal:
                c += ((a >> 8) * (n - c)) >> 8;
                break;
            case CssTexture2D::Modulate:
                c = (n * (c >> 8)) >> 8;
                break;
            case CssTexture2D::Replace:
                c = n;
                break;
            }
            rgba[k] = c;
        }
    }
    if (t->function != CssTexture2D::Decal && (t->format == SWV_IMAGE_ALPHA || t->format == SWV_IMAGE_LUMINANCE_ALPHA || t->format == SWV_IMAGE_RGBA))
        rgba[3] = t->function == CssTexture2D::Replace ? a : (a * (rgba[3] >> 8)) >> 8;
}

void CssRasterizerStandard::DrawTexLine()
{
    int remaining = row.LineLength(), x = row.left.x;
    TextureSpan samples[2];
    for (int u = 0; u < texture_count; ++u)
        begin_texture_span(*this, u, samples[u]);

    uint8_t scratch = 0;
    uint8_t *dest_alpha = alpha && triangle_flags.alpha_write ? alpha + row.y * alpha_pitch : nullptr;
    auto value = row.left.value;
    if (remaining > 1 && !triangle_flags.limit_color)
        for (int &c : value.rgb)
            c = clamp(c, 65535);

    bool first = true;
    while (remaining > 0) {
        int block = remaining;
        if (!triangle_flags.affine) {
            for (int u = 0; u < texture_count; ++u) {
                if (!samples[u].remaining)
                    next_texture_block(*this, u, samples[u], remaining, first, true);
                block = std::min(block, samples[u].remaining);
            }
            for (int u = 0; u < texture_count; ++u)
                samples[u].remaining -= block;
            first = false;
        }
        do {
            if (!triangle_flags.depth_test || row.depth[x] >= (value.z >> DepthFractionBits)) {
                int rgba[4] = {value.rgb[0], value.rgb[1], value.rgb[2], value.alpha};
                for (int u = 0; u < texture_count; ++u)
                    if (texture[u].format != SWV_IMAGE_NONE)
                        texture_color(&texture[u], &samples[u], rgba);
                if ((rgba[3] >> 8) >= alpha_threshold) {
                    if (triangle_flags.depth_write)
                        row.depth[x] = value.z >> DepthFractionBits;
                    if (triangle_flags.fog_enabled) {
                        int factor = clamp(value.fog >> 3, 8191);
                        for (int k = 0; k < 3; ++k)
                            rgba[k] += (factor * (fog[k] - rgba[k])) >> 13;
                    }
                    uint8_t *ap = dest_alpha ? dest_alpha + x : &scratch;
                    if (mode != SWV_BLEND_REPLACE) {
                        int dest[4];
                        unpack(row.pixels[x], dest);
                        dest[3] = *ap << 8;
                        compose(mode, rgba, dest, true);
                    }
                    if (triangle_flags.limit_color || remaining == 1)
                        for (int &c : rgba)
                            c = clamp(c, 65535);
                    if (triangle_flags.color_write)
                        row.pixels[x] = (rgba[0] & 0xf800) | ((rgba[1] >> 10) * 32) | (rgba[2] >> 11);
                    *ap = rgba[3] >> 8;
                }
            }
            value.z += row.left.dx.z;
            for (int k = 0; k < 3; ++k)
                value.rgb[k] += row.left.dx.rgb[k];
            value.alpha += row.left.dx.alpha;
            value.fog += row.left.dx.fog;
            for (int u = 0; u < texture_count; ++u) {
                samples[u].pos[0] += samples[u].step[0];
                samples[u].pos[1] += samples[u].step[1];
            }
            ++x;
            --remaining;
        } while (--block);
    }
}

void CssRasterizerStandard::DrawLine()
{
    int x = row.left.x, z = row.left.value.z;
    int rgba[4] = {row.left.value.rgb[0], row.left.value.rgb[1], row.left.value.rgb[2], row.left.value.alpha};
    uint8_t scratch = 0;
    uint8_t *alpha_pixel = &scratch;
    if (alpha && triangle_flags.alpha_write)
        alpha_pixel = alpha + row.y * alpha_pitch + x;
    for (; x < row.right.x; ++x) {
        if (alpha_threshold <= (rgba[3] >> 8) && (!triangle_flags.depth_test || row.depth[x] >= (z >> DepthFractionBits))) {
            if (triangle_flags.depth_write)
                row.depth[x] = z >> DepthFractionBits;
            int color[4] = {rgba[0], rgba[1], rgba[2], rgba[3]};
            if (mode != SWV_BLEND_REPLACE) {
                int dest[4];
                unpack(row.pixels[x], dest);
                dest[3] = *alpha_pixel << 8;
                compose(mode, color, dest, false);
            }
            if (triangle_flags.color_write)
                row.pixels[x] = pack_dither(color, x, row.y);
            *alpha_pixel = clamp(color[3] >> 8, 255);
        }
        if (alpha && triangle_flags.alpha_write)
            ++alpha_pixel;
        z += row.left.dx.z;
        for (int k = 0; k < 3; ++k)
            rgba[k] += row.left.dx.rgb[k];
        rgba[3] += row.left.dx.alpha;
    }
}

void CssRasterizerStandard::DrawFlatLine()
{
    int x = row.left.x, z = row.left.value.z;
    const int *dither = row.dither[row.y & 1];
    uint16_t color = dither[x & 1], toggle = color ^ dither[(x & 1) ^ 1];
    for (; x < row.right.x; ++x) {
        if (row.depth[x] >= (z >> DepthFractionBits)) {
            row.depth[x] = z >> DepthFractionBits;
            row.pixels[x] = color;
        }
        color ^= toggle;
        z += row.left.dx.z;
    }
}

void CssRasterizerStandard::DrawOpaqueLine()
{
    int z = row.left.value.z;
    int rgb[] = {row.left.value.rgb[0], row.left.value.rgb[1], row.left.value.rgb[2]};
    for (int x = row.left.x; x < row.right.x; ++x) {
        if (row.depth[x] >= (z >> DepthFractionBits)) {
            row.depth[x] = z >> DepthFractionBits;
            row.pixels[x] = pack_dither(rgb, x, row.y);
        }
        z += row.left.dx.z;
        for (int k = 0; k < 3; ++k)
            rgb[k] += row.left.dx.rgb[k];
    }
}

void CssRasterizerStandard::DrawTransparentLine()
{
    int z = row.left.value.z, opacity = row.left.value.alpha;
    int rgb[] = {row.left.value.rgb[0], row.left.value.rgb[1], row.left.value.rgb[2]};
    for (int x = row.left.x; x < row.right.x; ++x) {
        if (row.depth[x] >= (z >> DepthFractionBits)) {
            int color[3] = {rgb[0], rgb[1], rgb[2]};
            if (opacity < OpaqueAlpha) {
                int dest[3];
                unpack(row.pixels[x], dest);
                for (int k = 0; k < 3; ++k)
                    color[k] = dest[k] + (((opacity >> 8) * (color[k] - dest[k])) >> 8);
            }
            row.pixels[x] = pack_dither(color, x, row.y);
        }
        z += row.left.dx.z;
        opacity += row.left.dx.alpha;
        for (int k = 0; k < 3; ++k)
            rgb[k] += row.left.dx.rgb[k];
    }
}

static bool visible_span(const CssRasterizerStandard &r)
{
    int near_z = r.row.left.value.z;
    if (r.row.left.dx.z < 0)
        near_z += r.row.LineLength() * r.row.left.dx.z;
    near_z >>= DepthFractionBits;
    for (int x = r.row.left.x; x < r.row.right.x; ++x)
        if (r.row.depth[x] >= near_z)
            return true;
    return false;
}

static int power_of_two_texel(const SwvRasterTexture &tex, const TextureSpan &s)
{
    int x = uint16_t(s.pos[0]) >> (16 - tex.width_shift);
    int y = uint16_t(s.pos[1]) >> (16 - tex.height_shift);
    int index = x + (y << tex.width_shift);
    return tex.indices ? tex.indices[index] : index;
}

void CssRasterizerStandard::DrawUnLitTexLine()
{
    if (!visible_span(*this))
        return;
    const auto &tex = texture[0];
    TextureSpan sample;
    begin_texture_span(*this, 0, sample);
    int remaining = row.LineLength(), x = row.left.x, z = row.left.value.z;
    while (remaining > 0) {
        int block = remaining;
        if (!triangle_flags.affine) {
            next_texture_block(*this, 0, sample, remaining, x == row.left.x, false);
            block = sample.remaining;
        }
        remaining -= block;
        for (int i = 0; i < block; ++i, ++x) {
            if (row.depth[x] >= (z >> DepthFractionBits)) {
                int index = power_of_two_texel(tex, sample);
                if (!tex.alpha || !alpha_threshold || (alpha16(tex.alpha[index]) >> 8) >= alpha_threshold) {
                    row.depth[x] = z >> DepthFractionBits;
                    row.pixels[x] = tex.rgb[index];
                }
            }
            z += row.left.dx.z;
            sample.pos[0] = uint16_t(sample.pos[0] + sample.step[0]);
            sample.pos[1] = uint16_t(sample.pos[1] + sample.step[1]);
        }
    }
}

template<bool transparent>
static void lit_texture_span(CssRasterizerStandard &r)
{
    TextureSpan sample;
    begin_texture_span(r, 0, sample);
    if (!visible_span(r))
        return;
    const auto &tex = r.texture[0];
    auto &row = r.row;
    auto value = row.left.value;
    int remaining = row.LineLength(), x = row.left.x;
    if (remaining > 1 && !r.triangle_flags.limit_color)
        for (int &c : value.rgb)
            c = clamp(c, 65535);
    while (remaining > 0) {
        int block = remaining;
        if (!r.triangle_flags.affine) {
            next_texture_block(r, 0, sample, remaining, x == row.left.x, false);
            block = sample.remaining;
        }
        do {
            if (row.depth[x] >= (value.z >> DepthFractionBits)) {
                int index = power_of_two_texel(tex, sample);
                int color[3];
                unpack(tex.rgb[index], color);
                int opacity = tex.alpha ? (alpha16(tex.alpha[index]) * (value.alpha >> 8)) >> 8 : (value.alpha >> 8) << 8;
                if ((opacity >> 8) >= r.alpha_threshold) {
                    for (int k = 0; k < 3; ++k)
                        color[k] = (color[k] * (value.rgb[k] >> 8)) >> 8;
                    if constexpr (transparent) {
                        if (opacity < OpaqueAlpha) {
                            int dest[3];
                            unpack(row.pixels[x], dest);
                            for (int k = 0; k < 3; ++k)
                                color[k] = dest[k] + ((opacity * ((color[k] - dest[k]) >> 8)) >> 8);
                        }
                    } else {
                        row.depth[x] = value.z >> DepthFractionBits;
                    }
                    if (r.triangle_flags.limit_color || remaining == 1)
                        for (int &c : color)
                            c = clamp(c, 65535);
                    row.pixels[x] = (color[0] & 0xf800) | ((color[1] >> 10) * 32) | (color[2] >> 11);
                }
            }
            ++x;
            --remaining;
            value.z += row.left.dx.z;
            for (int k = 0; k < 3; ++k)
                value.rgb[k] += row.left.dx.rgb[k];
            value.alpha += row.left.dx.alpha;
            sample.pos[0] = uint16_t(sample.pos[0] + sample.step[0]);
            sample.pos[1] = uint16_t(sample.pos[1] + sample.step[1]);
        } while (--block);
    }
}

void CssRasterizerStandard::DrawLitTexLine() { lit_texture_span<false>(*this); }
void CssRasterizerStandard::DrawTransparentTexLine() { lit_texture_span<true>(*this); }

void CssRasterizerStandard::CalcFlatColor()
{
    const int *rgb = vertices[0]->rgb;
    int red = clamp(rgb[0], 0xf800) >> 9;
    int green = clamp(rgb[1], 0xfc00) >> 8;
    int blue = clamp(rgb[2], 0xf800) >> 9;
    for (int y = 0; y < 2; ++y) {
        for (int x = 0; x < 2; ++x) {
            int d = (y + 1) ^ (x * 2);
            row.dither[y][x] = (((red + d) >> 2) << 11) |
                               (((green + d) >> 2) << 5) | ((blue + d) >> 2);
        }
    }
}

/* 0x2e2ad8 and 0x2e3a44. Screen winding orders the forward edge on the
 * left and the backward edge on the right. A reversed span ends the triangle.
 */
void CssRasterizerStandard::DrawTriangleFast(SssProjectedVertex *a, SssProjectedVertex *b,
                                           SssProjectedVertex *c)
{
    vertices[0] = a;
    vertices[1] = b;
    vertices[2] = c;
    DrawTriangle();
}

void CssRasterizerStandard::DrawTriangle()
{
    SssProjectedVertex *a = vertices[0];
    triangle_flags = flags;
    int top = 0, max_y = a->y, min_x = a->x, max_x = a->x;
    for (int i = 1; i < 3; ++i) {
        const auto &v = *vertices[i];
        if (v.y < vertices[top]->y)
            top = i;
        max_y = std::max(max_y, v.y);
        min_x = std::min(min_x, v.x);
        max_x = std::max(max_x, v.x);
    }
    row.y = (vertices[top]->y + 15) >> 4;
    int last = (max_y + 15) >> 4;
    if (row.y == last || ((min_x + 15) >> 4) == ((max_x + 15) >> 4))
        return;
    auto *b = vertices[1], *c = vertices[2];
    if (triangle_flags.textured && triangle_flags.fog_enabled && a->fog == 255 && b->fog == 255 && c->fog == 255) {
        triangle_flags.fog_enabled = triangle_flags.textured = false;
        for (int k = 0; k < 3; ++k)
            a->rgb[k] = b->rgb[k] = c->rgb[k] = fog[k];
    }
    triangle_flags.limit_color = mode == SWV_BLEND_ALPHA_ADD || mode == SWV_BLEND_MODULATE_X2 ||
                                 texture[0].function == CssTexture2D::Add || texture[1].function == CssTexture2D::Add;
    triangle_flags.smooth = a->alpha != b->alpha || a->alpha != c->alpha;
    for (int k = 0; k < 3; ++k) {
        int shift = k == 1 ? 8 : 9;
        triangle_flags.smooth |= (a->rgb[k] >> shift) != (b->rgb[k] >> shift) ||
                                 (a->rgb[k] >> shift) != (c->rgb[k] >> shift);
    }
    if (triangle_flags.smooth || triangle_flags.textured) {
        unsigned all = ~0u, any = 0;
        for (int k = 0; k < 3; ++k) {
            all &= a->rgb[k] & b->rgb[k] & c->rgb[k];
            any |= a->rgb[k] | b->rgb[k] | c->rgb[k];
        }
        if (!all || any >= 65536)
            triangle_flags.limit_color = true;
    }
    if (triangle_flags.textured) {
        span = &CssRasterizerStandard::DrawTexLine;
        const auto &tex = texture[0];
        bool single = tex.format != SWV_IMAGE_NONE && texture[1].format == SWV_IMAGE_NONE && tex.width_shift >= 0 && tex.height_shift >= 0 &&
                      !(alpha && triangle_flags.alpha_write) && triangle_flags.color_write && triangle_flags.depth_test &&
                      !triangle_flags.fog_enabled && !tex.clamp_s && !tex.clamp_t &&
                      (tex.format == SWV_IMAGE_RGB || tex.format == SWV_IMAGE_RGBA);
        if (single && mode == SWV_BLEND_REPLACE && triangle_flags.depth_write) {
            bool white = !triangle_flags.smooth && a->rgb[0] == 65536 && a->rgb[1] == 65536 && a->rgb[2] == 65536 && a->alpha == 255;
            if (tex.function == CssTexture2D::Replace || (tex.function == CssTexture2D::Modulate && white))
                span = &CssRasterizerStandard::DrawUnLitTexLine;
            else if (tex.function == CssTexture2D::Modulate)
                span = &CssRasterizerStandard::DrawLitTexLine;
        } else if (single && mode == SWV_BLEND_ALPHA && !triangle_flags.depth_write && tex.format == SWV_IMAGE_RGBA && tex.function == CssTexture2D::Modulate) {
            span = &CssRasterizerStandard::DrawTransparentTexLine;
        }
    } else {
        span = &CssRasterizerStandard::DrawLine;
        if (!alpha_threshold && triangle_flags.color_write && !(alpha && triangle_flags.alpha_write) && triangle_flags.depth_test) {
            if (triangle_flags.depth_write && mode == SWV_BLEND_REPLACE) {
                span = triangle_flags.smooth ? &CssRasterizerStandard::DrawOpaqueLine : &CssRasterizerStandard::DrawFlatLine;
                CalcFlatColor();
            } else if (!triangle_flags.depth_write && mode == SWV_BLEND_ALPHA) {
                span = &CssRasterizerStandard::DrawTransparentLine;
            }
        }
    }

    SetGradients();

    struct Edge { int index, end, x, dx; };
    Edge left{top, row.y, 0, 0}, right{top, row.y, 0, 0};
    int remaining = 3;
    while (row.y < last) {
        auto begin = [&](Edge &edge, bool on_left) {
            int i = edge.index;
            edge.index = on_left ? (i == 2 ? 0 : i + 1) : (i == 0 ? 2 : i - 1);
            const auto &v = *vertices[i], &next = *vertices[edge.index];
            edge.end = (next.y + 15) >> 4;
            if (row.y >= edge.end)
                return;
            edge.dx = ((next.x - v.x) * g_quick_scaledreciprocal(next.y - v.y, 20)) >> 8;
            int off_y = ((v.y + 15) & ~15) - v.y;
            edge.x = ((v.x << 8) + 4095) + ((edge.dx * off_y) >> 4);
            int off_x = ((edge.x >> 8) & ~15) - v.x;
            int slope = edge.dx >> 12;
            if (on_left) {
                row.left.fraction = edge.x & 4095;
                row.left.fraction_step = edge.dx & 4095;
                auto start = [&](int attr, int base, int bias) {
                    const auto &g = gradients.at(attr);
                    row.left.value.at(attr) = base + ((g.x * off_x + g.y * off_y) >> 4) + bias;
                    int step = g.y + slope * g.x;
                    row.left.step[0].at(attr) = step;
                    row.left.step[1].at(attr) = step + row.left.dx.at(attr);
                };
                start(Z, v.z, 0);
                if (triangle_flags.smooth) {
                    start(ALPHA, 257 * v.alpha, 128);
                    for (int k = 0; k < 3; ++k)
                        start(RED + k, triangle_flags.textured ? v.rgb[k] : upper(v.rgb[k], 65535), 128);
                }
                if (triangle_flags.fog_enabled)
                    start(FOG, 257 * v.fog, 128);
            }
            if (triangle_flags.textured) {
                if (!on_left) {
                    row.right.fraction = edge.x & 4095;
                    row.right.fraction_step = edge.dx & 4095;
                }
                auto &value = on_left ? row.left.value.texture : row.right.value;
                auto &step0 = on_left ? row.left.step[0].texture : row.right.step[0];
                auto &step1 = on_left ? row.left.step[1].texture : row.right.step[1];
                int fx = ((off_x << 16) >> 4) + 2048, fy = ((off_y << 16) >> 4) + 2048;
                for (int u = 0; u < texture_count; ++u) {
                    const auto &uv = gradients.uv[u];
                    int q = uv.q[i];
                    for (int coord = triangle_flags.affine ? 1 : 0; coord < 3; ++coord) {
                        int attr = Q0 + 3 * u + coord;
                        auto &g = uv.coord[coord].delta;
                        int texcoord = coord == 1 ? v.tex[u].s : v.tex[u].t;
                        int64_t offset = int64_t(fx) * g.x + int64_t(fy) * g.y;
                        if (coord == 0)
                            value.at(attr) = q + (offset >> 16);
                        else if (triangle_flags.affine)
                            value.at(attr) = (texcoord << 7) + (offset >> 16);
                        else
                            value.at(attr) = (int64_t(q) * texcoord + offset) >> 16;
                        step0.at(attr) = g.y + slope * g.x;
                        step1.at(attr) = step0.at(attr) + g.x;
                    }
                }
            }
        };
        if (row.y >= right.end) {
            do {
                begin(right, false);
                --remaining;
            } while (remaining > 0 && row.y >= right.end);
        }
        if (row.y >= left.end) {
            do {
                begin(left, true);
                --remaining;
            } while (remaining > 0 && row.y >= left.end);
        }
        row.left.x = left.x >> 12;
        row.right.x = right.x >> 12;
        if (row.y >= 0 && row.y < height) {
            row.pixels = reinterpret_cast<uint16_t *>(reinterpret_cast<uint8_t *>(pixels) + row.y * pitch);
            row.depth = depth + row.y * width;
            if (row.left.x >= 0 && row.right.x <= width && row.left.x < row.right.x)
                (this->*span)();
            else if (row.left.x > row.right.x)
                return;
            else if (row.left.x < row.right.x)
                ClipHorizontalLine();
        }
        ++row.y;
        left.x += left.dx;
        right.x += right.dx;
        auto advance = [](auto &edge) -> auto & {
            int sum = edge.fraction + edge.fraction_step;
            edge.fraction = sum & 4095;
            return edge.step[sum >> 12];
        };
        auto &step = advance(row.left);
        row.left.value.z += step.z;
        row.left.value.alpha += step.alpha;
        if (triangle_flags.smooth)
            for (int k = 0; k < 3; ++k)
                row.left.value.rgb[k] += step.rgb[k];
        if (triangle_flags.fog_enabled)
            row.left.value.fog += step.fog;
        if (triangle_flags.textured) {
            auto &right_step = advance(row.right);
            for (int u = 0; u < texture_count; ++u) {
                for (int coord = triangle_flags.affine ? 1 : 0; coord < 3; ++coord) {
                    int attr = Q0 + 3 * u + coord;
                    row.left.value.texture.at(attr) += step.texture.at(attr);
                    row.right.value.at(attr) += right_step.at(attr);
                }
            }
        }
    }
}

void CssRasterizerStandard::ClipHorizontalLine()
{
    SssTriVals saved = row;
    if (row.left.x >= width || row.right.x <= 0)
        return;
    if (row.left.x < 0) {
        int offset = -row.left.x;
        for (int attr = Z; attr < Q0 + 3 * texture_count; ++attr)
            row.left.value.at(attr) += offset * gradients.at(attr).x;
        row.left.x = 0;
    }
    if (row.right.x > width) {
        int offset = row.right.x - width;
        for (int attr = Q0; attr < Q0 + 3 * texture_count; ++attr)
            row.right.value.at(attr) -= offset * gradients.at(attr).x;
        row.right.x = width;
    }
    (this->*span)();
    row = saved;
}

/* Sprite rectangle dispatch, 0x2e3e14/0x2e45f4. Its direct indexed
 * transfer precedes conversion to the two normally shaded triangles. */
void CssRasterizerStandard::DrawSprite(bool scaled, SssProjectedVertex *a, SssProjectedVertex *b,
                                        SssProjectedVertex *c, SssProjectedVertex *d)
{
    vertices[0] = a;
    vertices[1] = b;
    vertices[2] = c;
    vertices[3] = d;
    if (!DrawSpriteOptimised(scaled)) {
        DrawTriangle();
        vertices[0] = c;
        vertices[1] = b;
        vertices[2] = d;
        DrawTriangle();
    }
}

bool CssRasterizerStandard::DrawSpriteOptimised(bool scaled)
{
    const SwvRasterTexture *tex = nullptr;
    for (const auto &unit : texture) {
        if (unit.format != SWV_IMAGE_NONE) {
            if (tex) return false;
            tex = &unit;
        }
    }
    if (!tex || vertices[0]->alpha != 255 || (alpha && flags.alpha_write))
        return false;
    if (tex->function != CssTexture2D::Replace || mode != SWV_BLEND_REPLACE ||
        !flags.color_write || flags.fog_enabled || flags.depth_write != flags.depth_test)
        return false;
    if (!tex->indices || (tex->format != SWV_IMAGE_RGB && tex->format != SWV_IMAGE_RGBA))
        return false;

    const auto &a = *vertices[0], &b = *vertices[1], &c = *vertices[2];
    int w = (c.x - a.x) >> 4, h = (b.y - a.y) >> 4;
    if (w <= 0 || h <= 0)
        return true;
    int x = (a.x + 15) >> 4, y = (a.y + 15) >> 4;
    uint16_t z = static_cast<uint16_t>(a.z >> DepthFractionBits);
    int s = tex->width * a.tex[0].s, t = tex->height * a.tex[0].t;
    int ds = c.tex[0].s - a.tex[0].s, dt = b.tex[0].t - a.tex[0].t;
    const ptrdiff_t color_size = ptrdiff_t(height - 1) * pitch + 2 * width;
    const ptrdiff_t depth_size = ptrdiff_t(height) * width;

    auto blit = [&]<bool scale, bool rgba, bool zbuffer>() {
        int s_step, t_step;
        if constexpr (scale) {
            s_step = (tex->width * ds) / w;
            t_step = (tex->height * dt) / h;
        } else {
            w = std::min(w, tex->width);
            h = std::min(h, tex->height);
            s_step = ds < 0 ? -1 : 1;
            t_step = dt < 0 ? -tex->width : tex->width;
        }
        ptrdiff_t color_offset = ptrdiff_t(y) * pitch + 2 * x;
        ptrdiff_t depth_offset = ptrdiff_t(y) * width + x;
        int first_texel = (t >> 16) * tex->width + (s >> 16);
        for (int j = 0; j < h; ++j, color_offset += pitch, depth_offset += width) {
            // The blitter addresses the target linearly even across a row boundary.
            int first = 0, end = w;
            if (color_offset < 0 || color_offset + 2 * w > color_size) {
                first = std::clamp<ptrdiff_t>((1 - color_offset) / 2, 0, w);
                end = std::clamp<ptrdiff_t>((color_size - color_offset) / 2, 0, w);
            }
            if constexpr (zbuffer) {
                if (depth_offset < 0 || depth_offset + w > depth_size) {
                    first = std::max<ptrdiff_t>(first, std::min<ptrdiff_t>(w, -depth_offset));
                    end = std::min<ptrdiff_t>(end, std::max<ptrdiff_t>(0, depth_size - depth_offset));
                }
            }
            if (first < end) {
                auto *dst = reinterpret_cast<uint8_t *>(pixels) + color_offset + 2 * first;
                int u = (scale ? s : first_texel) + s_step * first;
                int tex_row = (t >> 16) * tex->width;
                for (int i = first; i < end; ++i, u += s_step, dst += 2) {
                    if constexpr (zbuffer) {
                        if (depth[depth_offset + i] < z)
                            continue;
                    }
                    int index = tex->indices[scale ? tex_row + (u >> 16) : u];
                    if constexpr (rgba) {
                        if (tex->alpha[index] < alpha_threshold)
                            continue;
                    }
                    memcpy(dst, tex->rgb + index, sizeof(uint16_t));
                    if constexpr (zbuffer)
                        depth[depth_offset + i] = z;
                }
            }
            if constexpr (scale)
                t += t_step;
            else
                first_texel += t_step;
        }
    };
    auto draw = [&]<bool scale>() {
        if (tex->format == SWV_IMAGE_RGBA) {
            if (flags.depth_test && depth) blit.template operator()<scale, true, true>();
            else blit.template operator()<scale, true, false>();
        } else {
            if (flags.depth_test && depth) blit.template operator()<scale, false, true>();
            else blit.template operator()<scale, false, false>();
        }
    };
    if (scaled) draw.template operator()<true>();
    else draw.template operator()<false>();
    return true;
}

void CssRasterizerStandard::SetCompositingMode(const CssCompositingMode *compositing)
{
    mode = static_cast<SwvBlendMode>(compositing->GetBlending());
    alpha_threshold = saturatingTruncate(compositing->GetAlphaThreshold() * 65536.0f) >> 8;
    flags.depth_test = flags.depth_write = false;
    depth_offset = false;
    depth_factor = depth_units = 0;
    if (depth_enabled) {
        flags.depth_write = compositing->GetDepthWrite();
        flags.depth_test = compositing->GetDepthTest();
        depth_factor = toFixed16(compositing->GetDepthOffsetFactor());
        depth_units = toFixed16(compositing->GetDepthOffsetUnits());
        depth_offset = depth_factor || depth_units;
    }
    flags.color_write = compositing->GetColorWrite();
    flags.alpha_write = compositing->GetAlphaWrite();
}

void CssRasterizerStandard::SetFog(const CssFog *fog_state)
{
    flags.fog_enabled = fog_state && fog_state->GetMode() != SWV_FOG_NONE;
    if (flags.fog_enabled) {
        uint32_t color = fog_state->GetColor();
        for (int k = 0; k < 3; ++k)
            fog[k] = ((color >> (16 - 8 * k)) & 255) << 8;
    }
}

static void bind_image(SwvRasterTexture &unit, CssImage2D &image)
{
    int w = image.GetWidth();
    unit.setExtent(w, image.GetHeight());
    if (image.GetpPalette()) {
        unit.indices = static_cast<const uint8_t *>(image.GetpPixels());
        unit.rgb = image.GetpPalette();
    } else {
        unit.indices = nullptr;
        unit.rgb = static_cast<const uint16_t *>(image.GetpPixels());
    }
    unit.alpha = image.GetpAlpha();
}

void CssRasterizerStandard::SetTexture(int index, CssTexture2D *tex, int polygon_flags)
{
    if (static_cast<unsigned>(index) >= 2)
        return;
    auto &unit = texture[index];
    if (tex && tex->GetImage()) {
        bind_image(unit, *tex->GetImage());
        unit.function = tex->GetBlending();
        for (int k = 0; k < 3; ++k)
            unit.blend[k] = ((tex->GetBlendColor() >> (16 - 8 * k)) & 255) << 8;
        unit.format = tex->GetDataFormat();
        unit.clamp_s = tex->GetWrappingS() == CssTexture2D::Clamp;
        unit.clamp_t = tex->GetWrappingT() == CssTexture2D::Clamp;
        flags.textured = true;
        flags.affine = !(polygon_flags & CssPolygonMode::PerspectiveCorrection);
    } else {
        unit.rgb = nullptr;
        unit.alpha = unit.indices = nullptr;
        unit.format = SWV_IMAGE_NONE;
    }
    texture_count = 0;
    for (int i = 0; i < 2; ++i)
        if (texture[i].format != SWV_IMAGE_NONE)
            texture_count = i + 1;
    if (!texture_count)
        flags.textured = false;
}

void CssRasterizerStandard::SetSpriteImage(CssImage2D *image, CssTexture2D::EssBlending blending)
{
    texture[1].format = SWV_IMAGE_NONE;
    texture[1].rgb = nullptr;
    texture[1].alpha = texture[1].indices = nullptr;
    texture_count = 1;
    if (!image) {
        texture_count = 0;
        flags.textured = false;
    }
    bind_image(texture[0], *image);
    texture[0].function = blending;
    texture[0].format = static_cast<SwvImageFormat>(image->GetFormat());
    texture[0].clamp_s = texture[0].clamp_t = false;
    flags.textured = flags.affine = true;
}
