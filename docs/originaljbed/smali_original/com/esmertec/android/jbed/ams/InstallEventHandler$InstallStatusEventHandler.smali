.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStatusEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallStatusEventHandler"
.end annotation


# static fields
.field private static final AMS_MODULE_ID:I = 0x4


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 141
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 146
    const/4 v2, 0x4

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStatusEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/util/I18N;->getStringID(II)I

    move-result v1

    .line 147
    .local v1, "retId":I
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStatusEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 148
    .local v0, "msg":Ljava/lang/String;
    if-eqz v0, :cond_0

    .line 149
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStatusEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v3, 0x2719

    invoke-virtual {v2, v3, v0}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v2

    invoke-virtual {v2}, Landroid/os/Message;->sendToTarget()V

    .line 150
    :cond_0
    return-void
.end method
