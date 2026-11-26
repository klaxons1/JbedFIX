.class public Lcom/esmertec/android/jbed/JbedConfig$Menu;
.super Ljava/lang/Object;
.source "JbedConfig.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedConfig;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "Menu"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 288
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static isAMSListLaunch()Z
    .locals 1

    .prologue
    .line 430
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$100()Lcom/esmertec/android/jbed/JbedConfig;

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$200()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedSettings;->isAMSListLaunch()Z

    move-result v0

    return v0
.end method

.method public static isAboutDisabled()Z
    .locals 1

    .prologue
    .line 360
    const-string v0, "MENU.ABOUT.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isAllowedHiddenMenu()Z
    .locals 1

    .prologue
    .line 423
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$100()Lcom/esmertec/android/jbed/JbedConfig;

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$200()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedSettings;->isAllowedHiddenMenu()Z

    move-result v0

    return v0
.end method

.method public static isApnDisabled()Z
    .locals 1

    .prologue
    .line 353
    const-string v0, "MENU.APN.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isCreateFolderDisabled()Z
    .locals 1

    .prologue
    .line 329
    const-string v0, "MENU.CREATE_FOLDER.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isExitDisabled()Z
    .locals 1

    .prologue
    .line 395
    const-string v0, "MENU.EXIT.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isInstallDisabled()Z
    .locals 9

    .prologue
    const/4 v5, 0x3

    const-string v8, "config.properties"

    const-string v7, "MENU.INSTALL.DISABLE"

    const-string v6, ""

    const-string v4, "JbedConfig"

    .line 336
    const-string v1, ""

    .line 337
    .local v1, "propString":Ljava/lang/String;
    const-string v2, "JbedConfig"

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "JbedConfig"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "String="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$100()Lcom/esmertec/android/jbed/JbedConfig;

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$200()Landroid/content/Context;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/JbedSettings;->getRootDir()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "config.properties"

    invoke-virtual {v2, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 338
    :cond_0
    new-instance v0, Ljava/io/File;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$100()Lcom/esmertec/android/jbed/JbedConfig;

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->access$200()Landroid/content/Context;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/JbedSettings;->getRootDir()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "config.properties"

    invoke-virtual {v2, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v0, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 339
    .local v0, "configFile":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 340
    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$300(Ljava/io/File;)Ljava/util/Properties;

    move-result-object v2

    const-string v3, "MENU.INSTALL.DISABLE"

    invoke-virtual {v2, v7}, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 341
    const-string v2, "JbedConfig"

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_1

    const-string v2, "JbedConfig"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "propString d1="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 344
    :cond_1
    if-eqz v1, :cond_2

    const-string v2, ""

    invoke-virtual {v6, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3

    :cond_2
    const-string v2, "MENU.INSTALL.DISABLE"

    invoke-static {v7}, Lcom/esmertec/android/jbed/JbedConfig;->access$400(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    move-object v1, v2

    .line 345
    :cond_3
    const-string v2, "JbedConfig"

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_4

    const-string v2, "JbedConfig"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "propString="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 346
    :cond_4
    if-eqz v1, :cond_5

    const-string v2, ""

    invoke-virtual {v6, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_6

    :cond_5
    const/4 v2, 0x0

    :goto_0
    return v2

    :cond_6
    const-string v2, "true"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v2

    goto :goto_0
.end method

.method public static isMoveDisabled()Z
    .locals 1

    .prologue
    .line 301
    const-string v0, "MENU.MOVE.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isReconfigEnable()Z
    .locals 1

    .prologue
    .line 409
    const-string v0, "MENU.RECONFIGURATION"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isReconfigForAdamEnable()Z
    .locals 1

    .prologue
    .line 416
    const-string v0, "MENU.RECONFIGURATION.FOR.ADAM"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isRemoveAllDisabled()Z
    .locals 1

    .prologue
    .line 374
    const-string v0, "MENU.REMOVEALL.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isRemoveDisabled()Z
    .locals 1

    .prologue
    .line 367
    const-string v0, "MENU.REMOVE.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isRemoveMultiEnabled()Z
    .locals 1

    .prologue
    .line 315
    const-string v0, "MENU.REMOVE_MULTI.ENABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isRenameDisabled()Z
    .locals 1

    .prologue
    .line 322
    const-string v0, "MENU.RENAME.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isRotationEnabled()Z
    .locals 1

    .prologue
    .line 294
    const-string v0, "MENU.ROTATION.ENABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isSortDisabled()Z
    .locals 1

    .prologue
    .line 308
    const-string v0, "MENU.SORT.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isStorateSettingEnable()Z
    .locals 1

    .prologue
    .line 402
    const-string v0, "MENU.STORAGE_SETTING.ENABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isTasksDisabled()Z
    .locals 1

    .prologue
    .line 434
    const-string v0, "MENU.TASKS.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isUpFolderDisabled()Z
    .locals 1

    .prologue
    .line 381
    const-string v0, "MENU.UPFOLDER.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isUpdateDisabled()Z
    .locals 1

    .prologue
    .line 388
    const-string v0, "MENU.UPDATE.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method
