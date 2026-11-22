.class Lcom/esmertec/android/jbed/service/JbedEngine$1;
.super Landroid/os/Handler;
.source "JbedEngine.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedEngine;-><init>(Landroid/app/Service;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

.field final synthetic val$s:Landroid/app/Service;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 108
    const-class v0, Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->$assertionsDisabled:Z

    return-void

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;Landroid/app/Service;)V
    .locals 0

    .prologue
    .line 108
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iput-object p2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->val$s:Landroid/app/Service;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 8
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const/4 v7, 0x0

    const/4 v5, 0x2

    const-string v6, " oldReason="

    const-string v4, "JbedEngine"

    .line 111
    iget v2, p1, Landroid/os/Message;->what:I

    packed-switch v2, :pswitch_data_0

    .line 163
    :pswitch_0
    const-string v2, "JbedEngine"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Unhandled message received. WHAT: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p1, Landroid/os/Message;->what:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 165
    :cond_0
    :goto_0
    return-void

    .line 114
    :pswitch_1
    const-string v2, "JbedEngine"

    const-string v2, "FINISH SERVICE"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 116
    invoke-virtual {p0, v5}, Lcom/esmertec/android/jbed/service/JbedEngine$1;->removeMessages(I)V

    .line 117
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2, v7}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$002(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .line 119
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$100(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v2

    if-eqz v2, :cond_1

    .line 120
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$100(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v2

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->finish()V

    .line 121
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->val$s:Landroid/app/Service;

    invoke-virtual {v2}, Landroid/app/Service;->stopSelf()V

    goto :goto_0

    .line 124
    :pswitch_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$200(Lcom/esmertec/android/jbed/service/JbedEngine;)I

    move-result v1

    .line 126
    .local v1, "ret":I
    if-lez v1, :cond_2

    .line 127
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$300(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 128
    :cond_2
    invoke-virtual {p0, v5}, Lcom/esmertec/android/jbed/service/JbedEngine$1;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 130
    .local v0, "pollNetworkMsg":Landroid/os/Message;
    const-wide/16 v2, 0x1f4

    invoke-virtual {p0, v0, v2, v3}, Lcom/esmertec/android/jbed/service/JbedEngine$1;->sendMessageDelayed(Landroid/os/Message;J)Z

    move-result v2

    if-nez v2, :cond_0

    .line 131
    const-string v2, "JbedEngine"

    const-string v2, "failed to put the JBED_EVT_POLL_NETWORK to queue."

    invoke-static {v4, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 135
    .end local v0    # "pollNetworkMsg":Landroid/os/Message;
    .end local v1    # "ret":I
    :pswitch_3
    sget-boolean v2, Lcom/esmertec/android/jbed/service/JbedEngine$1;->$assertionsDisabled:Z

    if-nez v2, :cond_3

    iget-object v2, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    if-nez v2, :cond_3

    new-instance v2, Ljava/lang/AssertionError;

    invoke-direct {v2}, Ljava/lang/AssertionError;-><init>()V

    throw v2

    .line 136
    :cond_3
    iget-object v2, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v2, Ljava/lang/Runnable;

    invoke-interface {v2}, Ljava/lang/Runnable;->run()V

    .line 138
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$300(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    goto :goto_0

    .line 142
    :pswitch_4
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, p1, Landroid/os/Message;->arg1:I

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$400(Lcom/esmertec/android/jbed/service/JbedEngine;I)V

    .line 144
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$300(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    goto :goto_0

    .line 147
    :pswitch_5
    const-string v2, "JbedEngine"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " request vm to IDLE. priority="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p1, Landroid/os/Message;->arg1:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " oldReason="

    invoke-virtual {v2, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 148
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    const/4 v3, 0x1

    iget v4, p1, Landroid/os/Message;->arg1:I

    invoke-static {v2, v3, v4}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$500(Lcom/esmertec/android/jbed/service/JbedEngine;II)V

    goto/16 :goto_0

    .line 151
    :pswitch_6
    const-string v2, "JbedEngine"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " request vm to background. priority="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p1, Landroid/os/Message;->arg1:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " oldReason="

    invoke-virtual {v2, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 152
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, p1, Landroid/os/Message;->arg1:I

    invoke-static {v2, v5, v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$500(Lcom/esmertec/android/jbed/service/JbedEngine;II)V

    goto/16 :goto_0

    .line 156
    :pswitch_7
    const-string v2, "JbedEngine"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " request vm to foreground. priority="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p1, Landroid/os/Message;->arg1:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " oldReason="

    invoke-virtual {v2, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 157
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    const/4 v3, 0x3

    iget v4, p1, Landroid/os/Message;->arg1:I

    invoke-static {v2, v3, v4}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$500(Lcom/esmertec/android/jbed/service/JbedEngine;II)V

    goto/16 :goto_0

    .line 160
    :pswitch_8
    new-instance v2, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-direct {v2, v3, v7}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedEngine$1;)V

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->run()V

    goto/16 :goto_0

    .line 111
    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_2
        :pswitch_3
        :pswitch_0
        :pswitch_4
        :pswitch_5
        :pswitch_7
        :pswitch_6
        :pswitch_8
    .end packed-switch
.end method
