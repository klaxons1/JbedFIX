#include "cssserializein.hpp"

static const uint8_t swerve_signature[] = {0xbb,'S','W','E','R','V','E',0xab,13,10,26,10};

CssFileHeaderSWV::CssFileHeaderSWV() : CssFileHeader(swerve_signature, sizeof swerve_signature) {}
