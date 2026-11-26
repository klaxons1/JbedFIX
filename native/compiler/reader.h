#ifndef JBED_COMPILER_READER_H
#define JBED_COMPILER_READER_H

#include "pool.h"
#include "writer.h"

struct JbedReader {
    JbedRuntime *runtime;
    JbedEmitter *emitter;
    const uint8_t *data;
    size_t data_length;
    int32_t offset;
    int32_t bytes_left;
    JbedStackMaps map;
    size_t map_capacity;
};

bool jbed_reader_init(JbedReader *, JbedRuntime *, const uint8_t *, size_t, int32_t offset,
                      int32_t length, JbedError *);
uint8_t jbed_reader_read(JbedReader *);
uint16_t jbed_reader_u2(JbedReader *);
uint32_t jbed_reader_s4(JbedReader *);
bool jbed_reader_bytes(JbedReader *, void *, int32_t count, JbedError *);
void jbed_reader_skip(JbedReader *, int32_t);
bool jbed_reader_close(const JbedReader *);
int32_t jbed_reader_position(const JbedReader *);
int32_t jbed_reader_remaining(const JbedReader *);
bool jbed_reader_maps(JbedReader *, JbedEmitter *, const JbedMethod *, JbedStackMaps *,
                      JbedError *);
bool jbed_reader_class(JbedReader *, const JbedPoolServices *, JbedClass *, JbedError *);

/* Reader's static allocation cursors and the original platform constants. */
typedef struct JbedReaderLayout {
    int32_t next_init_flag;
    int32_t first_pointer_range;
    int32_t primitive_static_top;
    int32_t pointer_static_top;
    uint32_t relative_statics_base;
    int32_t initial_static_capacity;
    uint32_t static_base;
    uint32_t code_mode_bit;
} JbedReaderLayout;

/* These calls are Writer/reflection primitives, not replacements for Reader's
 * allocation, inheritance or vtable algorithms. */
typedef struct JbedReaderLayoutServices {
    JbedPool *pool;
    void *context;
    JbedClass *array_base_class;
    uint32_t throw_abstract_address;
    bool (*register_class)(void *, JbedClass *, JbedError *);
    bool (*allocate_descriptor)(void *, JbedClass *, uint32_t, uint32_t *, JbedError *);
    bool (*pointer_fields)(void *, JbedClass *, uint32_t, bool write, uint32_t *, JbedError *);
    bool (*put_word)(void *, uint32_t, uint32_t, JbedError *);
    bool (*put_halfword)(void *, uint32_t, uint16_t, JbedError *);
    bool (*put_class)(void *, uint32_t, JbedClass *, JbedError *);
    bool (*put_relocation)(void *, uint32_t, uint32_t, bool resident, JbedError *);
    bool (*method_by_number)(void *, JbedClass *, int32_t, JbedMethod **, JbedError *);
} JbedReaderLayoutServices;

void jbed_reader_layout_use_writer(JbedReaderLayoutServices *, JbedWriter *);

void jbed_reader_layout_init(JbedReaderLayout *, uint32_t relative_base, int32_t capacity,
                             uint32_t static_base, uint32_t mode_bit);
bool jbed_reader_prepare(JbedReaderLayout *, const JbedReaderLayoutServices *, JbedClass *,
                         JbedError *);
void jbed_reader_fixup_fields(JbedReaderLayout *, JbedClass *);
size_t jbed_reader_pointer_ranges(const JbedReaderLayout *, uint32_t ranges[4]);
uint32_t jbed_reader_relative_statics_size(const JbedReaderLayout *);
bool jbed_reader_allocate_descriptor(const JbedReaderLayout *, const JbedReaderLayoutServices *,
                                     JbedClass *, JbedError *);

#endif
