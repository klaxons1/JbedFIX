#ifndef JBED_SWERVE_ENGINE_H
#define JBED_SWERVE_ENGINE_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
#include <setjmp.h>
#include "cssmatrix.hpp"
#define SWV_EXTERN_C_BEGIN extern "C" {
#define SWV_EXTERN_C_END }
#else
#define SWV_EXTERN_C_BEGIN
#define SWV_EXTERN_C_END
#endif


#ifdef __cplusplus
enum EssObjectType : int {
    ObjectHeader = 0, AnimationControllerObject = 1, AnimationTrackObject = 2,
    AppearanceObject = 3, BackgroundObject = 4, CameraObject = 5, CompositingModeObject = 6,
    FogObject = 7, PolygonModeObject = 8, GroupObject = 9, Image2DObject = 10,
    TriangleStripArrayObject = 11, LightObject = 12, MaterialObject = 13, MeshObject = 14,
    MorphingMeshObject = 15, SkinnedMeshObject = 16, Texture2DObject = 17, SpriteObject = 18,
    KeyframeSequenceObject = 19, VertexArrayObject = 20, VertexBufferObject = 21,
    WorldObject = 22, PlasmaImageObject = 23, StagesetObject = 24,
    Graphics3DObject = 25, RayIntersectionObject = 26, TransformObject = 27, LoaderObject = 28, XrefObject = 255
};

class CssTrapHandler {
public:
    jmp_buf &Trap();
    void CleanupStack();
    void Leave(int code);
    static void UnTrap();

    volatile int error = 0;
private:
    jmp_buf jump;
    bool active = false, cleanup_ready = false;
};
#endif

SWV_EXTERN_C_BEGIN

typedef enum EngineNodeType {
    EngineNodeType_AnimationController,
    EngineNodeType_AnimationTrack,
    EngineNodeType_Appearance,
    EngineNodeType_Background,
    EngineNodeType_Camera,
    EngineNodeType_CompositingMode,
    EngineNodeType_Fog,
    EngineNodeType_Graphics3D,
    EngineNodeType_Group,
    EngineNodeType_Image2D,
    EngineNodeType_KeyframeSequence,
    EngineNodeType_Light,
    EngineNodeType_Loader,
    EngineNodeType_Material,
    EngineNodeType_Mesh,
    EngineNodeType_MorphingMesh,
    EngineNodeType_PlasmaImage,
    EngineNodeType_PolygonMode,
    EngineNodeType_RayIntersection,
    EngineNodeType_SkinnedMesh,
    EngineNodeType_Sprite3D,
    EngineNodeType_Stageset,
    EngineNodeType_Texture2D,
    EngineNodeType_Transform,
    EngineNodeType_TriangleStripArray,
    EngineNodeType_VertexArray,
    EngineNodeType_VertexBuffer,
    EngineNodeType_World,
    EngineNodeType_Unknown,
    EngineNodeType_Force_Enum_To_Int = 0x7fffffff
} swvEngineNodeType;

typedef enum EngineError {
    EngineError_NoError,
    EngineError_General,
    EngineError_NoMemory,
    EngineError_Overflow,
    EngineError_Abort,
    EngineError_DivideByZero,
    EngineError_FloatInvalidOperation,
    EngineError_FloatInvalidNumber,
    EngineError_InvalidDataRange,
    EngineError_DataSinkInvalidState,
    EngineError_BufferOverrun,
    EngineError_BadBufferLength,
    EngineError_CorruptFile,
    EngineError_BadChecksum,
    EngineError_InvalidState,
    EngineError_InvalidParameter,
    EngineError_NullPointer,
    EngineError_Force_Enum_To_Int = 0x7fffffff
} swvEngineError;

/* Internal leave codes; engine_getLastError maps them to the public API enum. */
typedef enum SwvLeaveCode {
    SWV_LEAVE_NONE = 0,
    SWV_LEAVE_GENERAL = -2,
    SWV_LEAVE_NO_MEMORY = -4,
    SWV_LEAVE_OVERFLOW = -9,
    SWV_LEAVE_ABORT = -39,
    SWV_LEAVE_DIVIDE_BY_ZERO = -41,
    SWV_LEAVE_FLOAT_INVALID_OPERATION = -1000,
    SWV_LEAVE_FLOAT_INVALID_NUMBER = -1001,
    SWV_LEAVE_INVALID_DATA_RANGE = -1101,
    SWV_LEAVE_DATA_SINK_INVALID_STATE = -1103,
    SWV_LEAVE_BUFFER_OVERRUN = -1200,
    SWV_LEAVE_BAD_BUFFER_LENGTH = -1201,
    SWV_LEAVE_CORRUPT_FILE = -1202,
    SWV_LEAVE_BAD_CHECKSUM = -1203,
    SWV_LEAVE_INVALID_STATE = -1300,
    SWV_LEAVE_INVALID_PARAMETER = -1301,
    SWV_LEAVE_NULL_POINTER = -1302
} SwvLeaveCode;

void swv_record_error(int raw_error);
int swv_raw_error(void);
int swv_next_animation_stamp(void);
#if defined(__cplusplus)
[[noreturn]]
#elif defined(__GNUC__)
__attribute__((noreturn))
#endif
void g_ssThrowLeave(int error);

#ifdef __cplusplus
/* setjmp has to run in the native API frame that receives the exception. */
#define SWV_BEGIN_API(frame)                 \
    CssTrapHandler frame;                    \
    if (setjmp((frame).Trap())) {            \
        swv_record_error((frame).error);     \
        return 0;                            \
    }                                        \
    (frame).CleanupStack()
#endif

#ifdef __cplusplus
SssTransformComponents *swv_default_transform();
CssMatrix *swv_identity_matrix();
#endif
void *swv_retain_handle(void *handle);
int engine_initialize(void);
void engine_uninitialize(void);
void engine_releaseHandle(void *handle);
void engine_getLastError(int *result);
void engine_getHandleType(void *handle, int *result);
void engine_getRefCount(void *handle, int *result);
typedef struct EngineVersion {
    int32_t m_Major, m_Minor, m_RevisionMajor, m_RevisionMinor, m_Branch;
} swvEngineVersion;

typedef struct EngineSysInfo {
    int32_t m_BitCount, m_MaskRed, m_MaskGreen, m_MaskBlue;
    int32_t m_ShiftRed, m_ShiftGreen, m_ShiftBlue;
    int32_t m_SizeRed, m_SizeGreen, m_SizeBlue;
} swvEngineSysInfo;

typedef enum EngineEdition {
    EngineEdition_Micro, EngineEdition_Standard, EngineEdition_Enhanced,
    EngineEdition_Force_Enum_To_Int = 0x7fffffff
} swvEngineEdition;

void engine_getVersion(swvEngineVersion *result);
void engine_getEdition(int *result);
void engine_getSysInfo(swvEngineSysInfo *result);
int graphics3d_getCapability(int id, int *result);
const char *swerveProvenance(void);

SWV_EXTERN_C_END
#endif
