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

## Latest observed runtime status

The linker phase has now completed successfully on the Android 11 test device:

- Android 11 allows `libjbedvm.so` text relocations because target SDK is 22.
- The service connects.
- `JbedEngine` starts its native VM thread.
- `nativeInitializeSubsystems()` completes sufficiently to log the command line/settings.
- The first `nativeJbedRun()` call enters the real VM.

The latest runtime failure occurs immediately in the first VM iteration:

```text
JbedEngine: Jbed Thread Started
JbedEngine: jbed.settings=...
from int com.esmertec.android.jbed.service.JbedEngine.nativeJbedRun()
pc ... libjbedvm.so (Java_android_jbed_service_JbedEngine_nativeJbedRun+12)
```

`Java_android_jbed_service_JbedEngine_nativeJbedRun()` is only a thin wrapper:

```c
int Java_android_jbed_service_JbedEngine_nativeJbedRun() {
    return Jbed_run(50);
}
```

The primary ART failure was subsequently captured and is now known exactly:

```text
JNI DETECTED ERROR IN APPLICATION: use of invalid jobject 0xc200299c
from int com.esmertec.android.jbed.service.JbedEngine.nativeJbedRun()
```

This is an Android 2.x JNI lifetime bug in the proprietary VM, not a missing linker symbol. `docs/libjbedvm.so.c` identifies the bad flow:

1. `Java_android_jbed_service_JbedEngine_nativeInitializeSubsystems()` receives the Java `JbedEngine` object as JNI parameter `a2`.
2. It saves that **local JNI reference** directly in global native storage:

   ```c
   dword_31C864 = a2;
   ```

3. The native method returns, making `a2` invalid on modern ART.
4. On the first `Jbed_run()`, `JbniS_com_jbed_runtime_Main_notifyStateChange()` invokes callback `sub_A0264()`.
5. `sub_A0264()` calls `CallBooleanMethod` using the stale `dword_31C864` object reference, which ART rejects.

The relevant decompiled callback is:

```c
return (*env)->CallBooleanMethod(
    env, dword_31C864, dword_31C868, commit, oldState, newState, reason);
```

Dalvik-era JNI represented references in a way that let this unsafe pattern survive. ART uses checked/indirect JNI references and aborts immediately.

A real fix now requires an ARM32 binary patch to `libjbedvm.so`:

- replace/augment the `dword_31C864 = a2` path with `NewGlobalRef(a2)`;
- store that global ref instead of the local ref;
- call `DeleteGlobalRef` when the VM finalizes;
- keep the existing callback ABI unchanged.

A compatibility shim loaded after the original method returns cannot reliably fix this because the local reference has already expired. The patch must occur inside the original native initialization method or through a carefully designed in-method interception.

The previous Skia ABI mismatch was fixed in:

```text
870f647 Match legacy SkPaint measureText ABI
```

The next agent should collect a fresh complete failure using the `crash` buffer and look specifically for lines immediately before the `from int ... nativeJbedRun()` message:

```bash
adb logcat -c
adb shell am force-stop com.esmertec.android.jbed
adb shell monkey -p com.esmertec.android.jbed 1
adb logcat -d -b crash -v threadtime
adb logcat -d -b main -v threadtime | grep -Ei 'JNI DETECTED|JNI ERROR|Fatal signal|Abort message|nativeJbedRun|jbed.native'
```

On Windows PowerShell, use `Select-String` instead of `grep`.

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
