#include "vm_types.h"
#include "vm_words.h"
#include "class_access.h"
#include "method_ranges.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdalign.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>

static void *allocate(void *context, size_t bytes)
{
    alignas(max_align_t) static unsigned char arena[4 << 20];
    size_t *used = context;
    size_t offset = (*used + alignof(max_align_t) - 1) & ~(alignof(max_align_t) - 1);
    assert(offset + bytes <= sizeof arena);
    *used = offset + bytes;
    return arena + offset;
}

static jmp_buf on_array_store;
static bool checking_array_store;

static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    if (checking_array_store && error->kind == JBED_ERROR_ARRAY_STORE)
        longjmp(on_array_store, 1);
    fprintf(stderr, "Unexpected VM error %d\n", error->kind);
    abort();
}

void test_class_access(JbedAndroidRomTables *);

static void test_private_invokespecial(JbedRuntime *runtime, JbedClass *object)
{
    JbedClass owner = {.id = 0x10001, .flags = 0x800000, .superclass = object, .depth = 1};
    JbedMethod helper = {.owner = &owner, .flags = JBED_ACC_PRIVATE, .name_id = 101,
                         .signature_id = 0xf00d};
    owner.methods = &helper;
    owner.method_count = 1;
    uint8_t tags[] = {0, 23, 12, 10};
    uint32_t values[] = {0, 0, (101u << 16) | 0xf00d, (1u << 16) | 2};
    JbedPoolObject cached = {.class_object = &owner};
    JbedPoolServices services = {.runtime = runtime};
    JbedPool pool = {.services = &services, .owner = &owner, .tags = tags, .values = values,
                     .count = 4, .objects = &cached, .object_count = 1};
    JbedMethod *resolved = NULL;
    JbedError error = {0};
    assert(jbed_pool_method(&pool, 3, JBED_ACC_SUPER, &resolved, &error) && resolved == &helper);
}

static void test_heap_references(const JbedVmClassTable *t, JbedClass *string_array, JbedClass *thread)
{
    uint8_t bytes[64] = {0};
    JbedBuffer heap = {.data = bytes, .size = sizeof bytes, .address = 0x71000000};
    JbedAddress array = heap.address, value = array + 32;
    jbed_vm_put_word(heap, array, string_array->descriptor_address);
    jbed_vm_put_word(heap, array + 12, 1);
    jbed_vm_put_word(heap, value, string_array->superclass->descriptor_address);
    assert(jbed_vm_checkcast(t, heap, value, string_array->superclass) == value);
    jbed_vm_store_array_ref(t, heap, array, 0, value, true);
    assert(jbed_vm_word(heap, array + 16) == value);
    jbed_vm_put_word(heap, value, thread->descriptor_address);
    checking_array_store = true;
    if (setjmp(on_array_store) == 0) {
        jbed_vm_store_array_ref(t, heap, array, -1, value, true);
        abort();
    }
    checking_array_store = false;
    jbed_vm_store_array_ref(t, heap, array, 0, 0, false);
    assert(jbed_vm_word(heap, array + 16) == 0);
}

int main(int argc, char **argv)
{
    assert(argc == 2);
    FILE *f = fopen(argv[1], "rb");
    assert(f && fseek(f, 0, SEEK_END) == 0);
    size_t size = (size_t)ftell(f);
    rewind(f);
    uint8_t *bytes = malloc(size);
    assert(bytes && fread(bytes, 1, size, f) == size);
    fclose(f);

    size_t used = 0;
    JbedRuntime runtime = {
        .context = &used, .allocate_zeroed = allocate, .raise_error = raise_error};
    JbedAndroidRomTables tables;
    jbed_android_rom_tables_init(&tables, &runtime, (JbedImageView){.bytes = bytes, .size = size}, false);
    JbedVmClassTable *t = &tables.classes;
    size_t classes = 0, methods = 0, fields = 0;
    for (uint32_t id = 1; id <= t->id_limit; ++id) {
        JbedClass *c = jbed_vm_class_by_id(t, id);
        if (c) {
            assert(jbed_vm_lookup_class(t, c->package_id, c->base_id, c->array_dimensions, true) ==
                   c);
            ++classes;
            methods += c->method_count;
            fields += c->field_count;
        }
    }
    /* The eight primitive Class objects have no name bucket records. */
    assert(classes == 1005 + 8 && methods == 10678 && fields == 7594);
    assert(!jbed_vm_class_by_id(t, 0x10000 | 466));

    JbedClass *string = jbed_vm_class_by_id(t, 466), *object = jbed_vm_class_by_id(t, 462);
    JbedClass *string_array = jbed_vm_lookup_class(t, 217, 1585, 1, false);
    JbedClass *object_array = jbed_vm_lookup_class(t, 217, 3057, 1, false);
    JbedClass *thread = jbed_vm_class_by_id(t, 340), *runnable = jbed_vm_class_by_id(t, 116);
    JbedClass *int_array = jbed_vm_class_by_id(t, 463), *byte_array = jbed_vm_class_by_id(t, 467);
    assert(string_array->superclass == string && int_array->superclass->id == 10);
    assert(jbed_vm_assignable(runnable, thread) && !jbed_vm_assignable(thread, runnable));
    assert(jbed_vm_assignable(object_array, string_array) &&
           !jbed_vm_assignable(string_array, object_array));
    assert(!jbed_vm_assignable(int_array, byte_array) &&
           !jbed_vm_assignable(object, int_array->superclass));
    assert(!jbed_vm_instance_of(t, 0, object));
    assert(jbed_vm_instance_of(t, string_array->descriptor_address, object_array));
    assert(jbed_vm_instance_of(t, thread->descriptor_address, runnable));
    assert(!jbed_vm_instance_of(t, string->descriptor_address, runnable));
    assert(jbed_vm_interface_method(t, thread->descriptor_address, runnable, 0) == 0xc2e61);
    assert(jbed_vm_method_by_number(thread, 3)->code_address == 0xc2e60);

    test_heap_references(t, string_array, thread);
    test_private_invokespecial(&runtime, object);

    JbedPoolServices pool = {0};
    JbedMethod *method;
    JbedField *field;
    JbedPoolServices unresolved_services = {.runtime = &runtime, .class_access = &tables.access};
    JbedPool unresolved = {.services = &unresolved_services};
    JbedClass *pool_class = jbed_vm_class_by_id(t, 47);
    assert(jbed_pool_method(&unresolved, 1, 0, &method, NULL) && method->owner == pool_class);
    assert(jbed_pool_field(&unresolved, 1, 0, &field, NULL) && field->owner == pool_class);
    assert(jbed_vm_find_method(&pool, string, 16817, 61674, &method, NULL));
    assert(method->code_address == 0xb6a5e && method->generated_size == 34);
    JbedClassAccess access;
    jbed_class_access_init(&access, &runtime, t, NULL, NULL, true);
    assert(jbed_method_by_pc(&access, 0xb6a62, JBED_METHOD_ALL_BUNDLES) == method);
    assert(!jbed_method_by_pc(&access, 0xb6a62, JBED_METHOD_LOADED_BUNDLE));
    assert(!jbed_method_by_pc(&access, 0xb6a62, JBED_METHOD_DYNAMIC_BUNDLE));
    assert(jbed_vm_method_visible(&pool, method));
    assert(jbed_vm_find_field(&pool, jbed_vm_class_by_id(t, 558), 10595, 11, &field, NULL));
    assert(field->constant_value == INT64_MAX);
    assert(jbed_vm_find_field(&pool, jbed_vm_class_by_id(t, 558), 4163, 11, &field, NULL));
    assert(field->constant_value == UINT64_C(0x8000000000000000));

    test_class_access(&tables);
    free(bytes);
    printf("%zu class objects, %zu methods, %zu fields; array, interface and "
           "member lookup passed\n",
           classes, methods, fields);
    return 0;
}
