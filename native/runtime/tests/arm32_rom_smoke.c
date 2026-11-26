/* Real runtime + generated ROM, without JNI. For ARM32 Linux under Unicorn.
 * No managed/runtime callbacks are replaced by this driver. */
#include "instance.h"
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

extern const JbedBootImage jbed_boot_image;

static void diagnostic(void *context, const char *phase)
{
    (void)context;
    printf("CHECKPOINT: %s\n", phase);
    fflush(stdout);
}

int main(int argc, char **argv)
{
    char error[512] = {0};
    JbedInstance *instance = jbed_instance_create(&jbed_boot_image,
        8 * 1024 * 1024, 256 * 1024, error, sizeof error);
    if (!instance) { fprintf(stderr, "CREATE FAILED: %s\n", error); return 1; }
    jbed_instance_set_diagnostic(instance, diagnostic, NULL);
    if (argc > 1 && !strcmp(argv[1], "main")) {
        if (!jbed_instance_start_main(instance, "TransformProbe", 0, NULL, NULL, error, sizeof error)) {
            fprintf(stderr, "START FAILED: %s\n", error);
            jbed_instance_destroy(instance);
            return 1;
        }
        int32_t delay = 0, status = -1;
        for (unsigned i = 0; i < 1000; ++i) {
            if (!jbed_instance_iterate(instance, 50, &delay, &status, error, sizeof error)) {
                fprintf(stderr, "ITERATE FAILED: %s\n", error);
                jbed_instance_destroy(instance);
                return 1;
            }
            if (delay == -3) {
                printf("MAIN EXIT: %" PRId32 "\n", status);
                jbed_instance_destroy(instance);
                return status == 0 ? 0 : 1;
            }
        }
        fprintf(stderr, "MAIN FAILED: iteration limit exceeded\n");
        jbed_instance_destroy(instance);
        return 1;
    }
    if (!jbed_instance_initialize(instance, error, sizeof error)) {
        fprintf(stderr, "INITIALIZE FAILED: %s\n", error);
        jbed_instance_destroy(instance);
        return 1;
    }
    uint64_t result = 0;
    JbedAddress throwable = 0;
    bool ok = jbed_instance_call(instance, "TransformProbe", "run", "()I", NULL, 0, &result, &throwable);
    /* ()I defines only r0; the high return word r1 is unspecified. */
    printf("DIRECT: success=%d result=%" PRId32 " throwable=0x%08" PRIx32 "\n", ok, (int32_t)result, throwable);
    jbed_instance_destroy(instance);
    return ok && (int32_t)result == 42 && !throwable ? 0 : 1;
}
