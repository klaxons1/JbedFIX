#!/usr/bin/env bash
# Builds the ARM32 compatibility shim used by libjbedvm.so.
set -euo pipefail

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  echo "ANDROID_NDK_HOME must point to an installed Android NDK." >&2
  exit 1
fi

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) host_tag=linux-x86_64 ;;
  Darwin-arm64) host_tag=darwin-arm64 ;;
  Darwin-x86_64) host_tag=darwin-x86_64 ;;
  *) echo "Unsupported NDK host: $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

clang="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$host_tag/bin/clang"
test -x "$clang"
mkdir -p lib/armeabi

"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libdrm1.so \
  -o lib/armeabi/libdrm1.so native_compat/libdrm1.c

# libutils is private on Android 11. This shim only supplies the two RefBase
# retain/release symbols imported by this particular Jbed VM.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -nostdlib \
  -Wl,-soname,libutils.so \
  -o lib/armeabi/libutils.so native_compat/libutils_compat.S

# The VM imports a small pre-Honeycomb Skia C++ ABI. This first-stage bridge
# provides safe symbol-compatible operations while the modern rendering bridge
# is developed separately.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libskia.so \
  -o lib/armeabi/libskia.so native_compat/libskia_compat.c

# libjbedvm imports platform libpng symbols without a DT_NEEDED entry. Build
# it first and make it a dependency of libcutils, which *is* in Jbed's linker
# dependency group; System.loadLibrary alone loads it RTLD_LOCAL on Android.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libpng.so \
  -o lib/armeabi/libpng.so native_compat/libpng_compat.c

# ART JNI local-reference lifetime bridge for the original VM.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libjbedcompat.so \
  -o lib/armeabi/libjbedcompat.so native_compat/jbed_jni_lifetime_hook.c -ldl -llog

# This VM has no unresolved libcutils symbols; it still carries the old
# DT_NEEDED entry. Its libpng dependency makes PNG symbols available while
# resolving libjbedvm.so.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libcutils.so -Wl,--no-as-needed \
  -Llib/armeabi -l:libpng.so \
  -o lib/armeabi/libcutils.so native_compat/empty_legacy_library.c

# Software compatibility path for the pre-Honeycomb Surface API used by Jbed.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libui.so \
  -o lib/armeabi/libui.so native_compat/libui_compat.c
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libsurfaceflinger_client.so \
  -o lib/armeabi/libsurfaceflinger_client.so native_compat/libsurface_compat.c

echo "Built Jbed native compatibility libraries"
