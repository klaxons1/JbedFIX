.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RemoveEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 580
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 584
    const-string v0, ""

    .line 585
    .local v0, "msg":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    sparse-switch v1, :sswitch_data_0

    .line 601
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "RemoveEventHandler unknown result value"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 587
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e6

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 603
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271b

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 606
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isShowToastEnabled()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 607
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->showToast(Ljava/lang/String;)V

    .line 612
    :goto_1
    return-void

    .line 590
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050368

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 591
    goto :goto_0

    .line 593
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050369

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 594
    goto :goto_0

    .line 599
    :sswitch_3
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "RemoveEventHandler RES_RUNNING_MIDLETS should be process at requestRemove()!"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 609
    :cond_0
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;->showInfo(Ljava/lang/String;)V

    goto :goto_1

    .line 585
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
        0x15 -> :sswitch_3
    .end sparse-switch
.end method
