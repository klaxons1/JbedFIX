#!/usr/bin/env python3
"""Recompile Gravity Defied 1.0 and compare with its original Android Jbed suite."""

import argparse
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jbedc", type=Path)
    parser.add_argument("rom", type=Path)
    parser.add_argument("jar", type=Path)
    parser.add_argument("reference", type=Path)
    args = parser.parse_args()
    expected = args.reference.read_bytes()
    with TemporaryDirectory() as directory:
        output = Path(directory) / "gravity.obj"
        # The recorded install used a 3156-byte code prefix and had already
        # assigned 33 identity hashes since Base.initBase seeded the generator.
        subprocess.run([args.jbedc.resolve(), "--rom-base", "0xc43ce000", "--prefix", "3156",
                        "--hash-state", "0xea66f24f", args.rom, args.jar, output], check=True)
        actual = output.read_bytes()
    if actual != expected:
        for i, (a, b) in enumerate(zip(actual, expected)):
            if a != b:
                raise SystemExit(f"Difference at 0x{i:x}, generated 0x{a:02x}, expected 0x{b:02x}")
        raise SystemExit(f"Difference at 0x{min(len(actual), len(expected)):x}, "
                         f"generated {len(actual)} bytes, expected {len(expected)}")
    print(f"Gravity Defied suite matches all {len(actual):,} bytes")


if __name__ == "__main__":
    main()
