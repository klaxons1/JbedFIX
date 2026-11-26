#!/usr/bin/env python3
"""Compare small reconstructed algorithms against original ARM instructions.

Requires Unicorn and a built jbedcompiler_oracle executable. Emulation stays
inside the named leaf routines; this does not start the VM or load Android.
"""

import argparse
import random
import struct
import subprocess
from pathlib import Path

from unicorn import Uc, UC_ARCH_ARM, UC_MODE_THUMB, UC_HOOK_CODE
from unicorn.arm_const import (
    UC_ARM_REG_LR, UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3,
    UC_ARM_REG_R9, UC_ARM_REG_R10, UC_ARM_REG_SP, UC_ARM_REG_PC,
)

CODE_BASE = 0xD0000000
CHAIN_OFFSETS = (0x100, 0x200, 0x2100, 0x2200, 0x4100, 0x4200, 0x6100, 0x6200)


def initial_chain(order):
    indices = [(order >> (i * 4)) & 7 for i in range(8)]
    words = {}
    for position, index in enumerate(indices):
        delta = (CHAIN_OFFSETS[indices[position + 1]] - CHAIN_OFFSETS[index]
                 if position < 7 else 0)
        words[CODE_BASE + CHAIN_OFFSETS[index]] = (
            ((index + 1) * 0x111) | ((index & 1) << 14) | (delta << 15)) & 0xFFFFFFFF
    return words


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("oracle", type=Path)
    parser.add_argument("--image", type=Path, default=Path(__file__).resolve().parents[3]
                        / "app/src/main/jniLibs/armeabi/libjbedvm.so")
    args = parser.parse_args()
    image = args.image.read_bytes()
    # This image's file offsets equal its VAs throughout the tested text spans.
    machine = Uc(UC_ARCH_ARM, UC_MODE_THUMB)
    machine.mem_map(0, (len(image) + 4095) & ~4095)
    machine.mem_write(0, image)
    state, stop = 0x700000, 0x710000
    machine.mem_map(state, 0x11000)
    addresses = (0x13EDD4, 0x1839C8, 0x1764B0, 0x1764B8,
                 0x12C7BE, 0x12E014, 0x145A32, 0x1839E4,
                 0x183A96, 0x183B94, 0x178758, 0x178572, 0x183D14)
    edges = (0, 1, 2, 15, 16, 31, 0x7FF, 0x800, 0x1FFF, 0x2000,
             0x1FFFFF, 0x200000, 0x7FFFFFFF, 0x80000000, 0xD0000000, 0xFFFFFFFF)
    randomizer = random.Random(0x20110126)
    cases = [(op, a, b) for op in range(7)
             for a, b in list(zip(edges, reversed(edges))) +
             [(randomizer.getrandbits(32), randomizer.getrandbits(32)) for _ in range(32)]]
    for displacement in [-0x400000, -0x3FFFFE, -2, 0, 2, 0x3FFFFC, 0x3FFFFE] + [
            randomizer.randrange(-0x200000, 0x200000) * 2 for _ in range(96)]:
        site = randomizer.getrandbits(32) & ~1
        cases.append((7, site, (site + 4 + displacement) & 0xFFFFFFFF))
    for _ in range(12):
        permutation = list(range(8))
        randomizer.shuffle(permutation)
        order = sum(index << (position * 4) for position, index in enumerate(permutation))
        cases.extend((8, order, (slot << 8) | output) for slot in range(4) for output in range(9))
        cases.extend((9, order, (slots << 8) | output) for slots in range(1, 5) for output in range(10))
    for seed in [0, 0x01010101, 0x01020102, 0xFFFFFFFF] + [randomizer.getrandbits(32) for _ in range(12)]:
        cases.extend((10, seed, output) for output in range(9))
        cases.extend((11, seed, output) for output in range(15))
    cases.extend((12, previous, site) for previous in range(9) for site in range(8))
    payload = b"".join(struct.pack("<III", *case) for case in cases)
    output = subprocess.run([str(args.oracle.resolve())], input=payload,
                            stdout=subprocess.PIPE, check=True).stdout
    if len(output) != len(cases) * 4:
        raise AssertionError("reconstruction oracle returned a partial response")
    actual = struct.unpack("<" + "I" * len(cases), output)
    read_stub, write_stub = stop + 0x100, stop + 0x104
    machine.mem_write(read_stub, b"\x70\x47")  # bx lr
    machine.mem_write(write_stub, b"\x70\x47")
    chain_words = {}

    def memory_callback(emulator, address, _size, _data):
        target = emulator.reg_read(UC_ARM_REG_R1)
        if address == read_stub:
            emulator.reg_write(UC_ARM_REG_R0, chain_words[target])
        elif address == write_stub:
            chain_words[target] = emulator.reg_read(UC_ARM_REG_R2)

    machine.hook_add(UC_HOOK_CODE, memory_callback, begin=read_stub, end=write_stub)
    for (op, a, b), result in zip(cases, actual):
        machine.reg_write(UC_ARM_REG_SP, state + 0xF000)
        machine.reg_write(UC_ARM_REG_LR, stop | 1)
        machine.reg_write(UC_ARM_REG_R9, state)
        machine.reg_write(UC_ARM_REG_R10, 0)
        machine.reg_write(UC_ARM_REG_R0, a)
        machine.reg_write(UC_ARM_REG_R1, b)
        if op in (2, 3):
            machine.mem_write(state + 48, struct.pack("<I", a))
            machine.reg_write(UC_ARM_REG_R0, state)
        elif op == 5:
            machine.reg_write(UC_ARM_REG_R0, 0)  # unused Pool receiver
            machine.reg_write(UC_ARM_REG_R1, a)
        elif op == 6:
            machine.reg_write(UC_ARM_REG_R0, 0)  # progress listener
            machine.reg_write(UC_ARM_REG_R1, a)
            machine.reg_write(UC_ARM_REG_R2, b)
        elif op in (8, 9, 12):
            machine.mem_write(state, bytes(256))
            vtable, heads, tails = state + 0x400, state + 0x1000, state + 0x1100
            machine.mem_write(state, struct.pack("<I", vtable))
            machine.mem_write(state + 48, struct.pack("<I", CODE_BASE))
            machine.mem_write(state + 140, struct.pack("<II", heads, tails))
            for array in (heads, tails):
                machine.mem_write(array, bytes(48))
                machine.mem_write(array + 12, struct.pack("<I", 8))
            machine.mem_write(vtable + 84, struct.pack("<I", write_stub | 1))
            machine.mem_write(vtable + 144, struct.pack("<I", read_stub | 1))
            machine.reg_write(UC_ARM_REG_R0, state)
            if op == 12:
                chain_words = {}
                machine.reg_write(UC_ARM_REG_R1, 0 if a == 8 else CODE_BASE + CHAIN_OFFSETS[a])
                machine.reg_write(UC_ARM_REG_R2, CODE_BASE + CHAIN_OFFSETS[b])
                machine.reg_write(UC_ARM_REG_R3, 0x4321)
            else:
                chain_words = initial_chain(a)
                machine.reg_write(UC_ARM_REG_R1, CODE_BASE + CHAIN_OFFSETS[a & 7])
                if op == 8:
                    start = CODE_BASE + ((b >> 8) & 3) * 8192
                    machine.reg_write(UC_ARM_REG_R2, start)
                    machine.reg_write(UC_ARM_REG_R3, start + 8192)
                else:
                    machine.reg_write(UC_ARM_REG_R2, (b >> 8) & 7)
        elif op in (10, 11):
            entries, longs, words = state + 0x2000, state + 0x3000, state + 0x4000
            machine.mem_write(state, bytes(256))
            machine.mem_write(state + 12, struct.pack("<II", entries, longs))
            machine.mem_write(state + 40, struct.pack("<I", 1))
            machine.mem_write(state + 48, struct.pack("<I", 8192))
            for array in (entries, longs):
                machine.mem_write(array, bytes(1040))
                machine.mem_write(array + 12, struct.pack("<I", 256))
            machine.mem_write(words + 12, struct.pack("<I", 2))
            for index in range(4):
                machine.reg_write(UC_ARM_REG_SP, state + 0xF000)
                machine.reg_write(UC_ARM_REG_LR, stop | 1)
                machine.reg_write(UC_ARM_REG_R0, state)
                machine.reg_write(UC_ARM_REG_R1, CODE_BASE + 0x100 + index * 4)
                if op == 10:
                    machine.reg_write(UC_ARM_REG_R2, ((a >> (index * 8)) & 255) * 4)
                else:
                    variation = 0 if index == 2 else index
                    machine.mem_write(words + 16, struct.pack("<II", (a ^ variation) & 0x7FFFFFFF,
                                                             ((a >> 7) ^ (variation << 8)) & 0x7FFFFFFF))
                    machine.reg_write(UC_ARM_REG_R2, words)
                    machine.reg_write(UC_ARM_REG_R3, 2)
                machine.emu_start(addresses[op] | 1, stop, count=10000)
                if machine.reg_read(UC_ARM_REG_PC) != stop:
                    raise AssertionError(f"original 0x{addresses[op]:x} did not return")
            location = (state + (20, 24, 28, 32, 40)[b] if b < 5 else
                        entries + 16 + (b - 5) * 4 if b < 9 else longs + 16 + (b - 9) * 4)
            expected = struct.unpack("<I", machine.mem_read(location, 4))[0]
        if op not in (10, 11):
            machine.emu_start(addresses[op] | 1, stop, count=10000)
            if machine.reg_read(UC_ARM_REG_PC) != stop:
                raise AssertionError(f"original 0x{addresses[op]:x} did not return")
            expected = (struct.unpack("<I", machine.mem_read(state + 2064, 4))[0]
                        if op == 6 else machine.reg_read(UC_ARM_REG_R0))
            if op in (8, 9):
                index = b & 15
                if index < 8:
                    expected = chain_words[CODE_BASE + CHAIN_OFFSETS[index]]
                elif index == 9:
                    expected = struct.unpack("<I", machine.mem_read(state + 128, 4))[0]
            elif op == 12:
                expected = chain_words[CODE_BASE + CHAIN_OFFSETS[b]]
        if result != expected:
            raise AssertionError(f"0x{addresses[op]:x}({a:#x}, {b:#x}): "
                                 f"C={result:#x}, ARM={expected:#x}")
    print(f"{len(cases)} comparisons passed across {len(addresses)} original ARM routines")


if __name__ == "__main__":
    main()
