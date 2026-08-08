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

### FileConnection bridge

`JbedFileManager.getRoots()` is reached through the old native JNI bridge but returns null with a pending Java exception on this ART runtime. Its precise failure did not safely produce a Java stack trace: attempting `ExceptionDescribe()` itself hit the already constrained Jbed thread stack.

The compatibility shim now bypasses the two unsafe legacy static JNI callbacks entirely (`088a580`): it supplies `"<unknown>"` for native i18n and synthesizes a one-root `sdcard/` FileConnection payload for `getRoots`, without entering Android Java. The root path is chosen from `EXTERNAL_STORAGE`, `/storage/emulated/0`, `/sdcard`, then `/mnt/sdcard`. This is enough to stop NativeAms from treating storage as absent, but full FileConnection behavior is still not proven. Separately, `JbedFileManager` maps legacy `/mnt/sdcard` to Android's actual legacy external-storage path when its normal Java method can run (`043ce2f`).

### Current active blocker: Jbed thread stack

The VM advanced past FileConnection but then failed while scheduling NativeAms:

```text
java.lang.StackOverflowError: stack size 1040KB
at com.esmertec.android.jbed.service.JbedEngine.nativeJbedRun(Native Method)
at com.esmertec.android.jbed.service.JbedEngine$JbedThread.run(JbedEngine.java:...)
```

The same stack exhaustion occurred during the failing `getRoots()` callback. The Android host `JbedThread` stack was raised from the ART default (~1 MiB) to diagnostic headroom, but stack-only tuning is not a real fix. Testing showed the VM can still overflow with a larger host stack (for example `stack size 9232KB`) immediately after the zero-delay NativeAms scheduler path. Therefore the issue is not simply the default ART stack limit: it is an unbounded/deep recursive path inside the proprietary VM scheduler/bootstrap.

Current experiment: `libjbedcompat.so` now uses a staged scheduler patch. During NativeAms bootstrap it changes libjbedvm's hard-coded `Jbed_run(50)` immediate to the VM's minimum accepted `Jbed_run(20)`. The cloned JNIEnv table also intercepts the legacy `vmStateChange(true, ..., 3, ...)` `CallBooleanMethod` and lowers the wrapper to `Jbed_run(1)`, patches the matching `Jbed_iterate` `quantum >= 20` assertion guard to `>= 1`, and patches the later `if (quantum < 20) skip scheduled execution` gate to `if (quantum < 1)`. Java still repeats the same low-quantum patch from the `StackOverflowError` fallback. The fallback also resets libjbedvm native-call/scheduler flags that are normally restored at the end of `Jbed_iterate()` but are skipped when ART throws through the native frame. The Android host `JbedThread` is currently at 64 MiB diagnostic stack headroom because the scheduler now reaches the install handler but still overflows at the former 16 MiB setting; this distinguishes finite deep recursion from an effectively infinite loop. Java unblocks the AMS startup wait if nativeJbedRun still overflows after the foreground transition, so the UI is not left forever on the modal wait dialog.

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
