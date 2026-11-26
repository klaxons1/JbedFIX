#include "legacy_math.hpp"
#include "graphics3d_state.h"
#include "object_classes.hpp"
#include "platform.h"
#include "cssfixed1616.hpp"
#include <algorithm>
#include <cfloat>
#include <cmath>

namespace {
constexpr int MinimumLightDenominator = 6;
}

static int mul(int a, int b)
{
    return (int)((int64_t)a * b >> 16);
}

bool CssActiveLightStandard::Initialize(const CssLight &source, const CssMatrix &transform)
{
    const int mode = source.GetMode();
    const auto nonzero = [](float value) { return !(std::abs(value) < FLT_MIN); };
    valid = nonzero(source.GetIntensity()) &&
            (mode == CssLight::Ambient || nonzero(source.GetConstantAttenuation()) ||
             nonzero(source.GetLinearAttenuation()) || nonzero(source.GetQuadraticAttenuation()));
    if (!valid)
        return false;
    diffuse_enabled = mode != CssLight::Ambient;
    specular_enabled = false;
    color.SetPackedRGBA8(source.GetColor());
    color *= source.GetIntensity();
    scope = source.GetScope();
    shade = nullptr;
    last_w = 0;
    exponent = 0;
    position_scale = 1;
    if (mode == CssLight::Directional || mode == CssLight::Spot) {
        CssVector3D axis{-transform.m[8], -transform.m[9], -transform.m[10]};
        axis.Unit();
        direction = CssFixedVector3D(axis);
    }
    if (mode == CssLight::Omni || mode == CssLight::Spot) {
        center = {transform.m[12], transform.m[13], transform.m[14]};
        if (!(transform.flags & MatrixAffineFlag)) {
            const float inv_w = 1 / transform.m[15];
            center *= inv_w;
        }
        float bound = std::fmax(std::abs(center.x), std::fmax(std::abs(center.y), std::abs(center.z)));
        while (bound > 127.f) {
            ++exponent;
            bound *= 0.5f;
            position_scale *= 0.5f;
        }
        while (bound > 0 && bound < .25f) {
            --exponent;
            bound *= 2.0f;
            position_scale *= 2.0f;
        }
        if (exponent)
            center *= position_scale;
        position = CssFixedVector3D(center);
    }
    ambient = false;
    switch (mode) {
    case CssLight::Directional:
        shade = &CssActiveLightStandard::LightVertexParallel;
        break;
    case CssLight::Omni:
        shade = &CssActiveLightStandard::LightVertexOmni;
        break;
    case CssLight::Spot:
        cutoff = toFixed16(legacy_math::cos(source.GetSpotAngle() * radiansPerDegree));
        spot_power = toFixed16(source.GetSpotExponent());
        shade = &CssActiveLightStandard::LightVertexSpot;
        break;
    default:
        ambient = true;
        break;
    }
    constant = source.GetConstantAttenuation();
    linear = source.GetLinearAttenuation();
    quadratic_root = source.GetQuadraticAttenuation();
    attenuated = constant != 1 || linear || quadratic_root;
    if (attenuated) {
        if (quadratic_root)
            quadratic_root = std::sqrt(quadratic_root);
        attenuation[0] = toFixed16(constant);
        float inverse = 1 / position_scale;
        linear *= inverse;
        quadratic_root *= inverse;
        attenuation[1] = toFixed16(std::fmin(linear, 32767.f));
        attenuation[2] = toFixed16(std::fmin(quadratic_root, 32767.f));
    }
    return true;
}

bool CssActiveLightStandard::SetSurfaceParameters(const CssMaterial *source, int flags, int mesh_scope,
                                                   CssColor *ambient_color)
{
    enabled = false;
    if (!(scope & mesh_scope))
        return false;
    if (ambient && ambient_color) {
        *ambient_color += color;
        return false;
    }
    if (source) {
        diffuse_enabled = (source->GetColor(CssMaterial::Diffuse) & 0xffffff) != 0;
        specular_enabled = (source->GetColor(CssMaterial::Specular) & 0xffffff) != 0;
        if (diffuse_enabled || specular_enabled) {
            polygon = flags;
            enabled = true;
            if (specular_enabled)
                half_shininess = toFixed16(source->GetShininess()) >> 1;
        }
    }
    return enabled;
}

static SwvFixedWord ss_quick_powRange1(SwvFixedWord base, SwvFixedWord exponent)
{
    const int numerator = mul(base, exponent) + base;
    return g_divide_int64_int64(int64_t(numerator) * 65536, base + exponent);
}

static SwvFixedWord ss_quick_powRange2(SwvFixedWord base, SwvFixedWord exponent)
{
    const int factor = mul(exponent >> 2, base - 65536) + 65536;
    return factor > 0 ? mul(mul(base, factor), factor) : 0;
}

inline SwvFixedWord ss_quick_pow(SwvFixedWord base, SwvFixedWord exponent)
{
    if (!base)
        return exponent ? 0 : 65536;
    if (exponent <= 32768)
        return ss_quick_powRange1(base, exponent);
    if (exponent < 98304)
        return mul(ss_quick_powRange1(base, exponent), 98304 - exponent) +
               mul(ss_quick_powRange2(base, exponent), exponent - 32768);
    return mul(base, exponent) > exponent - 262144 ? ss_quick_powRange2(base, exponent) : 0;
}

inline bool ss_quick_pow_test(SwvFixedWord numerator, SwvFixedWord denominator, SwvFixedWord exponent)
{
    return mul(numerator, exponent + 65536) > mul(denominator, exponent - 196608);
}

static CssColor lightContribution(CssColor light, const CssColor &surface, int intensity)
{
    light.FixedScale(intensity);
    light *= surface;
    return light;
}

void CssActiveLightStandard::LightSpecular(SssLitVertex *v, const CssFixedVector3D &incident,
                                           SwvFixedWord attenuation)
{
    CssFixedVector3D view{0, 0, -65536};
    if (polygon & CssPolygonMode::LocalCameraLighting) {
        view = v->eye;
        view.Unit();
    }
    const CssFixedVector3D half = incident - view;
    const int cosine = half * (reverse_normal ? -*v->normal : *v->normal);
    if (cosine <= 0)
        return;
    const int size = std::max<int>(half.Magnitude2(), MinimumLightDenominator);
    const int cosine_sq = mul(cosine, cosine);
    if (!ss_quick_pow_test(cosine_sq, size, half_shininess))
        return;
    int intensity = ss_quick_pow(g_divide_int64_int64(int64_t(cosine_sq) * 65536, size), half_shininess);
    if (attenuation != 65536)
        intensity = mul(intensity, attenuation);
    if (intensity > 0)
        v->color += lightContribution(color, v->specular, intensity);
}

void CssActiveLightStandard::ReCacheVertexScale(SssLitVertex *v)
{
    last_w = v->eye_w;
    last_shift = v->w_shift;
    int w = last_w;
    int shift = exponent - last_shift;
    while (w > 196608) {
        w >>= 2;
        shift += 2;
    }
    if (shift < 0) {
        const float factor = std::ldexp(1.0f, shift);
        exponent -= shift;
        position_scale *= factor;
        center *= factor;
        position = CssFixedVector3D(center);
        if (attenuated) {
            const float inverse = std::ldexp(1.0f, -shift);
            linear *= inverse;
            quadratic_root *= inverse;
            attenuation[1] = toFixed16(std::fmin(linear, 32767.f));
            attenuation[2] = toFixed16(std::fmin(quadratic_root, 32767.f));
        }
        shift = 0;
    }
    eye_scale = g_fixed_reciprocal(w) >> std::min(shift, 31);
}

void CssActiveLightStandard::LightVertexParallel(SssLitVertex *v)
{
    if (diffuse_enabled) {
        const int diffuse = (reverse_normal ? -*v->normal : *v->normal) * direction;
        if (diffuse < 0)
            v->color -= lightContribution(color, v->diffuse, diffuse);
    }
    if (specular_enabled)
        LightSpecular(v, -direction, 65536);
}

static int distanceAttenuation(const int coefficients[3], int distance)
{
    const int quadratic = mul(coefficients[2], distance);
    const int divisor = mul(quadratic, quadratic) + mul(coefficients[1], distance) + coefficients[0];
    return g_fixed_reciprocal(std::max(MinimumLightDenominator, divisor));
}

void CssActiveLightStandard::LightVertexOmni(SssLitVertex *v)
{
    if (!diffuse_enabled && !specular_enabled)
        return;
    CssFixedVector3D eye = v->eye;
    if (v->eye_w != last_w || v->w_shift != last_shift)
        ReCacheVertexScale(v);
    eye *= eye_scale;
    CssFixedVector3D incident = position - eye;
    const int diffuse = (reverse_normal ? -*v->normal : *v->normal) * incident;
    if (diffuse <= 0)
        return;
    const unsigned shift = incident.PreScale();
    const int distance = static_cast<unsigned>(incident.Magnitude()) << shift;
    if (distance < MinimumLightDenominator)
        return;
    const int falloff = attenuated ? distanceAttenuation(attenuation, distance) : 65536;
    const int inverse = g_fixed_reciprocal(distance);
    if (diffuse_enabled) {
        int intensity = mul(diffuse, inverse);
        if (attenuated)
            intensity = mul(intensity, falloff);
        v->color += lightContribution(color, v->diffuse, intensity);
    }
    if (specular_enabled) {
        incident *= inverse;
        LightSpecular(v, incident, falloff);
    }
}

void CssActiveLightStandard::LightVertexSpot(SssLitVertex *v)
{
    if (!diffuse_enabled && !specular_enabled)
        return;
    CssFixedVector3D eye = v->eye;
    if (v->eye_w != last_w || v->w_shift != last_shift)
        ReCacheVertexScale(v);
    eye *= eye_scale;
    CssFixedVector3D incident = position - eye;
    const int diffuse = (reverse_normal ? -*v->normal : *v->normal) * incident;
    if (diffuse <= 0)
        return;
    const int cone_projection = -(direction * incident);
    const unsigned shift = incident.PreScale();
    int distance = incident.Magnitude();
    if (distance <= 1)
        return;
    distance = static_cast<unsigned>(distance) << shift;
    const int inverse = g_fixed_reciprocal(distance);
    const int cone = mul(cone_projection, inverse);
    if (cone <= cutoff || distance < 1)
        return;
    int falloff = attenuated ? distanceAttenuation(attenuation, distance) : 65536;
    if (spot_power > 0)
        falloff = mul(falloff, ss_quick_pow(cone, spot_power));
    if (diffuse_enabled)
        v->color += lightContribution(color, v->diffuse, mul(mul(diffuse, inverse), falloff));
    if (specular_enabled) {
        incident *= inverse;
        LightSpecular(v, incident, falloff);
    }
}

void CssActiveLightStandard::LightVertex(SssLitVertex *vertex, bool reverse)
{
    if (enabled) {
        reverse_normal = reverse;
        (this->*shade)(vertex);
    }
}
