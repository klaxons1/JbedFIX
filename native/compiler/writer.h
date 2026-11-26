#ifndef JBED_COMPILER_WRITER_H
#define JBED_COMPILER_WRITER_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Semantic reconstruction of the original libjbedvm.so Thumb methods. Target
 * addresses are 32-bit values; they are never cast to pointers in the host. */
typedef uint32_t JbedAddress;
typedef struct JbedWriter JbedWriter;
typedef struct JbedCodeBlockWriter JbedCodeBlockWriter;
typedef struct JbedStackMapArray JbedStackMapArray;
typedef struct JbedCodeOwner JbedCodeOwner;
typedef struct JbedClass JbedClass;
typedef struct JbedRomObjects JbedRomObjects;
typedef struct JbedRomServices JbedRomServices;

typedef struct JbedImageView {
    const uint8_t *bytes;
    size_t size;
    JbedAddress base;
} JbedImageView;

typedef struct JbedBuffer {
    uint8_t *data;
    uint32_t size;
    JbedAddress address;
} JbedBuffer;

typedef enum JbedWriterFault {
    JBED_WRITER_ASSERTION,
    JBED_WRITER_OUT_OF_CODE,
    JBED_WRITER_UNSUPPORTED, /* Required runtime or abstract-subclass adapter is missing. */
    JBED_WRITER_HALT,        /* Original System.halt, including forbidden base operations. */
    JBED_WRITER_OUT_OF_MEMORY,
    JBED_WRITER_JAVA_ERROR, /* Original java.lang.Error, distinct from adapter absence. */
    JBED_WRITER_ARRAY_INDEX
} JbedWriterFault;

typedef enum JbedPointerKind {
    JBED_POINTER_RESIDENT_OBJECT,
    JBED_POINTER_MOVABLE_OBJECT,
    JBED_POINTER_RESIDENT_CLASS,
    JBED_POINTER_COMPILED_CLASS
} JbedPointerKind;

/* These are original runtime dependencies, not stand-in implementations. The
 * adapter supplies managed ownership, target-address allocation and ROM tables.
 * fault must not return, matching the original Assert/Error exception paths. */
typedef struct JbedWriterServices {
    void *context;
    void (*fault)(void *, JbedWriterFault, const char *);
    JbedBuffer *(*new_code_buffer)(void *, uint32_t);
    JbedBuffer *(*resize_code_buffer)(void *, JbedBuffer *, uint32_t);
    void (*attach_code)(void *, JbedCodeOwner *, JbedBuffer *);
    void (*flush_cache)(void *, JbedAddress, uint32_t);
    void (*extend_statics)(void *, uint32_t, const uint32_t *, uint32_t);
    uint32_t (*stack_map_id)(void *);
    void (*add_stack_map)(void *, JbedAddress, uint32_t);
    const JbedRomServices *rom_services;
    bool full_debug_info;
    JbedPointerKind (*pointer_kind)(void *, JbedAddress);
    JbedClass *(*class_at)(void *, JbedAddress);
    int32_t (*allocation_test_property)(void *);
    uint32_t (*random_int)(void *);
    struct JbedVmStackMaps *stack_map_registry;
} JbedWriterServices;

typedef struct JbedWriterOps {
    bool (*reusable)(JbedWriter *);
    JbedAddress (*allocate_code)(JbedWriter *, JbedCodeOwner *, uint32_t, uint32_t);
    JbedAddress (*allocate)(JbedWriter *, JbedCodeOwner *, uint32_t);
    JbedAddress (*allocate_raw)(JbedWriter *, JbedCodeOwner *, uint32_t);
    void (*flush_code)(JbedWriter *, JbedCodeOwner *, JbedAddress);
    void (*put_word)(JbedWriter *, JbedAddress, uint32_t);
    void (*put_halfword)(JbedWriter *, JbedAddress, uint16_t);
    void (*put_byte)(JbedWriter *, JbedAddress, uint8_t);
    void (*put_pointer)(JbedWriter *, JbedAddress, JbedAddress);
    void (*put_static)(JbedWriter *, JbedAddress, JbedAddress);
    void (*put_reloc)(JbedWriter *, JbedAddress, JbedAddress, bool);
    void (*put_call)(JbedWriter *, JbedAddress, uint32_t, bool);
    int16_t (*get_halfword)(JbedWriter *, JbedAddress);
    uint32_t (*get_word)(JbedWriter *, JbedAddress);
    void (*write_block)(JbedWriter *, JbedAddress, const uint8_t *, uint32_t);
    uint32_t (*write_label)(JbedWriter *, JbedAddress, uint32_t);
    uint32_t (*write_call_label)(JbedWriter *, JbedAddress, uint32_t, uint32_t);
    uint32_t (*write_long_jump_label)(JbedWriter *, JbedAddress, uint32_t);
    void (*set_label)(JbedWriter *, uint32_t, JbedAddress);
    void (*cleanup)(JbedWriter *);
} JbedWriterOps;

struct JbedWriter {
    const JbedWriterOps *ops;
    const JbedWriterServices *services;
    JbedCodeBlockWriter *block_writer;   /* semantic subtype link, not a ROM field */
    JbedAddress cursor;                  /* original +12 */
    JbedBuffer *buffer;                  /* +16 */
    JbedAddress limit;                   /* +20 */
    JbedCodeOwner *owner;                /* +24: Method or Class */
    JbedAddress *labels;                 /* +28 */
    uint32_t label_capacity, last_label; /* last_label +32 */
    JbedStackMapArray *stack_maps;       /* +36 */
    bool writing_stack_maps;             /* +40 */
};

/* Compact stack-map entries combine a word PC offset and a 12-bit descriptor. */
enum {
    JBED_STACK_MAP_PC_MASK = 0xfffff,
    JBED_STACK_MAP_DESCRIPTOR_SHIFT = 20,
    JBED_STACK_MAP_DESCRIPTOR_LIMIT = 4096,
    JBED_STACK_MAP_LONG = 1,
    JBED_STACK_MAP_DELTA = 2,
    JBED_STACK_MAP_DELTA_OFFSET_SHIFT = 6,
    JBED_STACK_MAP_DELTA_MASK = 31,
    JBED_STACK_MAP_BITMAP_BITS = 31,
    JBED_STACK_MAP_HEADER_PC = 0,
    JBED_STACK_MAP_HEADER_NEXT = 4,
    JBED_STACK_MAP_HEADER_LENGTH = 8,
    JBED_STACK_MAP_HEADER_COUNT = 12,
    JBED_STACK_MAP_HEADER_CAPACITY = 16,
    JBED_STACK_MAP_HEADER_BYTES = 20
};
#define JBED_STACK_MAP_CONTINUATION UINT32_C(0x80000000)

struct JbedStackMapArray {
    uint32_t *entries, *long_words; /* original +12,+16 */
    uint32_t count, long_count;     /* +20,+24 */
    uint32_t entry_capacity, long_capacity;
    JbedAddress start, end, emitted; /* +28,+32,+36 */
    uint32_t max_long_words;         /* +40, initially 1 */
    bool ended;                      /* +44 */
    uint32_t max_bytes;              /* +48, zero means unbounded */
    JbedStackMapArray *next;         /* +52 */
};

#define JBED_CODE_BASE UINT32_C(0xd0000000)
#define JBED_LARGE_BASE UINT32_C(0xe0000000)
#define JBED_BLOCK_SIZE UINT32_C(8192)
#define JBED_BUFFER_BLOCKS 8u
#define JBED_BUFFER_SIZE (JBED_BLOCK_SIZE * JBED_BUFFER_BLOCKS)

/* A relocation-chain word stores a 14-bit target offset, a call flag,
 * and the signed byte displacement to the next relocation site. */
#define JBED_FIXUP_PAGE_SHIFT 14u
#define JBED_FIXUP_PAGE_MASK UINT32_C(0x3fff)
#define JBED_FIXUP_CALL UINT32_C(0x4000)
#define JBED_FIXUP_METADATA_MASK UINT32_C(0x7fff)
#define JBED_FIXUP_DELTA_SHIFT 15u
#define JBED_FIXUP_DELTA_SIGN UINT32_C(0x10000)
#define JBED_FIXUP_DELTA_RANGE INT32_C(0x20000)

typedef struct JbedCodeBlockHooks {
    void (*allocation_undone)(JbedCodeBlockWriter *);
    void (*flush_blocks)(JbedCodeBlockWriter *, uint32_t);
    JbedBuffer *(*new_large_block)(JbedCodeBlockWriter *, uint32_t);
    void (*store_large_blocks)(JbedCodeBlockWriter *);
    void (*generate_extra_data)(JbedCodeBlockWriter *);
    void (*add_label_fixup)(JbedCodeBlockWriter *, JbedAddress, uint32_t, uint32_t);
    void (*check_address)(JbedCodeBlockWriter *, JbedAddress, uint32_t);
} JbedCodeBlockHooks;

struct JbedCodeBlockWriter {
    JbedWriter writer;
    const JbedCodeBlockHooks *hooks;
    JbedAddress top, buffer_base, allocation_start, allocation_limit; /* +44..56 */
    uint32_t used[JBED_BUFFER_BLOCKS], joined_mask, no_alloc_mask;    /* +60..68 */
    uint8_t bytes[JBED_BUFFER_SIZE];                                  /* +72 managed byte[] */
    bool access_forbidden, allocation_forbidden, maps_forbidden;      /* +76..78 */
    JbedAddress large_top;                                            /* +80 */
    uint32_t large_count, large_capacity;
    JbedAddress *large_bases;                       /* +88 */
    JbedBuffer **large_blocks;                      /* +92 */
    JbedStackMapArray *maps[JBED_BUFFER_BLOCKS];    /* +96 */
    JbedStackMapArray *pending_maps[16];            /* +100 */
    uint32_t pending_count;                         /* +104 */
    bool flushing_maps;                             /* +108 */
    uint32_t flushed_map_count, flushed_long_words; /* +112,+116 */
    JbedRomObjects *rom_objects;                    /* +120 */
    uint32_t actual_bytes;                          /* +124 */
    JbedAddress split_chain_head;                   /* +128 */
    uint32_t flushed_bytes, total_joined;           /* +132,+136 */
    JbedAddress chain_heads[8], chain_tails[8];     /* Arch +140,+144 */
};

typedef struct JbedCodeBlock {
    bool registered;
    void *runtime_context;
    void (*register_anchor)(void *, struct JbedCodeBlock *);
    void (*deregister_anchor)(void *, struct JbedCodeBlock *);
} JbedCodeBlock;

_Noreturn void jbed_writer_fault(JbedWriter *, JbedWriterFault, const char *);
void jbed_writer_init(JbedWriter *, const JbedWriterServices *);
void jbed_writer_dispose(JbedWriter *);
uint32_t jbed_writer_get_label(JbedWriter *);
bool jbed_writer_reusable(JbedWriter *);
JbedAddress jbed_writer_allocation_limit(const JbedWriter *);
void jbed_writer_set_label(JbedWriter *, uint32_t, JbedAddress);
void jbed_writer_define_label(JbedWriter *, uint32_t, JbedAddress);
JbedWriter *jbed_writer_get_default(JbedWriter **, const JbedWriterServices *);
void jbed_writer_set_default(JbedWriter **, JbedWriter *);
void jbed_writer_register_class(JbedWriter *, JbedClass *);
void jbed_writer_set_relative_statics(JbedWriter *, uint32_t, const uint32_t *, uint32_t);
void jbed_writer_finish_block(JbedWriter *);
void jbed_writer_write_stack_maps(JbedWriter *);
void jbed_writer_cleanup(JbedWriter *);
JbedAddress jbed_writer_allocate_code(JbedWriter *, JbedCodeOwner *, uint32_t, uint32_t);
JbedAddress jbed_writer_allocate(JbedWriter *, JbedCodeOwner *, uint32_t);
JbedAddress jbed_writer_allocate_raw(JbedWriter *, JbedCodeOwner *, uint32_t);
void jbed_writer_flush_code(JbedWriter *, JbedCodeOwner *, JbedAddress);
void jbed_writer_put_word(JbedWriter *, JbedAddress, uint32_t);
void jbed_writer_put_halfword(JbedWriter *, JbedAddress, uint16_t);
void jbed_writer_put_byte(JbedWriter *, JbedAddress, uint8_t);
void jbed_writer_put_pointer(JbedWriter *, JbedAddress, JbedAddress);
void jbed_writer_put_static(JbedWriter *, JbedAddress, JbedAddress);
void jbed_writer_put_reloc(JbedWriter *, JbedAddress, JbedAddress, bool);
void jbed_writer_put_call(JbedWriter *, JbedAddress, uint32_t, bool);
int16_t jbed_writer_get_halfword(JbedWriter *, JbedAddress);
uint32_t jbed_writer_get_word(JbedWriter *, JbedAddress);
void jbed_writer_write_block(JbedWriter *, JbedAddress, const uint8_t *, uint32_t);
uint32_t jbed_writer_write_label(JbedWriter *, JbedAddress, uint32_t);
uint32_t jbed_writer_write_call_label(JbedWriter *, JbedAddress, uint32_t, uint32_t);
uint32_t jbed_writer_write_long_jump_label(JbedWriter *, JbedAddress, uint32_t);
void jbed_writer_add_long_map(JbedWriter *, JbedAddress, const uint32_t *, uint32_t);
void jbed_writer_add_short_map(JbedWriter *, JbedAddress, uint32_t);
uint32_t jbed_writer_map_count(const JbedWriter *);
uint32_t jbed_writer_long_map_words(const JbedWriter *);
uint32_t jbed_writer_blocks_generated(const JbedWriter *);
uint32_t jbed_writer_code_load(const JbedWriter *);
uint32_t jbed_writer_total_joined(const JbedWriter *);
uint32_t jbed_writer_large_block_count(const JbedWriter *);

void jbed_stack_map_init(JbedStackMapArray *, uint32_t);
void jbed_stack_map_dispose(JbedStackMapArray *);
bool jbed_stack_map_add_short(JbedStackMapArray *, JbedWriter *, JbedAddress, uint32_t);
bool jbed_stack_map_add_long(JbedStackMapArray *, JbedWriter *, JbedAddress, const uint32_t *,
                             uint32_t);
void jbed_stack_map_set_end(JbedStackMapArray *, JbedWriter *, JbedAddress);
JbedAddress jbed_stack_map_write(JbedStackMapArray *, JbedWriter *);
void jbed_stack_map_recycle(JbedStackMapArray *);

void jbed_code_writer_init(JbedCodeBlockWriter *, const JbedWriterServices *,
                           const JbedCodeBlockHooks *);
extern const JbedWriterOps jbed_code_writer_ops;
void jbed_code_writer_dispose(JbedCodeBlockWriter *);
uint32_t jbed_code_block_index(const JbedCodeBlockWriter *, JbedAddress);
JbedAddress jbed_code_block_base(const JbedCodeBlockWriter *, uint32_t);
uint32_t jbed_code_blocks_present(const JbedCodeBlockWriter *);
uint32_t jbed_code_blocks_generated(const JbedCodeBlockWriter *);
uint32_t jbed_code_last_joined(const JbedCodeBlockWriter *, uint32_t);
JbedAddress jbed_code_allocate(JbedCodeBlockWriter *, uint32_t, uint32_t);
JbedAddress jbed_code_allocate_large(JbedCodeBlockWriter *, uint32_t);
void jbed_code_close_allocation(JbedCodeBlockWriter *, JbedAddress);
void jbed_code_prevent_allocations(JbedCodeBlockWriter *, uint32_t);
void jbed_code_move_top(JbedCodeBlockWriter *, JbedAddress);
void jbed_code_flush_blocks(JbedCodeBlockWriter *, uint32_t);
void jbed_code_queue_maps(JbedCodeBlockWriter *, uint32_t);
void jbed_code_flush_maps(JbedCodeBlockWriter *, JbedAddress);
void jbed_code_flush_all(JbedCodeBlockWriter *);
void jbed_code_check_address(JbedCodeBlockWriter *, JbedAddress, uint32_t);
void jbed_code_check_access(JbedCodeBlockWriter *, JbedAddress, uint32_t);
JbedStackMapArray *jbed_code_stack_map(JbedCodeBlockWriter *, JbedAddress);
uint32_t jbed_code_write_label(JbedCodeBlockWriter *, JbedAddress, uint32_t);
uint32_t jbed_code_write_call_label(JbedCodeBlockWriter *, JbedAddress, uint32_t, uint32_t);
void jbed_code_register_class(JbedCodeBlockWriter *, JbedClass *);
void jbed_code_set_relative_statics(JbedCodeBlockWriter *, uint32_t, const uint32_t *, uint32_t);
uint32_t jbed_code_total_size(const JbedCodeBlockWriter *);
uint32_t jbed_code_load(const JbedCodeBlockWriter *);
void jbed_code_allocation_test(JbedCodeBlockWriter *, int32_t, uint32_t);

bool jbed_thumb_call_encode(JbedAddress, JbedAddress, uint32_t *);
JbedAddress jbed_thumb_call_destination(JbedAddress, uint32_t);
void jbed_thumb_call_write(JbedWriter *, JbedAddress, JbedAddress, uint8_t *, uint32_t);
JbedAddress jbed_code_add_fixup(JbedCodeBlockWriter *, JbedAddress, JbedAddress, uint32_t);
JbedAddress jbed_code_truncate_chain(JbedCodeBlockWriter *, JbedAddress, JbedAddress, JbedAddress);
JbedAddress jbed_code_split_chain(JbedCodeBlockWriter *, JbedAddress, uint32_t);
void jbed_code_block_register(JbedCodeBlock *);
void jbed_code_block_deregister(JbedCodeBlock *);
void jbed_code_block_init(JbedCodeBlock *, void *, void (*)(void *, JbedCodeBlock *),
                          void (*)(void *, JbedCodeBlock *));
void jbed_code_block_read(JbedCodeBlock *, JbedAddress, const uint8_t *, uint32_t, uint32_t,
                          void (*)(void *, JbedAddress, const uint8_t *, uint32_t));

#endif
