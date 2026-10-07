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
- logs *which* exception a legacy Java callback threw, with its class and
  message (`VM upcall <call> threw <java.lang.FooException: ...> in
  <Class.method>`), before clearing it. This is what identified the current
  blocker: `AmsClientBase.getEventName()` indexed its name arrays by event id,
  and the Android-side table holds five entries while the VM asks about ids up
  to 10031, so the log line inside `AmsConnection.fetchEvent()` threw
  `ArrayIndexOutOfBoundsException`, the VM received null and re-entered the
  call from native code until the JbedThread stack overflowed. The lookup is
  bounds checked now, `AmsEvent.toString()` no longer throws, `fetchEvent()` /
  `handleEventEx()` catch everything and fall back to a static event queue, and
  events are enqueued into whichever queue `fetchEvent()` reads;
- reports a legacy Java callback that throws. The 2011 VM has no notion of an
  ART exception, so the hook clears it before the next upcall and the VM simply
  receives the null the callback returned; `VM upcall <call> threw a Java
  exception in <Class.method>; clearing it` in `native.log` names the callback.
  This is the failure mode behind a VM retry loop: while `JbedFileManager`'s
  static root helpers went through `INSTANCE`, the VM's own file bridge could
  call them before a `JbedFileManager` existed in the process, receive null and
  repeat the call until the JbedThread stack overflowed. The helpers are now
  instance-independent. `disable-low-quantum-patch.patch` turns the staged
  scheduler-quantum patches off for an A/B run;
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

## Platform-library guard rails

The crash that motivates this block was decoded to libcore's
`AsynchronousCloseMonitor` inside `/apex/com.android.art/lib/libandroidio.so`:
the constructor inserts itself at the head of `blockedThreadList` with a `strd`
and faults because the `this` pointer it was handed is an odd, unmapped value.
Every VM-side explanation (TLS writes, raw syscalls, allocator/thread stubs) was
checked and excluded, so the corrupted pointer reaches the constructor from
outside the proprietary VM. The shim therefore keeps the legacy VM and the
platform runtime from crossing into each other:

- **VM timer-tick filter.** libjbedvm runs its Java threads inside one OS thread
  with `setitimer(ITIMER_VIRTUAL)` plus a handler for signal 34. The shim
  interposes the VM's GOT slots for `sigaction`/`signal` (through the ELF32
  relocation table of the *loaded* library, so no PLT rewriting is needed) and
  installs its own filter for the VM's timer interval. A tick is forwarded to
  the VM handler only when the interrupted `pc` is VM code: inside
  `libjbedvm.so`, in `/data/app/.../lib/arm/*`, or in an unnamed executable
  `[anon]` region. Ticks that landed anywhere else (ART, libcore, libc, APEX
  libraries) are counted in the crash record and dropped, so the legacy
  scheduler can no longer preempt the platform runtime in the middle of an
  operation. Create `/storage/emulated/0/jbedfix/disable-rt-signal-hooks.patch`
  to keep the ORIGINAL dispositions.
  Trade-off: while the VM is executing inside a platform library (for example
  inside libc) it is no longer preemptible.
- **Android 2.x `struct sigaction` translation.** The VM passes a 12-byte
  KitKat-era `struct sigaction` (handler, 4-byte mask, flags) where Android 11
  expects 16 bytes. `vm_sigaction_handler`/`vm_sigaction_flags`/
  `vm_sigaction_mask_to_modern` read the legacy layout, and
  `sanitize_sigaction_flags` keeps only `SA_RESTART`, `SA_NODEFER` and
  `SA_SIGINFO`; without this, bionic would pick up garbage as flags and
  `SA_RESETHAND` from the neighbouring stack word could silently disarm the
  filter after the first tick.
- **Platform monitor emulation.** The four exported entry points of
  `libandroidio.so`, `async_close_monitor_{create,was_signalled,
  signal_blocked_threads,destroy}`, are replaced by `movs r0, #0; bx lr` /
  `bx lr` stubs, so `blockedThreadList` is never built, walked or unlinked and
  the corrupted pointer cannot be stored. Create
  `/storage/emulated/0/jbedfix/disable-monitor-emulation.patch` to skip this.
  Trade-off: asynchronous-close interruption of blocking I/O is disabled for
  the process (`was_signalled` always reports "not signalled").
- **Long Android 11 module paths.** `module_lookup` matches the tail of the
  recorded mapping name, so the name buffer must hold the whole path:
  `/data/app/~~<hash>==/<package>-<hash>==/lib/arm/libjbedvm.so` is longer than
  95 characters. With the old 96-byte field the suffix comparison failed and the
  VM signal interposition silently never installed while the monitor emulation
  (a 37-character `/apex/...` path) did. The field now holds the scanner's full
  255-character path.
- **How the text is written.** `write_process_memory` patches through
  `/proc/self/mem` first, which keeps the mapping's permissions untouched, and
  falls back to a temporary `mprotect(RWX)`; both paths read the bytes back and
  flush the instruction cache, which ARM32 needs for modified code.
- The crash record now carries
  `guards sigactionInterposed=… signalInterposed=… monitorStubs=… vmSigAction
  calls=… filtered=… forwarded=… refused=… last=…`, and `native.log` prints
  the interposition, each intercepted/filtered/refused disposition and every
  stub that was written.

## Surface software bridge

The `main` branch reference commit `1b9e561` includes an Android 2.x
`libsurfaceflinger_client.so` and its Hex-Rays output. It confirms the legacy
`SurfaceInfo` ABI used by Jbed: width, height, stride, usage, format and a
pixel-buffer pointer. `libsurface_compat.c` and `libui_compat.c` implement the
small symbol subset imported by Jbed using a 480x800 RGB_565 software buffer.
They deliberately avoid Android 11's private SurfaceFlinger ABI. The current
bridge permits VM initialisation and framebuffer writes; presenting this buffer
on a modern Java Surface is a later step.

## Local install drop box

The AMS "Local install" search (`BasicEventHandler`'s local-install handler)
scans exactly two folders: `/storage/emulated/0/jbedfix/` (the shim's own
directory, so a JAR/JAD dropped next to `native.log` is offered in the MIDlet
list) and the VM's `LocalInstall` directory. It deliberately does not walk the
external-storage root any more: on Android 11 that recursion descends through
every media directory and the resulting list is unusable. Duplicate paths are
filtered.

The direct native install upcall (the diagnostic bridge that pushes the install
event straight into the VM's native queue) can be disabled without rebuilding by
creating `/storage/emulated/0/jbedfix/disable-direct-install-upcall.patch`; the
Java AMS path still queues the event.

Selecting a file in that list no longer depends on the proprietary installer.
`libjbedvm.so` carries its own Java AMS, but it is *ahead of time compiled*
inside the library: its Java string constants are stored as UCS-2 in the ROM
image next to literals such as `suite.jar`, `suite.utf` and `selector.utf`, and
its install pipeline (`STEP_GET_JAD`, `STEP_PARSE_JAD`, `STEP_VERIFY_JAD`,
`STEP_PRECOMPILE`) overflows the host thread stack on Android 11 as soon as it
consumes a local install event (`StackOverflowError: stack size 65MB`, then
`nativeJbedRun` returns a ~24 day delay). `LocalSuiteInstaller` therefore writes
the suite into the Jbed storage itself:

```text
<basedir><prefix>suite.jar        the MIDlet JAR          (prefix is s0_, s1_, ...)
<basedir><prefix>.jar             the same JAR, object-style name
<basedir><prefix>suite.utf        JAD attributes, .properties form
<basedir><prefix>.jad             the same JAD
<basedir><prefix>info_suite.utf   key/value pairs in the binary form
                                  JbedSelectorData.getInfoSuiteValue reads
<basedir><prefix>info_<no>.icn    the MIDlet icon from the manifest
<basedir>selector.utf             appended suite entry (DataOutput UTF text)
```

The MIDlet list is built by `JbedSelector` from `selector.utf`, so the suite is
visible and launchable from the UI as soon as the write finishes; the VM is then
asked to launch it like any other installed suite. The installer verifies its
own work by re-parsing `selector.utf` and logging the resulting entry, and the
first run of a build also records the current storage layout and selector
content in `jbed.log` and `/storage/emulated/0/jbedfix/installed-layout.txt`,
because the exact file naming of the AOT-compiled AMS cannot be read out of the
library. `disable-local-sidecar-install.patch` restores the original behaviour
(hand the request to the VM installer).

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

- `signal=`/`code=`/`pid=`/`tid=`/`thread=`/`blockedThreadSignals=`. `code` is
  `siginfo.si_code`: a value `<= 0` (plus the appended `sent=1`) means the
  signal was sent by a thread or process (`kill`/`tgkill`/`raise`) instead of
  being raised by the hardware, so `address` (`si_addr`) is not a fault address
  at all. For a bus error, `code=1` is `BUS_ADRALN` (misaligned access) and
  `code=2` is `BUS_ADRERR` (non-existent physical address).
  `blockedThreadSignals` counts the deliveries of libcore's `__SIGRTMIN+2`
  (signal 34): the AsynchronousCloseMonitor sends it from
  `IoBridge.closeAndSignalBlockedThreads`, i.e. whenever Java closes a
  `FileDescriptor`, so a non-zero count means the platform was closing
  descriptors during this run.
- `pc=`/`sp=`/`lr=` and `r0`–`r10`, `fp`, `ip`, `cpsr`. Registers that point
  into a mapping are annotated (`r1->/apex/.../libandroidio.so+0x2a64`,
  `r10->anon[rw-p]`, `r4->unmapped`).
- `pc-offsets:` the numbers a disassembler needs: the module's ELF base, the
  executable mapping's start, `pc` relative to both (`offsetFromElfBase=` and
  `offsetFromExecRegion=`), how far the executable mapping starts from the ELF
  base (`execStartFromElfBase=`) and, for the fault address, `faultMod8=` plus
  `faultAlignment=`. When `execStartFromElfBase` is `0x1000`, the mapping start
  is one page *after* the ELF base, so an offset taken from the mapping start is
  one page less than the file offset of that instruction.
- `pc-words:` the instruction words at `pc-16 … pc+4`, printed in the order the
  current state uses (ARM: big-endian word; Thumb: little-endian), which is what
  a disassembler expects. The last word is the faulting instruction.
- `pc-module-maps:` every mapping of that module with its permissions, address
  and distance from the ELF base.
- `pc-module-rw+0x…:` the first 96 bytes of the module's writable segment,
  where the AsynchronousCloseMonitor keeps its mutex and the head of its
  blocked-thread list; a corrupted head is visible here directly.
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
fault address into `/storage/emulated/0/jbedfix/probe.log`. The crash handler
also records the page address it derives for the faulting offset and appends the
same two offsets to `/storage/emulated/0/jbedfix/probe.txt`, so the next launch
dumps both interpretations of the offset side by side. A request list can also be
placed in `probe.txt` by hand, one
`<module name> <offset hex> [<length hex>] [key=value …]` per line (`#` starts a
comment); `offset` is relative to the mapping start, the default dump is 192
bytes starting 64 bytes before the offset, and every read is clamped to the
mapping. `probe.log` also receives the module's ELF header, program headers,
dynamic table and mapping list, which is what identifies how the loader placed
the module's first page.

Everything above is written from data the shim already has, so a record can be
copied from a phone by hand: the fields are short and each one is decoded by the
shim, and `probe.log` only has to be collected when the byte-level dump is
needed.

The shim also installs an observing handler for libcore's blocked-thread signal
(signal 34) and chains to the handler libcore installed, keeping its flags (no
`SA_RESTART`) so the signal still interrupts a blocked syscall exactly as
before. Each delivery is counted in the crash record and appended to
`native.log`, which shows whether a descriptor close was in flight around the
fault. If nothing installed a handler for that signal yet, the observer is not
installed at all - swallowing the signal would change its meaning.

Diagnostics can be disabled per launch without rebuilding by creating
`/storage/emulated/0/jbedfix/disable-crash-handler.patch`,
`/storage/emulated/0/jbedfix/disable-jni-trace.patch`,
`/storage/emulated/0/jbedfix/disable-blocked-thread-observer.patch`,
`/storage/emulated/0/jbedfix/disable-timer-tick-filter.patch`,
`/storage/emulated/0/jbedfix/disable-rt-signal-hooks.patch` or
`/storage/emulated/0/jbedfix/disable-monitor-emulation.patch`.

Upcall exception descriptions are intentionally disabled in the normal path:
ART's `ExceptionDescribe()` enters `Throwable.printStackTrace()` and can add
another Java recursion while the Jbed thread is recovering from a deep native
stack. To temporarily request the full ART description for one diagnostic run,
create `/storage/emulated/0/jbedfix/describe-upcall-exceptions.patch`. The
shim still records the exception fact and clears the pending exception in the
normal path; the marker is opt-in because the description is not safe for the
bootstrap recovery path.

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
