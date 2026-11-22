.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;
.super Landroid/widget/ArrayAdapter;
.source "RunningMidletManagerActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "ListAdapter"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroid/widget/ArrayAdapter",
        "<",
        "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Ljava/util/List;)V
    .locals 1
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
    .line 459
    .local p2, "list":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    .line 460
    const/4 v0, -0x1

    invoke-direct {p0, p1, v0, p2}, Landroid/widget/ArrayAdapter;-><init>(Landroid/content/Context;ILjava/util/List;)V

    .line 461
    return-void
.end method

.method private showDrmNormalIcon(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Z
    .locals 8
    .param p1, "data"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    const/4 v7, 0x0

    const/4 v6, 0x1

    .line 566
    iget v5, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    if-ne v5, v6, :cond_1

    move v2, v6

    .line 567
    .local v2, "isFLDrm":Z
    :goto_0
    const/4 v4, 0x1

    .line 570
    .local v4, "result":Z
    if-eqz v2, :cond_2

    .line 577
    const-string v3, "ORG"

    .line 580
    .local v3, "operatorCode":Ljava/lang/String;
    const/4 v5, 0x7

    new-array v0, v5, [Ljava/lang/String;

    const-string v5, "VDF"

    aput-object v5, v0, v7

    const-string v5, "H3G"

    aput-object v5, v0, v6

    const/4 v5, 0x2

    const-string v6, "ORG"

    aput-object v6, v0, v5

    const/4 v5, 0x3

    const-string v6, "TME"

    aput-object v6, v0, v5

    const/4 v5, 0x4

    const-string v6, "TNR"

    aput-object v6, v0, v5

    const/4 v5, 0x5

    const-string v6, "TIM"

    aput-object v6, v0, v5

    const/4 v5, 0x6

    const-string v6, "TMO"

    aput-object v6, v0, v5

    .line 581
    .local v0, "excludedOpCodeforFLIcon":[Ljava/lang/String;
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    array-length v5, v0

    if-ge v1, v5, :cond_2

    .line 582
    aget-object v5, v0, v1

    invoke-virtual {v3, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_0

    .line 583
    const/4 v4, 0x0

    .line 581
    :cond_0
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .end local v0    # "excludedOpCodeforFLIcon":[Ljava/lang/String;
    .end local v1    # "i":I
    .end local v2    # "isFLDrm":Z
    .end local v3    # "operatorCode":Ljava/lang/String;
    .end local v4    # "result":Z
    :cond_1
    move v2, v7

    .line 566
    goto :goto_0

    .line 586
    .restart local v2    # "isFLDrm":Z
    .restart local v4    # "result":Z
    :cond_2
    return v4
.end method


# virtual methods
.method public getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
    .locals 11
    .param p1, "position"    # I
    .param p2, "convertView"    # Landroid/view/View;
    .param p3, "parent"    # Landroid/view/ViewGroup;

    .prologue
    const/4 v10, 0x0

    .line 465
    const/4 v2, 0x0

    .line 466
    .local v2, "layout":Landroid/widget/LinearLayout;
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->getItem(I)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 467
    .local v5, "midletProxy":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    .line 472
    .local v0, "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    if-nez v0, :cond_0

    .line 473
    new-instance v8, Landroid/widget/FrameLayout;

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {v8, v9}, Landroid/widget/FrameLayout;-><init>(Landroid/content/Context;)V

    .line 562
    :goto_0
    return-object v8

    .line 475
    :cond_0
    iget-object v8, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v9, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v0, v8, v9}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v3

    .line 476
    .local v3, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-boolean v8, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    iput-boolean v8, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 477
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v8

    if-eqz v8, :cond_1

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v8

    if-eqz v8, :cond_1

    .line 479
    iget-object v8, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->checkExpiredMidlet(Ljava/lang/String;)Z

    move-result v8

    iput-boolean v8, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    .line 480
    iget-object v8, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->getDrmMethodType(Ljava/lang/String;)I

    move-result v8

    iput v8, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    .line 526
    :cond_1
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$400(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Landroid/view/LayoutInflater;

    move-result-object v8

    const v9, 0x7f030006

    invoke-virtual {v8, v9, p3, v10}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;Z)Landroid/view/View;

    move-result-object v2

    .end local v2    # "layout":Landroid/widget/LinearLayout;
    check-cast v2, Landroid/widget/LinearLayout;

    .line 527
    .restart local v2    # "layout":Landroid/widget/LinearLayout;
    const v8, 0x7f080016

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v8

    invoke-virtual {v8, v10}, Landroid/view/View;->setVisibility(I)V

    .line 533
    const v8, 0x7f080012

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v7

    check-cast v7, Landroid/widget/TextView;

    .line 534
    .local v7, "text":Landroid/widget/TextView;
    const v8, 0x7f080011

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/ImageView;

    .line 536
    .local v1, "icon":Landroid/widget/ImageView;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v8

    if-eqz v8, :cond_2

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v8}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v8

    invoke-virtual {v8}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v8

    iget v8, v8, Landroid/content/res/Configuration;->orientation:I

    const/4 v9, 0x2

    if-ne v8, v9, :cond_2

    .line 537
    const/16 v8, 0x172

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setMaxWidth(I)V

    .line 539
    :cond_2
    iget-object v8, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 540
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v3, v8}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getIcon(Landroid/content/Context;)Landroid/graphics/drawable/Drawable;

    move-result-object v4

    .line 541
    .local v4, "midletIcon":Landroid/graphics/drawable/Drawable;
    if-eqz v4, :cond_4

    .line 542
    invoke-virtual {v1, v4}, Landroid/widget/ImageView;->setImageDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 548
    :goto_1
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v8

    if-eqz v8, :cond_3

    .line 549
    const v8, 0x7f080019

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v6

    check-cast v6, Landroid/widget/TextView;

    .line 550
    .local v6, "size":Landroid/widget/TextView;
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$ListAdapter;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v3, v8}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeText(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v6, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 552
    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmPending()Z

    move-result v8

    if-eqz v8, :cond_5

    .line 553
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v8

    if-nez v8, :cond_3

    .line 554
    const v8, 0x7f080018

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v8

    invoke-virtual {v8, v10}, Landroid/view/View;->setVisibility(I)V

    .end local v6    # "size":Landroid/widget/TextView;
    :cond_3
    :goto_2
    move-object v8, v2

    .line 562
    goto/16 :goto_0

    .line 544
    :cond_4
    const v8, 0x7f020001

    invoke-virtual {v1, v8}, Landroid/widget/ImageView;->setBackgroundResource(I)V

    goto :goto_1

    .line 556
    .restart local v6    # "size":Landroid/widget/TextView;
    :cond_5
    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v8

    if-eqz v8, :cond_3

    .line 557
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v8

    if-nez v8, :cond_3

    .line 558
    const v8, 0x7f080017

    invoke-virtual {v2, v8}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v8

    invoke-virtual {v8, v10}, Landroid/view/View;->setVisibility(I)V

    goto :goto_2
.end method
