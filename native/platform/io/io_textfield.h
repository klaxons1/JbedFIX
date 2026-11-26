#ifndef JBED_TEXTFIELD_H
#define JBED_TEXTFIELD_H

#include <stdint.h>

enum { JBED_TEXTBOX_MASK = 0x0f000000 };

int android_textfield_create(int inline_field);
void android_textfield_dispose(int id);
void android_textfield_calculateSizeHints(int id, int width_hint, int height_hint,
                                          int *minimum_width, int *minimum_height,
                                          int *preferred_width, int *preferred_height);
void android_textfield_setPosition(int id, int x, int y, int width, int height);
void android_textfield_setClip(int id, int x, int y, int width, int height);
void android_textfield_setFocus(int id, int focus);
void android_textfield_setConstrains(int id, int constraints);
void android_textfield_setMaxSize(int id, int size);
int android_textfield_getCaretPosition(int id);
void android_textfield_setText(int id, const uint16_t *text, int length);
void android_textfield_replaceText(int id, int offset, int count, const uint16_t *text, int length);

void JPL_javaui_TextBox_refresh(void);
void JPL_javaui_TextBox_setText(const uint16_t *text, int length);
void JPL_javaui_TextField_refresh(int id);
void JPL_javaui_TextField_setText(int id, const uint16_t *text, int length);
void jbed_handle_nativeTextField_client_attached(void);
void jbed_handle_nativeTextBox_client_attached(void);

#endif
