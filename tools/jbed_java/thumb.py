"""Recover Java operations from the Jbed ARM/Thumb managed-code ABI.

This is an instruction/dataflow lifter, not a catalogue of translated methods.
Register and frame-slot values carry Java types; machine addresses are retained
only while they describe a known Java object, array, or isolate field. Unknown
native operations fail explicitly instead of becoming fabricated Java code.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field as dataclass_field, replace
import json
import re
import struct
from typing import Mapping, Sequence

from capstone import Cs, CS_ARCH_ARM, CS_GRP_JUMP, CS_MODE_THUMB
from capstone.arm import ARM_OP_REG, ARM_OP_IMM, ARM_REG_SP

from .model import (ExceptionRegion, FieldSpec, MethodSpec, RomImage, UnsupportedJava,
                    java_identifier, java_type, mapped_name)
from .structure import (Block, Branch, Jump, Switch, LiftedCFG, Return, Throw,
                        StructureError, structure_cfg)
from .simplify import simplify
from .exceptions import plan_exceptions
from .objects import ObjectModel, NOT_HANDLED as OBJECT_NOT_HANDLED
from .wide import (TypedWord, WideModel, NOT_HANDLED as WIDE_NOT_HANDLED, abi_argument, native_arithmetic_entry,
                   packed_value, unpack_bits, word_count, field_word, replace_field_word)


class UnsupportedThumb(ValueError):
    """An instruction or ABI operation is outside the supported Java subset."""


@dataclass(frozen=True)
class LiftResult:
    body_lines: tuple[str, ...] = ()
    instruction_count: int = 0
    calls: tuple[int, ...] = ()
    failure: str | None = None
    cfg: LiftedCFG | None = None
    exception_regions: tuple[ExceptionRegion, ...] = ()
    handler_locals: Mapping[int, str] | None = None


@dataclass(frozen=True)
class _Value:
    kind: str
    descriptor: str = "I"
    constant: int | None = None
    origin: str | None = None
    alignment: int = 1
    method: MethodSpec | None = None
    type_test: tuple[str, str] | None = None
    typed_word: TypedWord | None = None
    nonnull: bool = False
    frame_alias: int | None = None
    array_length: int | None = None
    string_owner: str | None = None
    string_data: str | None = None
    interface_table: bool = False


_UNKNOWN = _Value("unknown")
_INT = _Value("int")
_RETURN = _Value("return")

# ArchBase passes an exception ID to Base.allocException (0xe23bc).
# ID 5 constructs the ROM's plain Error; ID 7 calls Object.classLoadingError.
_TRAP_EXCEPTIONS = {
    "throwNull": "NullPointerException",
    "throwDiv": "ArithmeticException",
    "throwIndex": "ArrayIndexOutOfBoundsException",
    "throwAbstract": "Error",
    "throwClassCast": "ClassCastException",
    "throwNoClass": "NoClassDefFoundError",
}


@dataclass(frozen=True)
class _Flags:
    address: int
    kind: str
    left: str
    right: str = "0"
    register: int | None = None
    constant: int | None = None
    left_constant: int | None = None
    type_test: tuple[str, str] | None = None


@dataclass
class _State:
    registers: dict[int, _Value]
    stack: dict[int, _Value]
    sp: int = 0
    flags: _Flags | None = None
    carry: str | None = None
    switch_bounds: dict[int, tuple[int, int]] = dataclass_field(default_factory=dict)

    def copy(self):
        return _State(dict(self.registers), dict(self.stack), self.sp, self.flags, self.carry,
                      dict(self.switch_bounds))

    def store_frame(self, offset: int, register: int, value: _Value):
        if self.stack.get(offset, _UNKNOWN).kind == "ref":
            for reg, alias in tuple(self.registers.items()):
                if alias.frame_alias == offset:
                    self.registers[reg] = replace(alias, frame_alias=None)
        if value.kind == "ref":
            self.registers[register] = replace(value, frame_alias=offset)
            value = replace(value, frame_alias=None)
        self.stack[offset] = value


def _signed(value: int) -> int:
    return ((value + 0x80000000) & 0xffffffff) - 0x80000000


def _reference(descriptor: str) -> bool:
    return descriptor.startswith(("L", "["))


def _alignment(number: int) -> int:
    """Known power-of-two divisor of a 32-bit integer (zero has every divisor)."""
    bits = number & 0xffffffff
    return bits & -bits if bits else 1 << 32


class ThumbLifter:
    """Lift one ROM method, using ROM metadata to identify fields and calls."""

    def __init__(self, image: bytes, methods: Mapping[int, MethodSpec],
                 fields: Sequence[FieldSpec], helpers: Mapping[int, str] | None = None,
                 *, superclasses: Mapping[str, str | None] | None = None,
                 rom: RomImage | None = None):
        self.image = image
        self.methods = {address & ~1: method for address, method in methods.items()}
        self.fields = tuple(fields)
        self.helpers = dict(helpers or {})
        self.superclasses = dict(superclasses or {})
        self.rom = rom
        self.pointer_slots = frozenset()
        self.all_methods = rom.methods if rom is not None else tuple(methods.values())
        self.objects = ObjectModel(rom) if rom is not None else None
        self.instance_fields = {}
        self.isolate_fields = {}
        self.global_fields = {}
        for field in self.fields:
            if field.is_static and field.storage not in ("isolate_static", "static"):
                continue
            index = (self.isolate_fields if field.storage == "isolate_static" else
                     self.global_fields if field.storage == "static" else self.instance_fields)
            for offset in (field.offset, field.offset + 4) if field.descriptor in ("J", "D") else (field.offset,):
                key = offset if index is not self.instance_fields else (field.owner, offset)
                index.setdefault(key, []).append(field)
        self.virtual_methods = {}
        for method in self.all_methods:
            if method.virtual_slot >= 0:
                self.virtual_methods.setdefault((method.owner, method.virtual_slot), []).append(method)
        self.concrete_subtypes = {}
        if rom is not None:
            for klass in rom.classes:
                if klass.dimensions or klass.flags & (0x200 | 0x400):
                    continue
                seen, owner = set(), klass.name
                while owner and owner not in seen:
                    seen.add(owner)
                    self.concrete_subtypes.setdefault(owner, []).append(klass)
                    owner = self.superclasses.get(owner)
        self.decoder = Cs(CS_ARCH_ARM, CS_MODE_THUMB)
        self.decoder.detail = True
        self.nonreturning: dict[int, bool] = {}
        self.dispatch_compatible: dict[tuple[int, str], bool] = {}
        self.decoded_instructions = {}

    def decode(self, address: int, end: int):
        if not 0 <= address < end <= len(self.image):
            return None
        if address not in self.decoded_instructions:
            decoded = next(self.decoder.disasm(self.image[address:min(address + 4, len(self.image))],
                                                address, count=1), None)
            # Bound native instruction cache memory during whole-ROM batches.
            if len(self.decoded_instructions) >= 32768:
                self.decoded_instructions.clear()
            self.decoded_instructions[address] = decoded
        instruction = self.decoded_instructions[address]
        return instruction if instruction is not None and address + instruction.size <= end else None

    def direct_dispatch_matches(self, method: MethodSpec, descriptor: str) -> bool:
        """Check the AOT devirtualization decision against the recovered ROM.

        Virtual slots are assigned by Coder.Invoke/FCoder.CallVirtual. A direct
        branch to an inherited implementation can regain invokevirtual when
        every concrete ROM subtype of the declared receiver resolves that
        slot to the same implementation.
        """
        key = (method.address & ~1, descriptor)
        if key in self.dispatch_compatible:
            return self.dispatch_compatible[key]
        if self.rom is None or not descriptor.startswith("L") or method.virtual_slot < 0:
            return False
        owner = descriptor[1:-1]
        found = False
        for klass in self.concrete_subtypes.get(owner, ()):
            found = True
            try:
                target = self.rom.virtual_method(klass.name, method.virtual_slot)
            except UnsupportedJava:
                self.dispatch_compatible[key] = False
                return False
            if target.address & ~1 != method.address & ~1:
                self.dispatch_compatible[key] = False
                return False
        self.dispatch_compatible[key] = found
        return found

    def never_returns(self, method: MethodSpec, active: frozenset[int] = frozenset()) -> bool:
        """Recognize the ROM compiler's eliminated continuation after throw helpers.

        Follow a small callee's native control flow to its explicit VM throw
        operations. Names of application/compiler methods do not select this
        optimization; every reachable path must lack a native return.
        """
        address = method.address & ~1
        if address in self.nonreturning:
            return self.nonreturning[address]
        if (not address or method.is_native or method.is_abstract or method.has_handlers
                or method.size > 1024 or method.descriptor is None or method.return_type != "V"):
            self.nonreturning[address] = False
            return False
        if address in active or len(active) >= 6:
            return False
        active = active | {address}
        end, pending, seen = address + method.size, [address], set()
        while pending:
            position = pending.pop()
            if position in seen:
                continue
            if not address <= position < end or len(seen) >= 512:
                self.nonreturning[address] = False
                return False
            seen.add(position)
            ins = self.decode(position, end)
            if ins is None:
                self.nonreturning[address] = False
                return False
            mnemonic, operands = ins.mnemonic, ins.operands
            names = [ins.reg_name(operand.reg) for operand in operands if operand.type == ARM_OP_REG]
            if (mnemonic == "pop" and "pc" in names or mnemonic in ("mov", "bx") and "pc" in names
                    or mnemonic == "bx" or mnemonic == "add" and names and names[0] == "pc"):
                self.nonreturning[address] = False
                return False
            if mnemonic in ("bl", "blx") and operands[0].type == ARM_OP_IMM:
                target = operands[0].imm & ~1
                callee = self.methods.get(target)
                terminal = bool(callee and callee.owner == "com/jbed/runtime/ArchBase"
                                and (callee.name == "Throw" or callee.name in _TRAP_EXCEPTIONS))
                if terminal or callee is not None and self.never_returns(callee, active):
                    continue
            if mnemonic in ("b", "b.w"):
                target = operands[0].imm & ~1
                if not address <= target < end:
                    callee = self.methods.get(target)
                    if callee is None or not self.never_returns(callee, active):
                        self.nonreturning[address] = False
                        return False
                else:
                    pending.append(target)
                continue
            if mnemonic.startswith("b") and mnemonic not in ("bl", "blx") and operands[0].type == ARM_OP_IMM:
                pending.append(operands[0].imm & ~1)
            pending.append(position + ins.size)
        self.nonreturning[address] = True
        return True

    def lift(self, method: MethodSpec, *, structure: bool = False) -> LiftResult:
        session = _MethodLifter(self, method, structure=structure)
        try:
            return session.run()
        except (UnsupportedThumb, UnsupportedJava, StructureError) as error:
            return LiftResult(instruction_count=len(session.instructions),
                              calls=tuple(sorted(session.calls)), failure=str(error),
                              cfg=session.last_cfg, exception_regions=session.exception_regions,
                              handler_locals=session.handler_locals)


def lift_method(image: RomImage, method: MethodSpec, *, structure: bool = False) -> LiftResult:
    return ThumbLifter(image.data, image.methods_by_address, image.field_specs,
                       helpers=image.helpers, superclasses=image.superclasses, rom=image).lift(method, structure=structure)


class _MethodLifter:
    def __init__(self, parent: ThumbLifter, method: MethodSpec, *, structure: bool = False):
        self.parent, self.method = parent, method
        self.start, self.end = method.address & ~1, (method.address & ~1) + method.size
        self.instructions = {}
        self.locals: dict[str, str] = {}
        self.calls: set[int] = set()
        self.position = self.start
        self.statements: list[str] = []
        self.produce_source = structure
        self.last_cfg: LiftedCFG | None = None
        self.exception_plan = plan_exceptions(method, parent.superclasses)
        self.exception_regions: tuple[ExceptionRegion, ...] = ()
        self.handler_locals: dict[int, str] = {}
        self.guarded_spills: dict[int, tuple[int, int]] = {}

    def fail(self, reason: str):
        raise UnsupportedThumb(f"0x{self.position:x}: {reason}")

    def local(self, name: str, kind: str) -> str:
        previous = self.locals.setdefault(name, kind)
        if previous != kind:
            self.fail(f"inconsistent Java local type for {name}: {previous}/{kind}")
        return name

    @staticmethod
    def reg_number(instruction, reg: int) -> int:
        name = instruction.reg_name(reg)
        aliases = {"sb": 9, "sl": 10, "fp": 11, "ip": 12,
                   "sp": 13, "lr": 14, "pc": 15}
        if name in aliases:
            return aliases[name]
        if name.startswith("r") and name[1:].isdigit():
            return int(name[1:])
        raise UnsupportedThumb(f"unsupported register {name}")

    def bank(self, register: int, value: _Value) -> str:
        if value.kind == "int":
            return self.local(f"i{register}", "int")
        if value.kind in ("ref", "address"):
            return self.local(f"v{register}", "Object")
        self.fail(f"register r{register} contains {value.kind}, not a Java value")

    def slot(self, offset: int, value: _Value) -> str:
        suffix = f"m{-offset}" if offset < 0 else str(offset)
        if value.kind == "int":
            return self.local(f"si_{suffix}", "int")
        if value.kind in ("ref", "address"):
            return self.local(f"sv_{suffix}", "Object")
        self.fail(f"frame slot {offset} contains {value.kind}, not a Java value")

    def value(self, state: _State, register: int) -> _Value:
        if register == 13:
            return _Value("stack", constant=state.sp)
        value = state.registers.get(register, _UNKNOWN)
        if value.kind == "unknown":
            self.fail(f"read of undefined register r{register}")
        return value

    def expression(self, state: _State, register: int) -> str:
        return self.bank(register, self.value(state, register))

    def assign(self, state: _State, register: int, value: _Value, expression: str | None,
               offset_expression: str | None = None):
        if register in (9, 10):
            self.fail("write to reserved VM static-base/stack-limit register requires a runtime intrinsic")
        state.switch_bounds.pop(register, None)
        if state.flags is not None and state.flags.register == register:
            state.flags = replace(state.flags, register=None)
        if register == 13:
            if value.kind != "stack" or value.constant is None:
                self.fail("dynamic stack pointer")
            state.sp = value.constant
            return
        state.registers[register] = value
        if expression is not None and value.kind in ("int", "ref", "address"):
            self.statements.append(f"{self.bank(register, value)} = {expression};")
        if value.kind == "address":
            self.statements.append(f"{self.local(f'o{register}', 'int')} = {offset_expression};")

    def move(self, state: _State, destination: int, source: int):
        value = self.value(state, source)
        expression = self.bank(source, value) if value.kind in ("int", "ref", "address") else None
        offset = self.local(f"o{source}", "int") if value.kind == "address" else None
        self.assign(state, destination, value, expression, offset)

    def operand(self, instruction, state: _State, operand):
        if operand.type == ARM_OP_IMM:
            value = _signed(operand.imm)
            return _Value("int", constant=value, alignment=_alignment(value)), str(value)
        if operand.type == ARM_OP_REG:
            register = self.reg_number(instruction, operand.reg)
            value = self.value(state, register)
            return value, (self.bank(register, value) if value.kind in ("int", "ref", "address") else None)
        self.fail("unsupported instruction operand")

    def narrow(self, expression: str, descriptor: str) -> str:
        if descriptor == "Z":
            return f"({expression} != 0)"
        if descriptor in ("B", "C", "S"):
            return f"(({java_type(descriptor)}) {expression})"
        if descriptor == "I":
            return expression
        if _reference(descriptor):
            return f"(({java_type(descriptor)}) {expression})"
        self.fail(f"unsupported Java value type {descriptor}")

    def java_value(self, value: _Value, expression: str, descriptor: str) -> str:
        if _reference(descriptor):
            if value.kind == "int" and value.constant == 0:
                # Retain the declared argument type for overloaded calls.
                return f"(({java_type(descriptor)}) null)"
            if value.kind != "ref":
                self.fail(f"{value.kind} used as reference {descriptor}")
        elif value.kind != "int":
            self.fail(f"{value.kind} used as integer {descriptor}")
        return self.narrow(expression, descriptor)

    def load_java(self, state: _State, destination: int, descriptor: str, expression: str):
        if WideModel.load_java(self, state, destination, descriptor, expression):
            return
        if descriptor == "V":
            self.fail(f"unsupported load type {descriptor}")
        value = _Value("ref", descriptor, origin=f"value:{self.position:x}") if _reference(descriptor) else _INT
        self.assign(state, destination, value,
                    f"({expression} ? 1 : 0)" if descriptor == "Z" else expression)

    def field(self, owner: str, offset: int) -> FieldSpec:
        declared = owner
        seen = set()
        while owner and owner not in seen:
            seen.add(owner)
            candidates = self.parent.instance_fields.get((owner, offset), ())
            if len(candidates) == 1:
                return candidates[0]
            if candidates:
                self.fail(f"ambiguous instance field {owner}+{offset}")
            owner = self.parent.superclasses.get(owner)
        # FCoder can drop a downcast to the sole concrete ROM subclass.
        # Recover its own field only when the abstract base has no such slot.
        rom = self.parent.rom
        base = rom.by_name.get(declared) if rom else None
        concrete = self.parent.concrete_subtypes.get(declared, ())
        if (base and base.flags & 0x400 and len(concrete) == 1 and concrete[0].tag_address
                and concrete[0].name == self.method.owner):
            candidates = self.parent.instance_fields.get((self.method.owner, offset), ())
            if len(candidates) == 1:
                return candidates[0]
        self.fail(f"unresolved instance field at offset {offset}")

    def static_field(self, offset: int) -> FieldSpec:
        candidates = self.parent.isolate_fields.get(offset, ())
        if len(candidates) != 1:
            self.fail(f"isolate offset {offset} has {len(candidates)} field identities")
        return candidates[0]

    def virtual_method(self, table: _Value, slot: int) -> MethodSpec:
        descriptor = table.descriptor
        owner = descriptor[1:-1] if descriptor.startswith("L") else "java/lang/Object"
        rom = self.parent.rom
        if rom is not None and owner in rom.by_name and rom.by_name[owner].is_interface and not table.interface_table:
            return rom.implementation_slot(owner, slot)
        seen = set()
        while owner and owner not in seen:
            seen.add(owner)
            candidates = self.parent.virtual_methods.get((owner, slot), ())
            if len(candidates) == 1:
                return candidates[0]
            if candidates:
                self.fail(f"ambiguous virtual slot {owner}:{slot}")
            owner = None if table.interface_table else self.parent.superclasses.get(owner)
        self.fail(f"unresolved virtual slot {descriptor}:{slot}")

    def flags_result(self, state: _State, expression: str):
        name = self.local(f"z_{self.position:x}", "int")
        self.statements.append(f"{name} = {expression};")
        source = state.registers.get(int(expression[1:])) if re.fullmatch(r"i\d+", expression) else None
        state.flags = _Flags(self.position, "result", name, type_test=source.type_test if source else None)

    def comparison(self, state: _State, left: _Value, lhs: str | None,
                   right: _Value, rhs: str | None):
        if left.kind == "limit" and right.kind == "stack":
            state.flags = _Flags(self.position, "stack", "")
            return
        if left.kind == "ref" or right.kind == "ref":
            def reference(value, expression):
                if value.kind == "ref":
                    return expression
                if value.kind == "int" and value.constant == 0:
                    return "null"
                self.fail("reference compared with non-null integer")
            lhs, rhs = reference(left, lhs), reference(right, rhs)
            kind, java = "ref", "Object"
        elif left.kind == right.kind == "int":
            kind, java = "cmp", "int"
        else:
            self.fail(f"comparison of {left.kind} and {right.kind}")
        prefix = f"c_{self.position:x}" + ("r" if kind == "ref" else "")
        a, b = self.local(prefix + "a", java), self.local(prefix + "b", java)
        self.statements.extend((f"{a} = {lhs};", f"{b} = {rhs};"))
        register = int(lhs[1:]) if lhs and re.fullmatch(r"[iv]\d+", lhs) else None
        state.flags = _Flags(self.position, kind, a, b, register,
                             right.constant if right.kind == "int" else None,
                             left.constant if left.kind == "int" else None, left.type_test)

    def decode(self, address: int):
        if not self.start <= address < self.end:
            return None
        return self.parent.decode(address, self.end)

    def spill_guard(self, load):
        """Match a cleanup's two zero tests whose shared exit kills the loaded word."""
        if (load.mnemonic != "ldr" or load.size != 2 or load.operands[1].mem.base != ARM_REG_SP):
            return None
        dest = load.operands[0].reg
        check, skip, other, skip_other = (self.decode(load.address + n) for n in (2, 4, 6, 8))
        if not all(ins and ins.size == 2 for ins in (check, skip, other, skip_other)):
            return None
        if (check.mnemonic != "cmp" or check.op_str != f"{load.reg_name(dest)}, #0"
                or other.mnemonic != "cmp" or not re.fullmatch(r"r[456], #0", other.op_str)
                or other.operands[0].reg == dest or skip.mnemonic != "beq" or skip_other.mnemonic != "beq"
                or skip.operands[0].imm != skip_other.operands[0].imm):
            return None
        kill = self.decode(skip.operands[0].imm)
        if (kill and kill.mnemonic in ("mov", "movs") and kill.operands[0].reg == dest
                and re.fullmatch(r"r[0-7], r[0-7]", kill.op_str) and kill.operands[1].reg != dest):
            return other.operands[0].reg
        return None

    def spill_defined_or_guard_zero(self, use, offset, guard, predecessors):
        # Every incoming path must supply the saved integer or a zero guard.
        # Follow only instructions that preserve both, including calls whose
        # ABI preserves r4-r6. Exception edges carry the pre-call frame.
        register = self.reg_number(self.instructions[use], guard)
        pending, seen = [use], set()
        while pending:
            address = pending.pop()
            if address in seen:
                continue
            seen.add(address)
            for (source, kind), state in predecessors[address].items():
                word = state.stack.get(offset, _UNKNOWN)
                flag = state.registers.get(register, _UNKNOWN)
                if word.kind == "int" or flag.kind == "int" and flag.constant == 0:
                    continue
                if source < 0 or word.kind != "unknown":
                    return False
                ins = self.instructions[source]
                if ins.mnemonic not in ("bl", "blx"):
                    if (kind != "normal" or ins.mnemonic.startswith(("st", "vst", "push"))
                            or guard in ins.regs_access()[1]
                            or source + ins.size != address and not ins.group(CS_GRP_JUMP)):
                        return False
                pending.append(source)
        return True

    def checkpoint(self, instruction, state: _State):
        """Invert FCoder.InsertCheckPoint's five-instruction scheduler poll."""
        operands = instruction.operands
        if (instruction.mnemonic != "mov" or len(operands) != 2
                or any(operand.type != ARM_OP_REG for operand in operands)
                or self.reg_number(instruction, operands[1].reg) != 8):
            return None
        work = self.reg_number(instruction, operands[0].reg)
        decoded = [instruction]
        for _ in range(4):
            following = self.decode(decoded[-1].address + decoded[-1].size)
            if following is None:
                return None
            decoded.append(following)
        subtract, store, branch, call = decoded[1:]
        if (subtract.mnemonic != "subs" or len(subtract.operands) != 2
                or subtract.operands[0].type != ARM_OP_REG or subtract.operands[1].type != ARM_OP_IMM
                or self.reg_number(subtract, subtract.operands[0].reg) != work
                or subtract.operands[1].imm != 1
                or store.mnemonic != "mov" or len(store.operands) != 2
                or any(operand.type != ARM_OP_REG for operand in store.operands)
                or self.reg_number(store, store.operands[0].reg) != 8
                or self.reg_number(store, store.operands[1].reg) != work
                or branch.mnemonic != "bne" or call.mnemonic != "bl"
                or call.operands[0].type != ARM_OP_IMM
                or branch.operands[0].imm != call.address + call.size):
            return None
        helper = self.parent.methods.get(call.operands[0].imm & ~1)
        if (helper is None or helper.owner != "com/jbed/runtime/SchedulerInlines"
                or helper.name != "checkPoint" or helper.descriptor != "()V"):
            return None
        for ins in decoded:
            self.instructions[ins.address] = ins
        state.registers[work] = _UNKNOWN
        state.switch_bounds.pop(work, None)
        state.flags = None
        state.carry = None
        return Jump(call.address + call.size)

    def table_switch(self, instruction, state: _State):
        """Invert the two dense-table encodings used by Jbed's compilers.

        FCoder.TableJump emits four-byte branch entries selected with ADD PC.
        The ROM compiler also emits signed halfword offsets selected by a
        guarded ADD-PC/LDRSH sequence. The predecessor's unsigned range guard
        supplies the exact table bound, so literal data is never disassembled.
        """
        operands = instruction.operands
        if len(operands) != 3 or operands[0].type != ARM_OP_REG or operands[1].type != ARM_OP_REG or operands[2].type != ARM_OP_IMM:
            return None
        work = self.reg_number(instruction, operands[0].reg)
        index = self.reg_number(instruction, operands[1].reg)
        bound = state.switch_bounds.get(index)
        if bound is None or not 0 <= bound[0] <= 65535:
            return None
        maximum, fallback = bound
        following = self.decode(instruction.address + instruction.size)
        if following is None:
            return None
        consumed = [instruction, following]

        def register_add(ins, destination, source):
            return (ins is not None and ins.mnemonic == "add" and len(ins.operands) == 2
                    and all(operand.type == ARM_OP_REG for operand in ins.operands)
                    and self.reg_number(ins, ins.operands[0].reg) == destination
                    and self.reg_number(ins, ins.operands[1].reg) == source)

        if instruction.mnemonic == "adds" and work != index and operands[2].imm == 2 and register_add(following, work, 15):
            load = self.decode(following.address + following.size)
            branch = self.decode(load.address + load.size) if load else None
            if (load is None or load.mnemonic != "ldrsh" or len(load.operands) != 2
                    or self.reg_number(load, load.operands[0].reg) != work
                    or self.reg_number(load, load.operands[1].mem.base) != work
                    or self.reg_number(load, load.operands[1].mem.index) != index
                    or load.operands[1].mem.disp != 0 or not register_add(branch, 15, work)):
                return None
            table = following.address + 4 + 2
            base = branch.address + 4
            if table + 2 * (maximum + 1) > self.end:
                self.fail("relative switch table exceeds its owning method")
            cases = tuple((case, base + struct.unpack_from("<h", self.parent.image, table + 2 * case)[0])
                          for case in range(maximum + 1))
            consumed.extend((load, branch))
        elif instruction.mnemonic == "lsls" and operands[2].imm == 2:
            extra = 0
            branch = following
            if (following.mnemonic == "adds" and len(following.operands) == 2
                    and following.operands[0].type == ARM_OP_REG and following.operands[1].type == ARM_OP_IMM
                    and self.reg_number(following, following.operands[0].reg) == work
                    and following.operands[1].imm == 2):
                extra = 2
                branch = self.decode(following.address + following.size)
                consumed.append(branch)
            if not register_add(branch, 15, work):
                return None
            table = branch.address + 4 + extra
            if table + 4 * (maximum + 1) > self.end:
                self.fail("branch switch table exceeds its owning method")
            cases = tuple((case, table + 4 * case) for case in range(maximum + 1))
        else:
            return None
        if any(target & 1 or not self.start <= target < self.end for _, target in cases):
            self.fail("switch table points outside its owning method")
        for decoded in consumed:
            self.instructions[decoded.address] = decoded
        index_value = self.value(state, index)
        selector = self.bank(index, index_value)
        state.registers[work] = _UNKNOWN
        state.switch_bounds.pop(work, None)
        state.flags = None
        state.carry = None
        if index_value.constant is not None:
            key = index_value.constant
            return Jump(cases[key][1] if 0 <= key <= maximum else fallback)
        return Switch(selector, cases, fallback)

    def string_byte_array_terminator(self, state: _State) -> bool:
        if (self.method.owner, self.method.name, self.method.descriptor) != (
                "java/lang/String", "getISO8859_1Bytes", "()[B"):
            return False
        array = state.registers.get(0, _UNKNOWN)
        cursor = state.registers.get(2, _UNKNOWN)
        if (array.kind != "ref" or array.descriptor != "[B" or not (array.origin or "").startswith("array:")
                or cursor.kind != "address" or cursor.origin != array.origin
                or not self.start + 8 <= self.position <= self.end - 14):
            return False
        # The conversion loop writes one byte per UTF-16 character and advances
        # to the next untouched byte. tryAlloc zeroes the whole 32-byte-rounded
        # block. At the logical end, the guarded NUL is in that block's padding;
        # if the signed source-pointer comparison skipped the loop, it's in
        # already-zero storage. A 32-byte boundary skips the store entirely.
        tail = struct.unpack_from("<11H", self.parent.image, self.position - 8)
        return (tail[:4] == (0x7013, 0x3102, 0x3201, 0xe7f0)  # strb r3,[r2]; cursors +2/+1; loop
                and tail[4:8] == (0x06d1, 0x0ec9, 0x2900, 0xd001)  # if ((r2 & 31) == 0) skip
                and tail[8:] == (0x2100, 0x7011, 0xbdb0))  # store byte zero and return r0

    def condition(self, state: _State, mnemonic: str) -> str | bool:
        flags = state.flags
        if flags is None:
            self.fail("branch has unknown incoming condition flags")
        cc = mnemonic.removeprefix("b").removesuffix(".w")
        if flags.kind == "cmp" and flags.left_constant is not None and flags.constant is not None:
            left, right = flags.left_constant, flags.constant
            comparison = {"eq": left == right, "ne": left != right,
                          "lt": left < right, "le": left <= right, "gt": left > right, "ge": left >= right,
                          "mi": _signed(left - right) < 0, "pl": _signed(left - right) >= 0,
                          "hi": (left & 0xffffffff) > (right & 0xffffffff),
                          "ls": (left & 0xffffffff) <= (right & 0xffffffff),
                          "hs": (left & 0xffffffff) >= (right & 0xffffffff),
                          "cs": (left & 0xffffffff) >= (right & 0xffffffff),
                          "lo": (left & 0xffffffff) < (right & 0xffffffff),
                          "cc": (left & 0xffffffff) < (right & 0xffffffff)}
            if cc in comparison:
                return comparison[cc]
        if flags.kind == "stack":
            if cc == "ls":
                return True
            self.fail("unrecognized stack-overflow guard")
        signed = {"eq": "==", "ne": "!=", "lt": "<", "le": "<=", "gt": ">", "ge": ">=",
                  "mi": "<", "pl": ">="}
        if flags.kind == "ref" and cc not in ("eq", "ne"):
            self.fail("ordered reference comparison")
        if flags.kind == "result":
            carry = WideModel.carry_condition(state, cc)
            if carry is not WIDE_NOT_HANDLED:
                return carry
        if flags.kind == "result" and cc not in ("eq", "ne", "mi", "pl"):
            self.fail(f"branch {cc} needs carry/overflow flags")
        if flags.kind == "cmp" and cc in ("mi", "pl"):
            # BMI/BPL inspect N alone, unlike signed BLT/BGE (N xor V).
            # Java int subtraction preserves the machine's 32-bit wraparound.
            return f"({flags.left} - {flags.right}) {'<' if cc == 'mi' else '>='} 0"
        if cc in signed:
            return f"{flags.left} {signed[cc]} {flags.right}"
        unsigned = {"hi": ">", "ls": "<=", "hs": ">=", "cs": ">=", "lo": "<", "cc": "<"}
        if flags.kind == "cmp" and cc in unsigned:
            return f"({flags.left} & 0xffffffffL) {unsigned[cc]} ({flags.right} & 0xffffffffL)"
        self.fail(f"unsupported branch condition {cc}")

    def wide_memory_pair(self, instruction, state, descriptor, expression, load):
        """The ROM accesses D/J storage low word first, often with two LDR/STR."""
        high = self.decode(instruction.address + instruction.size)
        if high is None or high.mnemonic != instruction.mnemonic:
            return None
        memory, second = instruction.operands[1].mem, high.operands[1].mem
        low_reg = self.reg_number(instruction, instruction.operands[0].reg)
        high_reg = self.reg_number(high, high.operands[0].reg)
        if (memory.index or second.index or memory.base != second.base or
                second.disp != memory.disp + 4 or high_reg == low_reg or
                load and self.reg_number(instruction, memory.base) == low_reg):
            return None
        if any(instruction.address < boundary <= high.address for r in self.method.exception_regions
               for boundary in (r.start, r.end, r.handler)):
            return None
        if load:
            WideModel.load_java(self, state, low_reg, descriptor, expression, high_reg)
        else:
            values = [self.value(state, reg) for reg in (low_reg, high_reg)]
            if any(value.kind != "int" for value in values):
                self.fail("non-integer word stored into wide Java value")
            words = [self.bank(reg, value) for reg, value in zip((low_reg, high_reg), values)]
            source = packed_value(descriptor, values, words)
            if not source.isidentifier():
                # The STR pair leaves both registers intact. Subsequent uses
                # of this joined value need no second evaluation.
                source = WideModel.snapshot(self, state, descriptor, source, f"stored_{instruction.address:x}")
                for part, reg in enumerate((low_reg, high_reg)):
                    state.registers[reg] = replace(state.registers[reg],
                                                   typed_word=TypedWord(source, descriptor, part))
            self.statements.append(f"{expression} = {source};")
        self.instructions[high.address] = high
        return Jump(high.address + high.size)

    def packed_bytes(self, instruction, state, register, array, offset, width, load,
                     within_array):
        # The code-block writer and loader access little-endian words in byte[]
        # staging buffers. Halfwords can start at an odd payload index.
        if load:
            parts = [f"(({array}[({offset}) + {i}] & 255) << {8 * i})" for i in range(width)]
            word = "(" + " | ".join(parts) + ")"
            if instruction.mnemonic == "ldrsh":
                word = "(short) " + word
            self.assign(state, register, _INT, word)
        else:
            value = self.value(state, register)
            if value.kind != "int":
                self.fail("non-integer packed byte-array store")
            source = self.bank(register, value)
            if not within_array:
                # Check the last index before changing any byte of this single
                # STR/STRH. A negative first index then fails at the first store.
                check = self.local(f"bound_{self.position:x}", "int")
                self.statements.append(f"{check} = {array}[({offset}) + {width - 1}];")
            for i in range(width):
                self.statements.append(f"{array}[({offset}) + {i}] = (byte) ({source} >>> {8 * i});")

    def memory(self, instruction, state: _State, load: bool):
        operands = instruction.operands
        register = self.reg_number(instruction, operands[0].reg)
        memory = operands[1].mem
        base = self.reg_number(instruction, memory.base)
        displacement = memory.disp
        index_expression = None
        index_alignment = 1 << 32
        if memory.index:
            index_register = self.reg_number(instruction, memory.index)
            index = self.value(state, index_register)
            if index.kind != "int":
                self.fail("non-integer load/store index")
            if index.constant is not None:
                displacement += index.constant
            else:
                index_expression = self.bank(index_register, index)
                index_alignment = index.alignment
        if base == 15:
            if not load:
                self.fail("store through program counter")
            if index_expression:
                self.fail("dynamic program-counter load")
            address = ((instruction.address + 4) & ~3) + displacement
            if address < 0 or address + 4 > len(self.parent.image):
                self.fail("literal pool lies outside the image")
            number = _signed(struct.unpack_from("<I", self.parent.image, address)[0])
            literal = self.parent.objects.literal(number) if self.parent.objects else None
            if literal is not None:
                self.assign(state, register, _Value("ref", literal.descriptor,
                            constant=literal.address, origin=f"literal:{literal.address:x}", nonnull=True), literal.expression)
                return
            if address in self.parent.pointer_slots:
                self.assign(state, register, _Value("image_address", constant=number), None)
                return
            self.assign(state, register, _Value("int", constant=number, alignment=_alignment(number)), str(number))
            return
        value = self.value(state, base)
        wide_offset = 0
        if value.string_data is not None:
            if not load or instruction.mnemonic not in ("ldrh", "ldrsh"):
                self.fail("non-character access through String cursor")
            if min(value.alignment, _alignment(displacement), index_alignment) < 2:
                self.fail("unaligned String character access")
            if self.method.owner == "java/lang/String" and self.method.name == "charAt":
                self.fail("String.charAt reads the VM's UTF-16 backing store")
            address = self.bank(base, value)
            if displacement:
                address += f" + ({displacement})"
            if index_expression:
                address += f" + {index_expression}"
            char = f"((java.lang.String) {value.string_owner}).charAt(({address} - {value.string_data}) >> 1)"
            self.assign(state, register, _INT, "(short) " + char if instruction.mnemonic == "ldrsh" else char)
            return
        string_owner = None
        if value.kind == "stack":
            if index_expression:
                self.fail("dynamic frame-slot index")
            offset = value.constant + displacement
            if load:
                loaded = state.stack.get(offset, _UNKNOWN)
                if loaded.kind == "unknown":
                    guard = self.spill_guard(instruction) if self.method.has_handlers and offset < 0 else None
                    if guard is None:
                        self.fail(f"read of undefined frame slot {offset}")
                    self.guarded_spills[self.position] = offset, guard
                    loaded = _INT
                if loaded.kind == "ref":
                    loaded = replace(loaded, frame_alias=offset)
                expression = self.slot(offset, loaded) if loaded.kind in ("int", "ref", "address") else None
                self.assign(state, register, loaded, expression,
                            self.local(f"so_{'m' + str(-offset) if offset < 0 else offset}", "int")
                            if loaded.kind == "address" else None)
            else:
                stored = self.value(state, register)
                state.store_frame(offset, register, stored)
                if stored.kind in ("int", "ref", "address"):
                    self.statements.append(f"{self.slot(offset, stored)} = {self.bank(register, stored)};")
                if stored.kind == "address":
                    name = f"so_{'m' + str(-offset) if offset < 0 else offset}"
                    self.statements.append(f"{self.local(name, 'int')} = {self.local(f'o{register}', 'int')};")
            return
        if value.kind == "static":
            if index_expression:
                self.fail("dynamic isolate-field index")
            field = self.static_field((value.constant or 0) + displacement)
            descriptor = field.descriptor
            wide_offset = (value.constant or 0) + displacement - field.offset
            expression = f"{mapped_name(field.owner)}.{java_identifier(field.name)}"
        elif value.kind in ("int", "image_address") and value.constant is not None and not index_expression:
            address = (value.constant + displacement) & 0xffffffff
            candidates = self.parent.global_fields.get(address, ())
            if len(candidates) != 1:
                self.fail(f"absolute address 0x{address:x} has {len(candidates)} static field identities")
            field = candidates[0]
            descriptor = field.descriptor
            wide_offset = address - field.offset
            expression = f"{mapped_name(field.owner)}.{java_identifier(field.name)}"
        elif value.kind == "vtable":
            if not load or instruction.mnemonic != "ldr" or index_expression:
                self.fail("unsupported virtual table access")
            offset = (value.constant or 0) + displacement
            if offset == 0 and value.origin is not None:
                if (self.method.owner == "java/lang/Object" and self.method.name == "getClass"
                        and self.method.descriptor == "()Ljava/lang/Class;"):
                    self.fail("Object.getClass reads the VM object header and requires a runtime intrinsic")
                self.load_java(state, register, "Ljava/lang/Class;", f"{value.origin}.getClass()")
                return
            if offset < 8 or offset % 4:
                self.fail(f"unresolved class-header access at offset {offset}")
            target = self.virtual_method(value, (offset - 8) // 4)
            self.assign(state, register, _Value("method", value.descriptor, method=target), None)
            return
        elif value.kind in ("ref", "address"):
            descriptor = value.descriptor
            expression = self.bank(base, value)
            if value.kind == "ref" and displacement == 0 and load and not index_expression:
                if instruction.mnemonic != "ldr":
                    self.fail("object header requires a word load")
                receiver = self.local(f"header_{self.position:x}", "Object")
                self.statements.append(f"{receiver} = {expression};")
                self.assign(state, register, _Value("vtable", descriptor, constant=0, origin=receiver), None)
                return
            if descriptor.startswith("["):
                cast = f"(({java_type(descriptor)}) {expression})"
                if (not load and descriptor in ("[B", "[Z", "[C", "[S") and not index_expression
                        and instruction.mnemonic in ("str", "strh")
                        and (value.kind == "ref" or value.constant is not None)
                        and ObjectModel.store_packed_constant(self, state, register, value, cast,
                            (value.constant if value.kind == "address" else 0) + displacement - 16,
                            4 if instruction.mnemonic == "str" else 2)):
                    return
                if value.kind == "ref" and displacement == 12 and load and not index_expression:
                    if instruction.mnemonic != "ldr":
                        self.fail("array length requires a word load")
                    self.assign(state, register, _INT, f"{cast}.length")
                    return
                element = descriptor[1:]
                sizes = {"Z": 1, "B": 1, "C": 2, "S": 2, "I": 4, "F": 4, "J": 8, "D": 8}
                size = 4 if _reference(element) else sizes.get(element)
                if size is None:
                    self.fail(f"unsupported array component {element}")
                byte_offset = f"{self.local(f'o{base}', 'int')} + {displacement - 16}" if value.kind == "address" else str(displacement - 16)
                if index_expression:
                    byte_offset += f" + {index_expression}"
                alignment = min(value.alignment if value.kind == "address" else 1 << 32,
                                _alignment(displacement - 16), index_alignment)
                if alignment < min(size, 4):
                    self.fail("array address is not provably aligned to its element size")
                if size == 8:
                    if value.kind == "address" and value.alignment < 8 and value.constant is None:
                        self.fail("wide array word has an unknown low/high half")
                    if index_alignment < 8:
                        self.fail("wide array index does not identify an element")
                    wide_offset = ((value.constant or 0) + displacement - 16) % 8
                if value.kind == "ref" and not index_expression and displacement < 16:
                    self.fail("array access outside aligned Java element storage")
                if element == "B" and instruction.mnemonic in ("ldr", "ldrh", "ldrsh", "str", "strh"):
                    width = 4 if instruction.mnemonic in ("ldr", "str") else 2
                    known = None
                    if not index_expression and (value.kind == "ref" or value.constant is not None):
                        known = (value.constant if value.kind == "address" else 0) + displacement - 16
                    if known is not None and (known < 0 or value.array_length is not None
                                              and known + width > value.array_length):
                        self.fail("packed access extends beyond byte-array payload")
                    self.packed_bytes(instruction, state, register, cast, byte_offset, width, load,
                                      known is not None and value.array_length is not None)
                    return
                index = f"(({byte_offset}) >> {size.bit_length() - 1})" if size > 1 else f"({byte_offset})"
                expression, descriptor = f"{cast}[{index}]", element
            elif descriptor.startswith("L") and not index_expression:
                if value.kind == "address" and value.constant is None:
                    self.fail("object field has a dynamic native offset")
                field_offset = displacement + (value.constant if value.kind == "address" else 0)
                field = self.field(descriptor[1:-1], field_offset)
                descriptor = field.descriptor
                wide_offset = field_offset - field.offset
                expression = f"(({mapped_name(field.owner)}) {expression}).{java_identifier(field.name)}"
                if (load and field.owner == "java/lang/String" and field.name in ("value", "addr")
                        and (value.origin == "this" or value.origin in self.method.parameter_names)):
                    string_owner = value.origin
            else:
                self.fail("unresolved object interior address")
        else:
            self.fail(f"memory access through {value.kind}")
        if not descriptor:
            self.fail("unresolved field descriptor")
        # A Java field read already has the signedness of its declared type.
        # Require the machine access width to agree with that layout.
        width = 1 if instruction.mnemonic.endswith(("b", "sb")) else 2 if instruction.mnemonic.endswith(("h", "sh")) else 4
        expected = 1 if descriptor in ("Z", "B") else 2 if descriptor in ("C", "S") else 4
        if width != expected:
            self.fail(f"{width}-byte access to {descriptor} storage")
        if descriptor in ("J", "F", "D"):
            if descriptor in ("J", "D") and wide_offset == 0:
                pair = self.wide_memory_pair(instruction, state, descriptor, expression, load)
                if pair is not None:
                    return pair
            if load and descriptor == "F":
                self.load_java(state, register, descriptor, expression)
            elif load:
                self.assign(state, register, _INT, field_word(descriptor, expression, wide_offset))
            else:
                stored = self.value(state, register)
                if stored.kind != "int":
                    self.fail("non-integer word stored into wide Java value")
                word = self.bank(register, stored)
                result = (packed_value(descriptor, [stored], [word]) if descriptor == "F" else
                          replace_field_word(descriptor, expression, word, wide_offset))
                self.statements.append(f"{expression} = {result};")
            return
        if load:
            self.load_java(state, register, descriptor, expression)
            if string_owner:
                state.registers[register] = replace(state.registers[register], string_owner=string_owner)
            # Unsigned byte/halfword reads differ from Java signed fields.
            if descriptor == "B" and instruction.mnemonic == "ldrb":
                self.assign(state, register, _INT, f"{self.bank(register, _INT)} & 255")
            if descriptor == "S" and instruction.mnemonic == "ldrh":
                self.assign(state, register, _INT, f"{self.bank(register, _INT)} & 65535")
            if descriptor == "C" and instruction.mnemonic == "ldrsh":
                self.assign(state, register, _INT, f"(short) {self.bank(register, _INT)}")
        else:
            stored = self.value(state, register)
            expression_value = self.java_value(stored, self.bank(register, stored), descriptor)
            self.statements.append(f"{expression} = {expression_value};")

    def runtime_helper(self, target: int) -> str | None:
        # Recognize compiler ABI entrypoints from ROM identities, independently
        # of their placement or the identity of the method being recovered.
        helper = self.parent.helpers.get(target)
        if helper:
            return helper.rsplit(".", 1)[-1].split("(", 1)[0]
        method = self.parent.methods.get(target)
        if (method and method.owner == "com/jbed/runtime/ArchBase" and method.is_static
                and (method.descriptor == "()V" or method.name == "throwStackLargeFrame"
                     and method.descriptor == "(I)I")):
            return method.name
        return None

    def call(self, target: int, state: _State, *, tail: bool = False,
             resolved_method: MethodSpec | None = None, virtual: bool = False):
        if self.parent.objects is not None and not virtual:
            operation = self.parent.objects.lower_call(self, target, state, tail=tail)
            if operation is not OBJECT_NOT_HANDLED:
                return operation
        wide = WideModel.lower_call(self, target, state, tail=tail)
        if wide is not WIDE_NOT_HANDLED:
            return wide
        helper = self.runtime_helper(target)
        if helper in ("interfaceStub", "interfaceStubH") and self.parent.objects is not None:
            interface = self.value(state, 3)
            if interface.constant is None:
                self.fail("interface dispatch lacks its ROM Class identity")
            klass = self.parent.objects.class_at(interface.constant & 0xffffffff)
            if not klass.is_interface:
                self.fail("interface dispatch names a non-interface class")
            self.assign(state, 3, _Value("vtable", f"L{klass.name};", constant=0, interface_table=True), None)
            if not tail:
                state.registers[14] = _UNKNOWN
            state.flags = None
            state.carry = None
            return None
        via = re.fullmatch(r"callViaR([0-6])(?:_section_)?", helper or "")
        if via:
            function = self.value(state, int(via.group(1)))
            if function.kind == "method" and function.method:
                return self.call(function.method.address & ~1, state, tail=tail,
                                 resolved_method=function.method, virtual=True)
            if function.kind in ("int", "image_address") and function.constant is not None:
                return self.call(function.constant & ~1, state, tail=tail)
            self.fail("unresolved register-call trampoline")
        if helper in _TRAP_EXCEPTIONS:
            return Throw(f"new {_TRAP_EXCEPTIONS[helper]}()")
        if helper in ("throwStack", "throwStackLargeFrame"):
            self.fail("unrecognized stack-overflow path")
        method = resolved_method or self.parent.methods.get(target)
        if method is None:
            self.fail(f"unresolved call target 0x{target:x}")
        # Jbed folds disabled build options to MOVS r0,#imm8; MOV pc,lr.
        # Preserve that constant across callers, including erased reference
        # returns whose only live continuation is a null trap.
        if (not virtual and method.is_static and not method.flags & 0x20 and method.size == 4
                and not method.is_native and not method.has_handlers):
            move, ret = struct.unpack_from("<HH", self.parent.image, target)
            if move >> 8 == 0x20 and ret in (0x46f7, 0x4770):
                if method.owner != self.method.owner:
                    self.statements.append(f"__jbed_ensure_initialized({json.dumps(method.owner)});")
                immediate = move & 255
                self.assign(state, 0, _Value("int", constant=immediate, alignment=_alignment(immediate)), str(immediate))
                self.flags_result(state, self.bank(0, _INT))
                if not tail:
                    state.registers[14] = _UNKNOWN
                self.calls.add(target)
                return None
        if method.descriptor is None:
            self.fail(f"unresolved descriptor for {method.owner}.{method.name}")
        if (method.owner == "com/jbed/runtime/ArchBase" and method.name == "Throw"
                and method.descriptor == "(Ljava/lang/Throwable;)V"):
            value = self.value(state, 0)
            if value.kind == "int" and value.constant == 0:
                return Throw("null")
            throwable = "Ljava/lang/Throwable;"
            typ = value.descriptor if self.common_reference(value.descriptor, throwable) == throwable else throwable
            return Throw(self.java_value(value, self.bank(0, value), typ))
        descriptors = (() if method.is_static else (f"L{method.owner};",)) + method.argument_types
        arguments = []
        argument_values = []
        index = 0
        for descriptor in descriptors:
            words, values = [], []
            for _ in range(word_count(descriptor)):
                if index < 4:
                    value = self.value(state, index)
                    expression = self.bank(index, value)
                else:
                    offset = state.sp + (index - 4) * 4
                    value = state.stack.get(offset, _UNKNOWN)
                    if value.kind == "unknown":
                        self.fail(f"call argument in undefined frame slot {offset}")
                    expression = self.slot(offset, value)
                words.append(expression)
                values.append(value)
                index += 1
            if descriptor in ("J", "F", "D"):
                if any(value.kind != "int" for value in values):
                    self.fail("non-integer word in wide call argument")
                arguments.append(packed_value(descriptor, values, words))
            else:
                arguments.append(self.java_value(values[0], words[0], descriptor))
            argument_values.append(values[0])
        if method.is_constructor:
            self.fail("constructor call requires allocation/initialization recovery")
        if method.name == "<clinit>":
            self.fail("explicit class-initializer call")
        if method.is_static:
            expression = f"{mapped_name(method.owner)}.{java_identifier(method.name)}({', '.join(arguments)})"
        else:
            receiver = arguments[0]
            special_expression = None
            owner_flags = 0
            if self.parent.rom is not None and method.owner in self.parent.rom.by_name:
                owner_flags = self.parent.rom.by_name[method.owner].flags
            devirtualized = (method.virtual_slot < 0 or
                             bool(owner_flags & 0x800000 and not method.flags & 0x200000) or
                             self.parent.direct_dispatch_matches(method, argument_values[0].descriptor))
            if not virtual and not (method.flags & 0x2 or (method.flags | owner_flags) & 0x10):
                # A direct native branch does not dynamically dispatch. A
                # Java virtual invocation would introduce overrides that the
                # machine code never visits; only a proven super call is safe.
                owner = self.parent.superclasses.get(self.method.owner)
                resolved = None
                if (argument_values[0].origin == "this" or
                        argument_values[0].descriptor == f"L{self.method.owner};"):
                    seen = set()
                    while owner and owner not in seen:
                        seen.add(owner)
                        candidates = [candidate for candidate in self.parent.all_methods
                                      if candidate.owner == owner and candidate.name == method.name
                                      and candidate.descriptor == method.descriptor and not candidate.is_static]
                        if candidates:
                            if len(candidates) == 1:
                                resolved = candidates[0]
                            break
                        owner = self.parent.superclasses.get(owner)
                if resolved is not None and resolved.address & ~1 == target:
                    if argument_values[0].origin == "this":
                        receiver = "super"
                    else:
                        receiver = self.java_value(argument_values[0], self.bank(0, argument_values[0]),
                                                   f"L{self.method.owner};")
                        operands = [json.dumps(method.owner), json.dumps(method.name),
                                    json.dumps(method.descriptor), receiver] + arguments[1:]
                        special_expression = "__jbed_invoke_special(" + ", ".join(operands) + ")"
                elif not devirtualized:
                    self.fail("direct instance call cannot be represented by proven nonvirtual Java dispatch")
            expression = special_expression or f"{receiver}.{java_identifier(method.name)}({', '.join(arguments[1:])})"
        if target:
            self.calls.add(target)
        for register in (0, 1, 2, 3, 12):
            state.registers[register] = _UNKNOWN
        if not tail:
            state.registers[14] = _UNKNOWN
        if method.return_type == "V":
            self.statements.append(expression + ";")
        else:
            self.load_java(state, 0, method.return_type, expression)
        state.flags = None
        state.carry = None
        # The ROM compiler removes continuations after a proven throwing
        # callee. JVM verification still requires a terminal instruction after
        # an ordinary void invocation; this ATHROW null edge is unreachable.
        return Throw("null") if not virtual and self.parent.never_returns(method) else None

    def return_term(self, state: _State):
        if state.sp:
            self.fail(f"return with unbalanced stack ({state.sp} bytes)")
        if self.method.return_type == "V":
            return Return()
        if self.method.return_type in ("J", "F", "D"):
            return Return(abi_argument(self, state, 0, self.method.return_type))
        value = self.value(state, 0)
        return Return(self.java_value(value, self.bank(0, value), self.method.return_type))

    def execute(self, instruction, incoming: _State):
        self.resolved_type_test = False
        state = incoming.copy()
        self.statements = []
        self.position = instruction.address
        m, operands = instruction.mnemonic, instruction.operands
        next_address = instruction.address + instruction.size
        term = None
        intrinsic = (self.checkpoint(instruction, state) or self.table_switch(instruction, state)
                     or WideModel.long_add_sub(self, instruction, state))
        if intrinsic is not None:
            term = intrinsic
        elif m in ("nop", "nop.w"):
            pass
        elif WideModel.lower_instruction(self, instruction, state):
            pass
        elif m in ("push", "pop"):
            registers = sorted(self.reg_number(instruction, operand.reg) for operand in operands)
            if m == "push":
                state.sp -= 4 * len(registers)
                for index, register in enumerate(registers):
                    value = state.registers.get(register, _UNKNOWN)
                    offset = state.sp + index * 4
                    state.store_frame(offset, register, value)
                    if value.kind in ("int", "ref", "address"):
                        if value.kind == "address":
                            self.fail("saving an interior address in a register-list frame")
                        self.statements.append(f"{self.slot(offset, value)} = {self.bank(register, value)};")
            else:
                for index, register in enumerate(registers):
                    value = state.stack.get(state.sp + index * 4, _UNKNOWN)
                    if register == 15:
                        if value.kind != "return":
                            self.fail("return PC is not the saved caller link")
                    else:
                        expression = self.slot(state.sp + index * 4, value) if value.kind in ("int", "ref") else None
                        self.assign(state, register, value, expression)
                state.sp += 4 * len(registers)
                if 15 in registers:
                    term = self.return_term(state)
        elif m in ("mov", "movs", "mov.w", "movs.w"):
            destination = self.reg_number(instruction, operands[0].reg)
            if destination == 15:
                if operands[1].type != ARM_OP_REG or self.value(state, self.reg_number(instruction, operands[1].reg)).kind != "return":
                    self.fail("computed PC write")
                term = self.return_term(state)
            elif operands[1].type == ARM_OP_REG:
                self.move(state, destination, self.reg_number(instruction, operands[1].reg))
            else:
                value, expression = self.operand(instruction, state, operands[1])
                self.assign(state, destination, value, expression)
            if m.startswith("movs") and term is None:
                value = self.value(state, destination)
                if value.kind == "int":
                    self.flags_result(state, self.bank(destination, value))
                else:
                    state.flags = None
        elif m in ("ldr", "ldrb", "ldrh", "ldrsb", "ldrsh", "str", "strb", "strh"):
            term = self.memory(instruction, state, m.startswith("ldr"))
        elif m in ("cmp", "cmp.w"):
            left, lhs = self.operand(instruction, state, operands[0])
            right, rhs = self.operand(instruction, state, operands[1])
            self.comparison(state, left, lhs, right, rhs)
            if left.kind == right.kind == "int":
                WideModel.record_arithmetic_carry(self, state, "cmp", lhs, rhs)
        elif m in ("tst", "cmn"):
            left, lhs = self.operand(instruction, state, operands[0])
            right, rhs = self.operand(instruction, state, operands[1])
            if left.kind != "int" or right.kind != "int":
                self.fail(f"{m} has non-integer operands")
            if m == "cmn":
                WideModel.record_arithmetic_carry(self, state, m, lhs, rhs)
            self.flags_result(state, f"({lhs} {'&' if m == 'tst' else '+'} {rhs})")
        elif m in ("add", "adds", "sub", "subs", "ands", "orrs", "eors", "bics", "muls",
                   "lsls", "lsrs", "asrs", "rsbs", "negs", "mvns", "sxth", "sxtb", "uxth", "uxtb"):
            destination = self.reg_number(instruction, operands[0].reg)
            if len(operands) == 2 and m not in ("mvns", "negs", "sxth", "sxtb", "uxth", "uxtb"):
                left, lhs = self.operand(instruction, state, operands[0])
                right, rhs = self.operand(instruction, state, operands[1])
            elif m in ("mvns", "negs", "sxth", "sxtb", "uxth", "uxtb"):
                left, lhs = self.operand(instruction, state, operands[1])
                right, rhs = _Value("int", constant=0), "0"
            else:
                left, lhs = self.operand(instruction, state, operands[1])
                right, rhs = self.operand(instruction, state, operands[2])
            if m in ("add", "adds") and right.kind in ("stack", "static", "vtable", "image_address") and left.kind == "int":
                left, right, lhs, rhs = right, left, rhs, lhs
            if m in ("add", "adds", "sub", "subs") and left.kind in ("stack", "static", "vtable", "image_address"):
                if right.kind != "int" or right.constant is None:
                    self.fail("dynamic frame/isolate address")
                delta = right.constant * (-1 if m.startswith("sub") else 1)
                self.assign(state, destination, replace(left, constant=(left.constant or 0) + delta), None)
                state.flags = None
            elif m in ("add", "adds") and (left.kind in ("ref", "address") or right.kind in ("ref", "address")):
                if right.kind in ("ref", "address"):
                    left, right, lhs, rhs = right, left, rhs, lhs
                    source_operand = operands[-1]
                else:
                    source_operand = operands[1] if len(operands) == 3 else operands[0]
                if right.kind != "int":
                    self.fail("reference address has a non-integer offset")
                if (left.kind == "ref" and left.descriptor == "[C" and left.string_owner is not None
                        and left.string_owner == right.string_owner and right.string_data is None
                        and (self.method.owner, self.method.name) != ("com/jbed/runtime/NativeOps", "getStringData")):
                    # Heap slices store an array-relative byte offset. ROM slices
                    # use a null array and an absolute UTF-16 address. This ROM
                    # primitive evaluates their exact sum once, before the loop.
                    name = self.local(f"data_{self.position:x}", "int")
                    for locations in (state.registers, state.stack):
                        for location, saved in locations.items():
                            if saved.string_data == name:
                                locations[location] = replace(saved, string_owner=None, string_data=None)
                    receiver = f"((java.lang.String) {left.string_owner})"
                    self.statements.append(f"{name} = com.jbed.runtime.NativeOps.getStringData({receiver});")
                    self.assign(state, destination, _Value("int", alignment=2,
                                string_owner=left.string_owner, string_data=name), name)
                    if instruction.update_flags:
                        state.carry = None
                        self.flags_result(state, self.bank(destination, _INT))
                    return state, Block(self.position, tuple(self.statements), Jump(next_address))
                if not left.descriptor.startswith("[") and right.constant is None:
                    self.fail("object address has a dynamic field offset")
                source = self.reg_number(instruction, source_operand.reg)
                offset = rhs if left.kind == "ref" else f"{self.local(f'o{source}', 'int')} + {rhs}"
                alignment = min(left.alignment if left.kind == "address" else 1 << 32, right.alignment)
                constant = None
                if right.constant is not None and (left.kind == "ref" or left.constant is not None):
                    constant = (left.constant if left.kind == "address" else 0) + right.constant
                self.assign(state, destination, _Value("address", left.descriptor, constant=constant,
                            origin=left.origin, alignment=alignment, array_length=left.array_length), lhs, offset)
                state.flags = None
            else:
                if left.kind != "int" or right.kind != "int":
                    if m == "lsls" and self.string_byte_array_terminator(state):
                        return state, Block(self.position, (), Jump(self.position + 12))
                    self.fail(f"{m} on {left.kind}/{right.kind}")
                if instruction.update_flags:
                    WideModel.record_arithmetic_carry(self, state, m, lhs, rhs)
                    WideModel.record_shift_carry(self, state, m, lhs, rhs, right.constant)
                subtraction_flags = bool(instruction.update_flags and m in ("subs", "rsbs", "negs"))
                if subtraction_flags:
                    if m == "subs":
                        self.comparison(state, left, lhs, right, rhs)
                    elif m == "rsbs":
                        self.comparison(state, right, rhs, left, lhs)
                    else:
                        self.comparison(state, _Value("int", constant=0), "0", left, lhs)
                constant = None
                alignment = 1
                binary = {"add": "+", "adds": "+", "sub": "-", "subs": "-", "ands": "&", "orrs": "|", "eors": "^", "muls": "*"}
                if m in binary:
                    op = binary[m]
                    expression = f"{lhs} {op} {rhs}"
                    if left.constant is not None and right.constant is not None:
                        a, b = left.constant, right.constant
                        constant = _signed({"+": lambda: a+b, "-": lambda: a-b, "&": lambda: a&b,
                                            "|": lambda: a|b, "^": lambda: a^b, "*": lambda: a*b}[op]())
                    alignment = (max(left.alignment, right.alignment) if op == "&" else
                                 min(1 << 32, left.alignment * right.alignment) if op == "*" else
                                 min(left.alignment, right.alignment))
                elif m == "bics":
                    expression = f"{lhs} & ~{rhs}"
                elif m in ("mvns", "negs", "rsbs"):
                    expression = f"~{lhs}" if m == "mvns" else f"-{lhs}" if m == "negs" else f"{rhs} - {lhs}"
                    if left.constant is not None:
                        if m == "mvns":
                            constant = _signed(~left.constant)
                        elif m == "negs":
                            constant = _signed(-left.constant)
                        elif right.constant is not None:
                            constant = _signed(right.constant - left.constant)
                elif m in ("sxth", "sxtb", "uxth", "uxtb"):
                    expression = f"(short) {lhs}" if m == "sxth" else f"(byte) {lhs}" if m == "sxtb" else f"{lhs} & {65535 if m == 'uxth' else 255}"
                else:
                    op = {"lsls": "<<", "lsrs": ">>>", "asrs": ">>"}[m]
                    if right.constant is not None:
                        shift = right.constant
                        if not 0 <= shift <= 32:
                            self.fail("unsupported immediate shift count")
                        expression = (f"{lhs} >> 31" if m == "asrs" else "0") if shift == 32 else f"{lhs} {op} {shift}"
                        if m == "lsls":
                            alignment = min(1 << 32, left.alignment << shift)
                        if left.constant is not None:
                            bits = left.constant & 0xffffffff
                            constant = _signed(bits << shift if m == "lsls" else
                                               bits >> shift if m == "lsrs" else left.constant >> shift)
                    else:
                        # ARM register shifts inspect eight count bits; Java
                        # masks to five, so keep the >=32 case explicit.
                        large = f"{lhs} >> 31" if m == "asrs" else "0"
                        expression = f"(({rhs} & 255) >= 32 ? {large} : {lhs} {op} ({rhs} & 255))"
                if constant is not None:
                    alignment = _alignment(constant)
                derived = None
                if m in ("add", "adds", "sub", "subs") and left.string_data and not right.string_data:
                    derived = left
                elif m in ("add", "adds") and right.string_data and not left.string_data:
                    derived = right
                result = _Value("int", constant=constant, alignment=alignment)
                if derived:
                    result = replace(result, string_owner=derived.string_owner, string_data=derived.string_data)
                self.assign(state, destination, result, expression)
                if instruction.update_flags and not subtraction_flags:
                    self.flags_result(state, self.bank(destination, _INT))
        elif m in ("bl", "blx"):
            if operands[0].type == ARM_OP_IMM:
                target = operands[0].imm & ~1
                if m == "bl" and self.start < target < self.end:
                    # JumpCC's long intra-method branch uses Thumb BL; the
                    # saved caller link remains in the method's frame.
                    state.registers[14] = _Value("pc", constant=next_address)
                    term = Jump(target)
                else:
                    term = self.call(target, state)
            elif operands[0].type == ARM_OP_REG:
                function = self.value(state, self.reg_number(instruction, operands[0].reg))
                if function.kind == "method" and function.method:
                    term = self.call(function.method.address & ~1, state,
                                     resolved_method=function.method, virtual=True)
                elif function.kind in ("int", "image_address") and function.constant is not None:
                    term = self.call(function.constant & ~1, state)
                else:
                    self.fail("unresolved indirect call")
            else:
                self.fail("unsupported call operand")
        elif m == "bx":
            register = self.reg_number(instruction, operands[0].reg)
            if self.value(state, register).kind != "return":
                self.fail("unresolved indirect branch")
            term = self.return_term(state)
        elif m in ("b", "b.w"):
            target = operands[0].imm & ~1
            if not self.start <= target < self.end:
                term = self.call(target, state, tail=True)
                if term is None:
                    term = self.return_term(state)
            else:
                term = Jump(target)
        elif m.startswith("b") and operands and operands[0].type == ARM_OP_IMM:
            target = operands[0].imm & ~1
            if state.flags and state.flags.kind == "stack":
                guard = self.decode(next_address)
                if (guard is None or guard.mnemonic != "bl" or len(guard.operands) != 1
                        or guard.operands[0].type != ARM_OP_IMM
                        or self.runtime_helper(guard.operands[0].imm & ~1) not in ("throwStack", "throwStackLargeFrame")
                        or target != next_address + guard.size):
                    self.fail("stack comparison is not followed by the compiler's overflow trap")
            condition = self.condition(state, m)
            term = Jump(target if condition else next_address) if isinstance(condition, bool) else Branch(condition, target, next_address)
        else:
            self.fail(f"unsupported instruction {m} {instruction.op_str}")
        term = term or Jump(next_address)
        return state, Block(instruction.address, tuple(self.statements), term)

    def merge_value(self, left: _Value, right: _Value) -> _Value:
        if left == right:
            return left
        if "unknown" in (left.kind, right.kind):
            return _UNKNOWN
        if left.kind != right.kind:
            if left.kind == "ref" and right.kind == "int" and right.constant == 0:
                return replace(left, origin=None, constant=None, nonnull=False, frame_alias=None,
                               array_length=None, string_owner=None)
            if right.kind == "ref" and left.kind == "int" and left.constant == 0:
                return replace(right, origin=None, constant=None, nonnull=False, frame_alias=None,
                               array_length=None, string_owner=None)
            return _UNKNOWN
        if (left.kind == "vtable" and left.constant == right.constant and left.descriptor == right.descriptor
                and left.interface_table == right.interface_table):
            return replace(left, origin=left.origin if left.origin == right.origin else None)
        if left.kind in ("stack", "static", "return", "limit", "vtable", "method", "image_address"):
            # Scratch register definitions need not agree when they are dead
            # at a join. A subsequent use still requires a resolved value.
            return _UNKNOWN
        descriptor = left.descriptor
        if descriptor != right.descriptor:
            if left.kind in ("ref", "address"):
                descriptor = self.common_reference(left.descriptor, right.descriptor)
            else:
                descriptor = "I"
        return _Value(left.kind, descriptor,
                      left.constant if left.constant == right.constant else None,
                      left.origin if left.origin == right.origin else None,
                      min(left.alignment, right.alignment),
                      type_test=left.type_test if left.type_test == right.type_test else None,
                      nonnull=left.nonnull and right.nonnull,
                      frame_alias=left.frame_alias if left.frame_alias == right.frame_alias else None,
                      array_length=left.array_length if left.array_length == right.array_length else None,
                      string_owner=left.string_owner if left.string_owner == right.string_owner else None,
                      string_data=left.string_data if left.string_data == right.string_data else None)

    def common_reference(self, left: str, right: str) -> str:
        if left == right:
            return left
        if left.startswith("[") and right.startswith("[") and _reference(left[1:]) and _reference(right[1:]):
            return "[" + self.common_reference(left[1:], right[1:])
        if not left.startswith("L") or not right.startswith("L"):
            return "Ljava/lang/Object;"
        ancestors, owner = set(), left[1:-1]
        while owner and owner not in ancestors:
            ancestors.add(owner)
            owner = self.parent.superclasses.get(owner)
        owner, seen = right[1:-1], set()
        while owner and owner not in seen:
            if owner in ancestors:
                return f"L{owner};"
            seen.add(owner)
            owner = self.parent.superclasses.get(owner)
        return "Ljava/lang/Object;"

    def merge(self, previous: _State, incoming: _State) -> _State:
        if previous.sp != incoming.sp:
            self.fail("stack depth differs across control-flow predecessors")
        registers = {register: self.merge_value(previous.registers.get(register, _UNKNOWN), incoming.registers.get(register, _UNKNOWN))
                     for register in previous.registers.keys() | incoming.registers.keys()}
        stack = {offset: self.merge_value(previous.stack.get(offset, _UNKNOWN), incoming.stack.get(offset, _UNKNOWN))
                 for offset in previous.stack.keys() | incoming.stack.keys()}
        flags = None
        if previous.flags is not None and incoming.flags is not None:
            a, b = previous.flags, incoming.flags
            if (a.address, a.kind, a.left, a.right) == (b.address, b.kind, b.left, b.right):
                flags = replace(a, register=a.register if a.register == b.register else None,
                                constant=a.constant if a.constant == b.constant else None,
                                left_constant=a.left_constant if a.left_constant == b.left_constant else None,
                                type_test=a.type_test if a.type_test == b.type_test else None)
        return _State(registers, stack, previous.sp,
                      flags,
                      previous.carry if previous.carry == incoming.carry else None,
                      {register: bound for register, bound in previous.switch_bounds.items()
                       if incoming.switch_bounds.get(register) == bound})

    def initial(self):
        if self.method.is_native or self.method.is_abstract or not self.method.size:
            self.fail("method has no managed Thumb body")
        if self.method.name in ("<init>", "<clinit>") and self.parent.objects is None:
            self.fail("initialization methods need constructor/class-initializer recovery")
        if self.method.flags & 0x20 and self.parent.objects is None:
            self.fail("synchronized method needs monitor/exception-frame recovery")
        state = _State({9: _Value("static", constant=0), 10: _Value("limit"), 14: _RETURN}, {})
        arguments = list(zip(self.method.argument_types, self.method.parameter_names))
        if not self.method.is_static:
            arguments.insert(0, (f"L{self.method.owner};", "this"))
        self.statements = []
        index = 0
        for descriptor, name in arguments:
            value = (_Value("ref", descriptor, origin=name, nonnull=name == "this")
                     if _reference(descriptor) else replace(_INT, origin=name))
            expressions = unpack_bits(descriptor, name) if descriptor in ("J", "F", "D") else (f"({name} ? 1 : 0)" if descriptor == "Z" else name,)
            for part, expression in enumerate(expressions):
                if descriptor in ("J", "F", "D"):
                    value = replace(value, typed_word=TypedWord(name, descriptor, part))
                if index < 4:
                    self.assign(state, index, value, expression)
                else:
                    offset = (index - 4) * 4
                    state.stack[offset] = value
                    self.statements.append(f"{self.slot(offset, value)} = {expression};")
                index += 1
        return state, tuple(self.statements)

    def run(self) -> LiftResult:
        state, initial = self.initial()
        native = native_arithmetic_entry(self)
        if native is not None:
            cfg, count = native
            return LiftResult(structure_cfg(cfg) if self.produce_source else (), count, cfg=cfg)
        incoming = {self.start: state}
        blocks = {}
        outgoing_states = {}
        pending_errors = {}
        catches = {}
        queue = deque([self.start])
        queued = {self.start}
        predecessor_states = {self.start: {(-1, "entry"): state}}

        def propagate(source: int, target: int, value: _State, kind: str = "normal"):
            key = (source, kind)
            predecessors = predecessor_states.setdefault(target, {})
            if predecessors.get(key) == value:
                return
            predecessors[key] = value
            merged = None
            for candidate in predecessors.values():
                merged = candidate.copy() if merged is None else self.merge(merged, candidate)
            if incoming.get(target) != merged:
                incoming[target] = merged
                if target not in queued:
                    queue.append(target)
                    queued.add(target)

        iterations = 0
        while queue:
            address = queue.popleft()
            queued.discard(address)
            self.position = address
            iterations += 1
            if iterations > 100000:
                self.fail("type dataflow did not converge")
            if not self.start <= address < self.end:
                self.fail("control flow leaves the declared method body")
            instruction = self.instructions.get(address)
            if instruction is None:
                instruction = self.decode(address)
                if instruction is None:
                    self.fail("undecodable or truncated Thumb instruction")
                self.instructions[address] = instruction
            try:
                outgoing, block = self.execute(instruction, incoming[address])
            except (UnsupportedThumb, UnsupportedJava) as error:
                # A second predecessor can refine a provisional null/reference
                # join. Finish the dataflow worklist before rejecting that use.
                pending_errors[address] = error
                continue
            pending_errors.pop(address, None)
            blocks[address] = block
            outgoing_states[address] = outgoing
            term = block.terminator
            successors = ((term.target,) if isinstance(term, Jump) else
                          (term.true_target, term.false_target) if isinstance(term, Branch) else
                          tuple(target for _, target in term.cases) + (term.default_target,)
                          if isinstance(term, Switch) else ())
            for target in successors:
                edge_state = outgoing.copy()
                flags = outgoing.flags
                if (isinstance(term, Branch) and flags is not None and flags.kind == "ref"
                        and flags.register is not None and flags.constant == 0
                        and term.true_target != term.false_target
                        and instruction.mnemonic in ("beq", "bne")
                        and (target == term.true_target) == (instruction.mnemonic == "bne")):
                    register = flags.register
                    value = edge_state.registers[register]
                    edge_state.registers[register] = replace(value, nonnull=True)
                    if value.frame_alias is not None:
                        slot = value.frame_alias
                        edge_state.stack[slot] = replace(edge_state.stack[slot], nonnull=True)
                if isinstance(term, Branch) and flags is not None and flags.type_test is not None:
                    cc = instruction.mnemonic.removeprefix("b")
                    constant = 0 if flags.kind == "result" else flags.constant
                    if cc in ("eq", "ne") and constant in (0, 1):
                        true_edge = (cc == "ne") == (constant == 0)
                        if (target == term.true_target) == true_edge:
                            origin, descriptor = flags.type_test
                            for register, value in tuple(edge_state.registers.items()):
                                if value.kind == "ref" and value.origin == origin:
                                    edge_state.registers[register] = replace(value, descriptor=descriptor)
                            for offset, value in tuple(edge_state.stack.items()):
                                if value.kind == "ref" and value.origin == origin:
                                    edge_state.stack[offset] = replace(value, descriptor=descriptor)
                if (instruction.mnemonic in ("bls", "blo", "bcc", "bhi", "bhs", "bcs")
                        and flags is not None and flags.kind == "cmp"
                        and flags.register is not None and flags.constant is not None
                        and 0 <= flags.constant <= 65535):
                    # The selector in a loop's first iteration can be constant.
                    # Even when the guard folds to a Jump, the bound and default
                    # come from its encoded taken and fallthrough addresses.
                    taken = instruction.operands[0].imm & ~1
                    fallthrough = instruction.address + instruction.size
                    cc = instruction.mnemonic.removeprefix("b")
                    upper_is_taken = cc in ("ls", "lo", "cc")
                    if taken != fallthrough and target == (taken if upper_is_taken else fallthrough):
                        maximum = flags.constant - (1 if cc in ("lo", "cc", "hs", "cs") else 0)
                        fallback = fallthrough if upper_is_taken else taken
                        fallback_instruction = self.decode(fallback)
                        if fallback_instruction and fallback_instruction.mnemonic in ("b", "b.w"):
                            fallback = fallback_instruction.operands[0].imm & ~1
                        edge_state.switch_bounds[flags.register] = (maximum, fallback)
                propagate(address, target, edge_state)
            if self.method.has_handlers and (instruction.mnemonic in ("bl", "blx") or isinstance(term, Throw)):
                # Base.InstanceOf on a ROM class lowers to a resolved JVM
                # instanceof, not a managed invocation. A spurious catch here
                # can reach a landing pad before its live spill is initialized.
                catches[address] = (() if self.resolved_type_test else
                                    self.exception_plan.catches_for(address, instruction.size))
                for target in dict.fromkeys(region.handler for region in catches[address]):
                    handler = self.exception_plan.handlers[target]
                    caught = incoming[address].copy()
                    caught.registers[0] = _Value("ref", f"L{handler.catch_type};")
                    self.local(handler.variable, "Object")
                    for register in (1, 2, 3, 12, 14):
                        caught.registers[register] = _UNKNOWN
                    caught.flags = None
                    caught.carry = None
                    propagate(address, handler.address, caught, "exception")
        if pending_errors:
            raise pending_errors[min(pending_errors)]
        guarded_offsets = set()
        for address, (offset, guard) in self.guarded_spills.items():
            if incoming[address].stack.get(offset, _UNKNOWN).kind == "unknown":
                if not self.spill_defined_or_guard_zero(address, offset, guard, predecessor_states):
                    raise UnsupportedThumb(f"0x{address:x}: read of undefined frame slot {offset}")
                guarded_offsets.add(offset)
        initial += tuple(f"{self.slot(offset, _INT)} = 0;" for offset in sorted(guarded_offsets))
        def null_conversions(before, after, caught=False):
            conversions = []
            for register, value in after.registers.items():
                if caught and register in (0, 1, 2, 3, 12, 14):
                    continue
                old = before.registers.get(register, _UNKNOWN)
                if value.kind == "ref" and old.kind == "int" and old.constant == 0:
                    conversions.append(f"{self.bank(register, value)} = null;")
            for offset, value in after.stack.items():
                old = before.stack.get(offset, _UNKNOWN)
                if value.kind == "ref" and old.kind == "int" and old.constant == 0:
                    conversions.append(f"{self.slot(offset, value)} = null;")
            return tuple(conversions)

        # Null constants share the machine integer register bank but become
        # references at Java joins. Materialize that conversion on its own
        # predecessor edge, including critical edges of conditional branches.
        for address, block in tuple(blocks.items()):
            term = block.terminator
            targets = ((term.target,) if isinstance(term, Jump) else
                       (term.true_target, term.false_target) if isinstance(term, Branch) else
                       tuple(target for _, target in term.cases) + (term.default_target,)
                       if isinstance(term, Switch) else ())
            replacements = {}
            for target in set(targets):
                before, after = outgoing_states[address], incoming[target]
                conversions = null_conversions(before, after)
                if conversions:
                    edge = -len(blocks) - 1
                    blocks[edge] = Block(edge, tuple(conversions), Jump(target))
                    replacements[target] = edge
            if isinstance(term, Jump):
                term = Jump(replacements.get(term.target, term.target))
            elif isinstance(term, Branch):
                term = Branch(term.condition, replacements.get(term.true_target, term.true_target),
                              replacements.get(term.false_target, term.false_target))
            elif isinstance(term, Switch):
                term = Switch(term.selector, tuple((value, replacements.get(target, target)) for value, target in term.cases),
                              replacements.get(term.default_target, term.default_target))
            blocks[address] = replace(block, terminator=term)
        # Only flags consumed by a branch survive. Their assignments have no
        # side effects; dropping unused captures makes arithmetic much clearer.
        used_flags = set()
        for block in blocks.values():
            if isinstance(block.terminator, Branch):
                used_flags.update(re.findall(r"\b(?:z_[0-9a-f]+|c_[0-9a-f]+r?[ab])\b", block.terminator.condition))
        for address, block in list(blocks.items()):
            statements = tuple(line for line in block.statements
                               if not re.match(r"(?:z_[0-9a-f]+|c_[0-9a-f]+r?[ab]) =", line)
                               or line.split(" =", 1)[0] in used_flags)
            blocks[address] = replace(block, statements=statements)
        for name in list(self.locals):
            if re.fullmatch(r"(?:z_[0-9a-f]+|c_[0-9a-f]+r?[ab])", name) and name not in used_flags:
                del self.locals[name]
        # ABI inputs are bound once on method entry. A native loop may jump
        # back to its first instruction without reinitializing those values.
        entry = -len(blocks) - 1
        while entry in blocks:
            entry -= 1
        blocks[entry] = Block(entry, initial, Jump(self.start))
        cfg = LiftedCFG(entry, blocks, self.locals, tuple(sorted(self.calls)))
        parameters = {name: java_type(descriptor)
                      for name, descriptor in zip(self.method.parameter_names, self.method.argument_types)}
        if not self.method.is_static:
            parameters["this"] = mapped_name(self.method.owner)
        # Native catch ranges refer to individual machine labels. Preserve
        # those labels and exceptional roots for the JVM exception table.
        if not self.method.has_handlers:
            cfg = simplify(cfg, parameters=parameters)
        self.last_cfg = cfg
        if self.method.has_handlers:
            regions = self.exception_plan.project(cfg, catches)
            self.handler_locals = self.exception_plan.handler_locals(cfg)
            # A native throw preserves stack slots and r4..r6, including a
            # zero stored before the try body. Give each exceptional edge its
            # own null conversion just as for ordinary control-flow joins.
            # Doing this in the shared handler would overwrite a nonnull value
            # arriving from a different throw site.
            landing_pads = {}
            projected = []
            for region in regions:
                conversions = null_conversions(incoming[region.start], incoming[region.handler], True)
                if conversions:
                    key = region.handler, conversions
                    if key not in landing_pads:
                        edge = -len(blocks) - 1
                        blocks[edge] = Block(edge, conversions, Jump(region.handler))
                        self.handler_locals[edge] = self.handler_locals[region.handler]
                        landing_pads[key] = edge
                    region = replace(region, handler=landing_pads[key])
                projected.append(region)
            self.exception_regions = tuple(projected)
            if self.produce_source:
                raise StructureError("exceptional CFG recovered; emit JVM exception tables before Java decompilation")
        body = structure_cfg(cfg) if self.produce_source else ()
        return LiftResult(body, len(self.instructions), tuple(sorted(self.calls)), cfg=cfg,
                          exception_regions=self.exception_regions, handler_locals=self.handler_locals)
