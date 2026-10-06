# Native compatibility experiments

`libjbedvm.so` was built for a much older Android release. Its ELF dependencies
include proprietary framework libraries that Android 11 does not expose to
ordinary applications.

## DRM1 shim

`libdrm1.c` is a deliberately narrow compatibility shim for the first missing
dependency reported by Android 11:

```
dlopen failed: library "libdrm1.so" not found
```

Static inspection of `libjbedvm.so` shows that it imports only these DRM1
symbols:

- `SVC_drm_openSession`, `SVC_drm_closeSession`
- `SVC_drm_getDeliveryMethod`, `SVC_drm_getRightsInfo`,
  `SVC_drm_getRightsIssuer`, `SVC_drm_getContentType`
- `SVC_drm_checkRights`, `SVC_drm_consumeRights`, `SVC_drm_deleteRights`,
  `SVC_drm_installRights`, `SVC_drm_getContent`

They are used for OMA DRM rights/content handling, represented in Java by
`JbedDrmManager` and `.dm`/`.drm` files. The shim rejects every DRM operation;
it is intended solely to get non-DRM MIDlets past dynamic linking and reveal
the next incompatible dependency.

### Build the ARM32 shim

Do this on a machine with the Android NDK installed. The output must be built
for **armeabi-v7a / 32-bit ARM**, because the Jbed VM is an ELF32 ARM library.

```bash
"$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/clang" \
  --target=armv7a-linux-androideabi19 \
  -fPIC -shared -O2 \
  -Wl,-soname,libdrm1.so \
  -o lib/armeabi/libdrm1.so native_compat/libdrm1.c
```

On macOS replace `linux-x86_64` with `darwin-x86_64` or `darwin-arm64` as
appropriate. Then rebuild the APK; Gradle's existing `jniLibs.srcDirs = ['lib']`
configuration packages `lib/armeabi/libdrm1.so` automatically.

### Expected result

This does **not** make the VM Android 11-compatible. It only lets the loader
advance past `libdrm1.so`.

## libutils shim

The same script also builds a minimal `libutils.so`. Inspection of this VM
shows it imports only `android::RefBase::incStrong` and `decStrong` from that
library. The shim exports no-op ARM32 versions of those two symbols. This is a
controlled leak, but is sufficient to advance the linker without pretending to
implement the rest of old `libutils`.

## libskia shim

`libskia_compat.c` supplies the exact small legacy Skia symbol set imported by
this VM: Paint configuration/metrics, Bitmap configuration, and Canvas text
operations. It is a safe first-stage compatibility layer: object operations do
not dereference legacy C++ object layouts, while text drawing and metrics are
currently no-ops. This gets the linker past `libskia.so` without claiming to
be a full renderer; Jbed's Surface-buffer rendering can then be tested.

## Jbed JNI/native scheduler compatibility hook

`jbed_jni_lifetime_hook.c` builds `libjbedcompat.so`, loaded after the original
`libjbedvm.so`. The shims are built for Android API 19 so the APK can install
on Android 4.4.2/KitKat. Scheduler-quantum binary patches are disabled on
pre-Lollipop devices and left to the legacy VM path; ART/Android 5+ keeps the
staged scheduler workarounds. It currently provides targeted ART workarounds:

- clones the active `JNIEnv` table long enough to promote libjbedvm's saved
  `JbedEngine` local reference to a global reference and to bypass unsafe
  legacy static callbacks. `JbedMidpManager.getString` returns `"<unknown>"`;
  `JbedFileManager.getRoots` returns a synthesized one-root `sdcard/` payload;
- uses a staged scheduler patch: bootstrap runs the original `nativeJbedRun`
  wrapper at `Jbed_run(20)`, then the cloned `JNIEnv` observes the legacy
  foreground `vmStateChange` `CallBooleanMethod` and asks Java to defer the
  patch until the native callback has returned. Java then lowers the wrapper to
  `Jbed_run(1)`, patches the matching `Jbed_iterate` minimum-quantum assertion
  guard from 20 to 1, and patches the later scheduled-execution gate from
  `quantum < 20` to `quantum < 1`. Applying the patch after the callback avoids
  an ARM ART SIGBUS observed when code was mprotected while the VM was still
  executing that callback. Java repeats this low-quantum patch from the
  `StackOverflowError` fallback as a safety net and resets the native-call/
  scheduler flags skipped when ART throws through the old native frame. This
  keeps execution inside the proprietary VM while minimizing scheduler stack
  pressure; it is not a complete fix for the proprietary scheduler;
- registers an `AmsConnection.nativeRequestLocalInstall()` bridge for local
  JAR/JAD selection. `AmsConnection` enqueues this call onto `JbedThread`;
  calling it directly from the Binder thread crashes because the old VM expects
  Jbed-thread native state. The bridge calls both exported native entry points,
  `Jbed_ams_event_requestInstall(url)` and
  `Jbed_ams_event_requestLocalInstall(url, "")`, then immediately calls
  `Jbed_upcall_poll()` to bypass a stalled native scheduler poll. The empty
  secondary JAD URL avoids `strlen(NULL)` in the local-install vararg formatter.
  This is a diagnostic bypass for cases where the original Java event queue is
  populated but the native AMS scheduler does not reach `NativeAms.nativeGetEvent()`
  after stack overflow.

## Surface software bridge

The `main` branch reference commit `1b9e561` includes an Android 2.x
`libsurfaceflinger_client.so` and its Hex-Rays output. It confirms the legacy
`SurfaceInfo` ABI used by Jbed: width, height, stride, usage, format and a
pixel-buffer pointer. `libsurface_compat.c` and `libui_compat.c` implement the
small symbol subset imported by Jbed using a 480x800 RGB_565 software buffer.
They deliberately avoid Android 11's private SurfaceFlinger ABI. The current
bridge permits VM initialisation and framebuffer writes; presenting this buffer
on a modern Java Surface is a later step.

## Native crash diagnostics

`libjbedcompat.so` mirrors its JNI, linker, and scheduler markers to
`/storage/emulated/0/jbedfix/native.log` in addition to Android's log buffer.
It also installs observing handlers for `SIGSEGV`, `SIGABRT`, `SIGBUS`,
`SIGILL` and `SIGFPE`, and appends a crash record to
`/storage/emulated/0/jbedfix/native-crash.log`. The handlers run on a private
128 KiB alternate signal stack and chain to whatever handler ART had installed
before them, so ART's tombstones, implicit null checks and `StackOverflowError`
handling keep working; the shim never replaces the previous disposition.

A crash record contains, per line:

- `signal=`/`code=`/`pid=`/`tid=`/`thread=`. `code` is `siginfo.si_code`: a
  value `<= 0` (plus the appended `sent=1`) means the signal was sent by a
  thread or process (`kill`/`tgkill`/`raise`) instead of being raised by the
  hardware, so `address` (`si_addr`) is not a fault address at all.
- `pc=`, `sp=`, `lr=`, `r0`–`r10`, `fp`, `ip` and `cpsr`.
- `pcModule=`/`pcModuleBase=`/`pcModuleOffset=` and the same triple for `lr`,
  plus `vmBase=` and `vmPcOffset=` when the PC is inside `libjbedvm.so`. The
  offsets are relative to the *mapping* containing the address, which is
  reproducible across launches even though module bases are randomized. When
  the PC or LR is inside the VM image, its offset can be looked up directly in
  `docs/libjbedvm.so.c`; unlike `si_addr`, these values identify the failing
  instruction and its caller.
- `faultModule=`/`faultModuleBase=`/`faultModuleOffset=`/`perms=` for
  `si_addr`, or `faultModule=unmapped` when it is not inside any mapping.
- `frame=N fp=… return=<module>+0x…` — the frame-pointer chain, which names the
  caller of the crashing function.
- `stack-scan <module>+0x… …` — return addresses found in the words above `sp`
  (bounded by the stack mapping), for frames built without frame pointers.
- `jni-trace …` — the last VM → Java upcalls seen by the cloned `JNIEnv` table
  with their Java method names, plus VM state transitions. This is the only
  trace of what the VM was doing when the fault happened in platform code that
  has no Java stack trace.

Because module offsets are reproducible, the shim re-reads the previous crash
record during the next launch and dumps the raw bytes around `pc`, `lr` and the
fault address into `native.log`
(`probe pc <module>+0x…: <hex bytes>`). Those bytes can be disassembled into ARM
instructions to identify the faulting instruction without shell access to the
device. An explicit request list can be placed in
`/storage/emulated/0/jbedfix/probe.txt`, one
`<module name> <offset hex> [<length hex>]` per line (`#` starts a comment);
`offset` is relative to the mapping start, the default dump is 192 bytes
starting 64 bytes before the offset, and every read is clamped to the mapping.

Diagnostics can be disabled per launch without rebuilding by creating
`/storage/emulated/0/jbedfix/disable-crash-handler.patch` or
`/storage/emulated/0/jbedfix/disable-jni-trace.patch`.

If logcat is available, collect it in addition to these files: the chained
handler lets ART emit its normal tombstone, which contains the full unwind this
shim only approximates.

For a controlled bootstrap comparison, create the empty marker file
`/storage/emulated/0/jbedfix/disable-startup-quantum.patch` before launching
Jbed. The compatibility shim will leave the decompiled VM's original
`nativeJbedRun -> Jbed_run(50)` immediate unchanged and record that choice in
`native.log`. Remove the marker to restore the default Android 5+ diagnostic
patch to `Jbed_run(20)`. This isolates the startup patch from the later
foreground/deferred patch without rebuilding the APK.

The next load attempt may expose additional unavailable legacy framework APIs.
