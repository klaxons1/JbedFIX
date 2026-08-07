.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SortSettingEventHandler"
.end annotation


# instance fields
.field private menuIdlist:[I

.field orderId:I

.field selected:I


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 1294
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 1297
    const/4 v0, 0x3

    new-array v0, v0, [I

    fill-array-data v0, :array_0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    return-void

    :array_0
    .array-data 4
        0x7f080044
        0x7f080046
        0x7f080047
    .end array-data
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;I)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;
    .param p1, "x1"    # I

    .prologue
    .line 1294
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->getMenuId(I)I

    move-result v0

    return v0
.end method

.method private getMenuId(I)I
    .locals 2
    .param p1, "idx"    # I

    .prologue
    .line 1311
    if-ltz p1, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    array-length v0, v0

    if-lt p1, v0, :cond_1

    .line 1312
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    const/4 v1, 0x0

    aget v0, v0, v1

    .line 1314
    :goto_0
    return v0

    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    aget v0, v0, p1

    goto :goto_0
.end method

.method private getMenuIndex(I)I
    .locals 2
    .param p1, "menuId"    # I

    .prologue
    .line 1303
    const/4 v0, 0x0

    .line 1304
    .local v0, "i":I
    const/4 v0, 0x0

    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    array-length v1, v1

    if-ge v0, v1, :cond_0

    .line 1305
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->menuIdlist:[I

    aget v1, v1, v0

    if-ne p1, v1, :cond_1

    .line 1308
    :cond_0
    return v0

    .line 1304
    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0
.end method


# virtual methods
.method public run()V
    .locals 6

    .prologue
    .line 1319
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 1320
    .local v0, "sortList":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050365

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1321
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050366

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1322
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f050367

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1323
    const-string v1, "AmsEventHandler"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "SortSettingEventHandler mEvent.mResult:"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1325
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f050364

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

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-direct {p0, v3}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->getMenuIndex(I)I

    move-result v3

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v4

    const/4 v5, 0x1

    sub-int/2addr v4, v5

    invoke-static {v3, v4}, Ljava/lang/Math;->min(II)I

    move-result v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$3;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;)V

    invoke-virtual {v2, v1, v3, v4}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040013

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040009

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$1;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 1344
    return-void
.end method
