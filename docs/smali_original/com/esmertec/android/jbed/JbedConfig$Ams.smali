.class public Lcom/esmertec/android/jbed/JbedConfig$Ams;
.super Ljava/lang/Object;
.source "JbedConfig.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedConfig;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "Ams"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 254
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static isCustomIconEnable()Z
    .locals 1

    .prologue
    .line 280
    const-string v0, "AMS.CUSTOMICON.ENABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isGenApk()Z
    .locals 1

    .prologue
    .line 257
    const-string v0, "AMS.GENAPK"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isMidletInFolderOnly()Z
    .locals 1

    .prologue
    .line 261
    const-string v0, "AMS.MIDLET.IN.FOLDER.ONLY"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isNotifyDrmConstraintEnable()Z
    .locals 1

    .prologue
    .line 284
    const-string v0, "AMS.CONSTRAINT.NOTIFY"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isShowToastEnabled()Z
    .locals 1

    .prologue
    .line 276
    const-string v0, "SHOW.TOAST.AFTER.REMOVE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isUsingSpecialIcon()Z
    .locals 1

    .prologue
    .line 269
    const-string v0, "AMS.USING.SPECIAL.ICONS"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static unlimitMidletInDefaultFolder()Z
    .locals 1

    .prologue
    .line 265
    const-string v0, "AMS.UNLIMIT.MIDLET.IN.DEFAULTFOLDER"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method
