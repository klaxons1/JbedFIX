"""Recover two Random methods from ROM, recompile for Jbed and compare Thumb execution."""

import argparse
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import zipfile

from unicorn.arm_const import UC_ARM_REG_R1, UC_ARM_REG_R8

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from tools.jbed_java.classfile import ClassFileBuilder, LiftedBody, emit_method_code
from tools.jbed_java.model import RomImage
from tools.jbed_java.thumb import lift_method
from tools.tests.test_jbed_bytecode import ThumbOracle


def recompile(args, rom, method, directory):
    # Inheriting Random preserves the receiver and the virtual call to next(int).
    klass = ClassFileBuilder("Calc", superclass=method.owner)
    lifted = lift_method(rom, method, structure=False)
    assert lifted.cfg is not None, lifted.failure
    body = LiftedBody(lifted.cfg, lifted.exception_regions, lifted.handler_locals or {})
    klass.add_method(method.name, method.descriptor, code=emit_method_code(rom, method, body, klass.pool))
    raw, verified = directory / "recovered.jar", directory / "verified.jar"
    with zipfile.ZipFile(raw, "w") as jar:
        jar.writestr("Calc.class", klass.to_bytes())
    subprocess.run(["java", "-jar", args.proguard, "-injars", raw, "-outjars", verified,
                    "-libraryjars", args.cldc, "-target", "1.2", "-microedition",
                    "-dontoptimize", "-dontobfuscate", "-dontshrink"], check=True)
    with zipfile.ZipFile(verified) as jar:
        path = directory / "Calc.class"
        path.write_bytes(jar.read("Calc.class"))
    output = subprocess.check_output([args.fixture.resolve(), args.image, path])
    address, size, _, rom_base = struct.unpack_from("<4I", output)
    assert len(output) == 16 + size
    return address, output[16:], rom_base


def compare(rom, klass, method, address, code, rom_base):
    oracle = ThumbOracle(rom.data)
    machine = oracle.machine
    for base, data in ((rom_base, rom.data), (address, code)):
        page = base & ~4095
        machine.mem_map(page, (base - page + len(data) + 4095) & ~4095)
        machine.mem_write(base, data)
    machine.reg_write(UC_ARM_REG_R8, 1024)
    machine.mem_write(oracle.SOURCE, struct.pack("<I", klass.tag_address))
    seed_address = oracle.SOURCE + next(field.offset for field in klass.fields if field.name == "seed")

    def call(entry, state):
        machine.mem_write(seed_address, struct.pack("<Q", state))
        result = oracle.call(entry, (oracle.SOURCE,)) & 0xffffffff
        assert oracle.exception is None, (method.name, hex(entry), oracle.exception)
        if method.return_type == "D":
            result |= machine.reg_read(UC_ARM_REG_R1) << 32
        return result, bytes(machine.mem_read(seed_address, 8))

    for state in (0, 1, 42, 123 ^ 25214903917, 1 << 47, (1 << 48) - 1):
        assert call(address, state) == call(method.address, state), (method.name, state)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixture", type=Path, help="jbedcompiler_thumb_smoke executable")
    parser.add_argument("proguard", type=Path, help="ProGuard executable JAR with -microedition support")
    parser.add_argument("cldc", type=Path, help="CLDC 1.1 API JAR")
    parser.add_argument("--image", type=Path, default=ROOT / "app/src/main/jniLibs/armeabi/libjbedvm.so")
    args = parser.parse_args()
    rom = RomImage(args.image)
    klass = rom.class_named("java/util/Random")
    for name in ("nextFloat", "nextDouble"):
        method = next(method for method in klass.methods if method.name == name)
        with tempfile.TemporaryDirectory() as directory:
            image = recompile(args, rom, method, Path(directory))
            compare(rom, klass, method, *image)
    print("Random.nextFloat/nextDouble match the original Thumb result bits and seed updates")


if __name__ == "__main__":
    main()
