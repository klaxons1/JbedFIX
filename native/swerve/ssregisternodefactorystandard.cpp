#include "cssobjectfactory.hpp"

void g_ssRegisterNodeFactories(CssObjectFactory *factory)
{
    factory->RegisterFactoryFunction(ObjectHeader, nullptr);
    g_ssRegisterNodeFactoriesForEditionMicroShared(factory);
    g_ssRegisterNodeFactoriesForEditionStandardShared(factory);
    g_ssRegisterNodeFactoriesForEditionStandardSpecific(factory);
}
