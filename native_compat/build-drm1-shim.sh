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

"$clang" --target=armv7a-linux-androideabi21 -fPIC -shared -O2 \
  -Wl,-soname,libdrm1.so \
  -o lib/armeabi/libdrm1.so native_compat/libdrm1.c

# libutils is private on Android 11. This shim only supplies the two RefBase
# retain/release symbols imported by this particular Jbed VM.
"$clang" --target=armv7a-linux-androideabi21 -fPIC -shared -nostdlib \
  -Wl,-soname,libutils.so \
  -o lib/armeabi/libutils.so native_compat/libutils_compat.S

echo "Built lib/armeabi/libdrm1.so and lib/armeabi/libutils.so"
