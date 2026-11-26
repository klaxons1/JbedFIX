.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;
.super Landroid/content/BroadcastReceiver;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)V
    .locals 0

    .prologue
    .line 129
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 5
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    const-string v4, "JbedVmNoRunningService"

    .line 132
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v2

    const-string v3, "com.esmertec.android.jbed.action.VMSTARTED"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 133
    const-string v2, "JbedVmNoRunningService"

    const-string v2, "get ACTION_JBED_VM_STARTED"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 134
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->access$300(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    .line 135
    .local v1, "l":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;->onStarted()V

    goto :goto_0

    .line 137
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "l":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    :cond_0
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v2

    const-string v3, "com.esmertec.android.jbed.action.VMSTOPPED"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 138
    const-string v2, "JbedVmNoRunningService"

    const-string v2, "get ACTION_JBED_VM_STOPPED"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 139
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->access$300(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .restart local v0    # "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    .line 140
    .restart local v1    # "l":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;->onStopped()V

    goto :goto_1

    .line 143
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "l":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    :cond_1
    new-instance v2, Ljava/lang/UnsupportedOperationException;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "unsupport action "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 145
    .restart local v0    # "i$":Ljava/util/Iterator;
    :cond_2
    return-void
.end method
