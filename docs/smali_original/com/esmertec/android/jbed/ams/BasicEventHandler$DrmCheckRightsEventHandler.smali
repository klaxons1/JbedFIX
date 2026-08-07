.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DrmCheckRightsEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 145
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 149
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    sparse-switch v0, :sswitch_data_0

    .line 160
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "DrmCheckRightsHandler unknown result value"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 151
    :sswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->mContext:Landroid/content/Context;

    const v1, 0x7f0501e5

    invoke-virtual {v0, v1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->showInfo(Ljava/lang/String;)V

    .line 162
    :goto_0
    return-void

    .line 154
    :sswitch_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->mContext:Landroid/content/Context;

    const v1, 0x7f0501e8

    invoke-virtual {v0, v1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->showError(Ljava/lang/String;)V

    goto :goto_0

    .line 157
    :sswitch_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmCheckRightsEventHandler;->showError(Ljava/lang/String;)V

    goto :goto_0

    .line 149
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
    .end sparse-switch
.end method
