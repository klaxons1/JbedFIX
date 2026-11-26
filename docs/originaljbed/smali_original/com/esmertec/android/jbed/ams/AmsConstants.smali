.class public interface abstract Lcom/esmertec/android/jbed/ams/AmsConstants;
.super Ljava/lang/Object;
.source "AmsConstants.java"


# static fields
.field public static final ALERT_TYPE_ERROR:I = 0x2

.field public static final ALERT_TYPE_INFO:I = 0x0

.field public static final ALERT_TYPE_WARNING:I = 0x1

.field public static final ASK_EXIT_RUNNING_MIDLETS:I = 0x6

.field public static final CONFIRMATION_ADDED:I = 0x1

.field public static final CONFIRMATION_GENERATE:I = 0x4

.field public static final CONFIRMATION_REMOVED:I = 0x2

.field public static final CONFIRMATION_SIGN:I = 0x3

.field public static final CONFIRMATION_USED:I = 0x0

.field public static final DCF_EXTEND_NAME:Ljava/lang/String; = ".dcf"

.field public static final DM_EXTEND_NAME:Ljava/lang/String; = ".dm"

.field public static final DRM_PURCHASE_TYPE_ALREADY_EXPIRED:I = 0x2

.field public static final DRM_PURCHASE_TYPE_COUNT1:I = 0x0

.field public static final DRM_PURCHASE_TYPE_JUST_EXPIRED:I = 0x1

.field public static final DRM_PURCHASE_TYPE_PENDING_INSTALL:I = 0x3

.field public static final EPA_CHECK:I = 0x1

.field public static final EPA_ERROR:I = 0x3

.field public static final EPA_OK:I = 0x1

.field public static final EPA_SET:I = 0x2

.field public static final EPA_WARNING:I = 0x2

.field public static final EVENT_ANDROID:I = 0x2710

.field public static final EVENT_ANDROID_DRM_PURCHASE_RO_CONFIRM:I = 0x271e

.field public static final EVENT_ANDROID_FOLDER_INFO:I = 0x2721

.field public static final EVENT_ANDROID_INPUT_FOLDER_NAME:I = 0x2715

.field public static final EVENT_ANDROID_INPUT_SUITE_NAME:I = 0x2716

.field public static final EVENT_ANDROID_LAUNCH_BROWSER:I = 0x2714

.field public static final EVENT_ANDROID_LIST_FOLDER:I = 0x2717

.field public static final EVENT_ANDROID_LIST_LOCAL_INSTALL:I = 0x2710

.field public static final EVENT_ANDROID_MIDLET_STARTUP_ERROR:I = 0x2719

.field public static final EVENT_ANDROID_MOVE_MULTIPLE:I = 0x271d

.field public static final EVENT_ANDROID_REMOVE_CONFIRM:I = 0x2711

.field public static final EVENT_ANDROID_REMOVE_FOLDER_CONFIRM:I = 0x2718

.field public static final EVENT_ANDROID_REMOVE_MULTIPLE:I = 0x271c

.field public static final EVENT_ANDROID_REMOVE_MULTIPLE_CONFIRM:I = 0x271b

.field public static final EVENT_ANDROID_REMOVE_MULTIPLE_FOLDERS:I = 0x271f

.field public static final EVENT_ANDROID_SHOW_ABOUT:I = 0x2712

.field public static final EVENT_ANDROID_SHOW_ALERT:I = 0x2713

.field public static final EVENT_ANDROID_SORT_SETTING:I = 0x2720

.field public static final EVENT_ANDROID_STORAGE_SETTING:I = 0x271a

.field public static final EVENT_CHANGE_CERTIFICATE_STATE:I = 0x35

.field public static final EVENT_CREATE_FOLDER:I = 0x3c

.field public static final EVENT_DESTROY:I = 0xa

.field public static final EVENT_DESTROYED:I = 0xb

.field public static final EVENT_DISPLAY_SIZE:I = 0x48

.field public static final EVENT_DRM_ACTIVATE:I = 0x26

.field public static final EVENT_DRM_CHECK_RIGHTS:I = 0x42

.field public static final EVENT_DRM_CONSTRAINT:I = 0x43

.field public static final EVENT_DRM_GET_METHOD_TYPE:I = 0x44

.field public static final EVENT_DRM_REINSTALL:I = 0x27

.field public static final EVENT_GET_ICONS:I = 0x16

.field public static final EVENT_INFO:I = 0x14

.field public static final EVENT_INSTALL:I = 0x5

.field public static final EVENT_INSTALL_AUTHENTICATION:I = 0x10

.field public static final EVENT_INSTALL_CANCEL:I = 0x6

.field public static final EVENT_INSTALL_PREVIEW_JAD:I = 0xf

.field public static final EVENT_INSTALL_PROGRESS:I = 0x4

.field public static final EVENT_INSTALL_QUERY:I = 0xd

.field public static final EVENT_INSTALL_QUERY_YES_NO:I = 0x39

.field public static final EVENT_INSTALL_STATUS:I = 0xc

.field public static final EVENT_INSTALL_STEP:I = 0x13

.field public static final EVENT_INSTALL_STEP_COMPLETE:I = 0x1c

.field public static final EVENT_INSTALL_UNSTOPPABLE:I = 0xe

.field public static final EVENT_JAD_DOWNLOAD:I = 0x37

.field public static final EVENT_JAD_DOWNLOAD_COMPLETE:I = 0x38

.field public static final EVENT_JAD_DOWNLOAD_PROGRESS:I = 0x36

.field public static final EVENT_JAR_DOWNLOAD:I = 0x24

.field public static final EVENT_JAR_DOWNLOAD_COMPLETE:I = 0x25

.field public static final EVENT_JAR_DOWNLOAD_PROGRESS:I = 0x23

.field public static final EVENT_LIST:I = 0x1

.field public static final EVENT_LIST_CERTIFICATES:I = 0x34

.field public static final EVENT_LIST_FOLDER_CONTENTS:I = 0x3b

.field public static final EVENT_LIST_RUNNING_MIDLETS:I = 0x22

.field public static final EVENT_LIST_STORAGE:I = 0x20

.field public static final EVENT_MOVE:I = 0x1f

.field public static final EVENT_MOVE_FOLDER:I = 0x3d

.field public static final EVENT_NONE:I = 0x0

.field public static final EVENT_NOTIFY_LAUNCH:I = 0x31

.field public static final EVENT_PAUSE:I = 0x8

.field public static final EVENT_PAUSED:I = 0x11

.field public static final EVENT_PERMISSIONS:I = 0x17

.field public static final EVENT_PERMISSIONS_ANSWERS:I = 0x18

.field public static final EVENT_PERMISSIONS_RESET_ANSWERS:I = 0x29

.field public static final EVENT_PLATFORM_RESET:I = 0x2a

.field public static final EVENT_PREINSTALL_FINISH:I = 0x2f

.field public static final EVENT_PREINSTALL_START:I = 0x2e

.field public static final EVENT_QUERY:I = 0x19

.field public static final EVENT_REMOVABLE_MEDIA_CHANGED:I = 0x1e

.field public static final EVENT_REMOVE:I = 0x7

.field public static final EVENT_REMOVE_ALL:I = 0x1a

.field public static final EVENT_REMOVE_FOLDER:I = 0x3f

.field public static final EVENT_REMOVE_FOLDER_CONTENTS:I = 0x40

.field public static final EVENT_RENAME:I = 0x15

.field public static final EVENT_RENAME_FOLDER:I = 0x3e

.field public static final EVENT_REQUEST_CHAPI:I = 0x2d

.field public static final EVENT_REQUEST_INSTALL:I = 0x21

.field public static final EVENT_REQUEST_PERMISSION:I = 0x33

.field public static final EVENT_REQUEST_PLATFORMREQUEST:I = 0x4a

.field public static final EVENT_REQUEST_PUSH:I = 0x2b

.field public static final EVENT_REQUEST_SATSA:I = 0x2c

.field public static final EVENT_RESUME:I = 0x9

.field public static final EVENT_RUN:I = 0x2

.field public static final EVENT_RUNNING:I = 0x12

.field public static final EVENT_RUNNING_MIDLET_MANAGER:I = 0x30

.field public static final EVENT_RUNTIME_ERROR:I = 0x3a

.field public static final EVENT_RUN_DEBUG:I = 0x28

.field public static final EVENT_SANITY_REPORT:I = 0x32

.field public static final EVENT_SELECT_INSTALL_FOLDER:I = 0x41

.field public static final EVENT_SELECT_STORAGE:I = 0x1d

.field public static final EVENT_SET:I = 0x1b

.field public static final EVENT_SET_DISPLAY_SIZE:I = 0x49

.field public static final EVENT_TW_EVER_LAUNCHED:I = 0x4b

.field public static final EVENT_TW_EXT:I = 0x45

.field public static final EVENT_TW_EXT_FOLDER:I = 0x46

.field public static final EVENT_TW_SHORTCUT:I = 0x47

.field public static final EVENT_UPDATE:I = 0x3

.field public static final EVT_OTHER:I = 0x9

.field public static final EVT_OTHER_NATIVE_AMS_EVENT:I = 0x29

.field public static final FORCE_INSTALL:I = 0x10

.field public static final FULL_SCREEN_FLAG:Ljava/lang/String; = "isFullScreen"

.field public static final HANDLE_BASE:I = 0x2710

.field public static final HANDLE_BRING_MIDLET_TO_FOREGROUND:I = 0x2710

.field public static final HANDLE_DESTROY_MIDLET:I = 0x271e

.field public static final HANDLE_ERROR:I = 0x2720

.field public static final HANDLE_FINISH:I = 0x2711

.field public static final HANDLE_GET_INSTALLED_STORAGE:I = 0x2726

.field public static final HANDLE_INITIALIZE_JBED:I = 0x2727

.field public static final HANDLE_INSTALLING:I = 0x2713

.field public static final HANDLE_INSTALL_CANCELLING:I = 0x2717

.field public static final HANDLE_INSTALL_FINISHED:I = 0x2715

.field public static final HANDLE_INSTALL_PROGRESS:I = 0x2714

.field public static final HANDLE_INSTALL_UNSTOPPABLE:I = 0x2716

.field public static final HANDLE_MIDLET_STARTUP_ERROR:I = 0x2724

.field public static final HANDLE_MIDLET_STATE_CHANGED:I = 0x271f

.field public static final HANDLE_PREINSTALLING:I = 0x272f

.field public static final HANDLE_REFRESH_LIST:I = 0x2712

.field public static final HANDLE_REFRESH_LIST_WITH_ROOT:I = 0x2721

.field public static final HANDLE_REFRESH_LIST_WITH_SORT_ORDER:I = 0x272e

.field public static final HANDLE_REMOVE_FINISHED:I = 0x271b

.field public static final HANDLE_REMOVE_MULTIPLE_FOLDER_FINISHED:I = 0x272d

.field public static final HANDLE_REMOVE_MULTIPLE_FOLDER_PROGRESS:I = 0x272c

.field public static final HANDLE_REMOVE_MULTIPLE_PROGRESS:I = 0x272a

.field public static final HANDLE_REMOVING:I = 0x271a

.field public static final HANDLE_REMOVING_MULTIPLE_FOLDER:I = 0x272b

.field public static final HANDLE_SDCARD_EVENT:I = 0x2729

.field public static final HANDLE_SENT_REPEAT_EVENT:I = 0x2728

.field public static final HANDLE_SHOW_CREATE_FOLDER_DIALOG:I = 0x2722

.field public static final HANDLE_SHOW_RENAME_FOLDER_DIALOG:I = 0x2723

.field public static final HANDLE_STORAGE_SETTING:I = 0x2725

.field public static final HANDLE_UPDATE_INSTALL_STATUS:I = 0x2719

.field public static final HANDLE_WAIT_RUNNING:I = 0x271c

.field public static final HANDLE_WAIT_RUNNING_FINISHED:I = 0x271d

.field public static final IQ_ASK_USER:I = 0x1

.field public static final IQ_INFORM_USER:I = 0x2

.field public static final IQ_RETAIN_RMS:I = 0x3

.field public static final IQ_UNAUTHORIZED:I = 0x21

.field public static final JAD_CONTENT:I = 0x2

.field public static final JAD_EXTEND_NAME:Ljava/lang/String; = ".jad"

.field public static final JAD_URL:I = 0x1

.field public static final JAR_EXTEND_NAME:Ljava/lang/String; = ".jar"

.field public static final JAR_URL:I = 0x4

.field public static final JTD_EXTEND_NAME:Ljava/lang/String; = ".jtd"

.field public static final KEY_REPEAT_DURATION:I = 0x96

.field public static final KEY_REPEAT_INITIAL_DURATION:I = 0x320

.field public static final NOTIFY_LAUNCH_CHAPI:I = 0x2

.field public static final NOTIFY_LAUNCH_PUSH:I = 0x1

.field public static final NOTIFY_LAUNCH_SPRINT:I = 0x3

.field public static final ORIG_JAD_URL:I = 0x8

.field public static final PERM_ALWAYS:I = 0x1

.field public static final PERM_ANSWER_ALWAYS:B = 0x20t

.field public static final PERM_ANSWER_NEVER:B = 0x1t

.field public static final PERM_ANSWER_NOT_SESSION:B = 0x2t

.field public static final PERM_ANSWER_NOT_USE:B = 0x4t

.field public static final PERM_ANSWER_SESSION:B = 0x10t

.field public static final PERM_ANSWER_USE:B = 0x8t

.field public static final PERM_ASK:I = 0x4

.field public static final PERM_NEVER:I = 0x2

.field public static final PERM_ONESHOT:I = 0x10

.field public static final PERM_SESSION:I = 0x8

.field public static final PIN_CHANGE:I = 0x0

.field public static final PIN_DISABLE:I = 0x2

.field public static final PIN_ENABLE:I = 0x1

.field public static final PIN_ENTER:I = 0x3

.field public static final PIN_UNBLOCK:I = 0x5

.field public static final REMOVE_ALL_PREINSTALLED:I = 0x1

.field public static final RESET_PREINSTALLED:I = 0x1

.field public static final RESET_PROTECTED:I = 0x2

.field public static final RES_CANCEL:I = 0x6

.field public static final RES_CANCELLING:I = 0x16

.field public static final RES_CANT_CREATE_DIRECTORY:I = 0x12

.field public static final RES_CONTINUE:I = 0x5

.field public static final RES_COPY_ERROR:I = 0x11

.field public static final RES_DOWNLOADING:I = 0x9

.field public static final RES_DRM_ERROR:I = 0x1b

.field public static final RES_DRM_INSTALL:I = 0x18

.field public static final RES_ERROR:I = 0xf

.field public static final RES_INSTALLING:I = 0xa

.field public static final RES_JAD_URL:I = 0x7

.field public static final RES_JAVA_HANDLE:I = 0x2

.field public static final RES_NO:I = 0x1a

.field public static final RES_NONE:I = 0x0

.field public static final RES_NOT_COMPLETELY_REMOVED:I = 0x1c

.field public static final RES_NOT_ENOUGH_SPACE:I = 0x10

.field public static final RES_NOT_FOUND:I = 0x8

.field public static final RES_NOT_RUNNING:I = 0xc

.field public static final RES_NOT_SET:I = 0xe

.field public static final RES_NO_ICON:I = 0xd

.field public static final RES_NO_INSTALL_RUNNING:I = 0x3

.field public static final RES_NO_RUNNING_MIDLETS:I = 0x14

.field public static final RES_NO_STORAGES:I = 0x13

.field public static final RES_OK:I = 0x1

.field public static final RES_RUNNING:I = 0xb

.field public static final RES_RUNNING_MIDLETS:I = 0x15

.field public static final RES_SIZE_MISMATCH:I = 0x17

.field public static final RES_TOO_LATE_FOR_CANCEL:I = 0x4

.field public static final RES_YES:I = 0x19

.field public static final RMC_ADDED:I = 0x1

.field public static final RMC_REMOVED:I = 0x2

.field public static final RUN_FROM_HOME_FLAG:Ljava/lang/String; = "isRunFromHome"

.field public static final SATSA_TYPE_CONFIRMATION:I = 0x1

.field public static final SATSA_TYPE_LIST:I = 0x2

.field public static final SATSA_TYPE_PIN:I = 0x0

.field public static final SET_NONE:I = 0x0

.field public static final SET_REMOVABLE:I = 0x1

.field public static final STEP_APPLEVELAUTH:I = 0x13

.field public static final STEP_CLEANUP:I = -0x1

.field public static final STEP_COMMIT:I = 0x15

.field public static final STEP_DONE:I = 0x1b

.field public static final STEP_GET_JAD:I = 0x1

.field public static final STEP_GET_JAR1:I = 0x3

.field public static final STEP_GET_JAR2:I = 0xd

.field public static final STEP_INITIAL:I = 0x0

.field public static final STEP_INSTALL_DRM:I = 0x19

.field public static final STEP_JAD_FROM_JAR:I = 0x4

.field public static final STEP_LIGHTWEIGHT_INTERNALISATION:I = 0x16

.field public static final STEP_PARSE_JAD:I = 0x5

.field public static final STEP_PARSE_MF:I = 0xf

.field public static final STEP_PERM1:I = 0xa

.field public static final STEP_PERM2:I = 0x11

.field public static final STEP_PRECOMPILE:I = 0x12

.field public static final STEP_PREVIEW_JAD:I = 0x2

.field public static final STEP_RMS:I = 0x14

.field public static final STEP_SELECT_STORAGE:I = 0x1a

.field public static final STEP_SET_DOMAIN:I = 0x8

.field public static final STEP_SIZE:I = 0xb

.field public static final STEP_TRUST:I = 0x9

.field public static final STEP_VERIFY_JAD:I = 0x7

.field public static final STEP_VERIFY_JAR:I = 0xe

.field public static final STEP_VERSION_UPDATE:I = 0x17

.field public static final STEP_VIDEO_PLAYBACK:I = 0x18

.field public static final STEP_WHAT_NEXT:I = 0xc

.field public static final SUPPORTED_EXT_NAMES:[Ljava/lang/String;

.field public static final UNKNOWN_URL:I

.field public static final eventAndroidNames:[Ljava/lang/String;

.field public static final eventNames:[Ljava/lang/String;

.field public static final resNames:[Ljava/lang/String;

.field public static final setNames:[Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 8

    .prologue
    const/4 v7, 0x4

    const/4 v6, 0x3

    const/4 v5, 0x2

    const/4 v4, 0x1

    const/4 v3, 0x0

    .line 1434
    const/16 v0, 0x4c

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "NONE"

    aput-object v1, v0, v3

    const-string v1, "LIST"

    aput-object v1, v0, v4

    const-string v1, "RUN"

    aput-object v1, v0, v5

    const-string v1, "UPDATE"

    aput-object v1, v0, v6

    const-string v1, "INSTALL_PROGRESS"

    aput-object v1, v0, v7

    const/4 v1, 0x5

    const-string v2, "INSTALL"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "INSTALL_CANCEL"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "REMOVE"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "PAUSE"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "RESUME"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "DESTROY"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "DESTROYED"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "INSTALL_STATUS"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "INSTALL_QUERY"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "INSTALL_UNSTOPPABLE"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "INSTALL_PREVIEW_JAD"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "INSTALL_AUTHENTICATION"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "PAUSED"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "RUNNING"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "INSTALL_STEP"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "INFO"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "RENAME"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "GET_ICONS"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "PERMISSIONS"

    aput-object v2, v0, v1

    const/16 v1, 0x18

    const-string v2, "PERMISSIONS_ANSWERS"

    aput-object v2, v0, v1

    const/16 v1, 0x19

    const-string v2, "QUERY"

    aput-object v2, v0, v1

    const/16 v1, 0x1a

    const-string v2, "REMOVE_ALL"

    aput-object v2, v0, v1

    const/16 v1, 0x1b

    const-string v2, "SET"

    aput-object v2, v0, v1

    const/16 v1, 0x1c

    const-string v2, "INSTALL_STEP_COMPLETE"

    aput-object v2, v0, v1

    const/16 v1, 0x1d

    const-string v2, "SELECT_STORAGE"

    aput-object v2, v0, v1

    const/16 v1, 0x1e

    const-string v2, "REMOVABLE_MEDIA_CHANGED"

    aput-object v2, v0, v1

    const/16 v1, 0x1f

    const-string v2, "MOVE"

    aput-object v2, v0, v1

    const/16 v1, 0x20

    const-string v2, "LIST_STORAGE"

    aput-object v2, v0, v1

    const/16 v1, 0x21

    const-string v2, "REQUEST_INSTALL"

    aput-object v2, v0, v1

    const/16 v1, 0x22

    const-string v2, "LIST_RUNNING_MIDLETS"

    aput-object v2, v0, v1

    const/16 v1, 0x23

    const-string v2, "JAR_DOWNLOAD_PROGRESS"

    aput-object v2, v0, v1

    const/16 v1, 0x24

    const-string v2, "JAR_DOWNLOAD"

    aput-object v2, v0, v1

    const/16 v1, 0x25

    const-string v2, "JAR_DOWNLOAD_COMPLETE"

    aput-object v2, v0, v1

    const/16 v1, 0x26

    const-string v2, "DRM_ACTIVATE"

    aput-object v2, v0, v1

    const/16 v1, 0x27

    const-string v2, "DRM_REINSTALL"

    aput-object v2, v0, v1

    const/16 v1, 0x28

    const-string v2, "EVENT_RUN_DEBUG"

    aput-object v2, v0, v1

    const/16 v1, 0x29

    const-string v2, "PERMISSIONS_RESET_ANSWERS"

    aput-object v2, v0, v1

    const/16 v1, 0x2a

    const-string v2, "PLATFORM_RESET"

    aput-object v2, v0, v1

    const/16 v1, 0x2b

    const-string v2, "REQUEST_PUSH"

    aput-object v2, v0, v1

    const/16 v1, 0x2c

    const-string v2, "REQUEST_SATSA"

    aput-object v2, v0, v1

    const/16 v1, 0x2d

    const-string v2, "EVENT_REQUEST_CHAPI"

    aput-object v2, v0, v1

    const/16 v1, 0x2e

    const-string v2, "PREINSTALL_START"

    aput-object v2, v0, v1

    const/16 v1, 0x2f

    const-string v2, "PREINSTALL_FINISH"

    aput-object v2, v0, v1

    const/16 v1, 0x30

    const-string v2, "RUNNING_MIDLET_MANAGER"

    aput-object v2, v0, v1

    const/16 v1, 0x31

    const-string v2, "NOTIFY_LAUNCH"

    aput-object v2, v0, v1

    const/16 v1, 0x32

    const-string v2, "SANITY_REPORT"

    aput-object v2, v0, v1

    const/16 v1, 0x33

    const-string v2, "REQUEST_PERMISSION"

    aput-object v2, v0, v1

    const/16 v1, 0x34

    const-string v2, "LIST_CERTIFICATES"

    aput-object v2, v0, v1

    const/16 v1, 0x35

    const-string v2, "CHANGE_CERTIFICATE_STATE"

    aput-object v2, v0, v1

    const/16 v1, 0x36

    const-string v2, "JAD_DOWNLOAD_PROGRESS"

    aput-object v2, v0, v1

    const/16 v1, 0x37

    const-string v2, "JAD_DOWNLOAD"

    aput-object v2, v0, v1

    const/16 v1, 0x38

    const-string v2, "JAD_DOWNLOAD_COMPLETE"

    aput-object v2, v0, v1

    const/16 v1, 0x39

    const-string v2, "INSTALL_QUERY_YES_NO"

    aput-object v2, v0, v1

    const/16 v1, 0x3a

    const-string v2, "MIDLET_RUNTIME_ERROR"

    aput-object v2, v0, v1

    const/16 v1, 0x3b

    const-string v2, "LIST_FOLDER_CONTENTS"

    aput-object v2, v0, v1

    const/16 v1, 0x3c

    const-string v2, "CREATE_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x3d

    const-string v2, "MOVE_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x3e

    const-string v2, "RENAME_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x3f

    const-string v2, "REMOVE_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x40

    const-string v2, "REMOVE_FOLDER_CONTENTS"

    aput-object v2, v0, v1

    const/16 v1, 0x41

    const-string v2, "SELECT_INSTALL_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x42

    const-string v2, "DRM_CHECK_RIGHTS"

    aput-object v2, v0, v1

    const/16 v1, 0x43

    const-string v2, "EVENT_DRM_CONSTRAINT"

    aput-object v2, v0, v1

    const/16 v1, 0x44

    const-string v2, "EVENT_DRM_GET_METHOD_TYPE"

    aput-object v2, v0, v1

    const/16 v1, 0x45

    const-string v2, "EVENT_TW_EXT"

    aput-object v2, v0, v1

    const/16 v1, 0x46

    const-string v2, "EVENT_TW_EXT_FOLDER"

    aput-object v2, v0, v1

    const/16 v1, 0x47

    const-string v2, "EVENT_TW_SHORTCUT"

    aput-object v2, v0, v1

    const/16 v1, 0x48

    const-string v2, "EVENT_DISPLAY_SIZE"

    aput-object v2, v0, v1

    const/16 v1, 0x49

    const-string v2, "EVENT_SET_DISPLAY_SIZE"

    aput-object v2, v0, v1

    const/16 v1, 0x4a

    const-string v2, "EVENT_REQUEST_PLATFORMREQUEST"

    aput-object v2, v0, v1

    const/16 v1, 0x4b

    const-string v2, "EVENT_TW_EVER_LAUNCHED"

    aput-object v2, v0, v1

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->eventNames:[Ljava/lang/String;

    .line 1519
    new-array v0, v5, [Ljava/lang/String;

    const-string v1, "NONE"

    aput-object v1, v0, v3

    const-string v1, "REMOVABLE"

    aput-object v1, v0, v4

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->setNames:[Ljava/lang/String;

    .line 1580
    const/16 v0, 0x1d

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "NONE"

    aput-object v1, v0, v3

    const-string v1, "OK"

    aput-object v1, v0, v4

    const-string v1, "JAVA_HANDLE"

    aput-object v1, v0, v5

    const-string v1, "NO_INSTALL_RUNNING"

    aput-object v1, v0, v6

    const-string v1, "TOO_LATE_FOR_CANCEL"

    aput-object v1, v0, v7

    const/4 v1, 0x5

    const-string v2, "CONTINUE"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "CANCEL"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "JAD_URL"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "NOT_FOUND"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "DOWNLOADING"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "INSTALLING"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "RUNNING"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "NOT_RUNNING"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "NO ICON"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "NOT_SET"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "ERROR"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "NOT_ENOUGH_SPACE"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "COPY_ERROR"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "CANT_CREATE_DIRECTORY"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "NO_STORAGES"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "NO_RUNNING_MIDLETS"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "RUNNING_MIDLETS"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "CANCELLING"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "SIZE_MISMATCH"

    aput-object v2, v0, v1

    const/16 v1, 0x18

    const-string v2, "DRM_INSTALL"

    aput-object v2, v0, v1

    const/16 v1, 0x19

    const-string v2, "YES"

    aput-object v2, v0, v1

    const/16 v1, 0x1a

    const-string v2, "NO"

    aput-object v2, v0, v1

    const/16 v1, 0x1b

    const-string v2, "DRM_ERROR"

    aput-object v2, v0, v1

    const/16 v1, 0x1c

    const-string v2, "NOT_COMPLETELY_REMOVED"

    aput-object v2, v0, v1

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->resNames:[Ljava/lang/String;

    .line 1950
    const/4 v0, 0x5

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "ANDROID_LIST_LOCAL_INSTALL"

    aput-object v1, v0, v3

    const-string v1, "ANDROID_REMOVE_ALERT"

    aput-object v1, v0, v4

    const-string v1, "ANDROID_SHOW_ABOUT"

    aput-object v1, v0, v5

    const-string v1, "ANDROID_SHOW_ALERT"

    aput-object v1, v0, v6

    const-string v1, "ANDROID_LAUNCH_BROWSER"

    aput-object v1, v0, v7

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->eventAndroidNames:[Ljava/lang/String;

    .line 1975
    new-array v0, v6, [Ljava/lang/String;

    const-string v1, ".jar"

    aput-object v1, v0, v3

    const-string v1, ".jad"

    aput-object v1, v0, v4

    const-string v1, ".jtd"

    aput-object v1, v0, v5

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->SUPPORTED_EXT_NAMES:[Ljava/lang/String;

    return-void
.end method
