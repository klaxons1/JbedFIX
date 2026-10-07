/*
 * Normalized loader boundary recovered from the ARM bodies at:
 *
 *   0x002cb11c  swvLoaderCreate
 *   0x002cb0cc  swvLoaderFree
 *   0x002cb274  XREF recursion helper
 *   0x002cb50c  swvLoaderLoadNamed
 *   0x002cb794  swvLoaderLoadBuffer
 *   0x002f5760  loader_create
 *   0x002f57e0  loader_onDataStart
 *   0x002f5854  loader_onDataEnd
 *   0x002f58bc  loader_onData
 *   0x002f5944  loader_onError
 *   0x002f59ac  loader_getRootCount
 *   0x002f59c0  loader_getRoot
 *   0x002f59f8  loader_getXREFName
 *   0x002f5a14  loader_resolveXREF
 *
 * This is deliberately a boundary implementation, not a declaration of the
 * proprietary functions as ELF symbols.  Every native indirect call is an
 * explicitly typed callback, which also makes the state machine testable on a
 * host without the Android VM or the original Swerve library.
 */
#include "m3g_loader_stream.h"

#include <stddef.h>
#include <stdlib.h>

static void set_status(int32_t *status, int32_t value)
{
    if (status != NULL) {
        *status = value;
    }
}

static void report_error(JbedM3GLoaderStream *stream, int32_t *status)
{
    (void)jbed_m3g_loader_on_error(stream, JBED_M3G_LOAD_ERROR);
    set_status(status, JBED_M3G_LOAD_ERROR);
}

int jbed_m3g_loader_on_data_start(const JbedM3GLoaderStream *stream,
                                  int32_t source_type,
                                  int32_t *status)
{
    if (stream == NULL || status == NULL ||
        stream->ops.on_data_start == NULL) {
        return 0;
    }
    return stream->ops.on_data_start(stream->core, source_type, status);
}

int jbed_m3g_loader_on_data(const JbedM3GLoaderStream *stream,
                            const void *data,
                            uint32_t chunk_length,
                            int32_t offset,
                            int32_t available,
                            int32_t *status)
{
    if (stream == NULL || status == NULL || stream->ops.on_data == NULL) {
        return 0;
    }
    return stream->ops.on_data(stream->core, data, chunk_length, offset,
                               available, status);
}

int jbed_m3g_loader_on_data_end(const JbedM3GLoaderStream *stream,
                                int32_t *status)
{
    if (stream == NULL || status == NULL ||
        stream->ops.on_data_end == NULL) {
        return 0;
    }
    return stream->ops.on_data_end(stream->core, status);
}

int jbed_m3g_loader_on_error(const JbedM3GLoaderStream *stream,
                             int32_t error_code)
{
    if (stream == NULL || stream->ops.on_error == NULL) {
        return 0;
    }
    return stream->ops.on_error(stream->core, error_code);
}

static int finish_png_named(JbedM3GLoaderStream *stream,
                            const void *name,
                            int32_t *status)
{
    if (stream->ops.load_png_named != NULL &&
        stream->ops.load_png_named(stream->read, stream->callback_state, name,
                                   &stream->png_image) &&
        stream->png_image != NULL) {
        stream->contains_extensions = 1;
        set_status(status, JBED_M3G_LOAD_OK);
        return 1;
    }
    set_status(status, JBED_M3G_LOAD_ERROR);
    return 0;
}

static int finish_png_buffer(JbedM3GLoaderStream *stream,
                             const void *data,
                             uint32_t length,
                             int32_t *status)
{
    if (stream->ops.load_png_buffer != NULL &&
        stream->ops.load_png_buffer(data, length, &stream->png_image) &&
        stream->png_image != NULL) {
        stream->contains_extensions = 1;
        set_status(status, JBED_M3G_LOAD_OK);
        return 1;
    }
    return 0;
}

int jbed_m3g_loader_create(JbedM3GLoaderStream **out_stream,
                           JbedM3GReadCallback read,
                           JbedM3GContainsXrefCallback contains_xref,
                           JbedM3GXrefDataCallback xref_data,
                           void *callback_state,
                           void *xref_context,
                           JbedM3GLoadExternalCallback load_external,
                           const JbedM3GCoreLoaderOps *ops)
{
    JbedM3GLoaderStream *stream;

    if (out_stream == NULL || ops == NULL || ops->create == NULL) {
        return 0;
    }
    *out_stream = NULL;
    stream = (JbedM3GLoaderStream *)calloc(1, sizeof(*stream));
    if (stream == NULL) {
        return 0;
    }

    stream->read = read;
    stream->contains_xref = contains_xref;
    stream->xref_data = xref_data;
    stream->callback_state = callback_state;
    stream->xref_context = xref_context;
    stream->load_external = load_external;
    stream->ops = *ops;
    stream->contains_extensions = 0;

    /* swvLoaderCreate calls loader_create and frees the wrapper on failure. */
    if (!stream->ops.create(&stream->core)) {
        free(stream);
        return 0;
    }
    *out_stream = stream;
    return 1;
}

void jbed_m3g_loader_free(JbedM3GLoaderStream *stream)
{
    if (stream == NULL) {
        return;
    }
    /* This is the order in swvLoaderFree: core first, temporary PNG second. */
    if (stream->ops.release != NULL && stream->core != NULL) {
        stream->ops.release(stream->core);
    }
    if (stream->ops.release_object != NULL && stream->png_image != NULL) {
        stream->ops.release_object(stream->png_image);
    }
    free(stream);
}

int jbed_m3g_loader_resolve_xrefs(JbedM3GLoaderStream *stream,
                                  void *xref_context,
                                  int32_t contains_extensions)
{
    uint8_t *name_bytes = NULL;
    uint32_t name_capacity = 0;

    if (stream == NULL || stream->ops.get_xref_name == NULL ||
        stream->ops.resolve_xref == NULL) {
        return 1;
    }

    /*
     * The native helper always requests index zero.  Resolving an entry
     * changes the core's pending-XREF list, so the next unresolved item again
     * appears at zero; incrementing a local index would skip entries.
     */
    for (;;) {
        int32_t name_length = 0;
        int32_t query_result = stream->ops.get_xref_name(
            stream->core, 0, NULL, &name_length);
        (void)query_result;

        if (name_length == -1) {
            free(name_bytes);
            return 1;
        }
        if (name_length < 0) {
            free(name_bytes);
            return 0;
        }
        if ((uint32_t)name_length > name_capacity) {
            uint8_t *grown = (uint8_t *)realloc(name_bytes,
                                                 (size_t)name_length);
            if (grown == NULL && name_length != 0) {
                free(name_bytes);
                return 0;
            }
            name_bytes = grown;
            name_capacity = (uint32_t)name_length;
        }
        if (!stream->ops.get_xref_name(stream->core, 0, name_bytes,
                                       &name_length) || name_length < 0) {
            free(name_bytes);
            return 0;
        }

        /* sub_2CB274 widens each byte to one zero-extended UTF-16 code unit. */
        uint16_t *name_utf16 = (uint16_t *)calloc(
            (size_t)name_length + 1u, sizeof(*name_utf16));
        if (name_utf16 == NULL) {
            free(name_bytes);
            return 0;
        }
        for (int32_t i = 0; i < name_length; ++i) {
            name_utf16[i] = name_bytes[i];
        }

        /* The second wrapper callback claims an XREF already handled by Java. */
        if (stream->contains_xref != NULL &&
            stream->contains_xref(stream->callback_state, name_utf16)) {
            free(name_utf16);
            free(name_bytes);
            return 1;
        }

        /*
         * For buffer loading, a non-null xref context is passed to the third
         * wrapper callback.  Its first call returns the UTF-16 unit count and
         * its second call fills that many units, exactly as sub_2CB274 does.
         */
        uint16_t *resolved_name = name_utf16;
        if (xref_context != NULL && stream->xref_data != NULL) {
            int translated_units = stream->xref_data(
                xref_context, name_utf16, NULL);
            if (translated_units <= 0) {
                free(name_utf16);
                free(name_bytes);
                return 0;
            }
            resolved_name = (uint16_t *)calloc((size_t)translated_units,
                                               sizeof(*resolved_name));
            if (resolved_name == NULL) {
                free(name_utf16);
                free(name_bytes);
                return 0;
            }
            (void)stream->xref_data(xref_context, name_utf16, resolved_name);
            free(name_utf16);
        }

        void *external_object = NULL;
        int32_t xref_extensions = contains_extensions;
        if (stream->ops.get_contains_extensions != NULL) {
            (void)stream->ops.get_contains_extensions(stream->core,
                                                       &xref_extensions);
        }
        if (stream->load_external == NULL ||
            !stream->load_external(stream->callback_state, resolved_name,
                                   xref_extensions, &external_object) ||
            external_object == NULL) {
            free(resolved_name);
            free(name_bytes);
            return 0;
        }
        (void)stream->ops.resolve_xref(stream->core, external_object);
        if (stream->ops.release_object != NULL) {
            stream->ops.release_object(external_object);
        }
        free(resolved_name);
    }
}

int jbed_m3g_loader_load_named(JbedM3GLoaderStream *stream,
                               const void *name,
                               int32_t source_type,
                               int32_t *status)
{
    uint8_t buffer[1024];
    int32_t byte_count = 0;
    int32_t continuation = 0;
    int result;

    if (stream == NULL || status == NULL || stream->read == NULL ||
        stream->ops.on_data_start == NULL || stream->ops.on_data == NULL) {
        set_status(status, JBED_M3G_LOAD_ERROR);
        return 0;
    }

    result = jbed_m3g_loader_on_data_start(stream, source_type, status);
    if (!result || *status != JBED_M3G_LOAD_OK) {
        return finish_png_named(stream, name, status);
    }

    for (;;) {
        const void *requested_name = continuation == 0 ? name : NULL;
        byte_count = 0;
        if (!stream->read(stream->callback_state, requested_name,
                          (uint32_t)sizeof(buffer), buffer, &byte_count)) {
            /* v11=1 in the native path, followed by onError(-10). */
            report_error(stream, status);
            (void)stream->read(stream->callback_state, NULL, 0, NULL,
                               &byte_count);
            return finish_png_named(stream, name, status);
        }
        ++continuation;

        if (*status != JBED_M3G_LOAD_OK) {
            break;
        }
        if (byte_count == 0) {
            break;
        }
        if (byte_count < 0 || byte_count > (int32_t)sizeof(buffer) ||
            !jbed_m3g_loader_on_data(stream, buffer, (uint32_t)byte_count,
                                     0, byte_count, status)) {
            (void)stream->read(stream->callback_state, NULL, 0, NULL,
                               &byte_count);
            return finish_png_named(stream, name, status);
        }

        if (*status >= 0) {
            int32_t offset = *status;
            if (!jbed_m3g_loader_resolve_xrefs(stream, stream->xref_context,
                                               stream->contains_extensions)) {
                report_error(stream, status);
                (void)stream->read(stream->callback_state, NULL, 0, NULL,
                                   &byte_count);
                return finish_png_named(stream, name, status);
            }
            if (!jbed_m3g_loader_on_data(stream, buffer,
                                         (uint32_t)byte_count, offset,
                                         byte_count - offset, status)) {
                (void)stream->read(stream->callback_state, NULL, 0, NULL,
                                   &byte_count);
                return finish_png_named(stream, name, status);
            }
        }
    }

    /* The native path always closes the reader before onDataEnd. */
    (void)stream->read(stream->callback_state, NULL, 0, NULL, &byte_count);
    if (*status == JBED_M3G_LOAD_OK) {
        if (stream->ops.on_data_end == NULL ||
            !jbed_m3g_loader_on_data_end(stream, status)) {
            return finish_png_named(stream, name, status);
        }
    }
    if (*status == JBED_M3G_LOAD_OK) {
        /* wrapper +0x14 is the successful-load flag, not core XREF state. */
        stream->contains_extensions = 1;
        return 1;
    }
    return finish_png_named(stream, name, status);
}

int jbed_m3g_loader_load_buffer(JbedM3GLoaderStream *stream,
                                const void *data,
                                uint32_t length,
                                int32_t source_type,
                                int32_t *status)
{
    int result;

    if (stream == NULL || status == NULL || stream->ops.on_data_start == NULL ||
        stream->ops.on_data == NULL) {
        set_status(status, JBED_M3G_LOAD_ERROR);
        return 0;
    }

    result = jbed_m3g_loader_on_data_start(stream, source_type, status);
    if (!result) {
        return finish_png_buffer(stream, data, length, status);
    }
    if (*status == JBED_M3G_LOAD_OK) {
        result = jbed_m3g_loader_on_data(stream, data, length, 0,
                                       (int32_t)(uintptr_t)data, status);
        if (!result) {
            return finish_png_buffer(stream, data, length, status);
        }
        if (*status >= 0) {
            int32_t offset = *status;
            if (!jbed_m3g_loader_resolve_xrefs(stream, stream->xref_context,
                                               stream->contains_extensions)) {
                report_error(stream, status);
                return finish_png_buffer(stream, data, length, status);
            }
            result = jbed_m3g_loader_on_data(stream, NULL, length, offset,
                                             -offset, status);
            if (!result) {
                return finish_png_buffer(stream, data, length, status);
            }
        }
    }

    if (*status == JBED_M3G_LOAD_END) {
        *status = JBED_M3G_LOAD_OK;
    }
    if (*status == JBED_M3G_LOAD_OK) {
        if (stream->ops.on_data_end == NULL ||
            !jbed_m3g_loader_on_data_end(stream, status)) {
            return finish_png_buffer(stream, data, length, status);
        }
        if (*status == JBED_M3G_LOAD_OK) {
            stream->contains_extensions = 1;
            return 1;
        }
    }
    return finish_png_buffer(stream, data, length, status);
}

int jbed_m3g_loader_get_root_count(const JbedM3GLoaderStream *stream,
                                   int32_t *count)
{
    if (stream == NULL || count == NULL) {
        return 0;
    }
    if (stream->png_image != NULL) {
        *count = 1;
        return 1;
    }
    if (stream->ops.get_root_count == NULL) {
        *count = 0;
        return 1;
    }
    return stream->ops.get_root_count(stream->core, count);
}

int jbed_m3g_loader_get_root(JbedM3GLoaderStream *stream,
                             int32_t index,
                             void **out_root)
{
    if (stream == NULL || out_root == NULL || index < 0) {
        return 0;
    }
    *out_root = NULL;
    if (stream->png_image != NULL) {
        if (index != 0) {
            return 0;
        }
        *out_root = stream->png_image;
        return 1;
    }
    if (stream->ops.get_root == NULL) {
        return 0;
    }
    return stream->ops.get_root(stream->core, index, out_root);
}
