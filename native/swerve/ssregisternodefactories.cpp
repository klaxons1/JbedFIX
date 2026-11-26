#include "cssobjectfactory.hpp"
#include "cssserializein.hpp"
#include "geometry_class.hpp"
#include "image_class.hpp"
#include "object_classes.hpp"

void g_ssRegisterNodeFactoriesForEditionMicroSpecific(CssObjectFactory *) {}

void g_ssRegisterNodeFactoriesForEditionMicroShared(CssObjectFactory *factory)
{
    factory->RegisterFactoryFunction(AnimationControllerObject, CssAnimationController::FactoryCreate);
    factory->RegisterFactoryFunction(AnimationTrackObject, CssAnimationTrack::FactoryCreate);
    factory->RegisterFactoryFunction(AppearanceObject, CssAppearance::FactoryCreate);
    factory->RegisterFactoryFunction(BackgroundObject, CssBackground::FactoryCreate);
    factory->RegisterFactoryFunction(CameraObject, CssCamera::FactoryCreate);
    factory->RegisterFactoryFunction(CompositingModeObject, CssCompositingMode::FactoryCreate);
    factory->RegisterFactoryFunction(FogObject, CssFog::FactoryCreate);
    factory->RegisterFactoryFunction(GroupObject, CssGroup::FactoryCreate);
    factory->RegisterFactoryFunction(PolygonModeObject, CssPolygonMode::FactoryCreate);
    factory->RegisterFactoryFunction(Image2DObject, CssImage2D::FactoryCreate);
    factory->RegisterFactoryFunction(KeyframeSequenceObject, CssKeyframeSequence::FactoryCreate);
    factory->RegisterFactoryFunction(LightObject, CssLight::FactoryCreate);
    factory->RegisterFactoryFunction(MaterialObject, CssMaterial::FactoryCreate);
    factory->RegisterFactoryFunction(MeshObject, CssMesh::FactoryCreate);
    factory->RegisterFactoryFunction(MorphingMeshObject, CssMorphingMesh::FactoryCreate);
    factory->RegisterFactoryFunction(RayIntersectionObject, CssRayIntersection::FactoryCreate);
    factory->RegisterFactoryFunction(SkinnedMeshObject, CssSkinnedMesh::FactoryCreate);
    factory->RegisterFactoryFunction(SpriteObject, CssSprite::FactoryCreate);
    factory->RegisterFactoryFunction(Texture2DObject, CssTexture2D::FactoryCreate);
    factory->RegisterFactoryFunction(TransformObject, CssTransform::FactoryCreate);
    factory->RegisterFactoryFunction(TriangleStripArrayObject, CssTriangleStripArray::FactoryCreate);
    factory->RegisterFactoryFunction(VertexArrayObject, CssVertexArray::FactoryCreate);
    factory->RegisterFactoryFunction(VertexBufferObject, CssVertexBuffer::FactoryCreate);
    factory->RegisterFactoryFunction(WorldObject, CssWorld::FactoryCreate);
    factory->RegisterFactoryFunction(XrefObject, CssXREF::FactoryCreate);
}
