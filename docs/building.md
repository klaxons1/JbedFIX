# Building

Use JDK 17 and an Android SDK outside the checkout. Set `JAVA_HOME` and
`ANDROID_HOME`, or put `sdk.dir` in the ignored `local.properties`.
Install the SDK packages pinned by the build:

```sh
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"
./gradlew :app:assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`. Native adapters build on
Linux x86_64 and macOS; the original VM stays in `jniLibs/armeabi/` and is
patched in memory. See [device constraints](compatibility.md) before installing.

## Source runtime runner

The separate `org.jbed.source` APK builds the reconstructed library and compiles
its diagnostic ROM from `native/rom/runtime.jar`. It requires a host C compiler,
CMake, pkg-config, libzip and zlib development files, plus these SDK packages:

```sh
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "platforms;android-35" "ndk;28.2.13676358" "cmake;3.22.1"
./gradlew -p native/android :app:assembleDebug
```

Output: `native/android/app/build/outputs/apk/debug/app-debug.apk`. Run
`TransformProbe.run()I` to exercise the recovered M3G Java wrappers and native
matrix/vertex-array operations; success returns 42. This is a ROM method runner.
An alternate generated image can be selected with `-PjbedBootImage=PATH`.

ROM preverification uses a temporary access facade because the original Jbed
compiler permits privileged cross-package access inside its ROM. The adapter
exposes members only to ProGuard, then restores every declaration's original
access flags and removes metadata-only constructor facades before `jbedrom`.
`testRomPreverify` and `verifyRomRoundtrip` check this; warnings are not disabled.
`checkRomBindings` reports all missing implementations before image generation.
The startup subset currently needs 33 additional source bindings, so the
source APK pipeline is not yet green even though preverification succeeds.

## GitHub Actions

The **Build source APK** workflow runs on pushes, pull requests and manual
dispatches. It builds the source runtime runner, not the legacy wrapper above;
no original `libjbedvm.so` or private analysis files are needed. Download
`jbed-source-debug-arm32` from the run's artifacts for the debug-signed APK.
It requires Android ARM32 userspace and remains a diagnostic ROM runner, not
a complete replacement MIDlet launcher. CI verifies compilation, linking,
APK signature and native library packaging; it does not execute the APK.

A separate host job builds the source libraries and `jbedc`/`jbedrom`, then
runs eleven self-contained CTest checks. Tests requiring the original binary
are not included in this job. To reproduce it on Ubuntu:

```sh
sudo apt-get install cmake ninja-build pkg-config zlib1g-dev libzip-dev libpng-dev
cmake -S native -B build/host -G Ninja -DCMAKE_BUILD_TYPE=Debug \
  -DJBED_BUILD_HOST_COMPILER=ON -DJBED_BUILD_HOST_TESTS=ON
cmake --build build/host --parallel 2
ctest --test-dir build/host --output-on-failure --no-tests=error
```

## Focused checks

The host PNG contract check uses a stub decoder:

```sh
mkdir -p build/native-tests
cc -std=c11 -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer native/compat/tests/png_compat_test.c -o build/native-tests/png_compat_test
build/native-tests/png_compat_test
```

Compiler checks are in [compiler.md](compiler.md). Bytecode recovery checks
require a JDK, Capstone and Unicorn:

```sh
python3 -m unittest discover -s tools/tests
```

The media lifecycle MIDlet's build helper accepts external ECJ, ProGuard and
CLDC/MIDP API JARs; see `tests/midlets/media-lifecycle/build.py --help`.

## Device testing and logs

```sh
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb logcat -b all -v threadtime
```

Keep all log buffers when investigating JNI aborts or native crashes.
`tools/collect-jbed-log.ps1` can clear logs, restart the app and save a capture.

For full-system ARM emulation, QEMU 11.1.1 TCG has an AArch64 condition-flag
error that crashes Android's Ogg extractor. QEMU 10.2.2 passes that stock
Android check.
