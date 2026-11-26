.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showFolderChoose()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 353
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 8
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "pos"    # I

    .prologue
    .line 355
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$600(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v6

    aget-object v6, v6, p2

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFullPath()Ljava/lang/String;

    move-result-object v4

    .line 356
    .local v4, "selectedPath":Ljava/lang/String;
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$400(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Z

    move-result-object v6

    array-length v6, v6

    if-ge v0, v6, :cond_3

    .line 357
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$400(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Z

    move-result-object v6

    aget-boolean v6, v6, v0

    if-eqz v6, :cond_1

    .line 358
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$200(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)I

    move-result v6

    const/4 v7, -0x1

    if-eq v6, v7, :cond_1

    .line 359
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$200(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)I

    move-result v7

    invoke-interface {v6, v7}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .line 360
    .local v5, "storage":Ljava/lang/String;
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f05037c

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_0

    .line 361
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    .line 362
    :cond_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v6, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$700(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v7

    aget-object v7, v7, v0

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7, v5}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveToStorageEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-result-object v3

    .line 363
    .local v3, "resultStorageEvent":Lcom/esmertec/android/jbed/ams/AmsEvent;
    iget v6, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v7, 0x1

    if-eq v6, v7, :cond_2

    .line 364
    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v1

    .line 365
    .local v1, "msg":Ljava/lang/String;
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-virtual {v6, v1}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showToast(Ljava/lang/String;)V

    .line 356
    .end local v1    # "msg":Ljava/lang/String;
    .end local v3    # "resultStorageEvent":Lcom/esmertec/android/jbed/ams/AmsEvent;
    .end local v5    # "storage":Ljava/lang/String;
    :cond_1
    :goto_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 367
    .restart local v3    # "resultStorageEvent":Lcom/esmertec/android/jbed/ams/AmsEvent;
    .restart local v5    # "storage":Ljava/lang/String;
    :cond_2
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v6, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$700(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v7

    aget-object v7, v7, v0

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7, v4}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveToFolderEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)I

    move-result v2

    .line 368
    .local v2, "resultFolderEvent":I
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v6, v2}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$800(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;I)V

    goto :goto_1

    .line 373
    .end local v2    # "resultFolderEvent":I
    .end local v3    # "resultStorageEvent":Lcom/esmertec/android/jbed/ams/AmsEvent;
    .end local v5    # "storage":Ljava/lang/String;
    :cond_3
    return-void
.end method
