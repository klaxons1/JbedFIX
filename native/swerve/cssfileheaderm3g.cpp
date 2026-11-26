#include "cssserializein.hpp"

static const uint8_t m3g_signature[] = {0xab,'J','S','R','1','8','4',0xbb,13,10,26,10};

CssFileHeaderM3G::CssFileHeaderM3G() : CssFileHeader(m3g_signature, sizeof m3g_signature) {}
