.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$PreinstallFolderStartEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "PreinstallFolderStartEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 57
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 61
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$PreinstallFolderStartEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallLock()Z

    .line 65
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$PreinstallFolderStartEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2713

    const/4 v2, 0x1

    invoke-static {v2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 67
    return-void
.end method
