#!/usr/bin/env python3
"""Reconstruct JVM class files from Jbed's precompiled ARM/Thumb ROM."""

from __future__ import annotations

import argparse
from collections import Counter
from concurrent.futures import ProcessPoolExecutor, as_completed
import multiprocessing
import os
from fnmatch import fnmatchcase
from pathlib import Path
import re
import sys
import time
import zipfile

from jbed_java.model import RomImage, UnsupportedJava


_ROM = _LIFTER = None


def _init_worker(path, image=None):
    from jbed_java.thumb import ThumbLifter
    global _ROM, _LIFTER
    _ROM = image if image is not None else RomImage(path)
    _LIFTER = ThumbLifter(_ROM.data, _ROM.methods_by_address, _ROM.fields,
                          helpers=_ROM.helpers, superclasses=_ROM.superclasses, rom=_ROM)


def _recover_class(name, methods, remap, unavailable, runtime_layout=False):
    from jbed_java.classfile import LiftedBody, emit_classfile, is_bootstrap_bitcast
    klass = _ROM.by_name[name]
    _LIFTER.pointer_slots = _ROM.pointer_slots if runtime_layout else frozenset()
    bodies, failures, field_errors = {}, {}, {}
    for method in methods:
        if method.is_native or method.is_abstract or is_bootstrap_bitcast(_ROM, method, remap):
            continue
        result = _LIFTER.lift(method, structure=False)
        if result.failure or result.cfg is None:
            failures[method] = result.failure or "no recovered control-flow graph"
        else:
            bodies[method] = LiftedBody(result.cfg, result.exception_regions,
                                         result.handler_locals or {})
    backend_errors = {}
    try:
        data = emit_classfile(_ROM, klass, bodies, methods=methods, remap=remap,
                              unavailable="omit" if unavailable == "error" else unavailable, errors=backend_errors,
                              field_errors=field_errors, runtime_layout=runtime_layout)
    except UnsupportedJava as error:
        failures.update((method, str(error)) for method in bodies)
        return name, None, (), failures, field_errors, str(error)
    failures.update(backend_errors)
    recovered = tuple(method for method in bodies if method not in backend_errors)
    return name, data, recovered, failures, field_errors, None


def _recover_classes(selected, image, path, remap, unavailable, jobs, runtime_layout=False):
    if jobs == 1:
        _init_worker(path, image)
        for klass, methods in selected:
            yield _recover_class(klass.name, methods, remap, unavailable, runtime_layout)
    else:
        # Each worker retains its ROM indexes and disassembler between classes.
        with ProcessPoolExecutor(jobs, mp_context=multiprocessing.get_context("spawn"),
                                 initializer=_init_worker, initargs=(path,)) as pool:
            pending = [pool.submit(_recover_class, klass.name, methods, remap, unavailable, runtime_layout)
                       for klass, methods in selected]
            for future in as_completed(pending):
                yield future.result()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("image", type=Path, nargs="?", default=Path(__file__).resolve().parents[1]
                        / "app/src/main/jniLibs/armeabi/libjbedvm.so")
    parser.add_argument("--output", "-o", type=Path, help="destination JAR, or class directory with --directory")
    parser.add_argument("--directory", action="store_true", help="write individual .class files")
    parser.add_argument("--class", dest="classes", action="append", default=[], metavar="NAME",
                        help="original class name or glob; defaults to every ROM class")
    parser.add_argument("--method", action="append", default=[], metavar="NAME[(ARGS)RESULT]",
                        help="select method names or exact JVM signatures; repeatable")
    parser.add_argument("--scan", action="store_true", help="measure bytecode recovery without writing files")
    parser.add_argument("--failures", action="store_true", help="print each method still requiring recovery")
    parser.add_argument("--unrecovered", choices=("native", "omit", "error"), default="native",
                        help="mark missing bodies native, omit them, or fail without writing output")
    parser.add_argument("--runtime-layout", action="store_true",
                        help="preserve ARM32 class/field layouts for the source ROM builder")
    parser.add_argument("--remap", action="append", default=[], metavar="OLD=NEW",
                        help="rename a class or package prefix in emitted descriptors")
    parser.add_argument("--jobs", "-j", type=int, default=min(4, os.cpu_count() or 1),
                        help="parallel class workers (default: up to 4; 1 for serial recovery)")
    args = parser.parse_args(argv)
    if args.jobs < 1:
        parser.error("--jobs must be positive")
    if not args.scan and args.output is None:
        parser.error("choose --output or --scan")
    if args.scan and args.output:
        parser.error("--scan does not write files")

    from jbed_java.classfile import _binary_name, is_bootstrap_bitcast

    try:
        started = time.perf_counter()
        remap = {}
        for item in args.remap:
            old, separator, new = item.partition("=")
            if not separator or not old or not new or old.endswith("/") != new.endswith("/"):
                raise ValueError("--remap requires OLD=NEW names, or two package prefixes ending in '/'")
            remap[old] = new
        rom = RomImage(args.image)
        patterns = [pattern.replace(".", "/") for pattern in args.classes]
        classes = sorted((c for c in rom.by_name.values() if not c.name.startswith("<") and
                          (not patterns or any(fnmatchcase(c.name, p) for p in patterns))),
                         key=lambda c: c.name)
        for pattern in patterns:
            if not any(fnmatchcase(c.name, pattern) for c in classes):
                raise ValueError(f"no class matches {pattern!r}")
        selected = [(c, tuple(m for m in c.methods if not args.method or
                    any(s in (m.name, m.name + (m.descriptor or "")) for s in args.method)))
                    for c in classes]
        for selector in args.method:
            if not any(selector in (m.name, m.name + (m.descriptor or ""))
                       for _, methods in selected for m in methods):
                raise ValueError(f"no method matches {selector!r}")
        selected = [(klass, methods) for klass, methods in selected if methods or not args.method]
        output, failures, field_failures, class_failures = {}, {}, {}, {}
        recovered = []
        declarations = sum(m.is_native or m.is_abstract for _, methods in selected for m in methods)
        bridges = [m for _, methods in selected for m in methods if m.is_kni_bridge]
        native_bitcasts = sum(is_bootstrap_bitcast(rom, m, remap) for _, methods in selected
                              for m in methods if not m.is_native and not m.is_abstract)
        total = sum(len(methods) for _, methods in selected) - declarations - native_bitcasts
        last_progress = started
        jobs = min(args.jobs, len(selected))
        results = _recover_classes(selected, rom, args.image, remap, args.unrecovered, jobs,
                                   args.runtime_layout)
        for class_index, (name, data, bodies, errors, fields, error) in enumerate(results, 1):
            failures.update(errors)
            field_failures.update(fields)
            recovered.extend(bodies)
            if error:
                class_failures[name] = error
            else:
                filename = _binary_name(name, remap) + ".class"
                if filename in output:
                    raise ValueError(f"class mappings collide at {filename}")
                output[filename] = data
            now = time.perf_counter()
            if now - last_progress >= 2:
                print(f"[{now - started:.1f}s] {class_index}/{len(selected)} classes; "
                      f"{len(recovered):,} bodies emitted; {name}", file=sys.stderr, flush=True)
                last_progress = now

        incomplete = bool(failures or field_failures or class_failures)
        refuse_output = args.unrecovered == "error" and incomplete
        if refuse_output:
            print("Output not written: selected classes contain unrecovered definitions", file=sys.stderr)
        if args.output and not refuse_output:
            if args.directory:
                for name, data in sorted(output.items()):
                    path = args.output / name
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_bytes(data)
            else:
                args.output.parent.mkdir(parents=True, exist_ok=True)
                with zipfile.ZipFile(args.output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
                    for name, data in sorted(output.items()):
                        entry = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                        entry.compress_type = zipfile.ZIP_DEFLATED
                        archive.writestr(entry, data)
            print(args.output)
        print(f"{len(output):,} classes; {len(recovered):,}/{total:,} method bodies recovered; "
              f"{sum(m.size for m in recovered):,} original method-span bytes; "
              f"{declarations:,} original native/abstract declarations; "
              f"{time.perf_counter() - started:.2f}s")
        if bridges:
            print(f"Native declarations include {len(bridges):,} KNI bridges "
                  f"({sum(m.size for m in bridges):,} original thunk-span bytes)")
        if native_bitcasts:
            print(f"{native_bitcasts} return-only ROM bitcasts use JVM native intrinsics")
        if args.failures:
            for method, reason in sorted(failures.items(), key=lambda item: (item[0].address, item[0].name)):
                print(f"0x{method.address:08x} {method.owner}.{method.name}{method.descriptor}: {reason}")
            for field, reason in field_failures.items():
                print(f"{field.owner}.{field.name}: {reason}")
        elif failures:
            reasons = Counter(re.sub(r"0x[0-9a-f]+", "<address>",
                              re.sub(r"^0x[0-9a-f]+: ", "", reason)) for reason in failures.values())
            print("Remaining lowering rules:")
            for reason, count in reasons.most_common(12):
                print(f"  {count:5,d}  {reason}")
        for name, reason in class_failures.items():
            print(f"Class {name}: {reason}", file=sys.stderr)
        if field_failures:
            print(f"{len(field_failures)} fields omitted because their types are unresolved", file=sys.stderr)
        return 0 if output and not refuse_output else 1
    except (OSError, ValueError, KeyError) as error:
        print(f"bytecode recovery failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
