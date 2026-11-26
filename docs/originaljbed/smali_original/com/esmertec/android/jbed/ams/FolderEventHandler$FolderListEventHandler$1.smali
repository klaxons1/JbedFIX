.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;)V
    .locals 0

    .prologue
    .line 219
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 221
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    const/16 v1, 0x41

    if-ne v0, v1, :cond_0

    .line 222
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestSelectStorageCancel()V

    .line 224
    :cond_0
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 225
    return-void
.end method
