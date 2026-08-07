.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RemoveAllEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 618
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 621
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    sparse-switch v0, :sswitch_data_0

    .line 632
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "RemoveAllEventHandler unknown result value"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 623
    :sswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x271b

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 624
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;->mContext:Landroid/content/Context;

    const v1, 0x7f0501e7

    invoke-virtual {v0, v1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;->showInfo(Ljava/lang/String;)V

    .line 635
    return-void

    .line 630
    :sswitch_1
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "RemoveAllEventHandler RES_RUNNING_MIDLETS should be process at requestRemove()!"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 621
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x15 -> :sswitch_1
    .end sparse-switch
.end method
