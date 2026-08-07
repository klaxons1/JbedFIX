.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallProgressEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 122
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    const/16 v1, 0x64

    const-string v2, "AmsEventHandler"

    .line 126
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ltz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-le v0, v1, :cond_1

    .line 127
    :cond_0
    const-string v0, "AmsEventHandler"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Receive invalid progress is "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 134
    :goto_0
    return-void

    .line 130
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v0, v1, :cond_2

    .line 131
    const-string v0, "AmsEventHandler"

    const-string v0, "Receive finished downloading result."

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 133
    :cond_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2714

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0
.end method
