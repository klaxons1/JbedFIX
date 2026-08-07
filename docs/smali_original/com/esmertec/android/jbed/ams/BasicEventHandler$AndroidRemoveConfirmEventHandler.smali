.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidRemoveConfirmEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 436
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    .prologue
    .line 436
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->remove()Z

    move-result v0

    return v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    .prologue
    .line 436
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->removeAll()Z

    move-result v0

    return v0
.end method

.method private remove()Z
    .locals 7

    .prologue
    const/4 v3, 0x1

    const/4 v6, 0x0

    .line 538
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->isRuningSuite(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 543
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0502ad

    new-array v3, v3, [Ljava/lang/Object;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v4

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    aput-object v4, v3, v6

    invoke-virtual {v1, v2, v3}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 545
    .local v0, "msg":Ljava/lang/String;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->showError(Ljava/lang/String;)V

    move v1, v6

    .line 550
    .end local v0    # "msg":Ljava/lang/String;
    :goto_0
    return v1

    .line 549
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveEvent(Ljava/lang/String;)V

    move v1, v3

    .line 550
    goto :goto_0
.end method

.method private removeAll()Z
    .locals 11

    .prologue
    const/4 v10, 0x1

    const/4 v9, 0x0

    .line 555
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v5, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v4

    .line 556
    .local v4, "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v4}, Ljava/util/List;->size()I

    move-result v5

    if-lez v5, :cond_1

    .line 560
    const-string v3, ""

    .line 561
    .local v3, "nameList":Ljava/lang/String;
    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 563
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v8, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v6

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "\n"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    goto :goto_0

    .line 566
    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_0
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f0502ad

    new-array v7, v10, [Ljava/lang/Object;

    aput-object v3, v7, v9

    invoke-virtual {v5, v6, v7}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    .line 568
    .local v2, "msg":Ljava/lang/String;
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->showError(Ljava/lang/String;)V

    move v5, v9

    .line 572
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v2    # "msg":Ljava/lang/String;
    .end local v3    # "nameList":Ljava/lang/String;
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;
    :goto_1
    return v5

    .line 571
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;
    :cond_1
    iget-object p0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveAllEvent()V

    move v5, v10

    .line 572
    goto :goto_1
.end method


# virtual methods
.method public run()V
    .locals 13

    .prologue
    const v12, 0x7f0500a2

    const-string v11, "\n"

    .line 439
    const/4 v5, 0x0

    .line 441
    .local v5, "msg":Ljava/lang/String;
    const/4 v6, 0x7

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v7, v7, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v6, v7, :cond_4

    .line 442
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v6

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v2, v0

    .line 443
    .local v2, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f0500a0

    const/4 v8, 0x1

    new-array v8, v8, [Ljava/lang/Object;

    const/4 v9, 0x0

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v10

    aput-object v10, v8, v9

    invoke-virtual {v6, v7, v8}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    .line 444
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v6

    if-eqz v6, :cond_0

    .line 445
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v8, 0x7f0500a1

    invoke-virtual {v7, v8}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 446
    iget-object v6, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v6}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    .local v3, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_0

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 447
    .local v1, "child":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto :goto_0

    .line 450
    .end local v1    # "child":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v3    # "i$":Ljava/util/Iterator;
    :cond_0
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v7, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 452
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v6

    const-string v7, "LGE"

    invoke-virtual {v6, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_1

    iget-boolean v6, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    if-eqz v6, :cond_1

    .line 453
    iget v6, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    const/4 v7, 0x3

    if-ne v6, v7, :cond_3

    .line 454
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f050381

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    .line 459
    :cond_1
    :goto_1
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getDeleteConfirmText()Ljava/lang/String;

    move-result-object v6

    if-eqz v6, :cond_2

    .line 460
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getDeleteConfirmText()Ljava/lang/String;

    move-result-object v5

    .line 478
    .end local v2    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    :goto_2
    new-instance v6, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v7

    invoke-direct {v6, v7}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v8, 0x7f05006d

    invoke-virtual {v7, v8}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v6

    invoke-virtual {v6, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v6

    const v7, 0x1040013

    new-instance v8, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;

    invoke-direct {v8, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)V

    invoke-virtual {v6, v7, v8}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v6

    const v7, 0x1040009

    new-instance v8, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;

    invoke-direct {v8, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)V

    invoke-virtual {v6, v7, v8}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v6

    invoke-virtual {v6}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 502
    return-void

    .line 456
    .restart local v2    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_3
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f05038d

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    goto :goto_1

    .line 462
    .end local v2    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_4
    const/16 v6, 0x1a

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v7, v7, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v6, v7, :cond_2

    .line 463
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v6, v6, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v6, Ljava/util/List;

    move-object v0, v6

    check-cast v0, Ljava/util/List;

    move-object v4, v0

    .line 464
    .local v4, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f05013c

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    .line 465
    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    .restart local v3    # "i$":Ljava/util/Iterator;
    :cond_5
    :goto_3
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_6

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 466
    .restart local v1    # "child":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v6

    if-eqz v6, :cond_5

    .line 467
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto :goto_3

    .line 470
    .end local v1    # "child":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_6
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v7, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    goto/16 :goto_2
.end method
