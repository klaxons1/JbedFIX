#ifndef JBED_RUNTIME_BOOT_IMAGE_H
#define JBED_RUNTIME_BOOT_IMAGE_H

#include "../compiler/boot_image.h"
#include "../compiler/writer.h"

typedef struct JbedLoadedBoot {
    const JbedBootImage *image;
    JbedBuffer memory;
    uint32_t executable_size;
} JbedLoadedBoot;

/* The writable tail holds isolate statics, managed stacks and the heap. */
bool jbed_boot_load(JbedLoadedBoot *, const JbedBootImage *, uint32_t writable_bytes, void *runtime,
                    char *error, size_t error_size);
void jbed_boot_unload(JbedLoadedBoot *);
JbedAddress jbed_boot_method(const JbedLoadedBoot *, const char *owner, const char *name,
                             const char *descriptor);
JbedAddress jbed_boot_class(const JbedLoadedBoot *, const char *name);

#endif
