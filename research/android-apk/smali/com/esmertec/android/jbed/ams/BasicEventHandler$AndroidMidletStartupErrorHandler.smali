.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidMidletStartupErrorHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 638
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    const/4 v6, 0x0

    .line 641
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    .line 642
    .local v1, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eqz v1, :cond_0

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDamaged()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 643
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f05037a

    const/4 v4, 0x1

    new-array v4, v4, [Ljava/lang/Object;

    iget-object v5, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    aput-object v5, v4, v6

    invoke-virtual {v2, v3, v4}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 644
    .local v0, "msg":Ljava/lang/String;
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f05006d

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040013

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;

    invoke-direct {v4, p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040009

    sget-object v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 660
    .end local v0    # "msg":Ljava/lang/String;
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;
    :goto_0
    return-void

    .line 659
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mContext:Landroid/content/Context;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object p0, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;
    check-cast p0, Ljava/lang/String;

    invoke-static {v2, p0, v6}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v2

    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    goto :goto_0
.end method
