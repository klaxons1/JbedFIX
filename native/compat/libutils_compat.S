/*
 * Android 2.x-era libutils compatibility shim.
 *
 * libjbedvm.so imports only RefBase::incStrong/decStrong from libutils.so.
 * On Android 11 libutils is a private framework library and is unavailable in
 * an app linker namespace. The VM's old surface code owns these references;
 * retain/release are made no-ops here so they cannot unload an object behind
 * the compatibility layer. This intentionally leaks those legacy references.
 */
.syntax unified
.thumb

.global _ZNK7android7RefBase9incStrongEPKv
.type _ZNK7android7RefBase9incStrongEPKv, %function
.thumb_func
_ZNK7android7RefBase9incStrongEPKv:
    bx lr

.global _ZNK7android7RefBase9decStrongEPKv
.type _ZNK7android7RefBase9decStrongEPKv, %function
.thumb_func
_ZNK7android7RefBase9decStrongEPKv:
    bx lr
