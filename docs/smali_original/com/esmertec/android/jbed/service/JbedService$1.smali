.class Lcom/esmertec/android/jbed/service/JbedService$1;
.super Lcom/esmertec/android/jbed/service/IJbedService$Stub;
.source "JbedService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedService;)V
    .locals 0

    .prologue
    .line 74
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;-><init>()V

    return-void
.end method


# virtual methods
.method public openAmsConnection()Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 119
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedService;->mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

    return-object v0
.end method

.method public openConnection()Lcom/esmertec/android/jbed/service/IJbedConnection;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 98
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedService$1$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedService$1$1;-><init>(Lcom/esmertec/android/jbed/service/JbedService$1;)V

    return-object v0
.end method

.method public openTextFieldConnection()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 123
    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;-><init>(Landroid/os/Handler;)V

    .line 124
    .local v0, "textFieldConnection":Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
    iget-object v1, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    return-object v1
.end method

.method public requestVmBackground()V
    .locals 1

    .prologue
    .line 136
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->requestVmBackground()V

    .line 137
    return-void
.end method

.method public setRotateHappen(Z)V
    .locals 1
    .param p1, "b"    # Z

    .prologue
    .line 131
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    iput-boolean p1, v0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRotating:Z

    .line 132
    return-void
.end method

.method public setStartWay(Z)V
    .locals 1
    .param p1, "b"    # Z

    .prologue
    .line 143
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    iput-boolean p1, v0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRunFromHome:Z

    .line 144
    return-void
.end method

.method public setVmState(II)V
    .locals 3
    .param p1, "state"    # I
    .param p2, "reason"    # I

    .prologue
    .line 150
    const/4 v0, -0x1

    .line 151
    .local v0, "event":I
    packed-switch p1, :pswitch_data_0

    .line 159
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "jbedservice setVmState recieve an un-recognize state"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 153
    :pswitch_0
    const/16 v0, 0x8

    .line 161
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    const/4 v2, 0x0

    invoke-virtual {v1, v0, p2, v2}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 162
    return-void

    .line 156
    :pswitch_1
    const/4 v0, 0x7

    .line 157
    goto :goto_0

    .line 151
    nop

    :pswitch_data_0
    .packed-switch 0x2
        :pswitch_0
        :pswitch_1
    .end packed-switch
.end method

.method public shutdownVm()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 92
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 93
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->stopVmAndWait()V

    .line 95
    :cond_0
    return-void
.end method

.method public startVm(IIIIIZZ)V
    .locals 8
    .param p1, "viewWidth"    # I
    .param p2, "viewHeight"    # I
    .param p3, "bytesPerPixel"    # I
    .param p4, "viewFullScreenWidth"    # I
    .param p5, "viewFullScreenHeight"    # I
    .param p6, "isRefresh"    # Z
    .param p7, "forceSizeChanged"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 78
    const-string v0, "jbedservice"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " startVm \n>> viewWidth="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> viewHeight="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> bytesPerPixel="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> viewFullScreenWidth="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> viewFullScreenHeight="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> isRefresh="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p6}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "\n>> mUiEventListener"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedService;->access$000(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/IJbedUiListener;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 87
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    move v6, p6

    move v7, p7

    invoke-virtual/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/JbedEngine;->startVm(IIIIIZZ)Z

    .line 89
    return-void
.end method
