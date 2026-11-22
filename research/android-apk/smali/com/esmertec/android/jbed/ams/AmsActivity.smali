.class public Lcom/esmertec/android/jbed/ams/AmsActivity;
.super Landroid/app/ListActivity;
.source "AmsActivity.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;,
        Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;
    }
.end annotation


# static fields
.field private static final AMS_MAIN_SCREEN_TITLE:I = 0x5c

.field private static final AMS_MODULE_ID:I = 0x4

.field private static final CURRENT_STORAGE_NAME:Ljava/lang/String; = "current.storage"

.field public static final DIALOG_INSTALL:I = 0x0

.field public static final DIALOG_WAIT:I = 0x1

.field public static final EXTERNAL_STORAGE_INDEX:I = 0x1

.field public static final HORIZOTAL_DIALOG:I = 0x2

.field public static final INTERNAL_STORAGE_INDEX:I = 0x0

.field public static final IS_CONTEXT_ITEM_SELECTED:I = 0x1

.field public static final IS_NOT_CONTEXT_ITEM_SELECTED:I = 0x0

.field public static final LANDSCAPE_MAX_WIDTH:I = 0x172

.field private static final LIST_ORDER_NAME:Ljava/lang/String; = "list.order"

.field private static final MINIMUM_MEMORY_SIZE:I = 0x9c4000

.field static final TAG:Ljava/lang/String; = "AmsActivity"

.field private static hasInitAmsClient:Z

.field private static mJbedExiting:Z

.field private static sListOrderMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;>;"
        }
    .end annotation
.end field


# instance fields
.field private isContextItemSelected:Z

.field mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

.field mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

.field private final mDevKeys:Ljava/lang/String;

.field private mHandler:Landroid/os/Handler;

.field private mInputDevKeys:Ljava/lang/StringBuffer;

.field private mInstallDialog:Landroid/app/ProgressDialog;

.field private mIsServiceConnected:Z

.field private mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

.field private mOptionMenu:Landroid/view/Menu;

.field private mPendingQueue:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList",
            "<",
            "Landroid/os/Message;",
            ">;"
        }
    .end annotation
.end field

.field private mRefreshReceiver:Landroid/content/BroadcastReceiver;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    const/4 v1, 0x0

    .line 90
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    .line 118
    sput-boolean v1, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasInitAmsClient:Z

    .line 119
    sput-boolean v1, Lcom/esmertec/android/jbed/ams/AmsActivity;->mJbedExiting:Z

    .line 134
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    const v1, 0x7f080044

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_ORDER:Ljava/util/Comparator;

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 135
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    const v1, 0x7f080045

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_REVERSE_ORDER:Ljava/util/Comparator;

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 136
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    const v1, 0x7f080046

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->SIZE_ORDER:Ljava/util/Comparator;

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 137
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    const v1, 0x7f080047

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->INSTALLTIME_ORDER:Ljava/util/Comparator;

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 138
    return-void
.end method

.method public constructor <init>()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    const/4 v1, 0x0

    .line 72
    invoke-direct {p0}, Landroid/app/ListActivity;-><init>()V

    .line 93
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInstallDialog:Landroid/app/ProgressDialog;

    .line 95
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    .line 101
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mPendingQueue:Ljava/util/ArrayList;

    .line 103
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    .line 106
    const-string v0, "123"

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mDevKeys:Ljava/lang/String;

    .line 108
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInputDevKeys:Ljava/lang/StringBuffer;

    .line 111
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 114
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 116
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    .line 140
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsActivity$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$1;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mRefreshReceiver:Landroid/content/BroadcastReceiver;

    .line 976
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100()Z
    .locals 1

    .prologue
    .line 72
    sget-boolean v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mJbedExiting:Z

    return v0
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->processIntent()V

    return-void
.end method

.method static synthetic access$102(Z)Z
    .locals 0
    .param p0, "x0"    # Z

    .prologue
    .line 72
    sput-boolean p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mJbedExiting:Z

    return p0
.end method

.method static synthetic access$1100(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/JbedApp;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$1200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    return v0
.end method

.method static synthetic access$1202(Lcom/esmertec/android/jbed/ams/AmsActivity;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;
    .param p1, "x1"    # Z

    .prologue
    .line 72
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    return p1
.end method

.method static synthetic access$1300(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/util/ArrayList;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mPendingQueue:Ljava/util/ArrayList;

    return-object v0
.end method

.method static synthetic access$1400(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->onServiceConnected()V

    return-void
.end method

.method static synthetic access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInstallDialog:Landroid/app/ProgressDialog;

    return-object v0
.end method

.method static synthetic access$1600(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->disconnect()V

    return-void
.end method

.method static synthetic access$1700(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/view/Menu;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mOptionMenu:Landroid/view/Menu;

    return-object v0
.end method

.method static synthetic access$1800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsListAdapter;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/ams/AmsActivity;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # Ljava/lang/String;

    .prologue
    .line 72
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->showWarningDialog(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/ams/AmsActivity;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->loadListOrderId()I

    move-result v0

    return v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/ams/AmsActivity;ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;
    .param p1, "x1"    # I
    .param p2, "x2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 72
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->refreshList(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    return-void
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->isInRoot()Z

    move-result v0

    return v0
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/lang/StringBuffer;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsActivity;

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInputDevKeys:Ljava/lang/StringBuffer;

    return-object v0
.end method

.method private connect()V
    .locals 4

    .prologue
    .line 346
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    const-wide/16 v2, 0x1

    invoke-virtual {v0, p0, v1, v2, v3}, Lcom/esmertec/android/jbed/JbedApp;->startService(Landroid/app/Activity;Landroid/os/Handler;J)V

    .line 347
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedApp;->notifyAmsForeground()V

    .line 348
    return-void
.end method

.method private disconnect()V
    .locals 2

    .prologue
    .line 383
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    .line 384
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->stopService(Landroid/os/Handler;)V

    .line 385
    return-void
.end method

.method private getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;
    .locals 2

    .prologue
    .line 388
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->getAmsClient(Landroid/os/Handler;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    return-object v0
.end method

.method private getApp()Lcom/esmertec/android/jbed/JbedApp;
    .locals 0

    .prologue
    .line 341
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getApplication()Landroid/app/Application;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/AmsActivity;
    check-cast p0, Lcom/esmertec/android/jbed/JbedApp;

    return-object p0
.end method

.method public static hasEnoughFreeMemory()Z
    .locals 10

    .prologue
    .line 953
    const-string v0, "/data"

    .line 954
    .local v0, "DATA_PATH":Ljava/lang/String;
    const-wide/16 v6, 0x0

    .line 955
    .local v6, "freeMem":J
    new-instance v5, Landroid/os/StatFs;

    invoke-direct {v5, v0}, Landroid/os/StatFs;-><init>(Ljava/lang/String;)V

    .line 958
    .local v5, "fileStats":Landroid/os/StatFs;
    invoke-virtual {v5}, Landroid/os/StatFs;->getBlockSize()I

    move-result v8

    int-to-long v3, v8

    .line 959
    .local v3, "blkSize":J
    invoke-virtual {v5}, Landroid/os/StatFs;->getAvailableBlocks()I

    move-result v8

    int-to-long v1, v8

    .line 960
    .local v1, "availBlkNum":J
    mul-long v6, v1, v3

    .line 962
    const-wide/32 v8, 0x9c4000

    cmp-long v8, v6, v8

    if-gez v8, :cond_0

    .line 963
    const/4 v8, 0x0

    .line 965
    :goto_0
    return v8

    :cond_0
    const/4 v8, 0x1

    goto :goto_0
.end method

.method public static initAmsClient(Lcom/esmertec/android/jbed/ams/AmsClient;)V
    .locals 2
    .param p0, "client"    # Lcom/esmertec/android/jbed/ams/AmsClient;

    .prologue
    .line 151
    if-nez p0, :cond_1

    .line 152
    const-string v0, "AmsActivity"

    const-string v1, "initAmsClient() client is null!"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 160
    :cond_0
    :goto_0
    return-void

    .line 155
    :cond_1
    sget-boolean v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasInitAmsClient:Z

    if-nez v0, :cond_0

    .line 156
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallCancelEvent()V

    .line 157
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->releaseInstallLock()V

    .line 158
    const/4 v0, 0x1

    sput-boolean v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasInitAmsClient:Z

    goto :goto_0
.end method

.method private isInRoot()Z
    .locals 1

    .prologue
    .line 432
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v0, :cond_1

    :cond_0
    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_1
    const/4 v0, 0x0

    goto :goto_0
.end method

.method private loadListOrderId()I
    .locals 3

    .prologue
    .line 658
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getPreferences(I)Landroid/content/SharedPreferences;

    move-result-object v0

    const-string v1, "list.order"

    const v2, 0x7f080044

    invoke-interface {v0, v1, v2}, Landroid/content/SharedPreferences;->getInt(Ljava/lang/String;I)I

    move-result v0

    return v0
.end method

.method private onServiceConnected()V
    .locals 1

    .prologue
    .line 354
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$7;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->start()V

    .line 380
    return-void
.end method

.method private processIntent()V
    .locals 14

    .prologue
    const-string v3, "AmsActivity"

    .line 778
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getIntent()Landroid/content/Intent;

    move-result-object v12

    .line 779
    .local v12, "intent":Landroid/content/Intent;
    invoke-virtual {v12}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v6

    .line 780
    .local v6, "action":Ljava/lang/String;
    invoke-virtual {v12}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v7

    .line 782
    .local v7, "bundle":Landroid/os/Bundle;
    if-nez v7, :cond_1

    .line 783
    const/4 v13, 0x0

    .line 802
    .local v13, "uriJad":Ljava/lang/String;
    :goto_0
    const-string v1, "AmsActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "processIntent() uriJad = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 804
    if-eqz v6, :cond_0

    const-string v1, "android.intent.action.VIEW"

    invoke-virtual {v6, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 805
    if-nez v13, :cond_3

    .line 806
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v1

    invoke-virtual {v12}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v2

    invoke-virtual {v12}, Landroid/content/Intent;->getType()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v0, p0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;-><init>(Landroid/content/Context;Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/net/Uri;Ljava/lang/String;)V

    .line 808
    .local v0, "installer":Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->requestInstall()V

    .line 816
    .end local v0    # "installer":Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;
    .end local v13    # "uriJad":Ljava/lang/String;
    :cond_0
    :goto_1
    return-void

    .line 786
    :cond_1
    const-string v1, "chapiURL"

    invoke-virtual {v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 787
    .local v8, "chapi_URL":Ljava/lang/String;
    const-string v1, "contentType"

    invoke-virtual {v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    .line 788
    .local v11, "chapi_contentType":Ljava/lang/String;
    const-string v1, "action"

    invoke-virtual {v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    .line 789
    .local v9, "chapi_action":Ljava/lang/String;
    const-string v1, "appName"

    invoke-virtual {v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    .line 790
    .local v10, "chapi_appName":Ljava/lang/String;
    if-eqz v8, :cond_2

    if-eqz v11, :cond_2

    if-eqz v9, :cond_2

    if-eqz v10, :cond_2

    .line 792
    const-string v1, "AmsActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "onCreate() chapiURL = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 793
    const-string v1, "AmsActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "onCreate() contentType = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 794
    const-string v1, "AmsActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "onCreate() action = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 795
    const-string v1, "AmsActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "onCreate() appName = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 796
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v1

    invoke-virtual {v1, v8, v11, v9, v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestChapiEvent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    goto/16 :goto_1

    .line 800
    :cond_2
    const-string v1, "uri"

    invoke-virtual {v7, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    .restart local v13    # "uriJad":Ljava/lang/String;
    goto/16 :goto_0

    .line 811
    .end local v8    # "chapi_URL":Ljava/lang/String;
    .end local v9    # "chapi_action":Ljava/lang/String;
    .end local v10    # "chapi_appName":Ljava/lang/String;
    .end local v11    # "chapi_contentType":Ljava/lang/String;
    :cond_3
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v2

    invoke-virtual {v12}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v3

    invoke-virtual {v12}, Landroid/content/Intent;->getType()Ljava/lang/String;

    move-result-object v4

    invoke-static {v13}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v5

    move-object v1, p0

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;-><init>(Landroid/content/Context;Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/net/Uri;Ljava/lang/String;Landroid/net/Uri;)V

    .line 813
    .restart local v0    # "installer":Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->requestInstall()V

    goto/16 :goto_1
.end method

.method private refreshList(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 12
    .param p1, "listOrderId"    # I
    .param p2, "folder"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 708
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    if-nez v9, :cond_0

    .line 775
    :goto_0
    return-void

    .line 714
    :cond_0
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 715
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    invoke-virtual {v9, p2}, Lcom/esmertec/android/jbed/ams/AmsClient;->getMergedChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;

    move-result-object v5

    .line 716
    .local v5, "mildets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    .local v3, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_2

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 717
    .local v1, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-boolean v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    if-eqz v9, :cond_1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v9

    if-eqz v9, :cond_1

    .line 718
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    iget-object v10, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v9, v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->checkExpiredMidlet(Ljava/lang/String;)Z

    move-result v9

    iput-boolean v9, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    .line 721
    :cond_1
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->clearState()V

    goto :goto_1

    .line 723
    .end local v1    # "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    if-eqz p2, :cond_3

    .line 724
    const-string v9, "AmsActivity"

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "folderName="

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    iget-object v11, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, " midlets.size = "

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-interface {v5}, Ljava/util/List;->size()I

    move-result v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v9, v10}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 726
    :cond_3
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v9

    if-eqz v9, :cond_4

    .line 727
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->isInRoot()Z

    move-result v9

    if-eqz v9, :cond_7

    .line 728
    const/4 v9, 0x4

    const/16 v10, 0x5c

    invoke-static {v9, v10}, Lcom/esmertec/android/jbed/util/I18N;->getStringID(II)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v6

    .line 729
    .local v6, "resourceId":Ljava/lang/Integer;
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v9

    invoke-virtual {v9}, Landroid/widget/ListView;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-virtual {v9}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v9

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v9, v10}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {p0, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setTitle(Ljava/lang/CharSequence;)V

    .line 736
    .end local v6    # "resourceId":Ljava/lang/Integer;
    :cond_4
    :goto_2
    sget-object v9, Lcom/esmertec/android/jbed/ams/AmsActivity;->sListOrderMap:Ljava/util/Map;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v10

    invoke-interface {v9, v10}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Comparator;

    .line 738
    .local v0, "comparator":Ljava/util/Comparator;, "Ljava/util/Comparator<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    if-nez v0, :cond_5

    .line 739
    const p1, 0x7f080044

    .line 740
    sget-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_ORDER:Ljava/util/Comparator;

    .line 743
    :cond_5
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v9

    if-eqz v9, :cond_6

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->isInRoot()Z

    move-result v9

    if-eqz v9, :cond_6

    .line 744
    sget-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_REVERSE_ORDER:Ljava/util/Comparator;

    .line 746
    :cond_6
    invoke-static {v5, v0}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 747
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->storeListOrderId(I)V

    .line 750
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    invoke-virtual {v9}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v8

    .line 751
    .local v8, "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v8}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_3
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_8

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 752
    .local v7, "runningMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v11, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v9, v10, v11}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v9

    const/4 v10, 0x1

    iput-boolean v10, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    .line 753
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v9

    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v11, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v9, v10, v11}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v9

    iget-boolean v10, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    iput-boolean v10, v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    goto :goto_3

    .line 732
    .end local v0    # "comparator":Ljava/util/Comparator;, "Ljava/util/Comparator<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .end local v7    # "runningMidlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v8    # "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_7
    iget-object v9, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {p0, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setTitle(Ljava/lang/CharSequence;)V

    goto :goto_2

    .line 756
    .restart local v0    # "comparator":Ljava/util/Comparator;, "Ljava/util/Comparator<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .restart local v8    # "runningMidlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_8
    new-instance v2, Lcom/esmertec/android/jbed/ams/FolderNameI18N;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;-><init>(Landroid/content/Context;)V

    .line 757
    .local v2, "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_9
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_b

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 758
    .local v4, "mildet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v9, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    const-string v10, "Download Games"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_c

    const/4 v9, 0x1

    invoke-virtual {v2, v9}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v9

    if-eqz v9, :cond_a

    const/4 v9, 0x1

    invoke-virtual {v2, v9}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/String;->length()I

    move-result v9

    if-nez v9, :cond_c

    .line 761
    :cond_a
    invoke-interface {v5, v4}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 772
    .end local v4    # "mildet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_b
    :goto_4
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    iput-object v5, v9, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    .line 773
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    invoke-virtual {v9}, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->notifyDataSetChanged()V

    .line 774
    const/4 v9, 0x1

    invoke-virtual {p0, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->onWindowFocusChanged(Z)V

    goto/16 :goto_0

    .line 764
    .restart local v4    # "mildet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_c
    iget-object v9, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    const-string v10, "Download Applications"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_9

    const/4 v9, 0x2

    invoke-virtual {v2, v9}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v9

    if-eqz v9, :cond_d

    const/4 v9, 0x2

    invoke-virtual {v2, v9}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/String;->length()I

    move-result v9

    if-nez v9, :cond_9

    .line 767
    :cond_d
    invoke-interface {v5, v4}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    goto :goto_4
.end method

.method private rotateScreen()V
    .locals 2

    .prologue
    .line 618
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    iget v0, v0, Landroid/content/res/Configuration;->orientation:I

    packed-switch v0, :pswitch_data_0

    .line 626
    const-string v0, "AmsActivity"

    const-string v1, "rotateScreen() get a un-recognize orientation"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 628
    :goto_0
    return-void

    .line 620
    :pswitch_0
    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setRequestedOrientation(I)V

    goto :goto_0

    .line 623
    :pswitch_1
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setRequestedOrientation(I)V

    goto :goto_0

    .line 618
    nop

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private showWarningDialog(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p1, "title"    # Ljava/lang/String;
    .param p2, "msg"    # Ljava/lang/String;

    .prologue
    .line 969
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v0, p1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0, p2}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 974
    return-void
.end method

.method private storeListOrderId(I)V
    .locals 2
    .param p1, "orderId"    # I

    .prologue
    .line 662
    const/4 v1, 0x0

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getPreferences(I)Landroid/content/SharedPreferences;

    move-result-object v1

    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v0

    .line 663
    .local v0, "editor":Landroid/content/SharedPreferences$Editor;
    const-string v1, "list.order"

    invoke-interface {v0, v1, p1}, Landroid/content/SharedPreferences$Editor;->putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;

    .line 665
    invoke-interface {v0}, Landroid/content/SharedPreferences$Editor;->commit()Z

    .line 666
    return-void
.end method


# virtual methods
.method public onContextItemSelected(Landroid/view/MenuItem;)Z
    .locals 1
    .param p1, "item"    # Landroid/view/MenuItem;

    .prologue
    .line 164
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    .line 165
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->onOptionsItemSelected(Landroid/view/MenuItem;)Z

    .line 166
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onContextItemSelected(Landroid/view/MenuItem;)Z

    move-result v0

    return v0
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 4
    .param p1, "icicle"    # Landroid/os/Bundle;

    .prologue
    .line 195
    const-string v1, "AmsActivity"

    const-string v2, "LIFECYCLE Ams onCreate"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 196
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onCreate(Landroid/os/Bundle;)V

    .line 199
    const/high16 v1, 0x7f030000

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setContentView(I)V

    .line 201
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/AmsListAdapter;-><init>(Landroid/content/Context;)V

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    .line 202
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    new-instance v2, Ljava/util/ArrayList;

    const/4 v3, 0x0

    invoke-direct {v2, v3}, Ljava/util/ArrayList;-><init>(I)V

    iput-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    .line 203
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->setListAdapter(Landroid/widget/ListAdapter;)V

    .line 207
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    const/high16 v2, 0x7f080000

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->findViewById(I)Landroid/view/View;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setEmptyView(Landroid/view/View;)V

    .line 208
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsActivity$2;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$2;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setOnItemClickListener(Landroid/widget/AdapterView$OnItemClickListener;)V

    .line 241
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsActivity$3;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$3;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setOnItemSelectedListener(Landroid/widget/AdapterView$OnItemSelectedListener;)V

    .line 274
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsActivity$4;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$4;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setOnCreateContextMenuListener(Landroid/view/View$OnCreateContextMenuListener;)V

    .line 289
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsActivity$5;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$5;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setOnKeyListener(Landroid/view/View$OnKeyListener;)V

    .line 326
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mPendingQueue:Ljava/util/ArrayList;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    new-instance v3, Lcom/esmertec/android/jbed/ams/AmsActivity$6;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$6;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-static {v2, v3}, Landroid/os/Message;->obtain(Landroid/os/Handler;Ljava/lang/Runnable;)Landroid/os/Message;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 332
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mRefreshReceiver:Landroid/content/BroadcastReceiver;

    new-instance v2, Landroid/content/IntentFilter;

    const-string v3, "android.intent.action.SYNC"

    invoke-direct {v2, v3}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 334
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271c

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 335
    .local v0, "msg":Landroid/os/Message;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v0}, Landroid/os/Handler;->sendMessage(Landroid/os/Message;)Z

    .line 338
    return-void
.end method

.method protected onCreateDialog(I)Landroid/app/Dialog;
    .locals 4
    .param p1, "id"    # I

    .prologue
    const v3, 0x7f050158

    const/4 v2, 0x1

    .line 632
    new-instance v0, Landroid/app/ProgressDialog;

    invoke-direct {v0, p0}, Landroid/app/ProgressDialog;-><init>(Landroid/content/Context;)V

    .line 633
    .local v0, "dialog":Landroid/app/ProgressDialog;
    packed-switch p1, :pswitch_data_0

    .line 654
    :goto_0
    return-object v0

    .line 635
    :pswitch_0
    const/16 v1, 0x64

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setMax(I)V

    .line 636
    invoke-virtual {v0, v2}, Landroid/app/ProgressDialog;->setProgressStyle(I)V

    .line 637
    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 638
    invoke-virtual {v0, v2}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    .line 639
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsActivity$9;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$9;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)V

    .line 646
    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInstallDialog:Landroid/app/ProgressDialog;

    goto :goto_0

    .line 649
    :pswitch_1
    invoke-virtual {v0, v2}, Landroid/app/ProgressDialog;->setIndeterminate(Z)V

    .line 650
    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 651
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    goto :goto_0

    .line 633
    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_1
    .end packed-switch
.end method

.method public onCreateOptionsMenu(Landroid/view/Menu;)Z
    .locals 2
    .param p1, "menu"    # Landroid/view/Menu;

    .prologue
    .line 427
    const-string v0, "AmsActivity"

    const-string v1, "Ams onCreateOptionsMenu"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 428
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getMenuInflater()Landroid/view/MenuInflater;

    move-result-object v0

    const/high16 v1, 0x7f070000

    invoke-virtual {v0, v1, p1}, Landroid/view/MenuInflater;->inflate(ILandroid/view/Menu;)V

    .line 429
    const/4 v0, 0x1

    return v0
.end method

.method protected onDestroy()V
    .locals 2

    .prologue
    .line 393
    const-string v0, "AmsActivity"

    const-string v1, "LIFECYCLE Ams onDestroy"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 394
    const/4 v0, 0x0

    sput-boolean v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasInitAmsClient:Z

    .line 395
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mRefreshReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 396
    invoke-super {p0}, Landroid/app/ListActivity;->onDestroy()V

    .line 397
    return-void
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 2
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    .line 670
    const/4 v0, 0x4

    if-ne p1, v0, :cond_1

    .line 672
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->isInRoot()Z

    move-result v0

    if-nez v0, :cond_0

    .line 673
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->loadListOrderId()I

    move-result v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->refreshList(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 674
    const/4 v0, 0x1

    .line 697
    :goto_0
    return v0

    .line 676
    :cond_0
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 678
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$10;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->start()V

    .line 697
    :cond_1
    invoke-super {p0, p1, p2}, Landroid/app/ListActivity;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v0

    goto :goto_0
.end method

.method public onOptionsItemSelected(Landroid/view/MenuItem;)Z
    .locals 12
    .param p1, "item"    # Landroid/view/MenuItem;

    .prologue
    const/4 v11, 0x0

    const/4 v10, 0x1

    const/4 v9, 0x0

    const-string v8, "\n"

    .line 482
    const/4 v2, 0x1

    .line 483
    .local v2, "isHandled":Z
    sget-boolean v6, Lcom/esmertec/android/jbed/ams/AmsActivity;->mJbedExiting:Z

    if-eqz v6, :cond_0

    move v6, v10

    .line 614
    :goto_0
    return v6

    .line 484
    :cond_0
    invoke-interface {p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v6

    packed-switch v6, :pswitch_data_0

    .line 611
    :pswitch_0
    const/4 v2, 0x0

    :cond_1
    :goto_1
    move v6, v2

    .line 614
    goto :goto_0

    .line 486
    :pswitch_1
    invoke-static {}, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasEnoughFreeMemory()Z

    move-result v6

    if-eqz v6, :cond_2

    .line 487
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v8, v8, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRunEvent(Ljava/lang/String;I)V

    goto :goto_1

    .line 489
    :cond_2
    const v6, 0x7f05006d

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v6

    const v7, 0x1040111

    invoke-virtual {p0, v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v7

    invoke-direct {p0, v6, v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->showWarningDialog(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_1

    .line 494
    :pswitch_2
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6, v9}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestListLocalInstall(Z)V

    goto :goto_1

    .line 497
    :pswitch_3
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->loadListOrderId()I

    move-result v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {p0, v6, v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->refreshList(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_1

    .line 500
    :pswitch_4
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInputFolderName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_1

    .line 503
    :pswitch_5
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requsetInputName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_1

    .line 506
    :pswitch_6
    iget-boolean v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    if-eqz v6, :cond_3

    .line 507
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveMultipleSelectEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    .line 510
    :goto_2
    iput-boolean v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    goto :goto_1

    .line 509
    :cond_3
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveMultipleSelectEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    goto :goto_2

    .line 513
    :pswitch_7
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6, v11}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestLaunchBrowser(Ljava/lang/String;)V

    goto :goto_1

    .line 516
    :pswitch_8
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v6

    if-eqz v6, :cond_4

    .line 517
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveFolderConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 519
    :cond_4
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 522
    :pswitch_9
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveAllConfirmEvent()V

    goto/16 :goto_1

    .line 525
    :pswitch_a
    iget-boolean v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    if-eqz v6, :cond_5

    .line 526
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveMultipleConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    .line 529
    :goto_3
    iput-boolean v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    goto/16 :goto_1

    .line 528
    :cond_5
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->isContextItemSelected:Z

    invoke-virtual {v6, v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveMultipleConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    goto :goto_3

    .line 532
    :pswitch_b
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestPermission(Ljava/lang/String;)V

    goto/16 :goto_1

    .line 535
    :pswitch_c
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInfoEvent(Ljava/lang/String;)V

    goto/16 :goto_1

    .line 538
    :pswitch_d
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestStartRunningMidletManager()V

    goto/16 :goto_1

    .line 541
    :pswitch_e
    new-instance v6, Lcom/esmertec/android/jbed/ams/AmsActivity$8;

    invoke-direct {v6, p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$8;-><init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/AmsActivity$8;->start()V

    goto/16 :goto_1

    .line 560
    :pswitch_f
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestShowAboutEvent()V

    goto/16 :goto_1

    .line 565
    :pswitch_10
    invoke-interface {p1}, Landroid/view/MenuItem;->getItemId()I

    move-result v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {p0, v6, v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->refreshList(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 568
    :pswitch_11
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestListCertificatesEvent()V

    goto/16 :goto_1

    .line 571
    :pswitch_12
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestUpdateEvent(Ljava/lang/String;)V

    goto/16 :goto_1

    .line 574
    :pswitch_13
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->rotateScreen()V

    goto/16 :goto_1

    .line 578
    :pswitch_14
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 579
    .local v0, "apnIntent":Landroid/content/Intent;
    const-string v6, "com.android.settings"

    const-string v7, "com.android.settings.ApnSettings"

    invoke-virtual {v0, v6, v7}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 580
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->startActivity(Landroid/content/Intent;)V

    goto/16 :goto_1

    .line 583
    .end local v0    # "apnIntent":Landroid/content/Intent;
    :pswitch_15
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v6

    invoke-virtual {p0, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getPreferences(I)Landroid/content/SharedPreferences;

    move-result-object v7

    const-string v8, "current.storage"

    invoke-interface {v7, v8, v9}, Landroid/content/SharedPreferences;->getInt(Ljava/lang/String;I)I

    move-result v7

    invoke-virtual {v6, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestStorageSetting(I)V

    goto/16 :goto_1

    .line 586
    :pswitch_16
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v6, :cond_1

    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v6

    if-nez v6, :cond_6

    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v6

    if-eqz v6, :cond_1

    .line 588
    :cond_6
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "Name : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 589
    .local v3, "msg":Ljava/lang/String;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "Vendor : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getVendorText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 590
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "Version : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getVersionText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 591
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "Size : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7, v11}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeText(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 592
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getDescription()Ljava/lang/String;

    move-result-object v4

    .line 593
    .local v4, "s":Ljava/lang/String;
    if-eqz v4, :cond_7

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "Description : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 594
    :cond_7
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInfoUrl()Ljava/lang/String;

    move-result-object v4

    .line 595
    if-eqz v4, :cond_8

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "Info URL : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 596
    :cond_8
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v6

    if-eqz v6, :cond_9

    .line 597
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_4
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v6

    if-ge v1, v6, :cond_9

    .line 598
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "MIDlet-"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    add-int/lit8 v7, v1, 0x1

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7, v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildren(I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v7

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 597
    add-int/lit8 v1, v1, 0x1

    goto :goto_4

    .line 602
    .end local v1    # "i":I
    :cond_9
    new-instance v5, Landroid/content/Intent;

    invoke-direct {v5}, Landroid/content/Intent;-><init>()V

    .line 603
    .local v5, "smsIntent":Landroid/content/Intent;
    const-string v6, "com.android.mms"

    const-string v7, "com.android.mms.ui.ComposeMessageActivity"

    invoke-virtual {v5, v6, v7}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 604
    const-string v6, "exit_on_sent"

    invoke-virtual {v5, v6, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 605
    const-string v6, "forwarded_message"

    invoke-virtual {v5, v6, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 606
    const-string v6, "sms_body"

    invoke-virtual {v5, v6, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 607
    invoke-virtual {p0, v5}, Lcom/esmertec/android/jbed/ams/AmsActivity;->startActivity(Landroid/content/Intent;)V

    goto/16 :goto_1

    .line 484
    nop

    :pswitch_data_0
    .packed-switch 0x7f080035
        :pswitch_3
        :pswitch_2
        :pswitch_7
        :pswitch_d
        :pswitch_a
        :pswitch_4
        :pswitch_11
        :pswitch_14
        :pswitch_13
        :pswitch_15
        :pswitch_f
        :pswitch_e
        :pswitch_0
        :pswitch_9
        :pswitch_0
        :pswitch_10
        :pswitch_0
        :pswitch_10
        :pswitch_10
        :pswitch_0
        :pswitch_5
        :pswitch_6
        :pswitch_1
        :pswitch_8
        :pswitch_c
        :pswitch_b
        :pswitch_12
        :pswitch_16
    .end packed-switch
.end method

.method protected onPause()V
    .locals 2

    .prologue
    .line 420
    const-string v0, "AmsActivity"

    const-string v1, "LIFECYCLE Ams onPause"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 421
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->disconnect()V

    .line 422
    invoke-super {p0}, Landroid/app/ListActivity;->onPause()V

    .line 423
    return-void
.end method

.method public onPrepareOptionsMenu(Landroid/view/Menu;)Z
    .locals 9
    .param p1, "menu"    # Landroid/view/Menu;

    .prologue
    const v8, 0x7f080036

    const/4 v7, 0x1

    const/4 v6, 0x0

    .line 439
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onPrepareOptionsMenu(Landroid/view/Menu;)Z

    .line 441
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mOptionMenu:Landroid/view/Menu;

    .line 442
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/ListView;->getAdapter()Landroid/widget/ListAdapter;

    move-result-object v3

    if-eqz v3, :cond_0

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/ListView;->getAdapter()Landroid/widget/ListAdapter;

    move-result-object v3

    invoke-interface {v3}, Landroid/widget/ListAdapter;->getCount()I

    move-result v3

    if-nez v3, :cond_2

    :cond_0
    move v0, v7

    .line 444
    .local v0, "isEmpty":Z
    :goto_0
    if-nez v0, :cond_3

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/ListView;->getSelectedItemPosition()I

    move-result v3

    const/4 v4, -0x1

    if-eq v3, v4, :cond_3

    move v1, v7

    .line 446
    .local v1, "isItemAvailable":Z
    :goto_1
    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->access$600(Landroid/view/Menu;)V

    .line 447
    const v3, 0x7f080034

    iget-boolean v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    invoke-interface {p1, v3, v4}, Landroid/view/Menu;->setGroupEnabled(IZ)V

    .line 448
    const v3, 0x7f080041

    if-nez v0, :cond_4

    move v4, v7

    :goto_2
    iget-boolean v5, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    and-int/2addr v4, v5

    invoke-interface {p1, v3, v4}, Landroid/view/Menu;->setGroupEnabled(IZ)V

    .line 450
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v3

    if-eqz v3, :cond_5

    .line 451
    invoke-interface {p1, v8}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v3

    invoke-interface {v3, v7}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    .line 457
    :goto_3
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v3

    if-eqz v3, :cond_1

    .line 458
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInputDevKeys:Ljava/lang/StringBuffer;

    invoke-virtual {v3}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "123"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_1

    .line 459
    invoke-interface {p1, v8}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v3

    invoke-interface {v3, v6}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    .line 460
    invoke-interface {p1, v8}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v3

    invoke-interface {v3, v6}, Landroid/view/MenuItem;->setVisible(Z)Landroid/view/MenuItem;

    .line 463
    :cond_1
    const v3, 0x7f080048

    iget-boolean v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mIsServiceConnected:Z

    and-int/2addr v4, v1

    invoke-interface {p1, v3, v4}, Landroid/view/Menu;->setGroupEnabled(IZ)V

    .line 465
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-static {v3, p1, v4, v5, v6}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->access$700(Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/view/Menu;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    .line 469
    const v3, 0x7f08003d

    invoke-interface {p1, v3}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v2

    .line 470
    .local v2, "itemRotate":Landroid/view/MenuItem;
    invoke-interface {v2}, Landroid/view/MenuItem;->isVisible()Z

    move-result v3

    if-eqz v3, :cond_6

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isRotationEnabled()Z

    move-result v3

    if-eqz v3, :cond_6

    move v3, v7

    :goto_4
    invoke-interface {v2, v3}, Landroid/view/MenuItem;->setVisible(Z)Landroid/view/MenuItem;

    .line 471
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInputDevKeys:Ljava/lang/StringBuffer;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mInputDevKeys:Ljava/lang/StringBuffer;

    invoke-virtual {v4}, Ljava/lang/StringBuffer;->length()I

    move-result v4

    invoke-virtual {v3, v6, v4}, Ljava/lang/StringBuffer;->delete(II)Ljava/lang/StringBuffer;

    .line 473
    return v7

    .end local v0    # "isEmpty":Z
    .end local v1    # "isItemAvailable":Z
    .end local v2    # "itemRotate":Landroid/view/MenuItem;
    :cond_2
    move v0, v6

    .line 442
    goto/16 :goto_0

    .restart local v0    # "isEmpty":Z
    :cond_3
    move v1, v6

    .line 444
    goto/16 :goto_1

    .restart local v1    # "isItemAvailable":Z
    :cond_4
    move v4, v6

    .line 448
    goto :goto_2

    .line 454
    :cond_5
    invoke-interface {p1, v8}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v3

    invoke-interface {v3, v6}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    goto :goto_3

    .restart local v2    # "itemRotate":Landroid/view/MenuItem;
    :cond_6
    move v3, v6

    .line 470
    goto :goto_4
.end method

.method protected onResume()V
    .locals 2

    .prologue
    .line 413
    const-string v0, "AmsActivity"

    const-string v1, "LIFECYCLE Ams onResume"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 414
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->connect()V

    .line 415
    invoke-super {p0}, Landroid/app/ListActivity;->onResume()V

    .line 416
    return-void
.end method

.method protected onStart()V
    .locals 2

    .prologue
    .line 401
    const-string v0, "AmsActivity"

    const-string v1, "LIFECYCLE Ams onStart"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 402
    invoke-super {p0}, Landroid/app/ListActivity;->onStart()V

    .line 403
    return-void
.end method

.method protected onStop()V
    .locals 2

    .prologue
    .line 407
    const-string v0, "AmsActivity"

    const-string v1, "LIFECYCLE Ams onStop"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 408
    invoke-super {p0}, Landroid/app/ListActivity;->onStop()V

    .line 409
    return-void
.end method

.method public onWindowFocusChanged(Z)V
    .locals 4
    .param p1, "hasFocus"    # Z

    .prologue
    const/4 v3, 0x0

    .line 171
    invoke-super {p0, p1}, Landroid/app/ListActivity;->onWindowFocusChanged(Z)V

    .line 172
    if-eqz p1, :cond_2

    .line 173
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    invoke-virtual {v1}, Landroid/widget/ListView;->requestFocusFromTouch()Z

    .line 174
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-lez v1, :cond_2

    .line 176
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v1, :cond_0

    .line 177
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v1, v3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 179
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-interface {v1, v2}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v0

    .line 180
    .local v0, "index":I
    const/4 v1, -0x1

    if-ne v0, v1, :cond_1

    move v0, v3

    .line 181
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/widget/ListView;->setSelection(I)V

    .line 185
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mListAdapter:Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 190
    .end local v0    # "index":I
    :cond_2
    return-void
.end method
