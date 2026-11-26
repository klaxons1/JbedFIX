#include "jbni_objects.h"
#include "vm_helpers.h"

#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

extern JbString *Jbni_intern_newEmptyStringLen(int units);
extern void Jbed_sendComplexEvent(int isolate, int code, int value, void *payload);

struct JbUpcallQueue {
    JbUpcallQueue *next;
    int priority;
    int read, write, capacity, writing, reading;
    int words[];
};

static JbUpcallQueue *queues;

JbUpcallQueue *Jbed_upcall_createQueue(int capacity, int priority)
{
    JbUpcallQueue *q = malloc(sizeof(*q) + (uint32_t)capacity * 4u + 3);
    if (!q)
        return NULL;
    q->priority = priority;
    q->capacity = capacity;
    q->write = q->read = 0;
    q->reading = q->writing = -1;
    JbUpcallQueue **link = &queues;
    while (*link && priority > (*link)->priority)
        link = &(*link)->next;
    q->next = *link;
    *link = q;
    return q;
}

void Jbed_upcall_deleteQueue(JbUpcallQueue *q)
{
    JbUpcallQueue **link = &queues;
    while (*link && *link != q)
        link = &(*link)->next;
    *link = q->next;
    free(q);
}

int Jbed_upcall_check(void)
{
    for (JbUpcallQueue *q = queues; q; q = q->next)
        if (q->read != q->write)
            return 1;
    return 0;
}

static int advance(JbUpcallQueue *q, int index, int words)
{
    index += words;
    return index >= q->capacity ? index - q->capacity : index;
}

static int space(JbUpcallQueue *q)
{
    int distance = q->read - q->writing;
    return distance <= 0 ? distance + q->capacity : distance;
}

static int put_word(JbUpcallQueue *q, int word)
{
    if (space(q) <= 1) return 0;
    q->words[q->writing] = word;
    q->writing = advance(q, q->writing, 1);
    return 1;
}

static int begin_event(JbUpcallQueue *q, int isolate, int code, int value)
{
    q->writing = q->write;
    return put_word(q, 0) && put_word(q, isolate) && put_word(q, code) && put_word(q, value);
}

static int end_event(JbUpcallQueue *q, int success)
{
    if (success)
        q->write = q->writing;
    q->writing = -1;
    return success;
}

int Jbed_upcall_sendSimple(JbUpcallQueue *q, int isolate, int code, int value)
{
    return end_event(q, begin_event(q, isolate, code, value));
}

/* A positive tag encodes (UTF-16 length + 1), a negative tag encodes ~int_count. */
static int put_buffer(JbUpcallQueue *q, int tag, const void *source, int bytes)
{
    int words = (bytes + 3) / 4;
    if (!put_word(q, tag)) return 0;
    if (words) {
        if (words >= space(q)) return 0;
        int first = (q->capacity - q->writing) * 4;
        if (first > bytes) first = bytes;
        memcpy(&q->words[q->writing], source, first);
        if (first < bytes)
            memcpy(q->words, (const char *)source + first, bytes - first);
        q->writing = advance(q, q->writing, words);
    }
    ++q->words[q->write];
    return 1;
}

static int put_ascii(JbUpcallQueue *q, const char *text)
{
    int length = (int)strlen(text);
    int words = (2 * length + 3) / 4;
    if (!put_word(q, length + 1) || words >= space(q)) return 0;
    if (words > 0) {
        int first = (q->capacity - q->writing) * 2;
        if (first > length) first = length;
        Jbni_convertAsciiToUcs2(text, first, (uint16_t *)&q->words[q->writing], first * 2);
        if (first < length)
            Jbni_convertAsciiToUcs2(text + first, length - first, (uint16_t *)q->words, (length - first) * 2);
        q->writing = advance(q, q->writing, words);
    }
    ++q->words[q->write];
    return 1;
}

int Jbed_upcall_sendComplex(JbUpcallQueue *q, int isolate, int code, int value, const char *format, ...)
{
    int success = begin_event(q, isolate, code, value);
    va_list args;
    va_start(args, format);
    for (; success && *format; ++format) {
        switch (*format) {
        case 'i': {
            int item = va_arg(args, int);
            success = put_word(q, -2) && put_word(q, item);
            if (success) ++q->words[q->write];
            break;
        }
        case 'a':
            success = put_ascii(q, va_arg(args, const char *));
            break;
        case 'I': {
            const int *items = va_arg(args, const int *);
            int count = va_arg(args, int);
            success = put_buffer(q, ~count, items, count * 4);
            break;
        }
        case 's': {
            const uint16_t *text = va_arg(args, const uint16_t *);
            int count = va_arg(args, int);
            success = put_buffer(q, count + 1, text, count * 2);
            break;
        }
        case 'S': {
            const uint16_t *const *texts = va_arg(args, const uint16_t *const *);
            int count = va_arg(args, int);
            for (int i = 0; success && i < count; ++i) {
                int n = 0;
                if (texts[i]) while (texts[i][n]) ++n;
                success = put_buffer(q, n + 1, texts[i], n * 2);
            }
            break;
        }
        }
    }
    va_end(args);
    return end_event(q, success);
}

static int get_word(JbUpcallQueue *q)
{
    int value = q->words[q->reading];
    q->reading = advance(q, q->reading, 1);
    return value;
}

static void get_buffer(JbUpcallQueue *q, void *dest, int bytes)
{
    if (!bytes) return;
    int first = (q->capacity - q->reading) * 4;
    if (first > bytes) first = bytes;
    memcpy(dest, &q->words[q->reading], first);
    if (first < bytes)
        memcpy((char *)dest + first, q->words, bytes - first);
    q->reading = advance(q, q->reading, (bytes + 3) / 4);
}

static void *get_object(JbUpcallQueue *q)
{
    int tag = get_word(q);
    if (tag > 0) {
        JbString *s = Jbni_intern_newEmptyStringLen(tag - 1);
        if (s && tag != 1)
            get_buffer(q, (void *)jb_string_chars(s), (tag - 1) * 2);
        return s;
    }
    JbArray *a = Jbni_newIntArray(~tag);
    if (a)
        get_buffer(q, a->data, (~tag) * 4);
    return a;
}

typedef struct {
    int isolate, code, value;
    void *payload;
} Upcall;

static int read_event(JbUpcallQueue *q, Upcall *event)
{
    q->reading = q->read;
    int count = get_word(q);
    event->isolate = get_word(q);
    event->code = get_word(q);
    event->value = get_word(q);
    event->payload = NULL;
    int success = 1;
    if (count == 1) {
        event->payload = get_object(q);
    } else if (count > 1) {
        void **saved_roots = Jbed_nativeCallStateAdr;
        JbArray *objects = Jbni_newObjectArray(count);
        *Jbed_nativeCallStateAdr++ = &objects;
        success = objects != NULL;
        for (int i = 0; success && i < count; ++i) {
            void *object = get_object(q);
            success = object != NULL;
            if (success)
                objects->data[i] = jb_ref(object);
        }
        event->payload = objects;
        Jbed_nativeCallStateAdr = saved_roots;
    }
    if (success) q->read = q->reading;
    q->reading = -1;
    return success;
}

int Jbed_upcall_poll(void)
{
    for (JbUpcallQueue *q = queues; q; q = q->next) {
        while (q->read != q->write) {
            Upcall event;
            if (!read_event(q, &event)) return 0;
            Jbed_sendComplexEvent(event.isolate, event.code, event.value, event.payload);
        }
    }
    return 1;
}
