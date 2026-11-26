.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "MmsPushEntry"
.end annotation


# static fields
.field private static final STATE:Ljava/lang/String; = "state"

.field private static final SUCCESS:I = 0x1

.field private static final TRANSACTION_COMPLETED_ACTION:Ljava/lang/String; = "android.intent.action.TRANSACTION_COMPLETED_ACTION"


# instance fields
.field private mReceiver:Landroid/content/BroadcastReceiver;

.field private mRegisteredAppIds:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 1

    .prologue
    .line 372
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 383
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    .line 385
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mRegisteredAppIds:Ljava/util/List;

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;

    .prologue
    .line 372
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    return-void
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;

    .prologue
    .line 372
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mRegisteredAppIds:Ljava/util/List;

    return-object v0
.end method


# virtual methods
.method public register(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p1, "port"    # Ljava/lang/String;
    .param p2, "param1"    # Ljava/lang/String;

    .prologue
    .line 388
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    if-nez v1, :cond_0

    .line 389
    new-instance v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;)V

    iput-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    .line 406
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 407
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.TRANSACTION_COMPLETED_ACTION"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 408
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 410
    .end local v0    # "filter":Landroid/content/IntentFilter;
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mRegisteredAppIds:Ljava/util/List;

    invoke-interface {v1, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 411
    return-void
.end method

.method public unregister()V
    .locals 2

    .prologue
    .line 414
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    if-eqz v0, :cond_0

    .line 415
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v0, v1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 416
    :cond_0
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    .line 417
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->mRegisteredAppIds:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 418
    return-void
.end method
