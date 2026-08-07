.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DrmActivateEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 169
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 173
    const-string v0, ""

    .line 174
    .local v0, "msg":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    sparse-switch v1, :sswitch_data_0

    .line 186
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "DrmActivateEventHandler unknown result value"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 177
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050278

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 188
    :goto_0
    const-string v1, "AmsEventHandler"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "DrmActivateEventHandler msg:"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 189
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "LGE"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    .line 190
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;->showToast(Ljava/lang/String;)V

    .line 191
    :cond_0
    return-void

    .line 180
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e8

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 181
    goto :goto_0

    .line 183
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 184
    goto :goto_0

    .line 174
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
    .end sparse-switch
.end method
