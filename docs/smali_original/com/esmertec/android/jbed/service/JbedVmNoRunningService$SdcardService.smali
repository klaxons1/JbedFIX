.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "SdcardService"
.end annotation


# instance fields
.field private SdcardChangedReceiver:Landroid/content/BroadcastReceiver;

.field private mIsVmStarted:Z

.field private mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;


# direct methods
.method constructor <init>()V
    .locals 1

    .prologue
    .line 212
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 214
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->mIsVmStarted:Z

    .line 216
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->SdcardChangedReceiver:Landroid/content/BroadcastReceiver;

    .line 237
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    .prologue
    .line 212
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    .prologue
    .line 212
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->mIsVmStarted:Z

    return v0
.end method

.method static synthetic access$402(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;
    .param p1, "x1"    # Z

    .prologue
    .line 212
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->mIsVmStarted:Z

    return p1
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 4
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    const-string v3, "JbedVmNoRunningService"

    .line 248
    const-string v2, "JbedVmNoRunningService"

    const-string v2, "SdcardService onCreate"

    invoke-static {v3, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 249
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 250
    .local v0, "externalStorageFilter":Landroid/content/IntentFilter;
    const-string v2, "android.intent.action.MEDIA_MOUNTED"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 251
    const-string v2, "android.intent.action.MEDIA_UNMOUNTED"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 252
    const-string v2, "android.intent.action.MEDIA_REMOVED"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 253
    const-string v2, "android.intent.action.MEDIA_BAD_REMOVAL"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 254
    const-string v2, "file"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addDataScheme(Ljava/lang/String;)V

    .line 255
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->SdcardChangedReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 262
    const-string v2, "JbedVmNoRunningService"

    const-string v2, "onCreate start to parse selector files and save them to db!!!"

    invoke-static {v3, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 263
    new-instance v1, Lcom/esmertec/android/jbed/ams/JbedSelector;

    invoke-static {p1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v2

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    .line 264
    .local v1, "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 265
    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->storeToDb(Landroid/content/Context;)V

    .line 269
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->launchPowerOn()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 271
    check-cast p1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    .end local p1    # "context":Landroid/content/Context;
    invoke-static {p1, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->access$500(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;Lcom/esmertec/android/jbed/ams/JbedSelector;)V

    .line 273
    :cond_0
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 276
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->SdcardChangedReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 277
    return-void
.end method
