.class public Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;
.super Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;
.source "JbedVideoClientImpl.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;
    }
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z

.field private static final DEBUG:Z = false

.field public static final OP_CLOSE:I = 0x2

.field public static final OP_DRAIN:I = 0xc

.field public static final OP_GETCHUNKSIZE:I = 0xb

.field public static final OP_GETDURATION:I = 0x6

.field public static final OP_GETMEDIATYPE:I = 0x10

.field public static final OP_GETMETADATA:I = 0x12

.field public static final OP_GETPOSITION:I = 0x7

.field public static final OP_GETRECSIZE:I = 0xd

.field public static final OP_GETSUPPORTEDCONTROLS:I = 0x11

.field public static final OP_GETVOLUME:I = 0x9

.field private static final OP_GET_SOURCE_HEIGHT:I = 0x190

.field private static final OP_GET_SOURCE_WIDTH:I = 0x191

.field public static final OP_ISPLAYING:I = 0x3e9

.field public static final OP_PAUSE:I = 0x4

.field public static final OP_PAUSERECORD:I = 0x17

.field public static final OP_PLAY:I = 0x3

.field public static final OP_RELEASEDEVICE:I = 0xf

.field public static final OP_RESET:I = 0x1

.field public static final OP_SETDATASIZE:I = 0xe

.field public static final OP_SETPOSITION:I = 0x8

.field public static final OP_SETVOLUME:I = 0xa

.field private static final OP_SET_DISPLAY_LOCATION:I = 0x194

.field private static final OP_SET_DISPLAY_SIZE:I = 0x195

.field private static final OP_SET_VIDEOREGION_LOCATION:I = 0x192

.field private static final OP_SET_VIDEOREGION_SIZE:I = 0x193

.field private static final OP_SET_VISIBLE:I = 0x196

.field public static final OP_STARTRECORD:I = 0x16

.field public static final OP_STOP:I = 0x5

.field public static final OP_STOPRECORD:I = 0x18

.field public static final RC_ERROR_COMMAND_IGNORED:I = -0x2

.field public static final RC_ERROR_OPERATION_FAILED:I = -0x1

.field public static final RC_OK:I = 0x0

.field private static final TAG:Ljava/lang/String; = "JbedVideoClientImpl"

.field private static final VIDEO_RECORD_PROTOCOL:Ljava/lang/String; = "capture://video"


# instance fields
.field private mCaptureDataStream:Ljava/io/OutputStream;

.field private mFrameParent:Landroid/view/View;

.field private mHandler:Landroid/os/Handler;

.field private mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

.field private mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

.field private mSurface:Landroid/view/Surface;

.field private mVideoHolder:Landroid/view/SurfaceHolder;

.field private mVideoParent:Landroid/view/View;

.field private mVideoRegionView:Landroid/widget/AbsoluteLayout;

.field private mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 36
    const-class v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->$assertionsDisabled:Z

    return-void

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public constructor <init>(Landroid/os/Handler;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/View;Landroid/view/View;)V
    .locals 2
    .param p1, "handler"    # Landroid/os/Handler;
    .param p2, "videoRegionView"    # Landroid/widget/AbsoluteLayout;
    .param p3, "videoView"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p4, "videoParent"    # Landroid/view/View;
    .param p5, "frameParent"    # Landroid/view/View;

    .prologue
    .line 305
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;-><init>()V

    .line 308
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    .line 309
    iput-object p3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .line 310
    iput-object p2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoRegionView:Landroid/widget/AbsoluteLayout;

    .line 311
    iput-object p4, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoParent:Landroid/view/View;

    .line 312
    iput-object p5, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mFrameParent:Landroid/view/View;

    .line 314
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    invoke-interface {v0}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mSurface:Landroid/view/Surface;

    .line 315
    invoke-static {}, Landroid/view/Surface;->openTransaction()V

    .line 320
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mSurface:Landroid/view/Surface;

    const/16 v1, 0x3ea

    invoke-virtual {v0, v1}, Landroid/view/Surface;->setLayer(I)V

    .line 321
    invoke-static {}, Landroid/view/Surface;->closeTransaction()V

    .line 323
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .line 324
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/view/View;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    .prologue
    .line 36
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoParent:Landroid/view/View;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/view/View;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    .prologue
    .line 36
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mFrameParent:Landroid/view/View;

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    .prologue
    .line 36
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/widget/AbsoluteLayout;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    .prologue
    .line 36
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoRegionView:Landroid/widget/AbsoluteLayout;

    return-object v0
.end method

.method private declared-synchronized setVisible(Z)V
    .locals 2
    .param p1, "isVisible"    # Z

    .prologue
    .line 341
    monitor-enter p0

    :try_start_0
    sget-boolean v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->$assertionsDisabled:Z

    if-nez v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mSurface:Landroid/view/Surface;

    if-nez v0, :cond_0

    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0}, Ljava/lang/AssertionError;-><init>()V

    throw v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0

    .line 342
    :cond_0
    if-eqz p1, :cond_1

    .line 343
    :try_start_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoRegionView:Landroid/widget/AbsoluteLayout;

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->updateViewRect(Landroid/view/View;)V

    .line 344
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->updateViewRect(Landroid/view/View;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 361
    :goto_0
    monitor-exit p0

    return-void

    .line 346
    :cond_1
    :try_start_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    new-instance v1, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;-><init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_0
.end method

.method private updateViewRect(Landroid/view/View;)V
    .locals 8
    .param p1, "v"    # Landroid/view/View;

    .prologue
    .line 569
    if-nez p1, :cond_0

    .line 570
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "view is null"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 572
    :cond_0
    instance-of v0, p1, Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    if-eqz v0, :cond_2

    .line 574
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    if-eqz v0, :cond_1

    .line 575
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v4, v1, Landroid/graphics/Rect;->left:I

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v5, v1, Landroid/graphics/Rect;->top:I

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->width()I

    move-result v6

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->height()I

    move-result v7

    move-object v1, p0

    move-object v2, p1

    invoke-direct/range {v0 .. v7}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;-><init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;Landroid/view/View;Landroid/os/Handler;IIII)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->update()V

    .line 591
    :cond_1
    :goto_0
    return-void

    .line 583
    :cond_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    if-eqz v0, :cond_1

    .line 584
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v4, v1, Landroid/graphics/Rect;->left:I

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v5, v1, Landroid/graphics/Rect;->top:I

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->width()I

    move-result v6

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->height()I

    move-result v7

    move-object v1, p0

    move-object v2, p1

    invoke-direct/range {v0 .. v7}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;-><init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;Landroid/view/View;Landroid/os/Handler;IIII)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->update()V

    goto :goto_0
.end method


# virtual methods
.method public getSnapshotFromCamera()[B
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 509
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->takePicture()[B

    move-result-object v0

    return-object v0
.end method

.method public getSnapshotFromMedia()Landroid/graphics/Bitmap;
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 515
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getCurrentPosition()I

    move-result v1

    .line 516
    .local v1, "currentPos":I
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getFrameAt(I)Landroid/graphics/Bitmap;

    move-result-object v0

    .line 518
    .local v0, "bitmap":Landroid/graphics/Bitmap;
    return-object v0
.end method

.method public operation(IIIII)I
    .locals 4
    .param p1, "playerId"    # I
    .param p2, "opId"    # I
    .param p3, "param1"    # I
    .param p4, "param2"    # I
    .param p5, "param3"    # I

    .prologue
    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 400
    const/4 v0, 0x0

    .line 403
    .local v0, "ret":I
    sparse-switch p2, :sswitch_data_0

    .line 502
    const/4 v0, -0x1

    .line 505
    :cond_0
    :goto_0
    :sswitch_0
    return v0

    .line 407
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->seekTo(I)V

    goto :goto_0

    .line 412
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 415
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v1, :cond_1

    .line 417
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->closeCamera()V

    .line 422
    :goto_1
    invoke-direct {p0, v2}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->setVisible(Z)V

    goto :goto_0

    .line 420
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->stopPlayback()V

    goto :goto_1

    .line 425
    :sswitch_3
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v3, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 426
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-nez v1, :cond_0

    .line 427
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    new-instance v2, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$3;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$3;-><init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)V

    invoke-virtual {v1, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_0

    .line 435
    :sswitch_4
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 436
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->pause()V

    goto :goto_0

    .line 439
    :sswitch_5
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 440
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->pause()V

    .line 441
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->seekTo(I)V

    goto :goto_0

    .line 444
    :sswitch_6
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getDuration()I

    move-result v0

    .line 445
    goto :goto_0

    .line 447
    :sswitch_7
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getCurrentPosition()I

    move-result v0

    .line 448
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput v0, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    goto :goto_0

    .line 451
    :sswitch_8
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1, p3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->seekTo(I)V

    .line 452
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getCurrentPosition()I

    move-result v0

    .line 453
    goto :goto_0

    .line 455
    :sswitch_9
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v1, :cond_2

    .line 456
    const/4 v0, 0x1

    goto :goto_0

    .line 458
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->isPlaying()Z

    move-result v1

    if-eqz v1, :cond_3

    move v0, v3

    .line 460
    :goto_2
    goto :goto_0

    :cond_3
    move v0, v2

    .line 458
    goto :goto_2

    .line 463
    :sswitch_a
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v1, :cond_4

    .line 464
    const/16 v0, 0xb0

    goto/16 :goto_0

    .line 466
    :cond_4
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getVideoWidth()I

    move-result v0

    .line 468
    goto/16 :goto_0

    .line 470
    :sswitch_b
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v1, :cond_5

    .line 471
    const/16 v0, 0xdc

    goto/16 :goto_0

    .line 473
    :cond_5
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getVideoHeight()I

    move-result v0

    .line 475
    goto/16 :goto_0

    .line 484
    :sswitch_c
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    if-eqz p3, :cond_6

    move v2, v3

    :cond_6
    iput-boolean v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    .line 486
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->setVisible(Z)V

    goto/16 :goto_0

    .line 490
    :sswitch_d
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->startRecord()V

    goto/16 :goto_0

    .line 494
    :sswitch_e
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->stopRecord()V

    goto/16 :goto_0

    .line 498
    :sswitch_f
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->stopRecord()V

    goto/16 :goto_0

    .line 403
    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_1
        0x2 -> :sswitch_2
        0x3 -> :sswitch_3
        0x4 -> :sswitch_4
        0x5 -> :sswitch_5
        0x6 -> :sswitch_6
        0x7 -> :sswitch_7
        0x8 -> :sswitch_8
        0xf -> :sswitch_0
        0x16 -> :sswitch_d
        0x17 -> :sswitch_e
        0x18 -> :sswitch_f
        0x190 -> :sswitch_b
        0x191 -> :sswitch_a
        0x192 -> :sswitch_0
        0x193 -> :sswitch_0
        0x194 -> :sswitch_0
        0x195 -> :sswitch_0
        0x196 -> :sswitch_c
        0x3e9 -> :sswitch_9
    .end sparse-switch
.end method

.method public prepareData(Ljava/lang/String;)I
    .locals 7
    .param p1, "dataSource"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    const/4 v6, 0x1

    const/4 v4, 0x0

    const/4 v5, -0x1

    const-string v3, "capture://video"

    .line 364
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-object p1, v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    .line 366
    const-string v2, "capture://video"

    invoke-virtual {p1, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 367
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v6, v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    .line 368
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->openCamera()Z

    move-result v2

    if-nez v2, :cond_0

    move v2, v5

    .line 390
    :goto_0
    return v2

    .line 371
    :cond_0
    const-string v2, "capture://video"

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v2

    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v3

    invoke-virtual {p1, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 373
    .local v1, "subDataSource":Ljava/lang/String;
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setVideoRecordPath(Ljava/lang/String;)V

    move v2, v4

    .line 374
    goto :goto_0

    .line 377
    .end local v1    # "subDataSource":Ljava/lang/String;
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iput-boolean v4, v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    .line 379
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setVideoPath(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 384
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mHandler:Landroid/os/Handler;

    new-instance v3, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$2;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$2;-><init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)V

    invoke-virtual {v2, v3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    move v2, v6

    .line 390
    goto :goto_0

    .line 380
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 381
    .local v0, "ioe":Ljava/lang/Exception;
    const-string v2, "JbedVideoClientImpl"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "failed to setVideoPath("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ")"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v2, v5

    .line 382
    goto :goto_0
.end method

.method public reconnectCamera()V
    .locals 1

    .prologue
    .line 522
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->closeCamera()V

    .line 523
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->openCamera()Z

    .line 524
    return-void
.end method

.method public restorePlayerState(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    .locals 2
    .param p1, "state"    # Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .prologue
    .line 559
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .line 560
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->setVisible(Z)V

    .line 561
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resume(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V

    .line 562
    return-void
.end method

.method public savePlayerState()V
    .locals 3

    .prologue
    .line 536
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    if-nez v1, :cond_1

    .line 555
    :cond_0
    :goto_0
    return-void

    .line 539
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getCurrentPosition()I

    move-result v2

    iput v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    .line 540
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DOING:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    .line 545
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;->onSuspend(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 549
    const/4 v1, 0x0

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->setVisible(Z)V

    .line 550
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v1, :cond_2

    .line 551
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->closeCamera()V

    goto :goto_0

    .line 546
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 547
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call jbedVideoListener.onSuspend(), RemoteException"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 553
    .end local v0    # "e":Landroid/os/RemoteException;
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->stopPlayback()V

    goto :goto_0
.end method

.method public setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V
    .locals 1
    .param p1, "listener"    # Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 395
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    .line 396
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V

    .line 397
    return-void
.end method

.method public updateDisplayRect(Landroid/graphics/Rect;)V
    .locals 1
    .param p1, "rect"    # Landroid/graphics/Rect;

    .prologue
    .line 599
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v0, p1}, Landroid/graphics/Rect;->set(Landroid/graphics/Rect;)V

    .line 600
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->updateViewRect(Landroid/view/View;)V

    .line 601
    return-void
.end method

.method public updateRegionRect(Landroid/graphics/Rect;)V
    .locals 1
    .param p1, "rect"    # Landroid/graphics/Rect;

    .prologue
    .line 609
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mState:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v0, p1}, Landroid/graphics/Rect;->set(Landroid/graphics/Rect;)V

    .line 610
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoRegionView:Landroid/widget/AbsoluteLayout;

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->updateViewRect(Landroid/view/View;)V

    .line 611
    return-void
.end method

.method updateView(Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/View;Landroid/view/View;)V
    .locals 0
    .param p1, "videoRegionView"    # Landroid/widget/AbsoluteLayout;
    .param p2, "videoView"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p3, "videoParent"    # Landroid/view/View;
    .param p4, "frameParent"    # Landroid/view/View;

    .prologue
    .line 327
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoRegionView:Landroid/widget/AbsoluteLayout;

    .line 328
    iput-object p2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoView:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .line 329
    iput-object p3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mVideoParent:Landroid/view/View;

    .line 330
    iput-object p4, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->mFrameParent:Landroid/view/View;

    .line 331
    return-void
.end method
