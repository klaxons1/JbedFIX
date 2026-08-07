.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 42
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 44
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFullPath()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveFolderEvent(Ljava/lang/String;)V

    .line 45
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x271a

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 46
    return-void
.end method
