#include "boot_image.h"

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

enum { THUMB_VENEER_BYTES = 16 };

static bool fail(char *error, size_t size, const char *message)
{
    if (error && size)
        snprintf(error, size, "%s", message);
    return false;
}

static void put_word(uint8_t *p, uint32_t value)
{
    p[0] = (uint8_t)value;
    p[1] = (uint8_t)(value >> 8);
    p[2] = (uint8_t)(value >> 16);
    p[3] = (uint8_t)(value >> 24);
}

static void *map_image(size_t size)
{
    /* Field IDs encode ROM constants as negative addresses. Their storage
     * therefore belongs in the positive half of the ARM32 address space. */
    static const uintptr_t hints[] = {0, 0x10000000, 0x30000000, 0x50000000, 0x70000000};
    for (size_t i = 0; i < sizeof(hints) / sizeof(*hints); ++i) {
        void *memory = mmap((void *)hints[i], size, PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (memory == MAP_FAILED) continue;
        if ((uintptr_t)memory <= (uintptr_t)INT32_MAX - size)
            return memory;
        munmap(memory, size);
    }
    return MAP_FAILED;
}

void jbed_boot_unload(JbedLoadedBoot *boot)
{
    if (boot->memory.data)
        munmap(boot->memory.data, boot->memory.size);
    *boot = (JbedLoadedBoot){0};
}

bool jbed_boot_load(JbedLoadedBoot *boot, const JbedBootImage *image, uint32_t writable_bytes, void *runtime,
                    char *error, size_t error_size)
{
    *boot = (JbedLoadedBoot){0};
    if (!image || !image->bytes || !image->size || image->size > UINT32_MAX ||
        image->native_count > UINT32_MAX / THUMB_VENEER_BYTES)
        return fail(error, error_size, "Invalid boot image size");
    if ((uint64_t)image->statics_size + image->globals_size > writable_bytes)
        return fail(error, error_size, "Boot statics exceed the writable allocation");
    long page = sysconf(_SC_PAGESIZE);
    if (page <= 0)
        return fail(error, error_size, "Cannot determine page size");
    uint64_t veneers = (image->size + UINT64_C(3)) & ~UINT64_C(3);
    uint64_t code_size = veneers + image->native_count * THUMB_VENEER_BYTES;
    code_size = (code_size + (uint64_t)page - 1) / (uint64_t)page * (uint64_t)page;
    uint64_t total = code_size + writable_bytes;
    total = (total + (uint64_t)page - 1) / (uint64_t)page * (uint64_t)page;
    if (total > INT32_MAX)
        return fail(error, error_size, "Boot image exceeds the positive ARM32 address range");
    void *allocation = map_image((size_t)total);
    if (allocation == MAP_FAILED)
        return fail(error, error_size, "Cannot reserve a positive ARM32 address range for the boot image");
    *boot = (JbedLoadedBoot){image,
        {(uint8_t *)allocation, (uint32_t)total, (uint32_t)(uintptr_t)allocation},
        (uint32_t)code_size};
    uint8_t *bytes = boot->memory.data;
    uint32_t base = boot->memory.address;
    memcpy(bytes, image->bytes, image->size);
    const char *problem = NULL;
    uintptr_t *fields = NULL;
    if (image->field_count) {
        if (!runtime || image->field_count > SIZE_MAX / sizeof(*fields)) {
            problem = "Boot runtime fields require a VM instance";
            goto failed;
        }
        fields = calloc(image->field_count, sizeof(*fields));
        if (!fields) {
            problem = "Cannot allocate boot field bindings";
            goto failed;
        }
        for (size_t i = 0; i < image->field_count; ++i) {
            fields[i] = image->fields[i].resolve ? (uintptr_t)image->fields[i].resolve(runtime) : 0;
            if (!fields[i] || fields[i] > UINT32_MAX) {
                problem = "Unbound boot runtime field";
                goto failed;
            }
        }
    }
    for (size_t i = 0; i < image->native_count; ++i) {
        uintptr_t target = (uintptr_t)image->natives[i].entry;
        if (!target || target > UINT32_MAX) {
            problem = "Unbound boot native function";
            goto failed;
        }
        uint8_t *p = bytes + veneers + i * THUMB_VENEER_BYTES;
        /* Preserve the fourth argument: push r3; ldr r3; mov ip,r3; pop r3;
         * bx ip; nop. The pointer retains its ARM/Thumb interworking bit. */
        put_word(p, UINT32_C(0x4b02b408));
        put_word(p + 4, UINT32_C(0xbc08469c));
        put_word(p + 8, UINT32_C(0x46c04760));
        put_word(p + 12, (uint32_t)target);
    }
    for (size_t i = 0; i < image->relocation_count; ++i) {
        const JbedBootRelocation *reloc = &image->relocations[i];
        if (image->size < 4 || reloc->offset > image->size - 4) {
            problem = "Boot relocation lies outside the image";
            goto failed;
        }
        uint32_t value;
        switch (reloc->kind) {
        case JBED_BOOT_RUNTIME_FIELD_POINTER:
            if (reloc->target >= image->field_count) {
                problem = "Invalid boot runtime field index";
                goto failed;
            }
            value = (uint32_t)fields[reloc->target];
            break;
        case JBED_BOOT_GLOBAL_POINTER:
            if (reloc->target >= image->globals_size) {
                problem = "Boot global reference lies outside the global block";
                goto failed;
            }
            value = base + (uint32_t)code_size + image->statics_size + reloc->target;
            break;
        case JBED_BOOT_IMAGE_POINTER:
            if ((reloc->target & ~1u) >= image->size) {
                problem = "Boot reference lies outside the image";
                goto failed;
            }
            value = base + reloc->target;
            break;
        case JBED_BOOT_NATIVE_POINTER:
        case JBED_BOOT_NATIVE_THUMB_CALL:
            if (reloc->target >= image->native_count) {
                problem = "Invalid boot native index";
                goto failed;
            }
            if (reloc->kind == JBED_BOOT_NATIVE_POINTER) {
                value = (uint32_t)(uintptr_t)image->natives[reloc->target].entry;
            } else if (!jbed_thumb_call_encode(base + reloc->offset,
                       base + (uint32_t)veneers + reloc->target * THUMB_VENEER_BYTES, &value)) {
                problem = "Boot native call exceeds Thumb branch range";
                goto failed;
            }
            break;
        default:
            problem = "Invalid boot relocation kind";
            goto failed;
        }
        put_word(bytes + reloc->offset, value);
    }
    __builtin___clear_cache((char *)bytes, (char *)bytes + code_size);
    if (mprotect(bytes, (size_t)code_size, PROT_READ | PROT_EXEC)) {
        problem = strerror(errno);
        goto failed;
    }
    free(fields);
    return true;

failed:
    free(fields);
    fail(error, error_size, problem);
    jbed_boot_unload(boot);
    return false;
}

JbedAddress jbed_boot_method(const JbedLoadedBoot *boot, const char *owner, const char *name,
                             const char *descriptor)
{
    for (size_t i = 0; i < boot->image->method_count; ++i) {
        const JbedBootMethod *method = &boot->image->methods[i];
        if (!strcmp(method->owner, owner) && !strcmp(method->name, name) &&
            !strcmp(method->descriptor, descriptor) && (method->offset & ~1u) < boot->image->size)
            return boot->memory.address + method->offset;
    }
    return 0;
}

JbedAddress jbed_boot_class(const JbedLoadedBoot *boot, const char *name)
{
    for (size_t i = 0; i < boot->image->class_count; ++i) {
        const JbedBootClass *klass = &boot->image->classes[i];
        if (!strcmp(klass->name, name) && klass->offset < boot->image->size)
            return boot->memory.address + klass->offset;
    }
    return 0;
}
