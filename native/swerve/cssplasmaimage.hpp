#ifndef SWERVE_CSSPLASMAIMAGE_HPP
#define SWERVE_CSSPLASMAIMAGE_HPP

#include "image_class.hpp"
#include "csscolor.hpp"
#include "engine.h"

struct SssKnot {
    int32_t x, y;
};

class CssWarpMap : public CssHeapObject {
public:
    uint8_t smooth = 0;
    CssArray<SssKnot> points;

    void SerializeIn(CssSerializeBufferObjectsIn &);
    void CloneHelper(const CssWarpMap &source);
    void InsertKnot(int index, const SssKnot &knot);
    SwvFixedWord Warp(SwvFixedWord x) const;
    SwvFixedWord WarpClamped(SwvFixedWord x) const;
};

class CssRandomNumber {
public:
    static constexpr uint32_t Multiplier = 1664525u, Increment = 1013904223u;
    virtual ~CssRandomNumber();
    static void operator delete(void *object) noexcept { swvFree(object); }
    uint32_t seed = 0;
    mutable uint32_t random_state = 0;
    SwvFixedWord Random() const;
};

class CssPlasmaImage : public CssImage2D, public CssRandomNumber {
public:
    using CssHeapObject::operator delete;
    enum EssPattern { Grid = 1, StaggeredRows, AlternatingAxes, HexagonalTiles, ConcentricRings };
    int width_shift = 7, height_shift = 7, noise_shift = 0, displacement = 0;
    int pattern = Grid, tile_x_shift = 4, tile_y_shift = 4;
    CssWarpMap curves[4];
    CssWarpMap *curve_index[4];
    int weights[2][16] = {};
    CssColor colors[4];
    int locks = 0;
    mutable bool dirty = true;

    CssPlasmaImage();
    enum EssWarpMap { WarpU, WarpV, BlendU, BlendV };
    static IssSerializable *FactoryCreate();
    void Construct();
    void CloneHelper(const CssPlasmaImage &source);
    void InsertWarpMapKnot(EssWarpMap map, int index, float x, float y);
    SwvFixedWord SeededRandom(SwvFixedWord value) const;
    void ReCache() const { dirty = true; }
    void ReCalculate() const;
    void BlockCache(bool block);
    int Type() const override { return PlasmaImageObject; }
    int GetWidth() const override { ReCalculate(); return CssImage2D::GetWidth(); }
    int GetHeight() const override { ReCalculate(); return CssImage2D::GetHeight(); }
    void *GetpPixels() const override { ReCalculate(); return CssImage2D::GetpPixels(); }
    CssObject3D *Clone() const override;
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
};

namespace plasma_fixed {
enum { HALF = 32768, ONE = 65536, MIN_WARP_SPAN = 66 };

inline int magnitude(int a) { return a < 0 ? -a : a; }
inline int mul16(int a, int b) { return (int32_t)(((int64_t)a * b) >> 16); }
inline int div16(int a, int b) { return b ? (int32_t)((int64_t)a * ONE / b) : -1; }
inline int recip(int a) { return g_quick_scaledreciprocal(a, 32); }
inline int clamp01(int a) { return a < 0 ? 0 : a > ONE ? ONE : a; }
inline int clampWarpSpan(int span) { return span < MIN_WARP_SPAN ? MIN_WARP_SPAN : span; }
}

#endif
