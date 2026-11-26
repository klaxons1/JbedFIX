"""Java identities and object layouts recovered from the Jbed ROM tables."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import struct
from typing import Mapping

try:
    from extract_jbed_aot import Image
except ModuleNotFoundError:
    from tools.extract_jbed_aot import Image


class UnsupportedJava(ValueError):
    """A ROM operation or type needs another recovery rule."""


_PRIMITIVES = dict(zip("VZBCSIJFD", ("void", "boolean", "byte", "char", "short",
                                          "int", "long", "float", "double")))
_KEYWORDS = frozenset("abstract assert boolean break byte case catch char class const continue "
    "default do double else enum extends final finally float for goto if implements import "
    "instanceof int interface long native new package private protected public return short "
    "static strictfp super switch synchronized this throw throws transient try void volatile "
    "while true false null _ var yield record sealed permits".split())


def java_identifier(name: str) -> str:
    """Preserve legal ROM names; escape characters and words rejected by javac."""
    if not name:
        raise UnsupportedJava("empty Java identifier")
    result = "".join(c if (c.isascii() and (c.isalnum() or c in "_$"))
                     else f"$u{ord(c):04x}$" for c in name)
    if result[0].isdigit() or result in _KEYWORDS:
        result = "$" + result
    return result


def mapped_name(name: str, remap: Mapping[str, str] | None = None) -> str:
    """Map exact binary names, or package prefixes ending with '/'."""
    for old, new in sorted((remap or {}).items(), key=lambda pair: -len(pair[0])):
        if name == old or old.endswith("/") and name.startswith(old):
            name = new + name[len(old):]
            break
    return ".".join(java_identifier(part) for part in name.split("/"))


def _type_end(descriptor: str, start: int, allow_void: bool = False) -> int:
    cursor = start
    while cursor < len(descriptor) and descriptor[cursor] == "[":
        cursor += 1
    if cursor == len(descriptor):
        raise UnsupportedJava(f"incomplete type descriptor {descriptor!r}")
    token = descriptor[cursor]
    if token == "L":
        end = descriptor.find(";", cursor)
        if end <= cursor + 1:
            raise UnsupportedJava(f"invalid reference descriptor {descriptor!r}")
        return end + 1
    if token in _PRIMITIVES and (token != "V" or allow_void and cursor == start):
        return cursor + 1
    raise UnsupportedJava(f"invalid type descriptor {descriptor!r}")


def split_method_descriptor(descriptor: str | None) -> tuple[tuple[str, ...], str]:
    if not descriptor or not descriptor.startswith("("):
        raise UnsupportedJava(f"unresolved method descriptor {descriptor!r}")
    cursor = 1
    arguments = []
    while cursor < len(descriptor) and descriptor[cursor] != ")":
        end = _type_end(descriptor, cursor)
        arguments.append(descriptor[cursor:end])
        cursor = end
    if cursor >= len(descriptor):
        raise UnsupportedJava(f"unterminated method descriptor {descriptor!r}")
    start = cursor + 1
    end = _type_end(descriptor, start, allow_void=True)
    if end != len(descriptor):
        raise UnsupportedJava(f"trailing method descriptor data {descriptor!r}")
    return tuple(arguments), descriptor[start:end]


def java_type(descriptor: str | None, remap: Mapping[str, str] | None = None) -> str:
    if not descriptor or _type_end(descriptor, 0, allow_void=True) != len(descriptor):
        raise UnsupportedJava(f"unresolved type descriptor {descriptor!r}")
    dimensions = len(descriptor) - len(descriptor.lstrip("["))
    base = descriptor[dimensions:]
    name = mapped_name(base[1:-1], remap) if base.startswith("L") else _PRIMITIVES[base]
    return name + "[]" * dimensions


@dataclass(frozen=True)
class ExceptionRegion:
    start: int
    end: int
    handler: int
    catch_class: str | None  # None is the VM's catch-all/finally record.


@dataclass(frozen=True)
class MethodSpec:
    owner: str
    name: str
    descriptor: str | None
    address: int
    size: int
    is_static: bool
    flags: int = 0
    virtual_slot: int = -1
    record_address: int = 0
    exception_regions: tuple[ExceptionRegion, ...] = ()

    @property
    def has_handlers(self) -> bool:
        return bool(self.exception_regions)

    @property
    def argument_types(self) -> tuple[str, ...]:
        return split_method_descriptor(self.descriptor)[0]

    @property
    def return_type(self) -> str:
        return split_method_descriptor(self.descriptor)[1]

    @property
    def parameter_names(self) -> tuple[str, ...]:
        return tuple(f"p{i}" for i in range(len(self.argument_types)))

    @property
    def is_constructor(self) -> bool:
        return self.name == "<init>"

    @property
    def is_abstract(self) -> bool:
        return bool(self.flags & 0x400)

    @property
    def is_native(self) -> bool:
        return bool(self.flags & 0x100) or self.is_kni_bridge

    @property
    def is_kni_bridge(self) -> bool:
        # Coder.Invoke (0x16c6bc) treats 0x800000 methods as KNI handle calls.
        # Their spans are ABI thunks: saveFrameInfo/enterCommonStack, native
        # Java_* target, exitCommonStack/throwKni (e.g. 0x1b73f0), not Java bodies.
        return bool(self.flags & 0x800000)


@dataclass(frozen=True)
class FieldSpec:
    owner: str
    name: str
    descriptor: str | None
    offset: int
    is_static: bool
    flags: int = 0
    storage: str = "instance"
    constant_bits: int | None = None
    record_address: int = 0


@dataclass(frozen=True)
class ClassSpec:
    name: str
    class_id: int
    descriptor_address: int
    tag_address: int
    flags: int
    instance_size: int
    superclass: str | None
    interfaces: tuple[str, ...]
    fields: tuple[FieldSpec, ...]
    methods: tuple[MethodSpec, ...]
    dimensions: int = 0

    @property
    def is_interface(self) -> bool:
        return bool(self.flags & 0x200)


def _exception_regions(image: Image, address: int, size: int, limit: int,
                       classes: Mapping[int, str]) -> tuple[ExceptionRegion, ...]:
    """Decode the trailing native table read by ArchBase.handleException.

    ROM method sizes exclude this table. Its tagged control-word pointer is
    retained in the owning method's literal pool; bit zero denotes handlers
    and bit one denotes synchronization. Requiring that reference, valid
    native ranges and a terminator before the next method distinguishes the
    table from adjacent instructions and unrelated pointer data.
    """
    if not size:
        return ()
    start = address & ~1
    end = start + size
    table = cursor = (end + 3) & ~3
    regions = []
    while cursor + 4 <= limit:
        try_start = image.u32(cursor)
        if not try_start:
            break
        if cursor + 16 > limit:
            return ()
        try_start, try_end, handler, catch_class = struct.unpack_from("<4I", image.data, cursor)
        if not (start <= try_start < try_end <= end and start <= handler < end):
            return ()
        if catch_class and catch_class not in classes:
            return ()
        regions.append(ExceptionRegion(try_start, try_end, handler,
                                       classes.get(catch_class) if catch_class else None))
        cursor += 16
    else:
        return ()
    if not regions:
        return ()
    if not any((image.u32(site) & ~3) == table and image.u32(site) & 1
               for site in range((start + 3) & ~3, end - 3, 4)):
        return ()
    return tuple(regions)


def _constructor_marker_types(image: Image, records: list[dict]) -> dict[int, str]:
    """Identify erased nominal types used exclusively as ignored constructor arguments.

    The ROM optimizer omitted these classes but retained their full bundle IDs
    in constructor signatures. Their original names are gone. Keep distinct
    nominal identities, proving that every occurrence's incoming argument is
    neither read nor passed to another method along any native control path.
    """
    from capstone import Cs, CS_ARCH_ARM, CS_GRP_JUMP, CS_MODE_THUMB
    from capstone.arm import ARM_OP_IMM

    known = {record["class_id"] for record in records} | {0, 4, 5, 6, 7, 8, 9, 10, 11}
    methods = {method["code_address"]: method for record in records
               for method in record["methods"] if method["code_address"]}
    uses: dict[int, list[tuple[dict, int]]] = {}
    for record in records:
        for method in record["methods"]:
            for index, typ in enumerate(method["argument_type_ids"]):
                if typ not in known:
                    uses.setdefault(typ, []).append((method, index))
            if method["return_type_id"] not in known:
                uses.setdefault(method["return_type_id"], []).append((method, -1))
    decoder = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
    decoder.detail = True

    def ignored(method: dict, argument: int) -> bool:
        if method["name"] != "<init>" or argument < 0 or not method["code_size"]:
            return False
        word = 1 + sum(2 if typ in (7, 11) else 1
                       for typ in method["argument_type_ids"][:argument])
        if word >= 4:
            return False
        register = f"r{word}"
        start, end = method["code_address"], method["code_address"] + method["code_size"]
        pending, visited = [(start, True)], set()
        while pending:
            address, live = pending.pop()
            if (address, live) in visited:
                continue
            visited.add((address, live))
            if not start <= address < end:
                return False
            ins = next(decoder.disasm(image.data[address:min(address + 4, end)], address, count=1), None)
            if ins is None:
                return False
            reads, writes = ins.regs_access()
            if live and register in (ins.reg_name(r) for r in reads):
                return False
            if register in (ins.reg_name(r) for r in writes):
                live = False
            if ins.mnemonic in ("bl", "blx"):
                if ins.operands[0].type != ARM_OP_IMM:
                    return False
                target = ins.operands[0].imm & ~1
                if start <= target < end:
                    pending.append((target, live))
                    continue
                callee = methods.get(target)
                if callee is None:
                    return False
                count = int(not callee["flags"] & 8) + sum(
                    2 if typ in (7, 11) else 1 for typ in callee["argument_type_ids"])
                if live and word < count:
                    return False
                if callee["name"] == "throwStack":
                    continue
                live = False  # The Java ABI clobbers argument registers at calls.
            elif ins.group(CS_GRP_JUMP):
                if ins.operands[0].type != ARM_OP_IMM:
                    return False
                pending.append((ins.operands[0].imm, live))
                if ins.mnemonic == "b":
                    continue
            if ins.mnemonic == "pop" and "pc" in ins.op_str or ins.mnemonic == "mov" and ins.op_str == "pc, lr":
                continue
            pending.append((address + ins.size, live))
        return True

    return {typ: f"com/jbed/recovered/types/Type{typ:08x}"
            for typ, occurrences in uses.items()
            if typ > 0xffff and all(ignored(method, argument) for method, argument in occurrences)}


# Nonresident reference IDs in the Android ROM signatures. Build 170767
# retains EventLoop's name and its implementation on FBCCEventLoop. The
# Xperia ROM retains PhoneSystem, PropertySource and IndicatorListener. For the
# remaining erased identities, concrete producers/receivers in the Android
# machine code link live classes to distinct JVM marker interfaces.
_LOOK = "com/jbed/midp/lcdui/lookandfeel/"
_PEER = "com/jbed/midp/lcdui/toolkit/peer/"
_DATE = "com/jbed/midp/lcdui/toolkit/datepicker/"
_BUNDLE_INTERFACES = {
    0x1003b: (None, ("com/jbed/ams/AmsToolkitBase",)),  # Main.main -> setExceptionHandler
    0x10054: ("com/jbed/runtime/PropertySource", ("com/jbed/runtime/PhoneSystem$IMEIPropertySource",)),
    0x1013e: (None, ("javax/microedition/lcdui/Display$1",)),  # ProtocolRegistry.notifyTrafficLoad
    0x1013f: (None, ("com/jbed/midp/StringDataImageFactory",)),  # ImageCache.getImage
    0x10143: (None, ("com/jbed/midp/lcdui/DefaultDeviceCapabilities",)),  # ConfigBase factories
    0x10145: (_LOOK + "EventLoop", ("com/jbed/midp/lcdui/javaui/FBCCEventLoop",)),
    0x10148: (_LOOK + "PhoneSystem", ("com/jbed/midp/lcdui/DefaultPhoneSystem",)),
    0x10158: (None, ("com/jbed/midp/lcdui/DefaultActionMapper",)),
    0x10159: (_LOOK + "IndicatorListener", (_LOOK + "peer/esmertec/IndicatorDecoration",)),
    0x1015a: (None, (_LOOK + "peer/PeerLookAndFeel",)),
    0x10160: (None, (_LOOK + "peer/PeerLookAndFeel",)),  # notifyCurrentDisplayable -> setListeners
    0x1016c: (None, (_LOOK + "peer/PeerLookAndFeel",)),
    0x1016d: (None, (_LOOK + "peer/DefaultLookAndFeel",)),  # getModelStrategies returns this
    0x1016e: (None, (_LOOK + "peer/DefaultLookAndFeel",)),  # getPaintStrategies returns this
    0x10177: (None, (_PEER + "StandardDisplayPeer",)),  # ThemePeerFactory.createDisplayPeer
    0x1017e: (None, (_PEER + "StandardPopupPeer",)),  # PopupInputHandler calls into its peer
    0x10189: (None, ("com/jbed/midp/lcdui/theme/JarThemeConnector",)),  # BMThemeData.createConnector
    0x1018e: (None, tuple(_DATE + name for name in
                          ("DatePicker", "DatetimeController", "CalendarController", "ClockItem"))),
    0x101bd: (None, ("com/jbed/microedition/media/player/CoreBasicPlayer",)),  # setMetaDataItem
    0x101ed: (None, ("javax/microedition/lcdui/DefaultFormLayoutPolicy",)),  # FormLayout.layout
}


class RomImage:
    def __init__(self, path: str | Path):
        self.image = Image(Path(path))
        self.data = self.image.data
        self.pointer_slots = set()
        if self.data[:6] == b"\x7fELF\x01\x01":
            section_offset = struct.unpack_from("<I", self.data, 32)[0]
            section_size, section_count = struct.unpack_from("<HH", self.data, 46)
            for i in range(section_count):
                section = section_offset + i * section_size
                if struct.unpack_from("<I", self.data, section + 4)[0] != 9:  # SHT_REL
                    continue
                offset, size = struct.unpack_from("<II", self.data, section + 16)
                for site, info in struct.iter_unpack("<II", self.data[offset:offset + size]):
                    if info & 255 in (2, 23):  # R_ARM_ABS32, R_ARM_RELATIVE
                        self.pointer_slots.add(site)
        records = self.image.rom_classes()
        self.erased_marker_types = _constructor_marker_types(self.image, records)
        type_descriptors = {0: "V", 4: "Z", 5: "C", 6: "F", 7: "D", 8: "B", 9: "S", 10: "I", 11: "J"}
        for record in records:
            name = record["full_name"]
            if name.startswith("<primitive:"):
                base = type_descriptors[int(name[11:-1])]
            else:
                base = "L" + name + ";"
            type_descriptors[record["class_id"]] = "[" * record["array_dimensions"] + base
        type_descriptors.update({typ: "L" + name + ";" for typ, name in self.erased_marker_types.items()})
        bundle_names = {typ: name or f"com/jbed/recovered/types/Type{typ:08x}"
                        for typ, (name, _) in _BUNDLE_INTERFACES.items()}
        type_descriptors.update({typ: "L" + name + ";" for typ, name in bundle_names.items()})
        # Manager.selectDisplaySize indexes the returned array and directly
        # passes the element to getDisplaySizeText(DisplaySizeInfo), 0xaff58.
        type_descriptors[0x10463] = "[Lcom/jbed/ams/DisplaySizeInfo;"
        # Manager.getCommands indexes this array and dispatches each element
        # directly to addCommonCommand(Command), 0xb3de8..0xb3e08.
        type_descriptors[0x10464] = "[Ljavax/microedition/lcdui/Command;"
        # This optional AMS receiver is absent from the resident class index.
        # Its method signature still preserves the loaded-bundle type identity.
        self.unresolved_types = {0x10122: "com/jbed/recovered/types/Type00010122"}
        type_descriptors.update({typ: "L" + name + ";" for typ, name in self.unresolved_types.items()})
        implements = {}
        for typ, (_, owners) in _BUNDLE_INTERFACES.items():
            for owner in owners:
                implements.setdefault(owner, []).append(bundle_names[typ])
        for record in records:
            for field in record["fields"]:
                if field["descriptor"] is None:
                    field["descriptor"] = type_descriptors.get(field["type_id"])
            for method in record["methods"]:
                types = method["argument_type_ids"] + [method["return_type_id"]]
                if method["descriptor"] is None and all(typ in type_descriptors for typ in types):
                    method["descriptor"] = "(" + "".join(type_descriptors[typ] for typ in types[:-1]) + ")" + type_descriptors[types[-1]]
        names = {c["descriptor_address"]: c["full_name"] for c in records}
        starts = sorted({m["code_address"] & ~1 for c in records for m in c["methods"]
                         if m["code_size"]})
        limits = dict(zip(starts, starts[1:] + [len(self.data)]))
        classes = []
        for record in records:
            owner = record["full_name"]
            address = record["descriptor_address"]
            interfaces = self.image.u32(address + 24)
            interface_names = ()
            if interfaces:
                count = self.image.u32(interfaces + 12)
                self.image.require_range(interfaces + 16, count * 4)
                interface_names = tuple(names[self.image.u32(interfaces + 16 + 4 * n)]
                                        for n in range(count))
            if not record["array_dimensions"]:
                interface_names += tuple(implements.get(owner, ()))
            fields = tuple(FieldSpec(owner, f["name"], f["descriptor"], f.get("offset", -1),
                bool(f["flags"] & 8), f["flags"], f["storage"], f.get("constant_bits"),
                f["record_address"]) for f in record["fields"])
            methods = tuple(MethodSpec(owner, m["name"], m["descriptor"], m["code_address"],
                m["code_size"], bool(m["flags"] & 8), m["flags"], m["virtual_slot"],
                m["record_address"], _exception_regions(self.image, m["code_address"],
                    m["code_size"], limits.get(m["code_address"] & ~1, len(self.data)), names))
                for m in record["methods"])
            classes.append(ClassSpec(owner, record["class_id"], address,
                self.image.u32(address + 36), self.image.u32(address + 12),
                record["instance_size"], names.get(record["superclass_address"]),
                interface_names, fields, methods, record["array_dimensions"]))
        classes.extend(ClassSpec(name, typ, 0, 0, 0x11, 12, "java/lang/Object", (), (), ())
                       for typ, name in sorted(self.erased_marker_types.items()))
        classes.extend(ClassSpec(name, typ, 0, 0, 0x601, 12, "java/lang/Object", (), (), ())
                       for typ, name in sorted(bundle_names.items()))
        self.classes = tuple(classes)
        self.by_name = {c.name: c for c in classes if not c.dimensions}
        self.by_descriptor = {c.descriptor_address: c for c in classes if c.descriptor_address}
        # Isolate.initBundle(0) walks this null-terminated Class[] in ROM order.
        self.initializer_order = {}
        initializer_table = self.image.u32(0x299354)
        while True:
            descriptor = self.image.u32(initializer_table + 4 * len(self.initializer_order))
            if not descriptor:
                break
            klass = self.by_descriptor.get(descriptor)
            if klass is None or klass.name in self.initializer_order:
                raise UnsupportedJava("invalid ROM class initializer order")
            self.initializer_order[klass.name] = len(self.initializer_order)
        self.by_id = {c.class_id: c for c in classes}
        self.by_tag = {c.tag_address: c for c in classes if c.tag_address}
        self.field_specs = tuple(f for c in classes for f in c.fields)
        self.methods = tuple(m for c in classes for m in c.methods)
        self.method_map = {}
        self.method_aliases: dict[int, list[MethodSpec]] = {}
        for method in self.methods:
            if method.address:
                self.method_aliases.setdefault(method.address & ~1, []).append(method)
        for address, aliases in self.method_aliases.items():
            if len(aliases) == 1:
                self.method_map[address] = aliases[0]
        self.methods_by_address = self.method_map
        self.fields = self.field_specs
        self.helpers: dict[int, str] = {}
        self.superclasses = {c.name: c.superclass for c in classes if not c.dimensions}
        self.interface_implementations: dict[str, list[ClassSpec]] = {}
        for klass in self.by_name.values():
            if klass.is_interface:
                continue
            pending = [i for base in self.ancestors(klass.name) for i in base.interfaces]
            seen = set()
            while pending:
                interface = pending.pop()
                if interface not in seen:
                    seen.add(interface)
                    self.interface_implementations.setdefault(interface, []).append(klass)
                    pending.extend(self.by_name[interface].interfaces)

    def class_named(self, name: str) -> ClassSpec:
        return self.by_name[name.replace(".", "/")]

    def method_at(self, address: int, owner: str | None = None) -> MethodSpec:
        matches = self.method_aliases.get(address & ~1, [])
        if owner is not None:
            matches = [m for m in matches if m.owner == owner]
        if len(matches) != 1:
            raise UnsupportedJava(f"method address 0x{address:x} has {len(matches)} identities")
        return matches[0]

    def ancestors(self, owner: str):
        seen = set()
        while owner is not None:
            if owner in seen:
                raise UnsupportedJava(f"cyclic superclass metadata for {owner}")
            seen.add(owner)
            klass = self.by_name[owner]
            yield klass
            owner = klass.superclass

    def instance_field(self, owner: str, offset: int) -> FieldSpec:
        for klass in self.ancestors(owner):
            for field in klass.fields:
                if not field.is_static and field.offset == offset:
                    return field
        raise UnsupportedJava(f"no instance field {owner}+0x{offset:x}")

    def static_field(self, offset: int) -> FieldSpec:
        matches = [f for f in self.field_specs if f.storage == "isolate_static" and f.offset == offset]
        if len(matches) != 1:
            raise UnsupportedJava(f"isolate offset 0x{offset:x} has {len(matches)} field identities")
        return matches[0]

    def virtual_method(self, owner: str, slot: int) -> MethodSpec:
        if slot < 0:
            raise UnsupportedJava(f"invalid virtual slot {slot}")
        for klass in self.ancestors(owner):
            for method in klass.methods:
                if method.virtual_slot == slot:
                    return method
        raise UnsupportedJava(f"no virtual method {owner} slot {slot}")

    def implementation_slot(self, interface: str, slot: int) -> MethodSpec:
        """Resolve a class-vtable load on a receiver whose declared type is an interface."""
        implementations = self.interface_implementations.get(interface, ())
        if implementations:
            common = set.intersection(*({c.name for c in self.ancestors(k.name)} for k in implementations))
            base = next(c for c in self.ancestors(implementations[0].name) if c.name in common)
            member = self.virtual_method(base.name, slot)
            checked = False
            for klass in implementations:
                if not klass.tag_address:
                    continue
                override = self.virtual_method(klass.name, slot)
                count = self.image.u16(klass.descriptor_address + 34)
                if slot >= count or (override.name, override.descriptor) != (member.name, member.descriptor):
                    break
                code = self.image.u32(klass.tag_address + 8 + 4 * slot)
                if not code or code & ~1 != override.address & ~1:
                    break
                checked = True
            else:
                if checked:
                    return member
        raise UnsupportedJava(f"unresolved implementation slot {interface}:{slot}")

    def object_class(self, address: int) -> ClassSpec:
        tag = self.image.u32(address) & ~3
        if tag not in self.by_tag:
            raise UnsupportedJava(f"unresolved object tag 0x{tag:x} at 0x{address:x}")
        return self.by_tag[tag]

    def string_literal(self, address: int) -> str:
        klass = self.object_class(address)
        if klass.name != "java/lang/String" or klass.dimensions:
            raise UnsupportedJava(f"object 0x{address:x} is not a String")
        pointer, count = struct.unpack_from("<II", self.data, address + 16)
        self.image.require_range(pointer, count * 2)
        return self.data[pointer:pointer + count * 2].decode("utf-16le", errors="surrogatepass")
