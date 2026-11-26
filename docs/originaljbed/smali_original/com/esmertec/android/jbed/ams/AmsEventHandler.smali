.class public abstract Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.super Ljava/lang/Object;
.source "AmsEventHandler.java"

# interfaces
.implements Ljava/lang/Runnable;
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;
    }
.end annotation


# static fields
.field private static ERROR_ID:I = 0x0

.field private static INFO_ID:I = 0x0

.field protected static final TAG:Ljava/lang/String; = "AmsEventHandler"

.field private static WARNING_ID:I

.field static defaultCancelListener:Landroid/content/DialogInterface$OnCancelListener;

.field static defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;


# instance fields
.field protected mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

.field protected mContext:Landroid/content/Context;

.field protected mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

.field protected mHandler:Landroid/os/Handler;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .prologue
    const/4 v1, -0x1

    .line 32
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsEventHandler$1;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler$1;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    .line 38
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsEventHandler$2;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler$2;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->defaultCancelListener:Landroid/content/DialogInterface$OnCancelListener;

    .line 83
    sput v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->INFO_ID:I

    .line 84
    sput v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->WARNING_ID:I

    .line 85
    sput v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->ERROR_ID:I

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 20
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 150
    return-void
.end method

.method static readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;
    .locals 2
    .param p0, "in"    # Ljava/io/DataInputStream;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 139
    invoke-virtual {p0}, Ljava/io/DataInputStream;->readBoolean()Z

    move-result v0

    .line 140
    .local v0, "hasContent":Z
    if-eqz v0, :cond_0

    .line 141
    invoke-virtual {p0}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v1

    .line 143
    :goto_0
    return-object v1

    :cond_0
    const/4 v1, 0x0

    goto :goto_0
.end method


# virtual methods
.method protected bringMidletToForeground(Z)V
    .locals 1
    .param p1, "isFullScreen"    # Z

    .prologue
    .line 135
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->bringMidletToForeground(Z)V

    .line 136
    return-void
.end method

.method public getContext()Landroid/content/Context;
    .locals 1

    .prologue
    .line 45
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method protected parseData([B)V
    .locals 0
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 52
    return-void
.end method

.method protected processMessageImmediately(Landroid/os/Message;)V
    .locals 1
    .param p1, "message"    # Landroid/os/Message;

    .prologue
    .line 147
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, p1}, Landroid/os/Handler;->sendMessageAtFrontOfQueue(Landroid/os/Message;)Z

    .line 148
    return-void
.end method

.method public run()V
    .locals 0

    .prologue
    .line 49
    return-void
.end method

.method protected showDialg(II)V
    .locals 1
    .param p1, "titleId"    # I
    .param p2, "msgId"    # I

    .prologue
    .line 71
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v0, p2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, p1, v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showDialg(ILjava/lang/String;)V

    .line 72
    return-void
.end method

.method protected showDialg(ILjava/lang/String;)V
    .locals 1
    .param p1, "titleId"    # I
    .param p2, "msg"    # Ljava/lang/String;

    .prologue
    .line 55
    const/4 v0, 0x0

    invoke-virtual {p0, p1, p2, v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showDialg(ILjava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V

    .line 56
    return-void
.end method

.method protected showDialg(ILjava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V
    .locals 4
    .param p1, "titleId"    # I
    .param p2, "msg"    # Ljava/lang/String;
    .param p3, "listener"    # Landroid/content/DialogInterface$OnClickListener;

    .prologue
    .line 60
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v1, p2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x104000a

    if-nez p3, :cond_1

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    :goto_0
    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 63
    .local v0, "builder":Landroid/app/AlertDialog$Builder;
    const/4 v1, -0x1

    if-eq p1, v1, :cond_0

    .line 64
    invoke-virtual {v0, p1}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    .line 66
    :cond_0
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 68
    return-void

    .end local v0    # "builder":Landroid/app/AlertDialog$Builder;
    :cond_1
    move-object v3, p3

    .line 60
    goto :goto_0
.end method

.method protected showError(Ljava/lang/String;)V
    .locals 1
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 119
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showError(Ljava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V

    .line 120
    return-void
.end method

.method protected showError(Ljava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V
    .locals 4
    .param p1, "msg"    # Ljava/lang/String;
    .param p2, "listener"    # Landroid/content/DialogInterface$OnClickListener;

    .prologue
    .line 124
    :try_start_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->ERROR_ID:I

    const/4 v3, -0x1

    if-ne v2, v3, :cond_0

    .line 125
    const-string v2, "com.esmertec.android.jbed.R$string"

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 126
    .local v0, "cls":Ljava/lang/Class;
    const-string v2, "AMS_ERROR"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result v2

    sput v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->ERROR_ID:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 131
    .end local v0    # "cls":Ljava/lang/Class;
    :cond_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->ERROR_ID:I

    invoke-virtual {p0, v2, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showDialg(ILjava/lang/String;Landroid/content/DialogInterface$OnClickListener;)V

    .line 132
    return-void

    .line 128
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 129
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/IllegalStateException;

    const-string v3, "Class cannot be found"

    invoke-direct {v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method protected showInfo(I)V
    .locals 2
    .param p1, "msgId"    # I

    .prologue
    .line 75
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v1, p1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 76
    .local v0, "msg":Ljava/lang/String;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showInfo(Ljava/lang/String;)V

    .line 77
    return-void
.end method

.method protected showInfo(Ljava/lang/String;)V
    .locals 4
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 95
    :try_start_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->INFO_ID:I

    const/4 v3, -0x1

    if-ne v2, v3, :cond_0

    .line 96
    const-string v2, "com.esmertec.android.jbed.R$string"

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 97
    .local v0, "cls":Ljava/lang/Class;
    const-string v2, "AMS_INFO"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result v2

    sput v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->INFO_ID:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 103
    .end local v0    # "cls":Ljava/lang/Class;
    :cond_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->INFO_ID:I

    invoke-virtual {p0, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showDialg(ILjava/lang/String;)V

    .line 104
    return-void

    .line 99
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 100
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/IllegalStateException;

    const-string v3, "Class cannot be found"

    invoke-direct {v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method protected showToast(Ljava/lang/String;)V
    .locals 2
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 80
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mContext:Landroid/content/Context;

    const/4 v1, 0x0

    invoke-static {v0, p1, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 81
    return-void
.end method

.method protected showWarning(Ljava/lang/String;)V
    .locals 4
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 108
    :try_start_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->WARNING_ID:I

    const/4 v3, -0x1

    if-ne v2, v3, :cond_0

    .line 109
    const-string v2, "com.esmertec.android.jbed.R$string"

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 110
    .local v0, "cls":Ljava/lang/Class;
    const-string v2, "AMS_WARNING"

    invoke-virtual {v0, v2}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result v2

    sput v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->WARNING_ID:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 115
    .end local v0    # "cls":Ljava/lang/Class;
    :cond_0
    sget v2, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->WARNING_ID:I

    invoke-virtual {p0, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->showDialg(ILjava/lang/String;)V

    .line 116
    return-void

    .line 112
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 113
    .local v1, "e":Ljava/lang/Exception;
    new-instance v2, Ljava/lang/IllegalStateException;

    const-string v3, "Class cannot be found"

    invoke-direct {v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v2
.end method
