.class public Lcom/esmertec/android/jbed/ams/JbedSelector;
.super Ljava/lang/Object;
.source "JbedSelector.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;
    }
.end annotation


# static fields
.field public static final FOLDER_TYPE_NAME:Ljava/lang/String; = "FOLDER"

.field private static final HAS_SHORT_CUT:Ljava/lang/String; = "hasShortCut"

.field private static final KET_MODIFIABLE_CONTENT:Ljava/lang/String; = "modifiableContent"

.field private static final KEY_DISPLAY_INFO:Ljava/lang/String; = "displaySizeInfo"

.field private static final KEY_DOMAIN:Ljava/lang/String; = "domain"

.field private static final KEY_ENTRY_CLASS:Ljava/lang/String; = "class"

.field private static final KEY_FILEROOT:Ljava/lang/String; = "fileRoot"

.field private static final KEY_FOLDER_BEGIN:Ljava/lang/String; = "folder"

.field private static final KEY_FOLDER_END:Ljava/lang/String; = "endfolder"

.field private static final KEY_INSTALL_TIME:Ljava/lang/String; = "install_time"

.field private static final KEY_IS_DRMPENDING:Ljava/lang/String; = "drmPending"

.field private static final KEY_IS_DRMPROTECTED:Ljava/lang/String; = "drmProtected"

.field private static final KEY_IS_DRM_INTERVAL_EVER_LAUNCHED:Ljava/lang/String; = "drmIntervalEverLaunched"

.field private static final KEY_LAUNCHPOWERON:Ljava/lang/String; = "launchPowerOn"

.field private static final KEY_MIDLET:Ljava/lang/String; = "midlet"

.field private static final KEY_PREINSTALLED:Ljava/lang/String; = "preinstalled"

.field private static final KEY_REMOVABLE:Ljava/lang/String; = "removable"

.field private static final KEY_ROOT:Ljava/lang/String; = "root"

.field private static final KEY_SUITE:Ljava/lang/String; = "suite"

.field private static final KEY_VENDOR:Ljava/lang/String; = "vendor"

.field private static final PROTECT_EXT:Ljava/lang/String; = "protectExt"

.field static final REMOVABLE_MEDIA_DIRECTORY_NAME:Ljava/lang/String; = "java"

.field public static final ROOT_FOLDER_NAME:Ljava/lang/String; = "/"

.field private static final SELECTOR_FILE_NAME:Ljava/lang/String; = "selector.utf"

.field public static final TAG:Ljava/lang/String; = "JbedSelector"

.field private static telMgr:Landroid/telephony/TelephonyManager;


# instance fields
.field mBaseDir:Ljava/lang/String;

.field mDataList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field private mLastModified:J


# direct methods
.method public constructor <init>(Ljava/lang/String;)V
    .locals 2
    .param p1, "baseDir"    # Ljava/lang/String;

    .prologue
    .line 168
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 98
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    .line 102
    const-wide/16 v0, -0x1

    iput-wide v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mLastModified:J

    .line 104
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mBaseDir:Ljava/lang/String;

    .line 169
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mBaseDir:Ljava/lang/String;

    .line 170
    return-void
.end method

.method private createExternalRoot(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 2
    .param p1, "root"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "name"    # Ljava/lang/String;
    .param p3, "storagePath"    # Ljava/lang/String;

    .prologue
    .line 214
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v0, p3, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 215
    .local v0, "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v1, -0x1

    iput v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 216
    const-string v1, "FOLDER"

    iput-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 217
    const-string v1, "N"

    iput-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    .line 218
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 220
    invoke-virtual {p1, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 221
    return-object v0
.end method

.method private createRoot()Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3

    .prologue
    .line 207
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mBaseDir:Ljava/lang/String;

    const-string v2, "/"

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 208
    .local v0, "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v1, -0x1

    iput v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 209
    const-string v1, "FOLDER"

    iput-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 210
    return-object v0
.end method

.method private getRoot()Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3

    .prologue
    .line 556
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-nez v1, :cond_0

    .line 557
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->createRoot()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 558
    .local v0, "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    move-object v1, v0

    .line 561
    .end local v0    # "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelector;
    :goto_0
    return-object v1

    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelector;
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    const/4 v2, 0x0

    invoke-interface {v1, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelector;
    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v1, p0

    goto :goto_0
.end method

.method private lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3

    .prologue
    .line 368
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    const/4 v2, 0x1

    sub-int/2addr v1, v2

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelector;
    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    return-object p0
.end method


# virtual methods
.method public findByHierarchyNames([Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 6
    .param p1, "names"    # [Ljava/lang/String;

    .prologue
    .line 570
    const/4 v1, 0x0

    .line 571
    .local v1, "level":I
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    .line 572
    .local v2, "list":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    const/4 v3, 0x0

    .line 573
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelector;
    .local v3, "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    array-length v4, p1

    if-ge v1, v4, :cond_2

    .line 574
    const/4 v3, 0x0

    .line 575
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_1
    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v4

    if-ge v0, v4, :cond_1

    .line 576
    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v4

    if-nez v4, :cond_3

    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    aget-object v5, p1, v1

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_3

    .line 577
    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v4, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    if-eqz v4, :cond_0

    .line 578
    const/4 v4, 0x0

    .line 592
    .end local v0    # "i":I
    :goto_2
    return-object v4

    .line 579
    .restart local v0    # "i":I
    :cond_0
    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v3

    .end local v3    # "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    check-cast v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 580
    .restart local v3    # "result":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v2, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    .line 585
    :cond_1
    if-nez v3, :cond_4

    .end local v0    # "i":I
    :cond_2
    move-object v4, v3

    .line 592
    goto :goto_2

    .line 575
    .restart local v0    # "i":I
    :cond_3
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 589
    :cond_4
    add-int/lit8 v1, v1, 0x1

    goto :goto_0
.end method

.method public findByUid(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3
    .param p1, "uuid"    # Ljava/lang/String;

    .prologue
    .line 533
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 534
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    move-object v2, v0

    .line 538
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    return-object v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 513
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 514
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    iget v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-ne v2, p2, :cond_0

    const/4 v2, -0x1

    if-eq p2, v2, :cond_0

    move-object v2, v0

    .line 518
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    return-object v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public findMidletByName(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 3
    .param p1, "name"    # Ljava/lang/String;

    .prologue
    .line 542
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 543
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_0

    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    move-object v2, v0

    .line 547
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    return-object v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 552
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    return-object v0
.end method

.method public getAllFolders(ZZZ)Ljava/util/List;
    .locals 5
    .param p1, "includeHidden"    # Z
    .param p2, "includeReadonly"    # Z
    .param p3, "includeRoot"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 637
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v1

    .line 638
    .local v1, "folders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    .local v2, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_4

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 639
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 640
    const/4 v3, 0x1

    .line 641
    .local v3, "included":Z
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v4

    if-eqz v4, :cond_1

    .line 642
    and-int/2addr v3, p1

    .line 644
    :cond_1
    iget-boolean v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-nez v4, :cond_2

    .line 645
    and-int/2addr v3, p2

    .line 648
    :cond_2
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v4, :cond_3

    .line 649
    and-int/2addr v3, p3

    .line 651
    :cond_3
    if-eqz v3, :cond_0

    .line 652
    invoke-interface {v1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 656
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v3    # "included":Z
    :cond_4
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v4

    if-eqz v4, :cond_5

    .line 657
    sget-object v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_REVERSE_ORDER:Ljava/util/Comparator;

    invoke-static {v1, v4}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 658
    :cond_5
    return-object v1
.end method

.method public getAllFolders(ZZZZ)Ljava/util/List;
    .locals 7
    .param p1, "includeHidden"    # Z
    .param p2, "includeReadonly"    # Z
    .param p3, "includeRoot"    # Z
    .param p4, "sdcardSelected"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    const-string v6, "sdcard"

    .line 663
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v1

    .line 664
    .local v1, "folders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    .local v2, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 666
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 667
    const/4 v3, 0x1

    .line 669
    .local v3, "included":Z
    if-eqz p4, :cond_3

    .line 670
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    const-string v5, "sdcard"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 671
    invoke-interface {v1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 694
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v3    # "included":Z
    :cond_1
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v4

    if-eqz v4, :cond_2

    .line 695
    sget-object v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_REVERSE_ORDER:Ljava/util/Comparator;

    invoke-static {v1, v4}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 696
    :cond_2
    return-object v1

    .line 675
    .restart local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local v3    # "included":Z
    :cond_3
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v4

    if-eqz v4, :cond_4

    .line 676
    and-int/2addr v3, p1

    .line 678
    :cond_4
    iget-boolean v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-nez v4, :cond_5

    .line 679
    and-int/2addr v3, p2

    .line 682
    :cond_5
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v4, :cond_6

    .line 683
    and-int/2addr v3, p3

    .line 685
    :cond_6
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    const-string v5, "sdcard"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_7

    .line 686
    const/4 v3, 0x0

    .line 688
    :cond_7
    if-eqz v3, :cond_0

    .line 689
    invoke-interface {v1, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0
.end method

.method public getAllOnlyMidlets()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 177
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 178
    .local v2, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 179
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v3

    if-eqz v3, :cond_0

    .line 180
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 183
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v2
.end method

.method public getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;
    .locals 5
    .param p1, "folder"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "includeHidden"    # Z
    .param p3, "includeReadonly"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            "ZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 701
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v3

    .line 702
    .local v3, "suites":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_6

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 703
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 704
    const/4 v2, 0x1

    .line 706
    .local v2, "included":Z
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v4

    if-nez v4, :cond_1

    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v4

    if-eqz v4, :cond_2

    .line 707
    :cond_1
    and-int/2addr v2, p2

    .line 709
    :cond_2
    iget-boolean v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-eqz v4, :cond_3

    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-nez v4, :cond_4

    .line 710
    :cond_3
    and-int/2addr v2, p3

    .line 712
    :cond_4
    if-eqz p1, :cond_5

    .line 713
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {p1, v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->equals(Ljava/lang/Object;)Z

    move-result v4

    and-int/2addr v2, v4

    .line 715
    :cond_5
    if-eqz v2, :cond_0

    .line 716
    invoke-interface {v3, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 720
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v2    # "included":Z
    :cond_6
    return-object v3
.end method

.method public getAllSyslockedMidlets()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 197
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 198
    .local v2, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 199
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v3

    if-eqz v3, :cond_0

    iget-object v3, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSystemLock()Z

    move-result v3

    if-eqz v3, :cond_0

    .line 200
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 203
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v2
.end method

.method getChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;
    .locals 1
    .param p1, "parent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ")",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 600
    if-nez p1, :cond_0

    .line 601
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getRoot()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object p1

    .line 603
    :cond_0
    iget-object v0, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    return-object v0
.end method

.method public getFolderByMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 2
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 522
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 523
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v0, :cond_0

    .line 524
    const/4 v1, 0x0

    .line 529
    :goto_0
    return-object v1

    .line 526
    :cond_0
    :goto_1
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v1

    if-nez v1, :cond_1

    .line 527
    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    goto :goto_1

    :cond_1
    move-object v1, v0

    .line 529
    goto :goto_0
.end method

.method public getMergedChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;
    .locals 5
    .param p1, "parent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ")",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 613
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 614
    .local v2, "result":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_4

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 616
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v3

    if-nez v3, :cond_0

    .line 619
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v3

    if-nez v3, :cond_1

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v3

    if-eqz v3, :cond_2

    .line 620
    :cond_1
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 624
    :cond_2
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v3

    const/4 v4, 0x1

    if-ne v3, v4, :cond_3

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmPending()Z

    move-result v3

    if-nez v3, :cond_3

    .line 625
    const/4 v3, 0x0

    invoke-virtual {v0, v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildren(I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v3

    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 627
    :cond_3
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 632
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_4
    return-object v2
.end method

.method public getMidlets()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 173
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    return-object v0
.end method

.method public getOnlySuites()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 187
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 188
    .local v2, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 189
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v3

    if-eqz v3, :cond_0

    .line 190
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 193
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v2
.end method

.method public getPowerOnMidlets()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 731
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 733
    .local v2, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 736
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFirstMidletInSuite()Z

    move-result v3

    if-eqz v3, :cond_0

    iget-boolean v3, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mLaunchPowerOn:Z

    if-eqz v3, :cond_0

    .line 742
    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 745
    .end local v0    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v2
.end method

.method public getPreMIDletWithSameClass(Ljava/lang/String;ILandroid/content/Context;)I
    .locals 6
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I
    .param p3, "context"    # Landroid/content/Context;

    .prologue
    const/4 v5, 0x1

    .line 796
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v2

    .line 797
    .local v2, "s":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eqz v2, :cond_0

    .line 798
    sub-int v3, p2, v5

    invoke-virtual {v2, v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildren(I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    .line 799
    .local v1, "m":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v0, 0x1

    .local v0, "i":I
    :goto_0
    if-ge v0, p2, :cond_0

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v3

    if-gt v0, v3, :cond_0

    .line 800
    if-eqz v1, :cond_1

    iget-object v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mEntryClass:Ljava/lang/String;

    if-eqz v3, :cond_1

    iget-object v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mEntryClass:Ljava/lang/String;

    sub-int v4, v0, v5

    invoke-virtual {v2, v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildren(I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v4

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mEntryClass:Ljava/lang/String;

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 801
    move p2, v0

    .line 806
    .end local v0    # "i":I
    .end local v1    # "m":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_0
    return p2

    .line 799
    .restart local v0    # "i":I
    .restart local v1    # "m":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0
.end method

.method loadFromDb(Landroid/content/Context;)V
    .locals 13
    .param p1, "context"    # Landroid/content/Context;
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    .prologue
    const/4 v12, 0x1

    const/4 v2, 0x0

    .line 451
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    .line 452
    .local v0, "resolver":Landroid/content/ContentResolver;
    sget-object v1, Lcom/esmertec/android/jbed/JbedProvider$Midlets;->CONTENT_URI:Landroid/net/Uri;

    const-string v5, "_ID asc"

    move-object v3, v2

    move-object v4, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 454
    .local v6, "c":Landroid/database/Cursor;
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 455
    :cond_0
    :goto_0
    if-eqz v6, :cond_3

    invoke-interface {v6}, Landroid/database/Cursor;->moveToNext()Z

    move-result v1

    if-eqz v1, :cond_3

    .line 456
    const-string v1, "name"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v9

    .line 457
    .local v9, "name":Ljava/lang/String;
    const-string v1, "storage_path"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v11

    .line 458
    .local v11, "storagePath":Ljava/lang/String;
    new-instance v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v7, v11, v9}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 459
    .local v7, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const-string v1, "file_root"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    .line 460
    const-string v1, "no"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getInt(I)I

    move-result v1

    iput v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 461
    const-string v1, "root"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 462
    const-string v1, "uid"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    .line 463
    const-string v1, "vendor"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    .line 464
    const-string v1, "install_time"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v1

    iput-wide v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    .line 465
    const-string v1, "domain"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDomain:Ljava/lang/String;

    .line 466
    const-string v1, "size"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getInt(I)I

    move-result v1

    iput v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    .line 467
    const-string v1, "removable"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    .line 468
    const-string v1, "drm_protected"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    .line 469
    const-string v1, "drm_pending"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v1

    iput-object v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    .line 470
    const-string v1, "is_hidden"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getInt(I)I

    move-result v8

    .line 471
    .local v8, "hidden":I
    if-ne v8, v12, :cond_2

    move v1, v12

    :goto_1
    iput-boolean v1, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    .line 473
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v1, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 475
    const-string v1, "parent_uid"

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v1

    invoke-interface {v6, v1}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v10

    .line 479
    .local v10, "parentUid":Ljava/lang/String;
    if-eqz v10, :cond_0

    .line 480
    invoke-virtual {p0, v10}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findByUid(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    invoke-virtual {v1, v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto/16 :goto_0

    .line 486
    .end local v7    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v8    # "hidden":I
    .end local v9    # "name":Ljava/lang/String;
    .end local v10    # "parentUid":Ljava/lang/String;
    .end local v11    # "storagePath":Ljava/lang/String;
    :catchall_0
    move-exception v1

    if-eqz v6, :cond_1

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_1
    throw v1

    .line 471
    .restart local v7    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local v8    # "hidden":I
    .restart local v9    # "name":Ljava/lang/String;
    .restart local v11    # "storagePath":Ljava/lang/String;
    :cond_2
    const/4 v1, 0x0

    goto :goto_1

    .line 486
    .end local v7    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v8    # "hidden":I
    .end local v9    # "name":Ljava/lang/String;
    .end local v11    # "storagePath":Ljava/lang/String;
    :cond_3
    if-eqz v6, :cond_4

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 488
    :cond_4
    return-void
.end method

.method public declared-synchronized loadFromFiles()V
    .locals 9

    .prologue
    const-string v5, "JbedSelector"

    .line 373
    monitor-enter p0

    :try_start_0
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->createRoot()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v3

    .line 374
    .local v3, "root":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    new-instance v4, Ljava/io/File;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v6, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "selector.utf"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 375
    .local v4, "selector":Ljava/io/File;
    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v5

    if-eqz v5, :cond_0

    iget-wide v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mLastModified:J

    invoke-virtual {v4}, Ljava/io/File;->lastModified()J

    move-result-wide v7

    cmp-long v5, v5, v7

    if-eqz v5, :cond_0

    .line 376
    const-string v5, "JbedSelector"

    const-string v6, "loadFromFiles since the selector.utf has been changed!!"

    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 377
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v5}, Ljava/util/List;->clear()V

    .line 378
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v5, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 379
    const/4 v1, 0x0

    .line 381
    .local v1, "in":Ljava/io/DataInputStream;
    :try_start_1
    new-instance v2, Ljava/io/DataInputStream;

    new-instance v5, Ljava/io/FileInputStream;

    invoke-direct {v5, v4}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v2, v5}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_1
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_0
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 382
    .end local v1    # "in":Ljava/io/DataInputStream;
    .local v2, "in":Ljava/io/DataInputStream;
    :try_start_2
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/ams/JbedSelector;->parse(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;Ljava/lang/String;)V

    .line 383
    invoke-virtual {v4}, Ljava/io/File;->lastModified()J

    move-result-wide v5

    iput-wide v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mLastModified:J
    :try_end_2
    .catch Ljava/io/FileNotFoundException; {:try_start_2 .. :try_end_2} :catch_6
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_5
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    .line 391
    :try_start_3
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 396
    .end local v2    # "in":Ljava/io/DataInputStream;
    :cond_0
    :goto_0
    monitor-exit p0

    return-void

    .line 384
    .restart local v1    # "in":Ljava/io/DataInputStream;
    :catch_0
    move-exception v5

    move-object v0, v5

    .line 385
    .local v0, "e":Ljava/io/FileNotFoundException;
    :goto_1
    :try_start_4
    const-string v5, "JbedSelector"

    const-string v6, " selectorFile.toString() isn\'t exist "

    invoke-static {v5, v6, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 386
    new-instance v5, Ljava/lang/IllegalStateException;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4}, Ljava/io/File;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " isn\'t exist"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v5, v6}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v5
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 390
    .end local v0    # "e":Ljava/io/FileNotFoundException;
    :catchall_0
    move-exception v5

    .line 391
    :goto_2
    :try_start_5
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_4
    .catchall {:try_start_5 .. :try_end_5} :catchall_1

    .line 393
    :goto_3
    :try_start_6
    throw v5
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    .line 373
    .end local v1    # "in":Ljava/io/DataInputStream;
    .end local v3    # "root":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v4    # "selector":Ljava/io/File;
    :catchall_1
    move-exception v5

    monitor-exit p0

    throw v5

    .line 387
    .restart local v1    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "root":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local v4    # "selector":Ljava/io/File;
    :catch_1
    move-exception v5

    move-object v0, v5

    .line 388
    .local v0, "e":Ljava/io/IOException;
    :goto_4
    :try_start_7
    const-string v5, "JbedSelector"

    const-string v6, " failed to read selector file"

    invoke-static {v5, v6, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_0

    .line 391
    :try_start_8
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_8
    .catch Ljava/io/IOException; {:try_start_8 .. :try_end_8} :catch_2
    .catchall {:try_start_8 .. :try_end_8} :catchall_1

    goto :goto_0

    .line 392
    :catch_2
    move-exception v5

    goto :goto_0

    .end local v0    # "e":Ljava/io/IOException;
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_3
    move-exception v5

    goto :goto_0

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    :catch_4
    move-exception v6

    goto :goto_3

    .line 390
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catchall_2
    move-exception v5

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_2

    .line 387
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_5
    move-exception v5

    move-object v0, v5

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_4

    .line 384
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_6
    move-exception v5

    move-object v0, v5

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_1
.end method

.method parse(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;Ljava/lang/String;)V
    .locals 17
    .param p1, "root"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "selector"    # Ljava/lang/String;
    .param p3, "storagePath"    # Ljava/lang/String;

    .prologue
    .line 248
    new-instance v4, Ljava/util/Stack;

    invoke-direct {v4}, Ljava/util/Stack;-><init>()V

    .line 249
    .local v4, "folderStack":Ljava/util/Stack;, "Ljava/util/Stack<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    move-object v0, v4

    move-object/from16 v1, p1

    invoke-virtual {v0, v1}, Ljava/util/Stack;->push(Ljava/lang/Object;)Ljava/lang/Object;

    .line 255
    const-string v14, "\\\\,"

    const-string v15, ","

    move-object/from16 v0, p2

    move-object v1, v14

    move-object v2, v15

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v14

    const-string v15, "\\\\\\\\"

    const-string v16, "\\\\"

    invoke-virtual/range {v14 .. v16}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    .line 257
    const-string v14, "\n"

    move-object/from16 v0, p2

    move-object v1, v14

    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v7

    .line 258
    .local v7, "lines":[Ljava/lang/String;
    const/4 v5, 0x0

    .local v5, "i":I
    :goto_0
    array-length v14, v7

    if-ge v5, v14, :cond_18

    .line 259
    aget-object v14, v7, v5

    invoke-virtual {v14}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v6

    .line 260
    .local v6, "line":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v14

    if-nez v14, :cond_1

    .line 258
    :cond_0
    :goto_1
    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    .line 262
    :cond_1
    aget-object v14, v7, v5

    const/16 v15, 0x3d

    invoke-virtual {v14, v15}, Ljava/lang/String;->indexOf(I)I

    move-result v10

    .line 263
    .local v10, "separtorPos":I
    aget-object v14, v7, v5

    const/4 v15, 0x0

    invoke-virtual {v14, v15, v10}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v14}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v12

    .line 264
    .local v12, "token":Ljava/lang/String;
    aget-object v14, v7, v5

    add-int/lit8 v15, v10, 0x1

    invoke-virtual {v14, v15}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v13

    .line 265
    .local v13, "value":Ljava/lang/String;
    invoke-virtual {v13}, Ljava/lang/String;->length()I

    move-result v14

    if-nez v14, :cond_2

    .line 267
    const-string v14, "endfolder"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_0

    .line 268
    invoke-virtual {v4}, Ljava/util/Stack;->pop()Ljava/lang/Object;

    goto :goto_1

    .line 273
    :cond_2
    const-string v14, ", \\"

    invoke-virtual {v13, v14}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v14

    if-eqz v14, :cond_3

    .line 274
    const/4 v14, 0x0

    invoke-virtual {v13}, Ljava/lang/String;->length()I

    move-result v15

    const/16 v16, 0x3

    sub-int v15, v15, v16

    invoke-virtual {v13, v14, v15}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v13

    .line 277
    :cond_3
    const-string v14, "folder"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_6

    .line 278
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v3

    move-object/from16 v1, p3

    move-object v2, v13

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 279
    .local v3, "folder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const-string v14, "sdcard"

    invoke-virtual {v13, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_4

    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v14

    if-nez v14, :cond_4

    .line 280
    const/4 v14, 0x1

    iput-boolean v14, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    .line 282
    :cond_4
    const/4 v14, -0x1

    iput v14, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 283
    const-string v14, "FOLDER"

    iput-object v14, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 284
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    move-object v14, v0

    invoke-interface {v14, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 286
    invoke-virtual {v4}, Ljava/util/Stack;->peek()Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 288
    .local v9, "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v9, v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 290
    invoke-virtual {v9}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v14

    if-eqz v14, :cond_5

    .line 291
    const/4 v14, 0x1

    iput-boolean v14, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    .line 293
    :cond_5
    invoke-virtual {v4, v3}, Ljava/util/Stack;->push(Ljava/lang/Object;)Ljava/lang/Object;

    goto/16 :goto_1

    .line 294
    .end local v3    # "folder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v9    # "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_6
    const-string v14, "suite"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_7

    .line 295
    new-instance v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v11

    move-object/from16 v1, p3

    move-object v2, v13

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 296
    .local v11, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v14, 0x0

    iput v14, v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 297
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    move-object v14, v0

    invoke-interface {v14, v11}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 300
    invoke-virtual {v4}, Ljava/util/Stack;->peek()Ljava/lang/Object;

    move-result-object v9

    check-cast v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 301
    .restart local v9    # "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v9, v11}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 302
    .end local v9    # "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v11    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_7
    const-string v14, "midlet"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_8

    .line 303
    new-instance v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v0, v8

    move-object/from16 v1, p3

    move-object v2, v13

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 304
    .local v8, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    add-int/lit8 v14, v14, 0x1

    iput v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 306
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iput-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 307
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    iput-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    .line 308
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    iput-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    .line 309
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    iput-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    .line 310
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    iput-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    .line 311
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-boolean v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mLaunchPowerOn:Z

    iput-boolean v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mLaunchPowerOn:Z

    .line 312
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-boolean v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    iput-boolean v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    .line 313
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iget-boolean v14, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPreInstall:Z

    iput-boolean v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPreInstall:Z

    .line 314
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    move-object v14, v0

    invoke-interface {v14, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 317
    iget-object v14, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    move-object/from16 v0, p0

    move-object v1, v14

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v11

    .line 318
    .restart local v11    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v11, v8}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 319
    .end local v8    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v11    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_8
    const-string v14, "root"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_9

    .line 320
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 321
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const/4 v15, 0x0

    invoke-virtual {v14, v15}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->calculateSize(Z)V

    goto/16 :goto_1

    .line 322
    :cond_9
    const-string v14, "domain"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_a

    .line 323
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDomain:Ljava/lang/String;

    goto/16 :goto_1

    .line 324
    :cond_a
    const-string v14, "vendor"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_b

    .line 325
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    goto/16 :goto_1

    .line 326
    :cond_b
    const-string v14, "preinstalled"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_c

    .line 327
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const-string v15, "Y"

    invoke-virtual {v13, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    iput-boolean v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPreInstall:Z

    goto/16 :goto_1

    .line 328
    :cond_c
    const-string v14, "install_time"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_d

    .line 329
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    invoke-static {v13}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v15

    iput-wide v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    goto/16 :goto_1

    .line 330
    :cond_d
    const-string v14, "removable"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_e

    .line 331
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    goto/16 :goto_1

    .line 332
    :cond_e
    const-string v14, "drmProtected"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_f

    .line 333
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    goto/16 :goto_1

    .line 334
    :cond_f
    const-string v14, "drmPending"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_10

    .line 335
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    goto/16 :goto_1

    .line 336
    :cond_10
    const-string v14, "drmIntervalEverLaunched"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_11

    .line 337
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmIntervalEverLaunched:Ljava/lang/String;

    goto/16 :goto_1

    .line 338
    :cond_11
    const-string v14, "fileRoot"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_12

    .line 342
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    .line 343
    sget-object v14, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v13, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_0

    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v14

    if-nez v14, :cond_0

    .line 344
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const/4 v15, 0x1

    iput-boolean v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    goto/16 :goto_1

    .line 345
    :cond_12
    const-string v14, "launchPowerOn"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_13

    .line 346
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const-string v15, "Y"

    invoke-virtual {v13, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    iput-boolean v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mLaunchPowerOn:Z

    goto/16 :goto_1

    .line 347
    :cond_13
    const-string v14, "modifiableContent"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_14

    .line 348
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const-string v15, "Y"

    invoke-virtual {v13, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    iput-boolean v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    goto/16 :goto_1

    .line 349
    :cond_14
    const-string v14, "class"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_15

    .line 350
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mEntryClass:Ljava/lang/String;

    goto/16 :goto_1

    .line 351
    :cond_15
    const-string v14, "protectExt"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_16

    .line 352
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    goto/16 :goto_1

    .line 353
    :cond_16
    const-string v14, "hasShortCut"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_17

    .line 354
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    const-string v15, "Y"

    invoke-virtual {v13, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    iput-boolean v15, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    goto/16 :goto_1

    .line 355
    :cond_17
    const-string v14, "displaySizeInfo"

    invoke-virtual {v12, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_0

    .line 356
    invoke-direct/range {p0 .. p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->lastSelectorData()Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v14

    iput-object v13, v14, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDisplayInfo:Ljava/lang/String;

    goto/16 :goto_1

    .line 362
    .end local v6    # "line":Ljava/lang/String;
    .end local v10    # "separtorPos":I
    .end local v12    # "token":Ljava/lang/String;
    .end local v13    # "value":Ljava/lang/String;
    :cond_18
    invoke-virtual {v4}, Ljava/util/Stack;->peek()Ljava/lang/Object;

    move-result-object v14

    move-object v0, v14

    move-object/from16 v1, p1

    if-eq v0, v1, :cond_19

    .line 363
    new-instance v14, Ljava/lang/IllegalArgumentException;

    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    move-object v0, v15

    move-object/from16 v1, p3

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    const-string v16, "selector.utf has been corrupted!"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    invoke-virtual {v15}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v15

    invoke-direct {v14, v15}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v14

    .line 365
    :cond_19
    return-void
.end method

.method public storeToDb(Landroid/content/Context;)V
    .locals 11
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    const/4 v10, 0x1

    const/4 v9, 0x0

    .line 401
    :try_start_0
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v3

    .line 402
    .local v3, "resolver":Landroid/content/ContentResolver;
    sget-object v6, Lcom/esmertec/android/jbed/ams/JbedSelector;->telMgr:Landroid/telephony/TelephonyManager;

    if-nez v6, :cond_0

    .line 403
    const-string v6, "phone"

    invoke-virtual {p1, v6}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Landroid/telephony/TelephonyManager;

    sput-object v6, Lcom/esmertec/android/jbed/ams/JbedSelector;->telMgr:Landroid/telephony/TelephonyManager;

    .line 405
    :cond_0
    sget-object v6, Lcom/esmertec/android/jbed/JbedProvider$Midlets;->CONTENT_URI:Landroid/net/Uri;

    const/4 v7, 0x0

    const/4 v8, 0x0

    invoke-virtual {v3, v6, v7, v8}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I

    .line 407
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getMidlets()Ljava/util/List;

    move-result-object v2

    .line 408
    .local v2, "mildets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_3

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 409
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    new-instance v5, Landroid/content/ContentValues;

    invoke-direct {v5}, Landroid/content/ContentValues;-><init>()V

    .line 410
    .local v5, "values":Landroid/content/ContentValues;
    const-string v6, "name"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 411
    const-string v6, "storage_path"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 412
    const-string v6, "file_root"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 413
    const-string v6, "no"

    iget v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 414
    const-string v6, "root"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 415
    const-string v6, "parent_uid"

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getParentUid()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 416
    const-string v6, "uid"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 417
    const-string v6, "_data"

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getIconPath()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 418
    const-string v6, "vendor"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 419
    const-string v6, "install_time"

    iget-wide v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    invoke-static {v7, v8}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 420
    const-string v6, "domain"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDomain:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 421
    const-string v6, "size"

    iget v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 422
    const-string v6, "removable"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 423
    const-string v6, "drm_protected"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 424
    const-string v6, "drm_pending"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 425
    const-string v6, "is_hidden"

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isHidden()Z

    move-result v7

    if-eqz v7, :cond_1

    move v7, v10

    :goto_1
    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 432
    const/4 v6, 0x0

    iput-boolean v6, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    .line 434
    const-string v6, "has_short_cut"

    iget-boolean v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    if-eqz v7, :cond_2

    move v7, v10

    :goto_2
    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 435
    const-string v6, "display_info"

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDisplayInfo:Ljava/lang/String;

    invoke-virtual {v5, v6, v7}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 436
    sget-object v6, Lcom/esmertec/android/jbed/JbedProvider$Midlets;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v3, v6, v5}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;
    :try_end_0
    .catch Landroid/database/sqlite/SQLiteException; {:try_start_0 .. :try_end_0} :catch_0

    goto/16 :goto_0

    .line 440
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v2    # "mildets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .end local v3    # "resolver":Landroid/content/ContentResolver;
    .end local v5    # "values":Landroid/content/ContentValues;
    :catch_0
    move-exception v6

    move-object v4, v6

    .line 441
    .local v4, "se":Landroid/database/sqlite/SQLiteException;
    const-string v6, "JbedSelector"

    const-string v7, " failed to store MIDlet info to db"

    invoke-static {v6, v7, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 443
    .end local v4    # "se":Landroid/database/sqlite/SQLiteException;
    :goto_3
    return-void

    .restart local v0    # "i$":Ljava/util/Iterator;
    .restart local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local v2    # "mildets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .restart local v3    # "resolver":Landroid/content/ContentResolver;
    .restart local v5    # "values":Landroid/content/ContentValues;
    :cond_1
    move v7, v9

    .line 425
    goto :goto_1

    :cond_2
    move v7, v9

    .line 434
    goto :goto_2

    .line 439
    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v5    # "values":Landroid/content/ContentValues;
    :cond_3
    :try_start_1
    sget-object v6, Lcom/esmertec/android/jbed/JbedProvider$Midlets;->CONTENT_URI:Landroid/net/Uri;

    const/4 v7, 0x0

    invoke-virtual {v3, v6, v7}, Landroid/content/ContentResolver;->notifyChange(Landroid/net/Uri;Landroid/database/ContentObserver;)V
    :try_end_1
    .catch Landroid/database/sqlite/SQLiteException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_3
.end method

.method public toFolderCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;)[",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;"
        }
    .end annotation

    .prologue
    .line 749
    .local p1, "folders":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v4

    new-array v3, v4, [Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 750
    .local v3, "result":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    array-length v4, v3

    if-ge v2, v4, :cond_2

    .line 751
    invoke-interface {p1, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 752
    .local v0, "folder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v4

    if-nez v4, :cond_0

    .line 753
    new-instance v4, Ljava/lang/IllegalArgumentException;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, " object "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, " is not folder type"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v4

    .line 755
    :cond_0
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v4

    const-string v5, "TW"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 756
    new-instance v1, Ljava/lang/StringBuffer;

    invoke-direct {v1}, Ljava/lang/StringBuffer;-><init>()V

    .line 757
    .local v1, "fullPath":Ljava/lang/StringBuffer;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFullPath()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 758
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->length()I

    move-result v4

    const/4 v5, 0x1

    sub-int/2addr v4, v5

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->deleteCharAt(I)Ljava/lang/StringBuffer;

    .line 759
    new-instance v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v4, v3, v2

    .line 750
    .end local v1    # "fullPath":Ljava/lang/StringBuffer;
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 761
    :cond_1
    new-instance v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getFormatedLevelName()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v4, v3, v2

    goto :goto_1

    .line 764
    .end local v0    # "folder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    return-object v3
.end method

.method public toMidletCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;)[",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;"
        }
    .end annotation

    .prologue
    .line 780
    .local p1, "suites":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v3

    new-array v1, v3, [Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 781
    .local v1, "result":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    array-length v3, v1

    if-ge v0, v3, :cond_1

    .line 782
    invoke-interface {p1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 783
    .local v2, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v3

    if-nez v3, :cond_0

    .line 784
    new-instance v3, Ljava/lang/IllegalArgumentException;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, " object "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " is not suite type"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 786
    :cond_0
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v4, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v5, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {p0, v4, v5}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v4

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-direct {v3, v4, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v3, v1, v0

    .line 781
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 788
    .end local v2    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v1
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    .prologue
    .line 504
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    .line 505
    .local v0, "b":Ljava/lang/StringBuffer;
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mDataList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    .local v2, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 506
    .local v1, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 507
    const-string v3, "\n"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto :goto_0

    .line 509
    .end local v1    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_0
    invoke-virtual {v0}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v3

    return-object v3
.end method

.method public toSuiteCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;)[",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;"
        }
    .end annotation

    .prologue
    .line 768
    .local p1, "suites":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v3

    new-array v1, v3, [Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    .line 769
    .local v1, "result":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    array-length v3, v1

    if-ge v0, v3, :cond_1

    .line 770
    invoke-interface {p1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 771
    .local v2, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v3

    if-nez v3, :cond_0

    .line 772
    new-instance v3, Ljava/lang/IllegalArgumentException;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, " object "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " is not suite type"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 774
    :cond_0
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v4, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-direct {v3, v4, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v3, v1, v0

    .line 769
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 776
    .end local v2    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    return-object v1
.end method

.method public touch()V
    .locals 3

    .prologue
    .line 495
    new-instance v0, Ljava/io/File;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector;->mBaseDir:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "selector.utf"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 496
    .local v0, "selectorFile":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 497
    const-string v1, "JbedSelector"

    const-string v2, " touch() the selector.utf to make refesh the content"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 498
    new-instance v1, Ljava/util/Date;

    invoke-direct {v1}, Ljava/util/Date;-><init>()V

    invoke-virtual {v1}, Ljava/util/Date;->getTime()J

    move-result-wide v1

    invoke-virtual {v0, v1, v2}, Ljava/io/File;->setLastModified(J)Z

    .line 500
    :cond_0
    return-void
.end method
