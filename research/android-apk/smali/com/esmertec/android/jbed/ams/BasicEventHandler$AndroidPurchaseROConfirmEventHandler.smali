.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidPurchaseROConfirmEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1551
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method static synthetic access$1800(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;Ljava/lang/String;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;
    .param p1, "x1"    # Ljava/lang/String;

    .prologue
    .line 1551
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->activateDrm(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method private activateDrm(Ljava/lang/String;)Z
    .locals 3
    .param p1, "suiteID"    # Ljava/lang/String;

    .prologue
    .line 1607
    const-string v0, "AmsEventHandler"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AndroidPurchaseROConfirmEventHandler activateDrm suiteID:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1608
    iget-object p0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDrmActivateEvent(Ljava/lang/String;)V

    .line 1609
    const/4 v0, 0x1

    return v0
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    const v7, 0x7f05006d

    const v6, 0x1040013

    const v5, 0x1040009

    .line 1554
    const/4 v2, 0x0

    .line 1555
    .local v2, "msg":Ljava/lang/String;
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v3

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v1, v0

    .line 1556
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-nez v3, :cond_1

    .line 1557
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f050394

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    .line 1558
    new-instance v3, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-direct {v3, v4}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v4, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$1;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V

    invoke-virtual {v3, v6, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    sget-object v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v3, v5, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 1604
    :cond_0
    :goto_0
    return-void

    .line 1568
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v4, 0x1

    if-ne v3, v4, :cond_2

    .line 1569
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f050395

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    .line 1570
    new-instance v3, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-direct {v3, v4}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v4, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V

    invoke-virtual {v3, v6, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V

    invoke-virtual {v3, v5, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0

    .line 1587
    :cond_2
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v4, 0x2

    if-ne v3, v4, :cond_0

    .line 1588
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f050396

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    .line 1589
    new-instance v3, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-direct {v3, v4}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v4, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$5;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$5;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V

    invoke-virtual {v3, v6, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$4;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$4;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V

    invoke-virtual {v3, v5, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0
.end method
