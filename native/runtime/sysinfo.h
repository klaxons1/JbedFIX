#ifndef JBED_SOURCE_SYSINFO_H
#define JBED_SOURCE_SYSINFO_H

#include "runtime.h"

JbedAddress SysInfo_getFirstString(void);
JbedAddress SysInfo_getProperty(JbedAddress name);

#endif
