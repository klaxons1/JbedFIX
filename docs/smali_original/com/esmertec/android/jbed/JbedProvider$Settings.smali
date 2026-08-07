.class public Lcom/esmertec/android/jbed/JbedProvider$Settings;
.super Ljava/lang/Object;
.source "JbedProvider.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedProvider;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "Settings"
.end annotation


# static fields
.field public static final BASE_DIR_COLUMN:Ljava/lang/String; = "base_dir"

.field public static final CERTS_ROOT_DIR_COLUMN:Ljava/lang/String; = "certs_root_dir"

.field public static final CONTENT_URI:Landroid/net/Uri;

.field public static final DEFAULT_BASE_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/Installed/"

.field public static final DEFAULT_CERTS_DEVICE_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/certs/SIM/DF/trustedCertificates/"

.field public static final DEFAULT_CERTS_ROOT_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/certs/"

.field public static final DEFAULT_LAPI_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/location/"

.field public static final DEFAULT_LOCALINSTALL_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/LocalInstall/"

.field public static final DEFAULT_PENDINGINSTALL_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/PendingInstall/"

.field public static final DEFAULT_PREINSTALL_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/PreInstall/"

.field public static final DEFAULT_ROOT_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/"

.field public static final DEFAULT_TMP_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/tmp/"

.field public static final EXTRA_COMMAND_LINE_COLUMN:Ljava/lang/String; = "extra_command_line"

.field public static final IS_ALLOWED_HIDDEN_MENU_COLUMN:Ljava/lang/String; = "is_allowed_hidden_menu"

.field public static final IS_LAUNCH_AMS_LIST_COLUMN:Ljava/lang/String; = "is_launch_ams_list"

.field public static final IS_NATIVEAMS_COLUMN:Ljava/lang/String; = "is_nativeams"

.field public static final IS_RUNTCK_COLUMN:Ljava/lang/String; = "is_runtck"

.field public static final LOCALINSTALL_DIR_COLUMN:Ljava/lang/String; = "localinstall_dir"

.field public static final OPERATOR_CERTS_DEVICE_DIR:Ljava/lang/String; = "/data/data/com.esmertec.android.jbed/certs/DEVICE/"

.field public static final ROOT_DIR_COLUMN:Ljava/lang/String; = "root_dir"

.field public static final SYNC_CERTS_DATE_COLUMN:Ljava/lang/String; = "sync_certs_date"

.field public static final SYNC_CERTS_SIZE_COLUMN:Ljava/lang/String; = "sync_certs_size"

.field private static final TABLE_NAME:Ljava/lang/String; = "settings"

.field public static final TCK_URL_COLUMN:Ljava/lang/String; = "tck_url"


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 88
    const-string v0, "content://jbed/settings"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 59
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
