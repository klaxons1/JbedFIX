.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidRemoveMultipleConfirmEventHandler"
.end annotation


# instance fields
.field private choosed:[Z

.field private suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 291
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 292
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    .prologue
    .line 291
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->showMultiChooseConfirm()V

    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    .prologue
    .line 291
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    .prologue
    .line 291
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    return-object v0
.end method

.method private showMultiChooseConfirm()V
    .locals 14

    .prologue
    const v13, 0x7f050381

    const/high16 v12, 0x7f020000

    const v11, 0x1040009

    const-string v10, "\n"

    .line 343
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v9, 0x7f050384

    invoke-virtual {v8, v9}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v7

    .line 344
    .local v7, "msg":Ljava/lang/String;
    const/4 v0, 0x1

    .line 345
    .local v0, "checkjadproperity":Z
    const-string v6, ""

    .line 347
    .local v6, "mgrUserDeniedbyJAD":Ljava/lang/String;
    const/4 v1, 0x0

    .line 348
    .local v1, "choosedNum":I
    const/4 v5, 0x0

    .local v5, "j":I
    :goto_0
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    array-length v8, v8

    if-ge v5, v8, :cond_1

    .line 349
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    aget-boolean v8, v8, v5

    if-eqz v8, :cond_0

    .line 350
    add-int/lit8 v1, v1, 0x1

    .line 348
    :cond_0
    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    .line 353
    :cond_1
    if-nez v1, :cond_2

    .line 354
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v9, 0x7f05039a

    invoke-virtual {v8, v9}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->showWarning(Ljava/lang/String;)V

    .line 404
    :goto_1
    return-void

    .line 357
    :cond_2
    const/4 v4, 0x0

    .local v4, "i":I
    :goto_2
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    array-length v8, v8

    if-ge v4, v8, :cond_4

    .line 358
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    aget-boolean v8, v8, v4

    if-eqz v8, :cond_3

    .line 359
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v9, v9, v4

    iget-object v9, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v9, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "\n"

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "\n"

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    .line 360
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v8, v8, v4

    iget-object v8, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v8}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getMgrUserDenied()Ljava/lang/String;

    move-result-object v6

    .line 361
    if-eqz v6, :cond_3

    const-string v8, "delete"

    invoke-virtual {v6, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_3

    .line 362
    const/4 v0, 0x0

    .line 365
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    aget-object v9, v9, v4

    iget-object v9, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v9, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "\n"

    invoke-virtual {v8, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "is not allowed to be delete by JAD"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    .line 357
    :cond_3
    add-int/lit8 v4, v4, 0x1

    goto :goto_2

    .line 370
    :cond_4
    if-nez v0, :cond_6

    .line 371
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v13}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v7}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    sget-object v9, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v3

    .line 376
    .local v3, "confirmDialogbyJAD":Landroid/app/AlertDialog;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v8

    if-eqz v8, :cond_5

    .line 377
    invoke-virtual {v3, v12}, Landroid/app/AlertDialog;->setIcon(I)V

    .line 378
    :cond_5
    invoke-virtual {v3}, Landroid/app/AlertDialog;->show()V

    goto/16 :goto_1

    .line 381
    .end local v3    # "confirmDialogbyJAD":Landroid/app/AlertDialog;
    :cond_6
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v13}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v7}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    const v9, 0x1040013

    new-instance v10, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;

    invoke-direct {v10, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V

    invoke-virtual {v8, v9, v10}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    sget-object v9, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v2

    .line 399
    .local v2, "confirmDialog":Landroid/app/AlertDialog;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v8

    if-eqz v8, :cond_7

    .line 400
    invoke-virtual {v2, v12}, Landroid/app/AlertDialog;->setIcon(I)V

    .line 401
    :cond_7
    invoke-virtual {v2}, Landroid/app/AlertDialog;->show()V

    goto/16 :goto_1
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
    .line 408
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v9, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v9}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v6

    .line 410
    .local v6, "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object p0, v9, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;
    check-cast p0, Ljava/util/List;

    move-object v0, p0

    check-cast v0, Ljava/util/List;

    move-object v1, v0

    .line 412
    .local v1, "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v8

    .line 413
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

    .line 414
    .local v2, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v5, 0x0

    .line 415
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

    .line 416
    .local v7, "runningmidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v9, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v10, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_1

    .line 417
    const/4 v5, 0x1

    .line 422
    .end local v7    # "runningmidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    iget-boolean v9, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPreInstall:Z

    if-nez v9, :cond_0

    .line 423
    if-nez v5, :cond_0

    .line 424
    invoke-interface {v8, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 428
    .end local v2    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v4    # "i$":Ljava/util/Iterator;
    .end local v5    # "isRunning":Z
    :cond_3
    return-object v8
.end method

.method public run()V
    .locals 6

    .prologue
    const/4 v5, 0x0

    const/4 v4, 0x1

    .line 299
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v2, v4, :cond_0

    .line 300
    new-array v3, v4, [Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    aput-object v2, v3, v5

    invoke-static {v3}, Lcom/google/android/collect/Lists;->newArrayList([Ljava/lang/Object;)Ljava/util/ArrayList;

    move-result-object v0

    .line 301
    .local v0, "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v2

    invoke-virtual {v2, v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toSuiteCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 308
    :goto_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    array-length v2, v2

    if-nez v2, :cond_1

    .line 309
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f050399

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->showWarning(Ljava/lang/String;)V

    .line 340
    :goto_1
    return-void

    .line 303
    .end local v0    # "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->getUnrunningMidlets()Ljava/util/List;

    move-result-object v0

    .line 304
    .restart local v0    # "allMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    sget-object v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_ORDER:Ljava/util/Comparator;

    invoke-static {v0, v2}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 305
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v2

    invoke-virtual {v2, v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toSuiteCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    goto :goto_0

    .line 313
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    array-length v2, v2

    new-array v2, v2, [Z

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    .line 314
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-ne v2, v4, :cond_2

    .line 315
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    aput-boolean v4, v2, v5

    .line 317
    :cond_2
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v3, 0x7f050381

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->choosed:[Z

    new-instance v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$3;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V

    invoke-virtual {v2, v3, v4, v5}, Landroid/app/AlertDialog$Builder;->setMultiChoiceItems([Ljava/lang/CharSequence;[ZLandroid/content/DialogInterface$OnMultiChoiceClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040013

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040009

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$1;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v1

    .line 337
    .local v1, "dialog":Landroid/app/AlertDialog;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v2

    if-eqz v2, :cond_3

    .line 338
    const/high16 v2, 0x7f020000

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog;->setIcon(I)V

    .line 339
    :cond_3
    invoke-virtual {v1}, Landroid/app/AlertDialog;->show()V

    goto :goto_1
.end method
