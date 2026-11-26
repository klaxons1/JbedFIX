"""Encode recovered ROM operations as JVM version 49 class files."""

from __future__ import annotations

import json
import re
import struct
from bisect import bisect_left
from collections.abc import Mapping, Sequence
from dataclasses import dataclass, field
from weakref import WeakKeyDictionary

from .model import (
    ClassSpec,
    ExceptionRegion,
    FieldSpec,
    MethodSpec,
    RomImage,
    UnsupportedJava,
    java_identifier,
    java_type,
    mapped_name,
    split_method_descriptor,
)
from .simplify import _Expr, _ParseError, _Parser
from .structure import Branch, Jump, LiftedCFG, Return, Switch, Throw


class UnsupportedBytecode(UnsupportedJava):
    pass


def _u2(value: int) -> bytes:
    if not 0 <= value <= 65535:
        raise UnsupportedBytecode(f"classfile u2 overflow: {value}")
    return struct.pack(">H", value)


def _u4(value: int) -> bytes:
    return struct.pack(">I", value & 0xFFFFFFFF)


def _mutf8(text: str) -> bytes:
    result = bytearray()
    units = text.encode("utf-16be", "surrogatepass")
    for pos in range(0, len(units), 2):
        value = int.from_bytes(units[pos : pos + 2], "big")
        if 0 < value < 128:
            result.append(value)
        elif value < 2048:
            result.extend((0xC0 | value >> 6, 0x80 | value & 63))
        else:
            result.extend(
                (0xE0 | value >> 12, 0x80 | value >> 6 & 63, 0x80 | value & 63)
            )
    return bytes(result)


class ConstantPool:
    """Deduplicated JVM constants; long/double occupy two constant-pool slots."""

    def __init__(self):
        self.entries: list[bytes | None] = []
        self.indices: dict[tuple, int] = {}

    def _add(self, key: tuple, payload: bytes, wide: bool = False) -> int:
        if key in self.indices:
            return self.indices[key]
        index = len(self.entries) + 1
        self.entries.append(payload)
        if wide:
            self.entries.append(None)
        _u2(len(self.entries) + 1)
        self.indices[key] = index
        return index

    def utf8(self, value: str) -> int:
        data = _mutf8(value)
        return self._add((1, value), b"\x01" + _u2(len(data)) + data)

    def class_(self, name: str) -> int:
        return self._add((7, name), b"\x07" + _u2(self.utf8(name)))

    def string(self, value: str) -> int:
        return self._add((8, value), b"\x08" + _u2(self.utf8(value)))

    def integer(self, value: int) -> int:
        value &= 0xFFFFFFFF
        return self._add((3, value), b"\x03" + _u4(value))

    def long(self, value: int) -> int:
        value &= 0xFFFFFFFFFFFFFFFF
        return self._add((5, value), b"\x05" + struct.pack(">Q", value), True)

    def float_bits(self, value: int) -> int:
        value &= 0xFFFFFFFF
        return self._add((4, value), b"\x04" + _u4(value))

    def double_bits(self, value: int) -> int:
        value &= 0xFFFFFFFFFFFFFFFF
        return self._add((6, value), b"\x06" + struct.pack(">Q", value), True)

    def name_type(self, name: str, descriptor: str) -> int:
        return self._add(
            (12, name, descriptor),
            b"\x0c" + _u2(self.utf8(name)) + _u2(self.utf8(descriptor)),
        )

    def field(self, owner: str, name: str, descriptor: str) -> int:
        return self._add(
            (9, owner, name, descriptor),
            b"\x09" + _u2(self.class_(owner)) + _u2(self.name_type(name, descriptor)),
        )

    def method(
        self, owner: str, name: str, descriptor: str, interface: bool = False
    ) -> int:
        tag = 11 if interface else 10
        return self._add(
            (tag, owner, name, descriptor),
            bytes((tag,))
            + _u2(self.class_(owner))
            + _u2(self.name_type(name, descriptor)),
        )

    def bytes(self) -> bytes:
        return _u2(len(self.entries) + 1) + b"".join(
            entry for entry in self.entries if entry is not None
        )


@dataclass(frozen=True)
class Code:
    bytecode: bytes
    max_stack: int
    max_locals: int
    # Bytecode PCs and binary catch class names; None denotes catch-all.
    exception_table: tuple[tuple[int, int, int, str | None], ...] = ()
    locals: tuple[tuple[str, str, int], ...] = ()


@dataclass(frozen=True)
class LiftedBody:
    cfg: LiftedCFG
    exception_regions: tuple[ExceptionRegion, ...] = ()
    handler_locals: Mapping[int, str] = field(default_factory=dict)


class ClassFileBuilder:
    """Raw class builder for recovered bodies or explicit metadata declarations."""

    def __init__(
        self,
        name: str,
        superclass: str | None = "java/lang/Object",
        *,
        flags: int = 0x21,
        interfaces: Sequence[str] = (),
        pool: ConstantPool | None = None,
        attributes: Sequence[tuple[str, bytes]] = (),
    ):
        self.pool = pool if pool is not None else ConstantPool()
        self.name, self.superclass = name, superclass
        self.flags, self.interfaces = flags, tuple(interfaces)
        self.attributes = tuple(attributes)
        self.fields: list[tuple[int, str, str, int | None, tuple]] = []
        self.methods: list[tuple[int, str, str, Code | None, bytes | None]] = []

    def add_field(
        self,
        name: str,
        descriptor: str,
        flags: int = 1,
        *,
        constant_index: int | None = None,
        attributes: Sequence[tuple[str, bytes]] = (),
    ):
        self.fields.append((flags, name, descriptor, constant_index, tuple(attributes)))

    def add_method(
        self,
        name: str,
        descriptor: str,
        flags: int = 1,
        *,
        code: Code | None = None,
        unavailable: bytes | None = None,
    ):
        split_method_descriptor(descriptor)
        if code is None and not flags & (0x100 | 0x400):
            raise UnsupportedBytecode(f"concrete method lacks Code: {name}{descriptor}")
        if code is not None and flags & (0x100 | 0x400):
            raise UnsupportedBytecode(
                f"native/abstract method has Code: {name}{descriptor}"
            )
        if name in ("<init>", "<clinit>") and code is None:
            raise UnsupportedBytecode(f"initializer lacks recovered Code: {name}")
        self.methods.append((flags, name, descriptor, code, unavailable))

    def _attribute(self, name: str, payload: bytes) -> bytes:
        return _u2(self.pool.utf8(name)) + _u4(len(payload)) + payload

    def to_bytes(self) -> bytes:
        cp = self.pool
        header = _u2(self.flags & 0x7631) + _u2(cp.class_(self.name))
        header += _u2(cp.class_(self.superclass) if self.superclass else 0)
        header += _u2(len(self.interfaces)) + b"".join(
            _u2(cp.class_(name)) for name in self.interfaces
        )
        fields = []
        for flags, name, desc, constant, attributes in self.fields:
            attrs = (
                []
                if constant is None
                else [self._attribute("ConstantValue", _u2(constant))]
            )
            attrs.extend(self._attribute(key, data) for key, data in attributes)
            fields.append(
                _u2(flags & 0x50DF)
                + _u2(cp.utf8(name))
                + _u2(cp.utf8(desc))
                + _u2(len(attrs))
                + b"".join(attrs)
            )
        methods = []
        for flags, name, desc, code, unavailable in self.methods:
            attrs = []
            if code is not None:
                if not code.bytecode or len(code.bytecode) > 65535:
                    raise UnsupportedBytecode(f"invalid JVM Code length for {name}")
                handlers = []
                for start, end, handler, catch in code.exception_table:
                    if not 0 <= start < end <= len(
                        code.bytecode
                    ) or not 0 <= handler < len(code.bytecode):
                        raise UnsupportedBytecode("invalid JVM exception interval")
                    handlers.append(
                        _u2(start)
                        + _u2(end)
                        + _u2(handler)
                        + _u2(cp.class_(catch) if catch else 0)
                    )
                nested = []
                if code.locals:
                    entries = [
                        _u2(0)
                        + _u2(len(code.bytecode))
                        + _u2(cp.utf8(local))
                        + _u2(cp.utf8(typ))
                        + _u2(slot)
                        for local, typ, slot in code.locals
                    ]
                    nested.append(
                        self._attribute(
                            "LocalVariableTable", _u2(len(entries)) + b"".join(entries)
                        )
                    )
                payload = (
                    _u2(code.max_stack)
                    + _u2(code.max_locals)
                    + _u4(len(code.bytecode))
                    + code.bytecode
                )
                payload += (
                    _u2(len(handlers))
                    + b"".join(handlers)
                    + _u2(len(nested))
                    + b"".join(nested)
                )
                attrs.append(self._attribute("Code", payload))
            if unavailable is not None:
                attrs.append(self._attribute("JbedUnavailableBody", unavailable))
            methods.append(
                _u2(flags & 0x1DFF)
                + _u2(cp.utf8(name))
                + _u2(cp.utf8(desc))
                + _u2(len(attrs))
                + b"".join(attrs)
            )
        attributes = [self._attribute(key, data) for key, data in self.attributes]
        tail = (
            header
            + _u2(len(fields))
            + b"".join(fields)
            + _u2(len(methods))
            + b"".join(methods)
            + _u2(len(attributes))
            + b"".join(attributes)
        )
        return b"\xca\xfe\xba\xbe\x00\x00\x00\x31" + cp.bytes() + tail


_INTS = frozenset("ZBCSI")
_PRIMITIVES = dict(
    zip(
        ("void", "boolean", "byte", "char", "short", "int", "long", "float", "double"),
        "VZBCSIJFD",
    )
)
_BIT_CONVERSIONS = {
    ("java/lang/Float", "intBitsToFloat"): "(I)F",
    ("java/lang/Float", "floatToRawIntBits"): "(F)I",
    ("java/lang/Double", "longBitsToDouble"): "(J)D",
    ("java/lang/Double", "doubleToRawLongBits"): "(D)J",
}
_RAW_BITS = {
    "java/lang/Float": ("floatToRawIntBits", "(F)I"),
    "java/lang/Double": ("doubleToRawLongBits", "(D)J"),
}
# Trusted ROM code reads these Class words directly and writes Throwable's
# message after allocating the exception. The JVM enforces member access.
_STATIC_INIT = ("com/jbed/runtime/Base", "staticInit", "(Ljava/lang/Class;)V")
_ARRAYSTORE = ("com/jbed/runtime/Base", "arraystore", "([Ljava/lang/Object;ILjava/lang/Object;)V")
_RAISE_EXCEPTION = ("com/jbed/runtime/Jbni", "raiseExceptionClassString", "(Ljava/lang/Class;Ljava/lang/String;)V")
_VM_FIELD_ACCESS = {
    ("java/lang/Class", "base", "Ljava/lang/Class;", False): (_STATIC_INIT, _ARRAYSTORE),
    ("java/lang/Class", "modifiers", "I", False): (_STATIC_INIT,),
    ("java/lang/Class", "initializer", "I", False): (_STATIC_INIT,),
    ("java/lang/Throwable", "detailMessage", "Ljava/lang/String;", True): (_RAISE_EXCEPTION,),
}


def _accessor(field_name: str, descriptor: str, store: bool) -> tuple[str, str]:
    if store:
        return "__jbed$set$" + field_name, "(" + descriptor + ")V"
    return "__jbed$get$" + field_name, "()" + descriptor


# Coder.Generate/FloatOp/DoubleOp select one ROM entry per JVM compare.
_COMPARE_OPCODES = {
    ("com/jbed/runtime/Long", "comp", "(JJ)I"): 0x94,
    ("com/jbed/runtime/Float", "compl", "(FF)I"): 0x95,
    ("com/jbed/runtime/Float", "compg", "(FF)I"): 0x96,
    ("com/jbed/runtime/Double", "compl", "(DD)I"): 0x97,
    ("com/jbed/runtime/Double", "compg", "(DD)I"): 0x98,
}


class _ImageIndex:
    def __init__(self, image: RomImage):
        self.by_name = image.by_name
        self.global_static_base = min((f.offset for f in image.fields if f.storage == "static"), default=0)
        self.class_names = {mapped_name(name): name for name in image.by_name}
        self.class_names.update({mapped_name(name): name for name in image.unresolved_types.values()})
        self.class_names.update(
            {name.replace("/", "."): name for name in image.by_name}
        )
        self.fields: dict[tuple[str, str, bool], list[FieldSpec]] = {}
        self.methods: dict[tuple[str, str, bool], list[MethodSpec]] = {}
        self.ancestor_cache: dict[str, tuple[ClassSpec, ...]] = {}
        for klass in image.by_name.values():
            for member in klass.fields:
                key = (klass.name, java_identifier(member.name), member.is_static)
                self.fields.setdefault(key, []).append(member)
            for method in klass.methods:
                if method.descriptor:
                    key = (klass.name, java_identifier(method.name), method.is_static)
                    self.methods.setdefault(key, []).append(method)

    def ancestors(self, owner: str) -> tuple[ClassSpec, ...]:
        cached = self.ancestor_cache.get(owner)
        if cached is None:
            pending, seen, result = [owner], set(), []
            while pending:
                name = pending.pop(0)
                if name in seen:
                    continue
                seen.add(name)
                klass = self.by_name.get(name)
                if klass is None:
                    continue
                result.append(klass)
                if klass.superclass:
                    pending.append(klass.superclass)
                pending.extend(klass.interfaces)
            cached = self.ancestor_cache[owner] = tuple(result)
        return cached


_IMAGE_INDEX: WeakKeyDictionary[RomImage, _ImageIndex] = WeakKeyDictionary()


def _image_index(image: RomImage) -> _ImageIndex:
    index = _IMAGE_INDEX.get(image)
    if index is None:
        index = _IMAGE_INDEX[image] = _ImageIndex(image)
    return index


def _binary_name(name: str, remap: Mapping[str, str] | None = None) -> str:
    # JVM names retain original Unicode/keywords; Java escaping belongs only to
    # the expression spelling accepted from the lifter and source rendering.
    for old, new in sorted((remap or {}).items(), key=lambda item: -len(item[0])):
        if name == old or old.endswith("/") and name.startswith(old):
            return new + name[len(old) :]
    return name


def is_bootstrap_bitcast(
    image: RomImage, method: MethodSpec, remap: Mapping[str, str] | None = None
) -> bool:
    # Int/float share r0, long/double share r0:r1. The ROM implements these
    # two bitcasts by returning unchanged. JVM verification distinguishes the
    # types, so their bootstrap definitions need the VM's native bitcasts.
    if method.size != 2 or not method.is_static or method.descriptor not in ("(I)F", "(J)D"):
        return False
    return (
        _BIT_CONVERSIONS.get((method.owner, method.name)) == method.descriptor
        and _binary_name(method.owner, remap) == method.owner
        and image.data[method.address:method.address + 2] in (b"\xf7\x46", b"\x70\x47")
    )


def _slots(descriptor: str) -> int:
    return 0 if descriptor == "V" else 2 if descriptor in ("J", "D") else 1


def _reference(descriptor: str) -> bool:
    return descriptor == "null" or descriptor.startswith(("L", "["))


def _category(descriptor: str) -> str:
    return "I" if descriptor in _INTS else "A" if _reference(descriptor) else descriptor


_INVERSE_BRANCH = {
    opcode: inverse
    for pair in ((0x99, 0x9A), (0x9B, 0x9C), (0x9D, 0x9E),
                 (0x9F, 0xA0), (0xA1, 0xA2), (0xA3, 0xA4),
                 (0xA5, 0xA6), (0xC6, 0xC7))
    for opcode, inverse in (pair, pair[::-1])
}

# Array accesses, integer division/remainder, field and method references,
# allocation, explicit traps, type checks, and monitor instructions.
_THROWING_OPCODES = frozenset((*range(0x2E, 0x36), *range(0x4F, 0x57),
                              0x6C, 0x6D, 0x70, 0x71, *range(0xB2, 0xBA),
                              *range(0xBB, 0xC4), 0xC5))


class _DistantBranches(Exception):
    def __init__(self, indices):
        self.indices = indices


class _Assembler:
    def __init__(self, wide_branches: set[int] | None = None):
        self.data = bytearray()
        self.labels: dict[object, int] = {}
        self.fixups: list[tuple[int, object, int]] = []
        self.wide_branches = wide_branches
        self.table_fixups: list[tuple[int, int, object]] = []
        self.heights: dict[object, int] = {}
        self.height = self.maximum = 0
        self.reachable = True
        self.serial = 0
        self.throw_sites: list[tuple[int, int]] = []

    def fresh(self):
        self.serial += 1
        return ("internal", self.serial)

    def emit(self, opcode: int, operands: bytes = b"", *, pop: int = 0, push: int = 0,
             can_throw: bool = True):
        if self.height < pop:
            raise UnsupportedBytecode("bytecode operand-stack underflow")
        self.height += push - pop
        self.maximum = max(self.maximum, self.height)
        start = len(self.data)
        self.data.append(opcode)
        self.data.extend(operands)
        if can_throw and opcode in _THROWING_OPCODES:
            self.throw_sites.append((start, len(self.data)))

    def target(self, label, height: int):
        old = self.heights.setdefault(label, height)
        if old != height:
            raise UnsupportedBytecode(f"inconsistent stack at label {label}")

    def mark(self, label, height: int = 0):
        if label in self.labels:
            raise UnsupportedBytecode(f"duplicate bytecode label {label}")
        self.target(label, height)
        if self.reachable and self.height != height:
            raise UnsupportedBytecode(f"fallthrough stack mismatch at {label}")
        self.labels[label] = len(self.data)
        self.height, self.reachable = height, True
        self.maximum = max(self.maximum, height)

    def _offset(self, opcode, label, width, pop=0):
        self.fixups.append((len(self.data), label, width))
        self.emit(opcode, bytes(width), pop=pop)
        self.target(label, self.height)

    def jump(self, label):
        if self.wide_branches is None or len(self.fixups) in self.wide_branches:
            self._offset(0xC8, label, 4)
        else:
            self._offset(0xA7, label, 2)
        self.reachable = False

    def branch(self, opcode: int, label, pop: int):
        if self.wide_branches is None or len(self.fixups) in self.wide_branches:
            self.emit(_INVERSE_BRANCH[opcode], _u2(8), pop=pop)
            self._offset(0xC8, label, 4)
        else:
            self._offset(opcode, label, 2, pop)

    def switch(self, cases: Sequence[tuple[int, int]], default):
        entries = dict(cases)
        if len(entries) != len(cases):
            raise UnsupportedBytecode("duplicate JVM switch key")
        ordered = sorted(entries)
        dense = bool(ordered) and ordered[-1] - ordered[0] + 1 <= 2 * len(ordered)
        base = len(self.data)
        self.emit(0xAA if dense else 0xAB, b"\0" * ((-base - 1) & 3), pop=1)

        def destination(label):
            self.target(label, self.height)
            self.table_fixups.append((base, len(self.data), label))
            self.data.extend(b"\0" * 4)

        destination(default)
        if dense:
            self.data.extend(struct.pack(">ii", ordered[0], ordered[-1]))
            for value in range(ordered[0], ordered[-1] + 1):
                destination(entries.get(value, default))
        else:
            self.data.extend(_u4(len(ordered)))
            for value in ordered:
                self.data.extend(struct.pack(">i", value))
                destination(entries[value])
        self.reachable = False

    def finish(self) -> bytes:
        distant = set()
        for index, (site, label, width) in enumerate(self.fixups):
            if label not in self.labels:
                raise UnsupportedBytecode(f"missing bytecode target {label}")
            offset = self.labels[label] - site
            if width == 2 and not -32768 <= offset <= 32767:
                distant.add(index)
            else:
                self.data[site + 1 : site + 1 + width] = offset.to_bytes(width, "big", signed=True)
        if distant:
            raise _DistantBranches(distant)
        for base, site, label in self.table_fixups:
            if label not in self.labels:
                raise UnsupportedBytecode(f"missing switch target {label}")
            self.data[site : site + 4] = struct.pack(">i", self.labels[label] - base)
        return bytes(self.data)


class _MethodCompiler:
    def __init__(
        self,
        image: RomImage,
        method: MethodSpec,
        body: LiftedBody,
        pool: ConstantPool,
        remap: Mapping[str, str] | None,
        wide_branches: set[int],
        runtime_layout: bool = False,
    ):
        self.image, self.method, self.body, self.cp = image, method, body, pool
        self.remap, self.asm = remap, _Assembler(wide_branches)
        self.runtime_layout = runtime_layout
        self.index = _image_index(image)
        self.classes = self.index.class_names
        self.types: dict[str, str] = {}
        self.locals: dict[str, tuple[str, int]] = {}
        self.next_local = 0
        self.empty_arrays: dict[str, str] = {}
        self.initializes_this = method.owner == "java/lang/Object"
        if not method.is_static:
            self.add_local("this", "L" + method.owner + ";")
        for name, typ in zip(method.parameter_names, method.argument_types):
            self.add_local(name, typ)
        for name, typ in body.cfg.locals.items():
            self.add_local(name, self.descriptor(typ))

    def binary_name(self, name: str) -> str:
        return _binary_name(name, self.remap)

    def map_descriptor(self, desc: str) -> str:
        return re.sub(
            r"L([^;]+);", lambda match: "L" + self.binary_name(match[1]) + ";", desc
        )

    def descriptor(self, typ: str) -> str:
        if typ.endswith("[]"):
            return "[" + self.descriptor(typ[:-2])
        if typ in _PRIMITIVES:
            return _PRIMITIVES[typ]
        if typ in ("Object", "String", "Class", "Throwable"):
            return "Ljava/lang/" + typ + ";"
        if typ in self.classes:
            return "L" + self.classes[typ] + ";"
        if "java.lang." + typ in self.classes:
            return "L" + self.classes["java.lang." + typ] + ";"
        raise UnsupportedBytecode(f"unresolved Java type {typ}")

    def add_local(self, name: str, descriptor: str):
        if name in self.locals:
            if self.locals[name][0] != descriptor:
                raise UnsupportedBytecode(f"inconsistent local type {name}")
            return
        self.locals[name] = (descriptor, self.next_local)
        self.types[name] = java_type(descriptor)
        self.next_local += _slots(descriptor)
        _u2(self.next_local)

    def local(self, name: str, store: bool = False):
        if name not in self.locals:
            raise UnsupportedBytecode(f"unknown local {name}")
        typ, slot = self.locals[name]
        index = {"I": 0, "J": 1, "F": 2, "D": 3, "A": 4}[_category(typ)]
        opcode = (0x36 if store else 0x15) + index
        if slot < 256:
            self.asm.emit(
                opcode,
                bytes((slot,)),
                pop=_slots(typ) if store else 0,
                push=0 if store else _slots(typ),
            )
        else:
            self.asm.emit(
                0xC4,
                bytes((opcode,)) + _u2(slot),
                pop=_slots(typ) if store else 0,
                push=0 if store else _slots(typ),
            )
        return typ

    def parse(self, text: str) -> _Expr:
        try:
            return _Parser(text, self.types).parse()
        except _ParseError as error:
            raise UnsupportedBytecode(
                f"unsupported lifted expression {text}: {error}"
            ) from error

    @staticmethod
    def qualified(expr: _Expr) -> str | None:
        if expr.kind == "name":
            return expr.value
        if expr.kind == "member":
            base = _MethodCompiler.qualified(expr.children[0])
            if base:
                return base + "." + expr.value
        return None

    def class_expression(self, expr: _Expr) -> str | None:
        name = self.qualified(expr)
        if name and name.split(".")[0] not in self.locals:
            return self.classes.get(name)
        return None

    def superclass(self) -> str:
        klass = self.image.by_name[self.method.owner]
        if self.method.is_static or not klass.superclass:
            raise UnsupportedBytecode("super receiver requires an instance superclass")
        return klass.superclass

    def ancestors(self, owner: str):
        return self.index.ancestors(owner)

    def field(self, expr: _Expr):
        receiver = expr.children[0]
        owner = self.class_expression(receiver)
        static = owner is not None
        if not static:
            typ = self.type(receiver)
            if not typ.startswith("L"):
                raise UnsupportedBytecode(f"field {expr.value} on {typ}")
            owner = typ[1:-1]
        for klass in self.ancestors(owner):
            matches = self.index.fields.get((klass.name, expr.value, static), ())
            if matches:
                if len(matches) != 1 or not matches[0].descriptor:
                    raise UnsupportedBytecode(f"ambiguous field {owner}.{expr.value}")
                return matches[0], None if static else receiver
        raise UnsupportedBytecode(f"unresolved field {owner}.{expr.value}")

    def emit_field(self, member: FieldSpec, *, store: bool = False):
        owner = self.binary_name(member.owner)
        descriptor = self.map_descriptor(member.descriptor)
        sites = _VM_FIELD_ACCESS.get((member.owner, member.name, member.descriptor, store), ())
        if not self.runtime_layout and (self.method.owner, self.method.name, self.method.descriptor) in sites:
            opcode = 0xB6
            reference = self.cp.method(owner, *_accessor(member.name, descriptor, store))
        else:
            opcode = (0xB2 if member.is_static else 0xB4) + int(store)
            reference = self.cp.field(owner, member.name, descriptor)
        slots = _slots(descriptor)
        self.asm.emit(opcode, _u2(reference), pop=int(not member.is_static) + (slots if store else 0),
                      push=0 if store else slots)

    def assignable(self, source: str, target: str) -> bool:
        if source == target or source in _INTS and target in _INTS:
            return True
        if source == "null" and _reference(target):
            return True
        if _reference(source) and target == "Ljava/lang/Object;":
            return True
        if source.startswith("[") and target.startswith("["):
            return (
                source == target
                or _reference(source[1:])
                and _reference(target[1:])
                and self.assignable(source[1:], target[1:])
            )
        if source.startswith("L") and target.startswith("L"):
            return any(k.name == target[1:-1] for k in self.ancestors(source[1:-1]))
        return False

    def resolve_call(self, expr: _Expr):
        callee, args = expr.children[0], expr.children[1:]
        if callee.kind != "member":
            raise UnsupportedBytecode(
                "unqualified/constructor-chain call needs an explicit invocation kind"
            )
        receiver = callee.children[0]
        owner = self.class_expression(receiver)
        static = owner is not None
        if not static:
            typ = self.type(receiver)
            if typ.startswith("[") and callee.value == "getClass":
                owner = "java/lang/Object"
            elif typ.startswith("L"):
                owner = typ[1:-1]
            else:
                raise UnsupportedBytecode(f"method receiver has type {typ}")
        types = tuple(self.type(arg) for arg in args)
        intrinsic = _BIT_CONVERSIONS.get((owner, callee.value)) if static else None
        if intrinsic and split_method_descriptor(intrinsic)[0] == types:
            return MethodSpec(owner, callee.value, intrinsic, 0, 0, True, 9), None, args
        candidates = []
        seen = set()
        for klass in self.ancestors(owner):
            for method in self.index.methods.get(
                (klass.name, callee.value, static), ()
            ):
                if method.descriptor in seen:
                    continue
                seen.add(method.descriptor)
                if len(method.argument_types) == len(types) and all(
                    self.assignable(a, b) for a, b in zip(types, method.argument_types)
                ):
                    candidates.append(method)
        exact = [m for m in candidates if m.argument_types == types]
        if len(exact) == 1:
            candidates = exact
        if len(candidates) != 1:
            raise UnsupportedBytecode(
                f"ambiguous/unresolved call {owner}.{callee.value}{types}"
            )
        return candidates[0], None if static else receiver, args

    def intrinsic(self, expr: _Expr):
        if expr.kind != "call" or expr.children[0].kind != "name":
            return None
        name = expr.children[0].value
        if name not in (
            "__jbed_new",
            "__jbed_init",
            "__jbed_new_array",
            "__jbed_new_array_n",
            "__jbed_ensure_initialized",
            "__jbed_monitor_enter",
            "__jbed_monitor_enter_nonnull",
            "__jbed_monitor_exit",
            "__jbed_invoke_special",
        ):
            return None
        args = expr.children[1:]
        if name == "__jbed_invoke_special":
            if len(args) < 4 or any(
                arg.kind != "literal" or not arg.value.startswith('"')
                for arg in args[:3]
            ):
                raise UnsupportedBytecode("invalid special-invocation intrinsic")
            owner, member, descriptor = (json.loads(arg.value) for arg in args[:3])
            parameters, _ = split_method_descriptor(descriptor)
            if len(args) - 4 != len(parameters) or member in ("<init>", "<clinit>"):
                raise UnsupportedBytecode("special-invocation signature mismatch")
            if not self.assignable(self.type(args[3]), "L" + self.method.owner + ";"):
                raise UnsupportedBytecode(
                    "special-invocation receiver is not the current class"
                )
            if not any(
                m.name == member and m.descriptor == descriptor and not m.is_static
                for m in self.image.by_name[owner].methods
            ):
                raise UnsupportedBytecode("unresolved special-invocation target")
            return name, owner, (member, descriptor), args[3:]
        if name in ("__jbed_monitor_enter", "__jbed_monitor_enter_nonnull", "__jbed_monitor_exit"):
            if len(args) != 1 or not _reference(self.type(args[0])):
                raise UnsupportedBytecode("monitor intrinsic requires one reference")
            return name, "", None, args
        if name in ("__jbed_new_array", "__jbed_new_array_n"):
            if (
                len(args) != (2 if name == "__jbed_new_array" else 3)
                or args[0].kind != "literal"
            ):
                raise UnsupportedBytecode("invalid array intrinsic")
            descriptor = json.loads(args[0].value)
            if not descriptor.startswith("["):
                raise UnsupportedBytecode("array intrinsic needs array descriptor")
            return name, descriptor, None, args[1:]
        required = 1 if name in ("__jbed_new", "__jbed_ensure_initialized") else 3
        if (
            len(args) < required
            or args[0].kind != "literal"
            or not args[0].value.startswith('"')
        ):
            raise UnsupportedBytecode("invalid allocation intrinsic owner")
        owner = json.loads(args[0].value)
        if owner not in self.image.by_name:
            raise UnsupportedBytecode(f"unknown allocation class {owner}")
        if name in ("__jbed_new", "__jbed_ensure_initialized"):
            if len(args) != 1:
                raise UnsupportedBytecode("invalid allocation intrinsic operands")
            return name, owner, None, ()
        if args[1].kind != "literal" or not args[1].value.startswith('"'):
            raise UnsupportedBytecode("invalid constructor intrinsic descriptor")
        descriptor = json.loads(args[1].value)
        parameters, result = split_method_descriptor(descriptor)
        if result != "V" or len(args) - 3 != len(parameters):
            raise UnsupportedBytecode("constructor intrinsic signature mismatch")
        if args[2].kind != "name" or args[2].value not in self.locals:
            raise UnsupportedBytecode("constructor receiver must be an uncast local")
        return name, owner, descriptor, args[2:]

    def type(self, expr: _Expr) -> str:
        kind, value, children = expr.kind, expr.value, expr.children
        if kind == "name":
            if value == "super":
                return "L" + self.superclass() + ";"
            if value not in self.locals:
                raise UnsupportedBytecode(f"unknown value {value}")
            return self.locals[value][0]
        if kind == "literal":
            if value == "null":
                return "null"
            if value in ("true", "false"):
                return "Z"
            if value.startswith('"'):
                return "Ljava/lang/String;"
            if value.startswith("'"):
                return "C"
            return "J" if value[-1:] in "lL" else "I"
        if kind == "cast":
            return self.descriptor(value)
        if kind == "class_literal":
            return "Ljava/lang/Class;"
        if kind == "index":
            typ = self.type(children[0])
            if not typ.startswith("["):
                raise UnsupportedBytecode("indexing nonarray value")
            return typ[1:]
        if kind == "member":
            if value == "class" and self.class_expression(children[0]) is not None:
                return "Ljava/lang/Class;"
            if (
                value == "length"
                and self.class_expression(children[0]) is None
                and self.type(children[0]).startswith("[")
            ):
                return "I"
            return self.field(expr)[0].descriptor
        if kind == "call":
            intrinsic = self.intrinsic(expr)
            if intrinsic:
                if intrinsic[0] == "__jbed_invoke_special":
                    return split_method_descriptor(intrinsic[2][1])[1]
                if intrinsic[0] == "__jbed_new":
                    return "L" + intrinsic[1] + ";"
                if intrinsic[0] in ("__jbed_new_array", "__jbed_new_array_n"):
                    return intrinsic[1]
                return "V"
            return self.resolve_call(expr)[0].return_type
        if kind == "new":
            return self.descriptor(value)
        if kind == "new_array":
            return "[" * len(children) + self.descriptor(value)
        if kind == "instanceof":
            return "Z"
        if kind == "unary":
            return "Z" if value == "!" else self.promote(self.type(children[0]))
        if kind == "binary":
            if value in ("==", "!=", "<", ">", "<=", ">=", "&&", "||"):
                return "Z"
            left, right = self.type(children[0]), self.type(children[1])
            if value in ("<<", ">>", ">>>"):
                return self.promote(left)
            if left == right == "Z" and value in ("&", "|", "^"):
                return "Z"
            return self.promote(left, right)
        if kind == "conditional":
            left, right = self.type(children[1]), self.type(children[2])
            if self.assignable(left, right):
                return right
            if self.assignable(right, left):
                return left
            return self.promote(left, right)
        raise UnsupportedBytecode(f"unsupported AST node {kind}")

    @staticmethod
    def promote(*types: str) -> str:
        if any(t not in _INTS and t not in ("J", "F", "D") for t in types):
            raise UnsupportedBytecode(f"nonnumeric operation on {types}")
        return next((t for t in ("D", "F", "J") if t in types), "I")

    def convert(self, source: str, target: str, *, explicit: bool = False):
        if source == target or source == "null" and _reference(target):
            return
        a, b = _category(source), _category(target)
        if a == b == "A":
            if explicit:
                name = (
                    target[1:-1]
                    if target.startswith("L")
                    else self.map_descriptor(target)
                )
                if target.startswith("L"):
                    name = self.binary_name(name)
                self.asm.emit(0xC0, _u2(self.cp.class_(name)), pop=1, push=1)
            elif not self.assignable(source, target):
                raise UnsupportedBytecode(
                    f"missing explicit reference cast {source} to {target}"
                )
            return
        conversions = {
            ("I", "J"): 0x85,
            ("I", "F"): 0x86,
            ("I", "D"): 0x87,
            ("J", "I"): 0x88,
            ("J", "F"): 0x89,
            ("J", "D"): 0x8A,
            ("F", "I"): 0x8B,
            ("F", "J"): 0x8C,
            ("F", "D"): 0x8D,
            ("D", "I"): 0x8E,
            ("D", "J"): 0x8F,
            ("D", "F"): 0x90,
        }
        if a != b:
            if (a, b) not in conversions:
                raise UnsupportedBytecode(f"invalid conversion {source} to {target}")
            self.asm.emit(conversions[a, b], pop=_slots(source), push=_slots(target))
        if explicit and target in ("B", "C", "S"):
            self.asm.emit({"B": 0x91, "C": 0x92, "S": 0x93}[target], pop=1, push=1)

    def integer(self, value: int, wide: bool = False):
        if wide:
            if value in (0, 1):
                self.asm.emit(0x09 + value, push=2)
            else:
                self.asm.emit(0x14, _u2(self.cp.long(value)), push=2)
        else:
            value = ((value + 0x80000000) & 0xFFFFFFFF) - 0x80000000
            if -1 <= value <= 5:
                self.asm.emit(0x03 + value, push=1)
            elif -128 <= value <= 127:
                self.asm.emit(0x10, bytes((value & 255,)), push=1)
            elif -32768 <= value <= 32767:
                self.asm.emit(0x11, struct.pack(">h", value), push=1)
            else:
                self.asm.emit(0x13, _u2(self.cp.integer(value)), push=1)

    @staticmethod
    def integer_literal(expr: _Expr) -> int | None:
        if expr.kind == "unary" and expr.value in ("+", "-"):
            value = _MethodCompiler.integer_literal(expr.children[0])
            return None if value is None else -value if expr.value == "-" else value
        if expr.kind == "literal":
            value = expr.value.rstrip("lL")
            try:
                return int(value, 16 if value.lower().startswith("0x") else 10)
            except ValueError:
                pass
        return None

    def allocate_array(self, descriptor: str, dimensions: Sequence[_Expr]):
        if (
            not dimensions
            or len(dimensions) > 255
            or len(dimensions) > len(descriptor) - len(descriptor.lstrip("["))
        ):
            raise UnsupportedBytecode("invalid allocated array dimensions")
        for dimension in dimensions:
            self.expression(dimension, "I")
        if len(dimensions) > 1:
            self.asm.emit(
                0xC5,
                _u2(self.cp.class_(self.map_descriptor(descriptor)))
                + bytes((len(dimensions),)),
                pop=len(dimensions),
                push=1,
            )
        else:
            component = descriptor[1:]
            if component in "ZCFDBSIJ" and len(component) == 1:
                self.asm.emit(
                    0xBC,
                    bytes(
                        (
                            {
                                "Z": 4,
                                "C": 5,
                                "F": 6,
                                "D": 7,
                                "B": 8,
                                "S": 9,
                                "I": 10,
                                "J": 11,
                            }[component],
                        )
                    ),
                    pop=1,
                    push=1,
                )
            else:
                name = (
                    self.binary_name(component[1:-1])
                    if component.startswith("L")
                    else self.map_descriptor(component)
                )
                self.asm.emit(0xBD, _u2(self.cp.class_(name)), pop=1, push=1)

    @staticmethod
    def uncast(expr: _Expr) -> _Expr:
        while expr.kind == "cast":
            expr = expr.children[0]
        return expr

    def empty_array(self, expr: _Expr) -> str | None:
        expr = self.uncast(expr)
        if expr.kind == "name":
            return self.empty_arrays.get(expr.value)
        intrinsic = self.intrinsic(expr)
        return (
            intrinsic[1]
            if (
                intrinsic
                and intrinsic[0] == "__jbed_new_array"
                and intrinsic[3][0].kind == "literal"
                and intrinsic[3][0].value == "0"
            )
            else None
        )

    def allocate_template_array(self, descriptor: str, args: Sequence[_Expr]):
        component = descriptor[1:]
        primitive_leaf = (
            len(component) == 2 and component[0] == "[" and component[1] in "ZBCSIJFD"
        )
        if not primitive_leaf and self.empty_array(args[1]) != component:
            raise UnsupportedBytecode(
                "template shape cloning requires primitive or proven empty leaf array"
            )
        if not component.startswith("["):
            raise UnsupportedBytecode("template allocation requires an array component")
        height = self.asm.height

        def temporary(typ: str) -> str:
            name = f"__jbed_array_{self.next_local}"
            while name in self.locals:
                name += "_"
            self.add_local(name, typ)
            return name

        count, template, result, index = (
            temporary("I"),
            temporary(component),
            temporary(descriptor),
            temporary("I"),
        )
        self.expression(args[0], "I")
        self.local(count, True)
        self.expression(args[1], component)
        self.local(template, True)
        self.allocate_array(descriptor, (_Expr("name", count),))
        self.local(result, True)
        loop, end = self.asm.fresh(), self.asm.fresh()
        self.local(count)
        self.integer(0)
        self.asm.branch(0xA4, end, 2)
        self.local(result)
        self.integer(0)
        self.local(template)
        self.asm.emit(0x53, pop=3)
        self.integer(1)
        self.local(index, True)
        self.asm.mark(loop, height)
        self.local(index)
        self.local(count)
        self.asm.branch(0xA2, end, 2)
        self.local(result)
        self.local(index)
        self.allocate_array(
            component, (_Expr("member", "length", (_Expr("name", template),)),)
        )
        self.asm.emit(0x53, pop=3)
        self.local(index)
        self.integer(1)
        self.asm.emit(0x60, pop=2, push=1)
        self.local(index, True)
        self.asm.jump(loop)
        self.asm.mark(end, height)
        self.local(result)

    def expression(self, expr: _Expr, expected: str | None = None) -> str:
        typ = self.type(expr)
        kind, value, children = expr.kind, expr.value, expr.children
        if kind == "name":
            self.local("this" if value == "super" else value)
        elif kind == "literal":
            if value == "null":
                self.asm.emit(0x01, push=1)
            elif value in ("true", "false"):
                self.integer(int(value == "true"))
            elif value.startswith('"'):
                self.asm.emit(0x13, _u2(self.cp.string(json.loads(value))), push=1)
            elif value.startswith("'"):
                decoded = json.loads(
                    '"' + value[1:-1].replace('"', '\\"').replace("\\'", "'") + '"'
                )
                if len(decoded) != 1:
                    raise UnsupportedBytecode("invalid character literal")
                self.integer(ord(decoded))
            else:
                self.integer(
                    int(
                        value.rstrip("lL"), 16 if value.lower().startswith("0x") else 10
                    ),
                    typ == "J",
                )
        elif kind == "cast":
            source = self.expression(children[0])
            self.convert(source, typ, explicit=True)
        elif kind == "class_literal":
            target = self.descriptor(value)
            if target in "VZBCSIJFD" and len(target) == 1:
                wrapper = {
                    "V": "Void",
                    "Z": "Boolean",
                    "B": "Byte",
                    "C": "Character",
                    "S": "Short",
                    "I": "Integer",
                    "J": "Long",
                    "F": "Float",
                    "D": "Double",
                }[target]
                self.asm.emit(
                    0xB2,
                    _u2(
                        self.cp.field(
                            "java/lang/" + wrapper, "TYPE", "Ljava/lang/Class;"
                        )
                    ),
                    push=1,
                )
            else:
                name = (
                    self.binary_name(target[1:-1])
                    if target.startswith("L")
                    else self.map_descriptor(target)
                )
                self.asm.emit(0x13, _u2(self.cp.class_(name)), push=1)
        elif kind == "index":
            self.expression(children[0])
            self.expression(children[1], "I")
            opcode = {
                "I": 0x2E,
                "J": 0x2F,
                "F": 0x30,
                "D": 0x31,
                "Z": 0x33,
                "B": 0x33,
                "C": 0x34,
                "S": 0x35,
            }.get(typ, 0x32)
            self.asm.emit(opcode, pop=2, push=_slots(typ))
        elif kind == "member":
            if value == "class" and self.class_expression(children[0]) is not None:
                self.asm.emit(
                    0x13,
                    _u2(
                        self.cp.class_(
                            self.binary_name(self.class_expression(children[0]))
                        )
                    ),
                    push=1,
                )
            elif (
                value == "length"
                and self.class_expression(children[0]) is None
                and self.type(children[0]).startswith("[")
            ):
                self.expression(children[0])
                self.asm.emit(0xBE, pop=1, push=1)
            else:
                member, receiver = self.field(expr)
                if receiver is not None:
                    self.expression(receiver)
                self.emit_field(member)
        elif kind == "call":
            intrinsic = self.intrinsic(expr)
            if intrinsic:
                operation, owner, descriptor, args = intrinsic
                if operation == "__jbed_new":
                    self.asm.emit(
                        0xBB, _u2(self.cp.class_(self.binary_name(owner))), push=1
                    )
                elif operation == "__jbed_new_array":
                    self.allocate_array(owner, args)
                elif operation == "__jbed_new_array_n":
                    self.allocate_template_array(owner, args)
                elif operation == "__jbed_invoke_special":
                    member, signature = descriptor
                    parameters, result = split_method_descriptor(signature)
                    self.expression(args[0])
                    for argument, parameter in zip(args[1:], parameters):
                        self.expression(argument, parameter)
                    self.asm.emit(
                        0xB7,
                        _u2(
                            self.cp.method(
                                self.binary_name(owner),
                                member,
                                self.map_descriptor(signature),
                            )
                        ),
                        pop=1 + sum(_slots(t) for t in parameters),
                        push=_slots(result),
                    )
                elif operation == "__jbed_ensure_initialized":
                    if self.runtime_layout:
                        self.asm.emit(0x13, _u2(self.cp.class_(self.binary_name(owner))), push=1)
                        self.asm.emit(0xB8, _u2(self.cp.method(
                            self.binary_name(_STATIC_INIT[0]), _STATIC_INIT[1],
                            self.map_descriptor(_STATIC_INIT[2]))), pop=1)
                    else:
                        self.asm.emit(
                            0xB2,
                            _u2(self.cp.field(self.binary_name(owner), "__jbed$initTrigger", "Z")),
                            push=1,
                        )
                        self.asm.emit(0x57, pop=1)
                elif operation in ("__jbed_monitor_enter", "__jbed_monitor_enter_nonnull", "__jbed_monitor_exit"):
                    self.expression(args[0])
                    # FCoder may have emitted the null trap before the protected
                    # region. A proven non-null JVM monitorenter cannot take it
                    # again and must not feed the acquired-lock cleanup handler.
                    self.asm.emit(0xC3 if operation == "__jbed_monitor_exit" else 0xC2, pop=1,
                                  can_throw=operation != "__jbed_monitor_enter_nonnull")
                else:
                    parameters, _ = split_method_descriptor(descriptor)
                    self.local(args[0].value)
                    for argument, parameter in zip(args[1:], parameters):
                        self.expression(argument, parameter)
                    self.asm.emit(
                        0xB7,
                        _u2(
                            self.cp.method(
                                self.binary_name(owner),
                                "<init>",
                                self.map_descriptor(descriptor),
                            )
                        ),
                        pop=1 + sum(_slots(t) for t in parameters),
                    )
                    if args[0].value == "this":
                        self.initializes_this = True
            else:
                method, receiver, args = self.resolve_call(expr)
                if receiver is None and (method.owner, method.name) in (
                    ("java/lang/Float", "intBitsToFloat"),
                    ("java/lang/Double", "longBitsToDouble"),
                ):
                    bits = self.integer_literal(args[0])
                    if bits is not None:
                        constant = (
                            self.cp.float_bits(bits)
                            if typ == "F"
                            else self.cp.double_bits(bits)
                        )
                        self.asm.emit(
                            0x13 if typ == "F" else 0x14,
                            _u2(constant),
                            push=_slots(typ),
                        )
                        if expected is not None:
                            self.convert(typ, expected)
                            return expected
                        return typ
                if receiver is not None:
                    self.expression(receiver)
                for arg, parameter in zip(args, method.argument_types):
                    self.expression(arg, parameter)
                compare = _COMPARE_OPCODES.get((method.owner, method.name, method.descriptor))
                if receiver is None and compare is not None:
                    self.asm.emit(compare, pop=2 * _slots(method.argument_types[0]), push=1)
                    if expected is not None:
                        self.convert("I", expected)
                        return expected
                    return "I"
                interface = bool(self.image.by_name[method.owner].flags & 0x200)
                opcode = (
                    0xB8
                    if receiver is None
                    else 0xB7
                    if method.flags & 2
                    or receiver.kind == "name"
                    and receiver.value == "super"
                    else 0xB9
                    if interface
                    else 0xB6
                )
                count = sum(_slots(t) for t in method.argument_types) + (
                    receiver is not None
                )
                target = self.binary_name(method.owner)
                if method.address == 0 and (method.owner, method.name) in _BIT_CONVERSIONS:
                    # Remapped classes can delegate these primitive operations
                    # to the host JVM's bootstrap classes.
                    target = method.owner
                    if (target, method.name, method.descriptor) == (
                        self.binary_name(self.method.owner), self.method.name, self.method.descriptor
                    ):
                        raise UnsupportedBytecode("a bootstrap bitcast cannot implement itself")
                operands = _u2(self.cp.method(
                    target, method.name, self.map_descriptor(method.descriptor), interface
                ))
                if opcode == 0xB9:
                    if count > 255:
                        raise UnsupportedBytecode("invokeinterface argument overflow")
                    operands += bytes((count, 0))
                self.asm.emit(opcode, operands, pop=count, push=_slots(typ))
        elif kind == "new_array":
            self.allocate_array(typ, children)
        elif kind == "instanceof":
            self.expression(children[0])
            target = self.descriptor(value)
            if not _reference(target):
                raise UnsupportedBytecode("instanceof requires reference type")
            name = (
                self.binary_name(target[1:-1])
                if target.startswith("L")
                else self.map_descriptor(target)
            )
            self.asm.emit(0xC1, _u2(self.cp.class_(name)), pop=1, push=1)
        elif kind == "new":
            owner = typ[1:-1]
            types = tuple(self.type(arg) for arg in children)
            matches = [
                m
                for m in self.image.by_name[owner].methods
                if m.is_constructor
                and m.descriptor
                and len(m.argument_types) == len(types)
                and all(self.assignable(a, b) for a, b in zip(types, m.argument_types))
            ]
            exact = [m for m in matches if m.argument_types == types]
            if len(exact) == 1:
                matches = exact
            if len(matches) != 1:
                raise UnsupportedBytecode(f"unresolved constructor {owner}{types}")
            method = matches[0]
            self.asm.emit(0xBB, _u2(self.cp.class_(self.binary_name(owner))), push=1)
            self.asm.emit(0x59, pop=1, push=2)
            for arg, parameter in zip(children, method.argument_types):
                self.expression(arg, parameter)
            self.asm.emit(
                0xB7,
                _u2(
                    self.cp.method(
                        self.binary_name(owner),
                        "<init>",
                        self.map_descriptor(method.descriptor),
                    )
                ),
                pop=1 + sum(_slots(t) for t in method.argument_types),
            )
        elif kind == "unary" and value != "!":
            self.expression(children[0], typ)
            if value == "-":
                self.asm.emit(
                    {"I": 0x74, "J": 0x75, "F": 0x76, "D": 0x77}[_category(typ)],
                    pop=_slots(typ),
                    push=_slots(typ),
                )
            elif value == "~":
                if typ not in ("I", "J"):
                    raise UnsupportedBytecode("nonintegral complement")
                self.integer(-1, typ == "J")
                self.asm.emit(
                    0x83 if typ == "J" else 0x82, pop=2 * _slots(typ), push=_slots(typ)
                )
        elif kind == "binary" and value not in (
            "==",
            "!=",
            "<",
            ">",
            "<=",
            ">=",
            "&&",
            "||",
        ):
            self.expression(children[0], typ)
            self.expression(children[1], "I" if value in ("<<", ">>", ">>>") else typ)
            category = _category(typ)
            if value in ("&", "|", "^", "<<", ">>", ">>>"):
                if category not in ("I", "J"):
                    raise UnsupportedBytecode("nonintegral bit operation")
                base = {
                    "<<": 0x78,
                    ">>": 0x7A,
                    ">>>": 0x7C,
                    "&": 0x7E,
                    "|": 0x80,
                    "^": 0x82,
                }[value]
                opcode = base + (category == "J")
            else:
                opcode = {"+": 0x60, "-": 0x64, "*": 0x68, "/": 0x6C, "%": 0x70}[
                    value
                ] + {"I": 0, "J": 1, "F": 2, "D": 3}[category]
            self.asm.emit(
                opcode,
                pop=_slots(typ) + (1 if value in ("<<", ">>", ">>>") else _slots(typ)),
                push=_slots(typ),
            )
        elif kind == "conditional":
            yes, no, end = self.asm.fresh(), self.asm.fresh(), self.asm.fresh()
            height = self.asm.height
            self.condition(children[0], yes, no, yes)
            self.asm.mark(yes, height)
            self.expression(children[1], typ)
            self.asm.jump(end)
            self.asm.mark(no, height)
            self.expression(children[2], typ)
            self.asm.mark(end, height + _slots(typ))
        elif kind in ("binary", "unary"):
            yes, no, end = self.asm.fresh(), self.asm.fresh(), self.asm.fresh()
            height = self.asm.height
            self.condition(expr, yes, no, yes)
            self.asm.mark(yes, height)
            self.integer(1)
            self.asm.jump(end)
            self.asm.mark(no, height)
            self.integer(0)
            self.asm.mark(end, height + 1)
        else:
            raise UnsupportedBytecode(f"unsupported expression {kind}")
        if expected is not None:
            self.convert(typ, expected)
            return expected
        return typ

    def condition(self, expr: _Expr, yes, no, fallthrough):
        if expr.kind == "unary" and expr.value == "!":
            self.condition(expr.children[0], no, yes, fallthrough)
            return
        if expr.kind == "binary" and expr.value in ("&&", "||"):
            middle = self.asm.fresh()
            height = self.asm.height
            self.condition(
                expr.children[0],
                middle if expr.value == "&&" else yes,
                no if expr.value == "&&" else middle,
                middle,
            )
            self.asm.mark(middle, height)
            self.condition(expr.children[1], yes, no, fallthrough)
            return
        if expr.kind == "binary" and expr.value in ("==", "!=", "<", ">=", ">", "<="):
            left, right = expr.children
            lt, rt = self.type(left), self.type(right)
            index = {"==": 0, "!=": 1, "<": 2, ">=": 3, ">": 4, "<=": 5}[expr.value]
            if _reference(lt) and _reference(rt):
                if index > 1:
                    raise UnsupportedBytecode("ordered reference comparison")
                self.expression(left)
                self.expression(right)
                branch, pop = 0xA5 + index, 2
            else:
                typ = self.promote(lt, rt)
                self.expression(left, typ)
                self.expression(right, typ)
                if typ == "I":
                    branch, pop = 0x9F + index, 2
                else:
                    # NaN must make ordered comparisons false.
                    opcode = (
                        0x94
                        if typ == "J"
                        else (0x96 if index in (2, 5) else 0x95)
                        if typ == "F"
                        else (0x98 if index in (2, 5) else 0x97)
                    )
                    self.asm.emit(opcode, pop=2 * _slots(typ), push=1)
                    branch, pop = 0x99 + index, 1
        else:
            typ = self.expression(expr)
            if typ not in _INTS:
                raise UnsupportedBytecode("nonboolean branch")
            branch, pop = 0x9A, 1
        if yes == fallthrough:
            branch, yes, no = _INVERSE_BRANCH[branch], no, yes
        self.asm.branch(branch, yes, pop)
        if no != fallthrough:
            self.asm.jump(no)

    def statement(self, text: str):
        text = text.strip().removesuffix(";").strip()
        parser = _Parser(text, self.types)
        try:
            left = parser.expression()
            if parser.peek() == "=":
                parser.take("=")
                right = parser.expression()
                if parser.peek():
                    raise _ParseError("trailing assignment tokens")
                if left.kind == "name":
                    if left.value not in self.locals:
                        raise UnsupportedBytecode(f"undeclared local {left.value}")
                    empty_array = self.empty_array(right)
                    self.expression(right, self.locals[left.value][0])
                    self.local(left.value, True)
                    self.empty_arrays.pop(left.value, None)
                    if empty_array:
                        self.empty_arrays[left.value] = empty_array
                elif left.kind == "index":
                    typ = self.type(left)
                    self.expression(left.children[0])
                    self.expression(left.children[1], "I")
                    self.expression(right, typ)
                    opcode = {
                        "I": 0x4F,
                        "J": 0x50,
                        "F": 0x51,
                        "D": 0x52,
                        "Z": 0x54,
                        "B": 0x54,
                        "C": 0x55,
                        "S": 0x56,
                    }.get(typ, 0x53)
                    self.asm.emit(opcode, pop=2 + _slots(typ))
                elif left.kind == "member":
                    member, receiver = self.field(left)
                    if receiver is not None:
                        self.expression(receiver)
                    self.expression(right, member.descriptor)
                    self.emit_field(member, store=True)
                else:
                    raise UnsupportedBytecode("unsupported assignment target")
            else:
                if parser.peek():
                    raise _ParseError("trailing statement tokens")
                typ = self.expression(left)
                if typ != "V":
                    self.asm.emit(0x58 if _slots(typ) == 2 else 0x57, pop=_slots(typ))
        except _ParseError as error:
            raise UnsupportedBytecode(
                f"unsupported statement {text}: {error}"
            ) from error
        if self.asm.height:
            raise UnsupportedBytecode("statement leaves operand stack nonempty")

    def compile(self) -> Code:
        cfg = self.body.cfg
        if cfg.entry not in cfg.blocks:
            raise UnsupportedBytecode("missing entry block")
        order = [cfg.entry] + [
            label for label in sorted(cfg.blocks) if label != cfg.entry
        ]
        for index, label in enumerate(order):
            following = order[index + 1] if index + 1 < len(order) else None
            self.asm.mark(label)
            self.empty_arrays.clear()
            block = cfg.blocks[label]
            for statement in block.statements:
                self.statement(statement)
            term = block.terminator
            if isinstance(term, Jump):
                if term.target != following:
                    self.asm.jump(term.target)
            elif isinstance(term, Branch):
                self.condition(
                    self.parse(term.condition), term.true_target, term.false_target, following
                )
            elif isinstance(term, Switch):
                self.expression(self.parse(term.selector), "I")
                self.asm.switch(term.cases, term.default_target)
            elif isinstance(term, Return):
                typ = self.method.return_type
                if self.method.is_constructor and not self.initializes_this:
                    raise UnsupportedBytecode(
                        "constructor return before recovered this/super initialization"
                    )
                if term.value is None:
                    if typ != "V":
                        raise UnsupportedBytecode("missing nonvoid return value")
                else:
                    if typ == "V":
                        raise UnsupportedBytecode("value returned from void method")
                    self.expression(self.parse(term.value), typ)
                self.asm.emit(
                    {"V": 0xB1, "I": 0xAC, "J": 0xAD, "F": 0xAE, "D": 0xAF, "A": 0xB0}[
                        _category(typ)
                    ],
                    pop=_slots(typ),
                )
                self.asm.reachable = False
            elif isinstance(term, Throw):
                typ = self.expression(self.parse(term.value))
                if not _reference(typ):
                    raise UnsupportedBytecode("athrow requires reference")
                self.asm.emit(0xBF, pop=1)
                self.asm.reachable = False
            else:
                raise UnsupportedBytecode(f"unsupported CFG terminator {term}")
        end_label = self.method.address + self.method.size
        if end_label not in self.asm.labels:
            self.asm.mark(end_label)
        # A native catch entry can also be reached with an empty stack through
        # ordinary control flow. Dedicated JVM handler stubs consume Throwable.
        self.asm.reachable = False
        handler_stubs = {}
        for address, local in self.body.handler_locals.items():
            if local not in self.locals or not _reference(self.locals[local][0]):
                raise UnsupportedBytecode(
                    "handler exception local missing/reference type required"
                )
            stub = ("handler", address)
            handler_stubs[address] = stub
            self.asm.mark(stub, 1)
            self.local(local, True)
            self.asm.jump(address)
        bytecode = self.asm.finish()
        handlers = []
        for region in self.body.exception_regions:
            if region.handler not in self.body.handler_locals:
                raise UnsupportedBytecode("handler has no exception-stack binding")
            try:
                start, end = (self.asm.labels[x] for x in (region.start, region.end))
                handler = self.asm.labels[handler_stubs[region.handler]]
            except KeyError as error:
                raise UnsupportedBytecode(
                    "exception region must align to CFG blocks"
                ) from error
            catch = self.binary_name(region.catch_class) if region.catch_class else None
            first = bisect_left(self.asm.throw_sites, (start,))
            last = bisect_left(self.asm.throw_sites, (end,), first)
            for throw_start, throw_end in self.asm.throw_sites[first:last]:
                handlers.append((throw_start, throw_end, handler, catch))
        local_table = tuple(
            (name, self.map_descriptor(typ), slot)
            for name, (typ, slot) in self.locals.items()
        )
        return Code(
            bytecode, self.asm.maximum, self.next_local, tuple(handlers), local_table
        )


def emit_method_code(
    image: RomImage,
    method: MethodSpec,
    cfg: LiftedCFG | LiftedBody,
    pool: ConstantPool,
    *,
    remap: Mapping[str, str] | None = None,
    runtime_layout: bool = False,
) -> Code:
    if method.has_handlers and not isinstance(cfg, LiftedBody):
        raise UnsupportedBytecode("native exception table lacks recovered handler CFG")
    body = cfg if isinstance(cfg, LiftedBody) else LiftedBody(cfg)
    wide_branches = set()
    while True:
        try:
            return _MethodCompiler(image, method, body, pool, remap, wide_branches, runtime_layout).compile()
        except _DistantBranches as error:
            # Widening a jump can move another target past the signed-16 limit.
            # Re-emission also recomputes switch padding and exception table PCs.
            wide_branches.update(error.indices)


def emit_classfile(
    image: RomImage,
    klass: ClassSpec,
    bodies: Mapping[MethodSpec, LiftedCFG | LiftedBody],
    *,
    methods: Sequence[MethodSpec] | None = None,
    remap: Mapping[str, str] | None = None,
    unavailable: str = "omit",
    errors: dict[MethodSpec, str] | None = None,
    field_errors: dict[FieldSpec, str] | None = None,
    runtime_layout: bool = False,
) -> bytes:
    """Return a classfile containing real selected bodies and original declarations.

    unavailable='native' adds marked no-Code declarations for unrecovered ordinary
    concrete methods. This mode supplies hierarchy metadata to a decompiler;
    those declarations are not recovered Java implementations.
    Fields with unresolved descriptors are omitted and recorded in field_errors
    when supplied; they do not discard independently recovered method bodies.
    """
    if unavailable not in ("omit", "native"):
        raise ValueError("unavailable must be omit or native")
    if klass.dimensions:
        raise UnsupportedBytecode("array classes have no classfile declaration")
    binary = lambda name: _binary_name(name, remap)
    descriptor = lambda desc: re.sub(
        r"L([^;]+);", lambda m: "L" + binary(m[1]) + ";", desc
    )
    # Coder.Translate sets 0x4000 when a public default constructor exists.
    flags = (klass.flags & 0x3611) | (0 if klass.is_interface else 0x20)
    builder = ClassFileBuilder(
        binary(klass.name),
        binary(klass.superclass) if klass.superclass else None,
        flags=flags,
        interfaces=tuple(binary(n) for n in klass.interfaces),
        attributes=(("JbedClassLayout", struct.pack(">HIII", 1, klass.class_id, klass.instance_size, klass.flags)),)
                   if runtime_layout else (),
    )
    if runtime_layout and klass.name in image.initializer_order:
        builder.attributes += (("JbedInitializerOrder",
            struct.pack(">HI", 1, image.initializer_order[klass.name])),)
    if any(member.name == "__jbed$initTrigger" for member in klass.fields):
        raise UnsupportedBytecode(
            "synthetic initialization trigger name collides with original field"
        )
    if not runtime_layout:
        builder.add_field(
            "__jbed$initTrigger", "Z", 0x1019 if klass.is_interface else 0x1009
        )
    for member in klass.fields:
        if not member.descriptor:
            if field_errors is not None:
                field_errors[member] = f"unresolved field descriptor {member.name}"
            continue
        constant = None
        if (
            member.constant_bits is not None
            and member.is_static
            and member.flags & 0x10
        ):
            bits = member.constant_bits
            if member.descriptor in _INTS:
                constant = builder.pool.integer(bits)
            elif member.descriptor == "J":
                constant = builder.pool.long(bits)
            elif member.descriptor == "F":
                constant = builder.pool.float_bits(bits)
            elif member.descriptor == "D":
                constant = builder.pool.double_bits(bits)
            elif member.descriptor == "Ljava/lang/String;" and bits:
                constant = builder.pool.string(image.string_literal(bits))
        layout = ()
        if runtime_layout:
            storage = {"instance": 0, "isolate_static": 1, "static": 2, "constant": 3}[member.storage]
            offset = 0 if storage == 3 else member.offset
            if storage == 2:
                offset -= _image_index(image).global_static_base
            layout = (("JbedFieldLayout", struct.pack(">BII", storage, offset, member.flags)),)
        builder.add_field(
            member.name,
            descriptor(member.descriptor),
            member.flags,
            constant_index=constant,
            attributes=layout,
        )
    selected = tuple(klass.methods if methods is None else methods)
    if runtime_layout:
        signatures = tuple(f.descriptor or "" for f in klass.fields) + tuple(m.descriptor or "" for m in selected)
        unresolved = [(typ, binary(name)) for typ, name in image.unresolved_types.items()
                      if any("L" + name + ";" in signature for signature in signatures)]
        if unresolved:
            payload = _u2(1) + _u2(len(unresolved))
            for typ, name in unresolved:
                encoded = name.encode("utf-8")
                payload += _u4(typ) + _u2(len(encoded)) + encoded
            builder.attributes += (("JbedUnresolvedTypes", payload),)
    for owner, field_name, field_type, store in _VM_FIELD_ACCESS:
        if runtime_layout or owner != klass.name:
            continue
        if not any(f.name == field_name and f.descriptor == field_type and not f.is_static for f in klass.fields):
            continue
        mapped_type = descriptor(field_type)
        signature = _accessor(field_name, mapped_type, store)
        if any((m.name, descriptor(m.descriptor)) == signature for m in klass.methods if m.descriptor):
            raise UnsupportedBytecode(f"VM field accessor collides with a ROM method: {owner}.{signature[0]}")
        ref = _u2(builder.pool.field(builder.name, field_name, mapped_type))
        if store:
            code = Code(b"\x2a\x2b\xb5" + ref + b"\xb1", 2, 2)
        else:
            result = b"\xb0" if _reference(mapped_type) else b"\xac"
            code = Code(b"\x2a\xb4" + ref + result, 1, 1)
        builder.add_method(*signature, flags=0x1011, code=code)  # public final synthetic
    missing_initializers = []
    for method in selected:
        if method not in klass.methods:
            raise UnsupportedBytecode("method selection belongs to another class")
        if not method.descriptor:
            message = f"unresolved method descriptor {method.name}"
            if errors is None:
                raise UnsupportedBytecode(message)
            errors[method] = message
            if runtime_layout and unavailable == "native":
                missing_initializers.append((method.name, "", method.flags))
            continue
        name = method.name
        flags = method.flags & 0x1DFF
        if is_bootstrap_bitcast(image, method, remap):
            builder.add_method(name, method.descriptor, flags | 0x100)
            continue
        if method in bodies:
            try:
                code = emit_method_code(
                    image, method, bodies[method], builder.pool, remap=remap, runtime_layout=runtime_layout
                )
            except UnsupportedJava as error:
                if errors is None:
                    raise
                errors[method] = str(error)
            else:
                builder.add_method(
                    name, descriptor(method.descriptor), flags & ~0x500, code=code
                )
                continue
        if method.is_native or method.is_abstract:
            if method.is_native:
                # KNI thunks retain their bridge flag instead of JVM ACC_NATIVE.
                flags |= 0x100
            builder.add_method(name, descriptor(method.descriptor), flags)
        elif unavailable == "native" and name not in ("<init>", "<clinit>"):
            if klass.is_interface:
                raise UnsupportedBytecode("native metadata placeholder in interface")
            builder.add_method(
                name,
                descriptor(method.descriptor),
                flags | 0x100,
                unavailable=_u4(method.flags) if runtime_layout else
                            _u4(method.flags) + _u4(method.address) + _u4(method.size),
            )
        elif runtime_layout and unavailable == "native":
            missing_initializers.append((name, descriptor(method.descriptor), method.flags))
    if missing_initializers:
        # Initializers cannot be native classfile declarations. Keep their input
        # signatures in a class attribute consumed by the source ROM compiler.
        # Inline strings survive preverification's constant-pool renumbering.
        payload = _u2(1) + _u2(len(missing_initializers))
        for name, signature, original_flags in missing_initializers:
            for value in (name, signature):
                encoded = value.encode("utf-8")
                payload += _u2(len(encoded)) + encoded
            payload += _u4(original_flags)
        builder.attributes += (("JbedUnavailableMethods", payload),)
    # The CLDC ROM works on raw register words internally. Recovered JVM
    # code that observes a float's NaN payload needs the inverse VM primitive
    # too. Mark this added classfile method synthetic to preserve its origin.
    raw_bits = _RAW_BITS.get(klass.name)
    if builder.name == klass.name and raw_bits and not any(
        (m.name, m.descriptor) == raw_bits for m in klass.methods
    ):
        builder.add_method(*raw_bits, flags=0x1109)  # public static native synthetic
    return builder.to_bytes()
