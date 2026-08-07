.class Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
.super Lcom/esmertec/android/jbed/app/IJbedVideoClientListener$Stub;
.source "JbedMediaManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "VideoPlayerProxy"
.end annotation


# static fields
.field private static final FLAG:Ljava/lang/String; = "VideoPlayerProxy"

.field private static final OP_SET_DISPLAY_LOCATION:I = 0x194

.field private static final OP_SET_DISPLAY_SIZE:I = 0x195

.field private static final OP_SET_VIDEOREGION_LOCATION:I = 0x192

.field private static final OP_SET_VIDEOREGION_SIZE:I = 0x193


# instance fields
.field private mDataSource:Ljava/lang/String;

.field private mNativeContext:I

.field private mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

.field private mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

.field private needRestoreState:Z


# direct methods
.method public constructor <init>(ILjava/lang/String;Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V
    .locals 4
    .param p1, "naiveContext"    # I
    .param p2, "url"    # Ljava/lang/String;
    .param p3, "videoClient"    # Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .prologue
    .line 530
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClientListener$Stub;-><init>()V

    .line 526
    const/4 v2, 0x0

    iput-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->needRestoreState:Z

    .line 528
    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-direct {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;-><init>()V

    iput-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .line 532
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mNativeContext:I

    .line 533
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    .line 534
    iput-object p3, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .line 535
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    iput-object v3, v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    .line 538
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    invoke-interface {v2, p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V
    :try_end_0
    .catch Landroid/os/DeadObjectException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_1

    .line 544
    return-void

    .line 539
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 540
    .local v0, "e":Landroid/os/DeadObjectException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.setListener(), DeadObjectException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 541
    .end local v0    # "e":Landroid/os/DeadObjectException;
    :catch_1
    move-exception v2

    move-object v1, v2

    .line 542
    .local v1, "re":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.setListener(), RemoteException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    .prologue
    .line 512
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    .prologue
    .line 512
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->needRestoreState:Z

    return v0
.end method


# virtual methods
.method public getDataSource()Ljava/lang/String;
    .locals 1

    .prologue
    .line 754
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    return-object v0
.end method

.method public getNativeContext()I
    .locals 1

    .prologue
    .line 606
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mNativeContext:I

    return v0
.end method

.method public getPrepareDataMethod()I
    .locals 1

    .prologue
    .line 613
    const/4 v0, 0x0

    return v0
.end method

.method public getSnapshotFromCamera()[B
    .locals 4

    .prologue
    .line 575
    :try_start_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v2

    monitor-enter v2
    :try_end_0
    .catch Landroid/os/DeadObjectException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_1

    .line 576
    :try_start_1
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 577
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v3

    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 579
    :cond_0
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 580
    :try_start_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->getSnapshotFromCamera()[B
    :try_end_2
    .catch Landroid/os/DeadObjectException; {:try_start_2 .. :try_end_2} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_2 .. :try_end_2} :catch_1

    move-result-object v2

    return-object v2

    .line 579
    :catchall_0
    move-exception v3

    :try_start_3
    monitor-exit v2
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    :try_start_4
    throw v3
    :try_end_4
    .catch Landroid/os/DeadObjectException; {:try_start_4 .. :try_end_4} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_4 .. :try_end_4} :catch_1

    .line 581
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 582
    .local v0, "e":Landroid/os/DeadObjectException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.getSnapshotFromCamera(), DeadObjectException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 583
    .end local v0    # "e":Landroid/os/DeadObjectException;
    :catch_1
    move-exception v2

    move-object v1, v2

    .line 584
    .local v1, "re":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.getSnapshotFromCamera(), RemoteException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method public getSnapshotFromMedia()Landroid/graphics/Bitmap;
    .locals 4

    .prologue
    .line 564
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->getSnapshotFromMedia()Landroid/graphics/Bitmap;
    :try_end_0
    .catch Landroid/os/DeadObjectException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_1

    move-result-object v2

    return-object v2

    .line 565
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 566
    .local v0, "e":Landroid/os/DeadObjectException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.getFrameAt(), DeadObjectException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 567
    .end local v0    # "e":Landroid/os/DeadObjectException;
    :catch_1
    move-exception v2

    move-object v1, v2

    .line 568
    .local v1, "re":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.getFrameAt(), RemoteException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method public isCameraPlaying()Z
    .locals 2

    .prologue
    .line 559
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    const-string v1, "capture://video"

    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public onCompletion()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 758
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyCompletion(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    .line 759
    return-void
.end method

.method public onError(II)V
    .locals 1
    .param p1, "arg1"    # I
    .param p2, "arg2"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 762
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyError(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;II)V

    .line 763
    return-void
.end method

.method public onPrepared()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 766
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    .line 767
    return-void
.end method

.method public onSuspend(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    .locals 3
    .param p1, "state"    # Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .prologue
    .line 770
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    monitor-enter v0

    .line 775
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v1, v2, :cond_0

    .line 776
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .line 777
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .line 781
    :goto_0
    monitor-exit v0

    .line 782
    return-void

    .line 779
    :cond_0
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->needRestoreState:Z

    goto :goto_0

    .line 781
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public operation(IIIII)I
    .locals 10
    .param p1, "playerId"    # I
    .param p2, "opId"    # I
    .param p3, "param1"    # I
    .param p4, "param2"    # I
    .param p5, "param3"    # I

    .prologue
    const/4 v9, 0x5

    const/4 v1, 0x1

    const/4 v3, 0x0

    const-string v0, ","

    const-string v8, "JbedMediaManager"

    .line 618
    sparse-switch p2, :sswitch_data_0

    .line 707
    :cond_0
    :goto_0
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_7

    .line 708
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    invoke-interface/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->operation(IIIII)I
    :try_end_0
    .catch Landroid/os/DeadObjectException; {:try_start_0 .. :try_end_0} :catch_5
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_6
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_7

    move-result v0

    .line 720
    :goto_1
    return v0

    .line 620
    :sswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-nez v0, :cond_0

    .line 621
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    if-eqz v0, :cond_1

    move v0, v1

    goto :goto_1

    :cond_1
    move v0, v3

    goto :goto_1

    .line 625
    :sswitch_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput p3, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    goto :goto_0

    .line 628
    :sswitch_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v1, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    goto :goto_0

    .line 632
    :sswitch_3
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v3, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    goto :goto_0

    .line 635
    :sswitch_4
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v3, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 636
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 638
    :try_start_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V
    :try_end_1
    .catch Landroid/os/RemoteException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 639
    :catch_0
    move-exception v0

    move-object v7, v0

    .line 640
    .local v7, "re":Landroid/os/RemoteException;
    const-string v0, "JbedMediaManager"

    invoke-static {v8, v9}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "JbedMediaManager"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "updateLinstener failed RemoteException : "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v8, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 645
    .end local v7    # "re":Landroid/os/RemoteException;
    :sswitch_5
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v0, v1, p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->updateRegionViewRect(ZII)Z

    .line 646
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 648
    :try_start_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->updateRegionRect(Landroid/graphics/Rect;)V
    :try_end_2
    .catch Landroid/os/RemoteException; {:try_start_2 .. :try_end_2} :catch_1

    goto :goto_0

    .line 649
    :catch_1
    move-exception v0

    move-object v6, v0

    .line 650
    .local v6, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call mVideoClient.updateRegionRect()!"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 655
    .end local v6    # "e":Landroid/os/RemoteException;
    :sswitch_6
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v0, v3, p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->updateRegionViewRect(ZII)Z

    .line 656
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 658
    :try_start_3
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->updateRegionRect(Landroid/graphics/Rect;)V
    :try_end_3
    .catch Landroid/os/RemoteException; {:try_start_3 .. :try_end_3} :catch_2

    goto/16 :goto_0

    .line 659
    :catch_2
    move-exception v0

    move-object v6, v0

    .line 660
    .restart local v6    # "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call mVideoClient.updateRegionRect()!"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 665
    .end local v6    # "e":Landroid/os/RemoteException;
    :sswitch_7
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v0, v1, p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->updateDisplayViewRect(ZII)Z

    .line 666
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 668
    :try_start_4
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->updateDisplayRect(Landroid/graphics/Rect;)V
    :try_end_4
    .catch Landroid/os/RemoteException; {:try_start_4 .. :try_end_4} :catch_3

    goto/16 :goto_0

    .line 669
    :catch_3
    move-exception v0

    move-object v6, v0

    .line 670
    .restart local v6    # "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call mVideoClient.updateDisplayRect()!"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 675
    .end local v6    # "e":Landroid/os/RemoteException;
    :sswitch_8
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v0, v3, p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->updateDisplayViewRect(ZII)Z

    .line 676
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 678
    :try_start_5
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->updateDisplayRect(Landroid/graphics/Rect;)V
    :try_end_5
    .catch Landroid/os/RemoteException; {:try_start_5 .. :try_end_5} :catch_4

    goto/16 :goto_0

    .line 679
    :catch_4
    move-exception v0

    move-object v6, v0

    .line 680
    .restart local v6    # "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call mVideoClient.updateDisplayRect()!"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 685
    .end local v6    # "e":Landroid/os/RemoteException;
    :sswitch_9
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    if-ne p3, v1, :cond_4

    :goto_2
    iput-boolean v1, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    .line 689
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    if-eqz v0, :cond_0

    .line 690
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    monitor-enter v0

    .line 691
    :try_start_6
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    if-eqz v1, :cond_2

    .line 692
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 694
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v1, v2, :cond_3

    .line 695
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    if-eqz v1, :cond_5

    .line 696
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->restoreState()V

    .line 702
    :cond_3
    :goto_3
    monitor-exit v0

    goto/16 :goto_0

    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_0

    throw v1

    :cond_4
    move v1, v3

    .line 685
    goto :goto_2

    .line 698
    :cond_5
    :try_start_7
    const-string v1, "JbedMediaManager"

    const/4 v2, 0x5

    invoke-static {v1, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_6

    const-string v1, "JbedMediaManager"

    const-string v2, "need restore State, but mVideoClient is null! Restore state after client is attached!"

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 699
    :cond_6
    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->needRestoreState:Z
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_0

    goto :goto_3

    .line 710
    :cond_7
    :try_start_8
    const-string v0, "JbedMediaManager"

    const/4 v1, 0x5

    invoke-static {v0, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_8

    const-string v0, "JbedMediaManager"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "mVideoClient is null! ingore operation: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ","

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_8
    .catch Landroid/os/DeadObjectException; {:try_start_8 .. :try_end_8} :catch_5
    .catch Landroid/os/RemoteException; {:try_start_8 .. :try_end_8} :catch_6
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_8} :catch_7

    :cond_8
    move v0, v3

    .line 711
    goto/16 :goto_1

    .line 713
    :catch_5
    move-exception v0

    move-object v6, v0

    .line 715
    .local v6, "e":Landroid/os/DeadObjectException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, " failed to call jbedVideoPlayer.operation() "

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 716
    .end local v6    # "e":Landroid/os/DeadObjectException;
    :catch_6
    move-exception v0

    move-object v7, v0

    .line 717
    .restart local v7    # "re":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, " failed to call jbedVideoPlayer.operation(), RemoteException"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 718
    .end local v7    # "re":Landroid/os/RemoteException;
    :catch_7
    move-exception v0

    move-object v6, v0

    .line 719
    .local v6, "e":Ljava/lang/Exception;
    const-string v0, "JbedMediaManager"

    invoke-static {v8, v9}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_9

    const-string v0, "JbedMediaManager"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "operation throw exception : "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v8, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 720
    :cond_9
    const/4 v0, -0x2

    goto/16 :goto_1

    .line 618
    :sswitch_data_0
    .sparse-switch
        0x2 -> :sswitch_4
        0x3 -> :sswitch_2
        0x4 -> :sswitch_3
        0x5 -> :sswitch_3
        0x8 -> :sswitch_1
        0x192 -> :sswitch_5
        0x193 -> :sswitch_6
        0x194 -> :sswitch_7
        0x195 -> :sswitch_8
        0x196 -> :sswitch_9
        0x3e9 -> :sswitch_0
    .end sparse-switch
.end method

.method public prepareData()V
    .locals 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 742
    const/4 v2, -0x1

    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    invoke-interface {v3, v4}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->prepareData(Ljava/lang/String;)I

    move-result v3

    if-ne v2, v3, :cond_0

    .line 743
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, "Open Camera failed!"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2
    :try_end_0
    .catch Landroid/os/DeadObjectException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_1

    .line 745
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 747
    .local v0, "e":Landroid/os/DeadObjectException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.prepareData() "

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 748
    .end local v0    # "e":Landroid/os/DeadObjectException;
    :catch_1
    move-exception v2

    move-object v1, v2

    .line 749
    .local v1, "re":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, " failed to call jbedVideoPlayer.prepareData(), RemoteException"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 751
    .end local v1    # "re":Landroid/os/RemoteException;
    :cond_0
    return-void
.end method

.method public reconnectCamera()V
    .locals 6

    .prologue
    const/4 v5, 0x5

    const-string v4, "JbedMediaManager"

    .line 591
    :try_start_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v2

    monitor-enter v2
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/NullPointerException; {:try_start_0 .. :try_end_0} :catch_1

    .line 592
    :try_start_1
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 593
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v3

    invoke-virtual {p0, v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 595
    :cond_0
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 596
    :try_start_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->reconnectCamera()V
    :try_end_2
    .catch Landroid/os/RemoteException; {:try_start_2 .. :try_end_2} :catch_0
    .catch Ljava/lang/NullPointerException; {:try_start_2 .. :try_end_2} :catch_1

    .line 603
    :cond_1
    :goto_0
    return-void

    .line 595
    :catchall_0
    move-exception v3

    :try_start_3
    monitor-exit v2
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    :try_start_4
    throw v3
    :try_end_4
    .catch Landroid/os/RemoteException; {:try_start_4 .. :try_end_4} :catch_0
    .catch Ljava/lang/NullPointerException; {:try_start_4 .. :try_end_4} :catch_1

    .line 598
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 599
    .local v1, "re":Landroid/os/RemoteException;
    const-string v2, "JbedMediaManager"

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_1

    const-string v2, "JbedMediaManager"

    const-string v2, "reconnect Camera failed !!!"

    invoke-static {v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 600
    .end local v1    # "re":Landroid/os/RemoteException;
    :catch_1
    move-exception v2

    move-object v0, v2

    .line 601
    .local v0, "ex":Ljava/lang/NullPointerException;
    const-string v2, "JbedMediaManager"

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_1

    const-string v2, "JbedMediaManager"

    const-string v2, "reconnect Camera failed !!!, NullPointerException"

    invoke-static {v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method public restoreState()V
    .locals 3

    .prologue
    .line 731
    :try_start_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 732
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->restorePlayerState(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V

    .line 733
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    .line 734
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->needRestoreState:Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 738
    return-void

    .line 735
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 736
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call jbedVideoPlayer.restorePlayer(), RemoteException"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 786
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "[VIDEO]0x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mNativeContext:I

    invoke-static {v1}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mDataSource:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " ASYNC_PREPAR_DATA"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V
    .locals 4
    .param p1, "videoClient"    # Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .prologue
    .line 548
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eq v1, p1, :cond_0

    .line 549
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .line 551
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    invoke-interface {v1, p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 556
    :cond_0
    :goto_0
    return-void

    .line 552
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 553
    .local v0, "re":Landroid/os/RemoteException;
    const-string v1, "JbedMediaManager"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "updateLinstener failed RemoteException : "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method
