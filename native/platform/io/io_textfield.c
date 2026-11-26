#include "io_textfield.h"
#include "jbni_objects.h"
#include "vm_os.h"

#include <stddef.h>

enum {
    TEXTFIELD_SET_TEXT = 1, TEXTFIELD_REFRESH = 2,
    TEXTBOX_SET_TEXT = 3, TEXTBOX_REFRESH = 4
};

static JbUpcallQueue *queue;
static unsigned queue_users;
static VmNotifier *field_waiter, *box_waiter;

#define DISPATCH(name) JbniS_com_jbed_midp_lcdui_javaui_UpcallDispatcher_##name
#define EDIT(name) JbniS_com_jbed_midp_lcdui_toolkit_ewt_NativeEditTextComponent_##name
#define OVERLAY(name) JbniS_com_jbed_midp_lcdui_toolkit_ewt_NativeOverlayTextBoxComponent_##name

void DISPATCH(nativeStartup)(void)
{
    if (queue_users == 0) queue = Jbed_upcall_createQueue(2048, 0);
    ++queue_users;
}

void DISPATCH(nativeShutdown)(void)
{
    if (--queue_users == 0) {
        Jbed_upcall_deleteQueue(queue);
        queue = NULL;
    }
}

void JPL_javaui_TextField_refresh(int id)
{
    if (jbed_foreground_display != -1 && queue)
        Jbed_upcall_sendComplex(queue, jbed_foreground_isolate, JBED_UPCALL_JAVA_UI, jbed_foreground_display,
                                "ii", TEXTFIELD_REFRESH, id);
}

void JPL_javaui_TextBox_refresh(void)
{
    if (jbed_foreground_display != -1 && queue)
        Jbed_upcall_sendComplex(queue, jbed_foreground_isolate, JBED_UPCALL_JAVA_UI, jbed_foreground_display,
                                "ii", TEXTBOX_REFRESH, 0);
}

void JPL_javaui_TextField_setText(int id, const uint16_t *text, int length)
{
    if (jbed_foreground_display != -1 && queue)
        Jbed_upcall_sendComplex(queue, jbed_foreground_isolate, JBED_UPCALL_JAVA_UI, jbed_foreground_display,
                                "iisi", TEXTFIELD_SET_TEXT, id, text, length, 0);
}

void JPL_javaui_TextBox_setText(const uint16_t *text, int length)
{
    if (jbed_foreground_display != -1 && queue)
        Jbed_upcall_sendComplex(queue, jbed_foreground_isolate, JBED_UPCALL_JAVA_UI, jbed_foreground_display,
                                "isi", TEXTBOX_SET_TEXT, text, length, 0);
}

static void attached(VmNotifier **waiter)
{
    if (*waiter) {
        ASYNC_notify(*waiter);
        *waiter = NULL;
    }
}

void jbed_handle_nativeTextField_client_attached(void) { attached(&field_waiter); }
void jbed_handle_nativeTextBox_client_attached(void) { attached(&box_waiter); }

static int create_control(int inline_field, VmNotifier **waiter)
{
    int id = android_textfield_create(inline_field);
    if (id == -1) {
        *waiter = vm_current_notifier();
        vm_current_notifier()->state = VM_BUSY;
    }
    return id;
}

int EDIT(nCreateControl)(void) { return create_control(1, &field_waiter); }
int OVERLAY(nCreateControl)(void) { return create_control(0, &box_waiter); }

void EDIT(nDestroy)(int id) { android_textfield_dispose(id); }
int EDIT(nGetCaretPosition)(int id) { return android_textfield_getCaretPosition(id); }
void EDIT(nSetMaxSize)(int id, int size) { android_textfield_setMaxSize(id, size); }
void EDIT(nSetConstraints)(int id, int constraints) { android_textfield_setConstrains(id, constraints); }
void EDIT(nSetInitialInputMode)(int id, const JbString *mode) { (void)id; (void)mode; }
void EDIT(nSetPosition)(int id, int x, int y, int w, int h) { android_textfield_setPosition(id,x,y,w,h); }
int EDIT(nSetClip)(int id, int x, int y, int w, int h)
{
    android_textfield_setClip(id, x, y, w, h);
    return 0;
}
int EDIT(nReleaseFocus)(int id) { android_textfield_setFocus(id, 0); return 0; }
int EDIT(nGrabFocus)(int id) { android_textfield_setFocus(id, 1); return 0; }

void EDIT(nSetText)(int id, const JbString *value)
{
    android_textfield_setText(id, jb_string_chars(value), value->length);
}

void EDIT(nReplaceText)(int id, int offset, int count, const JbString *value)
{
    android_textfield_replaceText(id, offset, count, value ? jb_string_chars(value) : NULL,
                                  value ? value->length : 0);
}

typedef struct {
    uint32_t header[3];
    int32_t hints[4];
} LayoutInfo;

void EDIT(nCalculateSizeHints)(int id, LayoutInfo *layout, int width_hint, int height_hint)
{
    int min_width, min_height, preferred_width, preferred_height;
    android_textfield_calculateSizeHints(id, width_hint, height_hint, &min_width, &min_height,
                                        &preferred_width, &preferred_height);
    layout->hints[0] = min_width;
    layout->hints[1] = min_height;
    layout->hints[2] = preferred_width;
    layout->hints[3] = preferred_height;
}

void OVERLAY(nDestroy)(int id) { EDIT(nDestroy)(id); }
int OVERLAY(nGetCaretPosition)(int id) { return EDIT(nGetCaretPosition)(id); }
void OVERLAY(nSetMaxSize)(int id, int size) { EDIT(nSetMaxSize)(id, size); }
void OVERLAY(nSetConstraints)(int id, int constraints) { EDIT(nSetConstraints)(id, constraints); }
void OVERLAY(nSetInitialInputMode)(int id, const JbString *mode) { EDIT(nSetInitialInputMode)(id, mode); }
void OVERLAY(nSetPosition)(int id, int x, int y, int w, int h) { EDIT(nSetPosition)(id,x,y,w,h); }
void OVERLAY(nSetText)(int id, const JbString *value) { EDIT(nSetText)(id, value); }
void OVERLAY(nReplaceText)(int id, int offset, int count, const JbString *value)
{
    EDIT(nReplaceText)(id, offset, count, value);
}
int OVERLAY(nReleaseFocus)(int id) { return (uint8_t)EDIT(nReleaseFocus)(id); }
int OVERLAY(nGrabFocus)(int id) { return (uint8_t)EDIT(nGrabFocus)(id); }
