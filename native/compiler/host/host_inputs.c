#include "host_inputs.h"

#include <zip.h>
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static bool input_error(char *error, size_t size, const char *path, const char *reason)
{
    if (size)
        snprintf(error, size, "%s: %s", path, reason);
    return false;
}

static uint16_t u16(const uint8_t *p)
{
    return (uint16_t)(p[0] | (uint16_t)p[1] << 8);
}

static uint32_t u32(const uint8_t *p)
{
    return (uint32_t)u16(p) | (uint32_t)u16(p + 2) << 16;
}

static void put32(uint8_t *p, uint32_t value)
{
    for (unsigned i = 0; i < 4; ++i)
        p[i] = (uint8_t)(value >> (8 * i));
}

enum { PT_LOAD = 1, PT_DYNAMIC = 2, DT_REL = 17, DT_RELSZ = 18, DT_RELENT = 19,
       R_ARM_RELATIVE = 23 };

static bool inside(size_t size, uint32_t offset, uint32_t length)
{
    return offset <= size && length <= size - offset;
}

static const uint8_t *file_address(const uint8_t *file, const uint8_t *ph, unsigned stride,
                                   unsigned count, uint32_t address, uint32_t length)
{
    for (unsigned i = 0; i < count; ++i, ph += stride) {
        uint32_t start = u32(ph + 8);
        if (u32(ph) == PT_LOAD && address >= start &&
            inside(u32(ph + 16), address - start, length))
            return file + u32(ph + 4) + (address - start);
    }
    return NULL;
}

/* Only the ELF object's own ROM pointers participate in offline compilation.
 * The external symbols in its GOT and PLT belong to the Android native runtime. */
static const char *map_rom(const uint8_t *file, size_t size, JbedAddress base, JbedBuffer *out)
{
    if (size < 52 || memcmp(file, "\177ELF\1\1\1", 7) ||
        u16(file + 16) != 3 || u16(file + 18) != 40)
        return "expected a little-endian ARM ELF32 shared library";
    uint32_t phoff = u32(file + 28);
    unsigned stride = u16(file + 42), count = u16(file + 44);
    if (stride < 32 || !inside(size, phoff, stride * count))
        return "invalid ELF program header table";
    const uint8_t *headers = file + phoff, *dynamic = NULL;
    uint32_t dynamic_size = 0, image_size = 0;
    for (unsigned i = 0; i < count; ++i) {
        const uint8_t *ph = headers + i * stride;
        uint32_t type = u32(ph), offset = u32(ph + 4), address = u32(ph + 8);
        uint32_t filesz = u32(ph + 16), memsz = u32(ph + 20);
        if (type != PT_LOAD && type != PT_DYNAMIC)
            continue;
        if (!inside(size, offset, filesz))
            return "ELF segment extends beyond the file";
        if (type == PT_DYNAMIC) {
            dynamic = file + offset;
            dynamic_size = filesz;
        } else {
            if (memsz < filesz || memsz > UINT32_MAX - address)
                return "invalid ELF load segment size";
            if (address + memsz > image_size)
                image_size = address + memsz;
        }
    }
    if (!dynamic || !image_size || (uint64_t)base + image_size > (uint64_t)UINT32_MAX + 1)
        return "ELF image does not fit at the requested base";
    uint32_t rel = 0, relsz = 0, relent = 0;
    for (uint32_t offset = 0; dynamic_size - offset >= 8; offset += 8) {
        uint32_t tag = u32(dynamic + offset), value = u32(dynamic + offset + 4);
        if (!tag)
            break;
        if (tag == DT_REL)
            rel = value;
        else if (tag == DT_RELSZ)
            relsz = value;
        else if (tag == DT_RELENT)
            relent = value;
    }
    if (!rel || !relsz || relent != 8 || relsz % relent)
        return "invalid ELF REL table";
    const uint8_t *entries = file_address(file, headers, stride, count, rel, relsz);
    if (!entries)
        return "ELF REL table lies outside the load segments";
    uint8_t *image = calloc(1, image_size);
    if (!image)
        return "cannot allocate the ROM image";
    for (unsigned i = 0; i < count; ++i) {
        const uint8_t *ph = headers + i * stride;
        if (u32(ph) == PT_LOAD)
            memcpy(image + u32(ph + 8), file + u32(ph + 4), u32(ph + 16));
    }
    for (uint32_t offset = 0; offset < relsz; offset += 8) {
        uint32_t site = u32(entries + offset), info = u32(entries + offset + 4);
        if ((info & 0xff) != R_ARM_RELATIVE)
            continue;
        if (!inside(image_size, site, 4) || info >> 8 || u32(image + site) > UINT32_MAX - base) {
            free(image);
            return "invalid R_ARM_RELATIVE relocation";
        }
        put32(image + site, base + u32(image + site));
    }
    *out = (JbedBuffer){.data = image, .size = image_size, .address = base};
    return NULL;
}

bool jbed_host_read_rom(const char *path, JbedAddress base, JbedBuffer *out, char *error, size_t size)
{
    *out = (JbedBuffer){0};
    FILE *fp = fopen(path, "rb");
    if (!fp)
        return input_error(error, size, path, strerror(errno));
    const char *reason = NULL;
    long length = fseek(fp, 0, SEEK_END) == 0 ? ftell(fp) : -1;
    if (length <= 0 || (unsigned long)length > UINT32_MAX || fseek(fp, 0, SEEK_SET))
        reason = "cannot read the ELF file size";
    else {
        uint8_t *file = malloc((size_t)length);
        if (!file)
            reason = "cannot allocate the ELF input";
        else if (fread(file, 1, (size_t)length, fp) != (size_t)length)
            reason = "cannot read the ELF file";
        else
            reason = map_rom(file, (size_t)length, base, out);
        free(file);
    }
    fclose(fp);
    return !reason || input_error(error, size, path, reason);
}

static bool read_class(zip_t *jar, zip_uint64_t index, const zip_stat_t *entry, size_t name_len,
                       JbedHostClassFn define, void *context, char *error, size_t size)
{
    if (!(entry->valid & ZIP_STAT_SIZE) || !entry->size || entry->size > INT32_MAX)
        return input_error(error, size, entry->name, "invalid class file size");
    zip_file_t *file = zip_fopen_index(jar, index, 0);
    if (!file)
        return input_error(error, size, entry->name, zip_strerror(jar));
    char *name = malloc(name_len + 1);
    uint8_t *bytes = malloc((size_t)entry->size);
    bool ok = false;
    if (!name || !bytes) {
        input_error(error, size, entry->name, "cannot allocate class file");
    } else {
        memcpy(name, entry->name, name_len);
        name[name_len] = 0;
        size_t read = 0;
        while (read < entry->size) {
            zip_int64_t part = zip_fread(file, bytes + read, entry->size - read);
            if (part <= 0)
                break;
            read += (size_t)part;
        }
        uint8_t extra;
        if (read != entry->size || zip_fread(file, &extra, 1) != 0)
            input_error(error, size, entry->name, "cannot read class file");
        else {
            ok = define(context, name, bytes, read);
            if (!ok && size && !error[0])
                input_error(error, size, entry->name, "class definition failed");
        }
    }
    if (zip_fclose(file) != 0 && ok)
        ok = input_error(error, size, entry->name, "cannot close class file");
    free(bytes);
    free(name);
    return ok;
}

bool jbed_host_read_jar(const char *path, JbedHostClassFn define, void *context, char *error,
                        size_t size)
{
    if (size)
        error[0] = 0;
    int code;
    zip_t *jar = zip_open(path, ZIP_RDONLY, &code);
    if (!jar) {
        zip_error_t failure;
        zip_error_init_with_code(&failure, code);
        input_error(error, size, path, zip_error_strerror(&failure));
        zip_error_fini(&failure);
        return false;
    }
    zip_int64_t count = zip_get_num_entries(jar, 0);
    bool ok = count >= 0;
    if (!ok)
        input_error(error, size, path, zip_strerror(jar));
    for (zip_int64_t i = 0; ok && i < count; ++i) {
        zip_stat_t entry;
        if (zip_stat_index(jar, (zip_uint64_t)i, ZIP_FL_ENC_RAW, &entry) < 0) {
            ok = input_error(error, size, path, zip_strerror(jar));
            break;
        }
        size_t n = strlen(entry.name);
        if (n > 6 && !strcmp(entry.name + n - 6, ".class"))
            ok = read_class(jar, (zip_uint64_t)i, &entry, n - 6, define, context, error, size);
    }
    zip_discard(jar);
    return ok;
}
