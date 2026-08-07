.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 0

    .prologue
    .line 429
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onStarted()V
    .locals 3

    .prologue
    .line 431
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    sget-object v2, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1102(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 432
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1200(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    .line 433
    const/4 v0, 0x0

    .line 436
    .local v0, "pushIntent":Landroid/content/Intent;
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1300(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Ljava/util/concurrent/ArrayBlockingQueue;

    move-result-object v1

    invoke-virtual {v1}, Ljava/util/concurrent/ArrayBlockingQueue;->poll()Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "pushIntent":Landroid/content/Intent;
    check-cast v0, Landroid/content/Intent;

    .restart local v0    # "pushIntent":Landroid/content/Intent;
    if-eqz v0, :cond_0

    .line 437
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    goto :goto_0

    .line 439
    :cond_0
    return-void
.end method

.method public onStopped()V
    .locals 2

    .prologue
    .line 442
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1102(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 444
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1200(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    .line 446
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$1400(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    .line 447
    return-void
.end method
