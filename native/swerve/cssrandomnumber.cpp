#include "cssplasmaimage.hpp"

CssRandomNumber::~CssRandomNumber() = default;

SwvFixedWord CssRandomNumber::Random() const
{
    random_state = Multiplier * random_state + Increment;
    return random_state & 65535;
}
