# Host tests

The loader state-machine test does not link the proprietary ARM core. It uses
fake typed callbacks to exercise the recovered control flow:

- named reads use a 1024-byte buffer and switch from the requested name to
  `NULL` on the second read;
- a pending XREF is repeatedly queried at index zero, loaded externally and
  resolved, including the third-callback UTF-16 name conversion;
- the buffer path converts `-11` to successful completion before
  `on_data_end`;
- a failed M3G start takes the temporary PNG root fallback;
- core root count/access and wrapper lifetime are checked.

Run it from the repository root with:

```sh
cc -std=c11 -Wall -Wextra -Werror \
  -Ivm_recovered/src/m3g \
  vm_recovered/src/m3g/m3g_loader_stream.c \
  vm_recovered/tests/m3g_loader_stream_test.c \
  -o /tmp/m3g_loader_stream_test
/tmp/m3g_loader_stream_test
```
