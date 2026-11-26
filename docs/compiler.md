# Jbed native compiler

The bundled VM compiles Java class files from MIDlet JARs into native Thumb
code during installation. The compiler is itself part of Jbed's precompiled
Java ROM inside `libjbedvm.so`. Android executes the application's DEX code;
Jbed executes its own ROM and the code it generates for installed MIDlets.

The [native size breakdown](native-analysis.md) measures the bundled VM and
ROM. Code generated when a JAR is installed is separate from that image.

## Reconstructed compiler

`jbedc` compiles a MIDlet JAR to Jbed’s original `.obj` suite format. Building
the host tool requires libzip and zlib. The APK runs the original VM.

```sh
cmake -S native/compiler -B build/compiler -DJBED_BUILD_HOST_COMPILER=ON
cmake --build build/compiler --target jbedc
build/compiler/jbedc app/src/main/jniLibs/armeabi/libjbedvm.so game.jar game.obj
```

For offline analysis the default ROM load address is zero. To reproduce an
installed suite, use its process’s ROM load address (`--rom-base`), initial
code padding (`--prefix`) and identity-hash generator state (`--hash-state`).
The address affects calls and literals, the padding affects block layout, and
the hash state affects serialized class headers.

Differential checks use Unicorn to execute the corresponding original Thumb.

```sh
cmake --build build/compiler --target jbedcompiler_oracle
python3 native/compiler/tests/differential.py build/compiler/jbedcompiler_oracle
```

## Installation and loading

The native AMS installer performs JAR reading, class verification, reference
resolution, native compilation and suite registration. The Android wrapper
queues installation through that original event path. The compiled output
includes method code, stack maps, class objects and relocation information.

This build selects installation-time compilation into prepared files.
`AmsToolkitBase.precompile` at `0xecc5e` returns 1, and the loader at `0xfb470`
selects that path. A separate `prepareJarCompileToRam` path exists at `0x14a14c`.

The verifier consumes CLDC `StackMap` attributes supplied in class files. It
checks their local and operand types against the bytecode, tracks uninitialized
objects and validates branch/exception targets. It is not an offline stack-map
generator. This build rejects `jsr`, `ret` and `invokedynamic`. The recovered
paths use this verifier and backend for ahead-of-time compilation, including
direct-to-memory output; no separate profiling-driven JIT has been identified.

## Execution requirements

The bundled backend emits Thumb-1 with ARM/Thumb interworking for AArch32.
An ARM64 port must handle both the fixed ROM and newly compiled MIDlets,
including object layouts, calling conventions, GC maps and exception handling.

The original allocator requests writable executable memory. Hosts forbidding
that mapping need a different allocation/publication strategy. The compatibility
adapter repairs the original allocation-failure check and no-op cache flush.

## Compiled-suite format

Installed suites use Jbed's proprietary `.obj` representation. The original
writer embedded absolute ROM addresses and omitted relocation records for
some static pointer literals. The adapter routes those pointers through the
existing static relocation chains, stores non-null destinations relative to
the VM image base, and adds the current base when loading. ROM class, string,
object-header and code references use the relocation-aware writer methods;
null pointers remain ordinary zero words.

The compiled-file header's third word is now a zero marker for this portable
format. The existing magic, VM fingerprint and version checks remain active.
Older files cannot be converted by changing that word alone because they lack
the pointer relocation records; see the [migration requirement](compatibility.md#remaining-constraints).

## ROM bytecode recovery

```sh
python3 tools/recover_jbed_bytecode.py --output research/jbed/recovered-rom.jar
```

Requires Python and Capstone. The output is input for existing JVM decompilers.
Unrecovered bodies are represented by native declarations carrying
`JbedUnavailableBody`; these are excluded from recovery counts. Method-span
sizes include embedded literals. Use `--help` for selectors and output options.
