#!/usr/bin/env python3
"""Build the MIDlet with ECJ 3.12.3, ProGuard 6.2.2 and CLDC 1.1/MIDP 2.0 API jars.

Supply the four tool/API jars explicitly; no SDK installation or download is needed.
MediaTest-BadURL must end in .mp3 and return media-invalid.mp3 with HTTP 200/audio/mpeg.
MediaTest-GoodURL optionally tests successful HTTP MP3 preparation and playback.
"""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile
import zipfile


def manifest(properties):
    lines = []
    for name, value in properties.items():
        line = (name + ": " + str(value)).encode("utf-8")
        while len(line) > 70:
            lines.append(line[:70])
            line = b" " + line[70:]
        lines.append(line)
    return b"\r\n".join(lines) + b"\r\n\r\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("ecj", "proguard", "cldc", "midp"):
        parser.add_argument("--" + name, required=True, type=Path, metavar="JAR")
    parser.add_argument("--java", default="java", help="Java executable (default: java)")
    parser.add_argument("--output-dir", type=Path,
                        default=Path(__file__).resolve().parents[3] / "research/test-apps/media-lifecycle")
    parser.add_argument("--bad-url", default="", help="HTTP URL of the generated invalid MP3 (must end in .mp3)")
    parser.add_argument("--good-url", default="", help="HTTP URL of a valid MP3 (must end in .mp3)")
    parser.add_argument("--cycles", type=int, default=24, help="Create/start/close repetitions")
    parser.add_argument("--timeout-ms", type=int, default=10000, help="Watchdog limit per media operation")
    args = parser.parse_args()
    if not 1 <= args.cycles <= 1000 or not 2000 <= args.timeout_ms <= 60000:
        parser.error("cycles must be 1..1000; timeout-ms must be 2000..60000")
    jars = {}
    for name in ("ecj", "proguard", "cldc", "midp"):
        jars[name] = getattr(args, name).resolve(strict=True)
    destination = args.output_dir.resolve()
    destination.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).with_name("MediaLifecycle.java").resolve()
    api = os.pathsep.join(str(jars[name]) for name in ("cldc", "midp"))
    jar_path = destination / "media-lifecycle.jar"
    properties = {
        "Manifest-Version": "1.0",
        "MIDlet-Name": "Media Lifecycle",
        "MIDlet-Vendor": "Jbed",
        "MIDlet-Version": "1.0.2",
        "MIDlet-1": "Media Lifecycle,,MediaLifecycle",
        "MicroEdition-Configuration": "CLDC-1.1",
        "MicroEdition-Profile": "MIDP-2.0",
        "MIDlet-Permissions-Opt": "javax.microedition.io.Connector.http",
        "MediaTest-Cycles": args.cycles,
        "MediaTest-TimeoutMs": args.timeout_ms,
    }
    if args.bad_url:
        properties["MediaTest-BadURL"] = args.bad_url
    if args.good_url:
        properties["MediaTest-GoodURL"] = args.good_url
    with tempfile.TemporaryDirectory(prefix="build-", dir=destination) as work:
        temporary = Path(work)
        classes = temporary / "classes"
        classes.mkdir()
        subprocess.run([args.java, "-jar", str(jars["ecj"]), "-source", "1.3", "-target", "1.1",
                        "-bootclasspath", api, "-d", str(classes), str(source)], check=True)
        raw_jar = temporary / "unverified.jar"
        with zipfile.ZipFile(raw_jar, "w", zipfile.ZIP_DEFLATED) as archive:
            for path in sorted(classes.rglob("*.class")):
                archive.write(path, path.relative_to(classes).as_posix())
        verified_jar = temporary / "verified.jar"
        subprocess.run([args.java, "-jar", str(jars["proguard"]),
                        "-injars", str(raw_jar), "-outjars", str(verified_jar),
                        "-libraryjars", api, "-microedition", "-dontshrink", "-dontoptimize",
                        "-dontobfuscate", "-keep", "public class MediaLifecycle { *; }"], check=True)
        with zipfile.ZipFile(verified_jar) as verified, \
                zipfile.ZipFile(jar_path, "w", zipfile.ZIP_DEFLATED) as archive:
            archive.writestr("META-INF/MANIFEST.MF", manifest(properties))
            for name in verified.namelist():
                archive.writestr(name, verified.read(name))
    jad = dict(properties)
    del jad["Manifest-Version"]
    jad["MIDlet-Jar-URL"] = jar_path.name
    jad["MIDlet-Jar-Size"] = jar_path.stat().st_size
    jar_path.with_suffix(".jad").write_bytes(
        ("\r\n".join(name + ": " + str(value) for name, value in jad.items()) + "\r\n").encode("utf-8"))
    (destination / "media-invalid.mp3").write_bytes(b"Intentionally invalid MP3 for MMAPI asynchronous prepare failure.\n")
    print(jar_path)
    print("Serve media-invalid.mp3 as HTTP 200/audio/mpeg; set MediaTest-BadURL in the JAD or MIDlet URL field.")


if __name__ == "__main__":
    main()
