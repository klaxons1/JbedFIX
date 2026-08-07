.class public Lcom/esmertec/android/jbed/SdcardChangedReceiver;
.super Landroid/content/BroadcastReceiver;
.source "SdcardChangedReceiver.java"


# static fields
.field private static final DEBUG:Z = true

.field static final TAG:Ljava/lang/String; = "SdcardChangedReceiver"


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 19
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 9
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    const-string v8, "SdcardChangedReceiver"

    .line 24
    invoke-virtual {p2}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v4

    .line 25
    .local v4, "uri":Landroid/net/Uri;
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v5

    invoke-virtual {v5}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v1

    .line 26
    .local v1, "externalStoragePath":Ljava/lang/String;
    invoke-virtual {v4}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v5

    const-string v6, "file"

    invoke-virtual {v5, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_0

    invoke-virtual {v4}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v1, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_0

    .line 28
    const-string v5, "SdcardChangedReceiver"

    const-string v5, "SdcardChangedReceiver start to parse selector files and save them to db!!!"

    invoke-static {v8, v5}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 29
    new-instance v2, Lcom/esmertec/android/jbed/ams/JbedSelector;

    invoke-static {p1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v5

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v2, v5}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    .line 31
    .local v2, "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    new-instance v3, Landroid/content/Intent;

    invoke-direct {v3}, Landroid/content/Intent;-><init>()V

    .line 32
    .local v3, "serviceIntent":Landroid/content/Intent;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v5

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, ".service.JbedService"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v3, v5, v6}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 33
    invoke-virtual {p0, p1, v3}, Lcom/esmertec/android/jbed/SdcardChangedReceiver;->peekService(Landroid/content/Context;Landroid/content/Intent;)Landroid/os/IBinder;

    move-result-object v0

    .line 34
    .local v0, "binder":Landroid/os/IBinder;
    const-string v5, "SdcardChangedReceiver"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "binder="

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v8, v5}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 36
    if-eqz v0, :cond_1

    .line 40
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->touch()V

    .line 47
    .end local v0    # "binder":Landroid/os/IBinder;
    .end local v2    # "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    .end local v3    # "serviceIntent":Landroid/content/Intent;
    :cond_0
    :goto_0
    return-void

    .line 43
    .restart local v0    # "binder":Landroid/os/IBinder;
    .restart local v2    # "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    .restart local v3    # "serviceIntent":Landroid/content/Intent;
    :cond_1
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 44
    invoke-virtual {v2, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->storeToDb(Landroid/content/Context;)V

    goto :goto_0
.end method
