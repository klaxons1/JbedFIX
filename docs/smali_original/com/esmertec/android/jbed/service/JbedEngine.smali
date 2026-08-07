.class public Lcom/esmertec/android/jbed/service/JbedEngine;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Lcom/esmertec/android/jbed/JbedConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;,
        Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;
    }
.end annotation


# static fields
.field private static final AIOC_POOL_INTERVAL:I = 0x1f4

.field private static final TAG:Ljava/lang/String; = "JbedEngine"

.field static VMCHANGE_ALLOW_MAPS:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field private mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

.field final mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

.field private mContext:Landroid/content/Context;

.field private mEventPending:Z

.field mHandler:Landroid/os/Handler;

.field public mIsRotating:Z

.field public mIsRunFromHome:Z

.field private mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

.field final mLifecycleListener:Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

.field private mRestartVM:Z

.field private mShutdownVM:Z

.field mVmChangeReason:I


# direct methods
.method static constructor <clinit>()V
    .locals 5

    .prologue
    const/16 v4, 0x8

    const/16 v3, 0x1f

    .line 89
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0, v4}, Ljava/util/HashMap;-><init>(I)V

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    .line 93
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x16

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 97
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 98
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 99
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 100
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    const/16 v1, 0x10

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 101
    return-void
.end method

.method public constructor <init>(Landroid/app/Service;)V
    .locals 1
    .param p1, "s"    # Landroid/app/Service;

    .prologue
    const/4 v0, 0x0

    .line 103
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 38
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mEventPending:Z

    .line 40
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mShutdownVM:Z

    .line 42
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mRestartVM:Z

    .line 52
    const/4 v0, 0x1

    iput v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    .line 170
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedEngine$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedEngine$2;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mLifecycleListener:Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    .line 181
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedEngine$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedEngine$3;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 105
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mContext:Landroid/content/Context;

    .line 108
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedEngine$1;

    invoke-direct {v0, p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine$1;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;Landroid/app/Service;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    .line 167
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    return-object v0
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 34
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    return-object p1
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object v0
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 34
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object p1
.end method

.method static synthetic access$1700(Lcom/esmertec/android/jbed/service/JbedEngine;IIIIII)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # I
    .param p2, "x2"    # I
    .param p3, "x3"    # I
    .param p4, "x4"    # I
    .param p5, "x5"    # I
    .param p6, "x6"    # I

    .prologue
    .line 34
    invoke-direct/range {p0 .. p6}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeScreenSizeChanged(IIIIII)V

    return-void
.end method

.method static synthetic access$1800(Lcom/esmertec/android/jbed/service/JbedEngine;)[Ljava/lang/String;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->getCommandLine()[Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$1900(Lcom/esmertec/android/jbed/service/JbedEngine;[Ljava/lang/String;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # [Ljava/lang/String;
    .param p2, "x2"    # I

    .prologue
    .line 34
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeInitializeSubsystems([Ljava/lang/String;I)V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/service/JbedEngine;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeAiocPoll()I

    move-result v0

    return v0
.end method

.method static synthetic access$2000(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeOnEnterRestartVMLoop()V

    return-void
.end method

.method static synthetic access$2100(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeJbedInitVmLifeCycle()V

    return-void
.end method

.method static synthetic access$2200(Lcom/esmertec/android/jbed/service/JbedEngine;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # I

    .prologue
    .line 34
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeJbedRequestState(I)V

    return-void
.end method

.method static synthetic access$2300(Lcom/esmertec/android/jbed/service/JbedEngine;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mShutdownVM:Z

    return v0
.end method

.method static synthetic access$2302(Lcom/esmertec/android/jbed/service/JbedEngine;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # Z

    .prologue
    .line 34
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mShutdownVM:Z

    return p1
.end method

.method static synthetic access$2400(Lcom/esmertec/android/jbed/service/JbedEngine;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mEventPending:Z

    return v0
.end method

.method static synthetic access$2402(Lcom/esmertec/android/jbed/service/JbedEngine;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # Z

    .prologue
    .line 34
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mEventPending:Z

    return p1
.end method

.method static synthetic access$2500(Lcom/esmertec/android/jbed/service/JbedEngine;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeJbedRun()I

    move-result v0

    return v0
.end method

.method static synthetic access$2600(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeOnExitRestartVMLoop()V

    return-void
.end method

.method static synthetic access$2700(Lcom/esmertec/android/jbed/service/JbedEngine;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mRestartVM:Z

    return v0
.end method

.method static synthetic access$2800(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeFinalizeSubsystems()V

    return-void
.end method

.method static synthetic access$2900(Lcom/esmertec/android/jbed/service/JbedEngine;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # Z

    .prologue
    .line 34
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine;->broadcastVmState(Z)V

    return-void
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->wakeUp()V

    return-void
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/service/JbedEngine;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # I

    .prologue
    .line 34
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeJbedDoRawEvent(I)V

    return-void
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/service/JbedEngine;II)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p1, "x1"    # I
    .param p2, "x2"    # I

    .prologue
    .line 34
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/service/JbedEngine;->requestVmState(II)V

    return-void
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/service/JbedEngine;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 34
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method private broadcastVmState(Z)V
    .locals 3
    .param p1, "isStarted"    # Z

    .prologue
    .line 390
    if-eqz p1, :cond_0

    const-string v2, "com.esmertec.android.jbed.action.VMSTARTED"

    move-object v0, v2

    .line 391
    .local v0, "action":Ljava/lang/String;
    :goto_0
    new-instance v1, Landroid/content/Intent;

    invoke-direct {v1, v0}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 392
    .local v1, "intent":Landroid/content/Intent;
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v1}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    .line 393
    return-void

    .line 390
    .end local v0    # "action":Ljava/lang/String;
    .end local v1    # "intent":Landroid/content/Intent;
    :cond_0
    const-string v2, "com.esmertec.android.jbed.action.VMSTOPPED"

    move-object v0, v2

    goto :goto_0
.end method

.method private getCommandLine()[Ljava/lang/String;
    .locals 5

    .prologue
    .line 369
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mContext:Landroid/content/Context;

    invoke-static {v2}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v1

    .line 370
    .local v1, "settings":Lcom/esmertec/android/jbed/JbedSettings;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getCommands()[Ljava/lang/String;

    move-result-object v0

    .line 372
    .local v0, "cmdLine":[Ljava/lang/String;
    const-string v2, "JbedEngine"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "jbed.settings="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 373
    return-object v0
.end method

.method private native nativeAiocPoll()I
.end method

.method private native nativeFinalizeSubsystems()V
.end method

.method private native nativeInitializePush()V
.end method

.method private native nativeInitializeSubsystems([Ljava/lang/String;I)V
.end method

.method private native nativeJbedDoRawEvent(I)V
.end method

.method private native nativeJbedInitVmLifeCycle()V
.end method

.method private native nativeJbedRequestState(I)V
.end method

.method private native nativeJbedRun()I
.end method

.method private native nativeOnEnterRestartVMLoop()V
.end method

.method private native nativeOnExitRestartVMLoop()V
.end method

.method private native nativeScreenSizeChanged(IIIIII)V
.end method

.method private requestVmState(II)V
    .locals 4
    .param p1, "newState"    # I
    .param p2, "newReason"    # I

    .prologue
    const-string v3, "JbedEngine"

    .line 349
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRotating:Z

    .line 350
    .local v0, "isRotating":Z
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRotating:Z

    .line 351
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    if-nez v1, :cond_1

    .line 366
    :cond_0
    :goto_0
    return-void

    .line 354
    :cond_1
    sget-object v1, Lcom/esmertec/android/jbed/service/JbedEngine;->VMCHANGE_ALLOW_MAPS:Ljava/util/Map;

    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    and-int/2addr v1, p2

    if-eqz v1, :cond_3

    .line 355
    if-eqz v0, :cond_2

    const/16 v1, 0x8

    if-eq p2, v1, :cond_0

    .line 358
    :cond_2
    iput p2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    .line 359
    const-string v1, "JbedEngine"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "requestVmState newState = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ",  newReason ="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 361
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeJbedRequestState(I)V

    .line 362
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->wakeUp()V

    goto :goto_0

    .line 364
    :cond_3
    const-string v1, "JbedEngine"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "ignore vm change request due to newReason "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " is not defined as subsequence of "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mVmChangeReason:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0
.end method

.method private sizeChangingDone()V
    .locals 2

    .prologue
    .line 379
    const-string v0, "JbedEngine"

    const-string v1, " sizeChanged has done!"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 380
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    monitor-enter v0

    .line 381
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v1}, Ljava/lang/Object;->notifyAll()V

    .line 382
    monitor-exit v0

    .line 383
    return-void

    .line 382
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method private vmStateChange(ZIII)Z
    .locals 6
    .param p1, "commit"    # Z
    .param p2, "oldState"    # I
    .param p3, "newState"    # I
    .param p4, "arg"    # I

    .prologue
    const/4 v5, 0x0

    const/4 v3, 0x1

    const-string v4, "JbedEngine"

    .line 558
    const/4 v0, 0x0

    .line 560
    .local v0, "res":Z
    if-eqz p1, :cond_2

    .line 561
    const-string v1, "JbedEngine"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Finished transition from state "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " to newstate "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "  reason "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v4, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 572
    if-nez p3, :cond_0

    .line 573
    const/4 v0, 0x1

    .line 574
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mShutdownVM:Z

    .line 575
    packed-switch p4, :pswitch_data_0

    .line 586
    :pswitch_0
    iput-boolean v5, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mRestartVM:Z

    .line 591
    :cond_0
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    monitor-enter v1

    .line 592
    const/4 v2, 0x3

    if-ne p3, v2, :cond_1

    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    iget-boolean v2, v2, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mIsVmInitialized:Z

    if-nez v2, :cond_1

    .line 593
    const-string v2, "JbedEngine"

    const-string v3, "wakeup main thread after vm has been started totally!!"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 594
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    const/4 v3, 0x1

    iput-boolean v3, v2, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mIsVmInitialized:Z

    .line 595
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 599
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeInitializePush()V

    .line 601
    :cond_1
    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 606
    :goto_1
    return v0

    .line 577
    :pswitch_1
    iput-boolean v5, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mShutdownVM:Z

    goto :goto_0

    .line 582
    :pswitch_2
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mRestartVM:Z

    goto :goto_0

    .line 601
    :catchall_0
    move-exception v2

    :try_start_1
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v2

    .line 603
    :cond_2
    const-string v1, "JbedEngine"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Starting transition from state "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " state "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v4, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_1

    .line 575
    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_1
        :pswitch_2
        :pswitch_2
        :pswitch_0
        :pswitch_0
        :pswitch_2
    .end packed-switch
.end method

.method private wakeUp()V
    .locals 2

    .prologue
    .line 336
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mEventPending:Z

    .line 337
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    if-eqz v0, :cond_0

    .line 338
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    monitor-enter v0

    .line 339
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v1}, Ljava/lang/Object;->notify()V

    .line 340
    monitor-exit v0

    .line 342
    :cond_0
    return-void

    .line 340
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method


# virtual methods
.method changeScreenifVmBackground(IIIII)V
    .locals 9
    .param p1, "viewWidth"    # I
    .param p2, "viewHeight"    # I
    .param p3, "bytesPerPixel"    # I
    .param p4, "viewFullScreenWidth"    # I
    .param p5, "viewFullScreenHeight"    # I

    .prologue
    .line 312
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    if-nez v0, :cond_0

    .line 314
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    const/4 v6, 0x1

    const/4 v7, 0x0

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    invoke-static/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1100(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;IIIIIZZ)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 320
    :cond_0
    :goto_0
    return-void

    .line 316
    :catch_0
    move-exception v0

    move-object v8, v0

    .line 317
    .local v8, "e":Ljava/lang/Exception;
    const-string v0, "JbedEngine"

    const-string v1, " Catched Exception!! changeScreenifVmBackground "

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0
.end method

.method public native nativeUpdateSystemTime()V
.end method

.method public requestVmBackground()V
    .locals 2

    .prologue
    .line 345
    const/4 v0, 0x2

    const/16 v1, 0x8

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/service/JbedEngine;->requestVmState(II)V

    .line 346
    return-void
.end method

.method public startVm(IIIIIZZ)Z
    .locals 9
    .param p1, "viewWidth"    # I
    .param p2, "viewHeight"    # I
    .param p3, "bytesPerPixel"    # I
    .param p4, "viewFullScreenWidth"    # I
    .param p5, "viewFullScreenHeight"    # I
    .param p6, "isRefreshViewSize"    # Z
    .param p7, "forceSizeChanged"    # Z

    .prologue
    .line 270
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    if-nez v0, :cond_3

    .line 271
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .line 273
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayPortraitWidth()I

    move-result v0

    if-eqz v0, :cond_1

    .line 274
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    iget v8, v0, Landroid/content/res/Configuration;->orientation:I

    .line 277
    .local v8, "orientation":I
    const/4 v0, 0x2

    if-ne v8, v0, :cond_2

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRunFromHome:Z

    if-nez v0, :cond_2

    .line 278
    sget p1, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewWidth:I

    .line 279
    sget p2, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewHeight:I

    .line 285
    :cond_0
    :goto_0
    move p4, p1

    .line 286
    move p5, p2

    .line 288
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRunFromHome:Z

    .line 291
    .end local v8    # "orientation":I
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    const/4 v6, 0x0

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    move/from16 v7, p7

    invoke-static/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1100(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;IIIIIZZ)V

    .line 294
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->startAndWait()V

    .line 295
    const/4 v0, 0x1

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->broadcastVmState(Z)V

    .line 296
    const/4 v0, 0x1

    .line 303
    :goto_1
    return v0

    .line 280
    .restart local v8    # "orientation":I
    :cond_2
    const/4 v0, 0x1

    if-ne v8, v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mIsRunFromHome:Z

    if-nez v0, :cond_0

    .line 281
    sget p1, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewWidth:I

    .line 282
    sget p2, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewHeight:I

    goto :goto_0

    .line 298
    .end local v8    # "orientation":I
    :cond_3
    if-eqz p6, :cond_4

    .line 299
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    const/4 v6, 0x1

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    move/from16 v7, p7

    invoke-static/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1100(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;IIIIIZZ)V

    .line 301
    const-string v0, "JbedEngine"

    const-string v1, " the vm is running! just to change the screen size!"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 303
    :cond_4
    const/4 v0, 0x0

    goto :goto_1
.end method

.method stopVmAndWait()V
    .locals 3

    .prologue
    .line 324
    const-string v0, "JbedEngine"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " requestVmDown mJbedThread="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 325
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    if-eqz v0, :cond_0

    .line 326
    const/4 v0, 0x0

    const/4 v1, -0x1

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/service/JbedEngine;->requestVmState(II)V

    .line 329
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine;->mJbedThread:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->join()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 332
    :cond_0
    :goto_0
    return-void

    .line 330
    :catch_0
    move-exception v0

    goto :goto_0
.end method

.method public updateSystemTime()V
    .locals 0

    .prologue
    .line 552
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/JbedEngine;->nativeUpdateSystemTime()V

    .line 553
    return-void
.end method
