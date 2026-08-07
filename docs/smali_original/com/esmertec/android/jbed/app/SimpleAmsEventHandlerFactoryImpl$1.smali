.class Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;->buildAmsHandler(I)Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;)V
    .locals 0

    .prologue
    .line 704
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .prologue
    const/16 v4, 0x2720

    const/4 v3, 0x0

    .line 707
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    sparse-switch v0, :sswitch_data_0

    .line 725
    const-string v0, "AmsEventHandler"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "WARNING, ignored ams event "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 728
    :goto_0
    return-void

    .line 709
    :sswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v1, 0xf

    if-ne v0, v1, :cond_0

    .line 710
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mHandler:Landroid/os/Handler;

    const/4 v1, 0x2

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v4, v1, v3, v2}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    goto :goto_0

    .line 712
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x271d

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 718
    :sswitch_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x271f

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iget-object v4, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v1, v2, v3, v4}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 722
    :sswitch_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x3a

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v4, v1, v3, v2}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    goto :goto_0

    .line 707
    :sswitch_data_0
    .sparse-switch
        0x2 -> :sswitch_0
        0xb -> :sswitch_1
        0x11 -> :sswitch_1
        0x12 -> :sswitch_1
        0x3a -> :sswitch_2
    .end sparse-switch
.end method
