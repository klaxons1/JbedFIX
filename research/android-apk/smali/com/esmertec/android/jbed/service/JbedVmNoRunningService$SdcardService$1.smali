.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$1;
.super Landroid/content/BroadcastReceiver;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)V
    .locals 0

    .prologue
    .line 216
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 5
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 219
    invoke-virtual {p2}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v2

    .line 220
    .local v2, "uri":Landroid/net/Uri;
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v3

    invoke-virtual {v3}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    .line 221
    .local v0, "externalStoragePath":Ljava/lang/String;
    invoke-virtual {v2}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v3

    const-string v4, "file"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-virtual {v2}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    .line 223
    const-string v3, "JbedVmNoRunningService"

    const-string v4, "rootChangeReceiver start to parse selector files and save them to db!!!"

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 224
    new-instance v1, Lcom/esmertec/android/jbed/ams/JbedSelector;

    invoke-static {p1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v1, v3}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    .line 226
    .local v1, "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->access$400(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 227
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->touch()V

    .line 234
    .end local v1    # "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    :cond_0
    :goto_0
    return-void

    .line 230
    .restart local v1    # "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    :cond_1
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 231
    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->storeToDb(Landroid/content/Context;)V

    goto :goto_0
.end method
