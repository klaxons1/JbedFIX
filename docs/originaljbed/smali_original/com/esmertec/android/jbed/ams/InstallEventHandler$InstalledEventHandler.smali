.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstalledEventHandler"
.end annotation


# static fields
.field static final DRM_INSTALL_PENDING:I = 0x5f

.field static final JAR_SERVER_NOT_FOUND:I = 0x13

.field static final USER_CANCELLED:I = 0x4a


# instance fields
.field suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 192
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 197
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    .prologue
    const v3, 0x7f05006d

    const v5, 0x1040013

    const/4 v4, 0x1

    .line 202
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->releaseInstallLock()V

    .line 203
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2715

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 205
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    if-eqz v1, :cond_4

    .line 206
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0x5f

    if-ne v1, v2, :cond_1

    .line 208
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 209
    .local v0, "errMsg":Ljava/lang/String;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->showWarning(Ljava/lang/String;)V

    .line 293
    .end local v0    # "errMsg":Ljava/lang/String;
    :cond_0
    :goto_0
    return-void

    .line 210
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0x13

    if-ne v1, v2, :cond_2

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isCustomiseNetworkErrorNotify()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 212
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050389

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 213
    .restart local v0    # "errMsg":Ljava/lang/String;
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f05038a

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x104000a

    sget-object v3, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0

    .line 218
    .end local v0    # "errMsg":Ljava/lang/String;
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v2, 0x4a

    if-eq v1, v2, :cond_3

    .line 220
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 221
    .restart local v0    # "errMsg":Ljava/lang/String;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->showError(Ljava/lang/String;)V

    goto :goto_0

    .line 224
    .end local v0    # "errMsg":Ljava/lang/String;
    :cond_3
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2712

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 227
    :cond_4
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->refreshSelector()V

    .line 228
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 245
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isAutoRun()Z

    move-result v1

    if-eqz v1, :cond_7

    .line 246
    invoke-static {}, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasEnoughFreeMemory()Z

    move-result v1

    if-eqz v1, :cond_6

    .line 247
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v1

    if-ne v1, v4, :cond_5

    .line 248
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2, v4}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestRunEvent(Ljava/lang/String;I)V

    .line 286
    :goto_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v1, :cond_0

    .line 287
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1, v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->calculateSize(Z)V

    goto/16 :goto_0

    .line 250
    :cond_5
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x2721

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1, v2, v3}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    goto :goto_1

    .line 253
    :cond_6
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    const v3, 0x1040111

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const/4 v2, 0x0

    invoke-virtual {v1, v5, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_1

    .line 260
    :cond_7
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x7f0500a6

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setMessage(I)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;)V

    invoke-virtual {v1, v5, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040009

    sget-object v3, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->defaultCancelListener:Landroid/content/DialogInterface$OnCancelListener;

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_1
.end method
