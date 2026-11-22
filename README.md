# JbedFIX

JbedFIX runs Java ME applications with a recovered Esmertec Jbed runtime on
Android. It combines the original 2011 ARM32 VM and precompiled Java class
library with a reconstructed Android application and native compatibility
adapters. Jbed's own installer verifies JARs and compiles their classes into
Thumb machine code.

The display bridge presents the VM's framebuffer through `ANativeWindow`.
Android Paint/Canvas supplies text, and BitmapFactory supplies the legacy PNG
adapter. On-screen direction keys, a numeric keypad and selectable virtual
screen sizes make phone games usable on touchscreens.

## Build and use

Install the dependencies in the [build guide](docs/building.md), then run:

```sh
./gradlew :app:assembleDebug
```

The APK is `app/build/outputs/apk/debug/app-debug.apk`. It requires ARM32 app
execution, either natively or through a compatible Android native bridge.
The package currently targets API 22 to load the original VM's text
relocations. Read the [tested configurations and platform
constraints](docs/compatibility.md) before choosing a device.

Open a MIDlet JAR with JbedFIX, complete the native installation, and select
the installed application. In a running game, tap **Menu** or press Android
**Back**. Choose **Resume**, **Controls**, **Screen size**, or **Exit game**.
**Exit game** asks the MIDlet to stop and returns to the application list
after its native exit completes. **Controls** selects the direction pad,
numeric keypad or hidden keypad; the Menu button remains available.
The default virtual screen is 240 × 320; smaller presets suit older phones.
The game area preserves the selected aspect ratio, and touch coordinates are
mapped back into the virtual screen. Some games cache their dimensions at
startup, so exit and launch the game again after changing its screen size.

## Documentation

- [Building](docs/building.md): toolchain, APK output, tests and inspection tools.
- [Compatibility](docs/compatibility.md): verified behavior, runtime adapters and remaining constraints.
- [Compiler](docs/compiler.md): native installation, Thumb emission and executable memory.
- [Native analysis](docs/native-analysis.md): binary components, ROM metadata and IDA analysis.
- [Research inputs](research/README.md): original disassembly and comparison packages.

## Repository layout

| Path | Contents |
|---|---|
| `app/src/main/` | Android sources, resources, assets and the original VM in `jniLibs/armeabi/` |
| `native/compat/` | Native adapters, JNI stack bridge and PNG contract tests |
| `tools/` | Static ROM/symbol inspection and device log collection |
| `research/` | Original smali and research notes; local binary inputs and IDA databases are ignored |
| `docs/` | Maintained documentation |
| `app/build/`, `build/`, `logs/` | Ignored generated output |
