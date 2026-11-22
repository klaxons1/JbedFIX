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

`JbedService` loads the VM and `libjbedcompat`. Initialization retains a global
reference to the Java engine, and initialization, execution and finalization
belong to the same `JbedThread`.

Jbed's Java threads run on separate heap stacks. ART expects Java upcalls on
the attached Android thread's stack, so invoking JNI directly from a Jbed
stack can produce a false `StackOverflowError`. The VM receives a private JNI
adapter that invokes Android on the native stack parked by Jbed's scheduler.
Android's actual `JNIEnv` and function table stay intact. Graphics operations
use the same boundary for complete Java/Bitmap operations and receive the
real Android environment. Under native-bridge translation, the bridge's own
stack transition is retained.

Media players release Android resources on close. Preparation, completion
and error callbacks run on the VM thread and check the registered player
before touching its native context, discarding callbacks for closed or
replaced players. Addresses with the ARM32 sign bit set remain valid player
identifiers. Asynchronous preparation failure wakes the waiting MIDlet with
a media exception; later playback failures deliver the MMAPI error event.
The [media lifecycle MIDlet](building.md#media-lifecycle-midlet) exercises
these paths.

The compatibility library applies small, byte-checked repairs to this exact
VM image during loading:

| Repair | Behavior |
|---|---|
| File roots | Parses the Java root serialization with unsigned lengths and copies its data into VM-owned allocations, fixing the original release of an interior JNI array pointer |
| Media metadata | Preserves the original JNI byte-array pointer for release on success and allocation failure, and reads the metadata pair count as unsigned |
| Generated-code cache | Redirects `OPL_os_intern_flushCache` to instruction-cache synchronization for the emitted range |
| Heap allocation failure | Changes the `OPL_os_getHeapBlock` check to recognize `MAP_FAILED` |
| Compiled suites | Records static ROM references in relocation chains and rebases them when loading |
| Native dummy stack | Restores its regular stack limit to zero after a reserved GC stack scope, allowing the next native entry to refresh its bounds while retaining stack assertions |
| Scheduler logging | Disables construction of scheduler trace strings during class initialization |

## Installation, graphics and input

Installation follows the original AMS event and native installer pipeline,
including verification, native compilation and suite registration. Content
URIs are copied into app-readable storage before that pipeline starts. The
former Java-only suite-registration fallback has been removed.

`JbedView` obtains a window through `ANativeWindow_fromSurface`. It maps the
VM's shared RGB565 framebuffer and copies rows using the producer and window
strides. Presentation uses `ANativeWindow_unlockAndPost`; view initialization
uses no private Surface or Canvas fields.

The Skia adapter implements the imported font metrics, measurement and text
drawing operations with Android Paint/Canvas. It caches fonts and text masks
and blends text into the native RGB565 target. The PNG adapter preserves the
legacy structure prefix used directly by Jbed, decodes through BitmapFactory,
and supplies straight RGBA8 rows. Bitmap access and decoding stay on the
Android thread stack.

On-screen controls send key-down, repeat and key-up events through the same
path as physical keys. The direction pad, numeric keypad and softkeys support
held keys; controls release keys when hidden or detached. Fixed virtual
resolutions are applied before the MIDlet RUN event, and the game area is
scaled with its aspect ratio preserved. Pointer coordinates follow that
scale. Controls and resolution preferences are saved for subsequent launches.

The toolbar's Menu button and Android Back open the application menu. Back
first dismisses the Android keyboard when it is open. Exit game sends the
native AMS destroy request and returns to the selector after completion;
the UI thread stays responsive while the MIDlet exits.

The former scheduler-quantum experiments, process-wide JNI-table replacement,
signal/crash handlers, Android monitor patches and diagnostic switch files
have been removed. Diagnostics use Android's log buffer; see
[log collection](building.md#device-testing-and-logs).

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
