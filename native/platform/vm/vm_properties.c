#include "vm_os.h"
#include "jbni_objects.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>

extern int android_LOGD(const char *format, ...);
extern int Jbni_intern_getStringUtf8(const JbString *, char *, int);

typedef struct Property Property;
struct Property {
    Property *next;
    char text[];  /* Adjacent NUL-terminated key and value. */
};

static Property *properties, *secondary;
static const char *const defaults[] = {
    "file.separator\0/", "vm.buildID\00020110126", "File.basedir\0/Installed/", "File.rootdir\0/"
};

void Jbed_props_startup(void) { properties = secondary = NULL; }

static void free_properties(Property **head)
{
    Property *p = *head;
    *head = NULL;
    while (p) {
        Property *next = p->next;
        free(p);
        p = next;
    }
}

void Jbed_props_shutdown(void)
{
    free_properties(&secondary);
    free_properties(&properties);
}

const char *Jbed_setProperty(const char *key, const char *value)
{
    size_t key_bytes = strlen(key) + 1;
    Property *p = malloc(sizeof(*p) + key_bytes + strlen(value) + 4);
    if (!p) {
        android_LOGD("ALWAYS: Failed to allocate space for property %s\n", key);
        return NULL;
    }
    memcpy(p->text, key, key_bytes);
    strcpy(p->text + key_bytes, value);
    p->next = properties;
    properties = p;
    return p->text + key_bytes;
}

const char *Jbed_getProperty(const char *key)
{
    for (Property *p = properties; p; p = p->next)
        if (strcmp(p->text, key) == 0)
            return p->text + strlen(key) + 1;
    for (size_t i = 0; i < sizeof(defaults)/sizeof(defaults[0]); ++i)
        if (strcmp(defaults[i], key) == 0)
            return defaults[i] + strlen(key) + 1;
    return NULL;
}

const char *Jbed_setPropertyDefault(const char *key, const char *value)
{
    const char *existing = Jbed_getProperty(key);
    return existing ? existing : Jbed_setProperty(key, value);
}

const char *getStorageRoot(void) { return Jbed_getProperty("File.basedir"); }

JbString *JbniS_java_lang_System_getProperty0(const JbString *key)
{
    static char name[128];
    if (Jbni_intern_getStringUtf8(key, name, sizeof(name)) == -1)
        return NULL;
    const char *value = Jbed_getProperty(name);
    return value ? Jbni_intern_newStringExc(value) : NULL;
}

int processMemorySizeValue(const char *value)
{
    char *suffix;
    long parsed = strtol(value, &suffix, 10);
    /* strtol in Bionic returned a signed 32-bit long. */
    if (parsed > INT32_MAX) parsed = INT32_MAX;
    int shift;
    switch (*suffix) {
    case '\0': shift = 0; break;
    case 'K': case 'k': shift = 10; break;
    case 'M': case 'm': shift = 20; break;
    default: return -1;
    }
    if (parsed < 0 || parsed > (INT32_MAX >> shift)) return -1;
    return (int)parsed << shift;
}

void setupMidpHome(const char *home)
{
    if (!home) return;
    char *path = malloc(strlen(home) + 16);
    if (!path) return;
    const char *root = Jbed_getProperty("File.rootdir");
    const char *base = Jbed_getProperty("File.basedir");
    const char *local = Jbed_getProperty("Ams.local-install-dir");
    if (!strcmp(root, "/"))
        Jbed_setProperty("File.rootdir", strcat(strcpy(path, home), "/"));
    if (!strcmp(base, "/Installed/"))
        Jbed_setProperty("File.basedir", strcat(strcpy(path, home), "/Installed/"));
    if (!local)
        Jbed_setProperty("Ams.local-install-dir", strcat(strcpy(path, home), "/LocalInstall/"));
    free(path);
}

static const char usage[] =
    "Command line options:\n"
    "-basedir <uri>         Use <uri> as base-directory for the filesystem.\n"
    "-localInstall <uri>    Use <uri> as browse directory for the ams.\n"
    "-tck <url>             Start the TCKRunner with the given URL.\n"
    "-rootdir <uri>         Use <uri> to set the File.rootdir property.\n"
    "-defaulturl <uri>         Use <uri> as default uri property.\n"
    "-Dkey=value         set property \"key\" to \"value\".\n"
    "-heapsize <size>         java heap size. e.g. 65536 or 128k or 1M.\n"
    "-heapinc <size>          java heap increment for chunked-heaps. e.g. 65536 or 128k or 1M.\n"
    "-heapfirst <size>          java heap size of the first chunk for chunked-heaps. e.g. 65536 or 128k or 1M.\n\n";

char **jbed_processCmdLine(int argc, char **argv, int *count, const char *home)
{
    setupMidpHome(home);
    *count = 0;
    char **remaining = malloc((size_t)argc * sizeof(*remaining));
    if (!remaining) {
        android_LOGD("jbed_processCmdLine: Failed to allocate memory!\n");
        return NULL;
    }
    Jbed_setProperty("com.jbed.ams.Main.manager", "com.jbed.ams.Manager");
    for (int i = 0; i < argc; ++i) {
        const char *arg = argv[i];
        const char *key = NULL;
        if (!strcmp(arg, "-basedir")) key = "File.basedir";
        else if (!strcmp(arg, "-localInstall")) key = "Ams.local-install-dir";
        else if (!strcmp(arg, "-tck")) key = "TCKRunnerMIDP.URL";
        else if (!strcmp(arg, "-orientation") || !strcmp(arg, "-o")) key = "Screen.Orientation";
        else if (!strcmp(arg, "-rootdir")) key = "File.rootdir";
        else if (!strcmp(arg, "-defaulturl")) key = "Ams.default-url";
        if (key) {
            if (++i == argc) {
                android_LOGD("WARNING: missing argument to %s, end of command line string meet!\n", arg);
                break;
            }
            Jbed_setProperty(key, argv[i]);
            if (!strcmp(arg, "-tck")) Jbed_setProperty("com.jbed.ams.Main.manager", "com.jbed.ams.TCKRunner");
            else if (!strcmp(key, "Screen.Orientation")) android_LOGD("Argument to %s is %s!\n", arg, argv[i]);
        } else if (strncmp(arg, "-D", 2) == 0) {
            const char *start = arg + 2, *equal = strchr(arg, '=');
            if (equal && equal > start && equal[1]) {
                size_t n = (size_t)(equal - start);
                char *name = malloc(n + 1);
                if (!name) { free(remaining); return NULL; }
                memcpy(name, start, n);
                name[n] = 0;
                Jbed_setProperty(name, equal + 1);
                free(name);
            }
        } else if (!strcmp(arg, "-heapsize") || !strcmp(arg, "-heapinc") || !strcmp(arg, "-heapfirst")) {
            if (++i == argc) {
                android_LOGD("WARNING: missing argument to %s, end of command line string found!\n", arg);
                break;
            }
            int size = processMemorySizeValue(argv[i]);
            if (size < 0) android_LOGD("Invalid value for %s.\n", arg);
            else if (!strcmp(arg, "-heapsize")) CPL_os_setHeapSize(size);
            else if (!strcmp(arg, "-heapinc")) CPL_os_setHeapIncrementSize(size);
            else CPL_os_setHeapFirstChunkSize(size);
        } else if (!strcmp(arg, "-help")) {
            android_LOGD(usage);
        } else {
            remaining[(*count)++] = argv[i];
        }
    }
    return remaining;
}
