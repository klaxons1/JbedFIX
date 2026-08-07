.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallCancelEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 170
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 174
    const-string v0, "AmsEventHandler"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "handleInstallCancelEvent() with evt is "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 175
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    packed-switch v0, :pswitch_data_0

    .line 185
    :goto_0
    return-void

    .line 177
    :pswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2717

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;->processMessageImmediately(Landroid/os/Message;)V

    goto :goto_0

    .line 175
    :pswitch_data_0
    .packed-switch 0x16
        :pswitch_0
    .end packed-switch
.end method
