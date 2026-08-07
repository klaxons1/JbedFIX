.class public Lcom/esmertec/android/jbed/JbedProvider$Midlets;
.super Ljava/lang/Object;
.source "JbedProvider.java"

# interfaces
.implements Landroid/provider/BaseColumns;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedProvider;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "Midlets"
.end annotation


# static fields
.field public static final CONTENT_URI:Landroid/net/Uri;

.field public static final DISPLAY_INFO:Ljava/lang/String; = "display_info"

.field public static final DOMAIN:Ljava/lang/String; = "domain"

.field public static final DRM_PENDING:Ljava/lang/String; = "drm_pending"

.field public static final DRM_PROTECTED:Ljava/lang/String; = "drm_protected"

.field public static final FILE_ROOT:Ljava/lang/String; = "file_root"

.field public static final HAS_SHORT_CUT:Ljava/lang/String; = "has_short_cut"

.field public static final HIDDEN:Ljava/lang/String; = "is_hidden"

.field public static final ICON_PATH:Ljava/lang/String; = "_data"

.field public static final INSTALL_TIME:Ljava/lang/String; = "install_time"

.field public static final NAME:Ljava/lang/String; = "name"

.field public static final NO:Ljava/lang/String; = "no"

.field public static final PARENT_UID:Ljava/lang/String; = "parent_uid"

.field public static final REMOVABLE:Ljava/lang/String; = "removable"

.field public static final ROOT:Ljava/lang/String; = "root"

.field public static final SIZE:Ljava/lang/String; = "size"

.field public static final STORAGE_PATH:Ljava/lang/String; = "storage_path"

.field public static final TABLE_NAME:Ljava/lang/String; = "midlets"

.field public static final UID:Ljava/lang/String; = "uid"

.field public static final VENDOR:Ljava/lang/String; = "vendor"


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 164
    const-string v0, "content://jbed/midlets"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/JbedProvider$Midlets;->CONTENT_URI:Landroid/net/Uri;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 119
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
