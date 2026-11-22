.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

.field final synthetic val$edtText:Landroid/widget/EditText;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;Landroid/widget/EditText;)V
    .locals 0

    .prologue
    .line 67
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->val$edtText:Landroid/widget/EditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 69
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->val$edtText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    .line 70
    .local v1, "newName":Ljava/lang/String;
    const-string v0, "/"

    .line 71
    .local v0, "folderPath":Ljava/lang/String;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    if-eqz v2, :cond_0

    .line 72
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFullPath()Ljava/lang/String;

    move-result-object v0

    .line 73
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v3, 0x3c

    if-ne v2, v3, :cond_2

    .line 74
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object p0, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestCreateFolder(Ljava/lang/String;Ljava/lang/String;)V

    .line 79
    :cond_1
    :goto_0
    return-void

    .line 75
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;
    :cond_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    if-eqz v2, :cond_1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_1

    .line 77
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object p0, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRenameFolder(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0
.end method
