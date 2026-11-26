"""Compare recovered JVM bytecode with the original ROM instructions.

Run with python3 -m unittest discover -s tools/tests. Requires Capstone,
Unicorn and a JDK. These checks execute isolated methods, not the Android VM.
"""

from __future__ import annotations

import base64
from dataclasses import dataclass
from pathlib import Path
import os
import random
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from tools.jbed_java.classfile import (ClassFileBuilder, Code, LiftedBody, emit_classfile,
    emit_method_code)
from tools.jbed_java.model import MethodSpec, RomImage, UnsupportedJava
from tools.jbed_java.structure import Block, Branch, LiftedCFG, Return, Switch
from tools.jbed_java.thumb import ThumbLifter, lift_method
from unicorn import Uc, UC_ARCH_ARM, UC_HOOK_CODE, UC_MODE_THUMB
from unicorn.arm_const import (UC_ARM_REG_LR, UC_ARM_REG_PC, UC_ARM_REG_R0,
    UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3, UC_ARM_REG_R9, UC_ARM_REG_R10,
    UC_ARM_REG_SP)


def signed(value):
    value &= 0xffffffff
    return value - 0x100000000 if value & 0x80000000 else value


def array_text(values):
    return "null" if values is None else ",".join(str(signed(x)) for x in values)


@dataclass(frozen=True)
class CopyCase:
    source: tuple[int, ...] | None
    target: tuple[int, ...] | None
    source_index: int
    target_index: int
    count: int
    alias: bool = False


class ThumbOracle:
    """Jbed's four-register Java ABI, with explicit null/bounds trap outcomes."""

    STATE = 0x700000
    STACK = STATE + 0xf000
    STOP = STATE + 0x10000
    SOURCE = STATE + 0x1000
    TARGET = STATE + 0x2000
    TRAPS = {0xe080c: "NullPointerException", 0xe0818: "ArrayIndexOutOfBoundsException"}

    def __init__(self, image):
        self.machine = Uc(UC_ARCH_ARM, UC_MODE_THUMB)
        self.machine.mem_map(0, (len(image) + 4095) & ~4095)
        self.machine.mem_write(0, image)
        self.machine.mem_map(self.STATE, 0x11000)
        self.exception = None
        self.machine.hook_add(UC_HOOK_CODE, self._trap, begin=0xe080c, end=0xe0818)

    def _trap(self, machine, address, _size, _data):
        if address in self.TRAPS:
            self.exception = self.TRAPS[address]
            machine.emu_stop()

    def call(self, address, arguments):
        self.exception = None
        machine = self.machine
        machine.reg_write(UC_ARM_REG_SP, self.STACK)
        machine.reg_write(UC_ARM_REG_LR, self.STOP | 1)
        machine.reg_write(UC_ARM_REG_R9, self.STATE)
        machine.reg_write(UC_ARM_REG_R10, 0)
        registers = (UC_ARM_REG_R0, UC_ARM_REG_R1, UC_ARM_REG_R2, UC_ARM_REG_R3)
        for index, register in enumerate(registers):
            machine.reg_write(register, arguments[index] & 0xffffffff if index < len(arguments) else 0)
        for index, argument in enumerate(arguments[4:]):
            machine.mem_write(self.STACK + index * 4, struct.pack("<I", argument & 0xffffffff))
        machine.emu_start(address | 1, self.STOP, count=20000)
        if self.exception is None and machine.reg_read(UC_ARM_REG_PC) != self.STOP:
            raise AssertionError(f"ROM method 0x{address:x} did not return")
        return signed(machine.reg_read(UC_ARM_REG_R0))

    def _write_array(self, address, values):
        if values is None:
            return 0
        self.machine.mem_write(address, bytes(12) + struct.pack("<I", len(values)))
        if values:
            self.machine.mem_write(address + 16,
                struct.pack("<" + "I" * len(values), *(x & 0xffffffff for x in values)))
        return address

    def _read_array(self, address, length):
        if not address:
            return None
        return struct.unpack("<" + "i" * length, self.machine.mem_read(address + 16, length * 4))

    def copy(self, case):
        source = self._write_array(self.SOURCE, case.source)
        target = source if case.alias else self._write_array(self.TARGET, case.target)
        self.call(0x172864, (source, case.source_index, target, case.target_index, case.count))
        source_values = self._read_array(source, len(case.source or ()))
        target_values = self._read_array(target, len((case.source if case.alias else case.target) or ()))
        return "|".join((self.exception or "ok", array_text(source_values), array_text(target_values)))

    def recycle(self):
        self.machine.mem_write(self.STATE, struct.pack("<14I", 0, 0, 0,
            self.SOURCE, self.TARGET, 1, 2, 3, 4, 5, 6, 1, 7, self.TARGET))
        self.call(0x178a28, (self.STATE,))
        values = struct.unpack("<11I", self.machine.mem_read(self.STATE + 12, 44))
        maps, emaps, map_index, emap_index, base, end, address, maximum, ended, size, successor = values
        return ",".join(map(str, (map_index, emap_index, base, end, address,
            int(successor == 0), maximum, size, ended, int(maps == self.SOURCE),
            int(emaps == self.TARGET))))


DRIVER = r"""
    static int[] array(String text) {
        if (text.equals("null")) return null;
        if (text.isEmpty()) return new int[0];
        String[] words = text.split(",");
        int[] result = new int[words.length];
        for (int i = 0; i < words.length; i++) result[i] = Integer.parseInt(words[i]);
        return result;
    }
    static String text(int[] values) {
        if (values == null) return "null";
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < values.length; i++) {
            if (i != 0) result.append(',');
            result.append(values[i]);
        }
        return result.toString();
    }
    public static void main(String[] arguments) throws Exception {
        java.io.BufferedReader input = new java.io.BufferedReader(new java.io.InputStreamReader(System.in));
        for (String line; (line = input.readLine()) != null;) {
            String[] words = line.split("\\|", -1);
            if (words[0].equals("call")) {
                System.out.println(callInstrToDest(Integer.parseInt(words[1]), Integer.parseInt(words[2])));
            } else if (words[0].equals("min")) {
                System.out.println(min(Integer.parseInt(words[1]), Integer.parseInt(words[2])));
            } else if (words[0].equals("digit")) {
                System.out.println(isDigit((char) Integer.parseInt(words[1])) ? 1 : 0);
            } else if (words[0].equals("alpha")) {
                System.out.println(recovered.CharacterUtil.isAlpha((char) Integer.parseInt(words[1])) ? 1 : 0);
            } else if (words[0].equals("alnum")) {
                System.out.println(recovered.CharacterUtil.isAlphaNum((char) Integer.parseInt(words[1])) ? 1 : 0);
            } else if (words[0].equals("countdown")) {
                System.out.println(countdown(Integer.parseInt(words[1])));
            } else if (words[0].equals("catch")) {
                System.out.println(RecoveredCatch.newEmptyStringLen(Integer.parseInt(words[1])));
            } else if (words[0].equals("packed")) {
                byte[] bytes = java.util.Base64.getDecoder().decode(words[2]);
                System.out.println(new Recovered().readInt(bytes, Integer.parseInt(words[1])));
            } else if (words[0].equals("recycle")) {
                Recovered value = new Recovered();
                int[] first = {1}, second = {2};
                value.maps = first; value.emaps = second;
                value.mapIndex = 1; value.emapIndex = 2; value.pcBase = 3;
                value.pcEnd = 4; value.addr = 5; value.maxMapLength = 6;
                value.endSet = true; value.maxSize = 7; value.next = new Recovered();
                value.recycle();
                System.out.println(value.mapIndex + "," + value.emapIndex + "," + value.pcBase + ","
                    + value.pcEnd + "," + value.addr + "," + (value.next == null ? 1 : 0) + ","
                    + value.maxMapLength + "," + value.maxSize + "," + (value.endSet ? 1 : 0) + ","
                    + (value.maps == first ? 1 : 0) + "," + (value.emaps == second ? 1 : 0));
            } else {
                int[] source = array(words[5]);
                int[] target = words[1].equals("1") ? source : array(words[6]);
                String outcome = "ok";
                try {
                    copy(source, Integer.parseInt(words[2]), target,
                         Integer.parseInt(words[3]), Integer.parseInt(words[4]));
                } catch (RuntimeException exception) {
                    outcome = exception.getClass().getSimpleName();
                }
                System.out.println(outcome + "|" + text(source) + "|" + text(target));
            }
        }
    }
"""


class BytecodeRecoveryTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.image = RomImage(ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")

    def test_vm_intrinsics_do_not_become_recursive_or_empty_java_bodies(self):
        lifter = ThumbLifter(self.image.data, self.image.methods_by_address,
                            self.image.fields, helpers=self.image.helpers,
                            superclasses=self.image.superclasses, rom=self.image)
        for address in (0xadc3a, 0xe03b4, 0xe0bf6):
            with self.subTest(address=hex(address)):
                result = lifter.lift(self.image.method_at(address), structure=False)
                self.assertIn("requires a runtime intrinsic", result.failure)

    def test_null_stores_at_joins_are_deterministic(self):
        with tempfile.TemporaryDirectory() as work:
            outputs = []
            for seed in ("0", "7"):
                jar = Path(work) / (seed + ".jar")
                subprocess.run([sys.executable, ROOT / "tools/recover_jbed_bytecode.py",
                                "--class", "com/jbed/ams/Installer", "--method", "installStepRms",
                                "-j", "1", "-o", jar],
                               check=True, stdout=subprocess.DEVNULL, env=dict(os.environ, PYTHONHASHSEED=seed))
                outputs.append(jar.read_bytes())
            self.assertEqual(outputs[0], outputs[1])

    @unittest.skipUnless(shutil.which("javap"), "a JDK is required")
    def test_bootstrap_bitcasts(self):
        pairs = (("java/lang/Float", "intBitsToFloat", "floatToRawIntBits"),
                 ("java/lang/Double", "longBitsToDouble", "doubleToRawLongBits"))
        with tempfile.TemporaryDirectory() as directory:
            for owner, name, raw in pairs:
                klass = self.image.class_named(owner)
                method = next(m for m in klass.methods if m.name == name)
                lift = lift_method(self.image, method, structure=False)
                self.assertIsNone(lift.failure)
                for exported in (owner, "Recovered" + owner.rsplit("/", 1)[-1]):
                    path = Path(directory) / (exported.rsplit("/", 1)[-1] + ".class")
                    path.write_bytes(emit_classfile(self.image, klass, {method: lift.cfg},
                        methods=(method,), remap={owner: exported}))
                    info = subprocess.check_output(["javap", "-p", "-v", str(path)], text=True)
                    if exported == owner:
                        self.assertRegex(info, rf"public static native \w+ {name}\(")
                        self.assertRegex(info, rf"public static native \w+ {raw}\(")
                        self.assertIn("ACC_NATIVE, ACC_SYNTHETIC", info)
                        self.assertNotIn("invokestatic", info)
                    else:
                        self.assertIn(f"// Method {owner}.{name}:", info)
                        self.assertNotIn(f"// Method {exported}.{name}:", info)

    def test_missing_body_is_refused(self):
        with self.assertRaises(UnsupportedJava):
            ClassFileBuilder("Missing").add_method("body", "()V")

    def test_packed_fields_keep_their_bundle_identity(self):
        def field(owner, name):
            return next(f.descriptor for f in self.image.class_named(owner).fields if f.name == name)

        loop = "com/jbed/midp/lcdui/lookandfeel/EventLoop"
        display = self.image.class_named("com/jbed/midp/lcdui/ewt/Display")
        getter = next(m for m in display.methods if m.name == "getEventLoop")
        self.assertEqual(field(display.name, "fEventLoop"), f"L{loop};")
        self.assertEqual(getter.descriptor, "()" + field(display.name, "fEventLoop"))
        self.assertIn(loop, self.image.class_named("com/jbed/midp/lcdui/javaui/FBCCEventLoop").interfaces)
        self.assertEqual(field("javax/microedition/rms/RecordStore", "peerObj"),
                         "Ljavax/microedition/rms/RecordStorePeerBase;")
        self.assertEqual(field("com/jbed/ams/Manager", "displaySizeInfos"),
                         "[Lcom/jbed/ams/DisplaySizeInfo;")

    def test_indirect_unknown_descriptor_does_not_block_caller(self):
        manager = self.image.class_named("com/jbed/ams/Manager")
        method = next(m for m in manager.methods if m.name == "showMIDletsInSuite")
        self.assertIsNone(lift_method(self.image, method).failure)

        # The stripped getAmsCmdReceiver() returns null. Its direct caller
        # still initializes AmsToolkitBase before taking the original null trap.
        caller = next(
            m for m in self.image.class_named("com/jbed/ams/NativeAms").methods if m.name == "postEvent"
            and m.descriptor == "(IILjava/lang/Object;)V")
        result = lift_method(self.image, caller)
        self.assertIsNone(result.failure)
        block = result.cfg.blocks[0xcce44]
        self.assertIn('__jbed_ensure_initialized("com/jbed/ams/AmsToolkitBase");', block.statements)
        self.assertEqual(block.terminator.value, "new NullPointerException()")

    def test_class_and_interface_vtables_select_different_invocations(self):
        cases = (
            (0x1859ce, "com/jbed/midp/lcdui/toolkit/peer/StandardDisplayPeer", "getColor", "(I)I", 0xb6),
            (0xc2e60, "java/lang/Runnable", "run", "()V", 0xb9),
        )
        for address, owner, name, descriptor, opcode in cases:
            method = self.image.method_at(address)
            cfg = lift_method(self.image, method).cfg
            pool = ClassFileBuilder(method.owner).pool
            code = emit_method_code(self.image, method, cfg, pool)
            reference = pool.method(owner, name, descriptor, interface=opcode == 0xb9)
            self.assertIn(struct.pack(">BH", opcode, reference), code.bytecode)

    @unittest.skipUnless(shutil.which("javap"), "a JDK is required")
    def test_rom_field_accessors_and_default_constructor_flag(self):
        # Subset exports still supply accessors on the class that owns the field.
        with tempfile.TemporaryDirectory() as directory:
            for owner, accessors in (("java/lang/Class", ("get$initializer", "get$modifiers", "get$base")),
                                   ("java/lang/Throwable", ("set$detailMessage",))):
                klass = self.image.class_named(owner)
                path = Path(directory) / (owner.rsplit("/", 1)[-1] + ".class")
                path.write_bytes(emit_classfile(self.image, klass, {}, methods=()))
                info = subprocess.check_output(["javap", "-p", "-v", str(path)], text=True)
                for accessor in accessors:
                    self.assertIn("__jbed$" + accessor, info)
                self.assertEqual(info.count("ACC_PUBLIC, ACC_FINAL, ACC_SYNTHETIC"), len(accessors))
                self.assertNotIn("ACC_ENUM", info)
                if owner == "java/lang/Throwable":
                    self.assertIn("private java.lang.String detailMessage", info)

    @unittest.skipUnless(shutil.which("javap"), "a JDK is required")
    def test_rom_math_min_uses_all_five_jvm_compare_opcodes(self):
        klass = self.image.class_named("java/lang/Math")
        methods = tuple(m for m in klass.methods if m.name == "min" and
                        m.descriptor in ("(JJ)J", "(FF)F", "(DD)D"))
        bodies = {m: lift_method(self.image, m, structure=False).cfg for m in methods}
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Comparisons.class"
            path.write_bytes(emit_classfile(self.image, klass, bodies, methods=methods,
                             remap={klass.name: "Comparisons"}))
            listing = subprocess.check_output(["javap", "-p", "-c", str(path)], text=True)
        compares = re.findall(r"^\s*\d+: (lcmp|[fd]cmp[lg])$", listing, re.MULTILINE)
        self.assertCountEqual(compares, ("lcmp", "fcmpl", "fcmpg", "dcmpl", "dcmpg"))

    def test_short_and_distant_branches_over_a_tableswitch(self):
        method = MethodSpec("java/lang/Math", "dispatch", "(I)I", 0x1000, 8, True, 9)
        for count in (2, 8192):
            cfg = LiftedCFG(0x1000, {
                0x1000: Block(0x1000, (), Branch("p0 == 0", 0x1006, 0x1002)),
                0x1002: Block(0x1002, (), Switch("p0", tuple((i, 0x1004) for i in range(count)), 0x1006)),
                0x1004: Block(0x1004, (), Return("1")),
                0x1006: Block(0x1006, (), Return("2")),
            }, {})
            code = emit_method_code(self.image, method, cfg, ClassFileBuilder("Calc").pool).bytecode
            # Only a distant target needs the inverse conditional over goto_w.
            jump, width = (0x9f, 2) if count == 2 else (0xc8, 4)
            site = code.index(jump)
            target = site + int.from_bytes(code[site + 1:site + 1 + width], "big", signed=True)
            self.assertEqual(code[target:], b"\x05\xac")
            switch = code.index(0xaa)
            payload = (switch + 4) & ~3
            default, low, high, first = struct.unpack_from(">4i", code, payload)
            self.assertEqual((switch + default, low, high), (target, 0, count - 1))
            self.assertEqual(code[switch + first:target], b"\x04\xac")

    def test_constant_first_iteration_reaches_rom_switch_tables(self):
        oracle = ThumbOracle(self.image.data)
        # makeDate uses BHI default; handshake uses BLS table then B default.
        for start, guard, keys, default_steps in (
            (0x174b48, 0x174b8c, 8, 2), (0x1a9008, 0x1a905c, 13, 3),
        ):
            result = lift_method(self.image, self.image.method_at(start), structure=False)
            self.assertIsNone(result.failure)
            switch, = (b.terminator for b in result.cfg.blocks.values()
                       if isinstance(b.terminator, Switch))
            targets = dict(switch.cases)
            self.assertEqual(set(targets), set(range(keys)))
            for selector in (*targets, -1, keys, keys + 1, 0x80000000):
                oracle.machine.reg_write(UC_ARM_REG_R0, selector & 0xffffffff)
                oracle.machine.emu_start(guard | 1, oracle.STOP,
                                         count=6 if selector in targets else default_steps)
                self.assertEqual(oracle.machine.reg_read(UC_ARM_REG_PC),
                                 targets.get(selector, switch.default_target))

    def test_exception_only_edges_are_not_silently_dropped(self):
        method = self.image.method_at(0xe1734)  # Jbni.newEmptyStringLen(int).
        self.assertEqual(tuple(region.catch_class for region in method.exception_regions),
                         ("java/lang/OutOfMemoryError",))
        result = lift_method(self.image, method, structure=False)
        self.assertIsNone(result.failure)
        self.assertIsNotNone(result.cfg)
        self.assertTrue(result.exception_regions)
        self.assertTrue(all(region.handler == 0xe174c and region.catch_class == "java/lang/OutOfMemoryError"
                            for region in result.exception_regions))
        self.assertIn(0xe174c, result.cfg.blocks)
        self.assertEqual(result.handler_locals, {0xe174c: "v0"})

    def test_native_field_load_cannot_enter_call_handler(self):
        method = self.image.method_at(0xd6318)  # SelectorStream.checkSanity
        result = lift_method(self.image, method)
        self.assertIsNone(result.failure)
        # The catch reads the saved root. The null check precedes the native
        # range, then ldr/str save that root before getUniqueIDFromStorageName.
        def catches_at(address):
            return [r.handler for r in result.exception_regions if r.start <= address < r.end]

        self.assertEqual(catches_at(0xd636a), [])        # ldr r0, [r5, ...]
        self.assertEqual(catches_at(0xd636e), [0xd63cc])  # bl getUniqueIDFromStorageName

    @unittest.skipUnless(shutil.which("javac") and shutil.which("java"), "a JDK is required")
    def test_packed_array_initializers(self):
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            for owner, name in (("java/util/TimeZone$TimeZoneImpl", "Months"), ("com/sun/midp/io/Base64", "Base64"),
                                ("com/jbed/security/GenData", "Permissions")):
                klass = self.image.class_named(owner)
                initializer = next(m for m in klass.methods if m.name == "<clinit>")
                result = lift_method(self.image, initializer)
                self.assertIsNone(result.failure)
                table = ClassFileBuilder(name)
                for field in klass.fields:
                    if field.is_static:
                        table.add_field(field.name, field.descriptor, 9)
                code = emit_method_code(self.image, initializer, result.cfg, table.pool, remap={owner: name})
                table.add_method("<clinit>", "()V", 8, code=code)
                (directory / (name + ".class")).write_bytes(table.to_bytes())
            driver = directory / "Tables.java"
            driver.write_text("class Tables { public static void main(String[] args) {"
                              " System.out.println(java.util.Arrays.toString(Months.staticMonthLength));"
                              " System.out.println(Base64.ALPHABET);"
                              " System.out.println(java.util.Arrays.toString(Permissions.perm_canLockDown));"
                              " System.out.println(java.util.Arrays.toString(Permissions.fg2permsMap[4])); } }")
            subprocess.run(["javac", "-proc:none", "-cp", tmp, "-d", tmp, driver], check=True)
            tables = subprocess.check_output(["java", "-Xverify:all", "-cp", tmp, "Tables"], text=True)
            self.assertEqual(tables.splitlines(), ["[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]",
                                                  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",
                                                  "[" + ", ".join(["true"] * 24) + "]", "[2, 3, 4, 5, 18, 20, 21, 22]"])

    def test_buffer_append_copies_the_selected_rom_or_heap_string(self):
        method = self.image.method_at(0xb7b90)
        result = lift_method(self.image, method)
        self.assertIsNone(result.failure)
        blocks = result.cfg.blocks
        literal, = (line for block in blocks.values() for line in block.statements if line.endswith(' = "null";'))
        receiver = literal.split(" = ", 1)[0]
        self.assertTrue(any(f"((java.lang.String) {receiver}).getChars(" in line
                            for line in blocks[0xb7bfa].statements))
        pool = ClassFileBuilder(method.owner).pool
        code = emit_method_code(self.image, method, LiftedBody(result.cfg, result.exception_regions,
                                result.handler_locals), pool).bytecode
        self.assertIn(struct.pack(">BH", 0xb6, pool.method("java/lang/String", "getChars", "(II[CI)V")), code)

    def test_recordstore_monitor_cleanup_starts_after_acquisition(self):
        method = self.image.method_at(0xce9a0)  # RecordStore.setMode
        result = lift_method(self.image, method, structure=False)
        self.assertIsNone(result.failure)
        code = emit_method_code(self.image, method, LiftedBody(
            result.cfg, result.exception_regions, result.handler_locals), ClassFileBuilder("Store").pool)
        protected = [code.bytecode[start] for start, _, _, _ in code.exception_table]
        # The native null trap precedes the range. Getfield and the peer call
        # are inside the block; all exits, including the rethrow, release it.
        self.assertNotIn(0xc2, protected)
        self.assertIn(0xb4, protected)
        self.assertIn(0xb6, protected)
        self.assertEqual(protected.count(0xc3), 2)

    @unittest.skipUnless(shutil.which("javac") and shutil.which("java"), "a JDK is required")
    def test_bytecode_matches_original_scalar_branches_and_array_loop(self):
        addresses = (0x1839c8, 0xb8452, 0xd65b2, 0x172864, 0x178a28, 0x161504)
        stack_maps = self.image.class_named("com/jbed/tbcc/Writer$StackMapArray")
        remap = {stack_maps.name: "Recovered"}
        descriptor = lambda value: value.replace("L" + stack_maps.name + ";", "LRecovered;")
        recovered = ClassFileBuilder("Recovered")
        for member in stack_maps.fields:
            recovered.add_field(member.name, descriptor(member.descriptor),
                                (member.flags & ~7) | 1)
        # Test fixture constructor; only the method under test comes from ROM.
        initializer = recovered.pool.method("java/lang/Object", "<init>", "()V")
        recovered.add_method("<init>", "()V", code=Code(
            b"\x2a\xb7" + struct.pack(">H", initializer) + b"\xb1", 1, 1))
        for address in addresses:
            method = self.image.method_at(address)
            result = lift_method(self.image, method, structure=False)
            self.assertFalse(result.failure, f"0x{address:x}: {result.failure}")
            code = emit_method_code(self.image, method, result.cfg, recovered.pool, remap=remap)
            recovered.add_method(method.name, descriptor(method.descriptor),
                                 9 if method.is_static else 1, code=code)
        # A backedge to the first instruction must not reinitialize ABI arguments.
        countdown = bytes.fromhex("0138 fdd1 f746")
        countdown_method = MethodSpec("Recovered", "countdown", "(I)I", 0x1000, 6, True, 9)
        countdown_result = ThumbLifter(bytes(0x1000) + countdown,
            {0x1000: countdown_method}, ()).lift(countdown_method, structure=False)
        self.assertFalse(countdown_result.failure, countdown_result.failure)
        recovered.add_method("countdown", "(I)I", 9, code=emit_method_code(
            self.image, countdown_method, countdown_result.cfg, recovered.pool))
        character_util = self.image.class_named("com/jbed/util/CharacterUtil")
        character_results = {method: lift_method(self.image, method, structure=False).cfg
                             for method in character_util.methods}
        dependency_remap = {character_util.name: "recovered/CharacterUtil",
                            "java/lang/Character": "recovered/Character"}
        utility_class = emit_classfile(self.image, character_util, character_results,
                                      remap=dependency_remap)
        digit = self.image.method_at(0xd65b2)
        dependency_class = emit_classfile(self.image, self.image.class_named(digit.owner),
            {digit: lift_method(self.image, digit, structure=False).cfg}, methods=(digit,),
            remap=dependency_remap)
        driver = DRIVER
        for name in ("callInstrToDest", "min", "isDigit", "countdown", "copy"):
            driver = driver.replace(name + "(", "Recovered." + name + "(")
        source = "public class Driver {\n" + driver + "}\n"

        catch_method = self.image.method_at(0xe1734)
        catch_result = lift_method(self.image, catch_method, structure=False)
        self.assertIsNone(catch_result.failure)
        self.assertIsNotNone(catch_result.cfg)
        catch_class = ClassFileBuilder("RecoveredCatch")
        catch_code = emit_method_code(self.image, catch_method,
            LiftedBody(catch_result.cfg, catch_result.exception_regions, catch_result.handler_locals),
            catch_class.pool, remap={catch_method.owner: "RecoveredCatch"})
        catch_class.add_method(catch_method.name, catch_method.descriptor, 9, code=catch_code)
        # Controlled external-call fixture: a negative length raises OOM;
        # other lengths return "value". The caller and its catch are recovered.
        error_class = catch_class.pool.class_("java/lang/OutOfMemoryError")
        error_constructor = catch_class.pool.method("java/lang/OutOfMemoryError", "<init>", "()V")
        value_constant = catch_class.pool.string("value")
        callee_code = (b"\x1a\x9c\x00\x0b\xbb" + struct.pack(">H", error_class) + b"\x59\xb7"
            + struct.pack(">H", error_constructor) + b"\xbf\x13" + struct.pack(">H", value_constant) + b"\xb0")
        catch_class.add_method("newEmptyStringLenExc", "(I)Ljava/lang/String;", 10,
                               code=Code(callee_code, 2, 1))

        oracle = ThumbOracle(self.image.data)
        oracle.machine.mem_write(0x1000, countdown)
        inputs, expected = [], []
        edges = (0, 1, -1, 0x7ff, 0x800, 0x7fffffff, -0x80000000)
        randomizer = random.Random(0x20110126)
        pairs = list(zip(edges, reversed(edges))) + [
            (signed(randomizer.getrandbits(32)), signed(randomizer.getrandbits(32)))
            for _ in range(48)]
        for operation, address in (("call", 0x1839c8), ("min", 0xb8452)):
            for a, b in pairs:
                inputs.append(f"{operation}|{a}|{b}")
                expected.append(str(oracle.call(address, (a, b))))
        payload = bytes((0xff, 0x81, 0x7f, 0xf3, 0x00, 0xca, 0xab, 0xe3))
        oracle.machine.mem_write(oracle.TARGET, bytes(12) + struct.pack("<I", len(payload)) + payload)
        for offset in range(len(payload) - 3):
            inputs.append(f"packed|{offset}|{base64.b64encode(payload).decode('ascii')}")
            expected.append(str(oracle.call(0x161504, (oracle.SOURCE, oracle.TARGET, offset))))
        # CLDC Character.isDigit is ASCII-only; a host-JDK replacement would fail these.
        for character in (0, 47, 48, 49, 57, 58, 65, 0x660, 0x669, 0xff10, 0xffff):
            inputs.append(f"digit|{character}")
            expected.append(str(oracle.call(0xd65b2, (character,))))
        for operation, address in (("alpha", 0x12fcec), ("alnum", 0x12fd04)):
            for character in (0, 47, 48, 57, 58, 64, 65, 90, 91, 96, 97, 122, 123,
                              0x660, 0x669, 0xff10, 0xffff):
                inputs.append(f"{operation}|{character}")
                expected.append(str(oracle.call(address, (character,))))

        values = (1, -1, -0x80000000, 0x7fffffff, 17)
        zeros = (0,) * 5
        cases = (
            CopyCase(values, zeros, 0, 0, 5), CopyCase(values, zeros, 1, 2, 2),
            CopyCase(values, zeros, 0, 0, 0), CopyCase(None, None, -1, -1, -1),
            CopyCase(values, None, 0, 1, 4, True), CopyCase(values, None, 1, 0, 4, True),
            CopyCase(values, None, 0, 0, 5, True), CopyCase(None, zeros, 0, 0, 1),
            CopyCase(values, None, 0, 0, 1), CopyCase(values, zeros, -1, 0, 1),
            CopyCase(values, zeros, 0, -1, 1), CopyCase(values, zeros, 4, 0, 2),
            CopyCase(values, zeros, 0, 4, 2), CopyCase((), (), 0, 0, 1),
            CopyCase(None, None, 0, 0, 0), CopyCase(values, zeros, 0x7fffffff, 0, 1),
        )
        for case in cases:
            inputs.append(f"copy|{int(case.alias)}|{case.source_index}|{case.target_index}|"
                          f"{case.count}|{array_text(case.source)}|{array_text(case.target)}")
            expected.append(oracle.copy(case))
        inputs.append("recycle")
        expected.append(oracle.recycle())
        for count in (1, 3, 17):
            inputs.append(f"countdown|{count}")
            expected.append(str(oracle.call(0x1000, (count,))))
        # The native oracle uses the same controlled callee outcomes and the
        # original catch-table target; the VM ABI leaves this frame's SP intact.
        table = (catch_method.address + catch_method.size + 3) & ~3
        _, _, handler, catch_descriptor = struct.unpack_from("<4I", self.image.data, table)
        self.assertEqual(self.image.by_descriptor[catch_descriptor].name, "java/lang/OutOfMemoryError")

        def callee_outcome(machine, _address, _size, _data):
            if signed(machine.reg_read(UC_ARM_REG_R0)) < 0:
                machine.reg_write(UC_ARM_REG_R0, oracle.TARGET)
                machine.reg_write(UC_ARM_REG_PC, handler | 1)
            else:
                machine.reg_write(UC_ARM_REG_R0, oracle.SOURCE)
                machine.reg_write(UC_ARM_REG_PC, machine.reg_read(UC_ARM_REG_LR))

        oracle.machine.hook_add(UC_HOOK_CODE, callee_outcome, begin=0xe16c0, end=0xe16c0)
        for count in (0, 1, -1):
            inputs.append(f"catch|{count}")
            expected.append("null" if oracle.call(catch_method.address, (count,)) == 0 else "value")

        with tempfile.TemporaryDirectory(prefix="jbed-bytecode-test-") as temporary:
            directory = Path(temporary)
            path = directory / "Driver.java"
            path.write_text(source)
            (directory / "recovered").mkdir()
            (directory / "Recovered.class").write_bytes(recovered.to_bytes())
            (directory / "recovered/CharacterUtil.class").write_bytes(utility_class)
            (directory / "recovered/Character.class").write_bytes(dependency_class)
            (directory / "RecoveredCatch.class").write_bytes(catch_class.to_bytes())
            compilation = subprocess.run(["javac", "-cp", str(directory), "-d", str(directory), str(path)],
                                         capture_output=True, text=True)
            self.assertEqual(compilation.returncode, 0, compilation.stderr + "\n" + source)
            execution = subprocess.run(["java", "-Xverify:all", "-cp", str(directory), "Driver"],
                input="\n".join(inputs) + "\n", capture_output=True, text=True, timeout=30)
            self.assertEqual(execution.returncode, 0, execution.stderr)
            self.assertEqual(execution.stdout.splitlines(), expected)


    @unittest.skipUnless(shutil.which("javac") and shutil.which("java"), "a JDK is required")
    def test_string_cursor_keeps_thumb_signed_address_order(self):
        oracle = ThumbOracle(self.image.data)
        method = self.image.method_at(0xb6a5e)  # String.hashCode
        result = lift_method(self.image, method)
        self.assertIsNone(result.failure)
        builder = ClassFileBuilder("RomString", "Storage")
        init = builder.pool.method("Storage", "<init>", "()V")
        builder.add_method("<init>", "()V", code=Code(b"\x2a\xb7" + struct.pack(">H", init) + b"\xb1", 1, 1))
        code = emit_method_code(self.image, method, result.cfg, builder.pool,
                                remap={"java/lang/String": "RomString", "com/jbed/runtime/NativeOps": "Data"})
        builder.add_method("hashCode", "()I", code=code)
        literal = 0x1f01f8  # .mp3
        chars = self.image.string_literal(literal)
        literal_data = oracle.call(0x12a164, (literal,))  # NativeOps.getStringData
        expected = [oracle.call(method.address, (literal,))]
        heap_offset = 22  # e.g. substring starting three chars into its array
        heap_data = oracle.TARGET + heap_offset
        boundary = 0x7ffffffc
        oracle.machine.mem_map(0x7ffff000, 0x2000)
        for array, offset in ((oracle.TARGET, heap_offset), (0, boundary)):
            oracle.machine.mem_write(oracle.SOURCE + 12, struct.pack("<3I", array, offset, len(chars)))
            oracle.machine.mem_write(array + offset, chars.encode("utf-16le"))
            expected.append(oracle.call(method.address, (oracle.SOURCE,)))
        self.assertEqual(expected[-1], 0)
        # Host bindings for the two ROM storage primitives used by the recovered loop.
        source = """
class Data { public static int getStringData(RomString s) { return s.base + s.addr; } }
class Storage {
    char[] value;
    int base, addr, count;
    public char charAt(int i) { return value == null ? ".mp3".charAt(i) : value[((addr - 16) >> 1) + i]; }
}
class Driver {
    public static void main(String[] args) {
        for (int i = 0; i < args.length; i++) {
            RomString s = new RomString();
            int address = Integer.parseInt(args[i]);
            if (i == 1) { s.addr = 22; s.base = address - s.addr; s.value = "xxx.mp3".toCharArray(); }
            else { s.addr = address; }
            s.count = 4;
            System.out.println(s.hashCode());
        }
    }
}
"""
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            (directory / "RomString.class").write_bytes(builder.to_bytes())
            (directory / "Driver.java").write_text(source)
            subprocess.run(["javac", "-cp", ".", "Driver.java"], cwd=directory, check=True)
            actual = subprocess.check_output(["java", "-Xverify:all", "-cp", ".", "Driver",
                                              *map(str, (literal_data, heap_data, boundary))], cwd=directory, text=True)
            self.assertEqual(list(map(int, actual.splitlines())), expected)


if __name__ == "__main__":
    unittest.main()
