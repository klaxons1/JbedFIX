#include "writer.h"

/* ArchCodeBlockWriter 0x1839c8/0x1839e4. This is the Thumb-1 two-halfword BL
 * encoding, with a signed 22-bit halfword displacement from PC+4. */
bool jbed_thumb_call_encode(JbedAddress site, JbedAddress destination, uint32_t *instruction)
{
    uint32_t displacement = destination - site - 4u;
    int32_t distance = (int32_t)(displacement + 1u);
    int32_t absolute = distance < 0 ? (int32_t)(0u - (uint32_t)distance) : distance;
    if (absolute >= INT32_C(0x400000) || ((site | destination) & 1u))
        return false;
    *instruction = (((displacement >> 1) & UINT32_C(0x7ff)) | UINT32_C(0xf800)) << 16;
    *instruction |= ((displacement >> 12) & UINT32_C(0x7ff)) | UINT32_C(0xf000);
    return true;
}
JbedAddress jbed_thumb_call_destination(JbedAddress site, uint32_t instruction)
{
    uint32_t bits =
        ((instruction & UINT32_C(0x7ff)) << 11) | ((instruction >> 16) & UINT32_C(0x7ff));
    int32_t displacement = (int32_t)bits;
    if (bits & UINT32_C(0x200000))
        displacement -= INT32_C(0x400000);
    return site + (uint32_t)(displacement * 2) + 4u;
}
void jbed_thumb_call_write(JbedWriter *w, JbedAddress site, JbedAddress destination,
                           uint8_t *buffer, uint32_t offset)
{
    uint32_t instruction;
    int32_t distance = (int32_t)(destination - site - 3u);
    int32_t absolute = distance < 0 ? (int32_t)(0u - (uint32_t)distance) : distance;
    /* The original range error precedes its alignment halt, including when both
     * conditions fail. Keep that observable exception ordering. */
    if (absolute >= INT32_C(0x400000))
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "Thumb call destination");
    if ((site | destination) & 1u)
        jbed_writer_fault(w, JBED_WRITER_HALT, "unaligned Thumb call");
    (void)jbed_thumb_call_encode(site, destination, &instruction);
    buffer[offset] = (uint8_t)instruction;
    buffer[offset + 1] = (uint8_t)(instruction >> 8);
    buffer[offset + 2] = (uint8_t)(instruction >> 16);
    buffer[offset + 3] = (uint8_t)(instruction >> 24);
}

/* In-memory relocation chains reserve low 15 bits for the page offset and BL
 * flag, and store a signed byte delta in the upper 17 bits. The serialized file
 * reader later sees positive deltas after splitCodeChain orders block groups.
 */
static int32_t chain_delta(uint32_t word)
{
    uint32_t bits = word >> JBED_FIXUP_DELTA_SHIFT;
    return (int32_t)bits - ((bits & JBED_FIXUP_DELTA_SIGN) ? JBED_FIXUP_DELTA_RANGE : 0);
}
static uint32_t chain_word(uint32_t metadata, JbedAddress site, JbedAddress next)
{
    return (metadata & JBED_FIXUP_METADATA_MASK) | ((next - site) << JBED_FIXUP_DELTA_SHIFT);
}
static bool in_range(JbedAddress address, JbedAddress start, JbedAddress end)
{
    return (int32_t)address >= (int32_t)start && (int32_t)address < (int32_t)end;
}

/* 0x183d14. Returns the new head, whether or not there was a previous link. */
JbedAddress jbed_code_add_fixup(JbedCodeBlockWriter *b, JbedAddress previous, JbedAddress site,
                                uint32_t metadata)
{
    if (metadata & ~JBED_FIXUP_METADATA_MASK)
        jbed_writer_fault(&b->writer, JBED_WRITER_HALT, "fixup metadata exceeds 15 bits");
    uint32_t word = previous ? chain_word(metadata, site, previous) : metadata;
    jbed_writer_put_word(&b->writer, site, word);
    return site;
}

/* truncateCodeChain 0x183a96; truncateStaticChain 0x183b70 delegates here. */
JbedAddress jbed_code_truncate_chain(JbedCodeBlockWriter *b, JbedAddress head, JbedAddress start,
                                     JbedAddress end)
{
    JbedWriter *w = &b->writer;
    while (in_range(head, start, end)) {
        int32_t delta = chain_delta(jbed_writer_get_word(w, head));
        if (!delta)
            return 0;
        head += (uint32_t)delta;
    }
    JbedAddress kept = head;
    for (;;) {
        uint32_t kept_word = jbed_writer_get_word(w, kept);
        int32_t delta = chain_delta(kept_word);
        if (!delta)
            return head;
        JbedAddress next = kept + (uint32_t)delta;
        if (in_range(next, start, end)) {
            do {
                delta = chain_delta(jbed_writer_get_word(w, next));
                if (!delta) {
                    jbed_writer_put_word(w, kept, kept_word & JBED_FIXUP_METADATA_MASK);
                    return head;
                }
                next += (uint32_t)delta;
            } while (in_range(next, start, end));
            jbed_writer_put_word(w, kept, chain_word(kept_word, kept, next));
        }
        kept = next;
    }
}

/* splitCodeChain 0x183b94; splitStaticChain 0x183d58 delegates here. Reverse
 * each per-slot list, concatenate the flushed slots in increasing order, and
 * return the reversed list still belonging to the live writer window. */
JbedAddress jbed_code_split_chain(JbedCodeBlockWriter *b, JbedAddress head, uint32_t slots)
{
    if (slots > JBED_BUFFER_BLOCKS)
        jbed_writer_fault(&b->writer, JBED_WRITER_ASSERTION, "split slots exceeds writer window");
    b->split_chain_head = 0;
    for (uint32_t i = 0; i < slots; i++)
        b->chain_heads[i] = 0;
    JbedAddress remaining = 0;
    for (;;) {
        uint32_t word = jbed_writer_get_word(&b->writer, head);
        int32_t delta = chain_delta(word);
        uint32_t slot = jbed_code_block_index(b, head), rewritten = word & JBED_FIXUP_METADATA_MASK;
        if (slot >= slots) {
            if (remaining)
                rewritten = chain_word(rewritten, head, remaining);
            remaining = head;
        } else {
            if (b->chain_heads[slot])
                rewritten = chain_word(rewritten, head, b->chain_heads[slot]);
            else
                b->chain_tails[slot] = head;
            b->chain_heads[slot] = head;
        }
        jbed_writer_put_word(&b->writer, head, rewritten);
        if (!delta)
            break;
        head += (uint32_t)delta;
    }
    JbedAddress tail = 0;
    for (uint32_t i = 0; i < slots; i++)
        if (b->chain_heads[i]) {
            if (tail)
                jbed_writer_put_word(
                    &b->writer, tail,
                    chain_word(jbed_writer_get_word(&b->writer, tail), tail, b->chain_heads[i]));
            else
                b->split_chain_head = b->chain_heads[i];
            tail = b->chain_tails[i];
        }
    return remaining;
}
