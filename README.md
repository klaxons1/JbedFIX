# Jbed recovered native source

This export contains the current manually reconstructed Jbed native source and
its supporting Android code and tools. It is a working-tree snapshot from
24 November 2026, including the ongoing runtime migration and uncommitted changes.

The C, migrated C++, headers and ARM assembly are preserved together because
the recovered implementation spans all four. This is a source reference snapshot;
the migration is unfinished and the complete tree need not build as a unit.

## Current source

| Directory | Contents |
|---|---|
| `native/compiler/` | Class-file reader, verifier, bytecode lowering, Thumb code generation, compiled-image formats, reflection tables and host compiler/ROM tools |
| `native/compiler/vm/` | Recovered memory, garbage collection, stack maps, exceptions, monitors, scheduling, type and string operations |
| `native/runtime/` | ARM32 execution and assembly bridge, native bindings, boot image loading, class initialization, reflection, arrays, fields, roots, scheduling, isolates, bundles and runtime integration |
| `native/platform/` | VM and OS services, AMS, MIDP display/graphics, media, PIM, DRM, push messaging, files, sockets, compression and image codecs |
| `native/platform/android/` | Reconstructed Android JNI and platform integration |
| `native/platform/jpeg6b/` | Included JPEG decoder dependency and its original README/license terms |
| `native/swerve/` | M3G scene objects, loading, animation, math, software rendering, raw API and system support; includes the C-to-C++ migration |
| `native/swerve/java/midp/src/share/native/` | Jbed KNI adapters for the M3G Java interface |
| `native/compat/` | Compatibility libraries and JNI/stack bridges for running the original ARM32 VM |
| `native/android/` | Separate Android runner for the source runtime, JNI entry points, graphics bridge and diagnostic probe |
| `native/rom/` | Recovered Java runtime JAR, runtime properties and Java boot-subset tooling used as ROM-generation inputs |
| `app/` | Reconstructed Android application, resources and Gradle setup for the original-VM compatibility path |
| `tools/` | ROM inspection, JVM bytecode recovery, native-symbol extraction, IDA analysis and device-log tools |
| `tests/`, `native/compiler/tests/`, `native/compat/tests/` | Existing recovery checks and probes |
| `docs/` | Compiler, native analysis, build, compatibility and Swerve rendering documentation |

The handwritten `native/compiler/tests/rom_format_check.c` was also recovered
from the workspace build directory. It checks ROM footer serialization and
relocation; it is included in CTest when `JBED_BUILD_HOST_TESTS=ON`.

GitHub Actions builds the source-runtime ARM32 APK and runs the self-contained
host tests. Download `jbed-source-debug-arm32` from the **Build source APK** run.
See [CI and local reproduction](docs/building.md#github-actions) for scope and commands.

## Build tools and inputs

CMake files, the Gradle wrapper, Android Gradle projects and existing test helpers
are included. Commands below are relative to the extracted directory. Install
SDKs and dependencies separately, exposing them through standard environment
variables and the build tools' normal search paths.

The host compiler and ROM builder require CMake, a C compiler, zlib and libzip:

```sh
cmake -S native/compiler -B build/compiler -DJBED_BUILD_HOST_COMPILER=ON
cmake --build build/compiler --target jbedc jbedrom
```

The broader native project also uses C++20 and libpng. Its Android configuration
can fetch the pinned libpng source through CMake. The standalone Android source
runner uses JDK 17, Android SDK 35, NDK 28.2.13676358 and CMake 3.22.1:

```sh
./gradlew -p native/android :app:assembleDebug
```

`native/android/rom.gradle` describes generation of the boot image from the
included `native/rom/runtime.jar`, `native/runtime/native.bindings`, runtime
properties and Java probe. Generated boot byte arrays are omitted; the generator
and its inputs are retained. See `docs/building.md` for the existing build flow.

The original VM binary, annotated IDA databases, comparison APKs, original
Android smali, downloaded build dependencies, compiled outputs, caches and logs
are omitted. The original-VM application and binary-comparison tools expect
`app/src/main/jniLibs/armeabi/libjbedvm.so` to be supplied separately. IDA analysis
scripts additionally need the annotated database described in
`research/README.md`. Documentation about those inputs and prior observations
is retained for context.

Machine-specific host paths have been removed from the export. Relative project
paths, environment-variable references and Android runtime filesystem paths
remain where they describe actual program behavior. IDA tooling is referred to
as the IDA CLI. Copyright and license notices in included sources are retained.
