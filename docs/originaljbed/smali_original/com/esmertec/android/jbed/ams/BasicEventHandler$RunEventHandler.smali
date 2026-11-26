.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RunEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 100
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 104
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271d

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->processMessageImmediately(Landroid/os/Message;)V

    .line 105
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0xf

    if-eq v1, v2, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0x1b

    if-ne v1, v2, :cond_2

    .line 106
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2724

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 113
    :cond_1
    :goto_0
    return-void

    .line 107
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x1

    if-ne v1, v2, :cond_1

    .line 108
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 109
    .local v0, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eqz v0, :cond_1

    .line 110
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFullScreen()Z

    move-result v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;->bringMidletToForeground(Z)V

    goto :goto_0
.end method
