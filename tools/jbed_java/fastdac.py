"""Restore Xperia FastDAC ROM instructions to standard JVM bytecode.

The instruction formats come from the native compiler at 0xc0d78 and its
switch readers at 0xbf308/0xbf49c/0xbf59c. Metadata belongs to the Xperia
image; no bodies are silently substituted into the Android ROM.
"""

from __future__ import annotations

import argparse
import struct
import zipfile
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .classfile import (
    ClassFileBuilder,
    Code,
    ConstantPool,
    UnsupportedBytecode,
    _Assembler,
)
from .model import split_method_descriptor


class UnsupportedFastDac(UnsupportedBytecode):
    pass


@dataclass(frozen=True)
class Instruction:
    pc: int
    size: int
    opcode: int | str
    operands: tuple = ()


def decode(code: bytes) -> tuple[Instruction, ...]:
    """Decode all instruction boundaries, including compressed ROM switches."""
    result = []
    pc = 0

    def number(at: int, size: int = 1, signed: bool = False) -> int:
        if at < 0 or at + size > len(code):
            raise UnsupportedFastDac(f"truncated instruction at bytecode {pc}")
        return int.from_bytes(code[at:at + size], "big", signed=signed)

    while pc < len(code):
        op = code[pc]
        size, operands, kind = 1, (), op
        if op in (0x10, 0x11):
            size = 2 if op == 0x10 else 3
            operands = (number(pc + 1, size - 1, True),)
        elif op in (0x12, *range(0x15, 0x1a), *range(0x36, 0x3b), 0xa9, 0xbc):
            size, operands = 2, (number(pc + 1),)
        elif op in (0x13, 0x14, *range(0xb2, 0xb9), 0xbb, 0xbd, 0xc0, 0xc1, 0xcd, 0xdb):
            size, operands = 3, (number(pc + 1, 2),)
        elif op == 0x84:
            size, operands = 3, (number(pc + 1), number(pc + 2, signed=True))
        elif 0x99 <= op <= 0xa8 or op in (0xc6, 0xc7):
            size, operands = 3, (pc + number(pc + 1, 2, True),)
        elif op in (0xc8, 0xc9):
            size, operands = 5, (pc + number(pc + 1, 4, True),)
        elif op in (0xaa, 0xab):
            cursor = (pc + 4) & ~3
            default = pc + number(cursor, 4, True)
            if op == 0xaa:
                low, high = number(cursor + 4, 4, True), number(cursor + 8, 4, True)
                if high < low or high - low > len(code) // 4:
                    raise UnsupportedFastDac(f"invalid tableswitch at {pc}")
                pairs = tuple((key, pc + number(cursor + 12 + 4 * (key - low), 4, True))
                              for key in range(low, high + 1))
                size = cursor + 12 + 4 * len(pairs) - pc
            else:
                count = number(cursor + 4, 4, True)
                if count < 0 or count > len(code) // 8:
                    raise UnsupportedFastDac(f"invalid lookupswitch at {pc}")
                pairs = tuple((number(cursor + 8 + 8 * i, 4, True),
                               pc + number(cursor + 12 + 8 * i, 4, True)) for i in range(count))
                size = cursor + 8 + 8 * count - pc
            kind, operands = "switch", (default, pairs)
        elif op == 0xb9:
            size, operands = 5, (number(pc + 1, 2), number(pc + 3))
        elif op == 0xba:  # FastDAC uses the pre-Java-7 reserved opcode.
            size, kind, operands = 3, "putstatic_offset", (4 * number(pc + 1, 2),)
        elif op == 0xc5:
            size, operands = 4, (number(pc + 1, 2), number(pc + 3))
        elif op == 0xc4:
            sub = number(pc + 1)
            if sub in (*range(0x15, 0x1a), *range(0x36, 0x3b), 0xa9):
                size, kind, operands = 4, sub, (number(pc + 2, 2),)
            elif sub == 0x84:
                size, kind, operands = 6, sub, (number(pc + 2, 2), number(pc + 4, 2, True))
            elif sub == 0xaa:
                low, high = number(pc + 3, signed=True), number(pc + 4, signed=True)
                if high < low:
                    raise UnsupportedFastDac(f"invalid compact tableswitch at {pc}")
                pairs = tuple((key, pc + number(pc + 5 + key - low)) for key in range(low, high + 1))
                size, kind, operands = 6 + high - low, "switch", (pc + number(pc + 2), pairs)
            elif sub == 0xab:
                count = number(pc + 3)
                pairs = tuple((number(pc + 4 + 2 * i, signed=True), pc + number(pc + 5 + 2 * i))
                              for i in range(count))
                size, kind, operands = 4 + 2 * count, "switch", (pc + number(pc + 2), pairs)
            elif sub in (0xc2, 0xc3):
                # Compiler ignores these markers; synchronization is in the
                # method's entry/exit protocol, not on the operand stack.
                size, kind = 2, "synchronized_marker"
            else:
                raise UnsupportedFastDac(f"unsupported wide opcode {sub:#x} at {pc}")
        elif 0xca <= op <= 0xcc:
            size, kind = 2, "getstatic_offset"
            operands = (4 * (number(pc + 1) + 256 * (op - 0xca)),)
        elif op in (0xce, 0xcf):
            size, kind, operands = 3, "getfield_offset" if op == 0xce else "putfield_offset", (4 * number(pc + 1),)
        elif op == 0xd0:
            arg = number(pc + 1)
            size, kind, operands = 2, "self_virtual", (arg & 63, 1, arg >> 6)
        elif op == 0xd1:
            arg = number(pc + 2)
            size, kind, operands = 3, "virtual", (number(pc + 1), arg & 63, arg >> 6)
        elif op == 0xd2:
            arg = number(pc + 1)
            size, kind, operands = 2, "virtual", (arg & 15, (arg & 127) >> 4, 0)
        elif 0xd3 <= op <= 0xd5:
            size, kind, operands = 2, 0x13, (number(pc + 1) + 256 * (op - 0xd2),)
        elif op == 0xd6:
            size, kind, operands = 3, "string", (number(pc + 1, 2),)
        elif op == 0xd7:
            size, kind, operands = 2, "new_dup", (number(pc + 1),)
        elif op in (0xd8, 0xe9):
            size, kind, operands = 2, "self_getfield" if op == 0xd8 else "getfield_offset", (2 * (number(pc + 1) & 254),)
        elif op in (0xd9, 0xda):
            arg = number(pc + 1, 2)
            size, kind, operands = 3, 0xb2 if arg & 1 else 0xb3, (arg >> 2,)
        elif 0xdc <= op <= 0xe7:
            size, kind = 2, "branch_zero" if op <= 0xe1 else "branch_pair"
            operands = (op - (0xdc if op <= 0xe1 else 0xe2), pc + number(pc + 1, signed=True))
        elif op == 0xe8:
            size, kind, operands = 2, 0xa7, (pc + number(pc + 1, signed=True),)
        elif op == 0xea:
            size, kind, operands = 2, "putfield_offset", (4 * (number(pc + 1) >> 1),)
        elif 0xeb <= op <= 0xf2:
            kind, operands = "getfield_offset", (4 * (op - (0xeb if op <= 0xef else 0xf0)),)
        elif op == 0xf3:
            size, kind, operands = 3, 0xb6, (number(pc + 1),)
        elif 0xf4 <= op <= 0xff:
            kind, operands = "putfield_offset", (4 * (op - (0xf4 if op <= 0xf9 else 0xfa)),)
        if pc + size > len(code):
            raise UnsupportedFastDac(f"truncated instruction at {pc}")
        result.append(Instruction(pc, size, kind, operands))
        pc += size
    starts = {ins.pc for ins in result}
    for ins in result:
        targets = _targets(ins)
        if any(target not in starts for target in targets):
            raise UnsupportedFastDac(f"branch outside instruction boundaries at {ins.pc}")
    return tuple(result)


def _targets(ins: Instruction) -> tuple[int, ...]:
    if ins.opcode == "switch":
        return (ins.operands[0], *(target for _, target in ins.operands[1]))
    if ins.opcode in ("branch_zero", "branch_pair"):
        return (ins.operands[1],)
    if isinstance(ins.opcode, int) and (0x99 <= ins.opcode <= 0xa8 or ins.opcode in (0xc6, 0xc7, 0xc8, 0xc9)):
        return (ins.operands[0],)
    return ()


def _reference(value: str) -> bool:
    return value == "null" or value.startswith(("L", "[", "?A", "!"))


def _width(value: str) -> int:
    return 2 if value in ("J", "D") or value.startswith("?J") else 1


def _words(values) -> int:
    return sum(_width(value) for value in values)


def _normalized(value: str) -> str:
    return "I" if value in "ZBCSI" else value


@dataclass(frozen=True)
class State:
    locals: tuple[str, ...]
    stack: tuple[str, ...]


@dataclass(frozen=True)
class Lowered:
    state: State
    data: bytes = b""
    branch: int | None = None
    peak: int = 0


class ReverseQuickener:
    """Typed dataflow resolves ROM offsets before emitting JVM references."""

    def __init__(self, image: Any, pool: ConstantPool | None = None):
        self.image = image
        self.pool = pool if pool is not None else ConstantPool()
        if not hasattr(image, "recovered_types"):
            image.recovered_types = {}
            image.field_type_variables = {}
        self.types: dict[str, str] = image.recovered_types
        self.field_variables: dict[tuple, str] = image.field_type_variables
        if not hasattr(image, "method_type_variables"):
            image.method_type_variables = {}
        self.method_variables: dict[int, tuple[tuple[str, ...], str]] = image.method_type_variables

    def _call_signature(self, member, stack: list[str], opcode: int):
        contract = self.method_variables.get(member.address)
        if contract is None and member.descriptor:
            return split_method_descriptor(member.descriptor)
        words = member.parameter_words - (0 if opcode == 0xb8 else 1)
        actual = []
        for value in reversed(stack):
            if words == 0:
                break
            words -= _width(value)
            actual.append(value)
        if words != 0:
            raise UnsupportedFastDac("call arguments disagree with ROM parameter frame")
        actual.reverse()
        if contract is None:
            parameters = tuple("?" + ("A" if _reference(value) else "J" if _width(value) == 2 else "I")
                               + f":argument:{member.address:x}:{i}" for i, value in enumerate(actual))
            result = {"void": "V", "ref": f"?A:return:{member.address:x}",
                      "wide": f"?J:return:{member.address:x}",
                      "word": f"?I:return:{member.address:x}"}[member.return_kind]
            contract = (parameters, result)
            self.method_variables[member.address] = contract
        parameters, result = contract
        if len(parameters) != len(actual):
            raise UnsupportedFastDac("inconsistent category-2 call arguments")
        for variable, value in zip(parameters, actual):
            resolved, incoming = self._resolve(variable), self._resolve(value)
            if incoming == "null":
                continue
            if _reference(resolved) and _reference(incoming) and not resolved.startswith("?") and not incoming.startswith("?"):
                self.types[variable] = self.image.common_superclass(resolved, incoming)
            else:
                self._constrain(variable, value)
        resolved_args = tuple(self._resolve(value) for value in parameters)
        resolved_result = self._resolve(result)
        if not any(value.startswith("?") for value in (*resolved_args, resolved_result)):
            member.descriptor = "(" + "".join(resolved_args) + ")" + resolved_result
        return parameters, result

    def _trivial_constructor(self, owner: str, visiting: frozenset[str] = frozenset()):
        """Recognize an eliminated no-op chain, rather than invent its body."""
        if owner in visiting or owner not in self.image.classes:
            return None
        cls = self.image.classes[owner]
        candidates = [m for m in cls.methods if m.name == "<init>" and m.has_bytecode
                      and (m.descriptor == "()V" or m.descriptor is None and m.parameter_words == 1)]
        for member in candidates:
            steps = [i for i in decode(member.code) if i.opcode != 0]
            if (len(steps) == 1 and steps[0].opcode == 0xb1
                    and (owner == "java/lang/Object" or cls.superclass
                         and self._trivial_constructor(cls.superclass, visiting | {owner}))):
                member.descriptor = "()V"
                return member
            if len(steps) == 3 and steps[0].opcode == 0x2a and steps[-1].opcode == 0xb1:
                call = steps[1]
                if call.opcode not in (0xb7, 0xdb):
                    continue
                target = (self.image.direct_method(call.operands[0]) if call.opcode == 0xdb
                          else self.image.pool_method(member, call.operands[0]))
                if (target.name == "<init>" and target.owner == cls.superclass
                        and self._trivial_constructor(target.owner, visiting | {owner}) is target):
                    member.descriptor = "()V"
                    return member
        return None

    def _allocation(self, owner: str, pc: int) -> tuple[bytes, str]:
        data = b"\xbb" + struct.pack(">H", self.pool.class_(owner))
        if owner not in self.explicit_constructors and self._trivial_constructor(owner):
            data += b"\x59\xb7" + struct.pack(">H", self.pool.method(owner, "<init>", "()V"))
            return data, "L" + owner + ";"
        return data, f"!{pc}:L{owner};"

    def _resolve(self, value: str) -> str:
        seen = set()
        while value.startswith("?") and value in self.types:
            if value in seen:
                raise UnsupportedFastDac("cyclic inferred type")
            seen.add(value)
            value = self.types[value]
        return value

    def _constrain(self, value: str, expected: str) -> None:
        actual, target = self._resolve(value), self._resolve(expected)
        if actual == target or target == "null":
            return
        if actual.startswith("?"):
            if (_width(actual) != _width(target)
                    or not actual.startswith("?U") and not target.startswith("?U")
                    and _reference(actual) != _reference(target)):
                raise UnsupportedFastDac(f"incompatible inferred types {actual} and {target}")
            self.types[actual] = target
        elif target.startswith("?"):
            self._constrain(target, actual)
        elif value.startswith("?") and _reference(actual) and _reference(target):
            common = self.image.common_superclass(actual, target)
            if common == actual:
                self.types[value] = target
            elif common != target:
                raise UnsupportedFastDac(f"conflicting reference constraints {actual} and {target}")
        elif actual != target and not (_reference(actual) and _reference(target)):
            raise UnsupportedFastDac(f"conflicting inferred types {actual} and {target}")

    def _field_type(self, member, hint: str | None = None) -> str:
        key = (member.owner, member.is_static, member.offset)
        if key in self.field_variables:
            variable = self.field_variables[key]
        elif member.descriptor:
            return member.descriptor
        else:
            if hint is None:
                storage = getattr(member, "storage_kind", None)
                hint = {"ref": "A", "wide": "J", "word": "I", "unknown": "U"}.get(storage)
                if hint is None:
                    hint = ("U" if not member.address else
                            "A" if member.flags & 2 else "J" if member.flags & 1 else "I")
            variable = "?" + hint + ":field:" + repr(key)
            self.field_variables[key] = variable
        resolved = self._resolve(variable)
        if not resolved.startswith("?"):
            member.descriptor = resolved
        return variable

    def _merge_type(self, left: str, right: str, *, local: bool = False) -> str:
        if left == right:
            return left
        if left.startswith("?") or right.startswith("?"):
            self._constrain(left, right)
            return left if left.startswith("?") else right
        if left == "null" and _reference(right):
            return right
        if right == "null" and _reference(left):
            return left
        if _reference(left) and _reference(right):
            if left.startswith("[") and right.startswith("["):
                a, b = left[1:], right[1:]
                if _reference(a) and _reference(b):
                    return "[" + self._merge_type(a, b)
            common = getattr(self.image, "common_superclass", None)
            return common(left, right) if common else "Ljava/lang/Object;"
        if local:
            return "top"
        raise UnsupportedFastDac(f"incompatible stack types {left} and {right}")

    def _merge(self, old: State, new: State) -> State:
        if len(old.stack) != len(new.stack):
            raise UnsupportedFastDac("inconsistent operand stack at control-flow merge")
        return State(tuple(self._merge_type(a, b, local=True) for a, b in zip(old.locals, new.locals)),
                     tuple(self._merge_type(a, b) for a, b in zip(old.stack, new.stack)))

    def compile(self, method: Any) -> Code:
        if not method.descriptor:
            raise UnsupportedFastDac("method signature was stripped from the ROM")
        code = method.code
        instructions = decode(code)
        if not instructions:
            raise UnsupportedFastDac("empty concrete method")
        self.explicit_constructors = set()
        for ins in instructions:
            if ins.opcode in (0xb7, 0xdb):
                try:
                    target = (self.image.direct_method(ins.operands[0]) if ins.opcode == 0xdb
                              else self.image.pool_method(method, ins.operands[0]))
                    if target.name == "<init>":
                        self.explicit_constructors.add(target.owner)
                except ValueError:
                    pass
        args, _ = split_method_descriptor(method.descriptor)
        local = [] if method.is_static else ["L" + method.owner + ";"]
        prefix = b""
        if method.name == "<init>" and method.owner != "java/lang/Object":
            parent = self.image.classes[method.owner].superclass
            if parent and self._trivial_constructor(parent):
                prefix = b"\x2a\xb7" + struct.pack(">H", self.pool.method(parent, "<init>", "()V"))
            else:
                local[0] = "!this:L" + method.owner + ";"
        for descriptor in args:
            local.append(_normalized(descriptor))
            if _width(descriptor) == 2:
                local.append("top")
        if len(local) > method.max_locals:
            raise UnsupportedFastDac("parameters exceed ROM local frame")
        local.extend(["top"] * (method.max_locals - len(local)))
        by_pc = {ins.pc: ins for ins in instructions}
        states = {0: State(tuple(local), ())}
        lowered: dict[int, Lowered] = {}
        pending = deque([0])
        regions = method.exception_regions
        for region in regions:
            if (region.start not in by_pc or region.end not in (*by_pc, len(code))
                    or region.handler not in by_pc):
                raise UnsupportedFastDac("exception range is not on instruction boundaries")

        def enqueue(pc: int, state: State):
            if pc not in by_pc:
                raise UnsupportedFastDac(f"control flow falls outside method at {pc}")
            merged = self._merge(states[pc], state) if pc in states else state
            if states.get(pc) != merged:
                states[pc] = merged
                pending.append(pc)

        while pending:
            pc = pending.popleft()
            ins, state = by_pc[pc], states[pc]
            try:
                step = self._lower(method, ins, state)
            except (ValueError, KeyError, IndexError) as exc:
                raise UnsupportedFastDac(f"{method.owner}.{method.name} at {pc}: {exc}") from exc
            lowered[pc] = step
            for target in _targets(ins):
                enqueue(target, step.state)
            terminal = ins.opcode == "switch" or ins.opcode in (0xa7, 0xc8, 0xbf, *range(0xac, 0xb2))
            if not terminal:
                enqueue(pc + ins.size, step.state)
            for region in regions:
                if region.start <= pc < region.end:
                    catch = "L" + (region.catch_class or "java/lang/Throwable") + ";"
                    enqueue(region.handler, State(state.locals, (catch,)))

        # Loads of stripped private fields can acquire their type from a later
        # return, arithmetic instruction, store, or call argument. Emit only
        # after those constraints have settled.
        for pc in lowered:
            step = self._lower(method, by_pc[pc], states[pc])
            lowered[pc] = step
            if not step.data and by_pc[pc].opcode in (
                    "getfield_offset", "putfield_offset", "self_getfield",
                    "getstatic_offset", "putstatic_offset", 0xb2, 0xb3, 0xb4, 0xb5):
                raise UnsupportedFastDac("private field type remains unresolved")
            if not step.data and by_pc[pc].opcode in ("virtual", "self_virtual", 0xb6, 0xb7, 0xb8, 0xb9, 0xcd, 0xdb):
                raise UnsupportedFastDac("callee signature remains unresolved")
        asm = _Assembler()
        if prefix:
            asm.emit(prefix[0], prefix[1:])
            asm.maximum = 1
        for ins in instructions:
            if ins.pc not in lowered:
                asm.labels[ins.pc] = len(asm.data)
                continue
            step, state = lowered[ins.pc], states[ins.pc]
            asm.mark(ins.pc, _words(state.stack))
            asm.maximum = max(asm.maximum, step.peak)
            if ins.opcode == "switch":
                asm.switch(ins.operands[1], ins.operands[0])
            elif ins.opcode in (0xa7, 0xc8):
                asm.jump(ins.operands[0])
            elif step.branch is not None:
                asm.branch(step.branch, _targets(ins)[0], _words(state.stack) - _words(step.state.stack))
            elif step.data:
                asm.emit(step.data[0], step.data[1:], pop=_words(state.stack), push=_words(step.state.stack))
            if ins.opcode in (0xbf, *range(0xac, 0xb2)):
                asm.reachable = False
        asm.labels[len(code)] = len(asm.data)
        exceptions = tuple((asm.labels[r.start], asm.labels[r.end], asm.labels[r.handler], r.catch_class)
                           for r in regions if asm.labels[r.start] != asm.labels[r.end])
        return Code(asm.finish(), asm.maximum, method.max_locals, exceptions)

    def _lower(self, method: Any, ins: Instruction, state: State) -> Lowered:
        stack, local = list(state.stack), list(state.locals)
        op, operands = ins.opcode, ins.operands
        data = b""
        branch = None
        peak = _words(stack)

        def pop(expected: str | None = None) -> str:
            if not stack:
                raise UnsupportedFastDac("operand stack underflow")
            value = stack.pop()
            actual = self._resolve(value)
            if actual.startswith("!") and expected is not None:
                raise UnsupportedFastDac("use of allocation before a recovered constructor call")
            if expected not in (None, "A"):
                self._constrain(value, _normalized(expected))
                actual = self._resolve(value)
            if expected == "A":
                if actual.startswith("?U"):
                    self.types[actual] = "?A" + actual[2:]
                    actual = self._resolve(actual)
                valid = _reference(actual)
            elif expected is None:
                valid = True
            elif _reference(expected):
                valid = _reference(actual)
            else:
                valid = _normalized(actual) == _normalized(self._resolve(expected))
            if not valid:
                raise UnsupportedFastDac(f"expected {expected}, found {value}")
            return value

        def push(value: str):
            nonlocal peak
            stack.append(_normalized(value))
            peak = max(peak, _words(stack))

        def u2(value: int) -> bytes:
            return struct.pack(">H", value)

        def field(member, store: bool, prefix: bytes = b""):
            if getattr(member, "initializer_error", None):
                raise UnsupportedFastDac(member.initializer_error)
            descriptor = self._field_type(member)
            if store:
                value = pop()
                self._constrain(descriptor, value)
            if not member.is_static:
                pop("A")
            if not store:
                push(descriptor)
            resolved = self._resolve(descriptor)
            if resolved.startswith("?"):
                return b""
            member.descriptor = resolved
            opcode = (0xb3 if store else 0xb2) if member.is_static else (0xb5 if store else 0xb4)
            return prefix + bytes((opcode,)) + u2(self.pool.field(member.owner, member.name, member.descriptor))

        def invoke(member, opcode: int, prefix: bytes = b""):
            arguments, result = self._call_signature(member, stack, opcode)
            for descriptor in reversed(arguments):
                pop(descriptor)
            initialized_noop = False
            if opcode != 0xb8:
                if member.name == "<init>":
                    target = pop()
                    if target.startswith("!"):
                        initialized = target.split(":", 1)[1]
                        stack[:] = [initialized if value == target else value for value in stack]
                        local[:] = [initialized if value == target else value for value in local]
                    elif self._trivial_constructor(member.owner) is member and not arguments:
                        initialized_noop = True
                    else:
                        raise UnsupportedFastDac("constructor receiver is already initialized")
                else:
                    pop("A")
            if result != "V":
                push(result)
            resolved_args = tuple(self._resolve(value) for value in arguments)
            resolved_result = self._resolve(result)
            if any(value.startswith("?") for value in (*resolved_args, resolved_result)):
                return b""
            if member.address in self.method_variables:
                member.descriptor = "(" + "".join(resolved_args) + ")" + resolved_result
            if initialized_noop:
                return prefix + b"\x57"
            index = self.pool.method(member.owner, member.name, member.descriptor, interface=opcode == 0xb9)
            encoded = prefix + bytes((opcode,)) + u2(index)
            if opcode == 0xb9:
                encoded += bytes((_words(arguments) + 1, 0))
            return encoded

        def receiver(words: int) -> str:
            consumed = 0
            for value in reversed(stack):
                consumed += _width(value)
                if consumed == words:
                    if not _reference(value):
                        raise UnsupportedFastDac("non-reference virtual receiver")
                    return self._resolve(value)
                if consumed > words:
                    break
            raise UnsupportedFastDac("virtual receiver crosses category-2 value")

        if op in ("branch_zero", "branch_pair"):
            condition, _ = operands
            right_token = pop()
            right = self._resolve(right_token)
            if op == "branch_zero":
                if _reference(right):
                    if condition > 1:
                        raise UnsupportedFastDac("ordered reference comparison")
                    branch = 0xc6 + condition
                else:
                    if right.startswith("?I"):
                        self._constrain(right_token, "I")
                        right = "I"
                    if right != "I":
                        raise UnsupportedFastDac("non-integer zero comparison")
                    branch = 0x99 + condition
            else:
                left_token = pop()
                self._constrain(left_token, right_token)
                left, right = self._resolve(left_token), self._resolve(right_token)
                if left.startswith("?I"):
                    self._constrain(left_token, "I")
                    left = right = "I"
                if _reference(left) and _reference(right):
                    if condition > 1:
                        raise UnsupportedFastDac("ordered reference comparison")
                    branch = 0xa5 + condition
                elif left == right == "I":
                    branch = 0x9f + condition
                else:
                    raise UnsupportedFastDac("incompatible compact comparison operands")
        elif op == "switch":
            pop("I")
        elif op in ("getfield_offset", "putfield_offset", "self_getfield"):
            prefix = b""
            if op == "self_getfield":
                push(local[0])
                prefix = b"\x2a"
            owner = self._resolve(stack[-2] if op == "putfield_offset" else stack[-1])
            raw = method.code[ins.pc]
            hint = ("A" if raw in range(0xeb, 0xf0) or raw in range(0xf4, 0xfa)
                    or raw in (0xd8, 0xe9, 0xea) and method.code[ins.pc + 1] & 1 else "I")
            member = self.image.field_at(owner, operands[0], kind="ref" if hint == "A" else "word")
            self._field_type(member, hint)
            data = field(member, op == "putfield_offset", prefix)
        elif op in ("getstatic_offset", "putstatic_offset"):
            constant = self.image.static_constant_at(operands[0]) if op == "getstatic_offset" else None
            if constant:
                tag, value = constant
                descriptor, add = {3: ("I", self.pool.integer), 4: ("F", self.pool.float_bits),
                                   5: ("J", self.pool.long), 6: ("D", self.pool.double_bits),
                                   8: ("Ljava/lang/String;", self.pool.string)}[tag]
                push(descriptor)
                data = bytes((0x14 if tag in (5, 6) else 0x13,)) + u2(add(value))
            else:
                data = field(self.image.static_field_at(operands[0]), op == "putstatic_offset")
        elif op in ("virtual", "self_virtual"):
            slot, argc, _ = operands
            prefix = b""
            if op == "self_virtual":
                push(local[0])
                prefix = b"\x2a"
            member = self.image.virtual_method(receiver(argc), slot)
            data = invoke(member, 0xb6, prefix)
        elif op == "string":
            push("Ljava/lang/String;")
            data = b"\x13" + u2(self.pool.string(self.image.string(operands[0])))
        elif op == "new_dup":
            name = self.image.new_class(operands[0])
            data, value = self._allocation(name, ins.pc)
            push(value)
            push(value)
            data += b"\x59"
            peak = max(peak, _words(stack))
        elif op == "synchronized_marker":
            if not method.is_synchronized:
                raise UnsupportedFastDac("synchronization marker without synchronized method")
        else:
            data, branch = self._ordinary(method, ins.pc, op, operands, stack, local, pop, push, invoke, field, u2)
            if op == 0xbb:
                peak = max(peak, _words(state.stack) + 2)
        return Lowered(State(tuple(local), tuple(stack)), data, branch, max(peak, _words(stack)))

    def _ordinary(self, method, pc, op, args, stack, local, pop, push, invoke, field, u2):
        data = bytes((op,))
        branch = None

        def load(index: int, expected: str):
            value = local[index]
            if expected != "A":
                self._constrain(value, expected)
            actual = self._resolve(value)
            if expected == "A":
                valid = _reference(actual)
            else:
                valid = actual == expected
            if not valid:
                raise UnsupportedFastDac(f"invalid local {index}: expected {expected}, found {value}")
            push(value)

        def store(index: int, expected: str):
            value = pop() if expected == "A" else pop(expected)
            if expected == "A" and not _reference(value):
                raise UnsupportedFastDac("astore of non-reference value")
            width = _width(value)
            if index + width > len(local):
                raise UnsupportedFastDac("local write exceeds frame")
            if index and local[index - 1] in ("J", "D"):
                local[index - 1] = "top"
            local[index] = value
            if width == 2:
                local[index + 1] = "top"

        def local_encoding(opcode: int, index: int) -> bytes:
            return bytes((opcode, index)) if index <= 255 else b"\xc4" + bytes((opcode,)) + u2(index)

        if op == 0x00:
            pass
        elif op == 0x01:
            push("null")
        elif 0x02 <= op <= 0x08:
            push("I")
        elif op in (0x09, 0x0a):
            push("J")
        elif 0x0b <= op <= 0x0d:
            push("F")
        elif op in (0x0e, 0x0f):
            push("D")
        elif op in (0x10, 0x11):
            push("I")
            data += int(args[0]).to_bytes(1 if op == 0x10 else 2, "big", signed=True)
        elif op in (0x12, 0x13, 0x14):
            tag, value = self.image.pool_constant(method, args[0])
            constructors = {3: ("I", self.pool.integer), 4: ("F", self.pool.float_bits),
                            5: ("J", self.pool.long), 6: ("D", self.pool.double_bits),
                            8: ("Ljava/lang/String;", self.pool.string)}
            if tag not in constructors:
                raise UnsupportedFastDac(f"unsupported constant tag {tag}")
            descriptor, add = constructors[tag]
            if (op == 0x14) != (tag in (5, 6)):
                raise UnsupportedFastDac("constant width disagrees with instruction")
            push(descriptor)
            data = bytes((0x14 if tag in (5, 6) else 0x13,)) + u2(add(value))
        elif 0x15 <= op <= 0x19:
            load(args[0], ("I", "J", "F", "D", "A")[op - 0x15])
            data = local_encoding(op, args[0])
        elif 0x1a <= op <= 0x2d:
            group, index = divmod(op - 0x1a, 4)
            load(index, ("I", "J", "F", "D", "A")[group])
        elif 0x2e <= op <= 0x35:
            pop("I")
            array = self._resolve(pop("A"))
            if op == 0x32:
                if not array.startswith("[") or not _reference(array[1:]):
                    raise UnsupportedFastDac("aaload component type is unresolved")
                push(array[1:])
            else:
                push(("I", "J", "F", "D", "A", "I", "I", "I")[op - 0x2e])
        elif 0x36 <= op <= 0x3a:
            store(args[0], ("I", "J", "F", "D", "A")[op - 0x36])
            data = local_encoding(op, args[0])
        elif 0x3b <= op <= 0x4e:
            group, index = divmod(op - 0x3b, 4)
            store(index, ("I", "J", "F", "D", "A")[group])
        elif 0x4f <= op <= 0x56:
            pop(("I", "J", "F", "D", "A", "I", "I", "I")[op - 0x4f])
            pop("I")
            pop("A")
        elif 0x57 <= op <= 0x5f:
            self._stack_operation(op, stack)
        elif 0x60 <= op <= 0x73:
            value = ("I", "J", "F", "D")[(op - 0x60) & 3]
            pop(value)
            pop(value)
            push(value)
        elif 0x74 <= op <= 0x77:
            value = ("I", "J", "F", "D")[op - 0x74]
            pop(value)
            push(value)
        elif 0x78 <= op <= 0x7d:
            value = "J" if op & 1 else "I"
            pop("I")
            pop(value)
            push(value)
        elif 0x7e <= op <= 0x83:
            value = "J" if op & 1 else "I"
            pop(value)
            pop(value)
            push(value)
        elif op == 0x84:
            if local[args[0]] != "I":
                raise UnsupportedFastDac("iinc on non-integer local")
            index, increment = args
            data = (bytes((op, index)) + struct.pack("b", increment)
                    if index <= 255 and -128 <= increment <= 127
                    else b"\xc4\x84" + u2(index) + struct.pack(">h", increment))
        elif 0x85 <= op <= 0x93:
            source, result = (("I", "J"), ("I", "F"), ("I", "D"),
                              ("J", "I"), ("J", "F"), ("J", "D"),
                              ("F", "I"), ("F", "J"), ("F", "D"),
                              ("D", "I"), ("D", "J"), ("D", "F"),
                              ("I", "I"), ("I", "I"), ("I", "I"))[op - 0x85]
            pop(source)
            push(result)
        elif 0x94 <= op <= 0x98:
            value = "J" if op == 0x94 else "F" if op <= 0x96 else "D"
            pop(value)
            pop(value)
            push("I")
        elif 0x99 <= op <= 0x9e:
            pop("I")
            branch = op
        elif 0x9f <= op <= 0xa6:
            value = "I" if op <= 0xa4 else "A"
            pop(value)
            pop(value)
            branch = op
        elif op in (0xa7, 0xc8):
            pass
        elif op in (0xa8, 0xa9, 0xc9):
            raise UnsupportedFastDac("jsr/ret is rejected by the FastDAC compiler")
        elif 0xac <= op <= 0xb0:
            expected = ("I", "J", "F", "D", "A")[op - 0xac]
            _, result = split_method_descriptor(method.descriptor)
            pop(result if expected == "A" else expected)
            if (expected == "A" and not _reference(result)) or (expected != "A" and _normalized(result) != expected):
                raise UnsupportedFastDac("return opcode disagrees with method signature")
        elif op == 0xb1:
            if split_method_descriptor(method.descriptor)[1] != "V":
                raise UnsupportedFastDac("void return in non-void method")
            if method.name == "<init>" and local[0].startswith("!"):
                raise UnsupportedFastDac("constructor return before superclass initialization")
        elif 0xb2 <= op <= 0xb5:
            member = self.image.pool_field(method, args[0])
            if member.is_static != (op <= 0xb3):
                raise UnsupportedFastDac("field staticness disagrees with opcode")
            data = field(member, op in (0xb3, 0xb5))
        elif op in (0xb6, 0xb7, 0xb8, 0xb9, 0xcd, 0xdb):
            member = self.image.direct_method(args[0]) if op == 0xdb else self.image.pool_method(method, args[0])
            opcode = op
            if op in (0xcd, 0xdb):
                if member.is_static:
                    opcode = 0xb8
                elif member.name == "<init>" or member.owner == method.owner:
                    opcode = 0xb7
                else:
                    opcode = self.image.direct_call_opcode(method, member)
            data = invoke(member, opcode)
        elif op == 0xbb:
            name = self.image.pool_class(method, args[0])
            data, value = self._allocation(name, pc)
            push(value)
        elif op == 0xbc:
            pop("I")
            primitive = {4: "Z", 5: "C", 6: "F", 7: "D", 8: "B", 9: "S", 10: "I", 11: "J"}[args[0]]
            push("[" + primitive)
            data += bytes(args)
        elif op == 0xbd:
            name = self.image.pool_class(method, args[0])
            pop("I")
            push("[" + (name if name.startswith("[") else "L" + name + ";"))
            data += u2(self.pool.class_(name))
        elif op == 0xbe:
            pop("A")
            push("I")
        elif op == 0xbf:
            pop("A")
        elif op in (0xc0, 0xc1):
            name = self.image.pool_class(method, args[0])
            pop("A")
            push("I" if op == 0xc1 else name if name.startswith("[") else "L" + name + ";")
            data += u2(self.pool.class_(name))
        elif op in (0xc2, 0xc3):
            pop("A")
        elif op == 0xc5:
            name = self.image.pool_class(method, args[0])
            for _ in range(args[1]):
                pop("I")
            push(name)
            data += u2(self.pool.class_(name)) + bytes((args[1],))
        elif op in (0xc6, 0xc7):
            pop("A")
            branch = op
        else:
            raise UnsupportedFastDac(f"unsupported opcode {op:#x}")
        return data, branch

    @staticmethod
    def _stack_operation(op: int, stack: list[str]):
        def take() -> str:
            if not stack:
                raise UnsupportedFastDac("operand stack underflow")
            return stack.pop()

        def one(value: str):
            if _width(value) != 1:
                raise UnsupportedFastDac("category-2 value in category-1 stack operation")

        a = take()
        if op == 0x57:
            one(a)
        elif op == 0x58:
            if _width(a) == 1:
                one(take())
        elif op == 0x59:
            one(a)
            stack.extend((a, a))
        elif op == 0x5a:
            b = take()
            one(a)
            one(b)
            stack.extend((a, b, a))
        elif op == 0x5b:
            b = take()
            one(a)
            if _width(b) == 2:
                stack.extend((a, b, a))
            else:
                c = take()
                one(c)
                stack.extend((a, c, b, a))
        elif op == 0x5c:
            if _width(a) == 2:
                stack.extend((a, a))
            else:
                b = take()
                one(b)
                stack.extend((b, a, b, a))
        elif op == 0x5d:
            b = take()
            if _width(a) == 2:
                one(b)
                stack.extend((a, b, a))
            else:
                c = take()
                one(b)
                one(c)
                stack.extend((b, a, c, b, a))
        elif op == 0x5e:
            b = take()
            if _width(a) == 2:
                if _width(b) == 2:
                    stack.extend((a, b, a))
                else:
                    c = take()
                    one(c)
                    stack.extend((a, c, b, a))
            else:
                one(b)
                c = take()
                if _width(c) == 2:
                    stack.extend((b, a, c, b, a))
                else:
                    d = take()
                    one(d)
                    stack.extend((b, a, d, c, b, a))
        elif op == 0x5f:
            b = take()
            one(a)
            one(b)
            stack.extend((a, b))


@dataclass(frozen=True)
class Recovery:
    name: str
    classfile: bytes
    bodies: int
    omissions: tuple[tuple[str, str], ...]


def infer_types(image) -> None:
    """Propagate private field/call types between bodies until stable."""
    methods = sorted(image.methods, key=lambda method: method.address)
    for method in methods:
        if method.descriptor is not None or not method.has_bytecode:
            continue
        if method.parameter_words == (0 if method.is_static else 1):
            if method.return_kind == "void":
                method.descriptor = "()V"
            elif method.return_kind in ("word", "wide"):
                try:
                    returns = {ins.opcode for ins in decode(method.code) if ins.opcode in range(0xac, 0xb1)}
                except UnsupportedFastDac:
                    continue
                if len(returns) == 1:
                    result = {0xac: "I", 0xad: "J", 0xae: "F", 0xaf: "D"}.get(next(iter(returns)))
                    if result:
                        method.descriptor = "()" + result
    previous = None
    seen = set()
    while True:
        for method in methods:
            if not method.has_bytecode or not method.descriptor:
                continue
            try:
                ReverseQuickener(image).compile(method)
            except (ValueError, KeyError, IndexError):
                # Partial constraints still help other callers. Only the final
                # emission pass decides whether a body can be represented.
                pass
        snapshot = (tuple(sorted(getattr(image, "recovered_types", {}).items())),
                    tuple((method.address, method.descriptor) for method in methods))
        if snapshot == previous:
            break
        if snapshot in seen:
            raise UnsupportedFastDac("private member type inference did not converge")
        seen.add(snapshot)
        previous = snapshot
    image.finalize_field_types()


def recover_class(image, cls) -> Recovery:
    """Build a partial class, omitting bodies whose semantics remain unresolved."""
    builder = ClassFileBuilder(cls.name, cls.superclass, flags=cls.access_flags,
                               interfaces=cls.interfaces)
    omissions = []
    bodies = 0
    field_keys = set()
    for member in cls.fields:
        key = (member.name, member.descriptor)
        if not member.descriptor or getattr(member, "initializer_error", None):
            omissions.append((member.name, member.initializer_error or "field type remains unresolved"))
            continue
        if key in field_keys:
            continue
        field_keys.add(key)
        constant = None
        bits = member.constant_bits
        if member.is_static and bits is not None:
            add = {"J": builder.pool.long, "D": builder.pool.double_bits,
                   "F": builder.pool.float_bits}.get(member.descriptor, builder.pool.integer)
            constant = add(bits)
        elif member.is_static and member.constant_value is not None:
            constant = builder.pool.string(member.constant_value)
        builder.add_field(member.name, member.descriptor, member.access_flags, constant_index=constant)
    method_keys = set()
    for method in cls.methods:
        display = method.name + (method.descriptor or "(?)")
        if not method.descriptor:
            omissions.append((display, "method signature remains unresolved"))
            continue
        key = (method.name, method.descriptor)
        if key in method_keys:
            omissions.append((display, "inferred signature collides with another ROM method"))
            continue
        if method.has_bytecode:
            try:
                code = ReverseQuickener(image, builder.pool).compile(method)
            except (ValueError, KeyError, IndexError) as exc:
                omissions.append((display, str(exc)))
                continue
            builder.add_method(method.name, method.descriptor, method.access_flags, code=code)
            bodies += 1
        else:
            if method.name in ("<init>", "<clinit>"):
                omissions.append((display, "initializer is implemented by the native VM"))
                continue
            builder.add_method(method.name, method.descriptor, method.access_flags)
        method_keys.add(key)
    return Recovery(cls.name, builder.to_bytes(), bodies, tuple(omissions))


def write_jar(image, destination: str | Path) -> tuple[Recovery, ...]:
    """Write deterministic class entries for this alternate FastDAC build."""
    infer_types(image)
    recovered = tuple(recover_class(image, cls) for _, cls in sorted(image.classes.items()))
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(destination, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for cls in recovered:
            info = zipfile.ZipInfo(cls.name + ".class", date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            archive.writestr(info, cls.classfile)
    return recovered


def main(argv: list[str] | None = None) -> int:
    from .fastdac_model import FastDacImage

    parser = argparse.ArgumentParser(description="Recover standard classfiles from the Xperia FastDAC ROM")
    parser.add_argument("image", type=Path, help="Xperia Windows Mobile jbed.exe")
    parser.add_argument("output", type=Path, help="output JAR for the alternate FastDAC build")
    args = parser.parse_args(argv)
    recovered = write_jar(FastDacImage(args.image), args.output)
    bodies = sum(cls.bodies for cls in recovered)
    omissions = sum(len(cls.omissions) for cls in recovered)
    print(f"Wrote {len(recovered)} classes and {bodies} recovered method bodies to {args.output}")
    print(f"Omitted {omissions} members with unresolved types, initializers, or bytecode semantics.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
