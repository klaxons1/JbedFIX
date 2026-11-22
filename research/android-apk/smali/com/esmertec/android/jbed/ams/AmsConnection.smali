.class public Lcom/esmertec/android/jbed/ams/AmsConnection;
.super Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;
.source "AmsConnection.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;,
        Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
    }
.end annotation


# static fields
.field private static INSTANCE:Lcom/esmertec/android/jbed/ams/AmsConnection; = null

.field private static final TAG:Ljava/lang/String; = "AmsConnection"

.field private static final WAIT_JBED_CLEINT_MAX_COUNT:I = 0xa


# instance fields
.field private mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

.field private mAmsClientMutx:Ljava/lang/Object;

.field private mAmsEventFilters:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;",
            ">;"
        }
    .end annotation
.end field

.field public final mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

.field private mContext:Landroid/content/Context;

.field private mDefaultFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

.field private mEventQueue:Ljava/util/concurrent/BlockingQueue;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/BlockingQueue",
            "<",
            "Lcom/esmertec/android/jbed/ams/AmsEvent;",
            ">;"
        }
    .end annotation
.end field

.field private mHandler:Landroid/os/Handler;

.field private mJbedClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

.field private mJbedClientMutx:Ljava/lang/Object;

.field private mLifeCycleFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

.field private mPendingDrmConsraintRequest:Z

.field private mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/BlockingQueue",
            "<",
            "Lcom/esmertec/android/jbed/ams/AmsEvent;",
            ">;"
        }
    .end annotation
.end field

.field private mPendingRequestEventQueue:Ljava/util/concurrent/BlockingQueue;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/BlockingQueue",
            "<",
            "Lcom/esmertec/android/jbed/ams/AmsEvent;",
            ">;"
        }
    .end annotation
.end field

.field private mPowerOnMidlets:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field private mRequestPermissionFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

.field private mRequestPushFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

.field private mRunFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

.field private mRunningMidletList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field private tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;


# direct methods
.method public constructor <init>(Landroid/os/Handler;)V
    .locals 3
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 98
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;-><init>()V

    .line 44
    new-instance v0, Ljava/util/concurrent/LinkedBlockingQueue;

    invoke-direct {v0}, Ljava/util/concurrent/LinkedBlockingQueue;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mEventQueue:Ljava/util/concurrent/BlockingQueue;

    .line 46
    new-instance v0, Ljava/util/concurrent/LinkedBlockingQueue;

    invoke-direct {v0}, Ljava/util/concurrent/LinkedBlockingQueue;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    .line 48
    new-instance v0, Ljava/util/concurrent/LinkedBlockingQueue;

    invoke-direct {v0}, Ljava/util/concurrent/LinkedBlockingQueue;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingRequestEventQueue:Ljava/util/concurrent/BlockingQueue;

    .line 52
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    .line 53
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClientMutx:Ljava/lang/Object;

    .line 62
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 68
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingDrmConsraintRequest:Z

    .line 70
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    .line 75
    new-instance v0, Ljava/util/HashMap;

    const/16 v1, 0x8

    invoke-direct {v0, v1}, Ljava/util/HashMap;-><init>(I)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    .line 77
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$1;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 181
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$2;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mDefaultFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 199
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$3;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mLifeCycleFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 258
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$4;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 297
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$5;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRequestPermissionFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 337
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/AmsConnection$6;-><init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRequestPushFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 99
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mHandler:Landroid/os/Handler;

    .line 100
    sput-object p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->INSTANCE:Lcom/esmertec/android/jbed/ams/AmsConnection;

    .line 101
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/16 v1, 0x12

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mLifeCycleFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 102
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/16 v1, 0xb

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mLifeCycleFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 103
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/16 v1, 0x11

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mLifeCycleFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 105
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 106
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/16 v1, 0x33

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRequestPermissionFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 107
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    const/16 v1, 0x2b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRequestPushFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 108
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClientMutx:Ljava/lang/Object;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object v0
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/ams/AmsConnection;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->startJbedClientAndWait()V

    return-void
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 32
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object p1
.end method

.method static synthetic access$1100(Lcom/esmertec/android/jbed/ams/AmsConnection;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;
    .param p1, "x1"    # Z

    .prologue
    .line 32
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->startJbedClientAndWait(Z)V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    return-object v0
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .prologue
    .line 32
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    return-object p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    return-object v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/concurrent/BlockingQueue;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/ams/AmsConnection;II[B)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;
    .param p1, "x1"    # I
    .param p2, "x2"    # I
    .param p3, "x3"    # [B

    .prologue
    .line 32
    invoke-direct {p0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->handleMidletLifecycleEvent(II[B)V

    return-void
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/ams/AmsConnection;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->isBackgroundMode()Z

    move-result v0

    return v0
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->getAmsClientAndWait()Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsConnection;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPowerOnMidlets:Ljava/util/List;

    return-object v0
.end method

.method private static fetchEvent()Lcom/esmertec/android/jbed/ams/AmsEvent;
    .locals 4

    .prologue
    const-string v3, "AmsConnection"

    .line 130
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsConnection;->INSTANCE:Lcom/esmertec/android/jbed/ams/AmsConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsConnection;->mEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v1}, Ljava/util/concurrent/BlockingQueue;->poll()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsEvent;

    .line 131
    .local v0, "e":Lcom/esmertec/android/jbed/ams/AmsEvent;
    if-eqz v0, :cond_0

    .line 132
    const-string v1, "AmsConnection"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "fetchAmsEvent() "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsEvent;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 136
    :goto_0
    return-object v0

    .line 134
    :cond_0
    const-string v1, "AmsConnection"

    const-string v1, "There is no any event, who call the fetchAmsEvent()?"

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->amsWarning(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0
.end method

.method private getAmsClientAndWait()Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    .locals 4

    .prologue
    .line 242
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    monitor-enter v0

    .line 245
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    if-nez v1, :cond_0

    .line 246
    const-string v1, "AmsConnection"

    const-string v2, "getAmsClientAndWait() amsClient is null! wait 2\'s"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 248
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    const-wide/16 v2, 0x7d0

    invoke-virtual {v1, v2, v3}, Ljava/lang/Object;->wait(J)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 251
    :cond_0
    :goto_0
    :try_start_2
    monitor-exit v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 252
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    return-object v0

    .line 251
    :catchall_0
    move-exception v1

    :try_start_3
    monitor-exit v0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v1

    .line 249
    :catch_0
    move-exception v1

    goto :goto_0
.end method

.method private static handleEventEx(II[B)V
    .locals 1
    .param p0, "eventId"    # I
    .param p1, "result"    # I
    .param p2, "data"    # [B

    .prologue
    .line 143
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection;->INSTANCE:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-virtual {v0, p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->handleEvent(II[B)V

    .line 144
    return-void
.end method

.method private handleMidletLifecycleEvent(II[B)V
    .locals 6
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const/4 v5, 0x1

    .line 432
    if-nez p3, :cond_0

    .line 433
    new-instance v3, Ljava/lang/IllegalArgumentException;

    const-string v4, " data is empty for lifecycle event!!"

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 435
    :cond_0
    new-instance v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    new-instance v3, Ljava/lang/String;

    invoke-direct {v3, p3}, Ljava/lang/String;-><init>([B)V

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v1, v3, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;I)V

    .line 437
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/16 v3, 0x11

    if-ne p1, v3, :cond_1

    .line 438
    iput-boolean v5, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 439
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 440
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 443
    :cond_1
    const/16 v3, 0x12

    if-ne p1, v3, :cond_4

    .line 444
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_3

    .line 445
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 467
    :cond_2
    :goto_0
    return-void

    .line 447
    :cond_3
    const/4 v3, 0x0

    iput-boolean v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 448
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 449
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 452
    :cond_4
    const/16 v3, 0xb

    if-ne p1, v3, :cond_2

    .line 456
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v3

    if-eqz v3, :cond_6

    .line 457
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_5
    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_7

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 458
    .local v2, "tmp":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v4, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_5

    .line 459
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v2}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    goto :goto_1

    .line 463
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v2    # "tmp":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_6
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 465
    :cond_7
    iput-boolean v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingDrmConsraintRequest:Z

    goto :goto_0
.end method

.method private isBackgroundMode()Z
    .locals 2

    .prologue
    .line 517
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mContext:Landroid/content/Context;

    invoke-static {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v0

    .line 518
    .local v0, "settings":Lcom/esmertec/android/jbed/JbedSettings;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedSettings;->isNativeAms()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedSettings;->isRunTck()Z

    move-result v1

    if-eqz v1, :cond_1

    :cond_0
    const/4 v1, 0x1

    :goto_0
    return v1

    :cond_1
    const/4 v1, 0x0

    goto :goto_0
.end method

.method private startJbedClientAndWait()V
    .locals 1

    .prologue
    .line 166
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isSupportSoftKeyboard()Z

    move-result v0

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->startJbedClientAndWait(Z)V

    .line 167
    return-void
.end method

.method private startJbedClientAndWait(Z)V
    .locals 5
    .param p1, "hasSoftKeyboard"    # Z

    .prologue
    const-string v1, "AmsConnection"

    .line 147
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClientMutx:Ljava/lang/Object;

    monitor-enter v1

    .line 148
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    if-nez v2, :cond_0

    .line 149
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 150
    .local v0, "jbedIntent":Landroid/content/Intent;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mContext:Landroid/content/Context;

    invoke-virtual {v4}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ".app.JbedAppActivity"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v2, v3}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 151
    const/high16 v2, 0x10000000

    invoke-virtual {v0, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 152
    const-string v2, "isFullScreen"

    if-nez p1, :cond_1

    const/4 v3, 0x1

    :goto_0
    invoke-virtual {v0, v2, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 154
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 155
    const-string v2, "AmsConnection"

    const-string v3, "startJbedClientAndWait(): block vm to wait the jbedclient ready!"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 157
    :try_start_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mJbedClientMutx:Ljava/lang/Object;

    invoke-virtual {v2}, Ljava/lang/Object;->wait()V

    .line 158
    const-string v2, "AmsConnection"

    const-string v3, "startJbedClientAndWait(): wakeup vm to since jbedclient is ready!"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 162
    .end local v0    # "jbedIntent":Landroid/content/Intent;
    :cond_0
    :goto_1
    :try_start_2
    monitor-exit v1

    .line 163
    return-void

    .line 152
    .restart local v0    # "jbedIntent":Landroid/content/Intent;
    :cond_1
    const/4 v3, 0x0

    goto :goto_0

    .line 162
    .end local v0    # "jbedIntent":Landroid/content/Intent;
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v2

    .line 159
    .restart local v0    # "jbedIntent":Landroid/content/Intent;
    :catch_0
    move-exception v2

    goto :goto_1
.end method


# virtual methods
.method public getRunningMidletList()Ljava/util/List;
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
    .line 513
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mRunningMidletList:Ljava/util/List;

    return-object v0
.end method

.method public handleEvent(II[B)V
    .locals 5
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const-string v4, "AmsConnection"

    .line 409
    const-string v2, "AmsConnection"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "handleEvent() "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    new-instance v3, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v3, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsEvent;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " mAmsClient="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 412
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsEventFilters:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 413
    .local v1, "filter":Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;
    if-nez v1, :cond_0

    .line 414
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mDefaultFilter:Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;

    .line 418
    :cond_0
    invoke-interface {v1, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;->onEvent(II[B)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 429
    :cond_1
    :goto_0
    return-void

    .line 422
    :cond_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    if-eqz v2, :cond_1

    .line 424
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    invoke-interface {v2, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->handleEvent(II[B)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 425
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 426
    .local v0, "e":Landroid/os/RemoteException;
    const-string v2, "AmsConnection"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " faile to handle the ams event "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method public onClientConnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V
    .locals 5
    .param p1, "client"    # Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 470
    if-nez p1, :cond_0

    .line 471
    new-instance v1, Ljava/lang/IllegalArgumentException;

    const-string v2, "onClientConnected() pass a invalid client !!"

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 473
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    monitor-enter v1

    .line 474
    :try_start_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    .line 475
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClientMutx:Ljava/lang/Object;

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 476
    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 477
    const/4 v0, 0x0

    .line 478
    .local v0, "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v1}, Ljava/util/concurrent/BlockingQueue;->poll()Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsEvent;

    .restart local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    if-eqz v0, :cond_1

    .line 479
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    iget v2, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    iget v3, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-interface {v1, v2, v3, v4}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->handleEvent(II[B)V

    goto :goto_0

    .line 476
    .end local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    :catchall_0
    move-exception v2

    :try_start_1
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v2

    .line 482
    .restart local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    :cond_1
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->isBackgroundMode()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 484
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->requestBackground()V

    .line 487
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->finish()V

    .line 489
    :cond_2
    return-void
.end method

.method public onClientDisconnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V
    .locals 5
    .param p1, "client"    # Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 493
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    if-eqz v1, :cond_0

    .line 494
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->getId()J

    move-result-wide v1

    invoke-interface {p1}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->getId()J

    move-result-wide v3

    cmp-long v1, v1, v3

    if-nez v1, :cond_1

    .line 495
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    .line 502
    :cond_0
    :goto_0
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingDrmConsraintRequest:Z

    if-eqz v1, :cond_2

    .line 503
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingDrmConsraintRequest:Z

    .line 504
    const/4 v0, 0x0

    .line 505
    .local v0, "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    :goto_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingRequestEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v1}, Ljava/util/concurrent/BlockingQueue;->poll()Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsEvent;

    .restart local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    if-eqz v0, :cond_2

    .line 506
    iget v1, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    iget v2, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iget-object v3, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-virtual {p0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->requestEvent(II[B)V

    goto :goto_1

    .line 498
    .end local v0    # "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    :cond_1
    const-string v1, "AmsConnection"

    const-string v2, " WARNNING : The connection has been connect to other client! so do nothing!"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 510
    :cond_2
    return-void
.end method

.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 114
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mContext:Landroid/content/Context;

    .line 115
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 121
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v0}, Ljava/util/concurrent/BlockingQueue;->clear()V

    .line 122
    return-void
.end method

.method public requestEvent(II[B)V
    .locals 8
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    const/4 v2, 0x2

    const/4 v4, 0x1

    const/4 v5, 0x0

    const-string v7, "AmsConnection"

    .line 375
    if-ne p1, v2, :cond_0

    .line 376
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v2, v3, :cond_2

    .line 377
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 391
    :cond_0
    const/16 v2, 0x2b

    if-ne p1, v2, :cond_1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v2, v3, :cond_1

    .line 392
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 394
    :cond_1
    const/16 v2, 0x43

    if-ne p1, v2, :cond_3

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingDrmConsraintRequest:Z

    if-ne v2, v4, :cond_3

    .line 395
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPendingRequestEventQueue:Ljava/util/concurrent/BlockingQueue;

    new-instance v3, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v3, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    invoke-interface {v2, v3}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 404
    :goto_0
    return-void

    .line 378
    :cond_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->tokenHolder:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v2, v3, :cond_0

    .line 380
    const/16 v0, 0x2710

    .line 382
    .local v0, "IGNORE_RUN_RESULT":I
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mAmsClient:Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    const/4 v3, 0x2

    const/4 v4, 0x1

    new-array v4, v4, [B

    const/4 v5, 0x0

    const/16 v6, 0x20

    aput-byte v6, v4, v5

    invoke-interface {v2, v3, v0, v4}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->handleEvent(II[B)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 386
    :goto_1
    const-string v2, "AmsConnection"

    const-string v2, "ingore EVENT_RUN since PUSH_REQUEST_HOLD get the token"

    invoke-static {v7, v2}, Lcom/esmertec/android/jbed/LogTag;->amsWarning(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 383
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 384
    .local v1, "e":Landroid/os/RemoteException;
    const-string v2, "AmsConnection"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " faile to handle the ams event "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v7, v2, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_1

    .line 398
    .end local v0    # "IGNORE_RUN_RESULT":I
    .end local v1    # "e":Landroid/os/RemoteException;
    :cond_3
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v1, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    .line 400
    .local v1, "e":Lcom/esmertec/android/jbed/ams/AmsEvent;
    const-string v2, "AmsConnection"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " deliverEventToJbedVm() "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v7, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 401
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v2, v1}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 403
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mHandler:Landroid/os/Handler;

    const/4 v3, 0x5

    const/16 v4, 0x29

    invoke-virtual {v2, v3, v4, v5}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v2

    invoke-virtual {v2}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0
.end method

.method public setPowerOnMidlets(Ljava/util/List;)V
    .locals 0
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
    .line 365
    .local p1, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection;->mPowerOnMidlets:Ljava/util/List;

    .line 366
    return-void
.end method
