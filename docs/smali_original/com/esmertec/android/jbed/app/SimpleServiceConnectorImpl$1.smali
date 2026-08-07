.class Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;
.super Landroid/os/Handler;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)V
    .locals 0

    .prologue
    .line 583
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 5
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const-string v2, "SimpleConnector"

    .line 586
    iget v0, p1, Landroid/os/Message;->what:I

    packed-switch v0, :pswitch_data_0

    .line 608
    :pswitch_0
    const-string v0, "SimpleConnector"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, " Unsupport event "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p1, Landroid/os/Message;->what:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 611
    :goto_0
    return-void

    .line 591
    :pswitch_1
    new-instance v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;-><init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;)V

    const-wide/16 v1, 0x190

    invoke-virtual {p0, v0, v1, v2}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_0

    .line 600
    :pswitch_2
    const-string v0, "SimpleConnector"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, " get HANDLE_ERROR "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 601
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mEventhListenHandler:Landroid/os/Handler;

    const v1, 0x1d4c4

    iget v2, p1, Landroid/os/Message;->arg1:I

    iget v3, p1, Landroid/os/Message;->arg2:I

    iget-object v4, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    invoke-static {v0, v1, v2, v3, v4}, Landroid/os/Message;->obtain(Landroid/os/Handler;IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 604
    :pswitch_3
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mEventhListenHandler:Landroid/os/Handler;

    const v1, 0x1d4c5

    iget v2, p1, Landroid/os/Message;->arg1:I

    iget v3, p1, Landroid/os/Message;->arg2:I

    iget-object v4, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    invoke-static {v0, v1, v2, v3, v4}, Landroid/os/Message;->obtain(Landroid/os/Handler;IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 586
    nop

    :pswitch_data_0
    .packed-switch 0x271d
        :pswitch_1
        :pswitch_0
        :pswitch_3
        :pswitch_2
    .end packed-switch
.end method
