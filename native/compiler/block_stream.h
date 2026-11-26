#ifndef JBED_COMPILER_BLOCK_STREAM_H
#define JBED_COMPILER_BLOCK_STREAM_H

#include "writer.h"

/* Stream integers are big endian; generated ARM words are little endian. */
typedef struct JbedBlockIo {
    void *context;
    bool (*read)(void *, void *, uint32_t);
    bool (*write)(void *, const void *, uint32_t);
    bool (*seek)(void *, uint32_t);
    uint32_t (*position)(void *);
    uint32_t (*length)(void *);
    bool (*close)(void *);
} JbedBlockIo;

typedef struct JbedBlockIdentity {
    uint32_t fingerprint;
    JbedAddress system_info_address;
    uint32_t build_id;
    bool full_debug_info;
} JbedBlockIdentity;

typedef struct JbedFileBlockLoader JbedFileBlockLoader;
typedef struct JbedRomServices JbedRomServices;

typedef enum JbedBlockLoadFault {
    JBED_BLOCK_BAD_MAGIC = 1,
    JBED_BLOCK_WRONG_VM = 2,
    JBED_BLOCK_WRONG_BUILD = 3,
    JBED_BLOCK_BAD_DATA = 4
} JbedBlockLoadFault;

/* HeapCodeBlocks operations supplied by the embedding VM.
 * Allocation returns target addresses plus independently accessible host bytes.
 * load_fault must transfer control to the host's exception boundary. */
typedef struct JbedBlockServices {
    void *context;
    bool (*allocate_blocks)(void *, uint32_t, JbedAddress *);
    JbedBuffer *(*allocate_large_block)(void *, uint32_t);
    bool (*read_code)(void *, JbedAddress, void *, uint32_t);
    bool (*write_code)(void *, JbedAddress, const void *, uint32_t);
    void (*begin_write)(void *);
    void (*end_write)(void *);
    void (*flush_fixups)(void *, JbedAddress);
    const JbedRomServices *rom_services;
    void (*load_fault)(void *, JbedBlockLoadFault, const char *);
} JbedBlockServices;

typedef struct JbedBlockVector {
    uint32_t *values;
    uint32_t length;
} JbedBlockVector;

typedef struct JbedBlockStreamWriter JbedBlockStreamWriter;
struct JbedBlockStreamWriter {
    JbedCodeBlockWriter base;
    JbedWriterOps ops;
    JbedCodeBlockHooks hooks;
    const JbedBlockServices *blocks;
    JbedBlockVector dynamic_chains, large_chains, label_chains;
    JbedBlockVector static_chains, static_pages;
    uint32_t static_page_count;
    JbedBlockVector static_data_chains;
    uint32_t static_data_count;
    void (*store_blocks)(JbedBlockStreamWriter *, uint32_t);
    void (*close_store)(JbedBlockStreamWriter *);
};

typedef struct JbedFileBlockWriter {
    JbedBlockStreamWriter stream;
    JbedBlockIo output;
    void *deflater;
    JbedBlockVector joined_ranges;
    uint32_t joined_words, blocks_stored;
} JbedFileBlockWriter;

typedef struct JbedDirectCodeWriter {
    JbedCodeBlockWriter base;
    JbedWriterOps ops, buffered_ops;
    JbedCodeBlockHooks hooks;
    const JbedBlockServices *blocks;
    JbedBlockVector label_chains, code_addresses, group_first;
    uint32_t blocks_stored, blocks_allocated;
} JbedDirectCodeWriter;

typedef struct JbedXipBlockWriter {
    JbedBlockStreamWriter stream;
    JbedWriterOps buffered_ops;
    JbedBlockVector code_addresses, large_addresses;
    JbedBlockVector pending_heads, pending_pages;
    uint32_t pending_count, blocks_allocated, large_allocated, blocks_stored;
    JbedAddress deferred_heads[JBED_BUFFER_BLOCKS];
    JbedAddress install_address;
} JbedXipBlockWriter;

struct JbedFileBlockLoader {
    JbedWriter diagnostics;
    const JbedBlockServices *blocks;
    JbedBlockIdentity identity;
    uint32_t flags, code_count, large_count, large_extent, label_count;
    JbedBlockVector code_addresses, large_addresses, large_bases, labels;
    JbedBlockVector dynamic_chains, large_chains, label_chains;
    JbedBlockVector static_chains, static_pages;
    uint8_t *buffer;
    uint32_t buffer_size;
};

void jbed_block_stream_init(JbedBlockStreamWriter *, const JbedWriterServices *,
                            const JbedBlockServices *);
void jbed_block_stream_dispose(JbedBlockStreamWriter *);
void jbed_block_stream_store(JbedBlockStreamWriter *);
bool jbed_block_stream_reusable(const JbedBlockStreamWriter *);
void jbed_block_stream_add_static_fixup(JbedBlockStreamWriter *, JbedAddress, JbedAddress,
                                        uint32_t);
void jbed_block_stream_add_dynamic_fixup(JbedBlockStreamWriter *, JbedAddress, JbedAddress,
                                         uint32_t);
void jbed_block_stream_add_large_fixup(JbedBlockStreamWriter *, JbedAddress, JbedAddress);
void jbed_block_stream_add_label_fixup(JbedBlockStreamWriter *, JbedAddress, uint32_t, uint32_t);

void jbed_file_writer_init(JbedFileBlockWriter *, const JbedWriterServices *,
                           const JbedBlockServices *, JbedBlockIo, const JbedBlockIdentity *);
void jbed_file_writer_dispose(JbedFileBlockWriter *);
void jbed_file_writer_store_blocks(JbedFileBlockWriter *, uint32_t);
void jbed_file_writer_close(JbedFileBlockWriter *);

void jbed_direct_writer_init(JbedDirectCodeWriter *, const JbedWriterServices *,
                             const JbedBlockServices *);
void jbed_direct_writer_dispose(JbedDirectCodeWriter *);
JbedAddress jbed_direct_relocate(JbedDirectCodeWriter *, JbedAddress);
JbedAddress jbed_direct_relocate_label(JbedDirectCodeWriter *, uint32_t);
void jbed_direct_cleanup(JbedDirectCodeWriter *);
void jbed_direct_write_call_label(JbedDirectCodeWriter *, JbedAddress, uint32_t, uint32_t);

void jbed_xip_writer_init(JbedXipBlockWriter *, const JbedWriterServices *,
                          const JbedBlockServices *);
void jbed_xip_writer_dispose(JbedXipBlockWriter *);
JbedAddress jbed_xip_relocate(JbedXipBlockWriter *, JbedAddress);
JbedAddress jbed_xip_relocate_label(JbedXipBlockWriter *, uint32_t);
bool jbed_xip_label_defined(const JbedXipBlockWriter *, uint32_t);
uint32_t jbed_xip_write_call_label(JbedXipBlockWriter *, JbedAddress, uint32_t, uint32_t);
JbedAddress jbed_xip_install_address(JbedXipBlockWriter *);

void jbed_file_loader_init(JbedFileBlockLoader *, const JbedWriterServices *,
                           const JbedBlockServices *, const JbedBlockIdentity *);
void jbed_file_loader_dispose(JbedFileBlockLoader *);
void jbed_file_loader_load(JbedFileBlockLoader *, JbedBlockIo);
JbedAddress jbed_file_loader_relocate(JbedFileBlockLoader *, JbedAddress);
JbedAddress jbed_file_loader_relocate_label(JbedFileBlockLoader *, uint32_t);
/* Patch a chain in one 8192-byte staging block; return its first site in the
 * following block, or zero when exhausted. Exposed for binary-format tests. */
JbedAddress jbed_file_loader_fixup(JbedFileBlockLoader *, JbedAddress, JbedAddress, bool, bool);

#endif
