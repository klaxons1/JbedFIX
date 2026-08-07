.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "MidletLifecycleEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 88
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .prologue
    .line 91
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x271f

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v1, v2, v3, v4}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 93
    return-void
.end method
