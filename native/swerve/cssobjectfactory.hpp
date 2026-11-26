#ifndef SWERVE_CSSOBJECTFACTORY_HPP
#define SWERVE_CSSOBJECTFACTORY_HPP

#include "heap_object.hpp"

class IssSerializable;

class CssObjectFactory : public CssHeapObject {
public:
    using FactoryFunction = IssSerializable *(*)();
    static void Create();
    static void Destroy();
    static IssSerializable *CreateObject(EssObjectType type);
    void RegisterFactoryFunction(EssObjectType type, FactoryFunction function);
private:
    FactoryFunction classes[LoaderObject + 1];
    FactoryFunction external_reference;
    void Construct();
};

void g_ssRegisterNodeFactories(CssObjectFactory *factory);
void g_ssRegisterNodeFactoriesForEditionMicroShared(CssObjectFactory *factory);
void g_ssRegisterNodeFactoriesForEditionStandardShared(CssObjectFactory *factory);
void g_ssRegisterNodeFactoriesForEditionStandardSpecific(CssObjectFactory *factory);

#endif
