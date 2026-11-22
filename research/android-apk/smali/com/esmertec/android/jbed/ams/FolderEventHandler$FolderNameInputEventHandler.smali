.class public Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FolderNameInputEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 56
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    .line 59
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mContext:Landroid/content/Context;

    const-string v5, "layout_inflater"

    invoke-virtual {v4, v5}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/view/LayoutInflater;

    .line 61
    .local v1, "mInflater":Landroid/view/LayoutInflater;
    const v4, 0x7f030007

    const/4 v5, 0x0

    invoke-virtual {v1, v4, v5}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v3

    .line 62
    .local v3, "v":Landroid/view/View;
    const v4, 0x7f080002

    invoke-virtual {v3, v4}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/EditText;

    .line 63
    .local v0, "edtText":Landroid/widget/EditText;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v4, v4, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v5, 0x3e

    if-ne v4, v5, :cond_0

    .line 64
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v0, v4}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 66
    :cond_0
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v5, 0x7f050066

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040013

    new-instance v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;

    invoke-direct {v6, p0, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;Landroid/widget/EditText;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040009

    sget-object v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 81
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getToggleSoftInputDelay()I

    move-result v4

    if-eqz v4, :cond_1

    .line 84
    new-instance v2, Ljava/util/Timer;

    invoke-direct {v2}, Ljava/util/Timer;-><init>()V

    .line 85
    .local v2, "timer":Ljava/util/Timer;
    new-instance v4, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;)V

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getToggleSoftInputDelay()I

    move-result v5

    int-to-long v5, v5

    invoke-virtual {v2, v4, v5, v6}, Ljava/util/Timer;->schedule(Ljava/util/TimerTask;J)V

    .line 95
    .end local v2    # "timer":Ljava/util/Timer;
    :cond_1
    return-void
.end method
