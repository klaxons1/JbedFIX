#include "cssobjectfactory.hpp"
#include "cssstatics.hpp"

void CssObjectFactory::Create()
{
    CssStatics &statics = g_Statics();
    statics.factory = new CssObjectFactory;
    statics.factory->Construct();
}

void CssObjectFactory::Construct()
{
    for (auto &function : classes) function = nullptr;
    external_reference = nullptr;
    g_ssRegisterNodeFactories(this);
}

void CssObjectFactory::Destroy()
{
    if (CssStatics *statics = g_pStaticsNoLeave()) {
        delete statics->factory;
        statics->factory = nullptr;
    }
}

IssSerializable *CssObjectFactory::CreateObject(EssObjectType type)
{
    CssObjectFactory *factory = g_Statics().factory;
    if (type <= LoaderObject) return factory->classes[type]();
    if (type == XrefObject) return factory->external_reference();
    return nullptr;
}

void CssObjectFactory::RegisterFactoryFunction(EssObjectType type, FactoryFunction function)
{
    CssObjectFactory *factory = g_Statics().factory;
    if (type == XrefObject)
        factory->external_reference = function;
    else
        factory->classes[type] = function;
}
