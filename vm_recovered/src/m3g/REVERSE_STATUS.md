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
2. repeated callback reads into a 1024-byte buffer;
3. `loader_onData` streaming into the Swerve M3G loader;
4. XREF enumeration through `loader_getXREFName`;
5. callback-based loading of external referenced files;
6. `loader_resolveXREF` for each external object;
7. `loader_onDataEnd`;
8. fallback to `swvPNGLoadNamed` when the stream is not accepted as M3G.

`swvLoaderLoadBuffer` (`0x2cb794`) is the memory-buffer equivalent and also
falls back to PNG. Root access is mediated by `swvLoaderGetRootCount` and
`swvLoaderGetRoot`; a temporary root at wrapper `+0x10` is returned first when
present.

## M3G object modules to recover next

1. `Transform` fixed-point matrix layout and `sub_2D3AEC`/`sub_2E06D8` math;
2. `VertexArray`, `VertexBuffer`, `IndexBuffer` storage and range checks;
3. `Appearance`, `Material`, `Texture2D`, `PolygonMode`, `CompositingMode`;
4. `Node`, `Group`, `World`, camera/light traversal;
5. `graphics3d_renderPrimitive`, then `renderNode` and `renderWorld`;
6. M3G loader binary chunks, XREF records and PNG image path;
7. animation controllers, morphing/skinned meshes and ray intersection;
8. VM/JNI lifetime, finalization and target graphics binding.

The JNI surface is already completely inventoried. The remaining work is to
replace opaque `sub_2D...`/`sub_2E...` calls in the Swerve core with typed
recompilable modules, starting with transform/math and loader formats.
