#include "writer.h"
#include "vm_stackmap.h"
#include <stdlib.h>
#include <string.h>

_Noreturn void jbed_writer_fault(JbedWriter *w, JbedWriterFault fault, const char *message)
{
    if (w->services && w->services->fault)
        w->services->fault(w->services->context, fault, message);
    abort(); /* A returning exception adapter violates the runtime contract. */
}

static void require(JbedWriter *w, bool condition, const char *message)
{
    if (!condition)
        jbed_writer_fault(w, JBED_WRITER_ASSERTION, message);
}

static uint8_t *direct_bytes(JbedWriter *w, JbedAddress address)
{
    require(w, w->buffer != NULL, "Writer has no allocated buffer");
    return w->buffer->data + (address - w->buffer->address);
}

/* Writer 0x1327d2..0x132894: native little-endian stores, with call
 * instructions emitted as two halfwords even when the instruction is not
 * word-aligned. */
static void direct_word(JbedWriter *w, JbedAddress a, uint32_t v)
{
    uint8_t *p = direct_bytes(w, a);
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16);
    p[3] = (uint8_t)(v >> 24);
}
static void direct_half(JbedWriter *w, JbedAddress a, uint16_t v)
{
    uint8_t *p = direct_bytes(w, a);
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
}
static void direct_byte(JbedWriter *w, JbedAddress a, uint8_t v)
{
    *direct_bytes(w, a) = v;
}
static int16_t direct_get_half(JbedWriter *w, JbedAddress a)
{
    const uint8_t *p = direct_bytes(w, a);
    return (int16_t)((uint16_t)p[0] | ((uint16_t)p[1] << 8));
}
static uint32_t direct_get_word(JbedWriter *w, JbedAddress a)
{
    const uint8_t *p = direct_bytes(w, a);
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}
static void direct_pointer(JbedWriter *w, JbedAddress a, JbedAddress v)
{
    jbed_writer_put_word(w, a, v);
}
static void direct_reloc(JbedWriter *w, JbedAddress a, JbedAddress v, bool dynamic)
{
    (void)dynamic;
    jbed_writer_put_word(w, a, v);
}
static void direct_call(JbedWriter *w, JbedAddress a, uint32_t v, bool dynamic)
{
    (void)dynamic;
    jbed_writer_put_halfword(w, a, (uint16_t)v);
    jbed_writer_put_halfword(w, a + 2, (uint16_t)(v >> 16));
}
static void unsupported_block(JbedWriter *w, JbedAddress a, const uint8_t *p, uint32_t n)
{
    (void)a;
    (void)p;
    (void)n;
    jbed_writer_fault(w, JBED_WRITER_HALT, "Writer.writeBlock");
}
static uint32_t unsupported_label(JbedWriter *w, JbedAddress a, uint32_t label)
{
    (void)a;
    (void)label;
    jbed_writer_fault(w, JBED_WRITER_JAVA_ERROR, "Writer label operation");
    return 0;
}
static uint32_t unsupported_call_label(JbedWriter *w, JbedAddress a, uint32_t call, uint32_t label)
{
    (void)call;
    return unsupported_label(w, a, label);
}

/* Writer.allocIntern 0x132726; Memory's locked managed array is supplied by the
 * runtime, and finishBlock must retain its target address during resize. */
static JbedAddress direct_allocate(JbedWriter *w, JbedCodeOwner *owner, uint32_t n, bool code)
{
    if ((!w->buffer || w->limit - w->cursor < n) && w->stack_maps && w->stack_maps->count)
        jbed_writer_write_stack_maps(w);
    if (!w->buffer || w->limit - w->cursor < n) {
        jbed_writer_finish_block(w);
        require(w, w->services && w->services->new_code_buffer, "Memory.newArray adapter");
        w->buffer = w->services->new_code_buffer(w->services->context, n < 16000 ? 16000 : n);
        if (!w->buffer)
            jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "code buffer");
        w->cursor = w->buffer->address;
        w->limit = w->cursor + w->buffer->size;
    }
    w->owner = owner;
    JbedAddress address = w->cursor;
    if (!code)
        jbed_writer_flush_code(w, owner, address + n);
    return address;
}
static JbedAddress direct_code(JbedWriter *w, JbedCodeOwner *o, uint32_t n, uint32_t minimum)
{
    (void)minimum;
    return direct_allocate(w, o, n, true);
}
static JbedAddress direct_data(JbedWriter *w, JbedCodeOwner *o, uint32_t n)
{
    return direct_allocate(w, o, n, false);
}
static void direct_flush(JbedWriter *w, JbedCodeOwner *o, JbedAddress end)
{
    (void)o;
    w->cursor = (end + 3u) & ~UINT32_C(3);
}
static bool not_reusable(JbedWriter *w)
{
    (void)w;
    return false;
}

static const JbedWriterOps direct_ops = {.reusable = not_reusable,
                                         .allocate_code = direct_code,
                                         .allocate = direct_data,
                                         .allocate_raw = direct_data,
                                         .flush_code = direct_flush,
                                         .put_word = direct_word,
                                         .put_halfword = direct_half,
                                         .put_byte = direct_byte,
                                         .put_pointer = direct_pointer,
                                         .put_static = direct_pointer,
                                         .put_reloc = direct_reloc,
                                         .put_call = direct_call,
                                         .get_halfword = direct_get_half,
                                         .get_word = direct_get_word,
                                         .write_block = unsupported_block,
                                         .write_label = unsupported_label,
                                         .write_call_label = unsupported_call_label,
                                         .write_long_jump_label = unsupported_label,
                                         .set_label = jbed_writer_define_label};

/* Writer constructor 0x13234c. Base reusable/statistics return zero;
 * prepareDone/registerClass are empty in the original base class. */
void jbed_writer_init(JbedWriter *w, const JbedWriterServices *services)
{
    memset(w, 0, sizeof(*w));
    w->ops = &direct_ops;
    w->services = services;
}
void jbed_writer_dispose(JbedWriter *w)
{
    free(w->labels);
    if (w->stack_maps) {
        jbed_stack_map_dispose(w->stack_maps);
        free(w->stack_maps);
    }
    w->labels = NULL;
    w->stack_maps = NULL;
}
uint32_t jbed_writer_get_label(JbedWriter *w)
{
    return ++w->last_label;
} /* 0x132362 */
bool jbed_writer_reusable(JbedWriter *w)
{
    return w->ops->reusable ? w->ops->reusable(w) : false;
}
JbedAddress jbed_writer_allocation_limit(const JbedWriter *w)
{
    return w->block_writer ? w->block_writer->allocation_limit : w->limit;
}
void jbed_writer_define_label(JbedWriter *w, uint32_t label, JbedAddress address)
{
    /* 0x13236c: growth is four times the label index, not capacity doubling. */
    if (label < w->label_capacity) {
        if (w->labels[label] != 0)
            jbed_writer_fault(w, JBED_WRITER_HALT, "label already defined");
    } else {
        uint32_t capacity = label * 4u;
        require(w, capacity > label, "label array size");
        JbedAddress *labels = calloc(capacity, sizeof(*labels));
        if (!labels)
            jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "labels");
        if (w->labels)
            memcpy(labels, w->labels, w->label_capacity * sizeof(*labels));
        free(w->labels);
        w->labels = labels;
        w->label_capacity = capacity;
    }
    w->labels[label] = address;
}
void jbed_writer_set_label(JbedWriter *w, uint32_t label, JbedAddress address)
{
    w->ops->set_label(w, label, address);
}
/* 0x1328b6/0x1328f0: the isolate's Writer static is an explicit slot here. */
JbedWriter *jbed_writer_get_default(JbedWriter **slot, const JbedWriterServices *s)
{
    if (!*slot) {
        *slot = calloc(1, sizeof(**slot));
        if (!*slot)
            abort();
        jbed_writer_init(*slot, s);
    }
    return *slot;
}
void jbed_writer_set_default(JbedWriter **slot, JbedWriter *w)
{
    *slot = w;
}
void jbed_writer_register_class(JbedWriter *w, JbedClass *c)
{
    if (w->block_writer)
        jbed_code_register_class(w->block_writer, c);
} /* base 0x13289a is empty */
void jbed_writer_set_relative_statics(JbedWriter *w, uint32_t size, const uint32_t *ranges,
                                      uint32_t count)
{
    if (w->block_writer)
        jbed_code_set_relative_statics(w->block_writer, size, ranges, count);
    else {
        require(w, w->services && w->services->extend_statics, "Isolate.extendStatics adapter");
        w->services->extend_statics(w->services->context, size, ranges, count);
    }
}
void jbed_writer_finish_block(JbedWriter *w)
{
    /* 0x132492: attaching repeatedly makes the Class.codeObjects pair chain in
     * the original runtime; attach_code owns that managed-object operation. */
    if (!w->buffer)
        return;
    const JbedWriterServices *s = w->services;
    require(w, s && s->resize_code_buffer && s->attach_code && s->flush_cache,
            "finishBlock runtime adapters");
    uint32_t size = w->cursor - w->buffer->address;
    if (s->resize_code_buffer(s->context, w->buffer, size) != w->buffer)
        jbed_writer_fault(w, JBED_WRITER_JAVA_ERROR, "locked code array moved");
    s->flush_cache(s->context, w->buffer->address, size);
    s->attach_code(s->context, w->owner, w->buffer);
    w->buffer = NULL;
    w->owner = NULL;
}
void jbed_writer_write_stack_maps(JbedWriter *w)
{
    /* 0x132560: allocation while serializing maps can call this recursively. */
    if (w->writing_stack_maps)
        return;
    w->writing_stack_maps = true;
    for (JbedStackMapArray *map = w->stack_maps; map; map = map->next) {
        JbedAddress address = jbed_stack_map_write(map, w);
        if (address) {
            const JbedWriterServices *s = w->services;
            if (s && s->stack_map_registry) {
                JbedVmStackMaps *maps = s->stack_map_registry;
                jbed_vm_stack_map_add(maps, address, jbed_vm_stack_map_id(maps));
            } else {
                require(w, s && s->stack_map_id && s->add_stack_map, "StackMapBlock.add adapter");
                s->add_stack_map(s->context, address, s->stack_map_id(s->context));
            }
        }
    }
    if (w->stack_maps)
        jbed_stack_map_recycle(w->stack_maps);
    w->writing_stack_maps = false;
}
void jbed_writer_cleanup(JbedWriter *w)
{
    if (w->ops->cleanup) {
        w->ops->cleanup(w);
        return;
    }
    jbed_writer_write_stack_maps(w);
    jbed_writer_finish_block(w);
}
JbedAddress jbed_writer_allocate_code(JbedWriter *w, JbedCodeOwner *o, uint32_t n, uint32_t m)
{
    return w->ops->allocate_code(w, o, n, m);
}
JbedAddress jbed_writer_allocate(JbedWriter *w, JbedCodeOwner *o, uint32_t n)
{
    return w->ops->allocate(w, o, n);
}
JbedAddress jbed_writer_allocate_raw(JbedWriter *w, JbedCodeOwner *o, uint32_t n)
{
    return w->ops->allocate_raw(w, o, n);
}
void jbed_writer_flush_code(JbedWriter *w, JbedCodeOwner *o, JbedAddress end)
{
    w->ops->flush_code(w, o, end);
}
void jbed_writer_put_word(JbedWriter *w, JbedAddress a, uint32_t v)
{
    w->ops->put_word(w, a, v);
}
void jbed_writer_put_halfword(JbedWriter *w, JbedAddress a, uint16_t v)
{
    w->ops->put_halfword(w, a, v);
}
void jbed_writer_put_byte(JbedWriter *w, JbedAddress a, uint8_t v)
{
    w->ops->put_byte(w, a, v);
}
void jbed_writer_put_pointer(JbedWriter *w, JbedAddress a, JbedAddress v)
{
    w->ops->put_pointer(w, a, v);
}
void jbed_writer_put_static(JbedWriter *w, JbedAddress a, JbedAddress v)
{
    w->ops->put_static(w, a, v);
}
void jbed_writer_put_reloc(JbedWriter *w, JbedAddress a, JbedAddress v, bool d)
{
    w->ops->put_reloc(w, a, v, d);
}
void jbed_writer_put_call(JbedWriter *w, JbedAddress a, uint32_t v, bool d)
{
    w->ops->put_call(w, a, v, d);
}
int16_t jbed_writer_get_halfword(JbedWriter *w, JbedAddress a)
{
    return w->ops->get_halfword(w, a);
}
uint32_t jbed_writer_get_word(JbedWriter *w, JbedAddress a)
{
    return w->ops->get_word(w, a);
}
void jbed_writer_write_block(JbedWriter *w, JbedAddress a, const uint8_t *p, uint32_t n)
{
    w->ops->write_block(w, a, p, n);
}
uint32_t jbed_writer_write_label(JbedWriter *w, JbedAddress a, uint32_t label)
{
    return w->ops->write_label(w, a, label);
}
uint32_t jbed_writer_write_call_label(JbedWriter *w, JbedAddress a, uint32_t call, uint32_t label)
{
    return w->ops->write_call_label(w, a, call, label);
}
uint32_t jbed_writer_write_long_jump_label(JbedWriter *w, JbedAddress a, uint32_t label)
{
    return w->ops->write_long_jump_label(w, a, label);
}

static JbedStackMapArray *base_maps(JbedWriter *w)
{
    if (!w->stack_maps) {
        w->stack_maps = calloc(1, sizeof(*w->stack_maps));
        if (!w->stack_maps)
            jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "stack maps");
        jbed_stack_map_init(w->stack_maps, 0);
    }
    return w->stack_maps;
}
void jbed_writer_add_long_map(JbedWriter *w, JbedAddress pc, const uint32_t *words, uint32_t count)
{
    JbedStackMapArray *map =
        w->block_writer ? jbed_code_stack_map(w->block_writer, pc) : base_maps(w);
    if (!jbed_stack_map_add_long(map, w, pc, words, count))
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "long stack map");
}
void jbed_writer_add_short_map(JbedWriter *w, JbedAddress pc, uint32_t bits)
{
    JbedStackMapArray *map =
        w->block_writer ? jbed_code_stack_map(w->block_writer, pc) : base_maps(w);
    if (!jbed_stack_map_add_short(map, w, pc, bits * 4u))
        jbed_writer_fault(w, w->block_writer ? JBED_WRITER_OUT_OF_CODE : JBED_WRITER_ASSERTION,
                          "short stack map");
}
static uint32_t map_count(const JbedWriter *w, bool longs)
{
    uint32_t count = 0;
    if (!w->block_writer) {
        for (const JbedStackMapArray *m = w->stack_maps; m; m = m->next)
            count += longs ? m->long_count : m->count;
    } else {
        const JbedCodeBlockWriter *b = w->block_writer;
        count = longs ? b->flushed_long_words : b->flushed_map_count;
        for (unsigned i = 0; i < 8; i++)
            for (const JbedStackMapArray *m = b->maps[i]; m; m = m->next)
                /* 0x177320/0x177380 deliberately read the head each time. */
                count += longs ? b->maps[i]->long_count : b->maps[i]->count;
    }
    return count;
}
uint32_t jbed_writer_map_count(const JbedWriter *w)
{
    return map_count(w, false);
}
uint32_t jbed_writer_long_map_words(const JbedWriter *w)
{
    return map_count(w, true);
}
uint32_t jbed_writer_blocks_generated(const JbedWriter *w)
{
    return w->block_writer ? jbed_code_blocks_generated(w->block_writer) : 0;
}
uint32_t jbed_writer_code_load(const JbedWriter *w)
{
    return w->block_writer ? jbed_code_load(w->block_writer) : 0;
}
uint32_t jbed_writer_total_joined(const JbedWriter *w)
{
    return w->block_writer ? w->block_writer->total_joined : 0;
}
uint32_t jbed_writer_large_block_count(const JbedWriter *w)
{
    return w->block_writer ? w->block_writer->large_count : 0;
}

/* CodeBlock 0x157e56..0x157f20. reset delegates to register, startWrite/flush
 * are empty and readable always true. Runtime CodeAnchor owns registration. */
void jbed_code_block_register(JbedCodeBlock *b)
{
    if (!b->registered) {
        b->register_anchor(b->runtime_context, b);
        b->registered = true;
    }
}
void jbed_code_block_deregister(JbedCodeBlock *b)
{
    if (!b->registered)
        abort();
    b->deregister_anchor(b->runtime_context, b);
    b->registered = false;
}
void jbed_code_block_init(JbedCodeBlock *b, void *context, void (*add)(void *, JbedCodeBlock *),
                          void (*remove)(void *, JbedCodeBlock *))
{
    b->registered = false;
    b->runtime_context = context;
    b->register_anchor = add;
    b->deregister_anchor = remove;
}
void jbed_code_block_read(JbedCodeBlock *b, JbedAddress destination, const uint8_t *source,
                          uint32_t offset, uint32_t count,
                          void (*move)(void *, JbedAddress, const uint8_t *, uint32_t))
{
    move(b->runtime_context, destination, source + offset, count);
}
