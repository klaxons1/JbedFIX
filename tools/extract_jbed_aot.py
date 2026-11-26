#!/usr/bin/env python3
"""Extract the ROM metadata tables embedded in an Esmertec Jbed VM.

This is intentionally a metadata extractor, not an AOT compiler.  Jbed stores
its precompiled Java image in libjbedvm.so and uses four-bit table parameters
followed by bucket-pointer arrays. Name lengths use a base-128 prefix whose
last byte has its high bit set; entries are grouped by hash bucket.

The ROM class index also identifies compiled method addresses and lengths.
Those lengths include inline literal pools; they are not instruction counts.

The offsets below are for the app/src/main/jniLibs/armeabi/libjbedvm.so shipped in this
repository.  Other VM builds require their own layout analysis.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
from collections import defaultdict
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

ROM_CLASS_INDEX = 0x25F548

# Unlike signatures, packed field records store just the low 16 bits of a
# bundle type. Full-width accessors, their native loads/stores and the Android
# 170767 field table identify these collisions in the bundled Android ROM.
_BUNDLE_FIELD_IDS = {
    "com/jbed/ams/Manager": {"displaySizeInfos": 0x10463},
    "com/jbed/midp/ImageCache": {"fImageFactory": 0x1013f},
    "com/jbed/midp/lcdui/DefaultPhoneSystem": {"fEventLoop": 0x10145},
    "com/jbed/midp/lcdui/ewt/Display": {"fEventLoop": 0x10145},
    "com/jbed/midp/lcdui/lookandfeel/peer/DefaultLookAndFeel": {
        "fDisplayPeer": 0x10177, "fActionMapper": 0x10158, "fDeviceCapabilities": 0x10143,
    },
    "com/jbed/midp/lcdui/theme/ThemeLoader": {"fConnector": 0x10189},
    "com/jbed/midp/lcdui/toolkit/ewt/FormLayout": {"fLayoutPolicy": 0x101ed},
    "com/jbed/midp/lcdui/toolkit/ewt/PopupInputHandler": {"fPopupPeer": 0x1017e},
    "com/jbed/midp/lcdui/toolkit/peer/StandardDisplayablePeer": {"fIndicatorListener": 0x10159},
    "com/jbed/midp/lcdui/toolkit/peer/StandardDisplayPeer": {
        "fPhoneSystem": 0x10148, "fIndicatorListener": 0x10159,
    },
    "com/jbed/runtime/Isolate": {"exceptionHandler": 0x1003b},
    "com/jbed/tina/media/clip/ParsingMidiClip": {"_metaListener": 0x101bd},
    "com/jbed/tina/media/clip/ParsingWavClip": {"_metaListener": 0x101bd},
    "java/lang/System": {"propertySource": 0x10054},
    "javax/microedition/io/ProtocolRegistry": {"pmonitor": 0x1013e},
    "javax/microedition/lcdui/Display": {
        "fProtocolMonitor": 0x1013e, "fEventLoop": 0x10145, "fDeviceCapabilities": 0x10143,
        "fLookAndFeel": 0x1015a, "fIndicatorListener": 0x10159, "fModelStrategies": 0x1016d,
    },
    "javax/microedition/lcdui/Form": {"fCustomItemListener": 0x10160, "fLayoutPolicy": 0x101ed},
}

PRIMITIVES = {
    4: ("boolean", "Z"), 5: ("char", "C"), 6: ("float", "F"),
    7: ("double", "D"), 8: ("byte", "B"), 9: ("short", "S"),
    10: ("int", "I"), 11: ("long", "J"),
}

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
        # Preserve the original extractor's unadjusted slot for existing users.
        # Header byte 2 can change both the shift and base; use runtime_slot to
        # resolve actual ROM references (notably the class-name table).
        return (self.bucket << self._entry_shift) + self.ordinal

    _entry_shift: int = 0
    runtime_slot: int = 0


class Image:
    def __init__(self, path: Path):
        self.path = path
        self.data = path.read_bytes()

    def u32(self, offset: int) -> int:
        self.require_range(offset, 4)
        return struct.unpack_from("<I", self.data, offset)[0]

    def u16(self, offset: int) -> int:
        self.require_range(offset, 2)
        return struct.unpack_from("<H", self.data, offset)[0]

    def require_range(self, offset: int, length: int) -> None:
        if offset < 0 or length < 0 or offset + length > len(self.data):
            raise ValueError(f"range 0x{offset:x}+0x{length:x} exceeds image")

    def _read_record(self, offset: int, end: int) -> tuple[int, bytes]:
        """Return the end and payload of one terminating-high-bit length record."""
        self.require_range(offset, 1)
        end = min(end, len(self.data))
        cursor = offset
        length = 0
        while cursor < end:
            value = self.data[cursor]
            cursor += 1
            length = (length << 7) | (value & 0x7F)
            if value & 0x80:
                break
        else:
            raise ValueError(f"unterminated record length at 0x{offset:x}")
        if length <= 0 or cursor + length > end:
            raise ValueError(f"invalid record length at 0x{offset:x}")
        return cursor + length, self.data[cursor : cursor + length]

    def table_info(self, name: str, base: int, end: int) -> dict:
        header = self.u32(base)
        bucket_bits = header & 0xF
        entry_shift = (header >> 4) & 0xF
        # sub_12A2DC increments the runtime shift and sets its base when byte 2
        # is nonzero; sub_12A384 returns (bucket << shift) + ordinal + base.
        runtime_entry_shift = entry_shift + bool((header >> 16) & 0xFF)
        runtime_slot_base = (1 << entry_shift) if (header >> 16) & 0xFF else 0
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
            self.require_range(pointer, 1)
            buckets.append({"bucket": bucket, "offset": pointer})
            ordinal = 1
            cursor = pointer
            while cursor < min(end, len(self.data)) and self.data[cursor] != 0:
                try:
                    next_cursor, payload = self._read_record(cursor, end)
                except ValueError:
                    break
                if any(byte < 0x20 or byte >= 0x7F for byte in payload):
                    # A bucket can contain binary records in the signature
                    # table; do not mistake them for a name.
                    break
                text = payload.decode("ascii", errors="replace")
                runtime_slot = (bucket << runtime_entry_shift) + ordinal + runtime_slot_base
                entries.append(Entry(name, bucket, ordinal, cursor, text, entry_shift, runtime_slot))
                cursor = next_cursor
                ordinal += 1

        return {
            "name": name,
            "offset": base,
            "end": end,
            "header": f"0x{header:08x}",
            "bucket_bits": bucket_bits,
            "entry_shift": entry_shift,
            "runtime_entry_shift": runtime_entry_shift,
            "runtime_slot_base": runtime_slot_base,
            "bucket_count": bucket_count,
            "non_empty_buckets": len(buckets),
            "data_start": data_start,
            "buckets": buckets,
            "entries": entries,
        }

    def read_length_prefixed(self, offset: int, end: int) -> tuple[int | None, bytes]:
        if offset < 0 or offset >= min(end, len(self.data)):
            return None, b""
        try:
            _, payload = self._read_record(offset, end)
        except ValueError:
            return None, b""
        if not payload or any(byte < 0x20 or byte >= 0x7F for byte in payload):
            return None, b""
        return len(payload), payload

    def table_payloads(self, name: str, base: int, end: int) -> dict[int, bytes]:
        """Include binary records, which the printable-name view omits."""
        info = self.table_info(name, base, end)
        result = {}
        for bucket in info["buckets"]:
            cursor = bucket["offset"]
            ordinal = 1
            while cursor < end and self.data[cursor] != 0:
                cursor, payload = self._read_record(cursor, end)
                slot = ((bucket["bucket"] << info["runtime_entry_shift"])
                        + ordinal + info["runtime_slot_base"])
                result[slot] = payload
                ordinal += 1
        return result

    @staticmethod
    def signature_types(signature_id: int, records: dict[int, bytes],
                        short_types: dict[int, int]) -> tuple[list[int], int]:
        """Decode SignatureEncoder's argument types followed by its return type.

        Evidence: openSignature 0x1477b4, getNextSignatureType 0x147818,
        addClassId 0x1471a4 and getBuiltSignatureId 0x1474a0. IDs 0xf000+
        inline three nibbles. Other IDs address binary reflection-table records.
        A void return (13) terminates immediately; 14 terminates a nonvoid result.
        Class IDs escaped by 15 mix nibble order with big-endian payload bytes.
        """
        inline = signature_id & 0xF000 == 0xF000
        data = b"" if inline else records[signature_id]
        cursor = 0
        types = []
        limit = 3 if inline else len(data) * 2
        while cursor < limit:
            if inline:
                token = (signature_id >> (cursor * 4)) & 0xF
                cursor += 1
            else:
                byte, high = divmod(cursor, 2)
                token = (data[byte] >> (high * 4)) & 0xF
                if token != 15:
                    cursor += 1
                else:
                    control = (data[byte + 1] & 0xF) if high else data[byte] >> 4
                    if control < 8:
                        token = control << 8
                        token |= ((data[byte + 1] & 0xF0) | (data[byte + 2] & 0xF)
                                  if high else data[byte + 1])
                        cursor += 4
                    else:
                        remaining = control & 7
                        cursor += remaining + 3
                        if high:
                            token = data[byte + 1] >> 4
                            next_byte = byte + 2
                        else:
                            token = 0
                            next_byte = byte + 1
                            remaining += 1
                        while remaining > 1:
                            token = (token << 8) | data[next_byte]
                            next_byte += 1
                            remaining -= 2
                        if remaining:
                            token = (token << 4) | (data[next_byte] & 0xF)
            if token == 13:
                return types, 0
            if token == 14:
                break
            types.append(short_types.get(token, token))
        if not types:
            raise ValueError(f"signature 0x{signature_id:x} has no return type")
        return types[:-1], types[-1]

    def rom_classes(self) -> list[dict]:
        """Decode class layouts, fields, signatures and compiled method spans.

        Layout evidence: sub_13421E/sub_134314/sub_134504 decode the class
        index; sub_12EC66 and sub_12F0C8 decode method records; sub_12F028
        tests code addresses against the recorded length. A method with a
        nonzero address but zero size is retained without inventing its extent.
        """
        names = {}
        for table_name in ("packages", "classes", "member_names", "field_names"):
            definition = next(table for table in TABLES if table[0] == table_name)
            names[table_name] = {
                entry.runtime_slot: entry.value
                for entry in self.table_info(*definition)["entries"]
            }
        names["packages"][0] = ""

        root = ROM_CLASS_INDEX
        header = self.u32(root)
        bucket_count = 1 << (header & 0xF)
        expected_count = self.u16(root + 4)
        self.require_range(root + 8, bucket_count * 4)
        classes = []
        for bucket in range(bucket_count):
            pointer = self.u32(root + 8 + bucket * 4)
            if not pointer:
                continue
            count = self.u32(pointer)
            self.require_range(pointer + 4, count * 12)
            for index in range(count):
                record = pointer + 4 + index * 12
                package_id, class_name_id, dimensions, _, descriptor = struct.unpack_from(
                    "<4HI", self.data, record
                )
                self.require_range(descriptor, 56)
                package = names["packages"].get(package_id)
                class_name = names["classes"].get(class_name_id)
                if package is None:
                    raise ValueError(f"unknown package ID {package_id} at 0x{record:x}")
                if class_name is None:
                    # Primitive type IDs occupy 4..11 and have no name-table
                    # entry. Keep their numeric identity instead of guessing.
                    if package_id == 0 and 4 <= class_name_id <= 11:
                        class_name = f"<primitive:{class_name_id}>"
                    else:
                        raise ValueError(f"unknown class name ID {class_name_id} at 0x{record:x}")
                full_name = f"{package}/{class_name}" if package else class_name
                method_count = self.u16(descriptor + 52)
                field_count = self.u16(descriptor + 54)
                self.require_range(descriptor + 56, (method_count + field_count) * 16)
                methods = []
                for method_index in range(method_count):
                    method_record = descriptor + 56 + method_index * 16
                    flags, name_signature, address, packed = struct.unpack_from(
                        "<4I", self.data, method_record
                    )
                    if flags & 0x80000:
                        # sub_12F028 treats size as an index into discontiguous
                        # code ranges in this case; none occur in this ROM.
                        raise ValueError(f"discontiguous method at 0x{method_record:x}")
                    size = packed >> 16
                    if size:
                        if not address:
                            raise ValueError(f"method has size but no address at 0x{method_record:x}")
                        self.require_range(address, size)
                    method_name = names["member_names"].get(name_signature & 0xFFFF)
                    if method_name is None:
                        raise ValueError(f"unknown method name at 0x{method_record:x}")
                    methods.append({
                        "name": method_name,
                        "code_address": address,
                        "code_size": size,
                        "record_address": method_record,
                        "flags": flags,
                        "signature_id": name_signature >> 16,
                        "virtual_slot": struct.unpack_from("<h", self.data, method_record + 12)[0],
                    })
                classes.append({
                    "package": package,
                    "class_name": class_name,
                    "full_name": full_name,
                    "descriptor_address": descriptor,
                    "record_address": record,
                    "array_dimensions": dimensions,
                    "class_id": self.u32(descriptor + 16),
                    "superclass_address": self.u32(descriptor + 20),
                    "instance_size": self.u32(descriptor + 28),
                    "field_count": field_count,
                    "methods": methods,
                    "fields": [],
                })
                # Field.getField 0x12c218 and getFieldAddress 0x12c2b8.
                for field_index in range(field_count):
                    field_record = descriptor + 56 + (method_count + field_index) * 16
                    flags, name_type, low, high = struct.unpack_from("<4I", self.data, field_record)
                    field_name = names["field_names"].get(name_type & 0xFFFF)
                    if field_name is None:
                        raise ValueError(f"unknown field name at 0x{field_record:x}")
                    storage = ("constant" if flags & 0x1000000 else
                               "isolate_static" if flags & 8 and flags & 0x10000 else
                               "static" if flags & 8 else "instance")
                    packed_type = name_type >> 16
                    type_id = _BUNDLE_FIELD_IDS.get(full_name, {}).get(field_name, packed_type)
                    if type_id & 0xffff != packed_type:
                        raise ValueError(f"unexpected packed field type at 0x{field_record:x}")
                    field = {
                        "name": field_name, "record_address": field_record,
                        "flags": flags, "type_id": type_id, "storage": storage,
                    }
                    if storage == "constant":
                        field["constant_bits"] = low | (high << 32)
                    else:
                        field["offset"] = low
                    classes[-1]["fields"].append(field)
        if len(classes) != expected_count:
            raise ValueError(f"class index has {len(classes)} entries, expected {expected_count}")
        by_address = {entry["descriptor_address"]: entry for entry in classes}
        type_names = {type_id: name for type_id, (name, _) in PRIMITIVES.items()}
        type_descriptors = {type_id: descriptor for type_id, (_, descriptor) in PRIMITIVES.items()}
        type_names[0], type_descriptors[0] = "void", "V"
        for entry in classes:
            dimensions = entry["array_dimensions"]
            name = entry["full_name"]
            primitive = re.fullmatch(r"<primitive:(\d+)>", name)
            if primitive:
                base_name, base_descriptor = PRIMITIVES[int(primitive[1])]
            else:
                base_name, base_descriptor = name, "L" + name + ";"
            type_names[entry["class_id"]] = base_name + "[]" * dimensions
            type_descriptors[entry["class_id"]] = "[" * dimensions + base_descriptor
        by_name = {name: type_id for type_id, name in type_names.items()}
        # The five compact reference aliases are initialized at 0x147a6c.
        short_types = {code: by_name[name] for code, name in {
            0: "java/lang/Object", 1: "java/lang/String", 2: "int[]",
            3: "byte[]", 12: "char[]",
        }.items()}
        signatures = self.table_payloads(*next(table for table in TABLES if table[0] == "signatures"))
        for entry in classes:
            parent = by_address.get(entry["superclass_address"])
            entry["superclass"] = type_names[parent["class_id"]] if parent else None
            for field in entry["fields"]:
                field["type"] = type_names.get(field["type_id"], f"<class:0x{field['type_id']:x}>")
                field["descriptor"] = type_descriptors.get(field["type_id"])
            for method in entry["methods"]:
                arguments, result = self.signature_types(method["signature_id"], signatures, short_types)
                method["argument_type_ids"] = arguments
                method["return_type_id"] = result
                method["argument_types"] = [type_names.get(t, f"<class:0x{t:x}>") for t in arguments]
                method["return_type"] = type_names.get(result, f"<class:0x{result:x}>")
                method["descriptor"] = (
                    "(" + "".join(type_descriptors[t] for t in arguments) + ")" + type_descriptors[result]
                    if all(t in type_descriptors for t in arguments + [result]) else None
                )
        return classes

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
                    "runtime_slot": entry.runtime_slot,
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
                    "runtime_slot": entry.runtime_slot,
                    "value": entry.value,
                }
                for entry in info["entries"]
                if entry.value in wanted
            ]
        raise KeyError(table_name)


def method_span_bytes(spans: Iterable[tuple[int, int]]) -> int:
    """Union of (address, size) spans, including any inline data."""
    total = 0
    end = 0
    for address, size in sorted(set(spans)):
        next_end = address + size
        if next_end > end:
            total += next_end - max(end, address)
            end = next_end
    return total


def component_sizes(classes: list[dict]) -> list[dict]:
    packages = defaultdict(list)
    for entry in classes:
        for method in entry["methods"]:
            if method["code_size"]:
                packages[entry["package"]].append((method["code_address"], method["code_size"]))
    return sorted(
        ({"package": package, "methods": len(spans), "method_span_bytes": method_span_bytes(spans)}
         for package, spans in packages.items()),
        key=lambda item: (-item["method_span_bytes"], item["package"]),
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("image", type=Path)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--components", action="store_true",
                        help="report ROM method-span bytes by package, including inline data")
    parser.add_argument("--class", dest="class_names", action="append", default=[], metavar="NAME",
                        help="show layouts and method descriptors for class-name substrings (repeatable)")
    args = parser.parse_args()
    image = Image(args.image)
    if args.class_names:
        classes = [entry for entry in image.rom_classes()
                   if any(name in entry["full_name"] for name in args.class_names)]
        if args.json:
            print(json.dumps(classes, indent=2))
        else:
            for entry in classes:
                name = entry["full_name"] + "[]" * entry["array_dimensions"]
                print(f"\n{name} extends {entry['superclass']} "
                      f"(id=0x{entry['class_id']:x}, descriptor=0x{entry['descriptor_address']:x}, "
                      f"instance size=0x{entry['instance_size']:x})")
                for field in entry["fields"]:
                    value = field.get("constant_bits", field.get("offset"))
                    print(f"  {field['storage']:14} 0x{value:08x}  {field['type']} {field['name']}")
                for method in entry["methods"]:
                    static = "static " if method["flags"] & 8 else ""
                    slot = (f" [virtual slot {method['virtual_slot']}]"
                            if method["virtual_slot"] >= 0 else "")
                    signature = method["descriptor"] or (
                        "(" + ", ".join(method["argument_types"]) + ") -> " + method["return_type"])
                    print(f"  0x{method['code_address']:08x}  {static}{method['name']}{signature}{slot}")
        return 0
    if args.components:
        components = component_sizes(image.rom_classes())
        if args.json:
            print(json.dumps({"measurement": "method spans including inline data",
                              "components": components}, indent=2))
        else:
            print("ROM method spans by package (including inline data):")
            for item in components:
                print(f"{item['method_span_bytes']:9,d} bytes  {item['methods']:5,d} methods  {item['package'] or '<default>'}")
        return 0
    report = image.report()
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
