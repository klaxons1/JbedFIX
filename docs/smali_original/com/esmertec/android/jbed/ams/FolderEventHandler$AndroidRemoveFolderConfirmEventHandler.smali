.class public Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidRemoveFolderConfirmEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    .line 37
    const v3, 0x7f0500a0

    .line 38
    .local v3, "stringId":I
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v4

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v1, v0

    .line 39
    .local v1, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mContext:Landroid/content/Context;

    const/4 v5, 0x1

    new-array v5, v5, [Ljava/lang/Object;

    const/4 v6, 0x0

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v7

    aput-object v7, v5, v6

    invoke-virtual {v4, v3, v5}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    .line 41
    .local v2, "msg":Ljava/lang/String;
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f05006d

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040013

    new-instance v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;

    invoke-direct {v6, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040009

    sget-object v6, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 48
    return-void
.end method
