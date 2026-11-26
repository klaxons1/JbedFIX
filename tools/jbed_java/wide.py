"""Jbed's soft-float and two-word arithmetic ABI, expressed as Java values.

The compiler passes successive words in r0..r3 and then on the stack. Long
and double use low word first, without AAPCS even-register padding: an instance
method's first long argument occupies r1/r2. Arithmetic entrypoints are
identified by ROM class/name/signature, never by the caller being recovered.
"""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass, replace
from hashlib import sha256
import struct
from typing import TYPE_CHECKING

from .model import MethodSpec, UnsupportedJava, java_type
from .structure import Block, Branch, Jump, LiftedCFG, Return

if TYPE_CHECKING:
    from .thumb import _Value

NOT_HANDLED = object()
_WIDE = frozenset(("J", "F", "D"))


def word_count(descriptor: str) -> int:
    return 2 if descriptor in ("J", "D") else 0 if descriptor == "V" else 1


def pack_bits(descriptor: str, words: Sequence[str]) -> str:
    """Interpret raw ABI words as a Java value, preserving IEEE bit patterns."""
    if len(words) != word_count(descriptor):
        raise UnsupportedJava(f"{descriptor} needs {word_count(descriptor)} ABI words")
    if descriptor in ("J", "D"):
        bits = f"(((long) ({words[1]}) << 32) | (({words[0]}) & 0xffffffffL))"
        return bits if descriptor == "J" else f"java.lang.Double.longBitsToDouble({bits})"
    if descriptor == "F":
        return f"java.lang.Float.intBitsToFloat({words[0]})"
    if descriptor == "V":
        raise UnsupportedJava("void has no value")
    return words[0]


def unpack_bits(descriptor: str, expression: str) -> tuple[str, ...]:
    """Split a side-effect-free Java value into its low/high transport words."""
    if descriptor == "J":
        bits = expression
    elif descriptor == "D":
        bits = f"java.lang.Double.doubleToRawLongBits({expression})"
    elif descriptor == "F":
        return (f"java.lang.Float.floatToRawIntBits({expression})",)
    elif descriptor == "V":
        return ()
    else:
        return (expression,)
    return (f"((int) ({bits}))", f"((int) (({bits}) >>> 32))")


@dataclass(frozen=True)
class TypedWord:
    """A register or spill holding one unchanged word of a JVM local."""
    local: str
    descriptor: str
    index: int


def packed_value(descriptor: str, values: Sequence[_Value], words: Sequence[str]) -> str:
    first = values[0].typed_word
    if (first is not None and first.descriptor == descriptor
            and all(value.typed_word == TypedWord(first.local, descriptor, index)
                    for index, value in enumerate(values))):
        return first.local
    # FCoder synthesizes constants either with MOV/LSL or literal loads.
    # The constant-pool writer can preserve their complete IEEE bit pattern.
    if descriptor in ("D", "J") and all(value.constant is not None for value in values):
        bits = ((values[1].constant & 0xffffffff) << 32) | (values[0].constant & 0xffffffff)
        literal = f"0x{bits:016x}L"
        return literal if descriptor == "J" else f"java.lang.Double.longBitsToDouble({literal})"
    return pack_bits(descriptor, [str(value.constant) if value.constant is not None else word
                                  for value, word in zip(values, words)])


def field_word(descriptor: str, expression: str, byte_offset: int = 0) -> str:
    """Read one original 32-bit field/array word, including a wide high half."""
    if descriptor not in _WIDE or byte_offset not in range(0, 4 * word_count(descriptor), 4):
        raise UnsupportedJava(f"invalid word offset {byte_offset} for {descriptor}")
    return unpack_bits(descriptor, expression)[byte_offset // 4]


def replace_field_word(descriptor: str, expression: str, word: str,
                       byte_offset: int = 0) -> str:
    """Value after a machine store to one half; the other half stays unchanged."""
    words = list(unpack_bits(descriptor, expression))
    field_word(descriptor, expression, byte_offset)  # Validate the access width/offset.
    words[byte_offset // 4] = word
    return pack_bits(descriptor, words)


_BIT_CONVERSIONS = {
    "java.lang.Float.floatToRawIntBits": ("int", "float"),
    "java.lang.Float.intBitsToFloat": ("float", "int"),
    "java.lang.Double.doubleToRawLongBits": ("long", "double"),
    "java.lang.Double.longBitsToDouble": ("double", "long"),
}


def bit_conversion(expr):
    """Return the typed primitive bit conversion, excluding arbitrary calls.

    Expressions use simplify's small AST. Keeping this matcher here shares the
    compiler ABI knowledge without coupling it to the Java or classfile writer.
    """
    if expr.kind != "call" or len(expr.children) != 2:
        return None
    callee = expr.children[0]
    names = []
    while callee.kind == "member" and len(callee.children) == 1:
        names.append(callee.value)
        callee = callee.children[0]
    if callee.kind != "name":
        return None
    name = ".".join((callee.value, *reversed(names)))
    signature = _BIT_CONVERSIONS.get(name)
    return (name, *signature, expr.children[1]) if signature else None


def _integer_literal(expr):
    if expr.kind == "unary" and expr.value in ("+", "-"):
        value = _integer_literal(expr.children[0])
        return value if value is None or expr.value == "+" else -value
    if expr.kind != "literal":
        return None
    text = expr.value.rstrip("lL")
    try:
        return int(text, 16 if text.lower().startswith("0x") else 10)
    except ValueError:
        return None


def fold_word_transport(expr, type_of, pure):
    """Undo FCoder's word split/rejoin while retaining genuine bit operations.

    The caller has already rewritten child expressions and propagates only
    side-effect-free values. Pair equality is structural, not a textual name
    match; a modified half cannot be mistaken for the original wide value.
    """
    conversion = bit_conversion(expr)
    if conversion:
        name, _, _, argument = conversion
        inner = bit_conversion(argument)
        inverse = {
            "java.lang.Float.intBitsToFloat": "java.lang.Float.floatToRawIntBits",
            "java.lang.Double.longBitsToDouble": "java.lang.Double.doubleToRawLongBits",
        }
        if inner and inverse.get(name) == inner[0] and type_of(inner[3]) == conversion[1]:
            return inner[3]

    if expr.kind != "binary" or expr.value != "|":
        return expr

    def high_word(node):
        if node.kind != "binary" or node.value != "<<" or _integer_literal(node.children[1]) != 32:
            return None
        value = node.children[0]
        if value.kind != "cast" or value.value != "long":
            return None
        return value.children[0]

    def low_word(node):
        if node.kind != "binary" or node.value != "&":
            return None
        first, second = node.children
        if _integer_literal(second) == 0xffffffff and type_of(second) == "long":
            return first
        if _integer_literal(first) == 0xffffffff and type_of(first) == "long":
            return second
        return None

    first, second = expr.children
    high, low = high_word(first), low_word(second)
    if high is None or low is None:
        first, second = second, first
        high, low = high_word(first), low_word(second)
    if high is None or low is None:
        return expr
    high_constant, low_constant = _integer_literal(high), _integer_literal(low)
    if high_constant is not None and low_constant is not None:
        bits = ((high_constant & 0xffffffff) << 32) | (low_constant & 0xffffffff)
        return type(expr)("literal", f"0x{bits:016x}L")
    if high_constant == 0:
        return second  # The original unsigned int-to-long widening.
    if low_constant == 0:
        return first

    # lreturn after moving an unchanged low/high pair, or a helper's result
    # passed immediately to another helper. Both halves retain the same value.
    high_mask = None
    if high.kind == "binary" and high.value == "&":
        for masked, mask in (high.children, tuple(reversed(high.children))):
            if _integer_literal(mask) is not None and type_of(mask) == "int":
                high, high_mask = masked, _integer_literal(mask)
                break
    bitwise = None
    if high.kind == low.kind == "binary" and high.value == low.value and high.value in ("^", "|"):
        def split_constant(node):
            for operand, literal in (node.children, tuple(reversed(node.children))):
                if (bits := _integer_literal(literal)) is not None and type_of(literal) == "int":
                    return operand, bits & 0xffffffff
            return None
        upper, lower = split_constant(high), split_constant(low)
        if upper and lower:
            bitwise = (high.value, (upper[1] << 32) | lower[1])
            high, low = upper[0], lower[0]
    high_source = high.children[0] if high.kind == "cast" and high.value == "int" else high
    low_source = low.children[0] if low.kind == "cast" and low.value == "int" else None
    if (high_source.kind == "binary" and high_source.value in (">>", ">>>")
            and _integer_literal(high_source.children[1]) == 32
            and low_source == high_source.children[0]
            and type_of(low_source) == "long" and pure(low_source)):
        value = low_source
        if bitwise is not None:
            operation, bits = bitwise
            value = type(expr)("binary", operation, (value, type(expr)("literal", f"0x{bits:016x}L")))
        if high_mask is not None:
            mask = ((high_mask & 0xffffffff) << 32) | 0xffffffff
            value = type(expr)("binary", "&", (value, type(expr)("literal", f"0x{mask:016x}L")))
        return value

    # i2l is one low word plus its sign extension from ASR #31.
    if (high_mask is None and bitwise is None and high.kind == "binary" and high.value == ">>"
            and _integer_literal(high.children[1]) == 31
            and high.children[0] == low and type_of(low) == "int" and pure(low)):
        return type(expr)("cast", "long", (low,))
    return expr


@dataclass(frozen=True)
class ArithmeticHelper:
    arguments: tuple[str, ...]
    result: str
    operation: str

    def expression(self, arguments: Sequence[str]) -> str:
        if len(arguments) != len(self.arguments):
            raise UnsupportedJava("arithmetic helper argument count differs from ROM signature")
        a = f"({arguments[0]})"
        if self.operation == "cast":
            return f"(({java_type(self.result)}) {a})"
        if self.operation == "neg":
            return f"(-{a})"
        b = f"({arguments[1]})"
        if self.operation == "unsigned_multiply":
            return f"(({a} & 0xffffffffL) * ({b} & 0xffffffffL))"
        if self.operation in ("comp", "compg", "compl"):
            owner = java_type(self.arguments[0]).capitalize()
            return f"com.jbed.runtime.{owner}.{self.operation}({a}, {b})"
        return f"({a} {self.operation} {b})"


def arithmetic_helper(method: MethodSpec | None) -> ArithmeticHelper | None:
    """Recognize compiler FloatOp/DoubleOp and Long opcode entrypoints.

    Coder.Generate 0x16a648/0x16a7b6 and its opcode table select these exact
    runtime identities. Java casts retain the VM's NaN-to-zero and saturating
    float-to-integer conversion rules; ordinary operators retain wraparound.
    """
    if method is None or not method.is_static:
        return None
    owner = method.owner
    # FCoder.Op2 0x141e28 selects these helpers for nonconstant idiv/irem.
    if owner == "com/jbed/runtime/Integer":
        if method.descriptor == "(II)I" and method.name in ("div", "rem"):
            return ArithmeticHelper(("I", "I"), "I", "/" if method.name == "div" else "%")
        # extMul 0xe6e24 enters ARM and executes UMULL, not signed SMULL.
        if method.name == "extMul" and method.descriptor == "(II)J":
            return ArithmeticHelper(("I", "I"), "J", "unsigned_multiply")
        return None
    kind = {"com/jbed/runtime/Long": "J", "com/jbed/runtime/Float": "F",
            "com/jbed/runtime/Double": "D"}.get(owner)
    if kind is None:
        return None
    binary = {"add": "+", "sub": "-", "mul": "*", "div": "/", "rem": "%"}
    if kind == "J":
        binary.update({"and": "&", "or": "|", "xor": "^"})
    arguments, result, operation = None, kind, None
    if method.name in binary:
        arguments, operation = (kind, kind), binary[method.name]
    elif method.name == "neg":
        arguments, operation = (kind,), "neg"
    elif kind == "J" and method.name in ("shl", "shr", "ushr"):
        arguments, operation = (kind, "I"), {"shl": "<<", "shr": ">>", "ushr": ">>>"}[method.name]
    elif method.name in (("comp",) if kind == "J" else ("compg", "compl")):
        arguments, result, operation = (kind, kind), "I", method.name
    else:
        types = {"int": "I", "long": "J", "float": "F", "double": "D"}
        source, separator, destination = method.name.partition("To")
        if separator and source in types and destination.lower() in types:
            arguments, result, operation = (types[source],), types[destination.lower()], "cast"
    if arguments is None:
        return None
    descriptor = "(" + "".join(arguments) + ")" + result
    if method.descriptor != descriptor:
        return None
    return ArithmeticHelper(arguments, result, operation)


# ARM branch-vector slots in Float.floatNative, in target address order.
_FLOAT_VECTOR = (
    "Double.doubleToLong", "Float.rem", "Float.longToFloat", "Double.rem",
    "Double.doubleToInt", "Float.sub", "Double.compg", "Double.compl",
    "Double.neg", "Float.add", "Double.floatToDouble", "Double.add",
    "Float.compg", "Double.intToDouble", "Float.compl", "Double.longToDouble",
    "Float.floatToLong", "Float.floatToInt", "Float.intToFloat", "Double.div",
    "Double.mul", "Float.mul", "Double.doubleToFloat", "Double.sub",
    "Float.neg", "Float.div",
)
_FLOAT_KERNEL = "5834dae10b89c3c8a1190ba6"

# These pure ARM kernels have no relocations. Integer.div/rem end in a
# relative BL to handleNewException, which is resolved separately.
_INTEGER_KERNELS = {
    "div": "ad03e729a799fc0229a1a1bd", "rem": "32ee5065753d684d594e17a6",
    "extDiv": "d8e817b65b0d4be54fbdcdfe", "uDiv": "e398d73697456cda8de34f5f",
    "longFixMul": "d5b4b857ec73eec84d21173b", "longFixDiv": "277a6bec22c3add9cfd3f55b",
    "sqrt": "9ce0cb098f05ee1f21d07de4",
}


def _float_entry(session, helper):
    method = session.method
    if method.size != 20 or session.end > len(session.parent.image):
        return None
    data = session.parent.image
    mode_switch, load, clear, jump, table = struct.unpack_from("<5I", data, session.start)
    # BX PC; .align 4; LDR ip, literal; BIC ip, ip, #1; ADD pc, ip, #offset.
    if (mode_switch, load, clear) != (0x4778, 0xe59fc004, 0xe3ccc001):
        return None
    offset = jump & 0xff
    vector = session.parent.methods.get(table & ~1)
    if (jump != 0xe28cf000 + offset or offset % 4 or offset // 4 >= len(_FLOAT_VECTOR)
            or vector is None or vector.owner != "com/jbed/runtime/Float" or vector.name != "floatNative"
            or _FLOAT_VECTOR[offset // 4] != method.owner.rsplit("/", 1)[-1] + "." + method.name):
        return None
    # The entry ABI alone doesn't identify the rounding and NaN behavior of
    # the software arithmetic reached through this vector.
    if not sha256(data[vector.address:vector.address + vector.size]).hexdigest().startswith(_FLOAT_KERNEL):
        return None
    expression = helper.expression(method.parameter_names)
    statements = ()
    locals_ = {}
    if helper.result in ("F", "D"):
        cast = "java.lang.Float.intBitsToFloat" if helper.result == "F" else "java.lang.Double.longBitsToDouble"
        positive = f"{cast}(0x7fc00000)" if helper.result == "F" else f"{cast}(0x7ff8000000000000L)"
        if helper.operation == "cast" and helper.arguments[0] in ("F", "D"):
            # Narrowing/widening preserves the sign of a NaN, replacing its payload.
            if helper.result == "F":
                nan = "(int) (java.lang.Double.doubleToRawLongBits(p0) >>> 32) & 0x80000000 | 0x7fc00000"
            else:
                nan = ("((long) java.lang.Float.floatToRawIntBits(p0) << 32) & 0x8000000000000000L"
                       " | 0x7ff8000000000000L")
            expression = f"(p0 == p0 ? {expression} : {cast}({nan}))"
        elif helper.operation in ("+", "-", "*", "/", "%"):
            # MUL/DIV/REM produce a positive quiet NaN for all invalid inputs.
            # ADD preserves a NaN operand. Double ADD canonicalizes when both
            # exponents are all ones. SUB negates the right operand before ADD.
            locals_["result"] = java_type(helper.result)
            statements = (f"result = {expression};",)
            nan = positive
            if helper.operation in ("+", "-"):
                left, right = "p0 != p0", "p1 != p1"
                if helper.result == "D":
                    inf = f"{cast}(0x7ff0000000000000L)"
                    left += f" && p1 > -{inf} && p1 < {inf}"
                    right += f" && p0 > -{inf} && p0 < {inf}"
                rhs = "p1" if helper.operation == "+" else "-p1"
                nan = f"{left} ? p0 : {right} ? {rhs} : {positive}"
            expression = f"(result == result ? result : {nan})"
    return LiftedCFG(session.start, {session.start: Block(session.start, statements, Return(expression))},
                     locals_), 4


def _integer_entry(method, data):
    if not data.startswith(bytes.fromhex("78470000")):
        return None
    start = method.address
    count = 1 + (len(data) - 4) // 4
    if (method.name, method.descriptor) == ("uDiv", "(II)I"):
        # The ARM normalization loop shifts a zero divisor forever.
        blocks = {start: Block(start, (), Branch("p1 == 0", start + 4, start + 8)),
                  start + 4: Block(start + 4, (), Jump(start + 4)),
                  start + 8: Block(start + 8, (), Return("(int) ((p0 & 0xffffffffL) / (p1 & 0xffffffffL))"))}
        return LiftedCFG(start, blocks, {}), count
    if (method.name, method.descriptor) == ("longFixMul", "(JJ)J"):
        # Three UMULLs. Each cross term discards its low word separately.
        a, b = "(p0 >>> 32)", "(p1 >>> 32)"
        result = f"{a} * {b} + (((p0 & 0xffffffffL) * {b}) >>> 32) + (({a} * (p1 & 0xffffffffL)) >>> 32)"
        return LiftedCFG(start, {start: Block(start, (), Return(result))}, {}), count
    if ((method.name, method.descriptor) == ("log2", "(I)I")
            and data[4:] == bytes.fromhex("100f6fe1 200060e2 1eff2fe1")):
        # CLZ followed by 32 - CLZ. CLDC has no numberOfLeadingZeros.
        locals_ = {"bits": "int"}
        initial, condition = ("bits = 0;",), "p0 != 0"
        step, result = ("p0 = p0 >>> 1;", "bits = bits + 1;"), "bits"
    elif (method.name, method.descriptor) == ("extDiv", "(III)I"):
        # Input is the low and high words of the dividend, then a uint32 divisor.
        locals_ = {"bits": "int", "quotient": "int", "remainder": "long", "divisor": "long", "trial": "long"}
        initial = ("bits = 32;", "quotient = p0;", "remainder = p1 & 0xffffffffL;", "divisor = p2 & 0xffffffffL;")
        condition = "bits != 0"
        step = ("trial = (remainder << 1) | (quotient >>> 31);",
                "quotient = (quotient << 1) | (trial >= divisor ? 1 : 0);",
                "remainder = (trial >= divisor ? trial - divisor : trial) & 0xffffffffL;", "bits = bits - 1;")
        result = "quotient"
    elif (method.name, method.descriptor) == ("longFixDiv", "(JJ)J"):
        # The seed bit at position 6 terminates after 58 restoring division steps.
        locals_ = {"bits": "int", "quotient": "long", "remainder": "long", "take": "boolean"}
        initial = ("bits = 58;", "quotient = 0L;", "remainder = 0L;")
        condition = "bits != 0"
        step = ("take = (p0 ^ 0x8000000000000000L) >= (p1 ^ 0x8000000000000000L);",
                "remainder = take ? p0 - p1 : p0;", "quotient = (quotient << 1) | (take ? 1L : 0L);",
                "p0 = remainder << 1;", "bits = bits - 1;")
        result = "(quotient << 5) | (remainder != 0L ? 1L : 0L)"
    elif (method.name, method.descriptor) == ("sqrt", "(J)J"):
        # Bit-by-bit root on the two-word unsigned fixed-point significand.
        locals_ = {"bit": "long", "root": "long", "trial": "long", "take": "boolean"}
        initial, condition = ("root = 0L;", "bit = 1L << 53;"), "bit != 0L"
        step = ("trial = root | bit;", "take = (p0 ^ 0x8000000000000000L) >= (trial ^ 0x8000000000000000L);",
                "p0 = (take ? p0 - trial : p0) << 1;", "root = take ? root | (bit << 1) : root;",
                "bit = bit >>> 1;")
        result = "root"
    else:
        return None
    blocks = {start: Block(start, initial, Jump(start + 4)),
              start + 4: Block(start + 4, (), Branch(condition, start + 8, start + 12)),
              start + 8: Block(start + 8, step, Jump(start + 4)),
              start + 12: Block(start + 12, (), Return(result))}
    return LiftedCFG(start, blocks, locals_), count


def native_arithmetic_entry(session):
    """Recognize the ARM-state implementations behind FCoder's Thumb entry points."""
    method = session.method
    if not method.is_static or method.has_handlers or method.owner not in (
        "com/jbed/runtime/Float", "com/jbed/runtime/Double", "com/jbed/runtime/Integer", "com/jbed/runtime/Long"
    ):
        return None
    helper = arithmetic_helper(method)
    if method.owner in ("com/jbed/runtime/Float", "com/jbed/runtime/Double"):
        if ((method.owner, method.name, method.descriptor) == ("com/jbed/runtime/Float", "floatNative", "()V")
                and sha256(session.parent.image[session.start:session.end]).hexdigest().startswith(_FLOAT_KERNEL)):
            session.fail("shared ARM dispatch table for 26 typed floating-point operations")
        return _float_entry(session, helper) if helper else None
    data = session.parent.image[session.start:session.end]
    if method.owner.endswith("/Integer") and method.name in _INTEGER_KERNELS:
        fixed = data[:-4] if method.name in ("div", "rem") else data
        if not sha256(fixed).hexdigest().startswith(_INTEGER_KERNELS[method.name]):
            return None
    if method.owner.endswith("/Long"):
        # MUL/MLA cross products plus UMULL low-by-low implement lmul.
        if (method.name != "mul" or helper is None or data != bytes.fromhex(
                "78470000 900303e0 923123e0 920081e0 031081e0 1eff2fe1")):
            return None
        count = 6
    elif method.name in ("div", "rem") and helper:
        # Both zero-divisor paths pass exception code 1 to handleNewException.
        interwork = 0 if method.name == "div" else 4
        if (data[interwork:interwork + 4] != bytes.fromhex("78470000")
                or data[-12:-4] != bytes.fromhex("7046 c11e 3a00 0120")):
            return None
        call = session.decode(session.end - 4)
        target = session.parent.methods.get(call.operands[0].imm & ~1) if call and call.mnemonic == "bl" else None
        if not target or (target.owner, target.name) != ("com/jbed/runtime/ArchBase", "handleNewException"):
            return None
        count = (method.size - interwork - 16) // 4 + interwork // 2 + 6
    elif method.name == "extMul" and helper and data == bytes.fromhex("78470000 0020a0e1 920181e0 1eff2fe1"):
        count = 4
    else:
        return _integer_entry(method, data)
    expression = helper.expression(method.parameter_names)
    return LiftedCFG(session.start, {session.start: Block(session.start, (), Return(expression))}, {}), count


def _abi_word(session, state, index: int) -> tuple[_Value, str]:
    if index < 4:
        value = session.value(state, index)
        if value.kind != "int":
            session.fail(f"arithmetic ABI word r{index} is {value.kind}")
        return value, session.bank(index, value)
    offset = state.sp + (index - 4) * 4
    value = state.stack.get(offset)
    if value is None or value.kind != "int":
        session.fail(f"arithmetic ABI word at frame offset {offset} is undefined/non-integer")
    return value, session.slot(offset, value)


def abi_argument(session, state, index: int, descriptor: str) -> str:
    values, words = zip(*(_abi_word(session, state, index + i)
                          for i in range(word_count(descriptor))))
    return packed_value(descriptor, values, words)


class WideModel:
    """Integration hooks for the instruction lifter's raw integer register banks."""

    @staticmethod
    def snapshot(session, state, descriptor, expression, name):
        temporary = session.local(name, java_type(descriptor))
        # A loop can execute this producer again while an earlier result still
        # lives in another register or a spill. Its stored words remain valid.
        for locations in (state.registers, state.stack):
            for location, value in locations.items():
                if value.typed_word and value.typed_word.local == temporary:
                    locations[location] = replace(value, typed_word=None)
        session.statements.append(f"{temporary} = {expression};")
        return temporary

    @staticmethod
    def load_java(session, state, destination: int, descriptor: str, expression: str,
                  high_register: int | None = None) -> bool:
        if descriptor not in _WIDE:
            return False
        from .thumb import _Value
        # A call or volatile read must be evaluated once before splitting.
        temporary = WideModel.snapshot(session, state, descriptor, expression, f"wide_{session.position:x}")
        for index, word in enumerate(unpack_bits(descriptor, temporary)):
            value = _Value("int", typed_word=TypedWord(temporary, descriptor, index))
            register = high_register if index and high_register is not None else destination + index
            session.assign(state, register, value, word)
        return True

    @staticmethod
    def lower_call(session, target: int, state, *, tail: bool = False):
        helper = arithmetic_helper(session.parent.methods.get(target))
        if helper is None:
            return NOT_HANDLED
        from .thumb import _UNKNOWN
        arguments, index = [], 0
        for descriptor in helper.arguments:
            count = word_count(descriptor)
            arguments.append(abi_argument(session, state, index, descriptor))
            index += count
        expression = helper.expression(arguments)
        for register in (0, 1, 2, 3, 12):
            state.registers[register] = _UNKNOWN
        if not tail:
            state.registers[14] = _UNKNOWN
        session.load_java(state, 0, helper.result, expression)
        state.flags = None
        state.carry = None
        return None

    @staticmethod
    def long_add_sub(session, instruction, state):
        """Invert the ROM's ADDS/ADCS or SUBS/SBCS pair, including a high-register move."""
        if instruction.mnemonic not in ("adds", "subs"):
            return None
        high = session.decode(instruction.address + instruction.size)
        setup = None
        if high and high.mnemonic in ("movs", "mov"):
            setup = high
            high = session.decode(setup.address + setup.size)
        subtract = instruction.mnemonic == "subs"
        if (high is None or high.mnemonic != ("sbcs" if subtract else "adcs")
                or len(high.operands) != 2):
            return None
        from capstone.arm import ARM_OP_REG
        from .structure import Jump
        low_reg = instruction.operands[0].reg
        high_reg = high.operands[0].reg
        if low_reg == high_reg or setup and setup.operands[0].reg != high_reg:
            return None

        high_words = []
        for operand in high.operands:
            ins = high
            if setup and operand.reg == high_reg:
                ins, operand = setup, setup.operands[1]
            if operand.type == ARM_OP_REG and operand.reg == low_reg:
                return None  # This input depends on the already-modified low word.
            high_words.append(session.operand(ins, state, operand))
        low_ops = instruction.operands if len(instruction.operands) == 2 else instruction.operands[1:]
        low_words = [session.operand(instruction, state, op) for op in low_ops]
        if any(value.kind != "int" for value, _ in low_words + high_words):
            return None

        def intact(low, high):
            part = low.typed_word
            return (part is not None and part.descriptor == "J" and part.index == 0
                    and high.typed_word == TypedWord(part.local, "J", 1))

        # ADC is commutative. For a constant addition the compiler often
        # puts zero in its destination and the original high word in its source.
        if not subtract and any(intact(low_words[i][0], high_words[1 - i][0]) for i in (0, 1)):
            high_words.reverse()
        operands = []
        for low, upper in zip(low_words, high_words):
            operands.append(packed_value("J", (low[0], upper[0]), (low[1], upper[1])))
        left_lo, right_lo = (f"({word} & 0xffffffffL)" for _, word in low_words)
        left_hi, right_hi = (f"({word} & 0xffffffffL)" for _, word in high_words)
        if subtract:
            carry = f"{left_hi} >= ({right_hi} + ({left_lo} < {right_lo} ? 1L : 0L))"
        else:
            carry = f"({left_hi} + {right_hi} + (({left_lo} + {right_lo}) >>> 32)) >= 0x100000000L"
        name = session.local(f"carry_{high.address:x}", "boolean")
        session.statements.append(f"{name} = {carry};")
        low_dest = session.reg_number(instruction, low_reg)
        high_dest = session.reg_number(high, high_reg)
        operation = "-" if subtract else "+"
        WideModel.load_java(session, state, low_dest, "J", f"({operands[0]} {operation} {operands[1]})",
                            high_dest)
        state.carry = name
        session.position = high.address
        session.flags_result(state, session.bank(high_dest, state.registers[high_dest]))
        session.position = instruction.address
        if setup:
            session.instructions[setup.address] = setup
        session.instructions[high.address] = high
        return Jump(high.address + high.size)

    @staticmethod
    def record_arithmetic_carry(session, state, mnemonic: str, left: str, right: str):
        """Capture C before overwriting a source; MOVS/logical ops preserve it."""
        if mnemonic in ("add", "adds", "cmn"):
            expression = f"(({left}) & 0xffffffffL) + (({right}) & 0xffffffffL) >= 0x100000000L"
        elif mnemonic in ("sub", "subs", "cmp"):
            expression = f"(({left}) & 0xffffffffL) >= (({right}) & 0xffffffffL)"
        elif mnemonic in ("rsbs", "negs"):
            expression = f"(({right}) & 0xffffffffL) >= (({left}) & 0xffffffffL)"
        else:
            return
        name = session.local(f"carry_{session.position:x}", "boolean")
        session.statements.append(f"{name} = {expression};")
        state.carry = name

    @staticmethod
    def record_shift_carry(session, state, mnemonic: str, left: str, right: str,
                           count: int | None = None):
        """ARM's shifted-out bit, including register counts of zero or >=32."""
        if mnemonic not in ("lsls", "lsrs", "asrs"):
            return
        if count == 0:
            return
        amount = str(count) if count is not None else f"(({right}) & 255)"
        if mnemonic == "lsls":
            shifted = f"(({left}) >>> (32 - {amount}) & 1) != 0"
            expression = f"({amount} > 32 ? false : {shifted})"
        elif mnemonic == "lsrs":
            shifted = f"(({left}) >>> ({amount} - 1) & 1) != 0"
            expression = f"({amount} > 32 ? false : {shifted})"
        else:
            shifted = f"(({left}) >>> ({amount} - 1) & 1) != 0"
            expression = f"({amount} >= 32 ? ({left}) < 0 : {shifted})"
        if count is None:
            if state.carry is None:
                # Zero preserves the unknown previous C flag. Refuse a later
                # ADC/SBC unless a subsequent instruction defines it.
                return
            expression = f"({amount} == 0 ? {state.carry} : {expression})"
        name = session.local(f"carry_{session.position:x}", "boolean")
        session.statements.append(f"{name} = {expression};")
        state.carry = name

    @staticmethod
    def carry_condition(state, condition: str):
        """Unsigned ARM conditions after an arithmetic result or preserved C."""
        if state.carry is None:
            return NOT_HANDLED
        if condition in ("hs", "cs"):
            return state.carry
        if condition in ("lo", "cc"):
            return f"!({state.carry})"
        flags = state.flags
        if flags is None or flags.kind not in ("result", "cmp"):
            return NOT_HANDLED
        zero = f"{flags.left} == {flags.right}"
        if condition == "hi":
            return f"({state.carry}) && !({zero})"
        if condition == "ls":
            return f"!({state.carry}) || ({zero})"
        return NOT_HANDLED

    @staticmethod
    def lower_instruction(session, instruction, state) -> bool:
        mnemonic = instruction.mnemonic.removesuffix(".w")
        if mnemonic not in ("adc", "adcs", "sbc", "sbcs"):
            return False
        from .thumb import _INT
        if state.carry is None:
            session.fail(f"{mnemonic} has no recovered incoming carry")
        operands = instruction.operands
        destination = session.reg_number(instruction, operands[0].reg)
        inputs = operands if len(operands) == 2 else operands[1:]
        left, lhs = session.operand(instruction, state, inputs[0])
        right, rhs = session.operand(instruction, state, inputs[1])
        if left.kind != "int" or right.kind != "int":
            session.fail(f"{mnemonic} operands are not integer ABI words")
        temporary = session.local(f"carry_sum_{session.position:x}", "long")
        if mnemonic.startswith("adc"):
            expression = f"(({lhs}) & 0xffffffffL) + (({rhs}) & 0xffffffffL) + ({state.carry} ? 1L : 0L)"
            carry = f"{temporary} >= 0x100000000L"
        else:
            expression = f"(({lhs}) & 0xffffffffL) - (({rhs}) & 0xffffffffL) - ({state.carry} ? 0L : 1L)"
            carry = f"{temporary} >= 0L"
        session.statements.append(f"{temporary} = {expression};")
        session.assign(state, destination, _INT, f"(int) {temporary}")
        if instruction.update_flags:
            name = session.local(f"carry_{session.position:x}", "boolean")
            session.statements.append(f"{name} = {carry};")
            state.carry = name
            session.flags_result(state, session.bank(destination, _INT))
        return True
