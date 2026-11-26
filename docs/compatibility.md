# Android compatibility

JbedFIX retains the bundled ARM32 VM and adapts its Android boundary. The APK
uses `minSdk 19` and `targetSdk 22`; the minimum SDK is an installation setting,
while the configurations below record observed execution.

## Verified execution

| Android configuration | Application | Observed behavior |
|---|---|---|
| Android 11 / API 30, x86 with ARM native-bridge translation | Arkanoid 1.0 | Native installation, compilation and game animation |
| Android 11 / API 30, x86 with ARM native-bridge translation | Gravity Defied 1.0 | Intro gameplay with PNG sprites and held-Up acceleration; the same compiled suite reloads after a process restart changes the VM load address |
| Android 11 / API 30, x86 with ARM native-bridge translation | Diamond Rush 1.0.1 | Angkor Wat gameplay with sound enabled; holding numeric 6 moves the character; the installed suite survives an APK update |
| Android 11 / API 30, x86 with ARM native-bridge translation | Opera Mini 4.4.28684 | Fetches Example Domain through `SocketConnection` on TCP port 1080 and `info.cern.ch` through J2ME HTTP connections to Opera's proxy on port 80 |
| Android 11 / API 30, x86 with ARM native-bridge translation | Stalker Mobile 1.1.0 | Standard M3G renders a textured first-person forest; aiming changes the view and Fire consumes ammunition |
| Android 11 / API 30, x86 with ARM native-bridge translation | JBenchmark2 2.1.1 | Completes all five tests at a virtual resolution of 240 × 320 |
| Android 11 / API 30, x86 with ARM native-bridge translation | Media Lifecycle 1.0.2 | WAV completion and repeated close, successful HTTP MP3 playback, and asynchronous preparation failure without hanging |
| Android 11 / API 30, ARM64 kernel with native ARM32 userspace | Gravity Defied 1.0 | Completes Easy / Intro with the 100cc bike in first place using held on-screen Up |
| Android 11 / API 30, ARM64 kernel with native ARM32 userspace | Stalker Mobile 1.1.0 | Standard M3G renders a textured forest with camera aiming and movement; the compiled suite reloads after a process restart |
| Android 11 / API 30, ARM64 kernel with native ARM32 userspace | JBenchmark2 2.1.1 | Completes all five tests at a virtual resolution of 240 × 320 |
| Android 7.0 / API 24, native ARM32 | Gravity Defied 1.0 | Native compilation and Easy / Intro gameplay with the 100cc bike; holding on-screen Up accelerates and advances the camera and track |
| Android 14 / API 34, ARM64 kernel with native ARM32 userspace | Gravity Defied 1.0 | Native installation and compilation, Easy / Intro course completion, and Menu / Exit game returning to the app list; installed with the low-target SDK bypass described below |

Diamond Rush exercises Android MediaPlayer/AudioTrack WAV and MIDI paths.
Audible output has not been checked.

At 240 × 320, JBenchmark2 scored 10224 with ARM native-bridge translation and
1013 under full-system TCG emulation. These scores describe the emulated
configurations, not physical-phone performance. Its software 3D test does
not use M3G, and the suite requests garbage collection between tests. The
native ARM32 rows use no Android native bridge.

## Runtime boundary

Jbed's Java threads run on separate heap stacks. ART expects Java upcalls on
the attached Android thread's stack, so invoking JNI directly from a Jbed
stack can produce a false `StackOverflowError`. The VM receives a private JNI
adapter that invokes Android on the native stack parked by Jbed's scheduler.
Android's actual `JNIEnv` and function table stay intact. Graphics operations
use the same boundary for complete Java/Bitmap operations and receive the
real Android environment. Under native-bridge translation, the bridge's own
stack transition is retained.

## Remaining constraints

New compiled `.obj` suites use a ROM-relative format that survives changes to
the VM's load address. Suites compiled before this repair contain absolute
ROM references without the required relocation records and are rejected by
the new loader. Reinstall those suites once from their original JARs. The
[format repair](compiler.md#compiled-suite-format) preserves the VM fingerprint
and version checks.

DRM-protected suites are unsupported. Direct J2ME HTTPS connections have not
received end-to-end validation.

Vendor-specific APIs can prevent a game from starting. The Nokia Tower Bloxx
1.2.4 build requires the absent `com.nokia.mid.ui.FullCanvas`, `DirectGraphics`
and `DirectUtils` classes. The Sony Ericsson 1.1.5 build requires MascotCapsule,
which this runtime does not provide. Standard M3G support does not supply
those vendor APIs.

An ARM64 CPU alone is insufficient: the Android system must support a 32-bit
app process or provide ARM32 translation. Check
[`Build.SUPPORTED_32_BIT_ABIS`](https://developer.android.com/reference/android/os/Build#SUPPORTED_32_BIT_ABIS).
There is no ARM64 VM build. Both the bundled ROM and newly generated Thumb
code require an ARM32 execution environment; see the [compiler architecture](compiler.md).

The original ELF contains text relocations. Android's linker rejects them
for applications targeting API 23 or later, which is why this package retains
API 22. A normal installation on newer Android releases also faces their
minimum target requirement: Android 14 requires at least 23, and Android 15
requires at least 24. Raising `targetSdk` requires fixing the native loading
constraint first. [AOSP linker rules](https://android.googlesource.com/platform/bionic/+/HEAD/android-changes-for-ndk-developers.md#text-relocations-enforced-for-api-level-23),
[Android 14](https://developer.android.com/about/versions/14/behavior-changes-all#minimum-target-api-level),
[Android 15](https://developer.android.com/about/versions/15/behavior-changes-all#minimum-target-api-level).

For development on a system that supports ARM32 execution, Android documents
`adb install --bypass-low-target-sdk-block` for testing low-target APKs. This
only bypasses the installation restriction; it does not add ARM32 support or
change native loading behavior.
