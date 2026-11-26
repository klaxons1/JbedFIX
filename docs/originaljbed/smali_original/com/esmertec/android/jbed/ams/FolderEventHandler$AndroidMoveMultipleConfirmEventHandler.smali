.class public Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidMoveMultipleConfirmEventHandler"
.end annotation


# instance fields
.field private final MIDLET_IS_IN_EXTERNAL_SDCARD:I

.field private final MIDLET_IS_IN_INTERNAL_STORAGE:I

.field private choosed:[Z

.field private folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

.field private includeRoot:Z

.field private storageSelected:I

.field storages:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;


# direct methods
.method public constructor <init>()V
    .locals 2

    .prologue
    const/4 v1, 0x0

    .line 235
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 237
    const/4 v0, -0x1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    .line 239
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 240
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 241
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    .line 244
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->MIDLET_IS_IN_INTERNAL_STORAGE:I

    .line 245
    const/4 v0, 0x1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->MIDLET_IS_IN_EXTERNAL_SDCARD:I

    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showFolderChoose()V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    iget v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    return v0
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;
    .param p1, "x1"    # I

    .prologue
    .line 235
    iput p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    return p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showMultiChooseConfirm()V

    return-void
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    return-object v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showStorageSetting()V

    return-void
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    return-object v0
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    .prologue
    .line 235
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    return-object v0
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;
    .param p1, "x1"    # I

    .prologue
    .line 235
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showMoveResult(I)V

    return-void
.end method

.method private showFolderChoose()V
    .locals 10

    .prologue
    const/4 v6, 0x0

    const-string v9, "/"

    .line 323
    const/4 v1, 0x0

    .line 325
    .local v1, "isStorageChanged":Z
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    array-length v4, v4

    if-ge v0, v4, :cond_0

    .line 326
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    aget-boolean v4, v4, v0

    if-eqz v4, :cond_4

    .line 327
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v4, v4, v0

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isOnSdcard()Z

    move-result v4

    if-eqz v4, :cond_3

    const/4 v4, 0x1

    move v3, v4

    .line 328
    .local v3, "storageFlag":I
    :goto_1
    iget v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    if-eq v3, v4, :cond_4

    .line 329
    const/4 v1, 0x1

    .line 335
    .end local v3    # "storageFlag":I
    :cond_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-boolean v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->includeRoot:Z

    invoke-virtual {v4, v6, v6, v5}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getAllFolders(ZZZ)Ljava/util/List;

    move-result-object v2

    .line 336
    .local v2, "moveFolders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    if-nez v1, :cond_1

    .line 337
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v4, v4, v6

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-interface {v2, v4}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 338
    :cond_1
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v4

    invoke-virtual {v4, v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toFolderCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v4

    iput-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 341
    const/4 v0, 0x0

    :goto_2
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    array-length v4, v4

    if-ge v0, v4, :cond_6

    .line 342
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v4, v4, v0

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "/Applications"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_5

    .line 343
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "/"

    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v8, 0x7f050388

    invoke-virtual {v7, v8}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v7, v7, v0

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v5, v6, v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v5, v4, v0

    .line 341
    :cond_2
    :goto_3
    add-int/lit8 v0, v0, 0x1

    goto :goto_2

    .end local v2    # "moveFolders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_3
    move v3, v6

    .line 327
    goto :goto_1

    .line 325
    :cond_4
    add-int/lit8 v0, v0, 0x1

    goto/16 :goto_0

    .line 344
    .restart local v2    # "moveFolders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_5
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v4, v4, v0

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "/Games"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_2

    .line 345
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "/"

    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v8, 0x7f050387

    invoke-virtual {v7, v8}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v7, v7, v0

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v5, v6, v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v5, v4, v0

    goto :goto_3

    .line 350
    :cond_6
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v5, 0x7f0500b9

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;

    invoke-direct {v6, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$8;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const/high16 v5, 0x1040000

    new-instance v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$7;

    invoke-direct {v6, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$7;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 381
    return-void
.end method

.method private showMoveResult(I)V
    .locals 3
    .param p1, "result"    # I

    .prologue
    .line 435
    const-string v0, ""

    .line 436
    .local v0, "msg":Ljava/lang/String;
    sparse-switch p1, :sswitch_data_0

    .line 447
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "RemoveEventHandler unknown result value"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 438
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e5

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 449
    :goto_0
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showToast(Ljava/lang/String;)V

    .line 450
    return-void

    .line 441
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e8

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 442
    goto :goto_0

    .line 444
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 445
    goto :goto_0

    .line 436
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
    .end sparse-switch
.end method

.method private showMultiChooseConfirm()V
    .locals 7

    .prologue
    const-string v6, "\n"

    .line 293
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v5, 0x7f050383

    invoke-virtual {v4, v5}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    .line 295
    .local v3, "msg":Ljava/lang/String;
    const/4 v0, 0x0

    .line 296
    .local v0, "choosedNum":I
    const/4 v2, 0x0

    .local v2, "j":I
    :goto_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    array-length v4, v4

    if-ge v2, v4, :cond_1

    .line 297
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    aget-boolean v4, v4, v2

    if-eqz v4, :cond_0

    .line 298
    add-int/lit8 v0, v0, 0x1

    .line 296
    :cond_0
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 301
    :cond_1
    if-nez v0, :cond_2

    .line 302
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v5, 0x7f05039a

    invoke-virtual {v4, v5}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p0, v4}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showWarning(Ljava/lang/String;)V

    .line 320
    :goto_1
    return-void

    .line 305
    :cond_2
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_2
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    array-length v4, v4

    if-ge v1, v4, :cond_4

    .line 306
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    aget-boolean v4, v4, v1

    if-eqz v4, :cond_3

    .line 307
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v5, v5, v1

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\n"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\n"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 305
    :cond_3
    add-int/lit8 v1, v1, 0x1

    goto :goto_2

    .line 310
    :cond_4
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f050382

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040013

    new-instance v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$6;

    invoke-direct {v6, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$6;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040009

    sget-object v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_1
.end method

.method private showMultiMidletChoose()V
    .locals 5

    .prologue
    .line 269
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050393

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 270
    .local v0, "title":Ljava/lang/String;
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v1, v0}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    new-instance v4, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$5;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$5;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v1, v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setMultiChoiceItems([Ljava/lang/CharSequence;[ZLandroid/content/DialogInterface$OnMultiChoiceClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040013

    new-instance v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$4;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$4;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040009

    new-instance v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$3;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 290
    return-void
.end method

.method private showStorageSetting()V
    .locals 4

    .prologue
    .line 248
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05029f

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 249
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 250
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05037c

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 252
    :cond_0
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    .line 253
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05037b

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v2

    new-array v2, v2, [Ljava/lang/String;

    invoke-interface {v0, v2}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Ljava/lang/CharSequence;

    iget v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storageSelected:I

    new-instance v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$2;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v1, v0, v2, v3}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    new-instance v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040009

    sget-object v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 266
    return-void
.end method


# virtual methods
.method public getUnrunningMidlets()Ljava/util/List;
    .locals 11
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 411
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v9, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v9}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v6

    .line 413
    .local v6, "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object p0, v9, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;
    check-cast p0, Ljava/util/List;

    move-object v0, p0

    check-cast v0, Ljava/util/List;

    move-object v1, v0

    .line 415
    .local v1, "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v8

    .line 416
    .local v8, "unrunningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_0
    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_3

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 417
    .local v2, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v5, 0x0

    .line 418
    .local v5, "isRunning":Z
    invoke-interface {v6}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    .local v4, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_2

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 419
    .local v7, "runningmidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v9, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v10, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_1

    .line 420
    const/4 v5, 0x1

    .line 425
    .end local v7    # "runningmidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    iget-boolean v9, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPreInstall:Z

    if-nez v9, :cond_0

    .line 426
    if-nez v5, :cond_0

    .line 427
    invoke-interface {v8, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 431
    .end local v2    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v4    # "i$":Ljava/util/Iterator;
    .end local v5    # "isRunning":Z
    :cond_3
    return-object v8
.end method

.method public run()V
    .locals 6

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 387
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->storages:Ljava/util/List;

    .line 388
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isMidletInFolderOnly()Z

    move-result v1

    if-nez v1, :cond_0

    move v1, v5

    :goto_0
    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->includeRoot:Z

    .line 389
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-boolean v3, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->includeRoot:Z

    invoke-virtual {v2, v4, v4, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getAllFolders(ZZZ)Ljava/util/List;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toFolderCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->folders:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 391
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v1, v5, :cond_1

    .line 392
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    .line 393
    .local v0, "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 394
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toSuiteCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 398
    .end local v0    # "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :goto_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    array-length v1, v1

    if-nez v1, :cond_2

    .line 399
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050399

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showWarning(Ljava/lang/String;)V

    .line 407
    :goto_2
    return-void

    :cond_0
    move v1, v4

    .line 388
    goto :goto_0

    .line 396
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->getUnrunningMidlets()Ljava/util/List;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toSuiteCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    goto :goto_1

    .line 403
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    array-length v1, v1

    new-array v1, v1, [Z

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    .line 404
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v1, v5, :cond_3

    .line 405
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->choosed:[Z

    aput-boolean v5, v1, v4

    .line 406
    :cond_3
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showMultiMidletChoose()V

    goto :goto_2
.end method
