.class public Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FolderOperationResultEventHandler"
.end annotation


# instance fields
.field mErrorInfo:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 103
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 105
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mErrorInfo:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public parseData([B)V
    .locals 1
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 109
    if-nez p1, :cond_0

    .line 112
    :goto_0
    return-void

    .line 111
    :cond_0
    new-instance v0, Ljava/lang/String;

    invoke-direct {v0, p1}, Ljava/lang/String;-><init>([B)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mErrorInfo:Ljava/lang/String;

    goto :goto_0
.end method

.method public run()V
    .locals 3

    .prologue
    .line 115
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271b

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 116
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x1

    if-eq v1, v2, :cond_1

    .line 117
    const/4 v0, 0x0

    .line 118
    .local v0, "listener":Landroid/content/DialogInterface$OnClickListener;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    packed-switch v1, :pswitch_data_0

    .line 128
    :pswitch_0
    const/4 v0, 0x0

    .line 130
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mErrorInfo:Ljava/lang/String;

    invoke-virtual {p0, v1, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->showError(Ljava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V

    .line 134
    .end local v0    # "listener":Landroid/content/DialogInterface$OnClickListener;
    :cond_0
    :goto_1
    return-void

    .line 121
    .restart local v0    # "listener":Landroid/content/DialogInterface$OnClickListener;
    :pswitch_1
    new-instance v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler$1;

    .end local v0    # "listener":Landroid/content/DialogInterface$OnClickListener;
    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;)V

    .line 126
    .restart local v0    # "listener":Landroid/content/DialogInterface$OnClickListener;
    goto :goto_0

    .line 131
    .end local v0    # "listener":Landroid/content/DialogInterface$OnClickListener;
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    const/16 v2, 0x3f

    if-ne v1, v2, :cond_0

    .line 132
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e6

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->showInfo(Ljava/lang/String;)V

    goto :goto_1

    .line 118
    :pswitch_data_0
    .packed-switch 0x3c
        :pswitch_1
        :pswitch_0
        :pswitch_1
    .end packed-switch
.end method
