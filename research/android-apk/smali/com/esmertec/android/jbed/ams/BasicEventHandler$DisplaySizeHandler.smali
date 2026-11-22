.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DisplaySizeHandler"
.end annotation


# instance fields
.field private displaySolutions:[Ljava/lang/String;

.field private displayString:[Ljava/lang/String;

.field private mSelected:I

.field private midletNo:I

.field private midletRoot:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 1688
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 1691
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mSelected:I

    return-void
.end method

.method static synthetic access$1900(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)Ljava/lang/String;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    .prologue
    .line 1688
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->midletRoot:Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$2000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    .prologue
    .line 1688
    iget v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->midletNo:I

    return v0
.end method

.method static synthetic access$2100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)[Ljava/lang/String;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    .prologue
    .line 1688
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displaySolutions:[Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$2200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    .prologue
    .line 1688
    iget v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mSelected:I

    return v0
.end method

.method static synthetic access$2202(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;
    .param p1, "x1"    # I

    .prologue
    .line 1688
    iput p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mSelected:I

    return p1
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    const/4 v4, 0x2

    const/4 v6, 0x1

    const/4 v5, 0x0

    .line 1697
    const-string v2, "AmsEventHandler"

    const-string v3, "DisplaySizeHandler"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1698
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iput v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->midletNo:I

    .line 1699
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v1

    .line 1700
    .local v1, "displayInfo":Ljava/lang/String;
    if-nez v1, :cond_0

    .line 1747
    :goto_0
    return-void

    .line 1717
    :cond_0
    const-string v2, ";"

    invoke-virtual {v1, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 1718
    .local v0, "di":[Ljava/lang/String;
    aget-object v2, v0, v5

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->midletRoot:Ljava/lang/String;

    .line 1719
    aget-object v2, v0, v6

    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v2

    iput v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mSelected:I

    .line 1720
    new-array v2, v4, [Ljava/lang/String;

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displaySolutions:[Ljava/lang/String;

    .line 1721
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displaySolutions:[Ljava/lang/String;

    const-string v3, ""

    aput-object v3, v2, v5

    .line 1722
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displaySolutions:[Ljava/lang/String;

    aget-object v3, v0, v4

    aput-object v3, v2, v6

    .line 1725
    new-array v2, v4, [Ljava/lang/String;

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displayString:[Ljava/lang/String;

    .line 1726
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displayString:[Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f0503a4

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    aput-object v3, v2, v5

    .line 1727
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displayString:[Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f0503a5

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    aput-object v3, v2, v6

    .line 1729
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f0503a6

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->displayString:[Ljava/lang/String;

    iget v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mSelected:I

    new-instance v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$3;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)V

    invoke-virtual {v2, v3, v4, v5}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040013

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040009

    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$1;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0
.end method
