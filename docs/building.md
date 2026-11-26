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
CMake, libzip and zlib development files, plus these SDK packages:

```sh
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "platforms;android-35" "ndk;28.2.13676358" "cmake;3.22.1"
./gradlew -p native/android :app:assembleDebug
```

Output: `native/android/app/build/outputs/apk/debug/app-debug.apk`. Run
`TransformProbe.run()I` to exercise the recovered M3G Java wrappers and native
matrix/vertex-array operations; success returns 42. This is a ROM method runner.
An alternate generated image can be selected with `-PjbedBootImage=PATH`.

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
