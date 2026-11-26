#include "vm_strings.h"
#include "vm_words.h"

#include <limits.h>
#include <string.h>

enum {
    STATIC_TABLE = 1488, DYNAMIC_TABLE = 1492,
    VALUE = 12, OFFSET = 16, COUNT = 20, NEXT = 24, INTERNED = 28,
    STRING_CLASS = 0x2179e8, CHAR_ARRAY_CLASS = 0x25e9a8, STRING_ARRAY_CLASS = 0x25e2a8,
    ROM_INTERN_TABLE = 0xab358, DYNAMIC_INTERN_BUCKETS = 64
};

/* String.resetIntern, 0xb706c. The platform's permanent table comes from
 * Jbed_start+0x30. Isolate fields hold the two String[] references. */
bool jbed_vm_strings_reset(JbedVmStrings *s)
{
    JbedAddress table = jbed_vm_new_array(s->heap, DYNAMIC_INTERN_BUCKETS, s->image.string_array_class);
    if (!table)
        return false;
    jbed_vm_put_word(s->heap->memory, s->image.dynamic_table_slot, table);
    return true;
}

uint32_t jbed_vm_string_table_size(const JbedVmStrings *s)
{
    JbedBuffer memory = s->heap->memory;
    JbedAddress table = jbed_vm_word(memory, s->image.dynamic_table_slot);
    return jbed_vm_word(memory, table + 12);
}

bool jbed_vm_strings_init_image(JbedVmStrings *s, JbedVmHeap *heap, JbedVmStringImage image,
                                JbedAddress root)
{
    *s = (JbedVmStrings){heap, image, root};
    jbed_vm_put_word(heap->memory, image.static_table_slot, image.intern_table);
    jbed_vm_put_word(heap->memory, root, 0);
    return jbed_vm_strings_reset(s);
}

bool jbed_vm_strings_init(JbedVmStrings *s, JbedVmHeap *heap, JbedAddress base,
                          JbedAddress statics, JbedAddress root)
{
    JbedVmStringImage image = {base + STRING_CLASS, base + CHAR_ARRAY_CLASS,
        base + STRING_ARRAY_CLASS, jbed_vm_word(heap->memory, base + ROM_INTERN_TABLE),
        statics + STATIC_TABLE, statics + DYNAMIC_TABLE};
    return jbed_vm_strings_init_image(s, heap, image, root);
}

static JbedAddress data(JbedBuffer map, JbedAddress string)
{
    return jbed_vm_word(map, string + VALUE) + jbed_vm_word(map, string + OFFSET);
}

/* String.compareTo, 0xb6890. The intern chains compare equal-length strings. */
static bool same_string(JbedBuffer map, JbedAddress left, JbedAddress right, uint32_t count)
{
    if (left == right)
        return true;
    JbedAddress a = data(map, left), b = data(map, right);
    for (uint32_t i = 0; i < count; ++i)
        if (jbed_vm_half(map, a + 2 * i) != jbed_vm_half(map, b + 2 * i))
            return false;
    return true;
}

static JbedAddress find_in_chain(JbedBuffer map, JbedAddress slot, JbedAddress string, uint32_t count)
{
    for (JbedAddress p = jbed_vm_word(map, slot); p; p = jbed_vm_word(map, p + NEXT))
        if (jbed_vm_word(map, p + COUNT) == count && same_string(map, p, string, count))
            return p;
    return 0;
}

/* Allocating a String with the next-locked flag, 0xdf7c8. The collector may
 * relocate the source while the allocation retries. */
static JbedAddress new_locked_string(JbedVmStrings *s, JbedAddress *source)
{
    JbedVmHeap *heap = s->heap;
    JbedVmHeapRoot root = {*source, *source, heap->temporary_roots};
    heap->temporary_roots = &root;
    if (!jbed_vm_next_allocate_locked(heap)) {
        heap->temporary_roots = root.previous;
        return 0;
    }
    JbedAddress result = jbed_vm_new_object(heap, s->image.string_class);
    heap->temporary_roots = root.previous;
    *source = root.value;
    return result;
}

/* String.hashCode / intern(boolean), 0xb6a5e / 0xb6f7c. String(String)
 * copies only the backing array, byte offset and character count. */
JbedAddress jbed_vm_string_intern(JbedVmStrings *s, JbedAddress string, bool create)
{
    JbedBuffer map = s->heap->memory;
    if (*jbed_vm_at(map, string + INTERNED))
        return string;
    uint32_t count = jbed_vm_word(map, string + COUNT), hash = 0;
    JbedAddress text = data(map, string);
    for (uint32_t i = 0; i < count; ++i)
        hash = 31 * hash + jbed_vm_half(map, text + 2 * i);
    JbedAddress table = jbed_vm_word(map, s->image.static_table_slot);
    uint32_t index = hash & (jbed_vm_word(map, table + 12) - 1);
    JbedAddress existing = find_in_chain(map, table + 16 + 4 * index, string, count);
    if (existing)
        return existing;
    table = jbed_vm_word(map, s->image.dynamic_table_slot);
    index = hash & (jbed_vm_word(map, table + 12) - 1);
    existing = find_in_chain(map, table + 16 + 4 * index, string, count);
    if (existing || !create)
        return existing;
    if (!(jbed_vm_word(map, string + 4) & (JBED_OBJECT_PINNED | JBED_OBJECT_LOCK_MASK))) {
        JbedAddress copy = new_locked_string(s, &string);
        if (!copy)
            return 0;
        jbed_vm_put_word(map, copy + VALUE, jbed_vm_word(map, string + VALUE));
        jbed_vm_put_word(map, copy + OFFSET, jbed_vm_word(map, string + OFFSET));
        jbed_vm_put_word(map, copy + COUNT, jbed_vm_word(map, string + COUNT));
        string = copy;
    }
    table = jbed_vm_word(map, s->image.dynamic_table_slot);
    JbedAddress head = table + 16 + 4 * index;
    jbed_vm_put_word(map, string + NEXT, jbed_vm_word(map, head));
    jbed_vm_put_word(map, head, string);
    *jbed_vm_at(map, string + INTERNED) = 1;
    return string;
}

static bool heap_error(JbedVmStrings *s, JbedError *error)
{
    JbedErrorKind kind = s->heap->fault == JBED_HEAP_OUT_OF_MEMORY ? JBED_ERROR_OUT_OF_MEMORY
                                                                   : JBED_ERROR_INTERNAL;
    if (error)
        *error = (JbedError){.kind = kind, .is_java_error = true, .message = "VM string allocation failed"};
    return false;
}

/* Pool.resolveUtf8s (0x12d9b0) shares a char[] among newly interned strings;
 * growing it leaves earlier String objects attached to the previous array. */
bool jbed_vm_pool_character_buffer(JbedVmStrings *s, size_t used, size_t capacity, JbedError *error)
{
    JbedBuffer map = s->heap->memory;
    if (!used)
        jbed_vm_put_word(map, s->character_root, 0);
    JbedAddress array = capacity <= INT32_MAX ?
        jbed_vm_new_array(s->heap, (int32_t)capacity, s->image.char_array_class) : 0;
    if (!array) {
        if (capacity > INT32_MAX)
            s->heap->fault = JBED_HEAP_OUT_OF_MEMORY;
        return heap_error(s, error);
    }
    if (used) {
        JbedAddress previous = jbed_vm_word(map, s->character_root);
        memcpy(jbed_vm_at(map, array + 16), jbed_vm_at(map, previous + 16), 2 * used);
    }
    jbed_vm_put_word(map, s->character_root, array);
    return true;
}

void jbed_vm_pool_finish_characters(JbedVmStrings *s, uint32_t length)
{
    JbedAddress array = jbed_vm_word(s->heap->memory, s->character_root);
    if (array)
        jbed_vm_resize_array(s->heap, array, length);
    jbed_vm_put_word(s->heap->memory, s->character_root, 0);
}

JbedPoolString *jbed_vm_pool_string_at(const JbedPoolServices *services, JbedAddress string)
{
    JbedBuffer map = services->vm_strings->heap->memory;
    JbedPoolString *result = jbed_alloc(services->runtime, sizeof *result);
    uint32_t count = jbed_vm_word(map, string + COUNT);
    uint16_t *chars = count ? jbed_alloc(services->runtime, (size_t)count * sizeof *chars) : NULL;
    JbedAddress text = data(map, string);
    for (uint32_t i = 0; i < count; ++i)
        chars[i] = jbed_vm_half(map, text + 2*i);
    *result = (JbedPoolString){jbed_vm_at(map, string), string, chars, count};
    return result;
}

bool jbed_vm_pool_intern(JbedPool *pool, size_t start, JbedPoolString **out, bool *retained,
                         JbedError *error)
{
    JbedVmStrings *s = pool->services->vm_strings;
    JbedBuffer map = s->heap->memory;
    JbedAddress array = jbed_vm_word(map, s->character_root);
    JbedAddress string = new_locked_string(s, &array);
    if (!string)
        return heap_error(s, error);
    uint32_t count = (uint32_t)(pool->character_count - start);
    uint32_t offset = 16 + 2 * (uint32_t)start;
    for (uint32_t i = 0; i < count; ++i) {
        uint16_t ch = pool->characters[start + i];
        uint8_t *p = jbed_vm_at(map, array + offset + 2*i);
        p[0] = (uint8_t)ch;
        p[1] = (uint8_t)(ch >> 8);
    }
    jbed_vm_put_word(map, string + VALUE, array);
    jbed_vm_put_word(map, string + OFFSET, offset);
    jbed_vm_put_word(map, string + COUNT, count);
    JbedAddress canonical = jbed_vm_string_intern(s, string, true);
    if (!canonical)
        return heap_error(s, error);
    *out = jbed_vm_pool_string_at(pool->services, canonical);
    *retained = canonical == string;
    return true;
}
