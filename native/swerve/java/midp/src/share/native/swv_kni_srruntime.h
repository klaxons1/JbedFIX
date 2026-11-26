#ifndef JBED_SWERVE_KNI_SRRUNTIME_H
#define JBED_SWERVE_KNI_SRRUNTIME_H
#include "swv_kni_helpers.h"

typedef struct {
    unsigned width, height, stride;
    void *pixels;
} SwvBackBuffer;

void swvKNIGraphicsGetBackBufferData(JbRef *root, SwvBackBuffer *out);
void swvKNIGraphicsSetBackBufferData(JbRef *root);
void swvKNIGraphicsUpdateBackBufferData(JbRef *root, int load, void **pixels);
#endif
