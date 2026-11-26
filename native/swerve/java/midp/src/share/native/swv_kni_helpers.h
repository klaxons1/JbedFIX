#ifndef JBED_SWERVE_KNI_HELPERS_H
#define JBED_SWERVE_KNI_HELPERS_H
#include "platform/jbni_objects.h"

typedef enum {
    swvBaseClassFIDs_Object3D = 0,
    swvBaseClassFIDs_Graphics3D = 1,
    swvBaseClassFIDs_Loader = 2,
    swvBaseClassFIDs_RayIntersection = 3,
    swvBaseClassFIDs_Transform = 4,
    swvBaseClassFIDs_Max
} swvBaseClassFIDs;

extern JbRef *Jbed_ParamPtr;
int ThrowSwerveAPIException(void);
int SWV_Engine_getHandleSize(void);
int SWV_Engine_initialize(void);
int SWV_Engine_getVersionMajor(void);
int SWV_Engine_getVersionMinor(void);
int SWV_Engine_getRevisionMajor(void);
int SWV_Engine_getRevisionMinor(void);
int SWV_Engine_getBranchNumber(void);
int SWV_Engine_getHandleType(void);
void SWV_Engine_releaseHandle(void);
void SWV_Engine_cacheFID(void);
void SWV_Finalize(swvBaseClassFIDs cls);

void *SWV_GetSwerveHandleFromPeer(JbRef *root, swvBaseClassFIDs cls);
void *SWV_Constructor_HandleReturn(int (*fn)(void **));
int SWV_UnSafeMethod_Handle(int (*fn)(void *, void *), swvBaseClassFIDs receiver_class, swvBaseClassFIDs arg_class);
void SWV_UnSafeSetter_Handle(int (*fn)(void *, void *), swvBaseClassFIDs receiver_class, swvBaseClassFIDs arg_class);
void SWV_Setter_Handle(void (*fn)(void *, void *), swvBaseClassFIDs receiver_class, swvBaseClassFIDs arg_class);
void *SWV_Getter_Handle(void (*fn)(void *, void **), swvBaseClassFIDs cls);
void SWV_UnSafeSetter_Float(int (*fn)(void *, float), swvBaseClassFIDs cls);
uint32_t SWV_Getter_Float(void (*fn)(void *, float *), swvBaseClassFIDs cls);
void SWV_UnSafeSetter_Integer(int (*fn)(void *, int), swvBaseClassFIDs cls);
void SWV_Setter_Integer(void (*fn)(void *, int), swvBaseClassFIDs cls);
int SWV_Getter_Integer(void (*fn)(void *, int *), swvBaseClassFIDs cls);
void SWV_Setter_Boolean(void (*fn)(void *, int), swvBaseClassFIDs cls);
int SWV_Getter_Boolean(void (*fn)(void *, int *), swvBaseClassFIDs cls);

int SWV_GetArrayBytes(JbRef *root, unsigned element_size, unsigned limit, void **bytes, unsigned *count);
void SWV_SetArrayBytes(JbRef *root, unsigned element_size, void *bytes, unsigned count);
void SWV_RestoreArrayBytes(JbRef *root, unsigned element_size, void *bytes, unsigned count);
void SWV_FreeArrayBytes(JbRef *root, void *bytes);
int SWV_GetImage2DEncoding(void);
int swvGetImage2DEncoding(JbRef *root);
void *SWV_Image2D_createPNG(void);
void SWV_Image2D_setRGB(void);
void SWV_BindTargetCritical(JbRef *root, void *handle);
void SWV_BindTargetGraphics(void);
void SWV_ReleaseTargetGraphics(void);
int swvEngineInitialize(void);
void swvEngineUninitialize(void);
#endif
