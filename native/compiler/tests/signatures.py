#!/usr/bin/env python3
"""Check C signature decoding and byte-exact rebuilding against the ROM corpus."""

import argparse
import struct
import subprocess
import sys
from pathlib import Path


def main():
    root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(root / "tools"))
    from extract_jbed_aot import Image, TABLES

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("oracle", type=Path)
    parser.add_argument("--image", type=Path,
                        default=root / "app/src/main/jniLibs/armeabi/libjbedvm.so")
    args = parser.parse_args()
    image = Image(args.image)
    table = next(t for t in TABLES if t[0] == "signatures")
    records = image.table_payloads(*table)
    ids = sorted({m["signature_id"] for klass in image.rom_classes() for m in klass["methods"]})
    payload = bytearray()
    for signature in ids:
        data = b"" if signature & 0xF000 == 0xF000 else records[signature]
        payload.extend(struct.pack("<HH", signature, len(data)))
        payload.extend(data)
    output = subprocess.run([args.oracle.resolve(), args.image, hex(table[1])], input=payload,
                            stdout=subprocess.PIPE, check=True).stdout
    cursor = 0
    short_types = {0: 0x1CE, 1: 0x1D2, 2: 0x1CF, 3: 0x1D3, 12: 0x1D0, 13: 0}
    for signature in ids:
        arguments, result = image.signature_types(signature, records, short_types)
        expected = arguments + [result]
        count = struct.unpack_from("<I", output, cursor)[0]
        cursor += 4
        values = struct.unpack_from("<" + "I" * (count + 2), output, cursor)
        cursor += 4 * (count + 2)
        if list(values[:-2]) != expected or values[-2:] != (signature, 1):
            raise AssertionError(f"signature {signature:#x}: decoded/rebuilt result {values}")
    if cursor != len(output):
        raise AssertionError("extra signature oracle output")
    print(f"{len(ids)} ROM signatures decoded and rebuilt with identical bytes and IDs")


if __name__ == "__main__":
    main()
