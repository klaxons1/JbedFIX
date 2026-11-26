.class public Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
.super Ljava/lang/Object;
.source "JbedService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ClientProxy"
.end annotation


# static fields
.field public static mSBUpdateMutex:Ljava/lang/Object;

.field public static requestSoftButtonUpdate:Z


# instance fields
.field private mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 377
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mSBUpdateMutex:Ljava/lang/Object;

    .line 379
    const/4 v0, 0x0

    sput-boolean v0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->requestSoftButtonUpdate:Z

    return-void
.end method

.method constructor <init>(Lcom/esmertec/android/jbed/app/IJbedClient;)V
    .locals 0
    .param p1, "jbedClient"    # Lcom/esmertec/android/jbed/app/IJbedClient;

    .prologue
    .line 383
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 384
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    .line 385
    return-void
.end method


# virtual methods
.method public finish()V
    .locals 3

    .prologue
    .line 392
    const-string v1, "jbedservice"

    const-string v2, " notify client to finish()"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 393
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    if-eqz v1, :cond_0

    .line 395
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/app/IJbedClient;->finish()V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 401
    :cond_0
    return-void

    .line 396
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 398
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call finish()"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .locals 3

    .prologue
    .line 423
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    if-eqz v1, :cond_0

    .line 425
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/app/IJbedClient;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    .line 431
    :goto_0
    return-object v1

    .line 426
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 428
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call getVideoClient()"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 431
    .end local v0    # "e":Landroid/os/RemoteException;
    :cond_0
    const/4 v1, 0x0

    goto :goto_0
.end method

.method public onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "leftButton"    # Ljava/lang/String;
    .param p2, "rightButton"    # Ljava/lang/String;

    .prologue
    .line 435
    sget-object v1, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mSBUpdateMutex:Ljava/lang/Object;

    monitor-enter v1

    .line 436
    const/4 v2, 0x1

    :try_start_0
    sput-boolean v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->requestSoftButtonUpdate:Z

    .line 437
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v2, :cond_0

    .line 439
    :try_start_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    invoke-interface {v2, p1, p2}, Lcom/esmertec/android/jbed/app/IJbedClient;->onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catch Landroid/os/RemoteException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 444
    :cond_0
    const/4 v2, 0x0

    :try_start_2
    sput-boolean v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->requestSoftButtonUpdate:Z

    .line 445
    sget-object v2, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mSBUpdateMutex:Ljava/lang/Object;

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 446
    monitor-exit v1

    .line 447
    return-void

    .line 440
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 441
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, "failed to call onSoftButtonChanged()"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 446
    .end local v0    # "e":Landroid/os/RemoteException;
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v2
.end method

.method public repaint(IIIIIIFF)V
    .locals 10
    .param p1, "clipLeft"    # I
    .param p2, "clipTop"    # I
    .param p3, "clipRight"    # I
    .param p4, "clipBottom"    # I
    .param p5, "width"    # I
    .param p6, "height"    # I
    .param p7, "pScale"    # F
    .param p8, "lScale"    # F

    .prologue
    .line 408
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    if-eqz v0, :cond_0

    .line 410
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->mJbedClient:Lcom/esmertec/android/jbed/app/IJbedClient;

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    move/from16 v6, p6

    move/from16 v7, p7

    move/from16 v8, p8

    invoke-interface/range {v0 .. v8}, Lcom/esmertec/android/jbed/app/IJbedClient;->repaint(IIIIIIFF)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 416
    :cond_0
    return-void

    .line 411
    :catch_0
    move-exception v0

    move-object v9, v0

    .line 413
    .local v9, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call repaint()"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public repaintAll()V
    .locals 9

    .prologue
    const/16 v3, 0x3fff

    const/4 v1, 0x0

    const/4 v5, -0x1

    const/4 v7, 0x0

    .line 419
    move-object v0, p0

    move v2, v1

    move v4, v3

    move v6, v5

    move v8, v7

    invoke-virtual/range {v0 .. v8}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->repaint(IIIIIIFF)V

    .line 420
    return-void
.end method
