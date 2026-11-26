#include "geometry_class.hpp"

CssIndexBuffer::~CssIndexBuffer() = default;

void CssIndexBuffer::SerializeIn(CssSerializeBufferObjectsIn &reader) { CssObject3D::SerializeIn(reader); }


void CssIndexBuffer::CloneHelper(const CssIndexBuffer &source)
{
    CssObject3D::CloneHelper(source);
    max_index = source.max_index;
}
