#ifndef JBED_PLATFORM_PIM_H
#define JBED_PLATFORM_PIM_H

#include <stddef.h>
#include <stdint.h>
#include "jbni_objects.h"

/* The embedded VM has 32-bit object references, including on a host inspecting
 * its heap. The Android upcall receives borrowed UTF-16/data pointers. */
typedef JbRef PimRef;
typedef JbArray PimArray;
typedef JbString PimString;

typedef struct {
    uint32_t header[3];
    int32_t id, data_type, capacity, count;
    PimRef attributes, values;
} PimField;

typedef struct {
    uint32_t header[3];
    int32_t id;
    PimRef name;
    uint32_t default_name;
    int32_t handle;
    uint8_t valid, padding[3];
    int32_t open, mode, type;
} PimList;

typedef struct {
    uint32_t header[3];
    PimRef uid, categories, deleted, added, fields;
    uint32_t modified;
    int32_t mode;
    PimRef list;
    uint32_t padding;
    int64_t revision;
} PimItem;

typedef struct {
    PimItem item;
    PimRef repeat_rule;
} PimEvent;

typedef struct {
    uint32_t header[3];
    PimRef except_days, result_dates;
    int32_t frequency, count, interval, month, week_day, week, month_day, year_day, padding;
    int64_t end;
} PimRepeatRule;

enum { PIM_CONTACT = 1, PIM_EVENT = 2, PIM_TODO = 3, PIM_ERROR = -128, PIM_PENDING = -129 };

/* CPL returns a Java array, a native result record, or a negative status. */
typedef intptr_t PimValue;
typedef struct {
    int32_t status, reserved[3];
    void *bytes;
    uint32_t length;
} PimResult;

int android_pim_isSupported(int);
int android_pim_remove(int, const uint16_t *, int);
int android_pim_getNextItem(int, const uint16_t *, int, void **, size_t *);
int android_pim_storeTodo(const uint16_t *, int, const uint16_t *, int, uint8_t, void **, size_t *);
int android_pim_storeEvent(const uint16_t *, int, const uint16_t *, int, const uint16_t *, int,
    const uint16_t *, int, int, int64_t, int64_t, const int32_t *, int, int, int, int, int64_t,
    void **, size_t *);
int android_pim_storeContact(const uint16_t *, int, const uint16_t *, int,
    const int32_t *, const uint16_t *const *, const int32_t *, const uint16_t *, int,
    const uint16_t *, int, const uint16_t *, int,
    const int32_t *, const uint16_t *const *, const int32_t *,
    const int32_t *, const uint16_t *const *, const int32_t *,
    const int32_t *, const uint16_t *const *, const int32_t *,
    const int32_t *, const uint16_t *const *, const int32_t *,
    const void *, size_t, void **, size_t *, int);

int CPL_pim_startUp(void);
int CPL_pim_shutDown(void);
int CPL_pim_closePIMList(int handle);
int CPL_pim_maxValues(int handle, int field);
PimValue CPL_pim_getSuppFields(int handle);
PimValue CPL_pim_getSuppAttrs(int handle, int field);
PimValue CPL_pim_getSuppArrElems(int handle, int field);
PimValue CPL_pim_getSuppRRuleFields(int handle, int frequency);
PimValue CPL_pim_listPIMLists(int type);
PimValue CPL_pim_openPIMList(int type, const PimString *name);
int CPL_pim_removePIMItem(int handle, const PimString *uid);
PimValue CPL_pim_getNextItem(const PimItem *previous, int handle);
PimValue CPL_pim_storeItem(const PimItem *item);
PimArray *getIntArrayFromPIMResult(PimResult *);
PimArray *getByteArrayFromPIMResult(PimResult *);

int CPL_pim_itemMaxCategories(const PimItem *);
int CPL_pim_maxCategories(int handle);
int CPL_pim_addCategory(int handle, const PimString *);
int CPL_pim_deleteCategory(int handle, const PimString *);
int CPL_pim_renameCategory(int handle, const PimString *, const PimString *);
PimValue CPL_pim_getItemCategories(const PimItem *);
PimValue CPL_pim_getCategories(int handle);

typedef struct { int32_t element, supported; } PimElement;
PimValue getSuppElems(const PimElement *options, int count);
PimValue getNameSuppElems(const PimElement *options, int count);
PimValue getContactSuppArrElems(int field);
PimArray *getBinaryDataFromField(const PimField *f, int slot);

int JbniV_com_jbed_pim_PIMImpl_open0(void *self);
void JbniV_com_jbed_pim_PIMImpl_finalize(void *self);
PimArray *JbniV_com_jbed_pim_PIMImpl_listPIMLists0(void *self, int type);
PimString *JbniV_com_jbed_pim_PIMListImpl_open0(PimList *);
void JbniV_com_jbed_pim_PIMListImpl_finalize(PimList *);
void JbniV_com_jbed_pim_PIMListImpl_close0(PimList *);
PimString *JbniV_com_jbed_pim_PIMItemImpl_storeItem0(PimItem *);
PimArray *JbniV_com_jbed_pim_PIMItemEnumerationImpl_getNextItem0(void *, const PimItem *, const PimList *);
void JbniV_com_jbed_pim_ToDoListImpl_removeToDo0(const PimList *, const PimItem *);
void JbniV_com_jbed_pim_EventListImpl_removeEvent0(const PimList *, const PimItem *);
void JbniV_com_jbed_pim_ContactListImpl_removeContact0(const PimList *, const PimItem *);
int JbniV_com_jbed_pim_PIMItemImpl_maxCategories0(const PimItem *);
int JbniV_com_jbed_pim_PIMListImpl_maxCategories0(const PimList *);
int JbniV_com_jbed_pim_PIMListImpl_maxValues0(const PimList *, int field);
PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppArrElems0(const PimList *, int field);
PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppAttrs0(const PimList *, int field);
PimArray *JbniV_com_jbed_pim_EventListImpl_getSuppRRuleFields0(const PimList *, int frequency);
PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppFields0(const PimList *);
PimArray *JbniV_com_jbed_pim_PIMItemImpl_getCategories0(const PimItem *);
PimArray *JbniV_com_jbed_pim_PIMListImpl_getCategories0(const PimList *);
void JbniV_com_jbed_pim_PIMListImpl_renameCategory0(const PimList *, const PimString *, const PimString *);
void JbniV_com_jbed_pim_PIMListImpl_addCategory0(const PimList *, const PimString *);
void JbniV_com_jbed_pim_PIMListImpl_deleteCategory0(const PimList *, const PimString *);

#endif
