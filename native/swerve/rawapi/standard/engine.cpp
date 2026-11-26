#include "cssstatics.hpp"
#include "object_class.hpp"

int engine_initialize() { return CssEngine::Initialize(); }
void engine_uninitialize() { CssEngine::Uninitialize(); }

void *swv_retain_handle(void *handle)
{
    if (handle)
        static_cast<CssRefCount *>(handle)->AddRef();
    return handle;
}

void engine_releaseHandle(void *handle)
{
    auto *ref = static_cast<CssRefCount *>(handle);
    ref->Release();
}

void engine_getRefCount(void *handle, int *out)
{
    *out = static_cast<CssRefCount *>(handle)->cReferences();
}

void engine_getHandleType(void *handle, int *out)
{
    static const unsigned char types[] = {
        EngineNodeType_AnimationController,
        EngineNodeType_AnimationTrack,
        EngineNodeType_Appearance,
        EngineNodeType_Background,
        EngineNodeType_Camera,
        EngineNodeType_CompositingMode,
        EngineNodeType_Fog,
        EngineNodeType_PolygonMode,
        EngineNodeType_Group,
        EngineNodeType_Image2D,
        EngineNodeType_TriangleStripArray,
        EngineNodeType_Light,
        EngineNodeType_Material,
        EngineNodeType_Mesh,
        EngineNodeType_MorphingMesh,
        EngineNodeType_SkinnedMesh,
        EngineNodeType_Texture2D,
        EngineNodeType_Sprite3D,
        EngineNodeType_KeyframeSequence,
        EngineNodeType_VertexArray,
        EngineNodeType_VertexBuffer,
        EngineNodeType_World,
        EngineNodeType_PlasmaImage,
        EngineNodeType_Stageset,
        EngineNodeType_Graphics3D,
        EngineNodeType_RayIntersection,
        EngineNodeType_Transform,
        EngineNodeType_Loader
    };
    unsigned type = static_cast<CssRefCount *>(handle)->Type();
    *out = type - 1 < sizeof(types) ? types[type - 1] : EngineNodeType_Unknown;
}

void engine_getLastError(int *out)
{
    static const short codes[] = {
        SWV_LEAVE_NONE,
        SWV_LEAVE_GENERAL,
        SWV_LEAVE_NO_MEMORY,
        SWV_LEAVE_OVERFLOW,
        SWV_LEAVE_ABORT,
        SWV_LEAVE_DIVIDE_BY_ZERO,
        SWV_LEAVE_FLOAT_INVALID_OPERATION,
        SWV_LEAVE_FLOAT_INVALID_NUMBER,
        SWV_LEAVE_INVALID_DATA_RANGE,
        SWV_LEAVE_DATA_SINK_INVALID_STATE,
        SWV_LEAVE_BUFFER_OVERRUN,
        SWV_LEAVE_BAD_BUFFER_LENGTH,
        SWV_LEAVE_CORRUPT_FILE,
        SWV_LEAVE_BAD_CHECKSUM,
        SWV_LEAVE_INVALID_STATE,
        SWV_LEAVE_INVALID_PARAMETER,
        SWV_LEAVE_NULL_POINTER
    };
    int raw = g_Statics().error;
    for (unsigned i = 0; i < sizeof(codes) / sizeof(*codes); ++i) {
        if (codes[i] == raw) {
            *out = (int)i;
            return;
        }
    }
    *out = EngineError_General;
}

void engine_getVersion(swvEngineVersion *result)
{
    *result = {2, 2, 0, 438, 0};
}

void engine_getEdition(int *result) { *result = EngineEdition_Standard; }

void engine_getSysInfo(swvEngineSysInfo *result)
{
    *result = {16, 0xf800, 0x07e0, 0x001f, 11, 5, 0, 5, 6, 5};
}

const char *swerveProvenance(void)
{
    return "\nBuilt: Fri Jun 29 10:14:36 GMTDT 2007\n"
           "SubVersion Branch: trunk\nSubVersion Revision: 2747\nCompiler: RVCT3.0 [Build 651] \n";
}
