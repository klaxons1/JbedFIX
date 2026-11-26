#ifndef JBED_VM_WORDS_H
#define JBED_VM_WORDS_H

#include "writer.h"

#include <assert.h>

static inline uint8_t *jbed_vm_span(JbedBuffer map, JbedAddress addr, uint32_t bytes)
{
    (void)bytes;
#if defined(JBED_NATIVE_ADDRESS_SPACE)
    (void)map;
    return (uint8_t *)(uintptr_t)addr;
#else
    assert(addr >= map.address && addr - map.address <= map.size &&
           bytes <= map.size - (addr - map.address));
    return map.data + (addr - map.address);
#endif
}

static inline uint8_t *jbed_vm_at(JbedBuffer map, JbedAddress addr)
{
    return jbed_vm_span(map, addr, 1);
}

static inline uint16_t jbed_vm_half(JbedBuffer map, JbedAddress addr)
{
    const uint8_t *p = jbed_vm_span(map, addr, 2);
    return (uint16_t)(p[0] | (uint16_t)p[1] << 8);
}

static inline uint32_t jbed_vm_word(JbedBuffer map, JbedAddress addr)
{
    const uint8_t *p = jbed_vm_span(map, addr, 4);
    return p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

static inline void jbed_vm_put_word(JbedBuffer map, JbedAddress addr, uint32_t value)
{
    uint8_t *p = jbed_vm_span(map, addr, 4);
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
    p[2] = (uint8_t)(value >> 16);
    p[3] = (uint8_t)(value >> 24);
}

#endif
