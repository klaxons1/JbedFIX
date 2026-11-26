#include "rom_objects.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
static unsigned char bytes[512]; static uint32_t pos;
static bool put(void *c,const void *p,uint32_t n){(void)c;memcpy(bytes+pos,p,n);pos+=n;return true;}
static bool get(void *c,void *p,uint32_t n){(void)c;memcpy(p,bytes+pos,n);pos+=n;return true;}
static void *alloc(void *c,size_t n){(void)c;return calloc(1,n);}
static void fail(void *c,const JbedError *e){(void)c;(void)e;abort();}
static uint32_t adr(void *c,uint32_t a){(void)c;return a?a+0x1000:0;}
static uint32_t label(void *c,uint32_t a){(void)c;return a?a*4+0x2000:0;}
int main(void){
 JbedRuntime rt={.allocate_zeroed=alloc,.raise_error=fail};
 JbedRomServices svc={.runtime=&rt};
 JbedBlockIo io={.read=get,.write=put};
 JbedRomRelocator rel={.address=adr,.label=label};
 uint32_t labels[]={0,7,9},maps[]={0xd0002340,0xe0000040};
 JbedRomObjects r={.services=&svc,.debug_info=true,.sync_index=13,.relative_statics_size=128,
  .pointer_ranges_address=0xd0001000,.string_table=labels,.string_table_count=3,
  .stack_maps=maps,.stack_map_count=2,.package_table=0xd0002000,.base_name_table=0xd0002100,
  .class_ref_table=0xd0002200,.field_name_table=0xd0002300,.method_name_table=0xd0002400,
  .signature_table=0xd0002500,.bundle_id=11};
 assert(jbed_rom_store(&r,&io));
 uint32_t expected[]={1,13,128,0xd0001000,0,3,0,7,9,2,0xd0002340,0xe0000040,
  0xd0002000,0xd0002100,0xd0002200,0xd0002300,0xd0002400,0xd0002500,11};
 assert(pos==sizeof expected);
 for(unsigned i=0;i<sizeof expected/sizeof expected[0];i++){
  uint32_t v=(uint32_t)bytes[i*4]<<24|(uint32_t)bytes[i*4+1]<<16|(uint32_t)bytes[i*4+2]<<8|bytes[i*4+3];
  assert(v==expected[i]);
 }
 JbedRomObjects read; jbed_rom_init(&read,&svc,NULL,false); pos=0;
 assert(jbed_rom_read(&read,&io,&rel));
 assert(read.pointer_ranges_address==adr(0,r.pointer_ranges_address));
 assert(read.string_table[0]==0&&read.string_table[1]==label(0,7));
 assert(read.stack_maps[1]==adr(0,maps[1]));
 assert(read.field_name_table==adr(0,r.field_name_table)&&read.bundle_id==11);
 r.debug_info=false;pos=0;assert(jbed_rom_store(&r,&io));pos=0;
 assert(jbed_rom_read(&read,&io,&rel));assert(read.field_name_table==r.field_name_table);
 puts("ROM footer byte order, labels, code relocation, and debug-table branch passed");
}
