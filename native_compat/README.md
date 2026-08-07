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
  --target=armv7a-linux-androideabi21 \
  -fPIC -shared -O2 \
  -Wl,-soname,libdrm1.so \
  -o lib/armeabi/libdrm1.so native_compat/libdrm1.c
```

On macOS replace `linux-x86_64` with `darwin-x86_64` or `darwin-arm64` as
appropriate. Then rebuild the APK; Gradle's existing `jniLibs.srcDirs = ['lib']`
configuration packages `lib/armeabi/libdrm1.so` automatically.

### Expected result

This does **not** make the VM Android 11-compatible. It only lets the loader
advance past `libdrm1.so`. The next load attempt will likely expose more legacy
private dependencies such as `libsurfaceflinger_client.so`, `libui.so`,
`libskia.so`, `libutils.so`, and `libcutils.so`. Those APIs are substantially
more difficult to shim, especially rendering and surface-management code.
