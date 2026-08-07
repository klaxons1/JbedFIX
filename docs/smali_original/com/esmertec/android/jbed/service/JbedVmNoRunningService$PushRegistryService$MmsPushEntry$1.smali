.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;
.super Landroid/content/BroadcastReceiver;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->register(Ljava/lang/String;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;)V
    .locals 0

    .prologue
    .line 389
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;->this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 6
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 391
    invoke-static {p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->getMmsAppIdAndType(Landroid/content/Context;Landroid/content/Intent;)Lcom/esmertec/android/jbed/util/SimpleEntry;

    move-result-object v1

    .line 392
    .local v1, "info":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/String;Ljava/lang/Integer;>;"
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getKey()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 393
    .local v0, "appId":Ljava/lang/String;
    if-eqz v0, :cond_0

    iget-object v4, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;->this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;

    invoke-static {v4}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->access$1000(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;)Ljava/util/List;

    move-result-object v4

    invoke-interface {v4, v0}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v4

    const/4 v5, -0x1

    if-ne v4, v5, :cond_2

    .line 394
    :cond_0
    invoke-static {}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$700()Ljava/lang/String;

    move-result-object v4

    const-string v5, "get a mms which is not belong to registered appId"

    invoke-static {v4, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 404
    :cond_1
    :goto_0
    return-void

    .line 398
    :cond_2
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getValue()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v2

    .line 399
    .local v2, "messageType":I
    const-string v4, "state"

    const/4 v5, 0x0

    invoke-virtual {p2, v4, v5}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v3

    .line 400
    .local v3, "state":I
    const/16 v4, 0x84

    if-ne v2, v4, :cond_1

    const/4 v4, 0x1

    if-ne v3, v4, :cond_1

    .line 402
    iget-object v4, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry$1;->this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;

    iget-object v4, v4, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v4, p2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$600(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Landroid/content/Intent;)V

    goto :goto_0
.end method
