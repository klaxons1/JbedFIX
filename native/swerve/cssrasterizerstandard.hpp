#ifndef SWERVE_CSSRASTERIZERSTANDARD_HPP
#define SWERVE_CSSRASTERIZERSTANDARD_HPP
#include "object_classes.hpp"
#include "render.h"

struct SwvRasterTexture {
    SwvImageFormat format;
    CssTexture2D::EssBlending function;
    int blend[3], width_shift, height_shift, width, height;
    bool clamp_s, clamp_t;
    const uint16_t *rgb;
    const uint8_t *alpha, *indices;
    void setExtent(int width, int height);
};

struct CssRasterizerStandard : public CssHeapObject {
    enum Attribute { Z, RED, GREEN, BLUE, ALPHA, FOG, Q0, S0, T0, Q1, S1, T1, ATTRS };
    struct TextureValues {
        int q[2], s[2], t[2];
        int &at(int attribute);
    };
    struct Values {
        int z;
        TextureValues texture;
        int rgb[3], alpha, fog;
        int &at(int attribute);
    };
    template<class T> struct ScanEdge {
        int x, fraction, fraction_step;
        T value, dx, step[2];
    };
    struct SssTriVals {
        int LineLength() const { return right.x - left.x; }
        int y;
        uint16_t *pixels, *depth;
        ScanEdge<Values> left;
        ScanEdge<TextureValues> right;
        int dither[2][2];
    } row = {};
    SwvRasterTexture texture[2] = {};
    struct Gradient { int x, y; };
    struct TextureGradient {
        int chunk, q[3];
        struct { Gradient delta; int chunk_step; } coord[3];
    };
    struct Gradients {
        Gradient z, rgb[3], fog, alpha;
        TextureGradient uv[2];
        Gradient &at(int attribute);
    } gradients = {};
    struct Flags {
        bool color_write = false, smooth = false, textured = false, affine = false;
        bool depth_test = false, depth_write = false;
        bool fog_enabled = false, limit_color = false, alpha_write = false;
    } triangle_flags = {};
    int alpha_threshold = 0;
    uint8_t *alpha = nullptr;
    int alpha_pitch = 0;
    SwvBlendMode mode = SWV_BLEND_REPLACE;
    int texture_count = 0, fog[3] = {};
    uint16_t *pixels = nullptr;
    int width = 0, height = 0, pitch = 0;
    Flags flags = {};
    SssProjectedVertex *vertices[4] = {};
    uint16_t *depth = nullptr;
    int depth_clear = 0;
    bool depth_enabled = true, depth_offset = false;
    int depth_factor = 0, depth_units = 0;
    void (CssRasterizerStandard::*span)();

    CssRasterizerStandard();
    ~CssRasterizerStandard() override;
    void Construct();
    void SetupBackBuffer(uint16_t *pixels, int width, int height, int pitch, uint16_t *depth,
                         bool enable_depth);
    void UpdateBackBuffer(uint16_t *pixels);
    void SetHints(bool enable_depth);
    void SetupAlphaBuffer(uint8_t *alpha, int pitch);
    void SetCompositingMode(const CssCompositingMode *);
    void SetFog(const CssFog *);
    void FillRect(int x, int y, int w, int h, uint16_t color, int opacity);
    void TexRect(int x, int y, int w, int h, int s, int t, int ds, int dt);
    void DrawTriangleFast(SssProjectedVertex *, SssProjectedVertex *, SssProjectedVertex *);
    void DrawTriangle();
    void SetTexture(int unit, CssTexture2D *, int polygon_flags);
    void SetSpriteImage(CssImage2D *, CssTexture2D::EssBlending);
    void SetGradients();
    void ClipHorizontalLine();
    void CalcFlatColor();
    void DrawSprite(bool scaled, SssProjectedVertex *, SssProjectedVertex *, SssProjectedVertex *, SssProjectedVertex *);
    bool DrawSpriteOptimised(bool scaled);
    void DrawLine();
    void DrawOpaqueLine();
    void DrawFlatLine();
    void DrawTransparentLine();
    void DrawTexLine();
    void DrawUnLitTexLine();
    void DrawLitTexLine();
    void DrawTransparentTexLine();

};
#endif
