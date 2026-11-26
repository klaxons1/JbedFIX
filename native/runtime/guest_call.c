#include "guest_call.h"
#include "execution.h"
#include "../compiler/signatures.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum { MAX_ARGUMENTS = 256, SIGNATURE_BYTES = 1286 };

static JbedTypeId descriptor_type(JbedVm *vm, const char **cursor, bool *reference)
{
    const char *start = *cursor, *p = start;
    *reference = *p == 'L' || *p == '[';
    while (*p == '[') ++p;
    if (*p == 'L') {
        const char *end = strchr(p, ';');
        if (!end) jbed_vm_fatal(vm, "Invalid guest callback descriptor");
        p = end + 1;
    } else if (*p && strchr("VZCFDBSIJ", *p)) {
        ++p;
    } else jbed_vm_fatal(vm, "Invalid guest callback type");
    *cursor = p;
    if (!*reference) {
        if (*start == 'V') return 0;
        const char *codes = "ZCFDBSIJ";
        return (JbedTypeId)(JBED_TYPE_BOOLEAN + (strchr(codes, *start) - codes));
    }
    if (*start == 'L') { ++start; --p; }
    JbedTypeId type = jbed_vm_lookup_type(vm, start, (size_t)(p - start), true, false);
    if (!type) jbed_vm_raise(vm, JBED_ERROR_NO_CLASS_DEF, "Guest callback type is absent");
    return type;
}

uint64_t jbed_vm_guest_call(JbedVm *vm, JbedGuestCallKind kind, const char *owner,
    const char *name, const char *descriptor, uint32_t *arguments, size_t count)
{
    if (count > MAX_ARGUMENTS || *descriptor++ != '(')
        jbed_vm_fatal(vm, "Invalid guest callback arguments");
    JbedTypeId types[MAX_ARGUMENTS + 1];
    JbedVmHeapRoot roots[MAX_ARGUMENTS];
    unsigned slots[MAX_ARGUMENTS], root_count = 0, type_count = 0;
    size_t words = kind == JBED_GUEST_STATIC ? 0 : 1;
    if (words) {
        if (!count || !arguments[0]) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
        slots[root_count++] = 0;
    }
    while (*descriptor && *descriptor != ')') {
        bool reference;
        JbedTypeId type = descriptor_type(vm, &descriptor, &reference);
        if (type_count == MAX_ARGUMENTS) jbed_vm_fatal(vm, "Too many guest callback parameters");
        types[type_count++] = type;
        if (words >= count || (reference && root_count == MAX_ARGUMENTS))
            jbed_vm_fatal(vm, "Guest callback argument overflow");
        if (reference) slots[root_count++] = (unsigned)words;
        words += type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE ? 2 : 1;
    }
    if (*descriptor++ != ')' || words != count)
        jbed_vm_fatal(vm, "Guest callback word count mismatch");
    bool reference;
    types[type_count++] = descriptor_type(vm, &descriptor, &reference);
    if (*descriptor) jbed_vm_fatal(vm, "Trailing guest callback descriptor");
    JbedVmHeapRoot *saved = vm->heap.temporary_roots;
    for (unsigned i = 0; i < root_count; ++i) {
        roots[i] = (JbedVmHeapRoot){arguments[slots[i]], arguments[slots[i]], vm->heap.temporary_roots};
        vm->heap.temporary_roots = &roots[i];
    }
    JbedAddress tag = kind == JBED_GUEST_STATIC ? 0 : jbed_vm_word(vm->heap.memory, arguments[0]);
    JbedAddress address = kind == JBED_GUEST_VIRTUAL ? jbed_vm_word(vm->heap.memory, tag)
        : jbed_vm_find_class(vm, owner);
    JbedClass *klass = jbed_class_from_target(&vm->classes, address);
    JbedNameId id = jbed_reflection_id(&vm->method_names, (const uint8_t *)name, strlen(name), false);
    JbedSignatureServices services = {.runtime = &vm->services,
        .reflection_table = &vm->signatures, .types = jbed_signature_rom_types()};
    uint8_t bytes[SIGNATURE_BYTES];
    JbedSignatureEncoder encoder;
    jbed_signature_init(&encoder, &services);
    encoder.bytes = bytes; /* Decoding must not allocate a buffer per callback. */
    JbedMethod *method = NULL;
    for (; klass && !method; klass = klass->superclass)
        for (JbedMethod *m = klass->methods; m; m = m->next) {
            if (m->name_id != id || !!(m->flags & JBED_ACC_STATIC) != (kind == JBED_GUEST_STATIC)) continue;
            jbed_signature_open(&encoder, m->signature_id);
            bool matches = true;
            for (unsigned i = 0; i < type_count; ++i)
                if (jbed_signature_next(&encoder) != types[i]) { matches = false; break; }
            if (matches && types[type_count - 1] != 0 &&
                jbed_signature_next(&encoder) != JBED_SIGNATURE_END) matches = false;
            jbed_signature_close(&encoder, m->signature_id);
            if (matches) { method = m; break; }
        }
    if (!method) jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, name);
    JbedAddress entry = kind == JBED_GUEST_VIRTUAL && method->dispatch_slot >= 0
        ? jbed_vm_word(vm->heap.memory, tag + 8 + 4u * (unsigned)method->dispatch_slot)
        : method->code_address;
    for (unsigned i = 0; i < root_count; ++i) arguments[slots[i]] = roots[i].value;
    uint64_t result;
    bool success = jbed_vm_invoke(vm, entry, arguments, count, &result);
    for (unsigned i = 0; i < root_count; ++i) arguments[slots[i]] = roots[i].value;
    vm->heap.temporary_roots = saved;
    if (!success) {
        JbedAddress throwable = vm->pending_exception;
        vm->pending_exception = 0;
        jbed_raise(&vm->services, &(JbedError){.kind = JBED_ERROR_THROWABLE,
            .runtime_throwable = jbed_vm_at(vm->heap.memory, throwable)});
    }
    return result;
}
