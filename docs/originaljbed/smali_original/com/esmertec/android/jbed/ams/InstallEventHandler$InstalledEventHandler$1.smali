.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;)V
    .locals 0

    .prologue
    .line 264
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    const/4 v2, 0x1

    .line 266
    invoke-static {}, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasEnoughFreeMemory()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 267
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v0

    if-ne v0, v2, :cond_0

    .line 268
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestRunEvent(Ljava/lang/String;I)V

    .line 279
    :goto_0
    return-void

    .line 270
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2721

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v0, v1, v2}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 273
    :cond_1
    new-instance v0, Landroid/app/AlertDialog$Builder;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05006d

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x1040111

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0
.end method
