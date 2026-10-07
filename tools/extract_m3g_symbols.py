#!/usr/bin/env python3
"""Inventory the exported JSR-184/Swerve symbols in libjbedvm.so.

The M3G implementation has unusually useful symbol names even though the
binary is stripped of normal source names: JNI adapters are named
Java_javax_microedition_m3g_*, while the native Swerve core exports names such
as graphics3d_renderWorld, transform_transform and swvLoaderLoadBuffer.
"""
from __future__ import annotations

import argparse
import csv
import re
import subprocess
from pathlib import Path

JNI = re.compile(r"^Java_javax_microedition_m3g_")
SWV = re.compile(r"^(?:SWV_|swv)")
CORE = re.compile(
    r"^(?:animation|appearance|background|camera|compositingmode|fog|"
    r"graphics3d|group|indexbuffer|keyframesequence|light|loader|material|"
    r"mesh|morphingmesh|object3d|polygonmode|rayintersection|skinnedmesh|"
    r"sprite3d|texture2d|transform|transformable|triangle|vertexarray|"
    r"vertexbuffer|world)_"
)


def layer(name: str) -> str:
    if JNI.match(name):
        return "jni-adapter"
    if SWV.match(name):
        return "vm-glue"
    if CORE.match(name):
        return "swerve-core"
    return "other"


def symbols(image: Path) -> list[dict[str, str]]:
    cmd = ["nm", "-D", "--defined-only", "--format=posix", str(image)]
    result = subprocess.run(cmd, check=True, text=True, capture_output=True)
    rows = []
    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) < 3:
            continue
        name, kind, address = fields[:3]
        if layer(name) == "other":
            continue
        size = fields[3] if len(fields) > 3 else ""
        rows.append({
            "layer": layer(name),
            "name": name,
            "address": "0x" + address,
            "size": "0x" + size if size else "",
        })
    rows.sort(key=lambda row: (int(row["address"], 16), row["name"]))
    return rows


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("image", type=Path)
    parser.add_argument("--csv", type=Path)
    args = parser.parse_args()
    rows = symbols(args.image)
    if args.csv:
        args.csv.parent.mkdir(parents=True, exist_ok=True)
        with args.csv.open("w", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=["layer", "name", "address", "size"])
            writer.writeheader()
            writer.writerows(rows)
    else:
        writer = csv.DictWriter(__import__("sys").stdout, fieldnames=["layer", "name", "address", "size"])
        writer.writeheader()
        writer.writerows(rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
