#include "image_class.hpp"
#include "cssobjectfactory.hpp"
#include "object_classes.hpp"

int sprite3d_create(int scaled, void *image, void *appearance, void **result)
{
    SWV_BEGIN_API(frame);
    if (!image)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    CssHeapPtr<CssSprite> sprite(static_cast<CssSprite *>(CssObjectFactory::CreateObject(SpriteObject)));
    sprite->Construct(scaled != 0, static_cast<CssImage2D *>(static_cast<CssRefCount *>(image)),
                      static_cast<CssAppearance *>(static_cast<CssRefCount *>(appearance)));
    *result = reference_handle(sprite.release());
    CssTrapHandler::UnTrap();
    return 1;
}

void sprite3d_getAppearance(void *handle, void **result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetpAppearance());
}

void sprite3d_setAppearance(void *handle, void *value)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    object->SetpAppearance(static_cast<CssAppearance *>(static_cast<CssRefCount *>(value)));
}

void sprite3d_getImage(void *handle, void **result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetpImage());
}

int sprite3d_setImage(void *handle, void *image)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    if (!image)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object->SetpImage(static_cast<CssImage2D *>(static_cast<CssRefCount *>(image)));
    CssTrapHandler::UnTrap();
    return 1;
}

void sprite3d_getCropHeight(void *handle, int *result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = object->GetCropHeight();
}

void sprite3d_getCropWidth(void *handle, int *result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = object->GetCropWidth();
}

void sprite3d_getCropX(void *handle, int *result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = object->GetCropX();
}

void sprite3d_getCropY(void *handle, int *result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = object->GetCropY();
}

void sprite3d_isScaled(void *handle, int *result)
{
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    *result = object->isScaled();
}

int sprite3d_setCrop(void *handle, int x, int y, int width, int height)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssSprite *>(static_cast<CssRefCount *>(handle));
    /* The ARM absolute value of INT32_MIN remains negative. */
    if ((width != INT32_MIN && (width < -1024 || width > 1024)) ||
        (height != INT32_MIN && (height < -1024 || height > 1024)))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetCrop(x, y, width, height);
    CssTrapHandler::UnTrap();
    return 1;
}
