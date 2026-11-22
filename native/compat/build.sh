#!/usr/bin/env bash
# Builds the ARM32 compatibility libraries into an output directory.
set -euo pipefail

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  echo "ANDROID_NDK_HOME must point to an installed Android NDK." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
output_dir="${1:-$repo_root/build/native-compat/armeabi}"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) host_tags=(linux-x86_64) ;;
  Darwin-arm64) host_tags=(darwin-arm64 darwin-x86_64) ;;
  Darwin-x86_64) host_tags=(darwin-x86_64) ;;
  *) echo "Unsupported NDK host: $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

clang=""
for host_tag in "${host_tags[@]}"; do
  candidate="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$host_tag/bin/clang"
  if [[ -x "$candidate" ]]; then
    clang="$candidate"
    break
  fi
done
if [[ -z "$clang" ]]; then
  echo "No compatible Clang found in ANDROID_NDK_HOME=$ANDROID_NDK_HOME" >&2
  exit 1
fi
mkdir -p "$output_dir"

"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libdrm1.so \
  -o "$output_dir/libdrm1.so" "$script_dir/libdrm1.c"

# libutils is private on Android 11. This shim only supplies the two RefBase
# retain/release symbols imported by this particular Jbed VM.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -nostdlib \
  -Wl,-soname,libutils.so \
  -o "$output_dir/libutils.so" "$script_dir/libutils_compat.S"

# The VM imports a small pre-Honeycomb Skia C++ ABI. This first-stage bridge
# supplies the imported symbols while the modern rendering bridge
# is developed separately.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libskia.so \
  -o "$output_dir/libskia.so" "$script_dir/libskia_compat.c" -ljnigraphics -llog -ldl

# libjbedvm imports platform libpng symbols without a DT_NEEDED entry. Build
# it first and make it a dependency of libcutils, which *is* in Jbed's linker
# dependency group; System.loadLibrary alone loads it RTLD_LOCAL on Android.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libpng.so \
  -o "$output_dir/libpng.so" "$script_dir/libpng_compat.c" -ljnigraphics -llog -ldl

# ART JNI local-reference lifetime bridge for the original VM.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libjbedcompat.so \
  -o "$output_dir/libjbedcompat.so" "$script_dir/jbed_runtime.c" \
  "$script_dir/jbed_host_jni.c" "$script_dir/jbed_host_stack.S" -ldl -llog

# This VM has no unresolved libcutils symbols; it still carries the old
# DT_NEEDED entry. Its libpng dependency makes PNG symbols available while
# resolving libjbedvm.so.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libcutils.so -Wl,--no-as-needed \
  -L"$output_dir" -l:libpng.so \
  -o "$output_dir/libcutils.so" "$script_dir/empty_legacy_library.c"

# Software compatibility path for the pre-Honeycomb Surface API used by Jbed.
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libui.so \
  -o "$output_dir/libui.so" "$script_dir/libui_compat.c"
"$clang" --target=armv7a-linux-androideabi19 -fPIC -shared -O2 \
  -Wl,-soname,libsurfaceflinger_client.so \
  -o "$output_dir/libsurfaceflinger_client.so" "$script_dir/libsurface_compat.c" -landroid -llog

echo "Built Jbed native compatibility libraries in $output_dir"
