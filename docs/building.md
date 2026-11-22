# Building and development

## Toolchain

| Component | Version |
|---|---|
| JDK | 17 |
| Gradle wrapper | 8.9 |
| Android Gradle Plugin | 8.5.2 |
| Android SDK platform / Build Tools | 34 / 34.0.0 |
| Android NDK | 25.2.9519653 |

Keep the Android SDK and NDK in the normal SDK installation outside the
checkout. Set `JAVA_HOME` to JDK 17 and `ANDROID_HOME` to that SDK, or set
`sdk.dir` in the ignored root `local.properties`. Install the pinned packages
if they are missing:

```sh
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --install "platforms;android-34" "build-tools;34.0.0" "ndk;25.2.9519653"
```

The native build supports Linux x86_64 and macOS. On Apple Silicon it also
recognizes the NDK's `darwin-x86_64` toolchain directory.

## APK and native libraries

```sh
./gradlew :app:assembleDebug
```

The APK is `app/build/outputs/apk/debug/app-debug.apk`.
`:app:buildNativeCompatibility` builds eight adapter libraries into
`app/build/generated/jniLibs/armeabi/` before native packaging. The original
VM remains in `app/src/main/jniLibs/armeabi/libjbedvm.so`; compatibility changes
are applied in memory when it loads.

To build only the adapters:

```sh
./gradlew :app:buildNativeCompatibility
```

For a standalone native build, set `ANDROID_NDK_HOME` to the installed NDK:

```sh
bash native/compat/build.sh
```

The default output is `build/native-compat/armeabi/`. An optional first
argument selects another output directory. Sources are resolved relative to
the script, so it can run from another working directory.

The adapters target ARMv7/API 19 and are packaged with the original VM in the
legacy `armeabi` directory. The APK retains `minSdk 19` and `targetSdk 22`.
See [compatibility](compatibility.md) for ARM32 execution and installation
requirements.

## Host tests

The PNG contract test checks the legacy structure offsets, bounded chunk
reading, malformed-input handling and output rows with a stub decoder. It
runs on the development host:

```sh
mkdir -p build/native-tests
cc -std=c11 -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer native/compat/tests/png_compat_test.c -o build/native-tests/png_compat_test
build/native-tests/png_compat_test
```

Use Android application tests for Java/Bitmap decoding, presentation and VM
execution. The [compatibility table](compatibility.md#verified-execution)
records the configurations and games already exercised.

## Media lifecycle MIDlet

`tests/midlets/media-lifecycle/MediaLifecycle.java` covers WAV completion,
repeated close and optional HTTP MP3 preparation success/failure. Its build
helper accepts external ECJ 3.12.3, ProGuard 6.2.2 and CLDC 1.1/MIDP 2.0 API
JARs through `--ecj`, `--proguard`, `--cldc` and `--midp`:

```sh
python3 tests/midlets/media-lifecycle/build.py --help
```

The generated JAR defaults to the ignored `research/test-apps/media-lifecycle/`
directory; install it through JbedFIX. Optional `--good-url` and `--bad-url`
values must end in `.mp3` and return HTTP 200 with content type `audio/mpeg`.
Use a valid MP3 for success and the generated `media-invalid.mp3` for failure.

## Device testing and logs

Install the debug APK on a device with ARM32 app support:

```sh
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

Open a MIDlet JAR with the application and let its native installer finish.
For a game test, exercise controls and observe animation as well as the first
frame. Keep the original JAR available for investigating compiled-suite
loading. Newer Android installation restrictions are described in
[compatibility](compatibility.md#remaining-constraints).

For full-system ARM emulation, QEMU 11.1.1 TCG has an AArch64 condition-flag
error that crashes Android's Ogg extractor. QEMU 10.2.2 passes the stock Ogg
decoding check.

Diagnostics go to logcat. To save all buffers without changing device state:

```sh
mkdir -p logs
adb logcat -b all -v threadtime > logs/jbed-logcat.txt
```

Stop capture with Ctrl+C. Preserve the full output when investigating JNI
aborts or native crashes, which can appear in different buffers.

The Windows helper actively clears logcat, force-stops and launches the
installed application, then captures full and filtered logs under `logs/`:

```powershell
.\tools\collect-jbed-log.ps1 -Seconds 15
```

It accepts `-Adb` to select an adb executable and `-PackageName` to select the
application package.

## Static inspection

`extract_jbed_aot.py` requires Python 3.10+ and the standard library. It reads
ROM metadata without executing the VM:

```sh
python3 tools/extract_jbed_aot.py app/src/main/jniLibs/armeabi/libjbedvm.so
```

Package totals use recorded method spans, including inline data:

```sh
python3 tools/extract_jbed_aot.py app/src/main/jniLibs/armeabi/libjbedvm.so --components
```

`--json` provides output for programmatic consumers.
`extract_m3g_symbols.py` invokes an ELF-capable `nm` and emits CSV to stdout:

```sh
python3 tools/extract_m3g_symbols.py app/src/main/jniLibs/armeabi/libjbedvm.so
```

Its optional `--csv PATH` saves the inventory. Exported symbol sizes include
inline data and differ from instruction-byte measurements.

`measure_jbed_code.py` runs inside IDA through `idagent`. Read `idagent --help`
and its linked guide first. The analyzed database is local and ignored by
Git, so a fresh clone needs that database separately:

```sh
idagent --db research/jbed/libjbedvm.so.i64 --direct -f tools/measure_jbed_code.py
```

Close it after inspection:

```sh
idagent stop --db research/jbed/libjbedvm.so.i64
```

See [native analysis](native-analysis.md) for the measurement method. Keep
lasting analysis in `research/`; build directories are disposable.

## Continuous integration

`.github/workflows/android.yml` builds on pushes, pull requests to `main` and
manual dispatch. It installs the pinned SDK packages, assembles the release
APK, signs it with the cached development keystore, verifies the signature
and uploads `app-release.apk`. Signing and upload are restricted to that app
output.
