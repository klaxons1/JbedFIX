#include "compiler.h"
#include "pool.h"
#include "thumb.h"
#include "writer.h"

#include <stdio.h>
#include <stdlib.h>

static const uint32_t chain_offsets[8] = {0x100,  0x200,  0x2100, 0x2200,
                                          0x4100, 0x4200, 0x6100, 0x6200};
static uint32_t chain_words[8];

static unsigned chain_index(uint32_t address)
{
    for (unsigned i = 0; i < 8; ++i)
        if (address == JBED_CODE_BASE + chain_offsets[i])
            return i;
    abort();
}

static void capture_word(JbedWriter *writer, JbedAddress address, uint32_t value)
{
    (void)writer;
    chain_words[chain_index(address)] = value;
}

static uint32_t captured_word(JbedWriter *writer, JbedAddress address)
{
    (void)writer;
    return chain_words[chain_index(address)];
}

static const JbedWriterOps chain_ops = {.put_word = capture_word, .get_word = captured_word};

static uint32_t chain_case(uint32_t op, uint32_t order, uint32_t query)
{
    JbedCodeBlockWriter writer = {.writer = {.ops = &chain_ops}, .buffer_base = JBED_CODE_BASE};
    for (unsigned i = 0; i < 8; ++i) {
        unsigned index = (order >> (i * 4)) & 7;
        uint32_t metadata = (index + 1) * 0x111u | ((index & 1) << 14);
        uint32_t delta = 0;
        if (i != 7)
            delta = chain_offsets[(order >> ((i + 1) * 4)) & 7] - chain_offsets[index];
        chain_words[index] = metadata | (delta << 15);
    }
    uint32_t head = JBED_CODE_BASE + chain_offsets[order & 7];
    uint32_t result;
    if (op == 8) {
        uint32_t slot = (query >> 8) & 3;
        result = jbed_code_truncate_chain(&writer, head, JBED_CODE_BASE + slot * 8192,
                                          JBED_CODE_BASE + (slot + 1) * 8192);
    } else {
        result = jbed_code_split_chain(&writer, head, (query >> 8) & 7);
    }
    unsigned output = query & 15;
    if (output < 8)
        return chain_words[output];
    return output == 8 ? result : writer.split_chain_head;
}

static uint32_t stack_map_case(uint32_t op, uint32_t seed, uint32_t output)
{
    JbedStackMapArray map;
    JbedWriter writer = {0};
    jbed_stack_map_init(&map, 8192);
    for (unsigned i = 0; i < 4; ++i) {
        if (op == 10) {
            jbed_stack_map_add_short(&map, &writer, JBED_CODE_BASE + 0x100 + i * 4,
                                     ((seed >> (i * 8)) & 255u) * 4);
        } else {
            uint32_t variation = i == 2 ? 0 : i;
            uint32_t words[2] = {(seed ^ variation) & 0x7fffffffu,
                                 ((seed >> 7) ^ (variation << 8)) & 0x7fffffffu};
            jbed_stack_map_add_long(&map, &writer, JBED_CODE_BASE + 0x100 + i * 4, words, 2);
        }
    }
    uint32_t result;
    switch (output) {
    case 0:
        result = map.count;
        break;
    case 1:
        result = map.long_count;
        break;
    case 2:
        result = map.start;
        break;
    case 3:
        result = map.end;
        break;
    case 4:
        result = map.max_long_words;
        break;
    default:
        result = output < 9 ? map.entries[output - 5] : map.long_words[output - 9];
        break;
    }
    jbed_stack_map_dispose(&map);
    return result;
}

static uint32_t word(const unsigned char *p)
{
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

int main(void)
{
    unsigned char input[12];
    while (fread(input, 1, sizeof input, stdin) == sizeof input) {
        uint32_t op = word(input), a = word(input + 4), b = word(input + 8), result;
        JbedCodeBlockWriter blocks = {.buffer_base = a};
        JbedCompiler compiler = {0};
        switch (op) {
        case 0:
            result = jbed_thumb_call_instr((int32_t)a);
            break;
        case 1:
            result = jbed_thumb_call_destination(a, b);
            break;
        case 2:
            result = jbed_code_block_index(&blocks, b);
            break;
        case 3:
            result = jbed_code_block_base(&blocks, b);
            break;
        case 4:
            result = jbed_pool_primitive_type(a);
            break;
        case 5:
            result = jbed_pool_bad_visibility(a);
            break;
        case 6:
            jbed_compiler_set_progress(&compiler, NULL, NULL, (int32_t)a, (int32_t)b);
            result = (uint32_t)compiler.total;
            break;
        case 7:
            if (!jbed_thumb_call_encode(a, b, &result))
                return 4;
            break;
        case 8:
        case 9:
            result = chain_case(op, a, b);
            break;
        case 10:
        case 11:
            result = stack_map_case(op, a, b);
            break;
        case 12:
            blocks.writer.ops = &chain_ops;
            jbed_code_add_fixup(&blocks, a == 8 ? 0 : JBED_CODE_BASE + chain_offsets[a],
                                JBED_CODE_BASE + chain_offsets[b], 0x4321);
            result = chain_words[b];
            break;
        default:
            return 2;
        }
        unsigned char output[4] = {(unsigned char)result, (unsigned char)(result >> 8),
                                   (unsigned char)(result >> 16), (unsigned char)(result >> 24)};
        if (fwrite(output, 1, sizeof output, stdout) != sizeof output)
            return 3;
    }
    return ferror(stdin) ? 4 : 0;
}
