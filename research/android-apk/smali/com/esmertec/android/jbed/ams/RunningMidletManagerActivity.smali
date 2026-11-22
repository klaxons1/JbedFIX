.class public Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
.super Landroid/app/ListActivity;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;
    }
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "RunningActivity"


# instance fields
.field private isContextItemSelected:Z

.field private mFocusPosition:I

.field private mHandler:Landroid/os/Handler;

.field private mInflater:Landroid/view/LayoutInflater;

.field selectedResumeItem:I

.field selectedStopItem:I


# direct methods
.method public constructor <init>()V
    .locals 2

    .prologue
    const/4 v1, -0x1

    .line 70
    invoke-direct {p0}, Landroid/app/ListActivity;-><init>()V

    .line 76
    iput v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    .line 78
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    .line 80
    iput v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedStopItem:I

    .line 81
    iput v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedResumeItem:I

    .line 88
    new-instance v0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mHandler:Landroid/os/Handler;

    .line 458
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    .prologue
    .line 70
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Ljava/util/List;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
    .param p1, "x1"    # Ljava/util/List;

    .prologue
    .line 70
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->refreshList(Ljava/util/List;)V

    return-void
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
    .param p1, "x1"    # I

    .prologue
    .line 70
    iput p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    return p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 70
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->showStopConfirmDialog(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    return-void
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Landroid/view/LayoutInflater;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    .prologue
    .line 70
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mInflater:Landroid/view/LayoutInflater;

    return-object v0
.end method

.method private getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;
    .locals 2

    .prologue
    .line 169
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->getAmsClient(Landroid/os/Handler;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    return-object v0
.end method

.method private getApp()Lcom/esmertec/android/jbed/JbedApp;
    .locals 0

    .prologue
    .line 165
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getApplication()Landroid/app/Application;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
    check-cast p0, Lcom/esmertec/android/jbed/JbedApp;

    return-object p0
.end method

.method private refreshList(Ljava/util/List;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 422
    .local p1, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    new-instance v0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;

    invoke-direct {v0, p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Ljava/util/List;)V

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->setListAdapter(Landroid/widget/ListAdapter;)V

    .line 425
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/ListView;->getCount()I

    move-result v0

    if-lez v0, :cond_0

    .line 426
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    .line 430
    :goto_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/ListView;->requestFocusFromTouch()Z

    .line 431
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    invoke-virtual {v0, v1}, Landroid/widget/ListView;->setSelection(I)V

    .line 432
    return-void

    .line 428
    :cond_0
    const/4 v0, -0x1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    goto :goto_0
.end method

.method private showStopConfirmDialog(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 5
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    const-string v4, "\n"

    .line 435
    const v2, 0x7f050386

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getString(I)Ljava/lang/String;

    move-result-object v1

    .line 436
    .local v1, "msg":Ljava/lang/String;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v3, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "\n"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "\n"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 437
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-direct {v2, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v3, 0x7f050385

    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getString(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040013

    new-instance v4, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;

    invoke-direct {v4, p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040009

    new-instance v4, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$11;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$11;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v0

    .line 455
    .local v0, "confirmDialog":Landroid/app/AlertDialog;
    invoke-virtual {v0}, Landroid/app/AlertDialog;->show()V

    .line 456
    return-void
.end method


# virtual methods
.method public onContextItemSelected(Landroid/view/MenuItem;)Z
    .locals 1
    .param p1, "item"    # Landroid/view/MenuItem;

    .prologue
    .line 272
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    .line 273
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->onOptionsItemSelected(Landroid/view/MenuItem;)Z

    .line 274
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onContextItemSelected(Landroid/view/MenuItem;)Z

    move-result v0

    return v0
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 6
    .param p1, "icicle"    # Landroid/os/Bundle;

    .prologue
    const/4 v5, -0x1

    .line 174
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onCreate(Landroid/os/Bundle;)V

    .line 175
    const v2, 0x7f030010

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->setContentView(I)V

    .line 177
    const-string v2, "layout_inflater"

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/view/LayoutInflater;

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mInflater:Landroid/view/LayoutInflater;

    .line 183
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mInflater:Landroid/view/LayoutInflater;

    const v3, 0x109000b

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/TextView;

    .line 184
    .local v1, "v":Landroid/view/View;
    new-instance v2, Landroid/view/ViewGroup$LayoutParams;

    invoke-direct {v2, v5, v5}, Landroid/view/ViewGroup$LayoutParams;-><init>(II)V

    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->addContentView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    .line 185
    const v2, 0x1020014

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    .line 186
    .local v0, "emptyText":Landroid/widget/TextView;
    const v2, 0x7f050363

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setText(I)V

    .line 187
    const/16 v2, 0x31

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setGravity(I)V

    .line 188
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    invoke-virtual {v2, v0}, Landroid/widget/ListView;->setEmptyView(Landroid/view/View;)V

    .line 190
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    new-instance v3, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$2;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$2;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v2, v3}, Landroid/widget/ListView;->setOnItemClickListener(Landroid/widget/AdapterView$OnItemClickListener;)V

    .line 206
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    new-instance v3, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v2, v3}, Landroid/widget/ListView;->setOnItemSelectedListener(Landroid/widget/AdapterView$OnItemSelectedListener;)V

    .line 219
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 220
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    new-instance v3, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v2, v3}, Landroid/widget/ListView;->setOnCreateContextMenuListener(Landroid/view/View$OnCreateContextMenuListener;)V

    .line 239
    :cond_0
    return-void
.end method

.method public onCreateOptionsMenu(Landroid/view/Menu;)Z
    .locals 3
    .param p1, "menu"    # Landroid/view/Menu;

    .prologue
    const/4 v2, 0x0

    .line 279
    const-string v0, "RunningActivity"

    const-string v1, "Ams onCreateOptionsMenu"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 281
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getMenuInflater()Landroid/view/MenuInflater;

    move-result-object v0

    const v1, 0x7f070001

    invoke-virtual {v0, v1, p1}, Landroid/view/MenuInflater;->inflate(ILandroid/view/Menu;)V

    .line 285
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 290
    const v0, 0x7f080051

    invoke-interface {p1, v0}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v0

    invoke-interface {v0, v2}, Landroid/view/MenuItem;->setIcon(Landroid/graphics/drawable/Drawable;)Landroid/view/MenuItem;

    .line 291
    const v0, 0x7f080052

    invoke-interface {p1, v0}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v0

    invoke-interface {v0, v2}, Landroid/view/MenuItem;->setIcon(Landroid/graphics/drawable/Drawable;)Landroid/view/MenuItem;

    .line 292
    const v0, 0x7f080053

    invoke-interface {p1, v0}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v0

    invoke-interface {v0, v2}, Landroid/view/MenuItem;->setIcon(Landroid/graphics/drawable/Drawable;)Landroid/view/MenuItem;

    .line 297
    :cond_0
    const/4 v0, 0x1

    return v0
.end method

.method protected onDestroy()V
    .locals 2

    .prologue
    .line 243
    invoke-super {p0}, Landroid/app/ListActivity;->onDestroy()V

    .line 244
    const-string v0, "RunningActivity"

    const-string v1, "LIFECYCLE Task Manager onDestroy"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 248
    return-void
.end method

.method public onOptionsItemSelected(Landroid/view/MenuItem;)Z
    .locals 15
    .param p1, "item"    # Landroid/view/MenuItem;

    .prologue
    .line 312
    const/4 v1, 0x1

    .line 313
    .local v1, "isHandled":Z
    const/4 v4, 0x0

    .line 314
    .local v4, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v10, -0x1

    iget v11, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    if-eq v10, v11, :cond_0

    .line 315
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v10

    invoke-virtual {v10}, Landroid/widget/ListView;->getAdapter()Landroid/widget/ListAdapter;

    move-result-object v10

    iget v11, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    invoke-interface {v10, v11}, Landroid/widget/ListAdapter;->getItem(I)Ljava/lang/Object;

    move-result-object v4

    .end local v4    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    check-cast v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 318
    .restart local v4    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_0
    invoke-interface/range {p1 .. p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v10

    packed-switch v10, :pswitch_data_0

    .line 403
    const/4 v1, 0x0

    .line 406
    :goto_0
    const/4 v10, -0x1

    iput v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    move v2, v1

    .line 407
    .end local v1    # "isHandled":Z
    .local v2, "isHandled":I
    :goto_1
    return v2

    .line 321
    .end local v2    # "isHandled":I
    .restart local v1    # "isHandled":Z
    :pswitch_0
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v10

    if-eqz v10, :cond_3

    .line 322
    iget-boolean v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    if-eqz v10, :cond_1

    .line 323
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v10

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v11

    iget v12, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    const-wide/16 v13, 0x0

    invoke-virtual {v10, v11, v12, v13, v14}, Landroid/widget/ListView;->performItemClick(Landroid/view/View;IJ)Z

    .line 355
    const/4 v10, 0x0

    iput-boolean v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    goto :goto_0

    .line 325
    :cond_1
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v8

    .line 326
    .local v8, "runningMidletNameList":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    invoke-virtual {v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v7

    .line 328
    .local v7, "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v7}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_2
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v10

    if-eqz v10, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 329
    .local v6, "runningMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    iget-object v11, v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v12, v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v5

    .line 330
    .local v5, "resumeMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v10, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-interface {v8, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_2

    .line 332
    .end local v5    # "resumeMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v6    # "runningMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    invoke-virtual {v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v10

    invoke-virtual {v10, v7}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toMidletCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v9

    .line 333
    .local v9, "suites":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v10, -0x1

    iput v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedResumeItem:I

    .line 335
    new-instance v10, Landroid/app/AlertDialog$Builder;

    invoke-direct {v10, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v11, 0x7f050380

    invoke-virtual {v10, v11}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const/4 v11, -0x1

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$7;

    invoke-direct {v12, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$7;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v10, v9, v11, v12}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const v11, 0x1040013

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$6;

    invoke-direct {v12, p0, v9}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$6;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;)V

    invoke-virtual {v10, v11, v12}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const v11, 0x1040009

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$5;

    invoke-direct {v12, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$5;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v10, v11, v12}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    invoke-virtual {v10}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    move v2, v1

    .line 353
    .restart local v2    # "isHandled":I
    goto/16 :goto_1

    .line 357
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v2    # "isHandled":I
    .end local v7    # "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .end local v8    # "runningMidletNameList":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    .end local v9    # "suites":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    :cond_3
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v10

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v11

    iget v12, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    const-wide/16 v13, 0x0

    invoke-virtual {v10, v11, v12, v13, v14}, Landroid/widget/ListView;->performItemClick(Landroid/view/View;IJ)Z

    goto/16 :goto_0

    .line 362
    :pswitch_1
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v10

    if-eqz v10, :cond_5

    .line 363
    iget-boolean v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    if-eqz v10, :cond_4

    .line 364
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    iget-object v11, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v12, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v10

    invoke-direct {p0, v10}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->showStopConfirmDialog(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 390
    const/4 v10, 0x0

    iput-boolean v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->isContextItemSelected:Z

    goto/16 :goto_0

    .line 367
    :cond_4
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    invoke-virtual {v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v7

    .line 368
    .restart local v7    # "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    invoke-virtual {v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v10

    invoke-virtual {v10, v7}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toMidletCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v9

    .line 369
    .restart local v9    # "suites":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v10, -0x1

    iput v10, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedStopItem:I

    .line 370
    new-instance v10, Landroid/app/AlertDialog$Builder;

    invoke-direct {v10, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v11, 0x7f050043

    invoke-virtual {v10, v11}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const/4 v11, -0x1

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$10;

    invoke-direct {v12, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$10;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v10, v9, v11, v12}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const v11, 0x1040013

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;

    invoke-direct {v12, p0, v9}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;)V

    invoke-virtual {v10, v11, v12}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    const v11, 0x1040009

    new-instance v12, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$8;

    invoke-direct {v12, p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$8;-><init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V

    invoke-virtual {v10, v11, v12}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v10

    invoke-virtual {v10}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    move v2, v1

    .line 388
    .restart local v2    # "isHandled":I
    goto/16 :goto_1

    .line 392
    .end local v2    # "isHandled":I
    .end local v7    # "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .end local v9    # "suites":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    :cond_5
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v10

    iget-object v11, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v12, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDestroyEvent(Ljava/lang/String;I)V

    goto/16 :goto_0

    .line 396
    :pswitch_2
    new-instance v3, Landroid/content/Intent;

    const-class v10, Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {v3, p0, v10}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 397
    .local v3, "jbedIntent":Landroid/content/Intent;
    const/high16 v10, 0x4000000

    invoke-virtual {v3, v10}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 398
    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->startActivity(Landroid/content/Intent;)V

    .line 399
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->finish()V

    goto/16 :goto_0

    .line 318
    nop

    :pswitch_data_0
    .packed-switch 0x7f080051
        :pswitch_0
        :pswitch_1
        :pswitch_2
    .end packed-switch
.end method

.method protected onPause()V
    .locals 2

    .prologue
    .line 265
    const-string v0, "RunningActivity"

    const-string v1, "LIFECYCLE Task Manager onPause"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 266
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->stopService(Landroid/os/Handler;)V

    .line 267
    invoke-super {p0}, Landroid/app/ListActivity;->onPause()V

    .line 268
    return-void
.end method

.method public onPrepareOptionsMenu(Landroid/view/Menu;)Z
    .locals 4
    .param p1, "menu"    # Landroid/view/Menu;

    .prologue
    const/4 v3, 0x1

    .line 302
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onPrepareOptionsMenu(Landroid/view/Menu;)Z

    .line 303
    const v1, 0x7f080034

    invoke-interface {p1, v1, v3}, Landroid/view/Menu;->setGroupEnabled(IZ)V

    .line 305
    iget v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    const/4 v2, -0x1

    if-eq v1, v2, :cond_0

    move v0, v3

    .line 306
    .local v0, "isItemAvailable":Z
    :goto_0
    const v1, 0x7f080048

    invoke-interface {p1, v1, v0}, Landroid/view/Menu;->setGroupEnabled(IZ)V

    .line 307
    return v3

    .line 305
    .end local v0    # "isItemAvailable":Z
    :cond_0
    const/4 v1, 0x0

    move v0, v1

    goto :goto_0
.end method

.method protected onResume()V
    .locals 4

    .prologue
    .line 258
    const-string v0, "RunningActivity"

    const-string v1, "LIFECYCLE Task Manager onResume"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 259
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mHandler:Landroid/os/Handler;

    const-wide/16 v2, 0x2

    invoke-virtual {v0, p0, v1, v2, v3}, Lcom/esmertec/android/jbed/JbedApp;->startService(Landroid/app/Activity;Landroid/os/Handler;J)V

    .line 260
    invoke-super {p0}, Landroid/app/ListActivity;->onResume()V

    .line 261
    return-void
.end method

.method protected onStop()V
    .locals 2

    .prologue
    .line 252
    const-string v0, "RunningActivity"

    const-string v1, "LIFECYCLE Task Manager onStop"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 253
    invoke-super {p0}, Landroid/app/ListActivity;->onStop()V

    .line 254
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .locals 2
    .param p1, "hasFocus"    # Z

    .prologue
    .line 412
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onWindowFocusChanged(Z)V

    .line 413
    if-eqz p1, :cond_0

    .line 414
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->mFocusPosition:I

    invoke-virtual {v0, v1}, Landroid/widget/ListView;->setSelection(I)V

    .line 418
    :cond_0
    return-void
.end method
