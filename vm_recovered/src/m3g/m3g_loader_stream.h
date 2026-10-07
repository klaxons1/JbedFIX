#ifndef JBED_RECOVERED_M3G_LOADER_STREAM_H
#define JBED_RECOVERED_M3G_LOADER_STREAM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Values written by the loader's virtual callbacks. */
#define JBED_M3G_LOAD_OK (-1)
#define JBED_M3G_LOAD_ERROR (-10)
#define JBED_M3G_LOAD_END (-11)

/*
 * swvLoaderLoadNamed calls the first wrapper slot as:
 *
 *     read(stack_context, name_or_null, 1024, buffer, &byte_count)
 *
 * The normalized ABI makes the output buffer explicit.  A zero byte_count
 * is end-of-input; a false return is a read failure.
 */
typedef int (*JbedM3GReadCallback)(void *callback_state,
                                   const void *name_or_null,
                                   uint32_t capacity,
                                   uint8_t *buffer,
                                   int32_t *out_byte_count);

typedef int (*JbedM3GContainsXrefCallback)(void *callback_state,
                                           const uint16_t *name);

/* The first call with buffer_or_null == NULL returns UTF-16 unit count. */
typedef int (*JbedM3GXrefDataCallback)(void *callback_state,
                                       const uint16_t *name,
                                       void *buffer_or_null);

/* Models the recursive swvLoadNamed call in sub_2CB274. */
typedef int (*JbedM3GLoadExternalCallback)(void *callback_state,
                                           const uint16_t *name,
                                           int32_t contains_extensions,
                                           void **out_object);

typedef struct JbedM3GCoreLoaderOps {
    int (*create)(void **out_core);
    void (*release)(void *core);
    void (*release_object)(void *object);

    int (*on_data_start)(void *core, int32_t source_type, int32_t *status);
    int (*on_data)(void *core, const void *data, uint32_t chunk_length,
                   int32_t offset, int32_t available, int32_t *status);
    int (*on_data_end)(void *core, int32_t *status);
    int (*on_error)(void *core, int32_t error_code);

    /* get_xref_name writes the required/actual byte length.  -1 ends XREFs. */
    int (*get_xref_name)(void *core, int32_t index, void *buffer,
                         int32_t *length);
    int (*resolve_xref)(void *core, void *object);
    int (*get_contains_extensions)(void *core, int32_t *value);

    int (*get_root_count)(void *core, int32_t *count);
    /* Native loader_getRoot returns a retained public handle. */
    int (*get_root)(void *core, int32_t index, void **out_root);

    int (*load_png_named)(JbedM3GReadCallback read_callback,
                         void *callback_state, const void *name,
                         void **out_image_handle);
    int (*load_png_buffer)(const void *data, uint32_t length,
                           void **out_image_handle);
} JbedM3GCoreLoaderOps;

/*
 * Logical form of the 0x18-byte native wrapper.  The first six fields map to
 * wrapper offsets 0x00..0x14 on the ARM build:
 *
 *   core, read, contains_xref, xref_data, png_image, contains_extensions.
 *
 * callback_state/xref_context are host-side context needed by the normalized
 * C boundary and are not native wrapper slots.
 */
typedef struct JbedM3GLoaderStream {
    void *core;
    JbedM3GReadCallback read;
    JbedM3GContainsXrefCallback contains_xref;
    JbedM3GXrefDataCallback xref_data;
    void *png_image;
    int32_t contains_extensions;

    void *callback_state;
    void *xref_context;
    JbedM3GLoadExternalCallback load_external;
    JbedM3GCoreLoaderOps ops;
} JbedM3GLoaderStream;

int jbed_m3g_loader_on_data_start(const JbedM3GLoaderStream *stream,
                                  int32_t source_type,
                                  int32_t *status);
int jbed_m3g_loader_on_data(const JbedM3GLoaderStream *stream,
                            const void *data,
                            uint32_t chunk_length,
                            int32_t offset,
                            int32_t available,
                            int32_t *status);
int jbed_m3g_loader_on_data_end(const JbedM3GLoaderStream *stream,
                                int32_t *status);
int jbed_m3g_loader_on_error(const JbedM3GLoaderStream *stream,
                             int32_t error_code);

int jbed_m3g_loader_create(JbedM3GLoaderStream **out_stream,
                           JbedM3GReadCallback read,
                           JbedM3GContainsXrefCallback contains_xref,
                           JbedM3GXrefDataCallback xref_data,
                           void *callback_state,
                           void *xref_context,
                           JbedM3GLoadExternalCallback load_external,
                           const JbedM3GCoreLoaderOps *ops);
void jbed_m3g_loader_free(JbedM3GLoaderStream *stream);

int jbed_m3g_loader_load_named(JbedM3GLoaderStream *stream,
                               const void *name,
                               int32_t source_type,
                               int32_t *status);
int jbed_m3g_loader_load_buffer(JbedM3GLoaderStream *stream,
                                const void *data,
                                uint32_t length,
                                int32_t source_type,
                                int32_t *status);
int jbed_m3g_loader_resolve_xrefs(JbedM3GLoaderStream *stream,
                                  void *xref_context,
                                  int32_t contains_extensions);

int jbed_m3g_loader_get_root_count(const JbedM3GLoaderStream *stream,
                                   int32_t *count);
int jbed_m3g_loader_get_root(JbedM3GLoaderStream *stream,
                             int32_t index,
                             void **out_root);

#ifdef __cplusplus
}
#endif

#endif
