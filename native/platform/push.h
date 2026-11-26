#ifndef JBED_PLATFORM_PUSH_H
#define JBED_PLATFORM_PUSH_H

#include <stddef.h>
#include <stdint.h>

typedef struct PushFile PushFile;
typedef struct PushEntry PushEntry;
typedef struct SmsMessage SmsMessage;

enum { SMS_PUSH = 0x10000, SMS_CBS = 0x20000 };

#define PUSH_FILE_ERROR ((PushFile *)(intptr_t)-1)
PushFile *CPL_push_open(int operation);
char *CPL_push_read(PushFile *);
int CPL_push_write(PushFile *, const char *);
int CPL_push_close(PushFile *);

struct SmsMessage {
    SmsMessage *next;
    char sender[36];
    int32_t sender_length;
    uint8_t type;
    uint16_t length, source_port, destination_port;
    int64_t timestamp;
    uint8_t *data;
};

struct VmNotifier;
void jbed_handle_sms_sendresult(struct VmNotifier *, uint8_t result);
void CPL_sms_notifyReader(void);
int CPL_sms_register(int port, int info);
void CPL_sms_deregister(int port);
SmsMessage *CPL_sms_poll(int port);
void CPL_sms_free(SmsMessage *);
const char *CPL_sms_msisdn(const SmsMessage *);
int jbed_handle_newSms(const char *sender, size_t sender_length, uint16_t source_port,
                       int destination_port, uint8_t type, int64_t timestamp,
                       const void *data, uint16_t length);
void CPL_wma_init(void);
void CPL_wma_shutdown(void);
extern uint8_t exitSmsThread;

SmsMessage *Jbed_push_sms_get_queued(PushEntry *);
int Jbed_push_sms_is_push_port(int port);
PushEntry *Jbed_push_sms_get_open_port(int port);
void Jbed_push_io_activity(void);
int Jbed_push_hand_back(PushEntry *);

const char *push_field(const char *record, int index);
int push_matchConn(const char *connection, const char *record);
int Jbed_push_check_next_push(void);
int64_t Jbed_push_get_next_alarm_time(void);
void Jbed_push_handle_boot(int start);
void Jbed_push_handle_vm_start(void);
void Jbed_push_handle_vm_exit_or_reset(void);
void Jbed_push_handle_shutdown(void);
#endif
