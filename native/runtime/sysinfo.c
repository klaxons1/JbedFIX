#include "sysinfo.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "SysInfo call outside a Jbed VM");
    return vm;
}

static JbedAddress image_field(JbedVm *vm, const char *name)
{
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SysInfo", name);
    if (!slot) jbed_vm_fatal(vm, "SysInfo image field is absent");
    return jbed_vm_word(vm->heap.memory, slot);
}

JbedAddress SysInfo_getFirstString(void) { return image_field(active(), "firstString"); }

JbedAddress SysInfo_getProperty(JbedAddress name)
{
    JbedVm *vm = active();
    JbedAddress address = image_field(vm, "propertiesHash");
    if (!address) return 0;
    if (!name) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    const JbString *key = (const JbString *)(uintptr_t)name;
    const uint16_t *characters = jb_string_chars(key);
    uint32_t hash = 0;
    for (int32_t i = 0; i < key->length; ++i) hash = 31 * hash + characters[i];
    const JbArray *table = (const JbArray *)(uintptr_t)address;
    uint32_t index = hash & ((uint32_t)table->length - 1);
    if (index >= (uint32_t)table->length) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    const JbArray *bucket = (const JbArray *)(uintptr_t)table->data[index];
    if (!bucket) return 0;
    for (int32_t i = 0; i < bucket->length; i += 2) {
        const JbString *property = (const JbString *)(uintptr_t)bucket->data[i];
        if (!property) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
        if (property->length == key->length &&
            !memcmp(jb_string_chars(property), characters, (size_t)key->length * sizeof(*characters))) {
            if (i + 1 >= bucket->length) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
            return bucket->data[i + 1];
        }
    }
    return 0;
}
