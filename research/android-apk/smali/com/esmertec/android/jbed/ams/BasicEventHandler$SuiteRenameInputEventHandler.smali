.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SuiteRenameInputEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1352
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    .line 1355
    const-string v5, "AmsEventHandler"

    const-string v6, "SuiteNameInputEventHandler"

    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1356
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->mContext:Landroid/content/Context;

    const-string v6, "layout_inflater"

    invoke-virtual {v5, v6}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/view/LayoutInflater;

    .line 1357
    .local v1, "mInflater":Landroid/view/LayoutInflater;
    const v5, 0x7f030007

    const/4 v6, 0x0

    invoke-virtual {v1, v5, v6}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v4

    .line 1358
    .local v4, "v":Landroid/view/View;
    const v5, 0x7f080002

    invoke-virtual {v4, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/EditText;

    .line 1359
    .local v0, "edtText":Landroid/widget/EditText;
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    .line 1361
    .local v2, "oldName":Ljava/lang/String;
    invoke-virtual {v0, v2}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 1363
    new-instance v5, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-direct {v5, v6}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v6, 0x7f0500af

    invoke-virtual {v5, v6}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v5

    invoke-virtual {v5, v4}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v5

    const v6, 0x1040013

    new-instance v7, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;

    invoke-direct {v7, p0, v0, v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;Landroid/widget/EditText;Ljava/lang/String;)V

    invoke-virtual {v5, v6, v7}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v5

    const v6, 0x1040009

    sget-object v7, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v5, v6, v7}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v5

    invoke-virtual {v5}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 1377
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getToggleSoftInputDelay()I

    move-result v5

    if-eqz v5, :cond_0

    .line 1380
    new-instance v3, Ljava/util/Timer;

    invoke-direct {v3}, Ljava/util/Timer;-><init>()V

    .line 1381
    .local v3, "timer":Ljava/util/Timer;
    new-instance v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$2;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;)V

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getToggleSoftInputDelay()I

    move-result v6

    int-to-long v6, v6

    invoke-virtual {v3, v5, v6, v7}, Ljava/util/Timer;->schedule(Ljava/util/TimerTask;J)V

    .line 1391
    .end local v3    # "timer":Ljava/util/Timer;
    :cond_0
    return-void
.end method
