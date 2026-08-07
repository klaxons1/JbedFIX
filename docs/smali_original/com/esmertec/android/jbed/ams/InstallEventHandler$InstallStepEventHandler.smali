.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallStepEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 482
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .prologue
    const/4 v4, 0x0

    .line 485
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0xd

    if-eq v1, v2, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x3

    if-ne v1, v2, :cond_1

    .line 489
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2713

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v1, v2, v3, v4}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->processMessageImmediately(Landroid/os/Message;)V

    .line 491
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050377

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 492
    .local v0, "msg":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2719

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v1, v2, v3, v4, v0}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 494
    .end local v0    # "msg":Ljava/lang/String;
    :cond_1
    return-void
.end method
