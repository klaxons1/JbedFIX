# Research inputs

This source export retains these notes as context. The original smali, binary
reference inputs and annotated IDA database described below are not included.

This directory holds the original Android smali and research notes in Git.
Binary references and the annotated IDA database are kept locally here and
ignored by Git. The Android build consumes the tracked original VM from
`app/src/main/jniLibs/armeabi/libjbedvm.so`; it does not package this directory.

| Path | Content |
|---|---|
| `android-apk/smali/` | Original Android-side Dalvik disassembly used to check reconstructed Java methods |
| `jbed/libjbedvm.so.i64` | Local annotated IDA database: recovered ROM names, corrected regions and subsystem comments |
| `android-legacy/libsurfaceflinger_client.so` | Local legacy Android Surface library used to inspect the imported ABI |
| `packages/appteka-2.3.1.apk` | Local comparison package labelled Java 2.3.1 |
| `packages/malavida-2.3.1.apk` | Local comparison package labelled Jbed 2.3.1 |

The local files are absent from a fresh clone. Preserve the annotated database
when moving the research workspace: creating a new database from the VM does
not restore its manual annotations.

## Build identity

The application's assets identify customer `HTC`, MIDP 2.0, CLDC 1.1 and an
Android 2.3 user agent. `JbedConfig` gives 2011-07-13 and `build.properties`
gives package revision 195487. The native library separately embeds
`vm.buildID=20110126`.

The separately supplied Android build-194731 native library is byte-for-byte
identical to the bundled VM. Build 170767 embeds `vm.buildID=20090702` and has different Android
imports. The Xperia Windows Mobile reference identifies FastDAC and
`20100329`; it is a different platform/compiler configuration.

## Redistributed Android packages

The [Appteka listing](https://appteka.store/apps/38fr182771) dates its upload to
July 2024. The saved package is revision 194731 and contains the same 2011
native VM. Its Android DEX differs from the local build-194731 reference, and
its configuration changes include a 32 MiB heap and font sizes. The upload
date identifies a redistribution, not a new compiler or VM. It does not carry
this project's compatibility libraries or local installer implementation.

The [Malavida package](https://www.malavida.com/en/soft/jbed/android/) is also
revision 194731 but contains no native `.so` library. Neither inspected
download supplies a newer Android VM.
