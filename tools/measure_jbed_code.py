#!/usr/bin/env python3
"""Report instruction sizes from the annotated IDA database for the bundled VM.

Run from the repository root:
idagent --db research/jbed/libjbedvm.so.i64 --direct -f tools/measure_jbed_code.py

Reads the current IDA code/data classifications and ROM method ownership.
The saved database supplies the code/data and ARM/Thumb corrections. Each
instruction item is counted once, including folded IDA instruction macros.
"""

from bisect import bisect_right
from collections import Counter
from pathlib import Path
import runpy

import ida_bytes
import ida_segment
import idautils


LABELS = {
    "m3g": "M3G / 3D, all layers",
    "ui": "MIDP UI / 2D / widgets / themes",
    "ams": "AMS / installer / launcher / MIDlet lifecycle",
    "security": "Security / SSL / crypto / DRM",
    "compiler": "Compiler / verifier / backends",
    "io": "Network / files / stream I/O",
    "vm": "VM runtime / OS / scheduling",
    "pim": "PIM / contacts / calendars",
    "media": "Media",
    "java": "Core java.lang / java.util / java.io",
    "jpeg": "JPEG decoder / adapter",
    "rms": "RMS record stores",
    "utils": "General utilities / ZIP / JAR",
    "reflect": "Class metadata / reflection / loading",
    "android": "Common Android JNI / graphics glue",
    "push": "Push / alarms / SMS",
    "gif": "GIF decoder",
    "other": "Other Java integration",
    "plt": "ELF import stubs",
}

# Half-open native implementation spans, grouped by exported symbol families.
# Instruction flags exclude each span's literal pools, RTTI and alignment.
NATIVE_REGIONS = (
    (0x09E7A8, 0x0A2378, "android"),  # JNI/upcalls/startup
    (0x0A2378, 0x0A3308, "vm"),       # OS/timers/heap/properties
    (0x0A3308, 0x0A377C, "vm"),       # async I/O/events
    (0x0A377C, 0x0A3C94, "ui"),       # native text UI
    (0x0A3C94, 0x0A5804, "io"),       # filesystem
    (0x0A5804, 0x0A58C8, "android"),  # phone state
    (0x0A58C8, 0x0A5D98, "io"),       # zlib bridge
    (0x0A5D98, 0x0A66E4, "io"),       # network platform
    (0x0A66E4, 0x0A690C, "android"),  # indicators/language
    (0x0A690C, 0x0A6FD8, "ams"),      # AMS events
    (0x0A6FD8, 0x0A7218, "push"),     # push storage
    (0x0A7218, 0x0A7A20, "media"),
    (0x0A7A20, 0x0A7FAC, "ui"),       # themes/window/fonts
    (0x0A7FAC, 0x0A80B0, "ams"),      # saved state
    (0x0A80B0, 0x0A8708, "push"),     # SMS/WMA
    (0x0A8708, 0x0A87C4, "ams"),      # signals
    (0x0A87C4, 0x0AA6F0, "pim"),
    (0x0AA6F0, 0x0AB328, "security"), # DRM
    (0x2BD1A8, 0x2BE29C, "vm"),       # lifecycle/async/upcalls
    (0x2BE29C, 0x2BE760, "vm"),       # string/CRC/date helpers
    (0x2BE760, 0x2BEE60, "io"),
    (0x2BEE60, 0x2C7270, "ui"),       # graphics/PNG/image pipeline
    (0x2C7270, 0x2C9824, "push"),
    (0x2C9824, 0x2C9858, "vm"),       # upcall-ready state
    (0x2C9858, 0x2C9BAC, "jpeg"),     # JPEG adapter
    (0x2C9BAC, 0x2CA53C, "gif"),
    (0x2CA53C, 0x2CA950, "media"),
    (0x2CA950, 0x2CAAC4, "push"),
    (0x2CAAC4, 0x2CCB78, "m3g"),      # platform/loader/PNG
    (0x2CCB78, 0x301A7C, "m3g"),      # engine/private runtime helpers
    (0x301A7C, 0x308FD8, "m3g"),      # KNI adapters
    (0x308FD8, 0x30A5E8, "m3g"),      # VM/array/graphics glue
    (0x30A5E8, 0x30A708, "vm"),       # async finalizer
    (0x30A708, 0x30F2E0, "jpeg"),
    (0x30F2E0, 0x30F378, "vm"),       # async waiter within JPEG region
    (0x30F378, 0x3115CC, "jpeg"),
    (0x3115CC, 0x311620, "vm"),       # float conversion helper
    (0x311620, 0x311D38, "android"),
)


def package_group(package: str) -> str:
    if package in {"com/jbed/ams", "com/jbed/install", "javax/microedition/midlet",
                   "com/jbed/midp/midlet"}:
        return "ams"
    if package.startswith(("com/jbed/midp/lcdui", "javax/microedition/lcdui",
                           "com/sun/midp/lcdui")):
        return "ui"
    if package in {"com/jbed/tbcc", "JBedFastCoder", "JBedFCoderThumb"}:
        return "compiler"
    if package.startswith("iaik/") or package in {
        "com/jbed/security", "javax/microedition/pki", "com/jbed/drm"
    }:
        return "security"
    if package in {"com/jbed/pim", "javax/microedition/pim"}:
        return "pim"
    if package in {"com/jbed/runtime", "com/jbed/cldc", "com/jbed/concurrent"}:
        return "vm"
    if package.startswith(("com/jbed/io", "javax/microedition/io",
                           "com/sun/cldc/io", "com/sun/midp/io")):
        return "io"
    if "/media" in package or package == "com/jbed/tina/event":
        return "media"
    if package.startswith("java/"):
        return "java"
    if package.startswith("com/jbed/util"):
        return "utils"
    return {
        "javax/microedition/m3g": "m3g",
        "javax/microedition/rms": "rms",
        "com/jbed/reflect": "reflect",
        "com/jbed/wma/config": "push",
    }.get(package, "other")


def measure() -> tuple[Counter, Counter]:
    root = Path(__file__).resolve().parent.parent
    decoder = runpy.run_path(str(root / "tools/extract_jbed_aot.py"))
    image = decoder["Image"](root / "app/src/main/jniLibs/armeabi/libjbedvm.so")
    classes = image.rom_classes()
    methods = sorted(
        (method["code_address"], method["code_address"] + method["code_size"],
         package_group(entry["package"]))
        for entry in classes for method in entry["methods"] if method["code_size"]
    )
    if any(left[1] > right[0] for left, right in zip(methods, methods[1:])):
        raise ValueError("ROM method spans overlap")
    method_starts = [start for start, end, group in methods]
    native_starts = [start for start, end, group in NATIVE_REGIONS]
    totals = Counter()
    layers = Counter()
    unassigned = []
    for section, expected in ((".text", (0x9E7A8, 0x311D38)),
                              (".plt", (0x9E574, 0x9E7A4))):
        segment = ida_segment.get_segm_by_name(section)
        if segment is None or (segment.start_ea, segment.end_ea) != expected:
            raise ValueError(f"Open the bundled VM's annotated database: unexpected {section}")
        for address in idautils.Heads(*expected):
            if not ida_bytes.is_code(ida_bytes.get_flags(address)):
                continue
            size = ida_bytes.get_item_size(address)
            if section == ".plt":
                group, layer = "plt", "PLT"
            else:
                group = None
                for regions, starts, layer in ((methods, method_starts, "ROM methods"),
                                               (NATIVE_REGIONS, native_starts, "Native")):
                    index = bisect_right(starts, address) - 1
                    if index >= 0 and address + size <= regions[index][1]:
                        group = regions[index][2]
                        break
                if group is None:
                    unassigned.append((address, size))
                    continue
            totals[group] += size
            layers[layer] += size
    if unassigned:
        locations = ", ".join(f"0x{address:x}" for address, size in unassigned[:8])
        raise ValueError(
            f"IDA marks {sum(size for address, size in unassigned)} bytes outside recorded "
            f"methods/native regions as code ({locations}); review their classification"
        )
    return totals, layers


def main() -> None:
    totals, layers = measure()
    total = sum(totals.values())
    print("Instruction bytes from the annotated IDA database:")
    for group, size in totals.most_common():
        print(f"{size:9,d} bytes  {size / 1024:7.1f} KiB  {LABELS[group]}")
    print(f"{total:9,d} bytes  {total / 1024:7.1f} KiB  TOTAL")
    print("; ".join(f"{layer}: {size:,} bytes" for layer, size in layers.items()))


if __name__ == "__main__":
    main()
