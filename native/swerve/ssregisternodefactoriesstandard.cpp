#include "cssobjectfactory.hpp"
#include "cssplasmaimage.hpp"

void g_ssRegisterNodeFactoriesForEditionStandardSpecific(CssObjectFactory *) {}

void g_ssRegisterNodeFactoriesForEditionStandardShared(CssObjectFactory *factory)
{
    factory->RegisterFactoryFunction(PlasmaImageObject, CssPlasmaImage::FactoryCreate);
    factory->RegisterFactoryFunction(StagesetObject, CssStageset::FactoryCreate);
}
