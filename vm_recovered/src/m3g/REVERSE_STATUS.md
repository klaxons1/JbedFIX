# M3G reverse status

Дата: 2026-10-08. Источник: `lib/armeabi/libjbedvm.so` и
`docs/libjbedvm.so.c`.

## Inventory

`m3g_symbols.csv` содержит 703 M3G/Swerve-related exported functions:

| layer | count | address range | role |
|---|---:|---|---|
| `jni-adapter` | 351 | `0x301a7d..0x308fc1` | Java M3G/KNI entrypoints |
| `vm-glue` | 73 | `0x2caac4..0x30a5b1` | handle, arrays, graphics target, loader/PNG glue |
| `swerve-core` | 279 | `0x2cee94..0x2f9d90` | native M3G object/scene/math/renderer API |

The symbol inventory is generated reproducibly:

```text
python3 tools/extract_m3g_symbols.py \
    lib/armeabi/libjbedvm.so \
    --csv vm_recovered/src/m3g/m3g_symbols.csv
```

## Recovered call boundary

A Java `Graphics3D.renderWorld(world)` call reaches the native core as:

```text
JbedKNI_VerifyObject(graphicsPeer, 79)
  -> SWV_GetSwerveHandleFromPeer(peer, 1)
JbedKNI_VerifyObject(worldPeer, 111)
  -> SWV_GetSwerveHandleFromPeer(peer, 0)
SWV_BindTargetCritical(graphicsPeer, graphicsHandle)
  -> graphics3d_renderWorld(graphicsHandle, worldHandle)
```

`renderNode` adds a node and transform handle. `renderPrimitive` adds vertex
buffer, index buffer, appearance, transform and an integer scope/flag argument.
A failed core call is converted to `ThrowSwerveAPIException` by the JNI layer.
This proves that rendering is implemented by the Swerve core, not by Java
wrapper classes.

## Handle and object layout

The recovered core methods consistently normalize a public handle with:

```c
if (handle)
    handle -= 4;
```

The public Java peer therefore stores/receives `object_base + 4`. The proven
fields of the common Object3D base are:

```text
base + 0x00  opaque vtable/type pointer
base + 0x04  reference count used by SWV glue
base + 0x08  opaque flags/type data
base + 0x0c  Object3D.userID
base + 0x10  animation-track storage pointer
base + 0x14  user-parameter storage pointer
```

The first normalized source slice is
`m3g_object3d_fields.c`, recovered from `0x2f67a8` and `0x2f67bc` and verified
with a host C compiler.

## Native loader path

The native loader wrapper is a 24-byte object created by `swvLoaderCreate`
(`0x2cb11c`):

```text
wrapper + 0x00  Swerve loader handle
wrapper + 0x04  read/open callback
wrapper + 0x08  callback/context value
wrapper + 0x0c  conversion/close callback
wrapper + 0x10  PNG/image fallback handle
wrapper + 0x14  completion/extension state
```

`swvLoaderLoadNamed` (`0x2cb50c`) performs:

1. `loader_onDataStart`;
2. repeated callback reads into a 1024-byte buffer, with the requested name
   only on the first read and `NULL` thereafter;
3. `loader_onData` streaming into the Swerve M3G loader;
4. XREF enumeration through `loader_getXREFName` at index zero. Resolving an
   entry mutates the pending list, so the next entry is again index zero;
5. byte names widened to zero-terminated UTF-16 names;
6. recursive external loading with the current core extension state;
7. `loader_resolveXREF` followed by release of the temporary external handle;
8. `loader_onDataEnd` and completion state;
9. fallback to `swvPNGLoadNamed` when the stream is not accepted as M3G.

`swvLoaderLoadBuffer` (`0x2cb794`) is the memory-buffer equivalent. It keeps
`-11` as the core's end marker until converting it to `-1` immediately before
`loader_onDataEnd`; it also falls back to PNG. Root access is mediated by
`swvLoaderGetRootCount` and `swvLoaderGetRoot`; a temporary root at wrapper
`+0x10` is returned as the sole root when present.

The normalized, host-compilable implementation is
`m3g_loader_stream.c/.h`. It keeps the proprietary core as typed callbacks and
therefore does not incorrectly expose internal ARM calls as ELF symbols.
`tests/m3g_loader_stream_test.c` covers named streaming, XREF recursion,
`-11` buffer completion, PNG fallback, roots and lifetime.

## Parallel recovery tracks started

The direct-field pass now covers all major object families in one normalized
module, `m3g_recovered_fields.c`:

- scene graph: `Node.scope`, picking/rendering flags, alpha factor, World
  camera/background slots;
- rendering resources: Mesh and MorphingMesh counts, Graphics3D dimensions,
  pitch, depth range and depth-buffer flag;
- materials/textures: Material shininess/color tracking, Fog density/mode,
  Texture2D blend/wrap/filter fields, Background color;
- lights: mode, color, intensity, spot parameters and attenuation;
- animation: KeyframeSequence duration, repeat mode, dimensions,
  interpolation and valid range;
- sprites: crop rectangle and scaled flag.

The transform track recovered the exact 68-byte matrix state at
`Transform + 0x0c`: sixteen IEEE-754 single-precision words plus a state word.
`sub_2D8174` initializes diagonal elements to `0x3f800000` and state to `63`.
This is now implemented in `m3g_transform_layout.c`; it does not guess a
fixed-point scale.

The renderer and loader tracks are also started at their real core boundaries:
`graphics3d_*`, `swvLoader*`, `loader_onData*`, XREF resolution, and PNG
fallback are listed with original addresses. Their complex allocation,
reference-count and callback internals remain opaque until their callee graphs
are typed.

## M3G object modules to recover next

1. `Transform` remaining matrix operations and fixed-point helpers;
2. `VertexArray`, `VertexBuffer`, `IndexBuffer` storage and range checks;
3. `Appearance`, `Material`, `Texture2D`, `PolygonMode`, `CompositingMode`;
4. `Node`, `Group`, `World`, camera/light traversal;
5. `graphics3d_renderPrimitive`, then `renderNode` and `renderWorld`;
6. M3G loader binary chunks, XREF records and PNG image path;
7. animation controllers, morphing/skinned meshes and ray intersection;
8. VM/JNI lifetime, finalization and target graphics binding.

The JNI surface is already completely inventoried. The remaining work is to
replace opaque `sub_2D...`/`sub_2E...` calls in the Swerve core with typed
recompilable modules across all tracks, rather than treating the JNI surface as
the engine itself.
