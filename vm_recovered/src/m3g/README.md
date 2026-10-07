# JSR-184 / M3G reverse engineering

## Binary layers

`libjbedvm.so` contains three distinguishable layers:

1. **KNI/JNI adapters** at approximately `0x301xxx..0x30xxxx`.
   Functions are named `Java_javax_microedition_m3g_*`. They verify Java peer
   objects through `JbedKNI_VerifyObject`, convert peers with
   `SWV_GetSwerveHandleFromPeer`, call the native core, and translate failure
   into `ThrowSwerveAPIException`.
2. **VM/Swerve glue** at approximately `0x308fd9..0x30a579`.
   `SWV_Constructor_HandleReturn`, `SWV_Finalize`, array accessors, handle
   refcounting and target graphics binding live here.
3. **Swerve M3G core**. Loader/decompression/PNG support is around
   `0x2caa..0x2cc`; object and scene operations are around
   `0x2cea..0x2f9`; graphics operations are around `0x2f3bd8..0x2f4550`.

The exported core symbol names are retained in the ELF and are recorded in
`m3g_symbols.csv`. This is much more useful than treating the whole M3G block
as anonymous ARM code.

## First recovered facts

- A public Java peer is an external handle pointing four bytes after the
  internal Swerve object header. Core methods normalize it with
  `if (handle) handle -= 4`.
- The internal object header has a reference count at `base + 4`.
- `Object3D.userID` is at `base + 12`; this is proven by
  `object3d_getUserID` and `object3d_setUserID`.
- `Object3D` animation-track storage is referenced at `base + 16`, and user
  parameter storage at `base + 20` in the recovered accessors.
- JNI `Graphics3D.renderWorld` does: verify Graphics3D peer, verify World peer,
  bind the target as critical, then call
  `graphics3d_renderWorld(graphics_handle, world_handle)`.
- JNI `Graphics3D.renderNode` has the same critical target binding and calls
  `graphics3d_renderNode(graphics_handle, node_handle, transform_handle)`.
- JNI `Graphics3D.renderPrimitive` passes graphics, vertex buffer, index
  buffer, appearance, transform and scope/flags to the core.
- `Loader` is not a Java-only parser: `swvLoaderCreate`, `swvLoaderLoadNamed`,
  `swvLoaderLoadBuffer`, `swvLoaderGetRoot` and the `loader_onData*` callbacks
  form a native streaming loader. `swvPNGLoadBuffer` is a separate image path.
- Transform operations use 32-bit fixed-point conversion helpers
  (`sub_2D3AEC`, `sub_2CDF00`, `sub_2E06D8`, `sub_2E14F0`) rather than ordinary
  host `float` arithmetic at every field access. The fixed-point scale and
  matrix layout are the next target of the reverse.

## Source status

`m3g_object3d_fields.c` is the first normalized, host-compilable slice of the
recovered core. `m3g_loader_stream.c` now provides the normalized loader
boundary with typed callbacks, XREF recursion and PNG fallback. The source
still intentionally does not pretend to be the complete engine: object
allocation, GC/refcount release, rendering and fixed-point math are separate
modules still being recovered.

The raw Hex-Rays bodies remain in `docs/libjbedvm.so.c`; every normalized source
file here records its original addresses and confidence level.
