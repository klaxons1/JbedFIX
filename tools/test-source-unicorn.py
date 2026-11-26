#!/usr/bin/env python3
"""Cross-build recovered sources and execute ARM32 tests + real ROM in Unicorn.

Install tools/requirements-unicorn.txt first. Supply unpacked zlib/libpng source
and the boot C emitted by jbedrom (the same input used for the Android APK).
Separate builds are intentional: layout fixtures use synthetic guest addresses,
whereas the full runtime dereferences real ARM32 pointers.
"""
import argparse
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TESTS = ['verifier', 'reader_pool', 'block_stream', 'coder', 'rom_format',
         'vm_exception', 'vm_memory', 'vm_mark', 'vm_compactor', 'vm_monitor']
TARGETS = ['jbed_guest_layout_test', 'jbed_drm_compat_test', 'jbed_png_compat_test',
           *['jbedcompiler_' + name + '_test' for name in TESTS]]


def command(words, log):
    with log.open('w') as out:
        result = subprocess.run([str(x) for x in words], cwd=ROOT, stdout=out, stderr=subprocess.STDOUT)
    if result.returncode:
        raise RuntimeError(f'{words[0]} failed ({result.returncode}); see {log}\n' + log.read_text(errors='replace')[-6000:])


def prepare(args):
    output = args.output
    cmake = shutil.which('cmake') or str(Path(sys.executable).parent / 'cmake')
    for mode, compiler in [('cc', 'cc'), ('cxx', 'c++')]:
        wrapper = output / mode
        # Zig's target triple controls instruction mode; -mthumb alone is not
        # sufficient in all Zig versions. Match the Android runtime's Thumb ABI.
        wrapper.write_text('#!/bin/sh\ntarget=arm-linux-musleabi\n'
            'for arg do [ "$arg" != -mthumb ] || target=thumb-linux-musleabi; done\n'
            f'exec {shlex.quote(sys.executable)} -m ziglang {compiler} '
            '-target "$target" -mcpu=cortex_a9 -mfloat-abi=softfp -static "$@"\n')
        wrapper.chmod(0o755)
    toolchain = output / 'toolchain.cmake'
    toolchain.write_text(f'''set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7)
set(CMAKE_C_COMPILER "{output / 'cc'}")
set(CMAKE_CXX_COMPILER "{output / 'cxx'}")
set(CMAKE_ASM_COMPILER "{output / 'cc'}")
set(CMAKE_C_FLAGS_INIT "-ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_INIT "-ffunction-sections -fdata-sections")
''')
    common = [f'-DCMAKE_TOOLCHAIN_FILE={toolchain}', '-DCMAKE_BUILD_TYPE=Release']
    command([cmake, '-S', args.zlib_source, '-B', output / 'zlib', *common,
             f'-DCMAKE_INSTALL_PREFIX={output / "deps"}', '-DZLIB_BUILD_EXAMPLES=OFF'], output / 'zlib-config.log')
    command([cmake, '--build', output / 'zlib', '--target', 'install', '-j', args.jobs], output / 'zlib-build.log')
    config = [*common, f'-DCMAKE_PREFIX_PATH={output / "deps"}',
              f'-DZLIB_LIBRARY_RELEASE={output / "deps/lib/libz.a"}',
              f'-DZLIB_LIBRARY_DEBUG={output / "deps/lib/libz.a"}',
              '-DJBED_FETCH_LIBPNG=ON', f'-DFETCHCONTENT_SOURCE_DIR_JBED_LIBPNG={args.png_source}']
    command([cmake, '-S', ROOT / 'native', '-B', output / 'test-native', *config,
             '-DJBED_BUILD_HOST_TESTS=ON', '-DJBED_BUILD_ARM32_LINUX_TESTS=OFF'], output / 'test-configure.log')
    command([cmake, '--build', output / 'test-native', '-j', args.jobs, '--target', *TARGETS], output / 'test-build.log')
    command([cmake, '-S', ROOT / 'native', '-B', output / 'native', *config,
             '-DJBED_BUILD_HOST_TESTS=OFF', '-DJBED_BUILD_ARM32_LINUX_TESTS=ON',
             f'-DJBED_BOOT_IMAGE={args.rom}'], output / 'rom-configure.log')
    command([cmake, '--build', output / 'native', '-j', args.jobs, '--target', 'jbed_arm32_rom_smoke'], output / 'rom-build.log')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'build/unicorn')
    parser.add_argument('--rom', type=Path)
    parser.add_argument('--zlib-source', type=Path)
    parser.add_argument('--png-source', type=Path)
    parser.add_argument('--skip-build', action='store_true')
    parser.add_argument('--main', action='store_true', help='Also attempt isolate startup; unsupported OS syscalls FAIL, never skip')
    parser.add_argument('--jobs', default='4')
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    if not args.skip_build:
        for name in ('rom', 'zlib_source', 'png_source'):
            value = getattr(args, name)
            if value is None or not value.exists():
                parser.error(f'--{name.replace("_", "-")} must exist unless --skip-build is used')
            setattr(args, name, value.resolve())
        prepare(args)
    reports = args.output / 'reports'
    reports.mkdir(exist_ok=True)
    runs = []
    for target in TARGETS:
        directory = args.output / 'test-native'
        if target.startswith('jbedcompiler_'): directory /= 'compiler'
        runs.append((target, directory / target, []))
    runs.append(('rom-direct', args.output / 'native/jbed_arm32_rom_smoke', []))
    if args.main:
        runs.append(('rom-main', args.output / 'native/jbed_arm32_rom_smoke', ['main']))
    summary = {'main_requested': args.main, 'results': []}
    for name, elf, arguments in runs:
        with (reports / (name + '.log')).open('w') as log:
            result = subprocess.run([sys.executable, str(ROOT / 'tools/run-arm-unicorn.py'),
                '--report', str(reports / (name + '.json')), str(elf), *arguments],
                stdout=log, stderr=subprocess.STDOUT, cwd=ROOT)
        summary['results'].append({'name': name, 'passed': result.returncode == 0, 'returncode': result.returncode})
        print(f'{name}: {"PASS" if result.returncode == 0 else "FAIL"}', flush=True)
    (reports / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    if not args.main:
        print('main / isolate scheduling NOT tested; use --main to attempt it. See each JSON report for OS adapter limitations.')
    return 0 if all(r['passed'] for r in summary['results']) else 1


if __name__ == '__main__':
    sys.exit(main())
