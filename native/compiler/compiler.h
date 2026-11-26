#ifndef JBED_COMPILER_DRIVER_H
#define JBED_COMPILER_DRIVER_H

#include "model.h"
#include "emitter.h"
#include "reader.h"
#include "writer.h"

typedef struct JbedCompiler JbedCompiler;
struct JbedVmClassTable;

/* The same layout cursors span all classes in one compile. Configure their
 * platform constants with jbed_reader_layout_init before the first call. */
typedef struct JbedCompilerLayout {
    JbedReaderLayout layout;
    JbedPool *pool; /* Supplies metadata services after TranslateClass releases each class pool. */
    JbedClass *array_base_class;
    uint32_t throw_abstract_address;
    JbedWriter *writer;
    int32_t primitive_static_start; /* Existing statics before this compilation. */
} JbedCompilerLayout;

/* Uses the bundled Android SysInfo block for static-field allocation. */
bool jbed_compiler_layout_android(JbedCompilerLayout *, JbedPool *, JbedWriter *,
                                  const struct JbedVmClassTable *, JbedAddress code_base);

/* Compiler's swap streams use little-endian 16-bit lengths and 32-bit handler
 * cells. These byte-stream services correspond to RawInput/OutputStream. */
typedef struct JbedCompilerSwap {
    void *context;
    bool (*length)(void *, int32_t *, JbedError *);
    bool (*seek)(void *, int32_t, JbedError *);
    bool (*read)(void *, void *, size_t, JbedError *);
    bool (*write)(void *, const void *, size_t, JbedError *);
} JbedCompilerSwap;

/* The driver orchestrates existing compiler classes and VM reflection services.
 * Fallible services return false with the original Java throwable in error.
 * They must not swallow OutOfMemoryError: several catch blocks exclude it.
 * Allocation returns zero-initialized memory with host-managed Java lifetime.
 * Context objects here are explicit replacements for Compiler's r9 statics. */
typedef struct JbedCompilerServices {
    void *context;
    JbedEmitter *emitter;
    void *(*allocate)(void *, size_t, JbedError *);
    void (*raise_error)(void *, const JbedError *); /* Must not return. */
    void (*enter)(void *);
    void (*leave)(void *);
    void (*checkpoint)(void *);
    void (*report_error)(void *, const JbedError *, const JbedClass *, const char *phase);
    void (*report_unresolved)(void *, JbedTypeId, const char *name);
    void (*report_oom_define)(void *, JbedTypeId);
    void (*report_statistics)(void *, bool final);
    const char *(*class_name)(void *, JbedTypeId);
    const char *(*package_name)(void *, JbedTypeId);
    JbedClass *(*class_object_base)(void *);
    JbedClass *(*next_class)(void *, JbedClass *previous);
    JbedTypeId (*next_unresolved)(void *, JbedTypeId previous);
    JbedClass *(*lookup_class)(void *, JbedTypeId);
    JbedClass *(*get_or_create_class)(void *, JbedTypeId, JbedError *);

    bool (*new_class_access)(void *, JbedError *);
    bool (*new_signature_encoder)(void *, JbedError *);
    bool (*new_coder)(void *, uint32_t options, bool long_jumps, JbedError *);
    bool (*coder_has_writer)(void *); /* Coder.writer is attached during translation. */
    bool (*init_pool)(void *, JbedError *);
    bool (*new_verifier)(void *, JbedError *);
    bool (*read_class)(void *, JbedClass **, const uint8_t *, size_t, JbedError *);
    bool (*init_reader)(void *, uint32_t method_offset, JbedError *);
    bool (*prepare_class)(void *, JbedClass *, JbedError *);
    bool (*fixup_relative_fields)(void *, JbedClass *, JbedError *);
    bool (*set_relative_statics)(void *, JbedError *);
    bool (*prepare_done)(void *, JbedError *);
    bool (*verify_class)(void *, JbedClass *, JbedError *);
    bool (*translate_class)(void *, JbedClass *, JbedError *);
    bool (*register_class)(void *, JbedClass *, JbedError *);
    bool (*allocate_descriptor)(void *, JbedClass *, JbedError *);
    bool (*cleanup_writer)(void *, JbedError *);
    bool (*flush_class_fixups)(void *, JbedClass *, uint32_t, JbedError *);
    bool (*flush_current_fixups)(void *, uint32_t, JbedError *);
    bool (*swap_pool_out)(void *, JbedPool *, JbedCompilerSwap *, JbedError *);
    bool (*swap_pool_in)(void *, JbedClass *, JbedCompilerSwap *, JbedError *);

    void (*reset_coder)(void *);
    void (*detach_writer)(void *);
    void (*drop_verifier)(void *);
    void (*drop_signature_encoder)(void *);
    void (*reset_pool)(void *);
    bool (*register_with_runtime)(void *, JbedError *);
    void (*reset_string_interning)(void *);
    void (*clear_dynamic_reflection)(void *);
    void (*reset_class_tables)(void *);
    void (*discard_code_ranges)(void *);
    void (*drop_classes_and_coder)(void *);
    /* Binds Reader, Pool and Writer to class input, swapping, preparation,
     * static layout, class registration and descriptor emission. */
    JbedCompilerLayout *class_layout;
    JbedClassAccess *class_access;
    struct JbedVerifier *verifier;
    struct JbedCoder *coder; /* Initialized with its Thumb backend and target writer. */
    void (*store_class_error)(void *, JbedClass *);
} JbedCompilerServices;

struct JbedCompiler {
    JbedCompilerServices services;
    void *progress_context;
    bool (*progress_listener)(void *, int32_t percent);
    int32_t progress, total, read_weight;
    bool canceled, ignore_class_sanity, swapping;
    bool has_coder;
    uint32_t options;
    uint32_t method_offset; /* Reader.methodOffset, initialized by FCoder.NewCoder. */
    JbedCompilerSwap *swap_input, *swap_output;
    JbedWriter *target_writer;
};

void jbed_compiler_init(JbedCompiler *, const JbedCompilerServices *,
                        bool ignore_sanity_property_present);
void jbed_compiler_set_progress(JbedCompiler *, bool (*)(void *, int32_t), void *, int32_t classes,
                                int32_t read_weight);
void jbed_compiler_clear_progress(JbedCompiler *);
bool jbed_compiler_made_progress(JbedCompiler *, bool post_read_phase);
bool jbed_compiler_is_canceled(const JbedCompiler *);
bool jbed_compiler_full_debug_info(const JbedCompiler *);
void jbed_compiler_enable_swapping(JbedCompiler *, JbedCompilerSwap *output,
                                   JbedCompilerSwap *input);
void jbed_compiler_disable_swapping(JbedCompiler *);
bool jbed_compiler_is_swapping(const JbedCompiler *);
bool jbed_compiler_check_class_sanity(JbedCompiler *, JbedTypeId, JbedError *);
void jbed_compiler_handle_error(JbedCompiler *, const JbedError *, JbedClass *, const char *phase);
bool jbed_compiler_check_error(const JbedClass *, JbedError *);
bool jbed_compiler_swap_class(JbedCompiler *, JbedClass *, JbedError *);
void jbed_compiler_strip_class(JbedClass *);
bool jbed_compiler_restore_class(JbedCompiler *, JbedClass *, JbedError *);
bool jbed_compiler_define(JbedCompiler *, JbedTypeId, const uint8_t *, size_t, JbedError *);
bool jbed_compiler_prepare(JbedCompiler *, JbedClass *, JbedError *);
bool jbed_compiler_verify(JbedCompiler *, JbedClass *, JbedError *);
bool jbed_compiler_translate(JbedCompiler *, JbedClass *, JbedError *);
bool jbed_compiler_compile(JbedCompiler *, JbedError *);
bool jbed_compiler_start(JbedCompiler *, uint32_t options, bool long_jumps,
                         bool (*progress)(void *, int32_t), void *, int32_t classes,
                         int32_t read_weight, JbedError *);
bool jbed_compiler_done(JbedCompiler *, bool register_classes, JbedError *);
bool jbed_compiler_reset(JbedCompiler *, JbedError *);
bool jbed_compiler_flush_fixups(JbedCompiler *, uint32_t boundary, JbedError *);

#endif
