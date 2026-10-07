#!/usr/bin/env python3
"""Extract the ROM metadata tables embedded in an Esmertec Jbed VM.

This is intentionally a metadata extractor, not an AOT compiler.  Jbed stores
its precompiled Java image in libjbedvm.so and uses four-bit table parameters
followed by open-addressed bucket arrays.  The name entries are length-prefixed
with 0x80 | length and are grouped by hash bucket.

The offsets below are for the lib/armeabi/libjbedvm.so shipped in this
repository.  They can be overridden in a future version once the ELF section
scanner is made automatic.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


TABLES = (
    ("packages", 0x26256C, 0x262C8C),
    ("classes", 0x262C8C, 0x266850),
    ("signatures", 0x266850, 0x269814),
    ("member_names", 0x269814, 0x2813E8),
    ("field_names", 0x2813E8, 0x2F6E64),
)

COMPILER_NAMES = re.compile(
    r"(?:compiler|coder|code|class|jar|zip|parse|verify|compile|precomp|fixup|"
    r"stackmap|codemap|method|field|installstep|prepareclass|translatemethod)",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class Entry:
    table: str
    bucket: int
    ordinal: int
    offset: int
    value: str

    @property
    def zero_base_slot(self) -> int:
        # The runtime adds a table-specific base to this slot.  The slot itself
        # is enough to correlate a string with a method/field descriptor.
        return (self.bucket << self._entry_shift) + self.ordinal

    _entry_shift: int = 0


class Image:
    def __init__(self, path: Path):
        self.path = path
        self.data = path.read_bytes()

    def u32(self, offset: int) -> int:
        return struct.unpack_from("<I", self.data, offset)[0]

    def table_info(self, name: str, base: int, end: int) -> dict:
        header = self.u32(base)
        bucket_bits = header & 0xF
        entry_shift = (header >> 4) & 0xF
        bucket_count = 1 << bucket_bits
        bucket_array = base + 4
        data_start = bucket_array + bucket_count * 4
        if data_start > end:
            raise ValueError(f"{name}: table header points beyond its data range")

        buckets = []
        entries: list[Entry] = []
        for bucket in range(bucket_count):
            pointer = self.u32(bucket_array + bucket * 4)
            if not pointer:
                continue
            buckets.append({"bucket": bucket, "offset": pointer})
            ordinal = 1
            cursor = pointer
            while cursor < end and self.data[cursor] != 0:
                length, payload = self.read_length_prefixed(cursor, end)
                if length is None:
                    # A bucket can contain binary records in the signature
                    # table; do not mistake them for a name.
                    break
                text = payload.decode("ascii", errors="replace")
                entries.append(Entry(name, bucket, ordinal, cursor, text, entry_shift))
                cursor += 1 + length
                ordinal += 1

        return {
            "name": name,
            "offset": base,
            "end": end,
            "header": f"0x{header:08x}",
            "bucket_bits": bucket_bits,
            "entry_shift": entry_shift,
            "bucket_count": bucket_count,
            "non_empty_buckets": len(buckets),
            "data_start": data_start,
            "buckets": buckets,
            "entries": entries,
        }

    def read_length_prefixed(self, offset: int, end: int) -> tuple[int | None, bytes]:
        if offset >= end:
            return None, b""
        first = self.data[offset]
        # The normal ROM name encoding is a signed one-byte length: 0x80 | N.
        # Positive bytes are a base-128 continuation form used by longer data.
        if first & 0x80:
            length = first & 0x7F
            start = offset + 1
        else:
            length = first & 0x7F
            start = offset + 1
            while first > 0 and start < end:
                first = self.data[start]
                length = (length << 7) | (first & 0x7F)
                start += 1
                if first & 0x80:
                    break
        if length <= 0 or start + length > end:
            return None, b""
        payload = self.data[start : start + length]
        if not payload or any(byte < 0x20 or byte >= 0x7F for byte in payload):
            return None, b""
        return length, payload

    def report(self) -> dict:
        tables = []
        for name, base, end in TABLES:
            info = self.table_info(name, base, end)
            interesting = [
                {
                    "bucket": entry.bucket,
                    "ordinal": entry.ordinal,
                    "offset": f"0x{entry.offset:x}",
                    "zero_base_slot": entry.zero_base_slot,
                    "value": entry.value,
                }
                for entry in info["entries"]
                if COMPILER_NAMES.search(entry.value)
            ]
            tables.append(
                {
                    key: value
                    for key, value in info.items()
                    if key not in {"buckets", "entries"}
                }
                | {"interesting": interesting},
            )

        return {
            "image": str(self.path),
            "tables": tables,
            "compiler_classes": self.find("classes", [
                "Compiler", "JBedFCoderThumb", "JBedFastCoder", "FCoder",
                "ClassAccess", "JarReader", "ClassRefTable", "ArchCodeBlockWriter",
                "DirectCodeBlockWriter", "XipBlockStreamWriter", "CodeBlockWriter",
            ]),
            "compiler_members": self.find("member_names", [
                "precompile", "compile", "precompileJarFile", "installStepPrecompile",
                "prepareJarFile", "prepareJarCompileToRam", "parseClass", "startCompile",
                "compileDirect", "PrepareClass", "TranslateMethod", "allocateCode",
                "GenFixup", "fixupCode", "flushFixups", "writeClassObj", "getStackMap",
                "getCodeRanges", "staticCodeChains", "dynCodeChains", "classRefTables",
            ]),
        }

    def find(self, table_name: str, values: Iterable[str]) -> list[dict]:
        wanted = set(values)
        for name, base, end in TABLES:
            if name != table_name:
                continue
            info = self.table_info(name, base, end)
            return [
                {
                    "bucket": entry.bucket,
                    "ordinal": entry.ordinal,
                    "offset": f"0x{entry.offset:x}",
                    "zero_base_slot": entry.zero_base_slot,
                    "value": entry.value,
                }
                for entry in info["entries"]
                if entry.value in wanted
            ]
        raise KeyError(table_name)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("image", type=Path)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    args = parser.parse_args()
    report = Image(args.image).report()
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        for table in report["tables"]:
            print(
                f"{table['name']:12} header={table['header']} "
                f"buckets={table['bucket_count']} nonempty={table['non_empty_buckets']} "
                f"data=0x{table['data_start']:x}..0x{table['end']:x}"
            )
        print("\nCompiler classes:")
        for item in report["compiler_classes"]:
            print(f"  {item['value']:28} bucket={item['bucket']:4} slot={item['zero_base_slot']:5} @ {item['offset']}")
        print("\nCompiler members:")
        for item in report["compiler_members"]:
            print(f"  {item['value']:32} bucket={item['bucket']:4} slot={item['zero_base_slot']:5} @ {item['offset']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
