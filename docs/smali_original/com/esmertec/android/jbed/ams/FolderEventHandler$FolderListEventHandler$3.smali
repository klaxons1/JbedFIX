.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;
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

.field final synthetic val$folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;)V
    .locals 0

    .prologue
    .line 201
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->val$folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "pos"    # I

    .prologue
    .line 203
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->val$folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v2, v2, p2

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFullPath()Ljava/lang/String;

    move-result-object v1

    .line 204
    .local v1, "selectedPath":Ljava/lang/String;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    const/16 v3, 0x41

    if-ne v2, v3, :cond_0

    .line 205
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object p0, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstalledFolderEvent(Ljava/lang/String;)V

    .line 210
    :goto_0
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 211
    return-void

    .line 207
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v2, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2, v3, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveToFolderEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)I

    move-result v0

    .line 208
    .local v0, "result":I
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->access$000(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;I)V

    goto :goto_0
.end method
