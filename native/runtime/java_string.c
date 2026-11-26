#include "java_string.h"
#include "execution.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum { STRING_VALUE = 12, STRING_ADDRESS = 16, STRING_COUNT = 20,
       ARRAY_LENGTH = 12, ARRAY_DATA = 16 };

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "String call outside a Jbed VM");
    return vm;
}

static _Noreturn void string_bounds(JbedVm *vm)
{
    JbedAddress error = jbed_vm_new_throwable(vm, "java/lang/StringIndexOutOfBoundsException");
    jbed_raise(&vm->services, &(JbedError){.kind = JBED_ERROR_THROWABLE,
        .runtime_throwable = jbed_vm_at(vm->heap.memory, error)});
}

JbedAddress NativeOps_getStringData(JbRef string)
{
    if (!string) return 0;
    JbedVm *vm = active();
    return jbed_vm_word(vm->heap.memory, string + STRING_VALUE) +
        jbed_vm_word(vm->heap.memory, string + STRING_ADDRESS);
}

uint16_t String_charAt(JbRef string, int32_t index)
{
    JbedVm *vm = active();
    if (!string) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    if ((uint32_t)index >= jbed_vm_word(vm->heap.memory, string + STRING_COUNT))
        string_bounds(vm);
    return jbed_vm_half(vm->heap.memory, NativeOps_getStringData(string) + 2u * (uint32_t)index);
}

void String_getChars(JbRef string, int32_t begin, int32_t end, JbRef destination, int32_t offset)
{
    JbedVm *vm = active();
    if (!string) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    if (begin < 0 || offset < 0 || begin > end ||
        end > (int32_t)jbed_vm_word(vm->heap.memory, string + STRING_COUNT))
        string_bounds(vm);
    if (!destination) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    int32_t capacity = (int32_t)jbed_vm_word(vm->heap.memory, destination + ARRAY_LENGTH);
    if (offset - begin > capacity - end)
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    memmove(jbed_vm_at(vm->heap.memory, destination + ARRAY_DATA + 2u * (uint32_t)offset),
        jbed_vm_at(vm->heap.memory, NativeOps_getStringData(string) + 2u * (uint32_t)begin),
        2u * (uint32_t)(end - begin));
}
