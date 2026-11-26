#ifndef SWERVE_LOADER_H
#define SWERVE_LOADER_H

#include "shared/swvloader.h"

SWV_EXTERN_C_BEGIN

typedef enum LoaderError {
    LoaderError_Error_None = -1, LoaderError_Error_Abort = -2, LoaderError_Error_NotFound = -3,
    LoaderError_Error_Read = -4, LoaderError_Error_UnableToCreate = -5, LoaderError_Error_UnableToFree = -6,
    LoaderError_Error_InvalidHeader = -7, LoaderError_Error_InvalidBody = -8,
    LoaderError_Error_InvalidChecksum = -9, LoaderError_Error_Unknown = -10,
    LoaderError_Error_DataPastEOF = -11
} swvLoaderError;

int loader_create(void **result);
void loader_getbContainsExtensions(void *pThis, int *result);
int loader_onDataStart(void *pThis, int bPermitExtensions, int *result);
int loader_onData(void *pThis, unsigned dataLength, const uint8_t *data, int offset, int length, int *result);
int loader_onDataEnd(void *pThis, int *result);
int loader_onError(void *pThis, int error);
void loader_getRootCount(void *pThis, int *result);
void loader_getRoot(void *pThis, int index, void **result);
void loader_getAuthoringField(void *pThis, unsigned nameLength, uint8_t *name, int *result);
void loader_getXREFName(void *pThis, unsigned nameLength, uint8_t *name, int *result);
void loader_resolveXREF(void *pThis, void *object);

SWV_EXTERN_C_END
#endif
