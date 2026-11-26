#include "runtime.h"
#include "../compiler/vm/vm_words.h"

#include <limits.h>
#include <string.h>

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm)
        jbed_vm_fatal(NULL, "Native call outside a Jbed VM");
    return vm;
}

static void *pointer(JbedVm *vm, JbedAddress ref)
{
    return ref ? jbed_vm_at(vm->heap.memory, ref) : NULL;
}

static JbArray *new_array(int count, int kind)
{
    JbedVm *vm = active();
    JbedAddress klass = kind == JBED_TYPE_REFERENCE
        ? vm->object_array_class : vm->primitive_array_classes[kind];
    return pointer(vm, jbed_vm_allocate_array(vm, klass, count, true));
}

JbArray *Jbni_newIntArray(int count) { return new_array(count, JBED_TYPE_INT); }
JbArray *Jbni_newByteArray(int count) { return new_array(count, JBED_TYPE_BYTE); }
JbArray *Jbni_newObjectArray(int count) { return new_array(count, JBED_TYPE_REFERENCE); }

static JbedAddress make_string(JbedVm *vm, JbedAddress characters, uint32_t count, bool kni)
{
    JbedVmHeapRoot root = {characters, characters, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress string = jbed_vm_allocate_object(vm, vm->string_class, kni);
    vm->heap.temporary_roots = root.previous;
    if (string) {
        jbed_vm_put_word(vm->heap.memory, string + 12, root.value);
        jbed_vm_put_word(vm->heap.memory, string + 16, root.value ? 16 : 0);
        jbed_vm_put_word(vm->heap.memory, string + 20, count);
    }
    return string;
}

static unsigned utf_width(uint8_t first)
{
    return first < 0x80 ? 1 : first < 0xe0 ? 2 : 3;
}

static uint16_t utf_character(const uint8_t *p, unsigned width)
{
    if (width == 1)
        return p[0];
    if (width == 2)
        return (uint16_t)((p[0] & 0x1f) << 6 | (p[1] & 0x3f));
    return (uint16_t)((p[0] & 0x0f) << 12 | (p[1] & 0x3f) << 6 | (p[2] & 0x3f));
}

/* Jbed uses modified UTF-8: three-byte UTF-16 units, including surrogates. */
static JbedAddress new_utf_string(JbedVm *vm, const char *bytes, int length,
                                  bool kni, bool replace_slashes)
{
    if (!bytes)
        return 0;
    const uint8_t *text = (const uint8_t *)bytes;
    size_t size = length < 0 ? strlen(bytes) : (size_t)length;
    size_t capacity = size;
    if (length < 0 || kni) {
        capacity = 0;
        for (size_t i = 0; i < size; i += utf_width(text[i]))
            ++capacity;
    }
    if (capacity > INT32_MAX)
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "String is too large");
    JbedAddress array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_CHAR],
                                               (int32_t)capacity, kni);
    if (!array)
        return 0;
    uint16_t *characters = pointer(vm, array + 16);
    uint32_t count = 0;
    for (size_t i = 0; i < size;) {
        unsigned width = utf_width(text[i]);
        if (width > size - i)
            break;
        uint16_t ch = utf_character(text + i, width);
        if (replace_slashes && ch == '/' && (kni || width == 1))
            ch = '.';
        characters[count++] = ch;
        i += width;
    }
    return make_string(vm, array, count, kni);
}

JbRef JbedKNI_NewUtfString(const char *bytes, int replace_slashes)
{
    return new_utf_string(active(), bytes, -1, true, replace_slashes != 0);
}

JbRef jbed_vm_new_utf_string(JbedVm *vm, const char *bytes, int32_t length, bool replace_slashes)
{
    return new_utf_string(vm, bytes, length, false, replace_slashes);
}

JbString *Jbni_intern_newStringLenExc(const char *bytes, int length)
{
    JbedVm *vm = active();
    return pointer(vm, new_utf_string(vm, bytes, length, false, false));
}

JbString *Jbni_intern_newStringExc(const char *bytes)
{
    return Jbni_intern_newStringLenExc(bytes, -1);
}

typedef struct StringRequest {
    JbedVm *vm;
    const char *bytes;
    int length;
    JbString *result;
    bool empty;
} StringRequest;

JbString *Jbni_intern_newEmptyStringLenExc(int count)
{
    JbedVm *vm = active();
    JbedAddress string = jbed_vm_allocate_object(vm, vm->string_class, false);
    JbedVmHeapRoot root = {string, string, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress characters = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_CHAR],
                                                     count, false);
    vm->heap.temporary_roots = root.previous;
    jbed_vm_put_word(vm->heap.memory, root.value + 12, characters);
    jbed_vm_put_word(vm->heap.memory, root.value + 16, characters ? 16 : 0);
    jbed_vm_put_word(vm->heap.memory, root.value + 20, (uint32_t)count);
    return pointer(vm, root.value);
}

static void string_request(void *argument)
{
    StringRequest *r = argument;
    r->result = r->empty ? Jbni_intern_newEmptyStringLenExc(r->length)
                        : Jbni_intern_newStringLenExc(r->bytes, r->length);
}

static JbString *try_string(StringRequest *request)
{
    JbedVm *vm = request->vm;
    JbedVmHeapRoot *roots = vm->heap.temporary_roots;
    JbedError caught;
    if (!vm->services.protected_call)
        jbed_vm_fatal(vm, "JBNI requires a native exception boundary");
    bool ok = vm->services.protected_call(vm->services.context, string_request, request, &caught);
    vm->heap.temporary_roots = roots;
    return ok ? request->result : NULL;
}

JbString *Jbni_intern_newString(const char *bytes)
{
    StringRequest r = {.vm = active(), .bytes = bytes, .length = -1};
    return try_string(&r);
}

JbString *Jbni_intern_newEmptyStringLen(int count)
{
    StringRequest r = {.vm = active(), .length = count, .empty = true};
    return try_string(&r);
}

static const uint16_t *string_chars(JbedVm *vm, const JbString *string)
{
    if (!string)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "Null string");
    return pointer(vm, string->chars + (uint32_t)string->offset);
}

int Jbni_intern_getStringAscii(const JbString *string, char *output, int capacity)
{
    JbedVm *vm = active();
    const uint16_t *chars = string_chars(vm, string);
    int count = string->length;
    if (!output || !capacity) {
        if (output || capacity)
            jbed_vm_fatal(vm, "String output pointer and capacity disagree");
        return count + 1;
    }
    int result = count + 1;
    if (count >= capacity) {
        count = capacity - 1;
        result = -1;
    }
    int written = 0;
    for (; written < count; ++written)
        output[written] = chars[written] && chars[written] < 256 ? (char)chars[written] : '?';
    output[written] = 0;
    return result;
}

int Jbni_intern_getStringUtf8(const JbString *string, char *output, int capacity)
{
    JbedVm *vm = active();
    const uint16_t *chars = string_chars(vm, string);
    if ((!output || !capacity) && (output || capacity))
        jbed_vm_fatal(vm, "String output pointer and capacity disagree");
    int used = 0;
    for (int i = 0; i < string->length; ++i) {
        unsigned ch = chars[i];
        unsigned width = ch && ch < 0x80 ? 1 : ch < 0x800 ? 2 : 3;
        if (output && capacity > 0) {
            if (capacity - used <= (int)width) {
                output[used] = 0;
                return -1;
            }
            if (width == 1) {
                output[used] = (char)ch;
            } else {
                if (width == 3) {
                    output[used] = (char)(0xe0 | ch >> 12);
                    output[used + 1] = (char)(0x80 | (ch >> 6 & 0x3f));
                } else {
                    output[used] = (char)(0xc0 | ch >> 6);
                }
                output[used + (int)width - 1] = (char)(0x80 | (ch & 0x3f));
            }
        }
        used += (int)width;
    }
    if (output && capacity > 0)
        output[used] = 0;
    return used + 1;
}

int Jbni_intern_getClassNameUtf8(JbRef class_ref, char *output, int capacity)
{
    JbedVm *vm = active();
    if ((!output || !capacity) && (output || capacity))
        jbed_vm_fatal(vm, "Class name output pointer and capacity disagree");
    if (!class_ref)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "Null class");
    JbedTypeId id = jbed_vm_word(vm->heap.memory, class_ref + 16);
    const char *name = id ? jbed_class_name(&vm->classes, id) : NULL;
    if (!name)
        name = "?";
    size_t length = strlen(name);
    if (output) {
        if (length >= (size_t)capacity) {
            output[0] = 0;
        } else {
            for (size_t i = 0; i < length; ++i)
                output[i] = name[i] == '.' ? '/' : name[i];
            output[length] = 0;
        }
    }
    return (int)length + 1;
}

int JbedKNI_ThrowNew(const char *class_name, JbRef message)
{
    JbedVm *vm = active();
    if (!class_name)
        jbed_vm_fatal(vm, "Null native exception class name");
    JbedAddress klass = JbedKNI_LookupClass(class_name);
    if (!klass)
        return -1;
    JbedVmHeapRoot root = {message, message, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress throwable = jbed_vm_allocate_object(vm, klass, true);
    vm->heap.temporary_roots = root.previous;
    if (!throwable)
        return -1;
    jbed_vm_put_word(vm->heap.memory, throwable + 16, root.value);
    vm->pending_exception = throwable;
    if (Jbed_ParamPtr)
        Jbed_ParamPtr[-1] = throwable;
    return 0;
}

static _Noreturn void raise_throwable(JbedVm *vm, JbedAddress throwable)
{
    JbedError error = {.kind = JBED_ERROR_THROWABLE, .runtime_throwable = pointer(vm, throwable)};
    jbed_raise(&vm->services, &error);
}

_Noreturn void Jbni_intern_raiseException(const char *class_name)
{
    JbedVm *vm = active();
    Jbed_noAllocation = 0;
    vm->heap.no_allocation = 0;
    JbedAddress klass = JbedKNI_LookupClass(class_name);
    if (!klass)
        jbed_vm_fatal(vm, "Native exception class is unavailable");
    raise_throwable(vm, jbed_vm_allocate_object(vm, klass, false));
}

_Noreturn void Jbni_intern_raiseCommonException(int code)
{
    JbedVm *vm = active();
    const char *name;
    switch (code) {
    case JBED_EXCEPTION_NULL_POINTER: name = "java/lang/NullPointerException"; break;
    case JBED_EXCEPTION_ARRAY_BOUNDS: name = "java/lang/ArrayIndexOutOfBoundsException"; break;
    case JBED_EXCEPTION_STRING_BOUNDS: name = "java/lang/StringIndexOutOfBoundsException"; break;
    case JBED_EXCEPTION_ILLEGAL_ARGUMENT: name = "java/lang/IllegalArgumentException"; break;
    case JBED_EXCEPTION_IO: name = "java/io/IOException"; break;
    case JBED_EXCEPTION_INDEX_BOUNDS: name = "java/lang/IndexOutOfBoundsException"; break;
    case JBED_EXCEPTION_OUT_OF_MEMORY:
        Jbed_noAllocation = 0;
        vm->heap.no_allocation = 0;
        if (!vm->out_of_memory)
            jbed_vm_fatal(vm, "Preallocated OutOfMemoryError is unavailable");
        raise_throwable(vm, vm->out_of_memory);
    default:
        jbed_vm_fatal(vm, "Unknown common native exception");
    }
    Jbni_intern_raiseException(name);
}
