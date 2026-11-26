#ifndef JBED_VM_TYPES_H
#define JBED_VM_TYPES_H

#include "pool.h"
#include "writer.h"

/* The compiler uses the same linked member representation for classes read from
 * class files and for the resident ROM's compact sixteen-byte member records.
 */
bool jbed_vm_assignable(const JbedClass *destination, const JbedClass *source);
bool jbed_vm_class_visible(const JbedClass *);
JbedMethod *jbed_vm_method_by_number(JbedClass *, int32_t slot);

bool jbed_vm_find_method(const JbedPoolServices *, JbedClass *, JbedNameId, JbedSignatureId,
                         JbedMethod **, JbedError *);
bool jbed_vm_find_field(const JbedPoolServices *, JbedClass *, JbedNameId, JbedTypeId, JbedField **,
                        JbedError *);
bool jbed_vm_method_visible(const JbedPoolServices *, const JbedMethod *);
bool jbed_vm_field_visible(const JbedPoolServices *, const JbedField *);
bool jbed_vm_pool_assignable(const JbedPoolServices *, const JbedClass *, const JbedClass *, bool *,
                             JbedError *);

typedef struct JbedVmClassSlot JbedVmClassSlot;
typedef struct JbedVmClassTable {
    JbedRuntime *runtime;
    JbedImageView image;
    uint32_t index;
    uint16_t id_limit, bucket_mask, overflow_limit;
    JbedVmClassSlot *slots;
    const struct JbedVmClassTable *parent;
} JbedVmClassTable;

/* Image pointers contain relocated target addresses. The runtime owns the
 * materialized class and member records. */
void jbed_vm_class_table_init(JbedVmClassTable *, JbedRuntime *, JbedImageView, uint32_t index);
void jbed_vm_class_table_load(JbedVmClassTable *, JbedRuntime *, JbedImageView, uint32_t index,
                              const JbedVmClassTable *parent);
JbedAddress jbed_vm_class_address(const JbedVmClassTable *, const JbedClass *);
JbedClass *jbed_vm_class_at(const JbedVmClassTable *, JbedAddress);
JbedClass *jbed_vm_class_by_id(const JbedVmClassTable *, JbedTypeId);
JbedClass *jbed_vm_lookup_class(const JbedVmClassTable *, uint16_t package_id,
                                uint16_t base_name_id, int32_t dimensions, bool include_hidden);
/* tag is the dispatch-table pointer stored in the first word of an object. */
bool jbed_vm_instance_of(const JbedVmClassTable *, uint32_t tag, const JbedClass *target);
uint32_t jbed_vm_interface_method(const JbedVmClassTable *, uint32_t tag, const JbedClass *iface,
                                  unsigned slot);
JbedAddress jbed_vm_checkcast(const JbedVmClassTable *, JbedBuffer heap, JbedAddress object,
                              const JbedClass *target);
void jbed_vm_store_array_ref(const JbedVmClassTable *, JbedBuffer heap, JbedAddress array,
                             int32_t index, JbedAddress value, bool check_type);
#endif
