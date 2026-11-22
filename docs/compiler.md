# Jbed native compiler

The bundled VM compiles Java class files from MIDlet JARs into native Thumb
code during installation. The compiler is itself part of Jbed's precompiled
Java ROM inside `libjbedvm.so`. Android executes the application's DEX code;
Jbed executes its own ROM and the code it generates for installed MIDlets.

The [native size breakdown](native-analysis.md) measures the bundled VM and
ROM. Code generated when a JAR is installed is separate from that image.

## Installation and loading

The native AMS installer performs JAR reading, class verification, reference
resolution, native compilation and suite registration. The Android wrapper
queues installation through that original event path. The compiled output
includes method code, stack maps, class objects and relocation information.

ROM method records and static inspection identify the compilation chain:

| Stage | Method | Address |
|---|---|---:|
| Installer phase | `Installer.installStepPrecompile` | `0x10e210` |
| JAR compilation request | `JarInstaller.precompileJarFile` | `0x149ed8` |
| Shared compilation worker | Internal worker | `0x14a304` |
| Compiler initialization | `Compiler.startCompile` | `0x146cb8` |
| Compilation driver | `Compiler.compile` | `0x1468e0` |
| Translation dispatch | `Compiler.translate` | `0x146828` |
| Class method iteration | `Coder.TranslateClass` | `0x16d8b4` |
| Method translation | `Coder.TranslateMethod` | `0x16d9a4` |

`AmsToolkitBase.precompile` at `0xecc5e` returns 1. The loader at `0xfb470`
therefore selects prepared compiled files. An alternate
`prepareJarCompileToRam` path at `0x14a14c` leads to `compileDirect`, but the
bundled configuration selects installation-time compilation.

The package names identify the TBCC/FastBCC compiler family. The driver has
separate class-level verification and translation loops.
`ArchCodeBlockWriter`, `DirectCodeBlockWriter` and `XipBlockStreamWriter`
provide output strategies. `Compiler.startCompile` creates `FCoder` through
`NewCoder` at `0x13fb38`, which initializes `thumbBit` to 1.

## Emitted instructions

The ELF attributes declare ARMv6 with ARM and Thumb-1 instructions. The Thumb
backend is also visible directly in its emitters:

| Emitter | Address | Encoding or operation |
|---|---:|---|
| `FCoder.GenHWord` | `0x13f774` | Writes one halfword and advances the output address by two bytes |
| `FCoder.GenInstr` | `0x13f7cc` | Packs `(a1 << 8) + (a2 << 6) + (a3 << 3) + a4` |
| `FCoder.CallInstr` | `0x13edd4` | Classic Thumb `BL`, with `0xf000` and `0xf800` halfword bases |
| `FCoder.CallVirtual` | `0x14043c` | Emits `0x4798` (`blx r3`) or `0x47f0` (`blx lr`) |
| `FCoder.EntryCode` | `0x140704` | Emits `PUSH`, stack adjustment and a stack-limit comparison |
| `FCoder.ExitCode` | `0x140dc4` | Emits return sequences including `POP ... pc` |
| `ArchCodeBlockWriter.buildCallInstr` | `0x1839e4` | Builds a Thumb `BL` pair relative to PC+4 and checks its displacement |

The generated code uses 32-bit ARM/Thumb interworking. It runs in compatible
AArch32 environments; it is not AArch64 code. Android compatibility problems
include the host interfaces, JNI stack model and loader policy described in
[compatibility](compatibility.md).

## Executable memory

`OPL_os_getHeapBlock` at `0xa2a40` requests private anonymous memory with read,
write and execute permissions. The original check at `0xa2ab0` tests for zero.
The compatibility adapter replaces that check with one that detects
`MAP_FAILED` while preserving the successful mapping address.

The original `CPL_os_flushCache` at `0xa58c4` is only `bx lr`, and
`OPL_os_intern_flushCache` at `0x2bd438` calls it. The adapter redirects the
latter to `__builtin___clear_cache`. The compiler's `Writer.finishBlock`
passes the generated range's start address and byte count, so publication of
compiled code now reaches instruction-cache synchronization. The patcher also
flushes its own changed instructions.

The allocator still requests writable executable memory. A host that forbids
that mapping would require changes to code allocation and publication.

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

The ROM decoder in `tools/extract_jbed_aot.py` reads the shipped class library;
it does not decode installed suite files.

An ARM64-only port must cover both the fixed VM/ROM and code emitted during
installation. Translating ARM32 execution preserves the existing object and
suite formats. A native ARM64 backend also requires compatible calling
conventions, runtime helpers, GC maps, exception handling and a rebuilt
precompiled class library.
