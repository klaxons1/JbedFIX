/*
 * Some pre-Android-11 DT_NEEDED entries are retained by libjbedvm.so even
 * though this build has no unresolved symbols from them. A non-empty source
 * creates a valid ELF shared object with the requested SONAME.
 */
int jbed_legacy_compat_marker(void) {
    return 0;
}
