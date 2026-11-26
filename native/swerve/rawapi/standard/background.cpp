#include "image_class.hpp"
#include "object_classes.hpp"

int background_create(void **result)
{
    return create_object(BackgroundObject, result);
}

void background_getColor(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetColor();
}

void background_setColor(void *handle, int value)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    object->SetColor(value);
}

void background_getImage(void *handle, void **result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->image);
}

int background_setImage(void *handle, void *image)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    if (image) {
        int format;
        image2d_getFormat(image, &format);
        if (format != 99 && format != 100)
            g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    }
    object->image = replace_reference(object->image, image);
    if (image) {
        int width, height;
        object->x = object->y = 0.0f;
        image2d_getWidth(image, &width);
        object->width = (float)width;
        image2d_getHeight(image, &height);
        object->height = (float)height;
    }
    CssTrapHandler::UnTrap();
    return 1;
}

void background_getImageModeX(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageModeX();
}

void background_getImageModeY(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageModeY();
}

void background_getCropX(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageCropX();
}

void background_getCropY(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageCropY();
}

void background_getCropWidth(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageCropWidth();
}

void background_getCropHeight(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetImageCropHeight();
}

void background_isColorClearEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetbColorClear();
}

void background_setColorClearEnable(void *handle, int value)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    object->SetbColorClear(value != 0);
}

void background_isDepthClearEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    *result = object->GetbDepthClear();
}

void background_setDepthClearEnable(void *handle, int value)
{
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    object->SetbDepthClear(value != 0);
}

int background_setImageMode(void *handle, int x_mode, int y_mode)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    if (x_mode < CssBackground::Border || x_mode > CssBackground::Repeat || y_mode < CssBackground::Border || y_mode > CssBackground::Repeat)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->mode_x = x_mode;
    object->mode_y = y_mode;
    CssTrapHandler::UnTrap();
    return 1;
}

int background_setCrop(void *handle, int x, int y, int width, int height)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssBackground *>(static_cast<CssRefCount *>(handle));
    if (width < 0 || height < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetImageCrop(x, y, width, height);
    CssTrapHandler::UnTrap();
    return 1;
}
