.class public Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
.super Ljava/lang/Object;
.source "JbedLcduiManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
.implements Lcom/esmertec/android/jbed/JbedConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;
    }
.end annotation


# static fields
.field private static final DEBUG:Z = false

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager; = null

.field private static JbedLcduiKeyMap:Ljava/util/HashMap; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private static final TAG:Ljava/lang/String; = "JbedLcduiManager"

.field private static mIsPreviousKeyAtl:Z

.field private static mIsPreviousKeyShift:Z


# instance fields
.field private mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

.field public final mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field private mIsPendingRepaint:Z

.field private mSoftBar:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

.field public final mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;


# direct methods
.method static constructor <clinit>()V
    .locals 6

    .prologue
    const/4 v0, 0x0

    const/4 v5, -0x5

    const/4 v4, -0x6

    const/4 v3, -0x7

    .line 41
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyAtl:Z

    .line 43
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyShift:Z

    .line 80
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->nativeInitialization()V

    .line 82
    new-instance v0, Ljava/util/HashMap;

    const/16 v1, 0xa

    invoke-direct {v0, v1}, Ljava/util/HashMap;-><init>(I)V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    .line 83
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x13

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, -0x1

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 84
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x14

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, -0x2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 85
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x16

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, -0x4

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 86
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x15

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, -0x3

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 87
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x17

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 88
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x42

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 89
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x43

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, -0x8

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 90
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 91
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 95
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 2
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 219
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 76
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    const/4 v1, 0x0

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mSoftBar:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    .line 98
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .line 200
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 220
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mHandler:Landroid/os/Handler;

    .line 221
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .line 222
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .prologue
    .line 25
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object v0
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 25
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object p1
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .prologue
    .line 25
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .prologue
    .line 25
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->nativeMvmSwitchMideltList()V

    return-void
.end method

.method static synthetic access$400()Z
    .locals 1

    .prologue
    .line 25
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyAtl:Z

    return v0
.end method

.method static synthetic access$402(Z)Z
    .locals 0
    .param p0, "x0"    # Z

    .prologue
    .line 25
    sput-boolean p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyAtl:Z

    return p0
.end method

.method static synthetic access$500()Z
    .locals 1

    .prologue
    .line 25
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyShift:Z

    return v0
.end method

.method static synthetic access$502(Z)Z
    .locals 0
    .param p0, "x0"    # Z

    .prologue
    .line 25
    sput-boolean p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPreviousKeyShift:Z

    return p0
.end method

.method static synthetic access$600()Ljava/util/HashMap;
    .locals 1

    .prologue
    .line 25
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->JbedLcduiKeyMap:Ljava/util/HashMap;

    return-object v0
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .prologue
    .line 25
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPendingRepaint:Z

    return v0
.end method

.method static synthetic access$702(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
    .param p1, "x1"    # Z

    .prologue
    .line 25
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPendingRepaint:Z

    return p1
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .prologue
    .line 25
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mSoftBar:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    return-object v0
.end method

.method private static getFontSize()I
    .locals 1

    .prologue
    .line 270
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getFontSize()I

    move-result v0

    return v0
.end method

.method private static native nativeInitialization()V
.end method

.method private native nativeMvmSwitchMideltList()V
.end method

.method private static onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    .locals 5
    .param p0, "left"    # Ljava/lang/String;
    .param p1, "right"    # Ljava/lang/String;

    .prologue
    .line 249
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mSBUpdateMutex:Ljava/lang/Object;

    monitor-enter v1

    .line 252
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    sget-boolean v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->requestSoftButtonUpdate:Z

    if-eqz v2, :cond_0

    .line 253
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    sget-object v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mSBUpdateMutex:Ljava/lang/Object;

    invoke-virtual {v2}, Ljava/lang/Object;->wait()V

    .line 255
    :cond_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    const/4 v2, 0x0

    sput-boolean v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->requestSoftButtonUpdate:Z

    .line 256
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mSoftBar:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    invoke-virtual {v2, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 263
    :goto_0
    :try_start_1
    monitor-exit v1

    .line 264
    return-void

    .line 259
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 260
    .local v0, "ie":Ljava/lang/InterruptedException;
    const-string v2, "JbedLcduiManager"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "onSoftButtonChanged throw InterruptedException : "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 263
    .end local v0    # "ie":Ljava/lang/InterruptedException;
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v2
.end method

.method private static repaint(IIIIIIFF)V
    .locals 9
    .param p0, "clipLeft"    # I
    .param p1, "clipTop"    # I
    .param p2, "clipRight"    # I
    .param p3, "clipBottom"    # I
    .param p4, "width"    # I
    .param p5, "height"    # I
    .param p6, "pScale"    # F
    .param p7, "lScale"    # F

    .prologue
    .line 237
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    if-nez v0, :cond_0

    .line 238
    sget-object p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .end local p0    # "clipLeft":I
    const/4 p1, 0x1

    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mIsPendingRepaint:Z

    .line 242
    .end local p1    # "clipTop":I
    :goto_0
    return-void

    .line 240
    .restart local p0    # "clipLeft":I
    .restart local p1    # "clipTop":I
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move v1, p0

    move v2, p1

    move v3, p2

    move v4, p3

    move v5, p4

    move v6, p5

    move v7, p6

    move/from16 v8, p7

    invoke-virtual/range {v0 .. v8}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->repaint(IIIIIIFF)V

    goto :goto_0
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 225
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mContext:Landroid/content/Context;

    .line 226
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 229
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    .line 230
    return-void
.end method
