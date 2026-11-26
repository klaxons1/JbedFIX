"""Recover Java allocation, type checks and ROM object constants.

These are compiler runtime intrinsics, identified by their ROM declarations.
The method being decompiled does not select a handwritten implementation.
"""

from __future__ import annotations

from dataclasses import dataclass
import json
import re
import struct

from .model import ClassSpec, MethodSpec, RomImage, UnsupportedJava, java_type


NOT_HANDLED = object()
_PRIMITIVES = {4: "Z", 5: "C", 6: "F", 7: "D", 8: "B", 9: "S", 10: "I", 11: "J"}
_CLASS_ARGUMENT = {"new_object": 0, "class_init": 0, "instanceof": 1,
                   "checkcast": 1, "new_array": 1, "new_array_n": 2}


@dataclass(frozen=True)
class Literal:
    descriptor: str
    expression: str
    address: int


class ObjectModel:
    def __init__(self, rom: RomImage):
        self.rom = rom
        self.intrinsics = {}
        declarations = {
            ("com/jbed/runtime/Memory", "newObject", "(Ljava/lang/Class;)Ljava/lang/Object;"): "new_object",
            ("com/jbed/runtime/Memory", "newArray", "(ILjava/lang/Class;)Ljava/lang/Object;"): "new_array",
            ("com/jbed/runtime/Memory", "newArrayN", "(ILjava/lang/Object;Ljava/lang/Class;)Ljava/lang/Object;"): "new_array_n",
            ("com/jbed/runtime/Base", "InstanceOf", "(Ljava/lang/Object;Ljava/lang/Class;)Z"): "instanceof",
            ("com/jbed/runtime/Base", "checkcast", "(Ljava/lang/Object;Ljava/lang/Class;)Ljava/lang/Object;"): "checkcast",
            ("com/jbed/runtime/Base", "init", "(Ljava/lang/Class;)V"): "class_init",
            ("com/jbed/runtime/Base", "arrayLength", "(Ljava/lang/Object;)I"): "array_length",
            ("com/jbed/runtime/Base", "arraystore", "([Ljava/lang/Object;ILjava/lang/Object;)V"): "array_store",
            ("com/jbed/runtime/Base", "arraystoreWithoutCastcheck", "([Ljava/lang/Object;ILjava/lang/Object;)V"): "array_store",
            ("com/jbed/runtime/ArchBase", "enter", "(Ljava/lang/Object;)V"): "monitor_enter",
            ("com/jbed/runtime/ArchBase", "exit", "(Ljava/lang/Object;)V"): "monitor_exit",
            ("com/jbed/runtime/ArchBase", "move", "(III)V"): "move",
        }
        for method in rom.methods:
            kind = declarations.get((method.owner, method.name, method.descriptor))
            if kind:
                self.intrinsics[method.address & ~1] = kind

    @staticmethod
    def descriptor(klass: ClassSpec) -> str:
        primitive = re.fullmatch(r"<primitive:(\d+)>", klass.name)
        base = _PRIMITIVES[int(primitive[1])] if primitive else "L" + klass.name + ";"
        return "[" * klass.dimensions + base

    def class_at(self, address: int) -> ClassSpec:
        try:
            return self.rom.by_descriptor[address]
        except KeyError:
            raise UnsupportedJava(f"no ROM class descriptor at 0x{address:x}") from None

    def literal(self, address: int) -> Literal | None:
        address &= 0xffffffff
        if address in self.rom.by_descriptor:
            descriptor = self.descriptor(self.rom.by_descriptor[address])
            return Literal("Ljava/lang/Class;", java_type(descriptor) + ".class", address)
        if address < 0 or address + 24 > len(self.rom.data) or address & 3:
            return None
        try:
            klass = self.rom.object_class(address)
        except (ValueError, KeyError):
            return None
        if klass.name == "java/lang/String" and not klass.dimensions:
            return Literal("Ljava/lang/String;", json.dumps(self.rom.string_literal(address), ensure_ascii=True), address)
        return None

    def copy_literal_array(self, session, state) -> bool:
        source, target, count = (session.value(state, reg) for reg in range(3))
        if (target.kind != "address" or not target.descriptor.startswith("[") or
                target.constant is None or target.array_length is None or source.kind not in ("int", "image_address") or
                source.constant is None or count.kind != "int" or count.constant is None):
            return False
        element = target.descriptor[1:]
        width = {"B": 1, "Z": 1, "S": 2, "C": 2, "I": 4, "J": 8}.get(element)
        reference = element.startswith("L")
        if reference:
            width = 4
        start, size = source.constant, count.constant
        # Jbed embeds constant initializer data in the allocating method.
        offset = target.constant - 16
        if (not width or size <= 0 or offset < 0 or offset % width or size % width or
                offset + size > width * target.array_length or
                start < session.start or start + size > session.end):
            return False
        values = []
        for pos in range(start, start + size, width):
            bits = int.from_bytes(self.rom.data[pos:pos + width], "little", signed=element in ("B", "S", "I", "J"))
            if reference and bits:
                literal = self.literal(bits)
                if not literal or element not in (literal.descriptor, "Ljava/lang/Object;"):
                    return False
                value = literal.expression
            elif reference:
                value = "null"
            elif element == "Z":
                if bits not in (0, 1):
                    return False
                value = "true" if bits else "false"
            else:
                value = f"{bits}L" if element == "J" else str(bits)
            values.append(value)
        array = session.bank(1, target)
        cast = f"(({java_type(target.descriptor)}) {array})"
        session.statements.extend(f"{cast}[{i}] = {v};" for i, v in enumerate(values, offset // width))
        return True

    @staticmethod
    def store_packed_constant(session, state, src_reg, array, reference, offset, width):
        """Expand an in-bounds STR/STRH into stores of whole JVM array elements."""
        element = array.descriptor[1:]
        size = 1 if element in ("B", "Z") else 2
        bits = session.value(state, src_reg)
        if (array.array_length is None or bits.kind != "int" or bits.constant is None or width <= size or
                offset < 0 or offset % size or offset + width > array.array_length * size):
            return False
        data = (bits.constant & 0xffffffff).to_bytes(4, "little")[:width]
        if element == "Z" and any(byte > 1 for byte in data):
            return False
        for pos in range(0, width, size):
            value = int.from_bytes(data[pos:pos + size], "little", signed=element in ("B", "S"))
            literal = ("false", "true")[value] if element == "Z" else str(value)
            session.statements.append(f"{reference}[{(offset + pos) // size}] = {literal};")
        return True

    @staticmethod
    def copy_string_chars(session, state) -> bool:
        source, target, count = (session.value(state, reg) for reg in range(3))
        if (not source.string_data or target.kind != "address" or target.descriptor != "[C"
                or not (target.origin or "").startswith("array:") or count.kind != "int"
                or min(source.alignment, target.alignment, count.alignment) < 2):
            return False
        # ArchBase.move copies forward in machine-width groups. Only these
        # copies have both a fresh destination and a bounded input span: concat
        # copies its two inputs into their combined size; the other three copy
        # the prefix preceding the first changed character into a same-size array.
        if session.method.owner != "java/lang/String" or (session.method.name, session.method.descriptor) not in {
                ("concat", "(Ljava/lang/String;)Ljava/lang/String;"), ("replace", "(CC)Ljava/lang/String;"),
                ("toUpperCase", "()Ljava/lang/String;"), ("toLowerCase", "()Ljava/lang/String;")}:
            return False
        start = f"(({session.bank(0, source)} - {source.string_data}) >> 1)"
        end = f"({start} + ({session.bank(2, count)} >> 1))"
        array = f"((char[]) {session.bank(1, target)})"
        offset = session.local("o1", "int")
        session.statements.append(f"((java.lang.String) {source.string_owner}).getChars("
                                  f"{start}, {end}, {array}, (({offset} - 16) >> 1));")
        return True

    def copy_buffer_chars(self, session, state) -> bool:
        if session.method.owner != "java/lang/StringBuffer":
            return False
        source, target, count = (session.value(state, r) for r in range(3))
        if (source.kind != "address" or source.descriptor != "[C" or target.kind != "address"
                or target.descriptor != "[C" or target.alignment < 2
                or count.kind != "int" or count.alignment < 2):
            return False
        destination = f"((char[]) {session.bank(1, target)})"
        length = f"({session.bank(2, count)} >>> 1)"
        signature = session.method.name, session.method.descriptor
        if signature in {("copy", "()V"), ("enlarge", "(I)V")}:
            # Both routines allocate capacity >= count before copying the used prefix.
            if source.constant != 16 or target.constant != 16:
                return False
            array = f"((char[]) {session.bank(0, source)})"
            session.statements.append(f"java.lang.System.arraycopy({array}, 0, {destination}, 0, {length});")
            return True
        if signature != ("append", "(Ljava/lang/String;)Ljava/lang/StringBuffer;"):
            return False
        # append selects p0 or the ROM string "null". A ROM String has no
        # char[] backing. Both layouts use the same value + addr instruction pair.
        pc = session.position - 22
        if pc < session.start or source.origin != f"value:{pc:x}":
            return False
        words = struct.unpack_from("<11H", self.rom.data, pc)
        receiver, temp = (words[0] >> 3) & 7, words[0] & 7
        # r0 = s.value + s.addr, r1 = dst + 16 + 2 * used, r2 = 2 * s.count.
        if (receiver < 3 or receiver == temp or words[:4] !=
                (0x68c0 | receiver << 3 | temp, temp << 3 | 1, 0x6900 | receiver << 3, 0x1808)
                or words[4] & 0xff00 != 0x9a00 or words[5] != 0x3210
                or words[6] & 0xffc7 != 0x6901 or words[7:9] != (0x0049, 0x1851)
                or words[9:] != (0x6942 | receiver << 3, 0x0052)):
            return False
        string = session.value(state, receiver)
        if string.kind != "ref" or string.descriptor != "Ljava/lang/String;":
            return False
        owner = f"((java.lang.String) {session.bank(receiver, string)})"
        offset = session.local("o1", "int")
        session.statements.append(f"{owner}.getChars(0, {length}, {destination}, (({offset} - 16) >>> 1));")
        return True

    def copy_calendar_flags(self, session, state) -> bool:
        if (session.method.owner, session.method.name, session.method.descriptor) != (
                "java/util/Calendar$Impl", "computeTime", "()V"):
            return False
        source, target, count = (session.value(state, r) for r in range(3))
        # The preceding isSet.length > 11 check covers all three stores.
        if (target.kind != "address" or target.descriptor != "[Z" or target.constant != 16 + 9
                or count.kind != "int" or count.constant != 3 or source.kind not in ("int", "image_address")
                or source.constant is None or not session.start <= source.constant <= session.end - 3):
            return False
        values = self.rom.data[source.constant:source.constant + 3]
        if any(value > 1 for value in values):
            return False
        array = f"((boolean[]) {session.bank(1, target)})"
        session.statements.extend(f"{array}[{index}] = {'true' if byte else 'false'};"
                                  for index, byte in enumerate(values, 9))
        return True

    @staticmethod
    def _clobber(state, tail: bool):
        from .thumb import _UNKNOWN
        for register in (0, 1, 2, 3, 12):
            state.registers[register] = _UNKNOWN
        if not tail:
            state.registers[14] = _UNKNOWN
        state.flags = None
        state.carry = None

    @staticmethod
    def _argument(session, state, word: int, descriptor: str, *, use_origin=False) -> str:
        from .thumb import _UNKNOWN
        if descriptor in ("J", "F", "D"):
            from .wide import abi_argument
            return abi_argument(session, state, word, descriptor)
        if word < 4:
            value = session.value(state, word)
            expression = session.bank(word, value)
        else:
            offset = state.sp + (word - 4) * 4
            value = state.stack.get(offset, _UNKNOWN)
            if value.kind == "unknown":
                session.fail(f"constructor argument in undefined frame slot {offset}")
            expression = session.slot(offset, value)
        if use_origin and value.origin and re.fullmatch(r"p\d+", value.origin):
            # Parameter origins survive moves; arithmetic produces a new value.
            expression = value.origin
            if descriptor == "Z":
                return expression
        return session.java_value(value, expression, descriptor)

    def _constructor(self, session, method: MethodSpec, target: int, state, tail: bool):
        from .thumb import _Value
        receiver = session.value(state, 0)
        word = 1
        arguments = []
        for descriptor in method.argument_types:
            arguments.append(self._argument(session, state, word, descriptor,
                                            use_origin=receiver.origin == "this"))
            word += 2 if descriptor in ("J", "D") else 1
        receiver_expression = session.bank(0, receiver)
        if receiver.origin == "this" and session.method.is_constructor:
            receiver_expression = "this"
            if method.owner not in (session.method.owner, self.rom.superclasses.get(session.method.owner)):
                session.fail("constructor targets neither this class nor its direct superclass")
        elif receiver.origin and receiver.origin.startswith("new:"):
            if receiver.descriptor != "L" + method.owner + ";":
                session.fail("constructor class differs from the allocated object")
            allocation = receiver.origin.split(":", 1)[1]
            initialized = _Value("ref", receiver.descriptor, origin="object:" + allocation, nonnull=True)
            # AOT keeps the uninitialized reference in callee-saved registers or
            # frame slots across invokespecial. All aliases become one object.
            for register, value in tuple(state.registers.items()):
                if value.origin == receiver.origin:
                    state.registers[register] = initialized
            for offset, value in tuple(state.stack.items()):
                if value.origin == receiver.origin:
                    state.stack[offset] = initialized
        else:
            session.fail("constructor receiver is not this or a pending allocation")
        operands = [json.dumps(method.owner), json.dumps(method.descriptor), receiver_expression] + arguments
        session.statements.append("__jbed_init(" + ", ".join(operands) + ");")
        session.calls.add(target)
        self._clobber(state, tail)
        return None

    def lower_call(self, session, target: int, state, *, tail: bool = False):
        from .thumb import _Value
        method = self.rom.methods_by_address.get(target & ~1)
        if method and method.is_constructor:
            return self._constructor(session, method, target, state, tail)
        operation = self.intrinsics.get(target & ~1)
        if operation is None:
            return NOT_HANDLED
        # The same entry points implement JVM instructions with literal types
        # and explicit VM calls with a java.lang.Class argument. The latter
        # keep their original invokestatic and runtime class identity.
        if operation in _CLASS_ARGUMENT:
            address = session.value(state, _CLASS_ARGUMENT[operation]).constant
            if not address:
                return NOT_HANDLED
            klass = self.class_at(address & 0xffffffff)
        if operation == "move":
            if not (self.copy_literal_array(session, state) or self.copy_string_chars(session, state)
                    or self.copy_buffer_chars(session, state) or self.copy_calendar_flags(session, state)):
                return NOT_HANDLED
            self._clobber(state, tail)
            return None
        if operation == "new_object":
            descriptor = self.descriptor(klass)
            if klass.dimensions or klass.is_interface or klass.flags & 0x400:
                session.fail("object allocation names an array, interface or abstract class")
            self._clobber(state, tail)
            expression = f"__jbed_new({json.dumps(klass.name)})"
            session.assign(state, 0, _Value("ref", descriptor, origin=f"new:{session.position:x}", nonnull=True), expression)
            return None
        if operation in ("new_array", "new_array_n"):
            descriptor = self.descriptor(klass)
            if not klass.dimensions:
                session.fail("array allocation does not name an array class")
            count = self._argument(session, state, 0, "I")
            length = session.value(state, 0).constant
            if operation == "new_array_n":
                template = session.value(state, 1)
                if not template.descriptor.startswith("[") or descriptor[1:] != template.descriptor:
                    session.fail("multidimensional allocation template has an incompatible array type")
                expression = (f"__jbed_new_array_n({json.dumps(descriptor)}, {count}, "
                              f"{self._argument(session, state, 1, template.descriptor)})")
            else:
                expression = f"__jbed_new_array({json.dumps(descriptor)}, {count})"
            name = f"array:{session.position:x}"
            self._clobber(state, tail)
            session.assign(state, 0, _Value("ref", descriptor, origin=name, nonnull=True, array_length=length), expression)
            return None
        if operation in ("instanceof", "checkcast"):
            descriptor = self.descriptor(klass)
            session.resolved_type_test = operation == "instanceof"
            origin = session.value(state, 0).origin
            reference = self._argument(session, state, 0, "Ljava/lang/Object;")
            expression = (f"({reference} instanceof {java_type(descriptor)})" if operation == "instanceof"
                          else f"(({java_type(descriptor)}) {reference})")
            self._clobber(state, tail)
            session.load_java(state, 0, "Z" if operation == "instanceof" else descriptor, expression)
            if operation == "instanceof" and origin is not None:
                state.registers[0] = _Value("int", type_test=(origin, descriptor))
            return None
        if operation == "array_length":
            value = session.value(state, 0)
            if not value.descriptor.startswith("["):
                return NOT_HANDLED
            expression = self._argument(session, state, 0, value.descriptor) + ".length"
            self._clobber(state, tail)
            session.load_java(state, 0, "I", expression)
            return None
        if operation == "array_store":
            array, index, item = (session.value(state, reg) for reg in (0, 1, 2))
            typ = array.descriptor
            null_item = item.kind == "int" and item.constant == 0
            # Base.arraystore can check type before bounds. aastore is exact
            # when the input fits the runtime component type unconditionally.
            if not null_item and not ((array.origin or "").startswith("array:")
                    and typ.startswith(("[L", "[[")) and item.kind == "ref" and item.descriptor == typ[1:]):
                return NOT_HANDLED
            if index.kind != "int":
                session.fail("reference-array store has a non-integer index")
            if not typ.startswith(("[L", "[[")):
                typ = "[Ljava/lang/Object;"
            receiver = session.java_value(array, session.bank(0, array), typ)
            source = "null" if null_item else session.java_value(item, session.bank(2, item), typ[1:])
            session.statements.append(f"{receiver}[{session.bank(1, index)}] = {source};")
            self._clobber(state, tail)
            return None
        if operation == "class_init":
            # Initializing the class whose initializer is already executing is
            # recursive initialization and therefore has no further effect.
            if klass.name != session.method.owner:
                session.statements.append(f"__jbed_ensure_initialized({json.dumps(klass.name)});")
            self._clobber(state, tail)
            return None
        if operation in ("monitor_enter", "monitor_exit"):
            monitor = session.value(state, 0)
            implicit = False
            if session.method.flags & 0x20:
                if session.method.is_static:
                    owner_class = self.rom.by_descriptor.get(monitor.constant)
                    implicit = owner_class is not None and owner_class.name == session.method.owner
                else:
                    implicit = monitor.origin == "this"
            if implicit:
                # JVM ACC_SYNCHRONIZED owns the method's monitor, including
                # exceptional exits represented by Jbed's frame control word.
                self._clobber(state, tail)
                return None
            reference = self._argument(session, state, 0, "Ljava/lang/Object;")
            if operation == "monitor_enter" and monitor.nonnull:
                operation = "monitor_enter_nonnull"
            session.statements.append(f"__jbed_{operation}({reference});")
            self._clobber(state, tail)
            return None
        raise AssertionError(operation)
