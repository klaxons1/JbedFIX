#ifndef JBED_COMPILER_ROM_OBJECTS_H
#define JBED_COMPILER_ROM_OBJECTS_H

#include "runtime.h"
#include "writer.h"
#include "reflection_table.h"
#include "block_stream.h"

typedef enum JbedRomObjectKind {
    JBED_ROM_STRING,
    JBED_ROM_CLASS,
    JBED_ROM_OTHER
} JbedRomObjectKind;

typedef struct JbedRomObjectView {
    JbedRomObjectKind kind;
    JbedAddress identity;
    JbedAddress header_class;
    uint32_t hash;
    const uint16_t *characters;
    uint32_t character_count;
    JbedClass *klass;
} JbedRomObjectView;

typedef enum JbedRomTable {
    JBED_ROM_PACKAGES,
    JBED_ROM_BASE_NAMES,
    JBED_ROM_CLASS_REFS,
    JBED_ROM_FIELDS,
    JBED_ROM_METHODS,
    JBED_ROM_SIGNATURES
} JbedRomTable;

typedef struct JbedRomRelocator {
    void *context;
    JbedAddress (*address)(void *, JbedAddress);
    JbedAddress (*label)(void *, uint32_t);
} JbedRomRelocator;

/* Original runtime dependencies: object identity/header/hash, ReflectionTable,
 * ClassAccess, method-range registry, managed allocation and isolate publication.
 * The generator and stream representation are implemented in rom_objects.c. */
typedef struct JbedRomServices {
    JbedRuntime *runtime;
    void *context;
    JbedAddress class_array_header, int_array_header;
    JbedAddress throw_abstract, throw_no_class;
    uint32_t fingerprint;
    JbedRomObjectView (*object)(void *, JbedAddress);
    JbedRomObjectView (*class_object)(void *, JbedClass *);
    bool (*resident_class)(void *, const JbedClass *);
    JbedAddress (*class_address)(void *, const JbedClass *);
    uint32_t (*sync_table_size)(void *);
    uint32_t (*dynamic_bundle_id)(void *);
    uint32_t (*string_table_size)(void *);
    JbedAddress (*generate_table)(void *, JbedRomTable, JbedWriter *, JbedRomObjects *);
    void (*append_code_ranges)(void *, JbedMethod *, uint32_t **, size_t *, size_t *);
    JbedAddress (*new_empty_locked_array)(void *, bool references);
    void (*extend_synchronizers)(void *, int32_t delta);
    void (*extend_statics)(void *, uint32_t, JbedAddress pointer_ranges);
    void (*install_string_table)(void *, const JbedAddress *, uint32_t);
    uint32_t (*stack_map_id)(void *);
    void (*add_stack_map)(void *, JbedAddress, uint32_t);
    void (*load_bundle)(void *, uint32_t bundle, JbedAddress classes, JbedAddress packages,
                        JbedAddress base_names);
    void (*reference_table)(void *, JbedRomTable, JbedAddress);
    void (*trace_debug_symbols)(void *, uint32_t bundle);
    void (*set_anchor_parameters)(void *, uint32_t map_id, const JbedRomObjectView *,
                                  uint32_t count);
    JbedReflectionTable *reflection_tables[JBED_ROM_SIGNATURES + 1];
    JbedImageView loaded_image;
    JbedClassAccess *class_access;
    JbedClassAccess *load_class_access; /* Runtime registry when publishing a compiler's output. */
    struct JbedVmStackMaps *stack_map_registry;
    struct JbedVmMonitors *monitors;
} JbedRomServices;

struct JbedRomObjects {
    const JbedRomServices *services;
    JbedWriter *writer;
    JbedRomObjectView *objects;
    uint32_t *object_labels;
    uint32_t object_count, object_capacity, class_count;
    uint32_t sync_index, bundle_id;
    JbedAddress *string_table;
    uint32_t string_table_count;
    JbedAddress package_table, base_name_table, class_ref_table;
    JbedAddress method_name_table, field_name_table, signature_table;
    uint32_t relative_statics_size;
    const uint32_t *pointer_ranges;
    uint32_t pointer_range_count;
    JbedAddress pointer_ranges_address;
    JbedAddress primitive_statics, pointer_statics, init_flags;
    JbedAddress *stack_maps;
    uint32_t stack_map_count, stack_map_capacity;
    uint32_t *method_code_ranges;
    size_t method_code_range_count, method_code_range_capacity;
    bool debug_info;
};

void jbed_rom_init(JbedRomObjects *, const JbedRomServices *, JbedWriter *, bool debug_info);
void jbed_rom_register_class(JbedRomObjects *, JbedClass *);
JbedPointerKind jbed_rom_pointer_kind(JbedRomObjects *, JbedAddress);
uint32_t jbed_rom_register_object(JbedRomObjects *, JbedAddress);
void jbed_rom_register_stack_map(JbedRomObjects *, JbedAddress);
void jbed_rom_register_relative_statics(JbedRomObjects *, uint32_t, const uint32_t *, uint32_t);
JbedAddress jbed_rom_primitive_statics(JbedRomObjects *);
JbedAddress jbed_rom_pointer_statics(JbedRomObjects *);
JbedAddress jbed_rom_init_flags(JbedRomObjects *);
JbedAddress jbed_rom_primitive_statics_base(JbedRomObjects *);
JbedAddress jbed_rom_pointer_statics_base(JbedRomObjects *);
JbedAddress jbed_rom_init_flags_base(JbedRomObjects *);
JbedAddress jbed_rom_class_address(const JbedRomServices *, const JbedClass *);
void jbed_rom_write_class(JbedRomObjects *, JbedAddress site, JbedClass *);
void jbed_rom_write_code(JbedRomObjects *, JbedAddress site, JbedAddress target);
void jbed_rom_object_header(JbedRomObjects *, JbedAddress, const JbedRomObjectView *, bool hash,
                            bool synchronizer);
JbedAddress jbed_rom_string_data(JbedRomObjects *, const JbedRomObjectView *);
JbedAddress jbed_rom_string(JbedRomObjects *, const JbedRomObjectView *, uint32_t label);
JbedAddress jbed_rom_class_array(JbedRomObjects *, JbedClass *const *, uint32_t);
JbedAddress jbed_rom_int_array(JbedRomObjects *, const uint32_t *, uint32_t);
JbedAddress jbed_rom_class(JbedRomObjects *, JbedClass *);
void jbed_rom_generate(JbedRomObjects *);
JbedAddress jbed_rom_generate_xip(JbedRomObjects *);
bool jbed_rom_store(const JbedRomObjects *, JbedBlockIo *);
bool jbed_rom_read(JbedRomObjects *, JbedBlockIo *, const JbedRomRelocator *);
JbedRomObjects *jbed_rom_load(const JbedRomServices *, JbedBlockIo *, const JbedRomRelocator *);
void jbed_rom_prepare_loaded(JbedRomObjects *);
void jbed_rom_prepare_generated(JbedRomObjects *, const JbedRomRelocator *);

#endif
