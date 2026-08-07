.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "StorageSettingEventHandler"
.end annotation


# instance fields
.field selected:I


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1268
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    .prologue
    .line 1272
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 1273
    .local v0, "storages":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05029f

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1274
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1275
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05037c

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1278
    :cond_0
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f05037b

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v1

    new-array v1, v1, [Ljava/lang/String;

    invoke-interface {v0, v1}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/CharSequence;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v4

    const/4 v5, 0x1

    sub-int/2addr v4, v5

    invoke-static {v3, v4}, Ljava/lang/Math;->min(II)I

    move-result v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;)V

    invoke-virtual {v2, v1, v3, v4}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040013

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040009

    sget-object v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 1291
    return-void
.end method
