.class public Lcom/esmertec/android/jbed/jsr/JbedDrmManager;
.super Ljava/lang/Object;
.source "JbedDrmManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# static fields
.field private static final CPL_DRM_CONSTRAINT_COUNT:I = 0x1

.field private static final CPL_DRM_CONSTRAINT_DATETIME_END:I = 0x4

.field private static final CPL_DRM_CONSTRAINT_DATETIME_START:I = 0x2

.field private static final CPL_DRM_CONSTRAINT_INTERVAL:I = 0x8

.field private static final CPL_DRM_EOF:I = -0x2

.field private static final CPL_DRM_FAILURE:I = -0x1

.field private static final CPL_DRM_SUCCESS:I = 0x0

.field private static final DEBUG:Z = false

.field public static final DM_FILENAME:Ljava/lang/String; = ".dm"

.field public static final DRM_FILENAME:Ljava/lang/String; = ".drm"

.field public static final JBED_DRM_METHOD_TYPE_CD:I = 0x2

.field public static final JBED_DRM_METHOD_TYPE_FL:I = 0x1

.field public static final JBED_DRM_METHOD_TYPE_SD:I = 0x3

.field private static final JBED_DRM_MIMETYPE_CONTENT:I = 0x2

.field private static final JBED_DRM_MIMETYPE_MESSAGE:I = 0x1

.field private static final JBED_DRM_MIMETYPE_RIGHTS_WBXML:I = 0x4

.field private static final JBED_DRM_MIMETYPE_RIGHTS_XML:I = 0x3

.field public static final JBED_DRM_PERMISSION_DISPLAY:I = 0x2

.field public static final JBED_DRM_PERMISSION_EXECUTE:I = 0x3

.field public static final JBED_DRM_PERMISSION_PLAY:I = 0x1

.field public static final JBED_DRM_PERMISSION_PRINT:I = 0x4

.field private static final TAG:Ljava/lang/String; = "JbedDrmManager"

.field private static mContext:Landroid/content/Context;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 96
    const-string v0, "/data/data/com.esmertec.android.jbed/PendingInstall/"

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedDrmManager;->nativeInitialization(Ljava/lang/String;)V

    .line 97
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 0
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 99
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 100
    return-void
.end method

.method public static getDrmMethodType(Ljava/lang/String;)I
    .locals 1
    .param p0, "drmFilename"    # Ljava/lang/String;

    .prologue
    .line 110
    const/4 v0, 0x0

    return v0
.end method

.method private static native nativeInitialization(Ljava/lang/String;)V
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 103
    sput-object p1, Lcom/esmertec/android/jbed/jsr/JbedDrmManager;->mContext:Landroid/content/Context;

    .line 104
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 107
    return-void
.end method
