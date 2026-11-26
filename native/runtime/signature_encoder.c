#include "rom_reflection.h"
#include "compiler.h"
#include "class_access.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum {
    SIGNATURE_BYTES = 12, SIGNATURE_LENGTH = 16, SIGNATURE_HIGH_NIBBLE = 20,
    SIGNATURE_ADDED_VOID = 21, SIGNATURE_CURRENT_ID = 24, SIGNATURE_INDEX = 28,
    SIGNATURE_CLASSES = 32, SIGNATURE_CAPACITY = 1286, ARRAY_DATA = 16
};

typedef struct SignatureCall {
    JbedVm *vm;
    JbRef object;
    JbedVmHeapRoot root;
    JbedSignatureServices services;
    JbedSignatureEncoder local, *encoder;
    uint8_t bytes[SIGNATURE_CAPACITY];
    int32_t arguments[5], result;
    char *descriptor;
} SignatureCall;

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "SignatureEncoder call outside a Jbed VM");
    return vm;
}

static void begin(SignatureCall *call, JbRef object)
{
    JbedVm *vm = active();
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    call->vm = vm;
    call->object = object;
    call->root = (JbedVmHeapRoot){object, object, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &call->root;
    JbedAddress root = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Compiler", "sigEnc");
    if (root && object == jbed_vm_word(vm->heap.memory, root)) {
        call->encoder = jbed_vm_compiler_signatures(vm);
        return;
    }
    JbedBuffer memory = vm->heap.memory;
    JbRef bytes = jbed_vm_word(memory, object + SIGNATURE_BYTES);
    if (bytes) memcpy(call->bytes, jbed_vm_at(memory, bytes + ARRAY_DATA), SIGNATURE_CAPACITY);
    call->services = (JbedSignatureServices){.runtime = &vm->services,
        .reflection_table = &vm->signatures, .types = jbed_signature_rom_types(),
        .class_access = jbed_vm_class_access_for_object(vm,
            jbed_vm_word(memory, object + SIGNATURE_CLASSES))};
    call->local = (JbedSignatureEncoder){.services = &call->services,
        .bytes = bytes ? call->bytes : NULL,
        .byte_count = (int32_t)jbed_vm_word(memory, object + SIGNATURE_LENGTH),
        .high_nibble = *jbed_vm_at(memory, object + SIGNATURE_HIGH_NIBBLE) != 0,
        .added_void = *jbed_vm_at(memory, object + SIGNATURE_ADDED_VOID) != 0,
        .current_id = (int32_t)jbed_vm_word(memory, object + SIGNATURE_CURRENT_ID),
        .nibble_index = jbed_vm_word(memory, object + SIGNATURE_INDEX)};
    call->encoder = &call->local;
}

static JbRef finish(SignatureCall *call, bool expose_buffer)
{
    JbedVm *vm = call->vm;
    JbedBuffer memory = vm->heap.memory;
    JbedSignatureEncoder *encoder = call->encoder;
    JbRef bytes = jbed_vm_word(memory, call->root.value + SIGNATURE_BYTES);
    if (encoder->bytes && (encoder == &call->local || expose_buffer)) {
        if (!bytes) {
            bytes = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE],
                                            SIGNATURE_CAPACITY, false);
            jbed_vm_put_word(memory, call->root.value + SIGNATURE_BYTES, bytes);
        }
        if (jbed_vm_at(memory, bytes + ARRAY_DATA) != encoder->bytes)
            memcpy(jbed_vm_at(memory, bytes + ARRAY_DATA), encoder->bytes, SIGNATURE_CAPACITY);
    }
    JbRef object = call->root.value;
    jbed_vm_put_word(memory, object + SIGNATURE_LENGTH, (uint32_t)encoder->byte_count);
    *jbed_vm_at(memory, object + SIGNATURE_HIGH_NIBBLE) = encoder->high_nibble;
    *jbed_vm_at(memory, object + SIGNATURE_ADDED_VOID) = encoder->added_void;
    jbed_vm_put_word(memory, object + SIGNATURE_CURRENT_ID, (uint32_t)encoder->current_id);
    jbed_vm_put_word(memory, object + SIGNATURE_INDEX, encoder->nibble_index);
    vm->heap.temporary_roots = call->root.previous;
    return bytes;
}

static JbRef operate(SignatureCall *call, void (*operation)(void *), bool expose_buffer)
{
    JbedError error;
    bool success = call->vm->services.protected_call(call->vm->services.context,
        operation, call, &error);
    call->vm->heap.temporary_roots = &call->root;
    JbRef bytes = finish(call, expose_buffer);
    if (!success) jbed_raise(&call->vm->services, &error);
    return bytes;
}

JbRef jbed_vm_signature_encoder_new(JbedVm *vm, JbedClassAccess *classes)
{
    JbedAddress klass = jbed_vm_find_class(vm, "com/jbed/reflect/SignatureEncoder");
    if (!klass || !classes || !classes->guest_root)
        jbed_vm_fatal(vm, "SignatureEncoder requires a published ClassAccess");
    JbRef object = jbed_vm_allocate_object(vm, klass, false);
    jbed_vm_put_word(vm->heap.memory, object + SIGNATURE_CLASSES,
        jbed_vm_word(vm->heap.memory, classes->guest_root));
    return object;
}

void SignatureEncoder_init(JbRef object, JbRef classes)
{
    JbedVm *vm = active();
    jbed_vm_put_word(vm->heap.memory, object + SIGNATURE_CLASSES, classes);
}

JbRef SignatureEncoder_copyIfInUse(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    JbRef result = call.encoder->current_id
        ? jbed_vm_signature_encoder_new(call.vm, call.encoder->services->class_access)
        : call.root.value;
    call.vm->heap.temporary_roots = call.root.previous;
    return result;
}

JbRef SignatureEncoder_getReflTable(void)
{
    JbedVm *vm = active();
    if (!vm->reflection_roots[4]) jbed_vm_fatal(vm, "Missing signature reflection root");
    return jbed_vm_word(vm->heap.memory, vm->reflection_roots[4]);
}

static void run_getBuf(void *context)
{
    SignatureCall *call = context;
    jbed_signature_buffer(call->encoder);
}

JbRef SignatureEncoder_getBuf(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    return operate(&call, run_getBuf, true);
}

static void run_startSignature(void *context)
{
    SignatureCall *call = context;
    jbed_signature_start(call->encoder);
}

void SignatureEncoder_startSignature(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_startSignature, false);
}

static void run_addShort(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_short(call->encoder, call->arguments[0]);
}

void SignatureEncoder_addShort(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_addShort, false);
}

static void run_addClassId(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_class_id(call->encoder, call->arguments[0]);
}

void SignatureEncoder_addClassId(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_addClassId, false);
}

static void run_addLongClassId(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_long_class_id(call->encoder, call->arguments[0]);
}

void SignatureEncoder_addLongClassId(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_addLongClassId, false);
}

static void run_addVoid(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_void(call->encoder);
}

void SignatureEncoder_addVoid(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_addVoid, false);
}

static void run_addPrimitive(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_primitive(call->encoder, call->arguments[0]);
}

void SignatureEncoder_addPrimitive(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_addPrimitive, false);
}

static void run_getBuiltSignatureId(void *context)
{
    SignatureCall *call = context;
    call->result = jbed_signature_finish(call->encoder);
}

int32_t SignatureEncoder_getBuiltSignatureId(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_getBuiltSignatureId, false);
    return call.result;
}

static void run_builtSignatureReturnsVoid(void *context)
{
    SignatureCall *call = context;
    call->result = jbed_signature_returns_void(call->encoder);
}

bool SignatureEncoder_builtSignatureReturnsVoid(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_builtSignatureReturnsVoid, false);
    return call.result;
}

static void run_discardBuiltSignature(void *context)
{
    SignatureCall *call = context;
    jbed_signature_discard(call->encoder);
}

void SignatureEncoder_discardBuiltSignature(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_discardBuiltSignature, false);
}

static void run_openSignature(void *context)
{
    SignatureCall *call = context;
    jbed_signature_open(call->encoder, call->arguments[0]);
}

void SignatureEncoder_openSignature(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_openSignature, false);
}

static void run_getNextSignatureType(void *context)
{
    SignatureCall *call = context;
    call->result = jbed_signature_next(call->encoder);
}

int32_t SignatureEncoder_getNextSignatureType(JbRef object)
{
    SignatureCall call;
    begin(&call, object);
    operate(&call, run_getNextSignatureType, false);
    return call.result;
}

static void run_closeSignature(void *context)
{
    SignatureCall *call = context;
    jbed_signature_close(call->encoder, call->arguments[0]);
}

void SignatureEncoder_closeSignature(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_closeSignature, false);
}

static void run_idToSignature(void *context)
{
    SignatureCall *call = context;
    call->descriptor = jbed_signature_descriptor(call->encoder, call->arguments[0]);
}

JbRef SignatureEncoder_idToSignature(JbRef object, int32_t argument)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = argument;
    operate(&call, run_idToSignature, false);
    return JbedKNI_NewUtfString(call.descriptor, false);
}

static void run_addPrimitiveArray(void *context)
{
    SignatureCall *call = context;
    jbed_signature_add_primitive_array(call->encoder, (uint32_t)call->arguments[0],
                                        (JbedTypeId)call->arguments[1]);
}

void SignatureEncoder_addPrimitiveArray(JbRef object, int32_t dimensions, int32_t type)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = dimensions;
    call.arguments[1] = type;
    operate(&call, run_addPrimitiveArray, false);
}

static void run_addClassType(void *context)
{
    SignatureCall *call = context;
    JbRef bytes = (JbRef)call->arguments[0];
    int32_t start = call->arguments[1], end = call->arguments[2];
    int32_t slash = call->arguments[3], dimensions = call->arguments[4];
    JbedClassAccess *classes = call->encoder->services->class_access;
    JbedTypeId id = (JbedTypeId)ClassAccess_getClassIdBytes(
        jbed_vm_word(call->vm->heap.memory, classes->guest_root),
        bytes, start, end, slash, dimensions);
    if (id == call->encoder->services->types.object)
        jbed_signature_add_short(call->encoder, JBED_SIGNATURE_OBJECT);
    else if (id == call->encoder->services->types.string)
        jbed_signature_add_short(call->encoder, JBED_SIGNATURE_STRING);
    else
        jbed_signature_add_class_id(call->encoder, id);
}

void SignatureEncoder_addClassType(JbRef object, JbRef bytes, int32_t start, int32_t end,
                                    int32_t slash, int32_t dimensions)
{
    SignatureCall call;
    begin(&call, object);
    call.arguments[0] = (int32_t)bytes;
    call.arguments[1] = start;
    call.arguments[2] = end;
    call.arguments[3] = slash;
    call.arguments[4] = dimensions;
    operate(&call, run_addClassType, false);
}

void SignatureEncoder_initialize(void)
{
    JbedVm *vm = active();
    static const struct { const char *field, *name; } types[] = {
        {"objectId", "java/lang/Object"}, {"stringId", "java/lang/String"},
        {"intArrayId", "[I"}, {"byteArrayId", "[B"}, {"charArrayId", "[C"}
    };
    for (size_t i = 0; i < sizeof(types) / sizeof(*types); ++i) {
        JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/reflect/SignatureEncoder", types[i].field);
        JbedAddress klass = jbed_vm_find_class(vm, types[i].name);
        if (!slot || !klass) jbed_vm_fatal(vm, "Missing signature type metadata");
        jbed_vm_put_word(vm->heap.memory, slot, jbed_vm_word(vm->heap.memory, klass + 16));
    }
}
