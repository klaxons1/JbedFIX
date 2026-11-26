#ifndef JBED_CLASS_ACCESS_H
#define JBED_CLASS_ACCESS_H

#include "vm_types.h"
#include "vm_memory.h"

typedef struct JbedClassParams {
    uint16_t package_id, base_id;
    int32_t dimensions;
} JbedClassParams;
typedef struct JbedClassBucket JbedClassBucket;

typedef struct JbedClassHeapImage {
    JbedAddress class_access_class, class_class, class_array_class;
    JbedAddress compiler_root, registered_root;
} JbedClassHeapImage;

struct JbedClassAccess {
    JbedRuntime *runtime;
    JbedReflectionTable *packages, *base_names;
    const JbedVmClassTable *bundles[2];
    bool all_classes;
    uint16_t dynamic_bundle;
    uint32_t next_low_id, param_capacity, object_capacity;
    JbedClassParams *params;
    JbedClass **classes;
    JbedClassBucket *buckets;
    const char **names[3]; /* ClassAccess.nameCache and ClassRefTable's per-bundle caches. */
    uint32_t name_capacity[3];
    JbedVmHeap *heap;
    JbedClassHeapImage heap_image;
    JbedAddress isolate_statics, guest_root; /* Scanned isolate slot containing ClassAccess. */
};

typedef struct JbedAndroidRomTables {
    JbedVmClassTable classes;
    JbedReflectionTable packages, base_names, method_names, field_names, signatures;
    JbedClassAccess access;
} JbedAndroidRomTables;

/* Initialize in its final storage; access borrows the embedded tables.
 * Use base zero for the bundled ELF, or a relocated image at its target VA. */
void jbed_android_rom_tables_init(JbedAndroidRomTables *, JbedRuntime *, JbedImageView,
                                  bool all_classes);

void jbed_class_access_init(JbedClassAccess *, JbedRuntime *, const JbedVmClassTable *resident,
                            JbedReflectionTable *packages, JbedReflectionTable *bases,
                            bool all_classes);
/* Both root slots must be included in the owning isolate's GC roots. */
void jbed_class_bind_heap_image(JbedClassAccess *, JbedVmHeap *, JbedClassHeapImage);
/* Adapter for the original Android ROM used by the offline compiler/oracle. */
void jbed_class_bind_heap(JbedClassAccess *, JbedVmHeap *, JbedAddress isolate_statics);
void jbed_class_publish(JbedClassAccess *);
void jbed_class_release_compiler_root(JbedClassAccess *);
JbedAddress jbed_class_target_address(JbedClassAccess *, JbedClass *);
JbedClass *jbed_class_from_target(JbedClassAccess *, JbedAddress);
JbedError jbed_class_error(const JbedClass *);
void jbed_class_access_load_bundle(JbedClassAccess *, const JbedVmClassTable *, JbedImageView,
                                   JbedAddress packages, JbedAddress bases);
JbedTypeId jbed_class_id(JbedClassAccess *, JbedClassParams, bool create, bool include_hidden);
JbedTypeId jbed_class_name_id(JbedClassAccess *, const uint8_t *, size_t start, size_t end,
                              size_t last_slash, int32_t dimensions);
JbedClassParams jbed_class_params(const JbedClassAccess *, JbedTypeId);
const char *jbed_class_name(JbedClassAccess *, JbedTypeId);
const char *jbed_class_package_name(JbedClassAccess *, JbedTypeId);
JbedTypeId jbed_class_array_of(JbedClassAccess *, JbedTypeId);
JbedTypeId jbed_class_primitive_array(JbedClassAccess *, JbedTypeId primitive, int32_t dimensions);
JbedClass *jbed_class_object(JbedClassAccess *, JbedTypeId);
JbedClass *jbed_class_get_or_create(JbedClassAccess *, JbedTypeId);
JbedClass *jbed_class_next(const JbedClassAccess *, const JbedClass *previous);
JbedTypeId jbed_class_next_unresolved(const JbedClassAccess *, JbedTypeId previous);
JbedAddress jbed_class_generate(JbedClassAccess *, JbedWriter *, JbedRomObjects *);

#endif
