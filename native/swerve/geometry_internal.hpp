#ifndef SWV_GEOMETRY_INTERNAL_HPP
#define SWV_GEOMETRY_INTERNAL_HPP

#include "geometry_class.hpp"
#include "objects.h"
#include "object_classes.hpp"
#include <cstring>

template<class T> static T *retain(T *base)
{
    if (base) base->AddRef();
    return base;
}

template<class T> static CssRefCount *handle_for(T *base)
{
    return retain(base);
}
template<class T> static T *lookup(void *handle)
{
    return static_cast<T *>(static_cast<CssRefCount *>(handle));
}
template<class T> static void zero_pointers(CssArray<T *> &array, int count)
{
    array.SetSize(count);
    if (count) memset(array.data, 0, static_cast<size_t>(count) * sizeof(T *));
}
template<class T> static void copy_pointers(CssArray<T *> &dest, const CssArray<T *> &src)
{
    dest = src;
    for (int i = 0; i < dest.size; ++i) retain(dest[i]);
}
template<class T> static void release_pointers(CssArray<T *> &array)
{
    for (int i = 0; i < array.size; ++i)
        if (array[i]) array[i]->Release();
}

inline int animate_ref(CssObject3D *base, int time, int valid, int stamp)
{
    if (!base) return valid;
    int interval = base->Animate(time, stamp);
    return interval < valid ? interval : valid;
}

inline void check_index(int i, int size) { if ((unsigned)i >= (unsigned)size) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE); }

inline CssVertexArray *make_vertex_array(int count, int components, int width)
{
    CssHeapPtr<CssVertexArray> array(CssVertexArray::Create());
    array->Construct(count, components, width);
    return array.release();
}

#endif
