#!/usr/bin/env python3
"""Execute a static ARM32 Linux ELF in Unicorn (pip: unicorn pyelftools).

A deliberately small Linux syscall adapter, not an Android emulator. Unknown
syscalls fail the run instead of silently succeeding. No host files are exposed.
Threads and asynchronous signals are not implemented. Output reports syscall
coverage and the last translated blocks on a fault. Guest code is never mocked.
"""
import argparse
from collections import Counter, deque
import errno
import json
from pathlib import Path
import struct
import sys
import time

from elftools.elf.elffile import ELFFile
from unicorn import Uc, UcError, UC_ARCH_ARM, UC_MODE_ARM, UC_HOOK_INTR, UC_HOOK_BLOCK, UC_HOOK_MEM_INVALID
from unicorn.arm_const import *

PAGE = 4096
REGS = [UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3, UC_ARM_REG_R4, UC_ARM_REG_R5, UC_ARM_REG_R6]


def execute(path, arguments, seconds=120, instructions=100_000_000, trace_syscalls=False):
    uc = Uc(UC_ARCH_ARM, UC_MODE_ARM)
    uc.reg_write(UC_ARM_REG_C1_C0_2, 0xf00000)  # CP10/11: VFP
    uc.reg_write(UC_ARM_REG_FPEXC, 0x40000000)
    mapped = set()
    def map_memory(address, size):
        begin, end = address & -PAGE, (address + size + PAGE - 1) & -PAGE
        cursor = begin
        while cursor < end:
            if cursor in mapped:
                cursor += PAGE
                continue
            stop = cursor + PAGE
            while stop < end and stop not in mapped:
                stop += PAGE
            uc.mem_map(cursor, stop - cursor)
            mapped.update(range(cursor, stop, PAGE))
            cursor = stop
    symbols = []
    with path.open('rb') as handle:
        elf = ELFFile(handle)
        if elf['e_machine'] != 'EM_ARM' or elf.elfclass != 32 or elf['e_type'] != 'ET_EXEC':
            raise RuntimeError('Expected a static non-PIE ARM32 executable')
        entry = elf['e_entry']
        phdr, phnum, phentsize = 0, elf.num_segments(), elf['e_phentsize']
        highest = 0
        permissions = {}
        for segment in elf.iter_segments():
            if segment['p_type'] == 'PT_INTERP':
                raise RuntimeError('Dynamic ELF loading is not supported')
            if segment['p_type'] != 'PT_LOAD':
                continue
            address, size = segment['p_vaddr'], segment['p_memsz']
            map_memory(address, size)
            uc.mem_write(address, segment.data())
            flags = segment['p_flags']
            protection = (1 if flags & 4 else 0) | (2 if flags & 2 else 0) | (4 if flags & 1 else 0)
            for page in range(address & -PAGE, (address + size + PAGE - 1) & -PAGE, PAGE):
                permissions[page] = permissions.get(page, 0) | protection
            highest = max(highest, address + size)
            if segment['p_offset'] == 0:
                phdr = address + elf['e_phoff']
        table = elf.get_section_by_name('.symtab')
        if table:
            symbols = sorted((s['st_value'] & ~1, s.name, s['st_size']) for s in table.iter_symbols()
                             if s['st_info']['type'] == 'STT_FUNC' and s['st_value'])
    pages = sorted(permissions)
    index = 0
    while index < len(pages):
        begin = pages[index]
        protection = permissions[begin]
        stop = index + 1
        while stop < len(pages) and pages[stop] == pages[stop - 1] + PAGE and permissions[pages[stop]] == protection:
            stop += 1
        uc.mem_protect(begin, pages[stop - 1] + PAGE - begin, protection)
        index = stop
    symbol_starts = [address for address, name, size in symbols]
    def location(pc):
        import bisect
        index = bisect.bisect_right(symbol_starts, pc & ~1) - 1
        if index < 0:
            return hex(pc)
        start, name, size = symbols[index]
        if not size or (pc & ~1) >= start + size:
            return hex(pc)
        return f'{pc:#010x} {name}+{(pc & ~1) - start:#x}'
    stack_base, stack_size = 0x7e000000, 8 * 1024 * 1024
    map_memory(stack_base, stack_size)
    uc.mem_protect(stack_base, stack_size, 3)
    sp = stack_base + stack_size - PAGE
    pointers = []
    for text in reversed([str(path), *arguments]):
        data = text.encode() + b'\0'
        sp -= len(data)
        uc.mem_write(sp, data)
        pointers.insert(0, sp)
    sp -= 16
    random = sp
    uc.mem_write(sp, bytes(range(16)))
    aux = [3, phdr, 4, phentsize, 5, phnum, 6, PAGE, 9, entry,
           11, 1000, 12, 1000, 13, 1000, 14, 1000, 16, 0x1fb0d7, 17, 100,
           23, 0, 25, random, 0, 0]
    words = [len(pointers), *pointers, 0, 0, *aux]
    sp = (sp - 4 * len(words)) & -16
    uc.mem_write(sp, struct.pack('<' + 'I' * len(words), *words))
    uc.reg_write(UC_ARM_REG_SP, sp)
    brk = (highest + PAGE - 1) & -PAGE
    mmap_next = 0x20000000
    calls = Counter()
    blocks = deque(maxlen=32)
    output = []
    exit_status = None
    failure = None
    start = time.monotonic()
    def block(_uc, address, size, _data):
        blocks.append((address, size))
    def invalid(_uc, access, address, size, value, _data):
        nonlocal failure
        failure = f'Invalid memory access type={access} address={address:#x} size={size} value={value:#x}'
        return False
    def syscall(_uc, interrupt, _data):
        nonlocal brk, mmap_next, exit_status, failure
        n = uc.reg_read(UC_ARM_REG_R7)
        a = [uc.reg_read(r) for r in REGS]
        calls[str(n)] += 1
        if trace_syscalls:
            print(f'svc {n}: ' + ' '.join(hex(x) for x in a), file=sys.stderr)
        result = 0
        try:
            if interrupt != 2:
                raise RuntimeError(f'Unexpected CPU interrupt {interrupt}')
            if n in (1, 248):  # exit, exit_group
                exit_status = a[0] & 255
                uc.emu_stop()
            elif n in (4, 146):  # write, writev
                if a[0] not in (1, 2):
                    result = -errno.EBADF
                else:
                    vectors = [(a[1], a[2])] if n == 4 else [struct.unpack('<II', uc.mem_read(a[1] + 8*i, 8)) for i in range(a[2])]
                    data = b''.join(bytes(uc.mem_read(p, size)) for p, size in vectors)
                    text = data.decode(errors='replace')
                    output.append(text)
                    print(text, end='', flush=True)
                    result = len(data)
            elif n == 45:  # brk
                if a[0] > brk:
                    map_memory(brk, a[0] - brk)
                    brk = a[0]
                result = brk
            elif n == 192:  # mmap2, anonymous mappings only
                if not a[3] & 0x20:
                    raise RuntimeError('File-backed mmap is not supported')
                address = (a[0] if a[0] else mmap_next) & -PAGE
                size = (a[1] + PAGE - 1) & -PAGE
                if not size or size > 256 * 1024 * 1024:
                    raise RuntimeError(f'Invalid or excessive mmap size {size}')
                if a[3] & 0x10:  # MAP_FIXED replaces old mappings
                    for p in range(address, address + size, PAGE):
                        if p in mapped:
                            uc.mem_unmap(p, PAGE)
                            mapped.remove(p)
                elif any(p in mapped for p in range(address, address + size, PAGE)):
                    address = mmap_next
                    while any(p in mapped for p in range(address, address + size, PAGE)):
                        address += size + PAGE
                map_memory(address, size)
                uc.mem_protect(address, size, a[2])
                mmap_next = max(mmap_next, address + size + PAGE)
                result = address
            elif n == 91:  # munmap
                for p in range(a[0], (a[0]+a[1]+PAGE-1) & -PAGE, PAGE):
                    if p in mapped:
                        uc.mem_unmap(p, PAGE)
                        mapped.remove(p)
            elif n == 125:  # mprotect
                # Preserve guest permissions, including W^X transitions.
                uc.mem_protect(a[0], (a[1]+PAGE-1) & -PAGE, a[2])
            elif n == 219:  # madvise DONTNEED: clear existing pages
                if a[2] == 4:
                    uc.mem_write(a[0], bytes(a[1]))
                elif a[2] != 0:
                    raise RuntimeError(f'Unsupported madvise advice {a[2]}')
            elif n == 0xf0005:  # ARM set_tls
                uc.reg_write(UC_ARM_REG_C13_C0_3, a[0])
            elif n == 0xf0002:  # ARM cacheflush (Unicorn invalidates translated code on writes)
                pass
            elif n == 256:  # set_tid_address; single emulated thread
                result = 1000
            elif n in (20, 224):  # getpid, gettid
                result = 1000
            elif n in (199, 200, 201, 202):
                result = 1000
            elif n == 242:  # sched_getaffinity: one virtual CPU
                if a[1] < 4:
                    result = -errno.EINVAL
                else:
                    uc.mem_write(a[2], struct.pack('<I', 1) + bytes(a[1] - 4))
                    result = 4
            elif n == 191:  # ugetrlimit
                limits = (stack_size, stack_size) if a[0] == 3 else (0xffffffff, 0xffffffff)
                uc.mem_write(a[1], struct.pack('<II', *limits))
            elif n == 78:  # gettimeofday
                micros = int(time.time() * 1_000_000)
                if a[0]: uc.mem_write(a[0], struct.pack('<II', micros//1_000_000, micros%1_000_000))
                if a[1]: uc.mem_write(a[1], bytes(8))
            elif n in (263, 403):  # clock_gettime / time64
                now = time.time_ns() if a[0] == 0 else time.monotonic_ns()
                uc.mem_write(a[1], struct.pack('<qq' if n == 403 else '<II', now//1_000_000_000, now%1_000_000_000))
            elif n == 54:  # ioctl: output streams aren't terminals
                result = -errno.ENOTTY
            elif n in (175,):  # rt_sigprocmask: no asynchronous signal delivery
                if a[2]: uc.mem_write(a[2], bytes(a[3]))
            else:
                raise RuntimeError(f'Unsupported Linux ARM syscall {n}, args={[hex(x) for x in a]}')
            uc.reg_write(UC_ARM_REG_R0, result & 0xffffffff)
        except Exception as error:
            failure = str(error)
            uc.emu_stop()
    uc.hook_add(UC_HOOK_INTR, syscall)
    uc.hook_add(UC_HOOK_BLOCK, block)
    uc.hook_add(UC_HOOK_MEM_INVALID, invalid)
    try:
        uc.emu_start(entry, 0, timeout=int(seconds * 1_000_000), count=instructions)
    except UcError as error:
        failure = (failure + '; ' if failure else '') + str(error)
    if exit_status is None and failure is None:
        failure = 'Execution budget exhausted (no exit syscall)'
    report = {'elf': str(path), 'exit_status': exit_status, 'failure': failure,
              'seconds': round(time.monotonic()-start, 3), 'syscalls': dict(calls),
              'stdout': ''.join(output), 'pc': location(uc.reg_read(UC_ARM_REG_PC)),
              'registers': {f'r{i}': hex(uc.reg_read(r)) for i, r in enumerate(REGS + [UC_ARM_REG_R7, UC_ARM_REG_R8, UC_ARM_REG_R9, UC_ARM_REG_R10, UC_ARM_REG_R11, UC_ARM_REG_R12, UC_ARM_REG_SP, UC_ARM_REG_LR])},
              'last_blocks': [location(address) for address, size in blocks],
              'limitations': ['Linux syscall subset, not Android/Bionic/JNI', 'No threads or asynchronous signal delivery']}
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seconds', type=int, default=120)
    parser.add_argument('--instructions', type=int, default=100_000_000)
    parser.add_argument('--report', type=Path)
    parser.add_argument('--trace-syscalls', action='store_true')
    parser.add_argument('elf', type=Path)
    parser.add_argument('arguments', nargs='*')
    args = parser.parse_args()
    report = execute(args.elf, args.arguments, args.seconds, args.instructions, args.trace_syscalls)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'stdout'}, indent=2), file=sys.stderr)
    return 1 if report['failure'] else report['exit_status']


if __name__ == '__main__':
    sys.exit(main())
