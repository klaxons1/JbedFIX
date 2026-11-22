.class public Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;
.super Landroid/app/Service;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    }
.end annotation


# static fields
.field public static final TAG:Ljava/lang/String; = "JbedVmNoRunningService"


# instance fields
.field private mLifecycleListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;",
            ">;"
        }
    .end annotation
.end field

.field private mVmStateListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;",
            ">;"
        }
    .end annotation
.end field

.field private mVmStateReceiver:Landroid/content/BroadcastReceiver;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 61
    invoke-direct {p0}, Landroid/app/Service;-><init>()V

    .line 65
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mLifecycleListeners:Ljava/util/List;

    .line 67
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateListeners:Ljava/util/List;

    .line 129
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    .line 297
    return-void
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    .prologue
    .line 61
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateListeners:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;Lcom/esmertec/android/jbed/ams/JbedSelector;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/JbedSelector;

    .prologue
    .line 61
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->launchPowerOnMidlets(Lcom/esmertec/android/jbed/ams/JbedSelector;)V

    return-void
.end method

.method private launchPowerOnMidlets(Lcom/esmertec/android/jbed/ams/JbedSelector;)V
    .locals 4
    .param p1, "selector"    # Lcom/esmertec/android/jbed/ams/JbedSelector;

    .prologue
    .line 159
    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getPowerOnMidlets()Ljava/util/List;

    move-result-object v1

    .line 161
    .local v1, "powerOnMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_0

    .line 166
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;Ljava/util/List;)V

    .line 197
    .local v0, "connection":Landroid/content/ServiceConnection;
    new-instance v2, Landroid/content/Intent;

    const-class v3, Lcom/esmertec/android/jbed/service/JbedService;

    invoke-direct {v2, p0, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 198
    .local v2, "serviceIntent":Landroid/content/Intent;
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 199
    const/4 v3, 0x1

    invoke-virtual {p0, v2, v0, v3}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->bindService(Landroid/content/Intent;Landroid/content/ServiceConnection;I)Z

    .line 201
    .end local v0    # "connection":Landroid/content/ServiceConnection;
    .end local v2    # "serviceIntent":Landroid/content/Intent;
    :cond_0
    return-void
.end method


# virtual methods
.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 2
    .param p1, "arg0"    # Landroid/content/Intent;

    .prologue
    .line 79
    const-string v0, "JbedVmNoRunningService"

    const-string v1, "JbedVmNoRunningService onBind"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 80
    const/4 v0, 0x0

    return-object v0
.end method

.method public onCreate()V
    .locals 2

    .prologue
    .line 84
    const-string v0, "JbedVmNoRunningService"

    const-string v1, "JbedVmNoRunningService onCreate()"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 85
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;->start()V

    .line 94
    return-void
.end method

.method public onDestroy()V
    .locals 4

    .prologue
    .line 121
    const-string v2, "JbedVmNoRunningService"

    const-string v3, "JbedVmNoRunningService onDestroy()"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 122
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 123
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    .line 124
    .local v1, "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    invoke-interface {v1, p0}, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;->onDestroy(Landroid/content/Context;)V

    goto :goto_0

    .line 126
    .end local v1    # "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 127
    return-void
.end method

.method public onInit()V
    .locals 7

    .prologue
    .line 96
    const-string v5, "JbedVmNoRunningService"

    const-string v6, "JbedVmNoRunningService onInit()"

    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 98
    new-instance v4, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    invoke-direct {v4}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;-><init>()V

    .line 99
    .local v4, "ss":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v5, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 100
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateListeners:Ljava/util/List;

    invoke-static {v4}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->access$000(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    move-result-object v6

    invoke-interface {v5, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 102
    new-instance v3, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    const/4 v5, 0x0

    invoke-direct {v3, v5}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V

    .line 103
    .local v3, "ps":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v5, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 104
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateListeners:Ljava/util/List;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$200(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    move-result-object v6

    invoke-interface {v5, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 106
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    .line 107
    .local v2, "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    invoke-interface {v2, p0}, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;->onCreate(Landroid/content/Context;)V

    goto :goto_0

    .line 110
    .end local v2    # "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    :cond_0
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 111
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v5, "com.esmertec.android.jbed.action.VMSTARTED"

    invoke-virtual {v0, v5}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 112
    const-string v5, "com.esmertec.android.jbed.action.VMSTOPPED"

    invoke-virtual {v0, v5}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 113
    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v5, v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 115
    return-void
.end method

.method public onStart(Landroid/content/Intent;I)V
    .locals 2
    .param p1, "intent"    # Landroid/content/Intent;
    .param p2, "startId"    # I

    .prologue
    .line 117
    const-string v0, "JbedVmNoRunningService"

    const-string v1, "JbedVmNoRunningService onStart()"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 118
    return-void
.end method
