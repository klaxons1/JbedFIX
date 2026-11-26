.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;
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
    name = "SmsPushEntry"
.end annotation


# instance fields
.field private mReceiver:Landroid/content/BroadcastReceiver;

.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 1

    .prologue
    .line 325
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 327
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;

    .prologue
    .line 325
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    return-void
.end method


# virtual methods
.method public register(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "port"    # Ljava/lang/String;
    .param p2, "param1"    # Ljava/lang/String;

    .prologue
    .line 335
    invoke-static {}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$700()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "register port"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 336
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 337
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.DATA_SMS_RECEIVED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 338
    const-string v1, "sms"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addDataScheme(Ljava/lang/String;)V

    .line 339
    const-string v1, "localhost"

    invoke-static {p1}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/content/IntentFilter;->addDataAuthority(Ljava/lang/String;Ljava/lang/String;)V

    .line 341
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 342
    return-void
.end method

.method public unregister()V
    .locals 2

    .prologue
    .line 345
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;->mReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v0, v1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 346
    return-void
.end method
