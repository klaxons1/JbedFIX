#include "coder.h"
#include "method_ranges.h"
#include "thumb.h"
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void *allocations[64];
static size_t allocated;
static void *allocate(void *context, size_t size)
{
    (void)context;
    assert(allocated < sizeof(allocations) / sizeof(*allocations));
    void *result = calloc(1, size);
    assert(result);
    allocations[allocated++] = result;
    return result;
}
static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    fprintf(stderr, "unexpected compiler error %d\n", error->kind);
    abort();
}

static void split_method_ranges(JbedRuntime *rt)
{
    JbedCoder coder = {.runtime = rt, .method_code_range_index = -1};
    jbed_coder_add_code_range(&coder, 0x1000, 0x1003);
    jbed_coder_add_code_range(&coder, 0, 0);
    jbed_coder_add_code_range(&coder, 0x2000, 0x2001);
    jbed_coder_add_code_range(&coder, 0x3000, 0x3003);
    jbed_coder_add_code_range(&coder, 0, 0);
    assert(coder.method_code_range_index == 0 && coder.method_code_length == 7);
    /* getOffset(Method,int) starts at word 4*size; getCodeRanges starts at 2*size. */
    JbedMethod method = {.flags = JBED_METHOD_CODE_RANGES, .generated_size = 1};
    JbedClass owner = {.methods = &method};
    assert(jbed_method_pc_offset(rt, &method, 0x2000) == 0);
    assert(jbed_method_pc_offset(rt, &method, 0x3003) == 5);
    assert(jbed_search_dynamic_method_by_pc(rt, &owner, 0x3001) == &method);
    assert(!jbed_search_dynamic_method_by_pc(rt, &owner, 0x3004));
    method.generated_size = 2;
    uint32_t *words = NULL;
    size_t used = 0, capacity = 0;
    jbed_method_pack_ranges(rt, &method, &words, &used, &capacity);
    const uint32_t expected[] = {0x2000, 0x2001, 0x3000, 0x3003, 0, 0};
    assert(method.generated_size == 0 && used == 6 && !memcmp(words, expected, sizeof expected));

    uint8_t image[56 + 16 + 16 + sizeof expected] = {0};
    image[52] = 1;     /* one method */
    image[54] = 1;     /* one field */
    image[56 + 2] = 8; /* ACC_CODERANGES */
    image[56 + 8] = 1;
    for (size_t i = 0; i < used; ++i)
        for (size_t byte = 0; byte < 4; ++byte)
            image[88 + i * 4 + byte] = (uint8_t)(words[i] >> (byte * 8));
    assert(jbed_search_rom_method_by_pc(rt, image, sizeof(image), 0x3003) == image + 56);
    assert(!jbed_search_rom_method_by_pc(rt, image, sizeof(image), 0x3004));
    jbed_method_discard_ranges(rt);
    assert(jbed_method_pc_offset(rt, &method, 0x2000) == -1);
    assert(jbed_method_add_range(rt, 0x5000, 0x5001) == 5);
}

static void long_jump_labels(JbedRuntime *runtime)
{
    JbedThumbCoder thumb = {.runtime = runtime, .helpers = jbed_thumb_rom_helpers(0)};
    jbed_thumb_reset_long_jumps(&thumb);
    JbedThumbLongJump *first = jbed_thumb_add_long_jump(&thumb, NULL, 0x2001, JBED_JUMP_ABSOLUTE);
    for (unsigned i = 1; i < 16; ++i)
        jbed_thumb_add_long_jump(&thumb, NULL, 0x2000 + i * 4, JBED_JUMP_ABSOLUTE);
    first->label = 0x3000;
    assert(thumb.long_jump_capacity == 32);
    assert(jbed_thumb_add_long_jump(&thumb, NULL, 0x2000, JBED_JUMP_ABSOLUTE) == first);
    assert(thumb.long_jumps[2]->label == 0x3000);
    jbed_thumb_reset_long_jumps(&thumb);
    assert(thumb.long_jump_capacity == 16 && thumb.long_jump_count == 2);
    assert(jbed_thumb_add_long_jump(&thumb, NULL, 0x2001, JBED_JUMP_ABSOLUTE)->label == 0);
    assert(first->label == 0x3000);
}

int main(void)
{
    JbedRuntime runtime = {.allocate_zeroed = allocate, .raise_error = raise_error};
    split_method_ranges(&runtime);
    JbedOptList cache;
    jbed_optlist_init(&cache, &runtime, 2, 7);
    /* An element value is reusable after a store to a distinct constant index
     * on the same array. A store to that element invalidates the value, while
     * a cached element address remains valid. */
    jbed_optlist_add(&cache, 1, 3u << 16);
    cache.registers_enabled = true;
    jbed_optlist_set_register(&cache, 2, -1);
    jbed_optlist_set_register(&cache, 3, 12);
    assert(jbed_optlist_search(&cache, 1, 3u << 16));
    assert(cache.found_register == 2 && cache.found_address == (12u << 16) + 3);
    jbed_optlist_remove_array_write(&cache, 1, 4u << 16);
    assert(jbed_optlist_get_registers(&cache, false) == (1u << 2));
    jbed_optlist_remove_array_write(&cache, 1, 3u << 16);
    assert(!jbed_optlist_get_registers(&cache, false));
    assert(jbed_optlist_get_registers(&cache, true) == (1u << 3));
    jbed_optlist_add(&cache, 2, 5u << 16);
    jbed_optlist_remove(&cache, 0, 1, UINT32_MAX);
    assert(!jbed_optlist_search(&cache, 1, 3u << 16));
    jbed_optlist_add(&cache, 3, 6u << 16);
    assert(cache.used == 4 && cache.found_index == 0); /* Reuses removed pair. */
    jbed_optlist_set_register(&cache, 4, -1);
    jbed_optlist_remove_fields(&cache);
    assert(jbed_optlist_search(&cache, 3, 6u << 16));
    assert(cache.found_register == -1); /* Calls discard cached register values. */

    /* Pointer maps use 31-bit words: native local at offset112 maps to bit31,
     * a register local maps to bit1, and synchronization reserves bit0. */
    JbedMethod method = {.max_locals = 2, .flags = JBED_ACC_SYNCHRONIZED};
    uint8_t pointers[] = {1, 1};
    uint32_t words[4] = {0};
    JbedCoder coder = {
        .method = &method, .local_pointers = pointers, .map_words = words, .map_capacity = 4};
    JbedThumbCoder thumb = {.coder = &coder};
    thumb.local_locations[0] = -5;
    thumb.local_locations[1] = 112;
    coder.thumb = &thumb;
    jbed_coder_create_map(&coder, 0);
    assert(coder.map_word_count == 2 && words[0] == 3 && words[1] == 1);
    pointers[1] = 0;
    jbed_coder_create_map(&coder, 0);
    assert(coder.map_word_count == 0 && words[0] == 3);
    assert(jbed_coder_same_map(&coder, 0, 3));
    method.flags = 0;
    coder.return_type = JBED_TYPE_REFERENCE;
    jbed_coder_create_map(&coder, -2);
    assert(coder.map_word_count == 0 && words[0] == 2);
    jbed_coder_clear_last_map(&coder);
    assert(!jbed_coder_same_map(&coder, 0, 2));
    long_jump_labels(&runtime);
    for (size_t i = 0; i < allocated; ++i)
        free(allocations[i]);
    puts("Coder cache invalidation, pointer maps and long-jump labels passed");
    return 0;
}
