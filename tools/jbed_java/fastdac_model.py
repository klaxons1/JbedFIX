"""Read class and member metadata from the Xperia Windows Mobile FastDAC ROM.

The image contains quickened Java bytecode, distinct from the Android AOT ROM.
Addresses below identify the tables read by this build's native VM routines.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import struct

from .model import ExceptionRegion


@dataclass
class FastDacField:
    owner: str | None
    name: str | None
    descriptor: str | None
    offset: int
    is_static: bool
    flags: int
    address: int
    storage_address: int | None = None
    constant_bits: int | None = None
    constant_value: str | None = None
    storage_kind: str | None = None
    name_recovered: bool = True
    initializer_error: str | None = None

    @property
    def access_flags(self) -> int:
        access = {0x2000: 4, 0x3000: 1, 0x4000: 2}.get(self.flags & 0x7000, 0)
        if not self.name_recovered:
            access = 1
        return access | (self.flags >> 4 & 0xD8)


@dataclass
class FastDacMethod:
    owner: str | None
    name: str | None
    descriptor: str | None
    address: int
    flags: int
    code: bytes
    max_locals: int
    max_stack: int
    pool_address: int
    exception_regions: tuple[ExceptionRegion, ...] = ()
    virtual_slot: int = -1
    interface: bool = False
    name_recovered: bool = True
    parameter_words: int = 0

    @property
    def is_static(self) -> bool:
        return not bool(self.flags & 0x1800)

    @property
    def is_synchronized(self) -> bool:
        return bool(self.flags & 0x2000)

    @property
    def is_native(self) -> bool:
        return self.flags & 3 == 2

    @property
    def is_abstract(self) -> bool:
        return self.flags & 3 == 0

    @property
    def has_bytecode(self) -> bool:
        return bool(self.flags & 1)

    @property
    def size(self) -> int:
        return len(self.code)

    @property
    def return_kind(self) -> str:
        return {0: "word", 0x4000: "wide", 0x8000: "ref", 0xC000: "void"}[self.flags & 0xC000]

    @property
    def access_flags(self) -> int:
        access = {0x40: 4, 0x60: 1, 0x80: 2}.get(self.flags & 0xE0, 0)
        if not self.name_recovered and not access:
            access = 1
        access |= 8 if self.is_static else 0
        access |= 0x20 if self.is_synchronized else 0
        access |= 0x100 if self.is_native else 0
        access |= 0x400 if self.is_abstract else 0
        if self.flags & 0x1800 == 0x1800 and not access & 2:
            access |= 0x10
        return access


@dataclass
class FastDacClass:
    name: str | None
    address: int
    class_id: int
    flags: int
    instance_size: int
    superclass_address: int
    dimensions: int
    descriptor: str | None
    superclass: str | None = None
    interfaces: tuple[str, ...] = ()
    methods: list[FastDacMethod] = field(default_factory=list)
    fields: list[FastDacField] = field(default_factory=list)
    virtual_methods: dict[int, FastDacMethod] = field(default_factory=dict)
    virtual_count: int = 0
    name_recovered: bool = True

    @property
    def is_interface(self) -> bool:
        return bool(self.flags & 0x200)

    @property
    def access_flags(self) -> int:
        return self.flags & 0x631


class FastDacImage:
    NAME_OFFSETS = 0x1C63B0
    NAME_DATA = 0x1C67B4
    CLASS_BUCKETS = 0x1F3210
    DEFAULT_POOL = 0x1C38A0
    DIRECT_METHODS = 0x201E78
    STRING_OBJECTS = 0x13C6CC
    NEW_CLASS_OFFSETS = 0x1C2E80
    NEW_CLASS_BASE = 0x1B9B98
    STATIC_BASE = 0x200E30

    def __init__(self, path: str | Path):
        self.path = Path(path)
        self.data = self.path.read_bytes()
        self.sections: list[tuple[int, int, int]] = []
        self._read_pe()
        self._names: dict[int, bytes | None] = {}
        self.class_records: dict[int, FastDacClass] = {}
        self.class_ids: dict[int, FastDacClass] = {}
        self.classes: dict[str, FastDacClass] = {}
        self.methods: list[FastDacMethod] = []
        self.methods_by_address: dict[int, FastDacMethod] = {}
        self.fields_by_address: dict[int, FastDacField] = {}
        self.static_fields: dict[int, FastDacField] = {}
        self.static_field_aliases: dict[int, list[FastDacField]] = {}
        self.direct_methods: dict[int, FastDacMethod] = {}
        self.static_values: dict[int, int] = {}
        self.explicit_static_values: set[int] = set()
        self.string_addresses: set[int] = set()
        self._read_static_values()
        self._read_classes()
        for cls in self.class_records.values():
            parent = self.class_records.get(cls.superclass_address)
            cls.superclass = parent.name if parent else None
            if not cls.dimensions:
                self._read_methods(cls)
                self._read_fields(cls)
                self._read_interfaces(cls)
        self._read_vtables()
        for method in self.methods:
            if method.flags & 5 == 5:
                method.exception_regions = self._read_exceptions(method)

    def _read_pe(self) -> None:
        if self.data[:2] != b"MZ" or len(self.data) < 64:
            raise ValueError("not a PE image")
        pe = struct.unpack_from("<I", self.data, 60)[0]
        if self.data[pe:pe + 4] != b"PE\0\0":
            raise ValueError("invalid PE signature")
        machine, count = struct.unpack_from("<HH", self.data, pe + 4)
        optional_size = struct.unpack_from("<H", self.data, pe + 20)[0]
        optional = pe + 24
        if machine != 0x1C2 or struct.unpack_from("<H", self.data, optional)[0] != 0x10B:
            raise ValueError("expected the Xperia ARM PE32 FastDAC image")
        base = struct.unpack_from("<I", self.data, optional + 28)[0]
        for i in range(count):
            at = optional + optional_size + 40 * i
            _, rva, size, raw = struct.unpack_from("<4I", self.data, at + 8)
            if raw + size > len(self.data):
                raise ValueError("PE section exceeds image")
            self.sections.append((base + rva, raw, size))

    def read(self, address: int, size: int) -> bytes:
        if size < 0:
            raise ValueError("negative image read")
        for start, raw, length in self.sections:
            if start <= address and address + size <= start + length:
                offset = raw + address - start
                return self.data[offset:offset + size]
        raise ValueError(f"unbacked image range {address:#x}+{size:#x}")

    def u8(self, address: int) -> int:
        return self.read(address, 1)[0]

    def u16(self, address: int) -> int:
        return int.from_bytes(self.read(address, 2), "little")

    def u32(self, address: int) -> int:
        return int.from_bytes(self.read(address, 4), "little")

    def name_bytes(self, identifier: int) -> bytes | None:
        """sub_A958C: bucketed IDs with 8-bit or extended 16-bit lengths."""
        if identifier == 0:
            return b""
        if not 0x100 <= identifier < 0x1D00:
            return None
        if identifier in self._names:
            return self._names[identifier]
        ordinal = identifier & 255
        cursor = self.NAME_DATA + self.u32(self.NAME_OFFSETS + ordinal * 4)
        while ordinal < identifier:
            length = self.u8(cursor)
            cursor += 1
            if length == 255:
                self._names[identifier] = None
                return None
            if length == 254:
                length = int.from_bytes(self.read(cursor, 2), "big")
                cursor += 2
            ordinal += 256
            value = self.read(cursor, length)
            self._names[ordinal] = value
            cursor += length
        return self._names[identifier]

    def name(self, identifier: int) -> str | None:
        value = self.name_bytes(identifier)
        return value.decode("utf-8") if value else None

    def _read_classes(self) -> None:
        # sub_9D134 searches these buckets through class+12.
        for bucket in range(32):
            address = self.u32(self.CLASS_BUCKETS + 4 * bucket)
            while address:
                if address in self.class_records:
                    raise ValueError("duplicate or cyclic class hash chain")
                flags = self.u32(address)
                package_id, name_id = self.u16(address + 8), self.u16(address + 10)
                package, name = self.name(package_id), self.name(name_id)
                name_recovered = bool(name) or name_id < 256
                if package_id and not package:
                    package = f"$romPackage{package_id:04x}"
                dimensions = self.u16(address + 24) if flags & 8 else 0
                if name_id < 256 and dimensions:
                    descriptor = "[" * dimensions + chr(name_id)
                    name = descriptor
                else:
                    if not name:
                        name = f"$romClass{self.u16(address + 6):04x}"
                    name = package + "/" + name if package else name
                    descriptor = "[" * dimensions + "L" + name + ";"
                cls = FastDacClass(name, address, self.u16(address + 6), flags,
                                   4 * self.u16(address + 4), self.u32(address + 20),
                                   dimensions, descriptor, name_recovered=name_recovered)
                self.class_records[address] = cls
                if cls.class_id in self.class_ids:
                    raise ValueError(f"duplicate class ID {cls.class_id:#x}")
                self.class_ids[cls.class_id] = cls
                if name and not dimensions:
                    if name in self.classes:
                        raise ValueError(f"duplicate class name {name}")
                    self.classes[name] = cls
                address = self.u32(address + 12)

    def optional(self, cls: FastDacClass, flag: int) -> int:
        """sub_9DADC: optional class slots are ordered by ascending flag."""
        if not cls.flags & flag:
            return self.DEFAULT_POOL if flag == 0x4000 else 0
        slot = cls.address + 24
        lower = flag >> 1
        while lower >= 0x800:
            if cls.flags & lower:
                slot += 4
            lower >>= 1
        return self.u32(slot)

    def method_header(self, method: int, property_index: int) -> int:
        """sub_A8B10; return the requested variable header slot address."""
        if not 0 <= property_index <= 8:
            raise ValueError("invalid method header property")
        flags, address = self.u32(method - 4), method - 4
        if property_index == 0:
            if not flags:
                return address
            if flags & 5 != 5:
                address += 4
        if property_index <= 1 and flags & 0x10000:
            address -= 4
        if property_index <= 2 and flags & 0xE0:
            address -= 4
        if property_index <= 3 and flags & 0x3800 == 0x2000:
            address -= 4
        if property_index <= 4 and flags & 0x11 == 1:
            address -= 4
        if property_index <= 5 and flags & 0x11 == 1:
            address -= 4
        if property_index <= 6 and not flags & 0x10:
            address -= 4
        if property_index <= 7 and flags & 8:
            address -= 4
        return address - 4

    def type_descriptor(self, identifier: int) -> str | None:
        if identifier in (66, 67, 68, 70, 73, 74, 83, 90, 86):
            return chr(identifier)
        cls = self.class_ids.get(identifier)
        return cls.descriptor if cls else None

    def signature(self, identifier: int) -> str | None:
        """sub_B1A48 parses resolved ROM types as primitive or class IDs."""
        data = self.name_bytes(identifier)
        if not data:
            return None
        cursor = 1

        def one() -> str | None:
            nonlocal cursor
            if cursor >= len(data):
                raise ValueError("truncated ROM signature")
            token = data[cursor]
            cursor += 1
            if token in b"BCDFIJSZV":
                return chr(token)
            if token == ord("L"):
                if cursor >= len(data):
                    raise ValueError("truncated escaped class ID")
                token = data[cursor]
                cursor += 1
            if cursor >= len(data):
                raise ValueError("truncated class ID")
            identifier = token * 256 + data[cursor]
            cursor += 1
            return self.type_descriptor(identifier)

        arguments = [one() for _ in range(data[0])]
        result = one()
        if cursor != len(data):
            raise ValueError("trailing ROM signature bytes")
        if result is None or any(value is None for value in arguments):
            return None
        return "(" + "".join(arguments) + ")" + result

    def _read_methods(self, cls: FastDacClass) -> None:
        address = self.optional(cls, 0x800)
        seen = set()
        while address and self.u32(address - 4):
            if address in seen:
                raise ValueError("cyclic method chain")
            seen.add(address)
            flags = self.u32(address - 4)
            next_address = address + 4 * (flags >> 17)
            if next_address <= address:
                raise ValueError("nonadvancing method chain")
            end = self.method_header(next_address, 0)
            padding = self.u8(end - 1)
            if padding < 64:
                end -= padding & 7
            name = descriptor = None
            if flags & 0xE0:
                packed = self.u32(self.method_header(address, 3))
                name, descriptor = self.name(packed & 65535), self.signature(packed >> 16)
            if flags & 0x10:
                max_locals = max_stack = 8
            elif flags & 1:
                local_bytes = self.u32(address - 20)
                max_locals = local_bytes // 4 - 4
                max_stack = (self.u32(address - 16) - local_bytes) // 4
            else:
                max_locals = max_stack = 0
            method = FastDacMethod(cls.name, name, descriptor, address, flags,
                                   self.read(address, end - address), max_locals, max_stack,
                                   self.u32(address - 8) if flags & 8 else self.DEFAULT_POOL,
                                   interface=cls.is_interface, name_recovered=bool(name),
                                   parameter_words=(flags >> 8 & 7) if flags & 0x10 else self.u8(address - 12))
            if not name:
                method.name = "<init>" if flags & 0x1800 == 0x1000 else f"$romMethod{address:x}"
            cls.methods.append(method)
            self.methods.append(method)
            self.methods_by_address[address] = method
            address = next_address
        if address and self.u32(address) != cls.address:
            raise ValueError("method chain terminator has wrong class owner")

    def _read_fields(self, cls: FastDacClass) -> None:
        table = self.optional(cls, 0x1000)
        if not table:
            return
        cursor = table + 2
        for _ in range(self.u16(table)):
            flags = self.u16(cursor)
            end = cursor + 4 + ((flags >> 8) & 2) - ((flags >> 14) & 2) + ((flags >> 6) & 2)
            name = descriptor = None
            if flags & 0x7000:
                name = self.name(self.u16(end))
                descriptor = self.type_descriptor(self.u16(end + 2))
                end += 4 + (2 if flags & 3 == 3 else 0)
            offset = 4 * (((flags >> 2) & 31) if flags & 0x8000 else self.u16(cursor + 2))
            static = bool(flags & 0x80)
            storage = None
            if static:
                storage = (self.STATIC_BASE + 4 * self.u16(cursor + 2)
                           if flags & 0x8000 else self.u32(cursor + 2))
            member = FastDacField(cls.name, name, descriptor, offset, static, flags, cursor, storage)
            member.storage_kind = "wide" if flags & 3 == 1 else "ref" if flags & 2 else "word"
            member.name_recovered = bool(name)
            if not name:
                member.name = f"$romStatic{storage:x}" if static else f"$romField{offset:x}"
            if storage is not None and flags & 0x100 and descriptor:
                value = self.static_values.get(storage)
                if value is not None:
                    if descriptor == "Ljava/lang/String;" and value:
                        member.constant_value = self._string_at(value)
                    elif descriptor in ("Z", "B", "C", "S", "I", "F", "J", "D"):
                        # An explicit initialized word is a ROM constant. A
                        # default zero is also final when no initializer runs.
                        if storage in self.explicit_static_values or not any(m.name == "<clinit>" for m in cls.methods):
                            if descriptor in ("J", "D"):
                                high = self.static_values.get(storage + 4)
                                if high is not None:
                                    member.constant_bits = value | high << 32
                            else:
                                member.constant_bits = value
            cls.fields.append(member)
            self.fields_by_address[cursor] = member
            if storage is not None:
                self.static_fields[storage - self.STATIC_BASE] = member
                self.static_field_aliases.setdefault(storage - self.STATIC_BASE, []).append(member)
            cursor = end

    def _read_static_values(self) -> None:
        """sub_A8D2C initializes static words from the stream at 0x147760."""
        cursor, destination = 0x147760, self.STATIC_BASE

        def integer() -> int:
            nonlocal cursor
            byte = self.u8(cursor)
            cursor += 1
            value = byte & 127
            if value & 64:
                value -= 128
            for _ in range(5):
                if not byte & 128:
                    return value
                byte = self.u8(cursor)
                cursor += 1
                value = value << 7 | byte & 127
            raise ValueError("oversized static initializer integer")

        def count() -> int:
            value = integer()
            if not 0 <= value <= 65535:
                raise ValueError("invalid static initializer count")
            return value

        def word(value: int, explicit: bool = True) -> None:
            nonlocal destination
            self.static_values[destination] = value & 0xFFFFFFFF
            if explicit:
                self.explicit_static_values.add(destination)
            destination += 4

        for _ in range(count()):
            pointer = self.STRING_OBJECTS + 4 * integer()
            self.string_addresses.add(pointer)
            word(pointer)
        object_address = 0x146298
        for _ in range(count()):
            object_address += integer() * 4
            word(object_address)
        for _ in range(count()):
            word(0, False)
        for _ in range(count()):
            word(integer())
        for _ in range(count()):
            word(0, False)

    def _read_interfaces(self, cls: FastDacClass) -> None:
        table = self.optional(cls, 0x2000)
        if table:
            pool = self.optional(cls, 0x4000)
            interfaces = []
            for index in range(self.u16(table)):
                pointer = self.u32(pool + 4 * self.u16(table + 2 + 2 * index))
                target = self.class_records.get(pointer)
                if target is None or target.dimensions or not target.name:
                    raise ValueError("invalid ROM interface reference")
                interfaces.append(target.name)
            cls.interfaces = tuple(interfaces)

    def _read_vtables(self) -> None:
        """Decode sub_9CE80's compact initialization stream without running it.

        The PE's writable method slots start empty. Native compiled overrides
        retain the Java identity of their slot, so their addresses are skipped.
        """
        address, cursor = 0x1B9B9C, 0x1C591A
        control, remaining, next_slot, overrides = 8, 127, 0, False

        def byte() -> int:
            nonlocal cursor
            value = self.u8(cursor)
            cursor += 1
            return value

        visited = set()
        while True:
            if address in visited or address not in self.class_records:
                raise ValueError("invalid class in vtable initialization stream")
            visited.add(address)
            cls = self.class_records[address]
            inherited_count = next_slot
            if remaining & 128:
                remaining += control << 7
                control = byte()
            for method in cls.methods:
                remaining -= 1
                if remaining < 0:
                    slot = control
                    if control & 128:
                        slot += byte() << 7
                    control = byte()
                else:
                    slot = next_slot
                    next_slot += 1
                cls.virtual_methods[slot] = method
                method.virtual_slot = slot
            if overrides:
                for _ in range(control):
                    slot = byte()
                    if slot & 128:
                        slot += byte() << 7
                    if slot not in cls.virtual_methods:
                        raise ValueError("compiled override has no Java method slot")
                control = byte()
            cls.virtual_count = next_slot
            parent = self.class_records.get(cls.superclass_address)
            for slot, method in cls.virtual_methods.items():
                if method.owner != cls.name:
                    continue
                if slot >= next_slot or method.flags & 0x1800 != 0x800:
                    method.virtual_slot = -1
                    continue
                ancestor = (parent.virtual_methods.get(slot)
                            if parent and slot < inherited_count and method.flags & 0x1800 == 0x800
                            else None)
                if ancestor and not method.name_recovered:
                    method.name = ancestor.name
                    method.name_recovered = ancestor.name_recovered
                    if method.descriptor is None:
                        method.descriptor = ancestor.descriptor
                elif not method.name_recovered:
                    method.name = f"$romVirtual{slot:x}"
            table = self.u32(cls.address + 16)
            for slot, method in cls.virtual_methods.items():
                self.direct_methods[(table + slot * 4 - self.DIRECT_METHODS) // 4] = method
            step, high = control & 15, control >> 5
            overrides = bool(control & 16)
            if not step:
                break
            address += step * 4
            low, remaining, control = byte(), byte(), byte()
            next_slot = low | high << 8
            child = self.class_records.get(address)
            if child is None:
                raise ValueError("vtable stream refers to missing class")
            parent = self.class_records.get(child.superclass_address)
            if parent is None and next_slot:
                raise ValueError("vtable has inherited slots without superclass")
            if parent:
                child.virtual_methods.update({slot: method for slot, method in parent.virtual_methods.items()
                                              if slot < next_slot})

    def _read_exceptions(self, method: FastDacMethod) -> tuple[ExceptionRegion, ...]:
        """sub_A7040: raw, single packed, or variable-length handler records."""
        encoded = self.u32(self.method_header(method.address, 1))
        records = []
        if not encoded & 1:
            for index in range(self.u16(encoded)):
                at = encoded + 2 + index * 8
                records.append(tuple(self.u16(at + 2 * i) for i in range(4)))
        else:
            value = encoded >> 1
            if value >= 0x1000000:
                start = value & 1023
                end = start + ((value >> 10) & 2047) + 1
                records.append((start, end, end + ((value >> 21) & 7), (value >> 24) - 1))
            else:
                cursor = 0x147B8C + value

                def varint() -> int:
                    nonlocal cursor
                    result = 0
                    for _ in range(5):
                        byte = self.u8(cursor)
                        cursor += 1
                        result = result << 7 | byte & 127
                        if not byte & 128:
                            return result & 65535
                    raise ValueError("oversized exception table integer")

                while True:
                    header = self.u8(cursor)
                    cursor += 1
                    start = varint()
                    end = (start + varint() + 1) & 65535
                    delta = header >> 5 & 3
                    if delta == 3:
                        delta = varint() - 5
                    catch = header & 31
                    if catch == 31:
                        catch = varint()
                    records.append((start, end, (end + delta) & 65535, catch))
                    if header & 128:
                        break
        result = []
        for start, end, handler, catch in records:
            if start == end:
                continue
            if not 0 <= start < end <= len(method.code) or not 0 <= handler < len(method.code):
                raise ValueError(f"exception bounds exceed method {method.address:#x}")
            catch_class = self.pool_class(method, catch) if catch else None
            result.append(ExceptionRegion(start, end, handler, catch_class))
        return tuple(result)

    def _tagged_method(self, pointer: int) -> FastDacMethod | None:
        address = pointer & ~3
        if pointer & 2:
            address = self.u32(address - 4)
        return self.methods_by_address.get(address)

    @staticmethod
    def _member(member):
        if member is None or not member.owner or not member.name:
            raise ValueError("member identity was stripped from the FastDAC ROM")
        return member

    def _class(self, descriptor: str) -> FastDacClass:
        name = descriptor[1:-1] if descriptor.startswith("L") and descriptor.endswith(";") else descriptor
        if name.startswith("["):
            name = "java/lang/Object"
        try:
            return self.classes[name]
        except KeyError:
            raise ValueError(f"unresolved FastDAC class {descriptor}") from None

    def field_at(self, receiver_descriptor: str, offset: int, kind: str | None = None) -> FastDacField:
        cls = self._class(receiver_descriptor)
        declaring = cls
        while cls:
            for member in cls.fields:
                if not member.is_static and member.offset == offset:
                    if member.storage_kind is None:
                        member.storage_kind = kind
                    return self._member(member)
            parent = self.class_records.get(cls.superclass_address)
            if parent and offset < parent.instance_size:
                declaring = parent
            cls = parent
        if not 0 <= offset < declaring.instance_size or offset & 3:
            raise ValueError(f"field offset exceeds {receiver_descriptor} instance layout")
        member = FastDacField(declaring.name, f"$romField{offset:x}", None, offset, False,
                              0, 0, storage_kind=kind, name_recovered=False)
        declaring.fields.append(member)
        return member

    def static_field_at(self, offset: int, kind: str | None = None) -> FastDacField:
        aliases = self.static_field_aliases.get(offset, [])
        if len(aliases) == 1:
            if aliases[0].storage_kind is None:
                aliases[0].storage_kind = kind
            return aliases[0]
        if len(aliases) > 1:
            raise ValueError("static word has multiple constant field identities")
        if offset < 0 or offset & 3 or self.STATIC_BASE + offset not in self.static_values:
            raise ValueError("static offset exceeds ROM static storage")
        owner = "jbed/rom/Statics"
        if owner not in self.classes:
            self.classes[owner] = FastDacClass(owner, 0, 0, 0x31, 0, 0, 0,
                                              "L" + owner + ";", superclass="java/lang/Object",
                                              name_recovered=False)
        member = self.static_fields.get(offset)
        if member is None:
            member = FastDacField(owner, f"$romStatic{offset:x}", None, offset, True,
                                  0x80, 0, self.STATIC_BASE + offset,
                                  storage_kind=kind, name_recovered=False)
            self.static_fields[offset] = member
            self.classes[owner].fields.append(member)
        elif member.storage_kind is None:
            member.storage_kind = kind
        return member

    def finalize_field_types(self) -> list[FastDacField]:
        """Attach ROM initial values after inference supplies field types.

        Nonzero object graphs require their own reconstruction. Exporters must
        honor initializer_error rather than emit a default-null replacement.
        """
        unavailable = []
        for cls in self.classes.values():
            for member in cls.fields:
                if not member.is_static or not member.descriptor:
                    continue
                member.initializer_error = None
                member.constant_bits = None
                member.constant_value = None
                value = self.static_values.get(member.storage_address)
                if value is None:
                    member.initializer_error = "static initializer is outside the ROM initialization table"
                elif member.descriptor in ("Z", "B", "C", "S", "I", "F", "J", "D"):
                    if member.descriptor in ("J", "D"):
                        high = self.static_values.get(member.storage_address + 4)
                        if high is None:
                            member.initializer_error = "wide static initializer is truncated"
                        else:
                            member.constant_bits = value | high << 32
                    else:
                        member.constant_bits = value
                elif value:
                    if member.descriptor == "Ljava/lang/String;" and value in self.string_addresses:
                        member.constant_value = self._string_at(value)
                    else:
                        member.initializer_error = f"nonzero ROM object initializer at {value:#x} needs reconstruction"
                if member.initializer_error:
                    unavailable.append(member)
        return unavailable

    def static_constant_at(self, offset: int) -> tuple[int, int | str] | None:
        aliases = self.static_field_aliases.get(offset, [])
        values = set()
        for member in aliases:
            if member.constant_value is not None:
                values.add((8, member.constant_value))
            elif member.constant_bits is not None:
                tag = {"J": 5, "D": 6, "F": 4}.get(member.descriptor, 3)
                values.add((tag, member.constant_bits))
            else:
                return None
        return next(iter(values)) if len(values) == 1 else None

    def virtual_method(self, receiver_descriptor: str, slot: int) -> FastDacMethod:
        return self._member(self._class(receiver_descriptor).virtual_methods.get(slot))

    def direct_method(self, index: int) -> FastDacMethod:
        return self._member(self.direct_methods.get(index))

    def new_class(self, index: int) -> str:
        if not 0 <= index < 256:
            raise ValueError("quickened new class index exceeds byte operand")
        cls = self.class_records.get(self.NEW_CLASS_BASE + 4 * self.u16(self.NEW_CLASS_OFFSETS + 2 * index))
        if not cls or not cls.name:
            raise ValueError("unresolved quickened new class")
        return cls.name

    def _string_at(self, address: int) -> str:
        value, offset, length = (self.u32(address + i * 4) for i in range(3))
        if length > len(self.data) // 2:
            raise ValueError("invalid ROM string length")
        return self.read(value + 4 + offset * 2, length * 2).decode("utf-16-le", errors="surrogatepass")

    def string(self, index: int) -> str:
        return self._string_at(self.STRING_OBJECTS + 4 * index)

    def _pool_entry(self, method: FastDacMethod, index: int) -> tuple[int, int]:
        if not 0 < index < self.u16(method.pool_address):
            raise ValueError(f"constant-pool index {index} exceeds its declared count")
        return self.u8(method.pool_address - index), self.u32(method.pool_address + index * 4)

    def pool_class(self, method: FastDacMethod, index: int) -> str:
        tag, pointer = self._pool_entry(method, index)
        cls = self.class_records.get(pointer)
        if tag & 15 != 7 or not cls or not cls.descriptor:
            raise ValueError("unresolved pool class")
        return cls.descriptor if cls.dimensions else cls.name

    def pool_constant(self, method: FastDacMethod, index: int) -> tuple[int, int | str]:
        tag, value = self._pool_entry(method, index)
        kind = tag & 15
        if kind in (3, 4):
            return kind, value
        if kind in (5, 6):
            if index + 1 >= self.u16(method.pool_address):
                raise ValueError("wide constant exceeds its constant pool")
            return kind, value | self.u32(method.pool_address + 4 * (index + 1)) << 32
        if kind == 8:
            return 8, self._string_at(value)
        raise ValueError(f"unsupported pool constant tag {tag:#x}")

    def pool_field(self, method: FastDacMethod, index: int) -> FastDacField:
        tag, value = self._pool_entry(method, index)
        if tag in (18, 19, 20, 21):
            return self._member(self.fields_by_address.get(value))
        if tag == 9:
            cls = self._class(self.pool_class(method, value & 65535))
            packed = self.u32(method.pool_address + 4 * (value >> 16))
            name, descriptor = self.name(packed & 65535), self.type_descriptor(packed >> 16)
            if not name or not descriptor:
                raise ValueError("symbolic field identity was stripped")
            for owner in self._hierarchy(cls):
                for member in owner.fields:
                    if member.name == name and member.descriptor == descriptor:
                        return self._member(member)
            raise ValueError("unresolved symbolic field constant")
        raise ValueError(f"invalid field constant tag {tag:#x}")

    def pool_method(self, method: FastDacMethod, index: int) -> FastDacMethod:
        tag, value = self._pool_entry(method, index)
        if tag == 27:
            # sub_A9DC8 resolves InterfaceMethodref directly to the abstract
            # method record; ordinary Methodref entries point to slots.
            return self._member(self.methods_by_address.get(value))
        if tag in (26, 30) or tag >= 32:
            if value & 3:
                raise ValueError("unaligned resolved method slot")
            return self.direct_method((value - self.DIRECT_METHODS) // 4)
        if tag in (10, 11):
            cls = self._class(self.pool_class(method, value & 65535))
            packed = self.u32(method.pool_address + 4 * (value >> 16))
            name, descriptor = self.name(packed & 65535), self.signature(packed >> 16)
            if not name or not descriptor:
                raise ValueError("symbolic method identity was stripped")
            for owner in self._hierarchy(cls):
                for member in owner.methods:
                    if member.name == name and member.descriptor == descriptor:
                        return self._member(member)
                if name == "<init>":
                    break
            raise ValueError("unresolved symbolic method constant")
        raise ValueError(f"invalid method constant tag {tag:#x}")

    def _hierarchy(self, cls: FastDacClass):
        pending = [cls]
        seen = set()
        while pending:
            cls = pending.pop(0)
            if cls.address in seen:
                continue
            seen.add(cls.address)
            yield cls
            parent = self.class_records.get(cls.superclass_address)
            if parent:
                pending.append(parent)
            pending.extend(self.classes[name] for name in cls.interfaces if name in self.classes)

    def common_superclass(self, left: str, right: str) -> str:
        ancestors = set()
        cls = self._class(left)
        while cls:
            ancestors.add(cls.address)
            cls = self.class_records.get(cls.superclass_address)
        cls = self._class(right)
        while cls:
            if cls.address in ancestors and cls.name:
                return "L" + cls.name + ";"
            cls = self.class_records.get(cls.superclass_address)
        return "Ljava/lang/Object;"

    def direct_call_opcode(self, caller: FastDacMethod, target: FastDacMethod) -> int:
        if target.is_static:
            return 0xB8
        if target.name == "<init>" or target.owner == caller.owner and target.flags & 0xE0 == 0x80:
            return 0xB7
        target_class = self._class(target.owner)
        if target.access_flags & 0x10 or target_class.flags & 0x10:
            return 0xB6
        cls = self._class(caller.owner)
        while cls.superclass_address:
            cls = self.class_records[cls.superclass_address]
            if cls.name == target.owner:
                return 0xB7
        raise ValueError("unresolved nonvirtual direct call semantics")
