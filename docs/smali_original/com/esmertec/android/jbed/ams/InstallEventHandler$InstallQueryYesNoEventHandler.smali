.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallQueryYesNoEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 501
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 504
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05006d

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    new-instance v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040009

    new-instance v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 519
    return-void
.end method
