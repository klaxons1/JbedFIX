#include "image_class.hpp"
#include "cssobjectfactory.hpp"
#include "object_classes.hpp"

int texture2d_create(void *image, void **result)
{
    SWV_BEGIN_API(frame);
    if (!image)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    CssHeapPtr<CssTexture2D> texture(static_cast<CssTexture2D *>(CssObjectFactory::CreateObject(Texture2DObject)));
    texture->Construct(static_cast<CssImage2D *>(static_cast<CssRefCount *>(image)));
    *result = reference_handle(texture.release());
    CssTrapHandler::UnTrap();
    return 1;
}

int texture2d_setImage(void *handle, void *image)
{
    SWV_BEGIN_API(frame);
    if (!image)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    texture->SetImage(static_cast<CssImage2D *>(static_cast<CssRefCount *>(image)));
    CssTrapHandler::UnTrap();
    return 1;
}

void texture2d_getImage(void *handle, void **image)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *image = reference_handle(texture->GetImage());
}

void texture2d_setBlendColor(void *handle, int color)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    texture->SetBlendColor(color);
}

int texture2d_setBlending(void *handle, int mode)
{
    SWV_BEGIN_API(frame);
    if (mode < CssTexture2D::Add || mode > CssTexture2D::Replace)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    texture->SetBlending(static_cast<CssTexture2D::EssBlending>(mode));
    CssTrapHandler::UnTrap();
    return 1;
}

int texture2d_setWrapping(void *handle, int s, int t)
{
    SWV_BEGIN_API(frame);
    if (s < CssTexture2D::Clamp || s > CssTexture2D::Repeat ||
        t < CssTexture2D::Clamp || t > CssTexture2D::Repeat)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    texture->SetWrapping(static_cast<CssTexture2D::EssWrap>(s), static_cast<CssTexture2D::EssWrap>(t));
    CssTrapHandler::UnTrap();
    return 1;
}

int texture2d_setFiltering(void *handle, int level, int image)
{
    SWV_BEGIN_API(frame);
    if (level < CssTexture2D::BaseLevel || level > CssTexture2D::Nearest ||
        image < CssTexture2D::Linear || image > CssTexture2D::Nearest)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    texture->SetFiltering(static_cast<CssTexture2D::EssFilter>(level), static_cast<CssTexture2D::EssFilter>(image));
    CssTrapHandler::UnTrap();
    return 1;
}

void texture2d_getBlending(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetBlending();
}

void texture2d_getBlendColor(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetBlendColor();
}

void texture2d_getWrappingS(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetWrappingS();
}

void texture2d_getWrappingT(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetWrappingT();
}

void texture2d_getImageFilter(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetImageFiltering();
}

void texture2d_getLevelFilter(void *handle, int *result)
{
    auto *texture = static_cast<CssTexture2D *>(static_cast<CssRefCount *>(handle));
    *result = texture->GetLevelFiltering();
}
