.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "MoveEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 120
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 124
    const-string v0, ""

    .line 125
    .local v0, "msg":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    sparse-switch v1, :sswitch_data_0

    .line 136
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "RemoveEventHandler unknown result value"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 127
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e5

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 138
    :goto_0
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;->showToast(Ljava/lang/String;)V

    .line 139
    return-void

    .line 130
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e8

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 131
    goto :goto_0

    .line 133
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 134
    goto :goto_0

    .line 125
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
    .end sparse-switch
.end method
