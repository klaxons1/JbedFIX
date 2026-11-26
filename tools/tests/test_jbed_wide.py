"""Representative wide-value recovery checks against the original ROM code."""

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from unicorn import UC_HOOK_CODE
from unicorn.arm_const import UC_ARM_REG_R0, UC_ARM_REG_R1

from tools.jbed_java.classfile import ClassFileBuilder, ConstantPool, emit_method_code
from tools.jbed_java.model import RomImage
from tools.jbed_java.thumb import lift_method
from tools.tests.test_jbed_bytecode import ThumbOracle

ROOT = Path(__file__).resolve().parents[2]


class WideRecoveryTest(unittest.TestCase):
    @unittest.skipUnless(shutil.which("javac") and shutil.which("java"), "a JDK is required")
    def test_arm_arithmetic_entries(self):
        image = RomImage(ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")
        oracle = ThumbOracle(image.data)
        exception = next(m.address for m in image.class_named("com/jbed/runtime/ArchBase").methods
                         if m.name == "handleNewException")

        def trap(machine, address, size, data):
            self.assertEqual(machine.reg_read(UC_ARM_REG_R0), 1)
            oracle.exception = "ArithmeticException"
            machine.emu_stop()

        oracle.machine.hook_add(UC_HOOK_CODE, trap, begin=exception, end=exception)
        cases = {
            "Float": {"add": (0x7f800123, 0xffc45678), "sub": (0, 0xff800123),
                      "mul": (0x7f800000, 0), "rem": (0xff812345, 0x3f800000)},
            "Double": {"add": (0x7ff8000012345678, 0xfff0000000000000),
                       "doubleToFloat": (0xfff8000012345678,), "floatToDouble": (0xffc12345,)},
            "Integer": {"div": (0x80000000, 0xffffffff), "rem": (9, 0),
                        "extMul": (0xffffffff, 0xfffffffe), "extDiv": (5, 3, 7),
                        "uDiv": (0xfffffff7, 3), "sqrt": (0xffffffffffffffff,),
                        "log2": (0x80000000,), "longFixDiv": (0x7fffffffffffffff, 0x8000000000000000),
                        "longFixMul": (0xffffffffaabbccdd, 0x8899aabb12345678)},
            "Long": {"mul": (0xffffffffffffffff, 0x8000000000000000)},
        }
        expected, calls = [], []
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            for owner, inputs in cases.items():
                builder = ClassFileBuilder("Recovered" + owner)
                for method in image.class_named("com/jbed/runtime/" + owner).methods:
                    if method.name not in inputs:
                        continue
                    cfg = lift_method(image, method).cfg
                    self.assertIsNotNone(cfg, method)
                    builder.add_method(method.name, method.descriptor, 9, code=emit_method_code(
                        image, method, cfg, builder.pool))
                    words, arguments = [], []
                    for kind, bits in zip(method.argument_types, inputs[method.name], strict=True):
                        wide = kind in ("J", "D")
                        literal = f"0x{bits:x}" + ("L" if wide else "")
                        arguments.append({"F": f"Float.intBitsToFloat({literal})",
                                          "D": f"Double.longBitsToDouble({literal})"}.get(kind, literal))
                        words.append(bits & 0xffffffff)
                        if wide:
                            words.append(bits >> 32)
                    call = builder.name + "." + method.name + "(" + ", ".join(arguments) + ")"
                    kind = method.return_type
                    result = oracle.call(method.address, words) & 0xffffffff
                    if kind in ("J", "D"):
                        result |= oracle.machine.reg_read(UC_ARM_REG_R1) << 32
                    if kind == "F":
                        call = f"Float.floatToRawIntBits({call})"
                    elif kind == "D":
                        call = f"Double.doubleToRawLongBits({call})"
                    number = "Long" if kind in ("J", "D") else "Integer"
                    calls.append(f"try {{ System.out.println({number}.toHexString({call})); }}"
                                 ' catch (ArithmeticException e) { System.out.println("ArithmeticException"); }')
                    expected.append(oracle.exception or f"{result:x}")
                (path / (builder.name + ".class")).write_bytes(builder.to_bytes())
            source = path / "Probe.java"
            source.write_text("public class Probe {public static void main(String[] args) {\n"
                              + "\n".join(calls) + "\n}}")
            subprocess.run(["javac", "-cp", path, "-d", path, source], check=True, capture_output=True)
            result = subprocess.check_output(["java", "-Xverify:all", "-cp", path, "Probe"], text=True)
            self.assertEqual(result.splitlines(), expected)

    def test_random_arithmetic_keeps_typed_operands(self):
        image = RomImage(ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")
        for address, divisor in ((0xba49c, (4, 0x4b800000)),
                                 (0xba4c2, (6, 0x4340000000000000))):
            method = image.method_at(address)
            with self.subTest(method=method.name):
                result = lift_method(image, method)
                self.assertIsNone(result.failure)
                pool = ConstantPool()
                emit_method_code(image, method, result.cfg, pool)
                calls = {key[1:] for key in pool.indices if key[0] in (10, 11)}
                self.assertEqual(calls, {("java/util/Random", "next", "(I)I")})
                self.assertIn(divisor, pool.indices)
        method = image.method_at(0xba3a4)  # Random.next(int) updates its 48-bit seed.
        pool = ConstantPool()
        code = emit_method_code(image, method, lift_method(image, method).cfg, pool)
        self.assertIn((5, 0xffffffffffff), pool.indices)
        for opcode in (0x69, 0x61, 0x7f):  # lmul, ladd, land
            self.assertEqual(code.bytecode.count(opcode), 1)

    def test_double_field_uses_one_jvm_access(self):
        image = RomImage(ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")
        for address, opcode in ((0xd2a04, 0xb5), (0xd2b7c, 0xb4)):
            method = image.method_at(address)
            with self.subTest(method=method.name):
                result = lift_method(image, method)
                self.assertIsNone(result.failure)
                pool = ConstantPool()
                code = emit_method_code(image, method, result.cfg, pool)
                access = bytes([opcode]) + pool.indices[(9, "java/lang/Double", "value", "D")].to_bytes(2)
                self.assertEqual(code.bytecode.count(access), 1)
                self.assertFalse(any(key[0] == 10 and key[1] == "java/lang/Double"
                                     for key in pool.indices))

    @unittest.skipUnless(shutil.which("javac") and shutil.which("java"), "a JDK is required")
    def test_generated_wide_methods_match_original(self):
        image = RomImage(ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")
        addresses = {"long": 0xb8440, "float": 0xb84be, "double": 0xb84c4,
                     "degrees": 0xb8708, "add": 0xe66a8, "sub": 0xe6950}
        recovered = ClassFileBuilder("RecoveredWide")
        for address in addresses.values():
            method = image.method_at(address)
            result = lift_method(image, method, structure=False)
            self.assertIsNone(result.failure, f"{method.name}{method.descriptor}: {result.failure}")
            recovered.add_method(method.name, method.descriptor, 9, code=emit_method_code(
                image, method, result.cfg, recovered.pool, remap={"java/lang/Math": "RecoveredWide"}))
        source = "public class WideDriver {\n" + r'''
            public static void main(String[] args) throws Exception {
                java.io.BufferedReader input = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
                for (String line; (line = input.readLine()) != null;) {
                    String[] words = line.split("\\|");
                    long a = Long.parseUnsignedLong(words[1]);
                    switch (words[0]) {
                        case "long": System.out.println(Long.toUnsignedString(RecoveredWide.abs(a))); break;
                        case "float": System.out.println(Integer.toUnsignedString(Float.floatToRawIntBits(RecoveredWide.abs(Float.intBitsToFloat((int) a))))); break;
                        case "double": System.out.println(Long.toUnsignedString(Double.doubleToRawLongBits(RecoveredWide.abs(Double.longBitsToDouble(a))))); break;
                        case "degrees": System.out.println(Long.toUnsignedString(Double.doubleToRawLongBits(RecoveredWide.toDegrees(Double.longBitsToDouble(a))))); break;
                        case "add": System.out.println(Long.toUnsignedString(RecoveredWide.add(a, Long.parseUnsignedLong(words[2])))); break;
                        case "sub": System.out.println(Long.toUnsignedString(RecoveredWide.sub(a, Long.parseUnsignedLong(words[2])))); break;
                        default: throw new AssertionError(words[0]);
                    }
                }
            }
        }'''
        inputs, expected = [], []
        oracle = ThumbOracle(image.data)

        def compare(operation, first, second=None):
            values = (first,) if second is None else (first, second)
            words = [word for value in values for word in (value & 0xffffffff, value >> 32)]
            if operation == "float":
                words = [first]
            low = oracle.call(addresses[operation], words) & 0xffffffff
            high = oracle.machine.reg_read(UC_ARM_REG_R1)
            expected.append(str(low if operation == "float" else low | (high << 32)))
            inputs.append(operation + "|" + "|".join(map(str, values)))

        for value in (0, 0xffffffffffffffff, 0x8000000000000000, 0xffffffff00000000):
            compare("long", value)
        for first, second in ((0, 1), (0xffffffff, 1), (0x100000000, 1),
                              (0x7fffffffffffffff, 1), (0x8000000000000000, 0xffffffffffffffff)):
            compare("add", first, second)
            compare("sub", first, second)
        compare("float", 0xffc12345)
        compare("double", 0xfff8123456789abc)
        # Exercise soft-float helper lowering as well as bitwise float transport.
        compare("degrees", 0x3ff8000000000000)
        with tempfile.TemporaryDirectory(prefix="jbed-bytecode-wide-") as directory:
            path = Path(directory) / "WideDriver.java"
            (Path(directory) / "RecoveredWide.class").write_bytes(recovered.to_bytes())
            path.write_text(source)
            compiled = subprocess.run(["javac", "-cp", directory, "-d", directory, str(path)],
                                      capture_output=True, text=True, check=False)
            self.assertEqual(compiled.returncode, 0, compiled.stderr)
            executed = subprocess.run(["java", "-Xverify:all", "-cp", directory, "WideDriver"],
                input="\n".join(inputs) + "\n", capture_output=True, text=True, check=False)
            self.assertEqual(executed.returncode, 0, executed.stderr)
            self.assertEqual(executed.stdout.splitlines(), expected)


if __name__ == "__main__":
    unittest.main()
