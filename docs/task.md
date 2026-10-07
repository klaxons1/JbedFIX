# JbedFIX Android 11 compatibility work — handoff

## Objective

Make the recovered `com.esmertec.android.jbed` / Jbed Java ME emulator build and, if technically possible, start on an Android 11 ARM device.

The repository is a reconstruction of an old Jbed APK, not original source code:

- Java sources in `java/` were decompiled with JADX and contain reconstructed code.
- `docs/smali_original/` contains the original Dalvik smali and is the reference for repairing broken Java decompilation.
- `lib/armeabi/libjbedvm.so` is the original proprietary ARM32 native VM.
- `docs/libjbedvm.so.c` is Hex-Rays output for that VM, **not original C source**.

The current target device is Android 11 with a 32-bit ARM compatibility runtime. The app package is:

```text
com.esmertec.android.jbed
```

## Origin of this build

This is almost certainly an HTC Android 2.3-era customer build, not a generic modern Android app. Evidence:

```properties
# assets/config.properties
CUSTOMER.NAME=HTC
USER.AGENT=Mozilla/5.0 (Linux; U; Android 2.3; en-us) Profile/MIDP-2.0 Configuration/CLDC-1.1
```

Other identifying values:

```text
Jbed build date: 2011-07-13
Jbed P4 build: 195487
```

The old VM expects Android 2.x private framework libraries and ABIs.

## Branch and pull request

All work in this session is on:

```text
arena/019fde7b-jbedfix
```

PR:

```text
https://github.com/klaxons1/JbedFIX/pull/4
```

Do not switch to or push another branch when working through Arena Agent Mode.

## Build status

GitHub Actions builds currently pass and upload an APK artifact. The workflow still runs:

```bash
./gradlew assembleRelease --no-daemon --parallel
```

`build.gradle` now invokes `buildDrmCompatibilityShim` before `mergeReleaseNativeLibs` so generated ARM32 libraries are packaged before the APK is assembled.

The app now keeps `minSdk 19` so the APK can be installed on Android 4.4.2/KitKat test devices, while retaining `targetSdk 22` for Android 11 compatibility experiments.

The target SDK was lowered from 28 to 22 because Android 11's linker allows this legacy-target app to load an ELF with text relocations:

```text
Warning: libjbedvm.so has text relocations ...
allowing for now because this app's target API level is still 22
```

This is required for the old VM. Raising target SDK back to 23 or later makes Android reject the VM before any native code runs.

## Java/decompilation repairs already made

The project originally failed resource compilation and Java compilation due to invalid JADX output and obsolete Android APIs. The work completed includes:

- `res/values/styles.xml`: replaced raw `-1` / `-2` layout values with `match_parent` / `wrap_content`.
- Replaced `com.google.android.collect.Lists` with a local compatibility implementation.
- Added compile-time compatibility types for removed hidden MMS PDU classes under `java/com/google/android/mms/`.
- Reconstructed broken settings asset extraction from `docs/smali_original/.../JbedSettings.smali`.
- Repaired malformed selector metadata parsing, media snapshot storage, configuration property loading, cursor update usage, decompiled exception flow, duplicate branches, invalid anonymous-class static initialization, and several removed Android APIs.
- Guarded absent `javax.net.ssl.trustStore` in `JbedSettings.syncCerts()`; Android 11 returned null and crashed on `new File(null)`.

A basic syntax scan found no remaining obvious patterns of:

```text
Method not decompiled
th = th2;
break; break;
```

However, many JADX warning comments remain. Repair future Java errors by comparing the exact method with the matching file in `docs/smali_original/`, not by guessing control flow.

## Native compatibility experiment

### Why this is necessary

`libjbedvm.so` is an ELF32 ARM library built against Android 2.x private system libraries:

```text
libdrm1.so
libutils.so
libskia.so
libcutils.so
libsurfaceflinger_client.so
libui.so
```

Android 11 does not expose these to an app linker namespace. The app was initially blocked at `libdrm1.so`; compatibility shims have been added only to make linker/native progress observable.

Source and build script:

```text
native_compat/build-drm1-shim.sh
native_compat/libdrm1.c
native_compat/libutils_compat.S
native_compat/libskia_compat.c
native_compat/empty_legacy_library.c
native_compat/libui_compat.c
native_compat/libsurface_compat.c
native_compat/libpng_compat.c
native_compat/README.md
```

Generated files are ignored and built in CI into `lib/armeabi/`:

```text
libdrm1.so
libutils.so
libskia.so
libcutils.so
libui.so
libsurfaceflinger_client.so
libpng.so
```

The project uses `lib/` as `jniLibs`, so these are packaged beside `libjbedvm.so`.

### Compatibility components and limitations

| Shim | Purpose | Current implementation | Important limitation |
|---|---|---|---|
| `libdrm1.so` | OMA DRM API (`SVC_drm_*`) | Rejects every DRM call with an error | DRM-protected `.drm` / `.dm` content cannot work. Ordinary MIDlets may not need it. |
| `libutils.so` | `android::RefBase::incStrong/decStrong` | ARM no-op retain/release calls | Deliberately leaks old native references. |
| `libskia.so` | Small old Skia surface imported by VM | ABI-named stubs for Paint/Bitmap/Canvas | Text rendering and true Skia object behavior are not implemented. It is only a load/initialization bridge. |
| `libcutils.so` | Old retained DT_NEEDED dependency | Empty valid ELF; also depends on `libpng.so` | No original libcutils behavior is implemented. |
| `libpng.so` | Legacy VM imports PNG symbols without DT_NEEDED | Stub symbols, loaded as a dependency of `libcutils.so` | PNG decoding is not implemented. |
| `libui.so` | Old Region + `bytesPerPixel` API | Minimal Region no-ops and pixel-format calculation | Does not provide actual Android UI behavior. |
| `libsurfaceflinger_client.so` | Old `Surface::lock/unlockAndPost` | 480x800 RGB_565 software buffer | Framebuffer is not presented to a modern Android `Surface`. |

### Why `libpng.so` is linked through libcutils

`libjbedvm.so` imports `png_sig_cmp` and related libpng symbols but does not list libpng as a `DT_NEEDED` dependency. Calling `System.loadLibrary("png")` did not work because it loaded the shim in Android's local linker scope.

The build script now creates this dependency chain:

```text
libjbedvm.so --DT_NEEDED--> libcutils.so --DT_NEEDED--> libpng.so
```

This puts PNG symbols in the linker's dependency group while resolving `libjbedvm.so`.

## Runtime status and current blockers (updated 2026-08-08)

The ARM32 VM now loads and executes meaningful Jbed code on the Android 11 ARM test device. This is **link/load and bootstrap progress**, not a complete Android 11 port.

### Confirmed working path

- `targetSdk 22` permits the required text relocations in `libjbedvm.so`; do not raise it to API 23+.
- Legacy dependency shims resolve the old Android 2.x linker dependencies sufficiently for the VM to load.
- `libjbedcompat.so` loads cleanly and registers its two `JbedEngine` methods. The removed experimental `JbedService`/MIDP class hook is no longer registered (`a33c7c1`).
- The JNI hook promotes the VM's stale saved `JbedEngine` local reference to a global reference before its first callback. This fixes ART's former `use of invalid jobject` abort.
- The hook substitutes `"<unknown>"` when the native MIDP string bridge returns null/throws, preventing the observed `strlen(NULL)` crash in `android_midp_getString`.
- Empty recovered `PreInstall/` content is no longer passed as `-preinstall` (`17def98`); current native AMS arguments are only `-native-ams`.
- The VM starts the root isolate, builds `com.jbed.ams.NativeAms`, starts the media subsystem, and reaches scheduler foreground selection.

Observed proof from the latest test before the final stack-size change:

```text
Main: main() started ROOT isolate
ams.Main started with 1 args:
  args[0] : -native-ams
Main: main() currentCommand is 16
NativeAms constructed okay
Scheduler.setForeground from null to com.jbed.ams.NativeAms
```

### Platform fault mitigation on the current branch

The last instrumented runs pinned the remaining fault inside libcore's
`AsynchronousCloseMonitor` (`/apex/com.android.art/lib/libandroidio.so`): a
`strd` storing the new node into `blockedThreadList` faults because the `this`
pointer is odd and unmapped. TLS writes, raw syscalls, allocator stubs and
thread creation inside `libjbedvm.so` were all excluded, so the shim now keeps
the legacy VM and the platform runtime apart instead of guessing further:

- the VM's `sigaction`/`signal` GOT slots are interposed and the VM's timer
  ticks are forwarded to the VM handler only when the interrupted `pc` lies in
  VM code; ticks that hit ART/libcore/libc are counted and dropped;
- the VM's 12-byte Android 2.x `struct sigaction` is translated and sanitized
  before it reaches bionic;
- libandroidio's four `async_close_monitor_*` entry points are replaced by
  `movs r0, #0; bx lr` / `bx lr` stubs so the blocked-thread list is never
  built or walked, at the cost of async-close interruption of blocking I/O.

Each layer has an on-device opt-out marker
(`disable-rt-signal-hooks.patch`, `disable-monitor-emulation.patch`) and the
crash record lists the resulting counters, so the next run shows which layer
engaged. See the "Platform-library guard rails" section of
`native_compat/README.md` for details and trade-offs.

### Platform fault mitigation on the current branch — follow-up

The first on-device run of the guard rails showed two errors at shim load that
were both consequences of one bug: mapping names were truncated to 95
characters, and Android 11 stores application libraries under
`/data/app/~~<hash>==/<package>-<hash>==/lib/arm/libjbedvm.so` (108 characters
for this package). `module_lookup("libjbedvm.so")` could therefore never match,
so the VM signal interposition never installed, while the monitor emulation
matched `/apex/com.android.art/lib/libandroidio.so` on the janitor retry. The
name field now holds the scanner's full path, the mapping table is refreshed
before the first guard attempt (it used to be empty, which also made every
module print as `unmapped`), and a module that is not mapped yet is reported as
"will retry" instead of an error.

The local-install search (`AmsEventHandler`) now scans exactly
`/storage/emulated/0/jbedfix/` (next to the shim logs) and the VM's own
`LocalInstall` directory; the walk of the whole external-storage root was
removed because on Android 11 it descends through every media directory.
Duplicate paths are filtered, and
`disable-direct-install-upcall.patch` disables the diagnostic direct-upcall
bridge so the install event travels only through the Java AMS path.

Selecting a JAR in that list now writes the suite into the Jbed storage directly
(`LocalSuiteInstaller`): `<prefix>suite.jar`, `<prefix>.jar`, `<prefix>suite.utf`,
`<prefix>.jad`, `<prefix>info_suite.utf`, `<prefix>info_<no>.icn` and an appended
`selector.utf` entry. The MIDlet list is built by `JbedSelector` from
`selector.utf`, so the entry appears without the VM's installer. The reason this
is necessary is visible in the library itself: the AMS is **AOT compiled inside
`libjbedvm.so`** (its Java string constants are UCS-2 entries in the ROM image
next to `suite.jar`, `suite.utf`, `selector.utf`, `/Installed/`), and its
install pipeline (`STEP_GET_JAD` … `STEP_PRECOMPILE`) overflows the host thread
stack as soon as it consumes a local install event. The installer self-verifies
by re-parsing `selector.utf`, and the first run of a build dumps the storage
layout and selector content into `jbed.log` /
`/storage/emulated/0/jbedfix/installed-layout.txt` so the JAR/JAD naming of the
AOT-compiled AMS can be confirmed. `disable-local-sidecar-install.patch` restores
the original (VM installer) behaviour.

The next run named the failure precisely: the VM's upcall
`AmsConnection.fetchEvent()` threw `ArrayIndexOutOfBoundsException`, because
`AmsClientBase.getEventName()` indexed `eventAndroidNames` (five entries) with
Android event ids that go up to 10031; the exception came from a log line
inside `fetchEvent()`, the hook cleared it, the VM received null and re-entered
the call from native code until the JbedThread stack overflowed. The lookup is
bounds checked, `AmsEvent.toString()` cannot throw, `fetchEvent()` and
`handleEventEx()` catch everything and drain a static fallback queue (so an
event still reaches the VM when no `AmsConnection` instance is registered in
the process), and the hook now reports the exception class and message of any
failing upcall.

Launching a suite reached the VM and failed the same way as install did
(`StackOverflowError: stack size 65MB` in `nativeJbedRun`). The last upcalls
before the overflow were a repeated VM -> Java call of one static
`JbedFileManager` method; the static root helpers (`getRoots`, `getRootPaths`)
went through the `JbedFileManager` `INSTANCE`, which may not exist yet when the
VM's file bridge calls them from native code, so they threw
`NullPointerException`. The compatibility hook clears a pending exception
before the next upcall (the 2011 VM cannot handle an ART exception), therefore
the VM saw a null byte array and repeated the call until the thread stack
overflowed. The helpers are now instance-independent, and the hook logs every
upcall that throws (`VM upcall <call> threw a Java exception in <Class.method>`)
together with `Class.method` names in the JNI trace, so a remaining retry loop
can be named from the log alone.

Installs are still blocked further down the stack: the install event reaches the
VM's native upcall queue and is consumed (`poll result=1`), but the VM's Java
side cannot run — `nativeJbedRun` raises `StackOverflowError: stack size 65MB`
immediately, the recovery path runs, and the next call returns
`delay=2147483513` (about 24 days), after which the JbedThread sleeps until the
next VM state change. This is the documented unbounded recursion inside the
proprietary VM scheduler/AMS path, not a stack-size limit.

### FileConnection bridge

`JbedFileManager.getRoots()` is reached through the old native JNI bridge but returns null with a pending Java exception on this ART runtime. `ExceptionDescribe()` is not a non-Java diagnostic on this ART build: it enters `Throwable.printStackTrace()`, which appeared in the JNI trace as repeated Java upcalls and added stack pressure during recovery. The hook therefore suppresses it by default; `/storage/emulated/0/jbedfix/describe-upcall-exceptions.patch` enables it only for an explicit one-off diagnostic run.

The compatibility shim now bypasses the two unsafe legacy static JNI callbacks entirely (`088a580`): it supplies `"<unknown>"` for native i18n and synthesizes a one-root `sdcard/` FileConnection payload for `getRoots`, without entering Android Java. The root path is chosen from `EXTERNAL_STORAGE`, `/storage/emulated/0`, `/sdcard`, then `/mnt/sdcard`. This is enough to stop NativeAms from treating storage as absent, but full FileConnection behavior is still not proven. Separately, `JbedFileManager` maps legacy `/mnt/sdcard` to Android's actual legacy external-storage path when its normal Java method can run (`043ce2f`).

### Current active blocker: Jbed thread stack

The VM advanced past FileConnection but then failed while scheduling NativeAms:

```text
java.lang.StackOverflowError: stack size 1040KB
at com.esmertec.android.jbed.service.JbedEngine.nativeJbedRun(Native Method)
at com.esmertec.android.jbed.service.JbedEngine$JbedThread.run(JbedEngine.java:...)
```

The same stack exhaustion occurred during the failing `getRoots()` callback. The Android host `JbedThread` stack was raised from the ART default (~1 MiB) to diagnostic headroom, but stack-only tuning is not a real fix. Testing showed the VM can still overflow with a larger host stack (for example `stack size 9232KB`) immediately after the zero-delay NativeAms scheduler path. Therefore the issue is not simply the default ART stack limit: it is an unbounded/deep recursive path inside the proprietary VM scheduler/bootstrap.

Current experiment: `libjbedcompat.so` uses a staged scheduler patch. During NativeAms bootstrap it changes libjbedvm's hard-coded `Jbed_run(50)` immediate to the VM's minimum accepted `Jbed_run(20)`. The decompiled flow confirms that the first `Jbed_run()` first calls `Jbed_initialize()`, commits state `0 -> 1`, then calls `Jbed_upcall_poll()` and `Jbed_iterate(20)`; therefore a crash after the state-1 callback but before the Java "nativeJbedRun returned" marker is in the post-initialization poll/iterate path. The cloned JNIEnv table observes the legacy `vmStateChange(true, ..., 3, ...)` `CallBooleanMethod` and now applies the low-quantum patch immediately after the original Java callback returns, before the VM resumes its caller. This is early enough to prevent the next scheduler pass from recursing at quantum 20, while avoiding the SIGBUS observed when code was mprotected while the callback was still executing. The patch lowers the wrapper to `Jbed_run(1)`, changes the matching `Jbed_iterate` `quantum >= 20` assertion guard to `>= 1`, and changes the later `if (quantum < 20) skip scheduled execution` gate to `if (quantum < 1)`. Java still repeats the same low-quantum patch from the `StackOverflowError` fallback. The fallback also resets libjbedvm native-call/scheduler flags that are normally restored at the end of `Jbed_iterate()` but are skipped when ART throws through the native frame. The Android host `JbedThread` remains at 64 MiB diagnostic stack headroom. Java unblocks the AMS startup wait if nativeJbedRun still overflows after the foreground transition, so the UI is not left forever on the modal wait dialog.

The startup patch can now be isolated without rebuilding: create `/storage/emulated/0/jbedfix/disable-startup-quantum.patch` and relaunch to keep the original `Jbed_run(50)` immediate. Remove it to use the default `Jbed_run(20)` diagnostic path. The Java loop writes `entering nativeJbedRun #N` and `nativeJbedRun #N returned delay=D` markers to `jbed.log`; the absence of the latter proves the native call did not return. For the first twelve calls, the native shim now snapshots the lifecycle globals decoded from `libjbedvm.so.c` (`requested`, `reason`, `committed`, `lastNotified`, `controlSignal`), scheduler time/deadline and quantum-patch flags, and both upcall queue lists before and after each run into `native.log`. This makes `2147483647` distinguishable between the explicit `Jbed_run()` idle return (`committed == 0 && requested == 0`), a scheduled item waiting for a far-future deadline, an empty queue, and an uncommitted state request. Native crash markers now include `pc`, `sp`, `lr`, ARM argument registers, module names and module offsets; when the PC or LR is inside the VM image, its offset can be looked up directly in the decompiled VM instead of guessing from `si_addr`.

Native crash records were extended for faults inside platform libraries: they now carry `si_code` (with `sent=1` when the signal was delivered rather than raised by hardware), the crashing thread's `tid` and name, the mapping (`faultModule`, base, offset, permissions) that contains `si_addr`, a frame-pointer return-address chain, and the last VM → Java upcalls observed by the cloned `JNIEnv` table. On the next launch the shim re-reads the previous crash record and dumps the raw bytes around `pc`, `lr` and the fault address into `native.log` as `probe …` lines, so the faulting instruction can be disassembled without a shell on the device; an explicit dump list can be placed in `/storage/emulated/0/jbedfix/probe.txt` as `<module> <offset-hex> [<length-hex>]`. `/storage/emulated/0/jbedfix/disable-crash-handler.patch` and `disable-jni-trace.patch` disable the diagnostics for an A/B launch. The current report is a SIGBUS in `/apex/com.android.art/lib/libandroidio.so` with `si_code=1` (`BUS_ADRALN`, a misaligned access), `si_addr == r4 == 0xebd6141d` (an odd address that is not inside any mapping) and `faultModule=unmapped`, i.e. an instruction in libandroidio reads or writes eight bytes through a wild pointer. libandroidio contains only libcore's AsynchronousCloseMonitor (its blocked-thread list, used by `IoBridge.closeAndSignalBlockedThreads` on every Java `FileDescriptor` close); the crash record now also reports the ELF-base-relative offsets, the instruction words around `pc`, the module's mapping list, the first words of its writable segment (the monitor's mutex and list head) and how many libcore `__SIGRTMIN+2` (signal 34) deliveries were observed, so the faulting instruction and the state of the monitor list can be read directly from `/storage/emulated/0/jbedfix/native-crash.log`. `native_compat/README.md` documents how to read each field; `/storage/emulated/0/jbedfix/probe.log` holds the byte-level dumps and the ELF layout that the shim collects on the launch after a crash.

Surface rendering also remains unresolved because the `libsurfaceflinger_client.so` shim has no modern display presentation path. Android 11 also blocks direct APN provider access; `JbedMidpManager` now treats APN lookup/observer failures as "no HTTP proxy" instead of crashing the remote VM process, and the legacy APN settings menu is hidden. Local JAR/JAD selections now also enqueue direct native install upcalls onto `JbedThread` from `AmsConnection` in addition to the original queued `INSTALL` event, because the recursive scheduler can fail to reach `NativeAms.nativeGetEvent()` after a post-foreground stack overflow. The bridge calls both `Jbed_ams_event_requestInstall(url)` and `Jbed_ams_event_requestLocalInstall(url, "")`, then invokes `Jbed_upcall_poll()` immediately to bypass a stalled scheduler poll. Calling these upcalls directly from the Binder thread crashed because the old VM expects Jbed-thread native state; calling `requestLocalInstall` with only one argument crashed in `strlen(NULL)`, so the bridge supplies an empty secondary JAD URL argument.

### Focused test procedure

Do not filter an accumulated old capture. Clear logcat, start the newest APK, then save a fresh capture:

```powershell
C:\adb\adb.exe logcat -c
C:\adb\adb.exe shell am force-stop com.esmertec.android.jbed
C:\adb\adb.exe shell monkey -p com.esmertec.android.jbed 1
Start-Sleep -Seconds 3
C:\adb\adb.exe logcat -d -v threadtime | Set-Content .\jbed-fresh.txt
Get-Content .\jbed-fresh.txt | Select-String -Pattern "jbed-jni-compat|JbedFileManager|FileSystemCallHandler|NativeAms|Scheduler|StackOverflowError|Fatal signal|JNI DETECTED|jbed_gfx|jbed.native" -Context 3,15
```

The previous `tools/collect-jbed-log.ps1` helper may also be used. Verify the APK is at or after `0393f61` before interpreting a missing marker.

### Relevant recent commits

```text
088a580 Bypass recursive legacy static JNI callbacks
0393f61 Increase Jbed VM thread stack on ART
c0daa81 Provide empty roots when legacy file bridge fails
5cc09d5 Trace legacy file system JNI startup
043ce2f Use current external storage root for J2ME file system
a33c7c1 Stop registering removed MIDP JNI hook methods
892a390 Replace obsolete display and surface APIs
17def98 Skip empty legacy preinstall mode
2197fab Guard null legacy MIDP JNI string results
c54dcf0 Prevent null localized strings crossing native boundary
```

## Important native reference in `main`

Commit `1b9e561` on `main` added:

```text
docs/libsurfaceflinger_client.so
docs/libsurfaceflinger_client.so.c
```

It is a real old ARM32 `libsurfaceflinger_client.so` plus Hex-Rays output. It was inspected but intentionally not bundled as the Android 11 solution.

It is useful as an ABI reference because it confirms the old functions and `SurfaceInfo` layout needed by the Jbed VM:

```text
android::Surface::lock(SurfaceInfo*, Region*, bool)
android::Surface::lock(SurfaceInfo*, bool)
android::Surface::unlockAndPost()
```

However that original library itself requires:

```text
libbinder.so
libhardware.so
libui.so
libutils.so
libcutils.so
```

Those are old framework-private Android libraries. Copying this old library into an Android 11 APK is not expected to work.

## Critical architectural limitation

The native VM was written for a pre-Honeycomb private Surface ABI. `docs/libjbedvm.so.c` shows that it obtains an old native Surface object and invokes old `Surface::lock`, receiving a `SurfaceInfo` that contains a direct `bits` pointer. It copies VM pixels into that buffer and calls `unlockAndPost()`.

The current `libsurfaceflinger_client.so` shim provides a software framebuffer so linker and VM initialization can progress, but it does **not** draw to the modern Java `Surface`.

Additionally, `Java_android_jbed_app_JbedView_nativeInitializeAppView` in `docs/libjbedvm.so.c` accesses old private Java fields on `android.view.Surface`, including `mNativeSurface`. Modern Android releases do not expose that old ABI. A complete solution will require one of:

1. Binary patch/rewrite `libjbedvm.so`'s old JbedView native entry point to use a modern bridge; or
2. A separate compatibility native library that constructs/adapts the expected old surface state and presents pixels through public APIs; or
3. Running the VM in a matching old Android 2.x/Android 3.x ARM environment instead of Android 11.

A no-op surface shim is not a complete emulator renderer.

## Recommended next steps for the next agent

1. **Do not reintroduce targetSdk >= 23.** Text relocations will make the VM impossible to load on Android 11.
2. The next technical task is **not another linker shim**. Implement and test an ARM32 patch that promotes the saved `JbedEngine` JNI local reference to a global reference during `Java_android_jbed_service_JbedEngine_nativeInitializeSubsystems()`.
3. Preserve a rollback copy of `libjbedvm.so`; this is proprietary binary patching. Confirm the patched library still has the expected ELF32 ARM layout and symbols.
4. Once the JNI global-reference patch is applied, collect the native VM crash from both `main` and `crash` buffers. The meaningful section begins at:

   ```text
   JbedEngine: Jbed Thread Started
   ```

5. If a new missing old C++ symbol is reported, compare it exactly against:

   ```bash
   readelf -Ws lib/armeabi/libjbedvm.so | grep ' UND '
   ```

   Add a shim only when its ABI can be determined safely. Verify mangled C++ names character-for-character.

5. If the native library gets through linker loading, inspect `JNI_OnLoad` in `docs/libjbedvm.so.c`. It registers native methods using correct `com/esmertec/android/jbed/...` class names, so the old exported `Java_android_jbed_*` symbol spelling is not by itself a blocker.

6. Do not claim the current shims make Jbed usable. They are controlled compatibility experiments to advance linker initialization and expose the actual next blockers.

7. For a usable Android 11 port, prioritize a real rendering plan:
   - establish a software framebuffer allocated by a modern native bridge;
   - bridge it to public `ANativeWindow`/`Surface` APIs or copy it to a Java `Bitmap`/`Canvas`;
   - patch/adapt the native VM's old `mNativeSurface` access;
   - implement PNG decoding if image resources are required;
   - later address camera/media/DRM only as needed.

8. A practical fallback is to obtain the matching HTC Android 2.3 ROM/system libraries and run the original APK in an old ARM Android emulator/device. This is useful for behavioral comparison and ABI investigation, but old system libraries must not be assumed to work when copied into Android 11.

## Commands used for device diagnostics

```bash
adb shell setprop log.tag.jbedservice DEBUG
adb shell setprop log.tag.jbedapp DEBUG
adb shell setprop log.tag.jbedams DEBUG
adb shell am force-stop com.esmertec.android.jbed
adb logcat -c
adb logcat -b all -v threadtime > jbed-startup.txt
```

Useful device ABI check:

```bash
adb shell getprop ro.product.cpu.abilist
adb shell getprop ro.product.cpu.abi
```

The VM is ELF32 ARM. It cannot run on a 64-bit-only device or x86/x86_64 emulator without a suitable ARM compatibility layer.
