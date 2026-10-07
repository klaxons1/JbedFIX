#include "m3g_loader_stream.h"

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static int fake_release_object_calls;

typedef struct FakeCore {
    int start_calls;
    int data_calls;
    int end_calls;
    int error_calls;
    int read_calls;
    int close_calls;
    int pending_xrefs;
    int resolved_xrefs;
    int release_objects;
    int png_loads;
    int expected_extensions;
    int fail_start;
    int buffer_mode;
    int buffer_xref;
    int object_token;
} FakeCore;

static FakeCore *fake_create(void **out_core)
{
    FakeCore *core = (FakeCore *)calloc(1, sizeof(*core));
    assert(core != NULL);
    core->pending_xrefs = 1;
    core->expected_extensions = 7;
    *out_core = core;
    return core;
}

static int fake_create_callback(void **out_core)
{
    (void)fake_create(out_core);
    return 1;
}

static void fake_release(void *opaque)
{
    free(opaque);
}

static void fake_release_object(void *opaque)
{
    (void)opaque;
    fake_release_object_calls++;
}

static int fake_on_start(void *opaque, int32_t source_type, int32_t *status)
{
    FakeCore *core = (FakeCore *)opaque;
    assert(source_type == 3);
    core->start_calls++;
    *status = core->fail_start ? JBED_M3G_LOAD_ERROR : JBED_M3G_LOAD_OK;
    return core->fail_start ? 0 : 1;
}

static int fake_on_data(void *opaque, const void *data, uint32_t length,
                        int32_t offset, int32_t available, int32_t *status)
{
    FakeCore *core = (FakeCore *)opaque;
    assert(length == (core->buffer_mode ? 4u : 4u));
    assert(offset >= 0);
    (void)available;
    if (core->buffer_mode && core->data_calls == 0) {
        assert(data != NULL);
        *status = core->buffer_xref ? 0 : JBED_M3G_LOAD_END;
    } else if (core->buffer_mode) {
        assert(data == NULL);
        *status = JBED_M3G_LOAD_OK;
    } else if (core->data_calls == 0) {
        assert(data != NULL);
        *status = 0;
    } else {
        assert(data != NULL);
        *status = JBED_M3G_LOAD_OK;
    }
    core->data_calls++;
    return 1;
}

static int fake_on_end(void *opaque, int32_t *status)
{
    FakeCore *core = (FakeCore *)opaque;
    core->end_calls++;
    *status = JBED_M3G_LOAD_OK;
    return 1;
}

static int fake_on_error(void *opaque, int32_t error_code)
{
    FakeCore *core = (FakeCore *)opaque;
    assert(error_code == JBED_M3G_LOAD_ERROR);
    core->error_calls++;
    return 1;
}

static int fake_get_xref_name(void *opaque, int32_t index, void *buffer,
                              int32_t *length)
{
    FakeCore *core = (FakeCore *)opaque;
    static const uint8_t name[] = {'t', 'e', 'x'};
    assert(index == 0);
    if (core->pending_xrefs == 0) {
        *length = -1;
        return -1;
    }
    *length = (int32_t)(sizeof(name));
    if (buffer != NULL) {
        memcpy(buffer, name, sizeof(name));
    }
    return *length;
}

static int fake_resolve_xref(void *opaque, void *object)
{
    FakeCore *core = (FakeCore *)opaque;
    assert(object == &core->object_token);
    assert(core->pending_xrefs == 1);
    core->pending_xrefs = 0;
    core->resolved_xrefs++;
    return 1;
}

static int fake_get_extensions(void *opaque, int32_t *value)
{
    FakeCore *core = (FakeCore *)opaque;
    *value = core->expected_extensions;
    return 1;
}

static int fake_get_root_count(void *opaque, int32_t *count)
{
    (void)opaque;
    *count = 2;
    return 1;
}

static int fake_get_root(void *opaque, int32_t index, void **root)
{
    FakeCore *core = (FakeCore *)opaque;
    if (index != 0) {
        return 0;
    }
    *root = &core->object_token;
    return 1;
}

static int fake_read(void *opaque, const void *name_or_null,
                     uint32_t capacity, uint8_t *buffer,
                     int32_t *out_byte_count)
{
    FakeCore *core = (FakeCore *)opaque;
    core->read_calls++;
    if (capacity == 0) {
        assert(name_or_null == NULL);
        assert(buffer == NULL);
        core->close_calls++;
        *out_byte_count = 0;
        return 1;
    }
    assert(capacity == 1024u);
    if (core->read_calls == 1) {
        assert(name_or_null != NULL);
        memcpy(buffer, "data", 4);
        *out_byte_count = 4;
    } else {
        assert(name_or_null == NULL);
        *out_byte_count = 0;
    }
    return 1;
}

static int fake_external(void *opaque, const uint16_t *name,
                         int32_t contains_extensions, void **out_object)
{
    FakeCore *core = (FakeCore *)opaque;
    assert(name[0] == 't' && name[1] == 'e' && name[2] == 'x');
    assert(name[3] == 0);
    assert(contains_extensions == 7);
    *out_object = &core->object_token;
    return 1;
}

static int fake_xref_data(void *opaque, const uint16_t *name, void *buffer)
{
    static const uint16_t translated[] = {'t', 'e', 'x', 0};
    assert(opaque == (void *)(uintptr_t)0x1234u);
    assert(name[0] == 't' && name[1] == 'e' && name[2] == 'x');
    if (buffer != NULL) {
        memcpy(buffer, translated, sizeof(translated));
    }
    return (int)(sizeof(translated) / sizeof(translated[0]));
}

static int fake_png_named(JbedM3GReadCallback read_callback, void *state,
                          const void *name, void **out_image)
{
    FakeCore *core = (FakeCore *)state;
    (void)read_callback;
    assert(name != NULL);
    core->png_loads++;
    *out_image = &core->object_token;
    return 1;
}

static int fake_png_buffer(const void *data, uint32_t length,
                           void **out_image)
{
    assert(data != NULL);
    assert(length == 4u);
    *out_image = (void *)data;
    return 1;
}

static JbedM3GCoreLoaderOps fake_ops(void)
{
    JbedM3GCoreLoaderOps ops;
    memset(&ops, 0, sizeof(ops));
    ops.create = fake_create_callback;
    ops.release = fake_release;
    ops.release_object = fake_release_object;
    ops.on_data_start = fake_on_start;
    ops.on_data = fake_on_data;
    ops.on_data_end = fake_on_end;
    ops.on_error = fake_on_error;
    ops.get_xref_name = fake_get_xref_name;
    ops.resolve_xref = fake_resolve_xref;
    ops.get_contains_extensions = fake_get_extensions;
    ops.get_root_count = fake_get_root_count;
    ops.get_root = fake_get_root;
    ops.load_png_named = fake_png_named;
    ops.load_png_buffer = fake_png_buffer;
    return ops;
}

static void test_named_stream_and_xref(void)
{
    JbedM3GCoreLoaderOps ops = fake_ops();
    JbedM3GLoaderStream *stream = NULL;
    int32_t status = 0;
    int32_t roots = 0;
    void *root = NULL;
    int result;

    result = jbed_m3g_loader_create(&stream, fake_read, NULL, NULL, NULL,
                                    NULL, fake_external, &ops);
    assert(result == 1 && stream != NULL);
    stream->callback_state = stream->core;
    result = jbed_m3g_loader_load_named(stream, "scene.m3g", 3, &status);
    assert(result == 1 && status == JBED_M3G_LOAD_OK);
    assert(((FakeCore *)stream->core)->resolved_xrefs == 1);
    assert(((FakeCore *)stream->core)->data_calls == 2);
    assert(((FakeCore *)stream->core)->close_calls == 1);
    assert(stream->contains_extensions == 1);
    assert(jbed_m3g_loader_get_root_count(stream, &roots) == 1);
    assert(roots == 2);
    assert(jbed_m3g_loader_get_root(stream, 0, &root) == 1);
    assert(root != NULL);
    jbed_m3g_loader_free(stream);
}

static void test_buffer_end_status(void)
{
    static const uint8_t data[] = {'d', 'a', 't', 'a'};
    JbedM3GCoreLoaderOps ops = fake_ops();
    JbedM3GLoaderStream *stream = NULL;
    int32_t status = 0;

    assert(jbed_m3g_loader_create(&stream, NULL, NULL, NULL, NULL, NULL,
                                  fake_external, &ops) == 1);
    stream->callback_state = stream->core;
    ((FakeCore *)stream->core)->buffer_mode = 1;
    assert(jbed_m3g_loader_load_buffer(stream, data, sizeof(data), 3,
                                       &status) == 1);
    assert(status == JBED_M3G_LOAD_OK);
    assert(((FakeCore *)stream->core)->end_calls == 1);
    jbed_m3g_loader_free(stream);
}

static void test_buffer_xref_translation(void)
{
    static const uint8_t data[] = {'d', 'a', 't', 'a'};
    JbedM3GCoreLoaderOps ops = fake_ops();
    JbedM3GLoaderStream *stream = NULL;
    int32_t status = 0;

    assert(jbed_m3g_loader_create(&stream, NULL, NULL, fake_xref_data, NULL,
                                  (void *)(uintptr_t)0x1234u, fake_external,
                                  &ops) == 1);
    stream->callback_state = stream->core;
    ((FakeCore *)stream->core)->buffer_mode = 1;
    ((FakeCore *)stream->core)->buffer_xref = 1;
    assert(jbed_m3g_loader_load_buffer(stream, data, sizeof(data), 3,
                                       &status) == 1);
    assert(status == JBED_M3G_LOAD_OK);
    assert(((FakeCore *)stream->core)->resolved_xrefs == 1);
    assert(((FakeCore *)stream->core)->data_calls == 2);
    jbed_m3g_loader_free(stream);
}

static void test_png_root_fallback(void)
{
    JbedM3GCoreLoaderOps ops = fake_ops();
    JbedM3GLoaderStream *stream = NULL;
    int32_t status = JBED_M3G_LOAD_OK;
    int32_t roots = 0;

    assert(jbed_m3g_loader_create(&stream, fake_read, NULL, NULL, NULL, NULL,
                                  NULL, &ops) == 1);
    stream->callback_state = stream->core;
    ((FakeCore *)stream->core)->fail_start = 1;
    assert(jbed_m3g_loader_load_named(stream, "image.png", 3, &status) == 1);
    assert(status == JBED_M3G_LOAD_OK);
    assert(jbed_m3g_loader_get_root_count(stream, &roots) == 1);
    assert(roots == 1);
    assert(((FakeCore *)stream->core)->png_loads == 1);
    jbed_m3g_loader_free(stream);
}

int main(void)
{
    test_named_stream_and_xref();
    test_buffer_end_status();
    test_buffer_xref_translation();
    test_png_root_fallback();
    return 0;
}
