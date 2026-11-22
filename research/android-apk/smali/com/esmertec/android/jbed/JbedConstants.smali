.class public interface abstract Lcom/esmertec/android/jbed/JbedConstants;
.super Ljava/lang/Object;
.source "JbedConstants.java"


# static fields
.field public static final ACTION_JBED_PUSH_ALARM:Ljava/lang/String; = "com.esmertec.android.jbed.action.PUSHALARM"

.field public static final ACTION_JBED_PUSH_SMS:Ljava/lang/String; = "com.esmertec.android.jbed.action.PUSHSMS"

.field public static final ACTION_JBED_VM_STARTED:Ljava/lang/String; = "com.esmertec.android.jbed.action.VMSTARTED"

.field public static final ACTION_JBED_VM_STOPPED:Ljava/lang/String; = "com.esmertec.android.jbed.action.VMSTOPPED"

.field public static final EVT_BTNDOWN:I = 0x1

.field public static final EVT_BTNUP:I = 0x2

.field public static final EVT_KEYDOWN:I = 0x3

.field public static final EVT_KEYUP:I = 0x4

.field public static final EVT_PTRMOVE:I = 0x0

.field public static final JBED_ACTIVITY_NAMES:[Ljava/lang/String;

.field public static final JBED_AMS_ACTIVITY_ID:I = 0x1

.field public static final JBED_APP_ACTIVITY_ID:I = 0x0

.field public static final JBED_CONSTRAINT_ANY:I = 0x0

.field public static final JBED_CONSTRAINT_CONSTRAINT_MASK:I = 0xffff

.field public static final JBED_CONSTRAINT_DECIMAL:I = 0x5

.field public static final JBED_CONSTRAINT_EMAILADDR:I = 0x1

.field public static final JBED_CONSTRAINT_INITIAL_CAPS_SENTENCE:I = 0x200000

.field public static final JBED_CONSTRAINT_INITIAL_CAPS_WORD:I = 0x100000

.field public static final JBED_CONSTRAINT_NON_PREDICTIVE:I = 0x80000

.field public static final JBED_CONSTRAINT_NUMERIC:I = 0x2

.field public static final JBED_CONSTRAINT_PASSWORD:I = 0x10000

.field public static final JBED_CONSTRAINT_PHONENUMBER:I = 0x3

.field public static final JBED_CONSTRAINT_SENSITIVE:I = 0x40000

.field public static final JBED_CONSTRAINT_UNEDITABLE:I = 0x20000

.field public static final JBED_CONSTRAINT_URL:I = 0x4

.field public static final JBED_EVT_AIOC_POLL:I = 0x2

.field public static final JBED_EVT_ASYNC_NOTIFY:I = 0x3

.field public static final JBED_EVT_BLOCK_VM_AFTER_PHONE_HANGUP:I = 0x9

.field public static final JBED_EVT_EXIT:I = 0x1

.field public static final JBED_EVT_REPAINT:I = 0x4

.field public static final JBED_EVT_SEND_RAWEVENT:I = 0x5

.field public static final JBED_EVT_VMCHANGE_BACKGROUND:I = 0x8

.field public static final JBED_EVT_VMCHANGE_FOREGROUND:I = 0x7

.field public static final JBED_EVT_VMCHANGE_PAUSE:I = 0x6

.field public static final JBED_EXIT_MIDLET:I = 0x2

.field public static final JBED_EXIT_VM:I = 0x3

.field public static final JBED_EXIT_VM_INSTALL_FAILED:I = 0x4

.field public static final JBED_EXIT_VM_INSTALL_SUCCEEDED:I = 0x5

.field public static final JBED_ITERATE_EXCEPTION:I = -0x2

.field public static final JBED_ITERATE_TIMEOUT:I = -0x1

.field public static final JBED_MAIN_ACTIVE:I = 0x2

.field public static final JBED_MAIN_ACTIVE_FOREGROUND:I = 0x3

.field public static final JBED_MAIN_DOWN:I = 0x0

.field public static final JBED_MAIN_IDLE:I = 0x1

.field public static final JBED_MAX_IDLE:I = 0x7fffffff

.field public static final JBED_MAX_RUN:I = 0x32

.field public static final JBED_MIDP_SUSPENDED:I = 0x6

.field public static final JBED_MIN_DELAY_TO_WAIT:I = 0xa

.field public static final JBED_MIN_IDLE:I = 0x0

.field public static final JBED_NATIVE_LIB:Ljava/lang/String; = "jbedvm"

.field public static final JBED_RESTART:I = 0x1

.field public static final JBED_RUNNING_MIDLET_ACTIVITY_ID:I = 0x2

.field public static final JBED_SYSTEM_EXIT:I = -0x3

.field public static final JVM_VIEW_SURFACE_LAYER:I = 0x3e9

.field public static final KEYCODE_CLEAR:I = -0x8

.field public static final KEYCODE_DOWN:I = -0x2

.field public static final KEYCODE_INVALID:I = 0x0

.field public static final KEYCODE_LEFT:I = -0x3

.field public static final KEYCODE_MULTITASK:I = -0x64

.field public static final KEYCODE_RIGHT:I = -0x4

.field public static final KEYCODE_SELECT:I = -0x5

.field public static final KEYCODE_SOFT1:I = -0x6

.field public static final KEYCODE_SOFT2:I = -0x7

.field public static final KEYCODE_UP:I = -0x1

.field public static final VIDEO_VIEW_SURFACE_LAYER:I = 0x3ea

.field public static final VMCHANGE_REASON_ALL:I = 0x1f

.field public static final VMCHANGE_REASON_AMS_CLIENT_ATTACHED:I = 0x10

.field public static final VMCHANGE_REASON_INCOMINGCALL:I = 0x2

.field public static final VMCHANGE_REASON_NONE:I = 0x1

.field public static final VMCHANGE_REASON_NORMAL_ACTIVITY_ATTACHED:I = 0x4

.field public static final VMCHANGE_REASON_NORMAL_ACTIVITY_DETTACHED:I = 0x8


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 279
    const/4 v0, 0x3

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "JbedAppActivity"

    aput-object v2, v0, v1

    const/4 v1, 0x1

    const-string v2, "AmsActivity"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, "RunningMidletActivity"

    aput-object v2, v0, v1

    sput-object v0, Lcom/esmertec/android/jbed/JbedConstants;->JBED_ACTIVITY_NAMES:[Ljava/lang/String;

    return-void
.end method
