# Native VM analysis

The local, Git-ignored IDA database is `research/jbed/libjbedvm.so.i64`, created from the original
`app/src/main/jniLibs/armeabi/libjbedvm.so` using the IDA CLI. It contains corrected code/data
boundaries, ARM mode repairs, subsystem comments, and more than 9,600 method labels recovered from ROM metadata. Existing
exported names are preserved. The image identity and comparison packages are
described in [research inputs](../research/README.md).

## Size accounting

The saved static classification counts **1,351,734 instruction bytes
(1.289 MiB)**, including 556 bytes of ELF import stubs. Capstone independently
decodes these bytes into 551,772 ARM/Thumb instructions, expanding IDA's folded
instruction macros. Component sizes below group the recorded ROM methods with
associated native adapters; native boundaries are inferred from exported
symbol families and layout.

The totals below measure the saved classification. A later ISA audit marked
suspicious ARM decodes at `0xf1034`, `0x10bab4` and `0x10e520` inside Thumb
regions for review; those annotations do not change the totals yet. Treat
1.29 MiB as the current code-size estimate, not a completely resolved
instruction inventory.

The whole ELF is 3,263,608 bytes (3.11 MiB):

| File content | Bytes |
|---|---:|
| Classified machine instructions, including PLT | 1,351,734 |
| Non-instruction content inside `.text` | 1,218,438 |
| Dynamic/PLT relocation tables | 547,232 |
| Other sections, ELF metadata and alignment | 146,204 |
| **Total** | **3,263,608** |

The `.text` section is 2,569,616 bytes, but contains the ROM header, class and
method descriptors, name/string tables, inline literals, and exception tables.
Instruction bytes are counted once by address, with embedded data excluded:

- `Jbed_start` at `0xab328–0xab428` is a **256-byte ROM header**, despite its
  ELF function tag.
- `0x1b938c–0x2bd1a8` contains ROM metadata.
- Relocation sites of type `R_ARM_RELATIVE` contain pointer words.
- 936 validated trailing exception tables contain 2,490 records and occupy
  **43,584 bytes**. These tables are excluded from the recorded method sizes.
- `Float.floatNative`, `0xe338c–0xe5028`, contains exactly 7,300 bytes of ARM
  instructions and 24 literal bytes. Its 26-entry branch vector and all helper
  paths were followed independently; spurious Thumb mode changes were removed.
- Installer catch handlers at `0x10f670–0x10f69e` and the precompile block
  beginning at `0x10e524` are instructions, confirmed by branch/catch-table
  references and independent Thumb decoding.

Physical accounting is 42,688 instruction bytes before the ROM header,
987,798 in named ROM methods, 320,692 in native code after the ROM metadata,
and 556 in PLT stubs. All counted code is assigned below. Package ownership
comes from method records; native adapters are grouped using their exported
families and contiguous implementation regions. These groups include both
Java-compiled code and native support where applicable:

| Logical component | Instruction bytes | KiB |
|---|---:|---:|
| M3G / 3D, all layers | 272,538 | 266.2 |
| MIDP UI / 2D / widgets / themes | 250,160 | 244.3 |
| AMS / installer / launcher / MIDlet lifecycle | 230,468 | 225.1 |
| Security / SSL / crypto / DRM | 94,964 | 92.7 |
| Compiler / verifier / backends | 85,594 | 83.6 |
| Network / files / stream I/O | 77,264 | 75.5 |
| VM runtime / OS / scheduling | 75,774 | 74.0 |
| PIM / contacts / calendars | 73,372 | 71.7 |
| Media | 42,788 | 41.8 |
| Core `java.lang`, `java.util`, `java.io` | 40,196 | 39.3 |
| JPEG decoder / adapter | 27,748 | 27.1 |
| RMS record stores | 18,720 | 18.3 |
| General utilities / ZIP / JAR | 16,352 | 16.0 |
| Class metadata / reflection / loading | 15,794 | 15.4 |
| Android JNI / graphics glue | 14,990 | 14.6 |
| Push / alarms / SMS | 10,630 | 10.4 |
| GIF decoder | 2,372 | 2.3 |
| Other Java integration | 1,454 | 1.4 |
| ELF import stubs | 556 | 0.5 |
| **Total** | **1,351,734** | **1,320.1** |

M3G breaks down further into 204,744 bytes of Swerve engine/private runtime
helpers (`0x2ccb78–0x301a7c`), 23,206 bytes in its 351 KNI adapters
(`0x301a7c–0x308fd8`), 7,824 bytes of loader/platform/PNG glue
(`0x2caac4–0x2ccb78`), 4,718 bytes of VM/array/graphics glue
(`0x308fd8–0x30a5e8`), and 32,046 bytes in Java M3G classes. These are
instruction counts within the stated address spans. The Swerve engine includes
memory, arithmetic and other support routines. JPEG excludes the async-waiter
insertion at `0x30f2e0–0x30f378`.

Swerve renders in software into the MIDP RGB565 bitmap. `SWV_BindTargetGraphics`
obtains its pixels and stride through `swvKNIGraphicsGetBackBufferData`;
releasing a screen target marks it dirty for the existing framebuffer
presenter. The ELF imports no EGL or GLES functions. The exported
`Java_javax_microedition_m3g_*` functions use Jbed KNI, not Android ART JNI.
PNG resources opened by the M3G `Loader`, including external texture
references in `.m3g` files, pass through `SWV_Image2D_createPNG` (`0x309c88`)
and `swvPNGLoadBuffer` (`0x2cbc78`). The compatibility PNG adapter decodes those
inputs with BitmapFactory and supplies straight RGBA8 rows. Constructing an
`Image2D` from a MIDP `Image` instead copies decoded pixels through `getRGB`
and `SWV_Image2D_setRGB`.

`Graphics3D.getProperties` and the native capability switch at `0x2d51a8`
report maximum viewport, texture and sprite-crop dimensions of 1024, two
texture units, two transforms per vertex and 256 lights. Perspective
correction and local-camera lighting are supported; antialiasing, true color,
dithering and mipmapping report unsupported. M3G benchmark results therefore
describe this software renderer at the selected virtual resolution.

The compiler group is `com/jbed/tbcc`, `JBedFastCoder`, and `JBedFCoderThumb`.
`com/jbed/reflect` is listed separately, as are AMS installation orchestration
and ZIP/JAR helpers. Security includes the recognizable IAIK packages. zlib,
libpng, Skia and the legacy Android display/DRM libraries remain external
dependencies; only their adapters are counted here.

The GIF implementation occupies `0x2c9bac–0x2ca53c` in the native portion:
1,024 instruction bytes for LZW/scanline decoding, 288 for image-descriptor
and local-palette handling, and 1,060 for `GIFdecodeImage` at `0x2ca0fc`.
`decodeImageFromData` dispatches GIF input to it alongside PNG and JPEG.
It accepts GIF87a/GIF89a, handles global/local palettes, transparent palette
indices and interlaced rows. The decoder uses a 4,096-entry LZW dictionary.
After decoding the first image descriptor it returns through cleanup; this
entry point loads a static image rather than playing an animation. IDA labels
the helpers `gif_decode_lzw_scanlines` and `gif_decode_image_descriptor`.

## ROM metadata and method ownership

`tools/extract_jbed_aot.py` resolves the ROM class index at `0x25f548`:
1,005 class-index records, including 70 array descriptors, and 10,678 method
records. Of these, 9,728 have unique, non-overlapping code spans within
`0xab428–0x1b938a`; 246 have addresses with no recorded size, and 704 have
neither.

Recorded method spans total **1,062,104 bytes**, including inline literals;
their classified instructions total **987,798 bytes**. The native/library
remainder is 363,936 instruction bytes, including PLT. The extractor's
`Image.rom_classes()` exposes these ownership records; its `--components`
option reports package **method-span sizes**, not IDA instruction sizes:

```sh
python3 tools/extract_jbed_aot.py app/src/main/jniLibs/armeabi/libjbedvm.so --components
```

To recalculate the instruction/component table from the saved IDA analysis,
open `research/jbed/libjbedvm.so.i64` through the IDA CLI and execute
`tools/measure_jbed_code.py` with the export root as the working directory.

`tools/measure_jbed_code.py` preserves the package grouping and native-region
boundaries used above. It reads the database's corrected instruction flags;
use the annotated database, since a fresh import misclassifies embedded data.

## Reverse-engineering difficulty

The ELF retains 1,663 defined function-tagged symbol entries and 164 named
imports, but no ordinary symbol table or DWARF. Use ROM records for Java method
ownership: some IDA shared tails cross those boundaries.

No positive evidence of packing, encrypted names, or deliberate control-flow
obfuscation was found in the inspected regions. Descriptive exports, Java ROM
names, diagnostic strings, relocations, unwind records and Swerve C++ RTTI
remain. The inspected initializer is ordinary setup; `JNI_OnLoad` obtains JNI
1.4 and registers 35 methods across 13 Android bridge classes.

See [compiler analysis](compiler.md) for instruction emission and compilation
timing, and [compatibility](compatibility.md) for the Android repair path.
