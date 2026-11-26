.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RequestInstallEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 104
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 108
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 109
    .local v0, "url":Ljava/lang/String;
    if-nez v0, :cond_0

    .line 110
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05036b

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;->showError(Ljava/lang/String;)V

    .line 114
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;
    :goto_0
    return-void

    .line 112
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;
    :cond_0
    iget-object p0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallEvent(Ljava/lang/String;)V

    goto :goto_0
.end method
