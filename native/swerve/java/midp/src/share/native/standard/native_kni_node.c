#include "kni.h"
#include "kni_targets.h"

uint32_t M3G_ENTRY(Node_getParentImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(node_getParent, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Node_getAlphaFactor)(void)
{
    return (uint32_t)SWV_Getter_Float(node_getAlphaFactor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Node_isRenderingEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(node_isRenderingEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Node_isPickingEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(node_isPickingEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Node_getScope)(void)
{
    return (uint32_t)SWV_Getter_Integer(node_getScope, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Node_setAlphaFactor)(void)
{
    SWV_UnSafeSetter_Float(node_setAlphaFactor, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Node_setRenderingEnable)(void)
{
    SWV_Setter_Boolean(node_setRenderingEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Node_setPickingEnable)(void)
{
    SWV_Setter_Boolean(node_setPickingEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Node_setScope)(void)
{
    SWV_Setter_Integer(node_setScope, swvBaseClassFIDs_Object3D);
}

/* 0x305910  (Ljavax/microedition/m3g/Node;Ljavax/microedition/m3g/Transform;)Z */
uint32_t M3G_ENTRY(Node_getTransformTo)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *node = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 2, swvBaseClassFIDs_Transform);
    int result = 0;
    if (!node_getTransformTo(self, node, transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}

/* 0x305840  (Ljavax/microedition/m3g/Node;ILjavax/microedition/m3g/Node;I)V */
void M3G_ENTRY(Node_setAlignmentImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *zReference = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    int zTarget = (int)Jbed_ParamPtr[2];
    void *yReference = kni_peer(&roots[2], 3, swvBaseClassFIDs_Object3D);
    int yTarget = (int)Jbed_ParamPtr[4];
    if (!node_setAlignment(self, zReference, zTarget, yReference, yTarget))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Node_align)(void)
{
    SWV_UnSafeMethod_Handle(node_align, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

/* 0x305740  (I)I */
uint32_t M3G_ENTRY(Node_getAlignmentReferenceImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!node_getAlignmentReference(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3057c0  (I)I */
uint32_t M3G_ENTRY(Node_getAlignmentTarget)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    if (!node_getAlignmentTarget(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}
