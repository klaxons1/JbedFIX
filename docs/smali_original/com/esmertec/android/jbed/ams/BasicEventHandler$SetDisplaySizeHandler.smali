.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SetDisplaySizeHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1751
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 1754
    const-string v0, "AmsEventHandler"

    const-string v1, "SetDisplaySizeHandler"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1758
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0503a6

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x1

    if-ne v1, v2, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050237

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    :goto_0
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    new-instance v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 1767
    return-void

    .line 1758
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050238

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    goto :goto_0
.end method
