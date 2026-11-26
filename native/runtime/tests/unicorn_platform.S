/* Test-only link boundaries for unavailable Android services. Every one
 * terminates with status 125 if reached; none pretends the service worked. */
.syntax unified
.thumb
.text
.macro unavailable name
    .p2align 2
    .global \name
    .type \name, %function
    .thumb_func
\name:
    ldr r0, =.Lunavailable_\@
    b jbed_unicorn_unavailable
    .size \name, .-\name
    .pushsection .rodata
.Lunavailable_\@: .asciz "\name"
    .popsection
.endm
unavailable JbniS_com_jbed_runtime_PhoneSystem_getObj0
unavailable JbniS_com_jbed_runtime_PhoneSystem_isSupported0
unavailable JbniS_com_jbed_runtime_PhoneSystem_setBool0
unavailable JbniS_com_jbed_runtime_PhoneSystem_setInt0
unavailable JbniS_com_jbed_util_I18N_nGet
unavailable jbed_ams_fetchAmsEvent
unavailable android_handle_ams_event
unavailable android_midp_platformRequest
unavailable android_media_createPlayer
unavailable android_media_operation
unavailable android_media_getMetaData
unavailable android_media_openStreamDev
unavailable android_sms_register
unavailable android_sms_deregister
unavailable android_engine_sizeChangingDone
unavailable android_lcdui_repaint
unavailable JbedGFX_charsWidth
unavailable JbedGFX_releaseTargFont
unavailable android_lcdui_getFontSize
unavailable JbedGFX_createTargFont
unavailable JbedGFX_getFontInfo
unavailable android_fc_getRoots
unavailable android_textfield_create
unavailable android_textfield_dispose
unavailable android_textfield_setMaxSize
unavailable android_textfield_setConstrains
unavailable android_textfield_setPosition
unavailable android_textfield_setFocus
unavailable android_textfield_setText
unavailable android_textfield_calculateSizeHints

.section .note.GNU-stack,"",%progbits
