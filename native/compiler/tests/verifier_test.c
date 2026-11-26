#include "verifier.h"
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>

static jmp_buf *boundary;
static JbedSignatureEncoder encoder;
enum { VOID_SIG = 0xf00d, INT_SIG = 0xf0ea, INT_INT_SIG = 0xfeaa, LONG_SIG = 0xf0eb };
static JbedSignatureId callee = VOID_SIG;
static bool resolved_while_open;
static JbedError thrown;
static void *allocations[512];
static size_t allocation_count;
static JbedClass object_class = {.id = 462};
static JbedClass owner = {.id = 500, .superclass = &object_class};
static void *allocate(void *context, size_t size)
{
    (void)context;
    void *p = calloc(1, size);
    assert(p);
    assert(allocation_count < sizeof(allocations) / sizeof(allocations[0]));
    allocations[allocation_count++] = p;
    return p;
}
static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    thrown = *error;
    longjmp(*boundary, 1);
}
static void halt(void *context, int32_t code, const char *message)
{
    (void)context;
    (void)code;
    (void)message;
    abort();
}
static bool protect(void *context, void (*body)(void *), void *arg, JbedError *caught)
{
    (void)context;
    jmp_buf local;
    jmp_buf *outer = boundary;
    boundary = &local;
    if (setjmp(local)) {
        *caught = thrown;
        boundary = outer;
        return false;
    }
    body(arg);
    boundary = outer;
    return true;
}
static JbedClass *class_object(void *context, JbedTypeId id)
{
    (void)context;
    if (id == object_class.id && encoder.current_id == 0xf0e0)
        resolved_while_open = true;
    return id == 500 ? &owner : id == 462 ? &object_class : NULL;
}
static bool assignable(void *context, JbedClass *to, JbedClass *from)
{
    (void)context;
    for (; from; from = from->superclass)
        if (from == to)
            return true;
    return false;
}
static size_t pool_size(void *context, JbedPool *pool)
{
    (void)context;
    (void)pool;
    return 4;
}
static uint8_t pool_tag(void *context, JbedPool *pool, uint16_t index)
{
    (void)context;
    (void)pool;
    assert(index == 1 || index == 2);
    return index == 1 ? 10 : 7;
}
static JbedTypeId pool_class(void *context, JbedPool *pool, uint16_t index)
{
    (void)context;
    (void)pool;
    assert(index == 2);
    return 462;
}
static JbedVerifierMemberReference member(void *context, JbedPool *pool, uint16_t index)
{
    (void)context;
    (void)pool;
    assert(index == 1);
    return (JbedVerifierMemberReference){2, 3};
}
static JbedSignatureId member_signature(void *context, JbedPool *pool, uint16_t index)
{
    (void)context;
    (void)pool;
    assert(index == 3);
    return callee;
}
static JbedNameId member_name(void *context, JbedPool *pool, uint16_t index)
{
    (void)context;
    (void)pool;
    assert(index == 3);
    return 10017;
}
static JbedRuntime runtime = {
    .allocate_zeroed = allocate, .raise_error = raise_error, .halt = halt, .protected_call = protect};
static JbedEmitter emitter = {.runtime = &runtime};
static JbedVerifierServices services = {.emitter = &emitter,
                                        .class_object = class_object,
                                        .class_assignable = assignable,
                                        .signature_encoder = &encoder,
                                        .pool_size = pool_size,
                                        .pool_tag = pool_tag,
                                        .pool_class_id = pool_class,
                                        .pool_member_reference = member,
                                        .pool_signature = member_signature,
                                        .pool_name = member_name};
static void check(uint8_t *code, size_t length, uint16_t signature_id, unsigned flags,
                  unsigned locals, unsigned stack, JbedStackMaps maps, unsigned expected)
{
    JbedVerifier verifier;
    JbedMethod method = {.owner = &owner,
                         .flags = flags,
                         .name_id = flags & JBED_ACC_STATIC ? 7 : 10017,
                         .signature_id = signature_id,
                         .max_locals = locals,
                         .max_stack = stack,
                         .code = code,
                         .code_length = length,
                         .stack_maps = maps};
    thrown = (JbedError){0};
    jbed_verifier_init(&verifier, &runtime, &services);
    jmp_buf escape;
    boundary = &escape;
    if (!setjmp(escape))
        jbed_verifier_verify_method(&verifier, &method);
    assert(encoder.current_id == 0);
    assert(thrown.detail_code == expected);
    assert(thrown.kind == (expected ? JBED_ERROR_NO_CLASS_DEF : JBED_ERROR_NONE));
    for (size_t i = 0; i < allocation_count; ++i)
        free(allocations[i]);
    allocation_count = 0;
}
#define RUN(code, sig, flags, locals, stack, map, error)                                           \
    check(code, sizeof(code), sig, flags, locals, stack, map, error)
int main(void)
{
    JbedSignatureServices signature_services = {.runtime = &runtime, .types = jbed_signature_rom_types()};
    jbed_signature_init(&encoder, &signature_services);
    JbedStackMaps none = {0};
    uint8_t returns_void[] = {0xb1};
    RUN(returns_void, VOID_SIG, JBED_ACC_STATIC, 0, 0, none, 0);
    uint8_t identity[] = {0x1a, 0xac};
    RUN(identity, INT_INT_SIG, JBED_ACC_STATIC, 1, 1, none, 0);
    uint8_t wrong_result[] = {0x0b, 0xae};
    RUN(wrong_result, INT_SIG, JBED_ACC_STATIC, 0, 1, none, 30);
    uint8_t empty_pop[] = {0x57, 0xb1};
    RUN(empty_pop, VOID_SIG, JBED_ACC_STATIC, 0, 0, none, 2);
    uint8_t falls_off[] = {0};
    RUN(falls_off, VOID_SIG, JBED_ACC_STATIC, 0, 0, none, 34);
    uint8_t after_return[] = {0xb1, 0xb1};
    RUN(after_return, VOID_SIG, JBED_ACC_STATIC, 0, 0, none, 10);
    uint8_t branch[] = {3, 0xa7, 0, 3, 0xac};
    uint32_t map_words[] = {1, 4, 0, 4, 1, 1};
    JbedStackMaps maps = {map_words, 6};
    RUN(branch, INT_SIG, JBED_ACC_STATIC, 0, 1, maps, 0);
    map_words[5] = 2;
    RUN(branch, INT_SIG, JBED_ACC_STATIC, 0, 1, maps, 8);
    uint8_t constructor[] = {0x2a, 0xb7, 0, 1, 0xb1};
    RUN(constructor, VOID_SIG, 0, 1, 1, none, 0);
    RUN(returns_void, VOID_SIG, 0, 1, 0, none, 32);
    uint8_t pair_overlap[] = {9, 0x40, 3, 0x3d, 0x1f, 0xad};
    RUN(pair_overlap, LONG_SIG, JBED_ACC_STATIC, 3, 2, none, 6);
    uint8_t object_result[] = {0x01, 0xb0};
    RUN(object_result, 0xf0e0, JBED_ACC_STATIC, 0, 1, none, 0);
    assert(resolved_while_open);
    callee = INT_INT_SIG;
    uint8_t missing_argument[] = {0xb8, 0, 1, 0xb1};
    RUN(missing_argument, VOID_SIG, JBED_ACC_STATIC, 0, 1, none, 2);
    puts("Verifier cases passed");
}
