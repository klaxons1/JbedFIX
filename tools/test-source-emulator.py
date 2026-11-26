#!/usr/bin/env python3
"""Boot an ARM-translation-capable Android AVD and test the source APK.

Requires an Android SDK with cmdline-tools, Linux, and preferably /dev/kvm.
The guest ABI list is checked: an x86-only boot is NOT an ARM32 runtime test.
All emulator output, logcat, checkpoints and crash buffers stay in --output.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import subprocess
import sys
import time

IMAGE = "system-images;android-30;google_apis;x86_64"
PACKAGE = "org.jbed.source"
ACTIVITY = PACKAGE + "/.MainActivity"
AVD = "jbed-source-smoke"


def annotation(message: str) -> None:
    if os.environ.get("GITHUB_ACTIONS") != "true":
        return
    for start in range(0, min(len(message), 18000), 3000):
        chunk = message[start:start + 3000].replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
        print(f"::error title=Android emulator smoke test::{chunk}", flush=True)


def run(command, *, timeout=120, check=True, input=None, env=None):
    result = subprocess.run([str(x) for x in command], input=input, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=timeout, env=env)
    if check and result.returncode:
        raise RuntimeError(f"Command failed ({result.returncode}): {' '.join(map(str, command))}\n{result.stdout[-12000:]}")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk", type=Path, default=os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT"))
    parser.add_argument("--apk", type=Path, default=Path("native/android/app/build/outputs/apk/debug/app-debug.apk"))
    parser.add_argument("--output", type=Path, default=Path("build/emulator-smoke"))
    parser.add_argument("--boot-timeout", type=int, default=480)
    parser.add_argument("--test-timeout", type=int, default=120)
    args = parser.parse_args()
    if args.sdk is None or not args.apk.is_file():
        parser.error("An Android SDK and an existing source APK are required")
    args.output.mkdir(parents=True, exist_ok=True)
    sdk = args.sdk.resolve()
    sdkmanager = sdk / "cmdline-tools/latest/bin/sdkmanager"
    avdmanager = sdk / "cmdline-tools/latest/bin/avdmanager"
    adb = sdk / "platform-tools/adb"
    emulator = sdk / "emulator/emulator"
    env = dict(os.environ, ANDROID_HOME=str(sdk), ANDROID_SDK_ROOT=str(sdk), ANDROID_SERIAL="emulator-5554")
    emulator_process = logcat = None
    handles = []
    adb_ready = False

    def command(*words, **kwargs):
        return run([adb, *words], env=env, **kwargs)

    def collect():
        for name, words in {
            "checkpoints.txt": ["shell", "run-as", PACKAGE, "cat", "files/source-runtime.log"],
            "crash-buffer.txt": ["logcat", "-b", "crash", "-d", "-v", "threadtime"],
            "all-logcat.txt": ["logcat", "-b", "all", "-d", "-v", "threadtime"],
            "exit-info.txt": ["shell", "dumpsys", "activity", "exit-info", PACKAGE],
            "guest-properties.txt": ["shell", "getprop"],
        }.items():
            try:
                result = command(*words, timeout=30, check=False)
                (args.output / name).write_text(result.stdout)
            except (OSError, subprocess.TimeoutExpired) as error:
                (args.output / name).write_text(str(error))

    def launch(method: str):
        # A single shell argument keeps the JVM descriptor quoted remotely.
        command("shell", f"am start -W -f 0x20000000 -n {ACTIVITY} --es method '{method}' --ez run true")

    log_path = args.output / "live-logcat.txt"

    def wait_for(expected: str, offset: int):
        deadline = time.monotonic() + args.test_timeout
        seen_alive = False
        while time.monotonic() < deadline:
            text = log_path.read_text(errors="replace")[offset:]
            if expected in text:
                return text
            if re.search(r"Fatal signal|FATAL EXCEPTION|Jbed fatal error", text):
                raise RuntimeError("Android reported a process crash\n" + text[-14000:])
            pid = command("shell", "pidof", PACKAGE, check=False, timeout=15).stdout.strip()
            if pid:
                seen_alive = True
            elif seen_alive:
                raise RuntimeError("The source app process exited before the expected result\n" + text[-14000:])
            time.sleep(1)
        raise RuntimeError(f"Timed out waiting for {expected!r}\n" + log_path.read_text(errors="replace")[offset:][-14000:])

    try:
        print("Installing emulator and ARM-translation-capable system image", flush=True)
        installed = run([sdkmanager, "--install", "emulator", "platform-tools", IMAGE], timeout=600, env=env)
        (args.output / "sdk-install.txt").write_text(installed.stdout)
        created = run([avdmanager, "create", "avd", "--force", "--name", AVD,
                       "--package", IMAGE, "--device", "pixel_2"], input="no\n", env=env)
        (args.output / "avd-create.txt").write_text(created.stdout)
        kvm = Path("/dev/kvm")
        if kvm.exists() and not os.access(kvm, os.R_OK | os.W_OK) and os.environ.get("GITHUB_ACTIONS") == "true":
            run(["sudo", "chmod", "666", str(kvm)], timeout=30)
        handle = (args.output / "emulator.txt").open("w")
        handles.append(handle)
        emulator_process = subprocess.Popen([str(emulator), "-avd", AVD, "-port", "5554",
            "-no-window", "-no-audio", "-no-boot-anim", "-no-snapshot", "-gpu", "swiftshader_indirect",
            "-cores", "2", "-memory", "2048"], stdout=handle, stderr=subprocess.STDOUT, env=env)
        command("wait-for-device", timeout=args.boot_timeout)
        adb_ready = True
        deadline = time.monotonic() + args.boot_timeout
        while command("shell", "getprop", "sys.boot_completed", check=False).stdout.strip() != "1":
            if emulator_process.poll() is not None:
                raise RuntimeError("Emulator exited during boot")
            if time.monotonic() > deadline:
                raise RuntimeError("Android did not finish booting")
            time.sleep(3)
        abis = command("shell", "getprop", "ro.product.cpu.abilist").stdout.strip()
        print("Booted Android guest ABIs: " + abis, flush=True)
        if "armeabi-v7a" not in abis.split(","):
            raise RuntimeError("Guest does not advertise ARM32 translation; refusing to count an x86-only boot as a test: " + abis)
        command("shell", "input", "keyevent", "82")
        command("install", "-r", str(args.apk.resolve()), timeout=180)
        command("logcat", "-c")
        handle = log_path.open("w")
        handles.append(handle)
        logcat = subprocess.Popen([str(adb), "logcat", "-b", "all", "-v", "threadtime"],
                                  stdout=handle, stderr=subprocess.STDOUT, env=env)
        tests = [
            ("direct managed call", "TransformProbe.run()I", "Result: 42", False),
            ("main after direct call (same process)", "TransformProbe.main([Ljava/lang/String;)V", "Exited with status 0", False),
            ("main from a fresh process", "TransformProbe.main([Ljava/lang/String;)V", "Exited with status 0", True),
        ]
        results = []
        for name, method, expected, fresh in tests:
            if fresh:
                command("shell", "am", "force-stop", PACKAGE)
            offset = len(log_path.read_text(errors="replace"))
            print("TEST: " + name, flush=True)
            launch(method)
            wait_for(expected, offset)
            results.append(name + ": PASS")
            (args.output / "results.txt").write_text("\n".join(results) + "\n")
            print(results[-1], flush=True)
        collect()
        print("ARM32 emulator smoke tests passed", flush=True)
        if os.environ.get("GITHUB_ACTIONS") == "true":
            print("::notice title=ARM32 emulator runtime validation::Direct call returned 42; same-process and fresh-process main both exited with status 0", flush=True)
        return 0
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        if adb_ready:
            collect()
        detail = str(error)
        emulator_log = args.output / "emulator.txt"
        if not adb_ready and emulator_log.exists():
            detail += "\n" + emulator_log.read_text(errors="replace")[-8000:]
        checkpoints = args.output / "checkpoints.txt"
        if checkpoints.exists():
            detail += "\nNative checkpoints:\n" + checkpoints.read_text(errors="replace")[-4000:]
        (args.output / "failure.txt").write_text(detail)
        print(detail, file=sys.stderr, flush=True)
        annotation(detail[-18000:])
        return 1
    finally:
        if logcat is not None:
            logcat.terminate()
            try: logcat.wait(timeout=10)
            except subprocess.TimeoutExpired: logcat.kill()
        if emulator_process is not None:
            try: command("emu", "kill", timeout=15, check=False)
            except (OSError, subprocess.TimeoutExpired): pass
            try: emulator_process.wait(timeout=30)
            except subprocess.TimeoutExpired:
                emulator_process.kill()
                emulator_process.wait()
        for handle in handles:
            handle.close()


if __name__ == "__main__":
    sys.exit(main())
