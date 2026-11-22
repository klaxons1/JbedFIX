.class public Lcom/esmertec/android/jbed/jsr/JbedVideoView;
.super Landroid/view/SurfaceView;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/widget/MediaController$MediaPlayerControl;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;,
        Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;,
        Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;
    }
.end annotation


# static fields
.field public static final CAMERA_DEFAULT_HEIGHT:I = 0xdc

.field public static final CAMERA_DEFAULT_WIDTH:I = 0xb0

.field private static final DEBUG:Z = false

.field private static final FLAG:Ljava/lang/String; = "JbedVideoView"

.field private static final MAX_RESUME_TRY:I = 0xa

.field private static final MODULE_PROJECT:I = 0x6

.field private static final STRING_ID:I = 0x15

.field public static mDefaultLocation:Landroid/graphics/Rect;


# instance fields
.field private mBufferingUpdateListener:Landroid/media/MediaPlayer$OnBufferingUpdateListener;

.field private mCamera:Landroid/hardware/Camera;

.field private mCameraData:[B

.field private final mCameraMutex:[B

.field private mCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

.field private mCurrentBufferPercentage:I

.field private mDataSource:Ljava/lang/String;

.field private mDuration:I

.field private mErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

.field private mFrameParent:Landroid/view/View;

.field private mHandler:Landroid/os/Handler;

.field private mIsPrepared:Z

.field private mJpegPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

.field private mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

.field private mMediaController:Landroid/widget/MediaController;

.field private mMediaPlayer:Landroid/media/MediaPlayer;

.field private mOnCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

.field private mOnErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

.field private mOnPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

.field mPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

.field private mRawPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

.field private mRecorder:Landroid/media/MediaRecorder;

.field mSHCallback:Landroid/view/SurfaceHolder$Callback;

.field private mSeekWhenPrepared:I

.field private mShutterCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

.field mSizeChangedListener:Landroid/media/MediaPlayer$OnVideoSizeChangedListener;

.field private mSnapshotInProgress:Z

.field private mStartWhenPrepared:Z

.field private mSurfaceHeight:I

.field private mSurfaceHolder:Landroid/view/SurfaceHolder;

.field private mSurfaceWidth:I

.field private mVideoHeight:I

.field private mVideoParent:Landroid/view/View;

.field private mVideoRecordPath:Ljava/lang/String;

.field private mVideoSizeReady:Z

.field private mVideoWidth:I

.field private mutex:Ljava/lang/Object;

.field private resumeTried:I


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    const/4 v2, 0x1

    const/4 v1, 0x0

    .line 106
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0, v1, v1, v2, v2}, Landroid/graphics/Rect;-><init>(IIII)V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    const/4 v2, 0x0

    const/4 v1, 0x0

    .line 109
    invoke-direct {p0, p1}, Landroid/view/SurfaceView;-><init>(Landroid/content/Context;)V

    .line 57
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    .line 58
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    .line 65
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    .line 66
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    .line 81
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mShutterCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

    .line 82
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRawPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

    .line 83
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mJpegPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

    .line 85
    new-array v0, v2, [B

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    .line 89
    new-instance v0, Landroid/os/Handler;

    invoke-direct {v0}, Landroid/os/Handler;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mHandler:Landroid/os/Handler;

    .line 90
    iput v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    .line 375
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSizeChangedListener:Landroid/media/MediaPlayer$OnVideoSizeChangedListener;

    .line 400
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

    .line 459
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

    .line 480
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

    .line 531
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mBufferingUpdateListener:Landroid/media/MediaPlayer$OnBufferingUpdateListener;

    .line 570
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSHCallback:Landroid/view/SurfaceHolder$Callback;

    .line 110
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->initVideoView()V

    .line 111
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "attrs"    # Landroid/util/AttributeSet;

    .prologue
    .line 114
    const/4 v0, 0x0

    invoke-direct {p0, p1, p2, v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V

    .line 115
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->initVideoView()V

    .line 116
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "attrs"    # Landroid/util/AttributeSet;
    .param p3, "defStyle"    # I

    .prologue
    const/4 v2, 0x0

    const/4 v1, 0x0

    .line 119
    invoke-direct {p0, p1, p2, p3}, Landroid/view/SurfaceView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V

    .line 57
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    .line 58
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    .line 65
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    .line 66
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    .line 81
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mShutterCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

    .line 82
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRawPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

    .line 83
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mJpegPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

    .line 85
    new-array v0, v2, [B

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    .line 89
    new-instance v0, Landroid/os/Handler;

    invoke-direct {v0}, Landroid/os/Handler;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mHandler:Landroid/os/Handler;

    .line 90
    iput v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    .line 375
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSizeChangedListener:Landroid/media/MediaPlayer$OnVideoSizeChangedListener;

    .line 400
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

    .line 459
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

    .line 480
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

    .line 531
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mBufferingUpdateListener:Landroid/media/MediaPlayer$OnBufferingUpdateListener;

    .line 570
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSHCallback:Landroid/view/SurfaceHolder$Callback;

    .line 120
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->initVideoView()V

    .line 121
    return-void
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/View;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoParent:Landroid/view/View;

    return-object v0
.end method

.method static synthetic access$1100(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/View;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mFrameParent:Landroid/view/View;

    return-object v0
.end method

.method static synthetic access$1202(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Z

    .prologue
    .line 55
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    return p1
.end method

.method static synthetic access$1300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Ljava/lang/Object;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    return-object v0
.end method

.method static synthetic access$1400(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    return v0
.end method

.method static synthetic access$1402(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Z

    .prologue
    .line 55
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    return p1
.end method

.method static synthetic access$1500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnPreparedListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

    return-object v0
.end method

.method static synthetic access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    return-object v0
.end method

.method static synthetic access$1602(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/media/MediaPlayer;)Landroid/media/MediaPlayer;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Landroid/media/MediaPlayer;

    .prologue
    .line 55
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    return-object p1
.end method

.method static synthetic access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    return-object v0
.end method

.method static synthetic access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSeekWhenPrepared:I

    return v0
.end method

.method static synthetic access$1802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSeekWhenPrepared:I

    return p1
.end method

.method static synthetic access$1900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    return v0
.end method

.method static synthetic access$1902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Z

    .prologue
    .line 55
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    return p1
.end method

.method static synthetic access$2000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnCompletionListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

    return-object v0
.end method

.method static synthetic access$2100(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    return-object v0
.end method

.method static synthetic access$2200(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnErrorListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

    return-object v0
.end method

.method static synthetic access$2300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$2400(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$2502(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCurrentBufferPercentage:I

    return p1
.end method

.method static synthetic access$2602(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceWidth:I

    return p1
.end method

.method static synthetic access$2702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHeight:I

    return p1
.end method

.method static synthetic access$2802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;[B)[B
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # [B

    .prologue
    .line 55
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraData:[B

    return-object p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/SurfaceHolder;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    return-object v0
.end method

.method static synthetic access$302(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/SurfaceHolder;)Landroid/view/SurfaceHolder;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Landroid/view/SurfaceHolder;

    .prologue
    .line 55
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    return-object p1
.end method

.method static synthetic access$402(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Ljava/lang/String;)Ljava/lang/String;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # Ljava/lang/String;

    .prologue
    .line 55
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoRecordPath:Ljava/lang/String;

    return-object p1
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)[B
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    return p1
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    return v0
.end method

.method static synthetic access$802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    return p1
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .prologue
    .line 55
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    return v0
.end method

.method static synthetic access$902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p1, "x1"    # I

    .prologue
    .line 55
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    return p1
.end method

.method private attachMediaController()V
    .locals 3

    .prologue
    .line 364
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    if-eqz v1, :cond_0

    .line 365
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v1, p0}, Landroid/widget/MediaController;->setMediaPlayer(Landroid/widget/MediaController$MediaPlayerControl;)V

    .line 366
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    instance-of v1, v1, Landroid/view/View;

    if-eqz v1, :cond_1

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    check-cast v1, Landroid/view/View;

    move-object v0, v1

    .line 368
    .local v0, "anchorView":Landroid/view/View;
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v1, v0}, Landroid/widget/MediaController;->setAnchorView(Landroid/view/View;)V

    .line 369
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    invoke-virtual {v1, v2}, Landroid/widget/MediaController;->setEnabled(Z)V

    .line 371
    .end local v0    # "anchorView":Landroid/view/View;
    :cond_0
    return-void

    :cond_1
    move-object v0, p0

    .line 366
    goto :goto_0
.end method

.method private initVideoView()V
    .locals 3

    .prologue
    const/4 v2, 0x1

    const/4 v0, 0x0

    .line 197
    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    .line 198
    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    .line 199
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSHCallback:Landroid/view/SurfaceHolder$Callback;

    invoke-interface {v0, v1}, Landroid/view/SurfaceHolder;->addCallback(Landroid/view/SurfaceHolder$Callback;)V

    .line 200
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    const/4 v1, 0x3

    invoke-interface {v0, v1}, Landroid/view/SurfaceHolder;->setType(I)V

    .line 201
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setFocusable(Z)V

    .line 202
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setFocusableInTouchMode(Z)V

    .line 203
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->requestFocus()Z

    .line 204
    return-void
.end method

.method private openVideo()V
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    const/4 v3, 0x0

    .line 325
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDataSource:Ljava/lang/String;

    if-nez v1, :cond_0

    .line 353
    :goto_0
    return-void

    .line 332
    :cond_0
    new-instance v0, Landroid/content/Intent;

    const-string v1, "com.android.music.musicservicecommand"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 333
    .local v0, "i":Landroid/content/Intent;
    const-string v1, "command"

    const-string v2, "pause"

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 334
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mContext:Landroid/content/Context;

    invoke-virtual {v1, v0}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    .line 336
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->stopPlayback()V

    .line 338
    new-instance v1, Landroid/media/MediaPlayer;

    invoke-direct {v1}, Landroid/media/MediaPlayer;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    .line 339
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v1}, Landroid/media/MediaPlayer;->reset()V

    .line 340
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setOnPreparedListener(Landroid/media/MediaPlayer$OnPreparedListener;)V

    .line 341
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSizeChangedListener:Landroid/media/MediaPlayer$OnVideoSizeChangedListener;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setOnVideoSizeChangedListener(Landroid/media/MediaPlayer$OnVideoSizeChangedListener;)V

    .line 342
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    .line 343
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setOnCompletionListener(Landroid/media/MediaPlayer$OnCompletionListener;)V

    .line 344
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setOnErrorListener(Landroid/media/MediaPlayer$OnErrorListener;)V

    .line 345
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mBufferingUpdateListener:Landroid/media/MediaPlayer$OnBufferingUpdateListener;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setOnBufferingUpdateListener(Landroid/media/MediaPlayer$OnBufferingUpdateListener;)V

    .line 346
    iput v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCurrentBufferPercentage:I

    .line 347
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDataSource:Ljava/lang/String;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setDataSource(Ljava/lang/String;)V

    .line 348
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setDisplay(Landroid/view/SurfaceHolder;)V

    .line 349
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setAudioStreamType(I)V

    .line 350
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/media/MediaPlayer;->setScreenOnWhilePlaying(Z)V

    .line 351
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v1}, Landroid/media/MediaPlayer;->prepare()V

    .line 352
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->attachMediaController()V

    goto :goto_0
.end method

.method private resetMediaRecorder()V
    .locals 1

    .prologue
    .line 894
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    if-eqz v0, :cond_0

    .line 895
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->reset()V

    .line 897
    :cond_0
    return-void
.end method

.method private storeImage([BLjava/lang/String;)I
    .locals 8
    .param p1, "data"    # [B
    .param p2, "filename"    # Ljava/lang/String;

    .prologue
    const/4 v7, -0x1

    const-string v4, "JbedVideoView"

    .line 833
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 834
    .local v1, "file":Ljava/io/File;
    if-eqz p1, :cond_4

    .line 835
    const/4 v2, 0x0

    .line 837
    .local v2, "stream":Ljava/io/OutputStream;
    :try_start_0
    new-instance v3, Ljava/io/FileOutputStream;

    invoke-direct {v3, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 838
    .end local v2    # "stream":Ljava/io/OutputStream;
    .local v3, "stream":Ljava/io/OutputStream;
    const/4 v4, 0x0

    :try_start_1
    array-length v5, p1

    invoke-virtual {v3, p1, v4, v5}, Ljava/io/OutputStream;->write([BII)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 843
    if-eqz v3, :cond_0

    .line 845
    :try_start_2
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_1

    .line 853
    :cond_0
    :goto_0
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v4

    long-to-int v4, v4

    .end local v3    # "stream":Ljava/io/OutputStream;
    :goto_1
    return v4

    .line 839
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 840
    .local v0, "e":Ljava/lang/Exception;
    :goto_2
    :try_start_3
    const-string v4, "JbedVideoView"

    const/4 v5, 0x6

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_1

    const-string v4, "JbedVideoView"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "getSnapshot, fails to write bitmap file : "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 843
    :cond_1
    if-eqz v2, :cond_2

    .line 845
    :try_start_4
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_2

    :cond_2
    :goto_3
    move v4, v7

    .line 846
    goto :goto_1

    .line 843
    .end local v0    # "e":Ljava/lang/Exception;
    :catchall_0
    move-exception v4

    :goto_4
    if-eqz v2, :cond_3

    .line 845
    :try_start_5
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_3

    .line 846
    :cond_3
    :goto_5
    throw v4

    .end local v2    # "stream":Ljava/io/OutputStream;
    :cond_4
    move v4, v7

    .line 851
    goto :goto_1

    .line 846
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_1
    move-exception v4

    goto :goto_0

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v0    # "e":Ljava/lang/Exception;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_2
    move-exception v4

    goto :goto_3

    .end local v0    # "e":Ljava/lang/Exception;
    :catch_3
    move-exception v5

    goto :goto_5

    .line 843
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catchall_1
    move-exception v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_4

    .line 839
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_4
    move-exception v4

    move-object v0, v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_2
.end method

.method private toggleMediaControlsVisiblity()V
    .locals 1

    .prologue
    .line 622
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v0}, Landroid/widget/MediaController;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 623
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v0}, Landroid/widget/MediaController;->hide()V

    .line 627
    :goto_0
    return-void

    .line 625
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v0}, Landroid/widget/MediaController;->show()V

    goto :goto_0
.end method


# virtual methods
.method public callRequestLayout()V
    .locals 0

    .prologue
    .line 242
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->requestLayout()V

    .line 243
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->invalidate()V

    .line 244
    return-void
.end method

.method public canPause()Z
    .locals 1

    .prologue
    .line 911
    const/4 v0, 0x1

    return v0
.end method

.method public canSeekBackward()Z
    .locals 1

    .prologue
    .line 909
    const/4 v0, 0x1

    return v0
.end method

.method public canSeekForward()Z
    .locals 1

    .prologue
    .line 910
    const/4 v0, 0x1

    return v0
.end method

.method public closeCamera()V
    .locals 2

    .prologue
    const/4 v1, 0x0

    .line 719
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    if-eqz v0, :cond_0

    .line 720
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    invoke-virtual {v0}, Landroid/hardware/Camera;->release()V

    .line 721
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    .line 723
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    if-eqz v0, :cond_1

    .line 724
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->release()V

    .line 725
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    .line 727
    :cond_1
    return-void
.end method

.method public getBufferPercentage()I
    .locals 1

    .prologue
    .line 684
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    .line 685
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCurrentBufferPercentage:I

    .line 687
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public getCurrentPosition()I
    .locals 1

    .prologue
    .line 662
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    .line 663
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->getCurrentPosition()I

    move-result v0

    .line 665
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public getDataSource()Ljava/lang/String;
    .locals 1

    .prologue
    .line 906
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDataSource:Ljava/lang/String;

    return-object v0
.end method

.method public getDuration()I
    .locals 1

    .prologue
    .line 650
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_1

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_1

    .line 651
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    if-lez v0, :cond_0

    .line 652
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    .line 658
    :goto_0
    return v0

    .line 654
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->getDuration()I

    move-result v0

    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    .line 655
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    goto :goto_0

    .line 657
    :cond_1
    const/4 v0, -0x1

    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    .line 658
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDuration:I

    goto :goto_0
.end method

.method public getFrameAt(I)Landroid/graphics/Bitmap;
    .locals 1
    .param p1, "pos"    # I

    .prologue
    .line 691
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0, p1}, Landroid/media/MediaPlayer;->getFrameAt(I)Landroid/graphics/Bitmap;

    move-result-object v0

    return-object v0
.end method

.method public getVideoHeight()I
    .locals 2

    .prologue
    .line 136
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    if-eqz v0, :cond_1

    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    if-nez v0, :cond_1

    .line 137
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    monitor-enter v0

    .line 140
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    invoke-virtual {v1}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 142
    :goto_0
    :try_start_1
    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 144
    :cond_1
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    return v0

    .line 142
    :catchall_0
    move-exception v1

    :try_start_2
    monitor-exit v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v1

    .line 141
    :catch_0
    move-exception v1

    goto :goto_0
.end method

.method public getVideoWidth()I
    .locals 2

    .prologue
    .line 124
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoSizeReady:Z

    if-eqz v0, :cond_1

    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    if-nez v0, :cond_1

    .line 125
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    monitor-enter v0

    .line 128
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mutex:Ljava/lang/Object;

    invoke-virtual {v1}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 130
    :goto_0
    :try_start_1
    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 132
    :cond_1
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    return v0

    .line 130
    :catchall_0
    move-exception v1

    :try_start_2
    monitor-exit v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v1

    .line 129
    :catch_0
    move-exception v1

    goto :goto_0
.end method

.method public initRecorder()V
    .locals 3

    .prologue
    .line 862
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    if-nez v0, :cond_0

    .line 863
    new-instance v0, Landroid/media/MediaRecorder;

    invoke-direct {v0}, Landroid/media/MediaRecorder;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    .line 865
    :cond_0
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resetMediaRecorder()V

    .line 866
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setAudioSource(I)V

    .line 867
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setVideoSource(I)V

    .line 868
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setOutputFormat(I)V

    .line 869
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoRecordPath:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setOutputFile(Ljava/lang/String;)V

    .line 870
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/16 v1, 0x14

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setVideoFrameRate(I)V

    .line 871
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/16 v1, 0xb0

    const/16 v2, 0x90

    invoke-virtual {v0, v1, v2}, Landroid/media/MediaRecorder;->setVideoSize(II)V

    .line 872
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setVideoEncoder(I)V

    .line 873
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setAudioEncoder(I)V

    .line 874
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    invoke-interface {v1}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/media/MediaRecorder;->setPreviewDisplay(Landroid/view/Surface;)V

    .line 875
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->prepare()V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 879
    :goto_0
    return-void

    .line 876
    :catch_0
    move-exception v0

    goto :goto_0
.end method

.method public isPlaying()Z
    .locals 1

    .prologue
    .line 677
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    .line 678
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->isPlaying()Z

    move-result v0

    .line 680
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method protected onMeasure(II)V
    .locals 3
    .param p1, "widthMeasureSpec"    # I
    .param p2, "heightMeasureSpec"    # I

    .prologue
    .line 159
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoWidth:I

    invoke-static {v2, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getDefaultSize(II)I

    move-result v1

    .line 160
    .local v1, "width":I
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoHeight:I

    invoke-static {v2, p2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getDefaultSize(II)I

    move-result v0

    .line 163
    .local v0, "height":I
    invoke-virtual {p0, v1, v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setMeasuredDimension(II)V

    .line 164
    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 1
    .param p1, "ev"    # Landroid/view/MotionEvent;

    .prologue
    .line 607
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    if-eqz v0, :cond_0

    .line 608
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->toggleMediaControlsVisiblity()V

    .line 610
    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public onTrackballEvent(Landroid/view/MotionEvent;)Z
    .locals 1
    .param p1, "ev"    # Landroid/view/MotionEvent;

    .prologue
    .line 615
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    if-eqz v0, :cond_0

    .line 616
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->toggleMediaControlsVisiblity()V

    .line 618
    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public openCamera()Z
    .locals 4

    .prologue
    .line 697
    :try_start_0
    invoke-static {}, Landroid/hardware/Camera;->open()Landroid/hardware/Camera;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    .line 699
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    invoke-virtual {v2}, Landroid/hardware/Camera;->getParameters()Landroid/hardware/Camera$Parameters;

    move-result-object v1

    .line 700
    .local v1, "parameters":Landroid/hardware/Camera$Parameters;
    const-string v2, "jpeg-quality"

    const/16 v3, 0x55

    invoke-virtual {v1, v2, v3}, Landroid/hardware/Camera$Parameters;->set(Ljava/lang/String;I)V

    .line 703
    const/16 v2, 0x140

    const/16 v3, 0xf0

    invoke-virtual {v1, v2, v3}, Landroid/hardware/Camera$Parameters;->setPictureSize(II)V

    .line 705
    const/16 v2, 0xb0

    const/16 v3, 0xdc

    invoke-virtual {v1, v2, v3}, Landroid/hardware/Camera$Parameters;->setPreviewSize(II)V

    .line 706
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    invoke-virtual {v2, v1}, Landroid/hardware/Camera;->setParameters(Landroid/hardware/Camera$Parameters;)V

    .line 707
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    invoke-virtual {v2, v3}, Landroid/hardware/Camera;->setPreviewDisplay(Landroid/view/SurfaceHolder;)V

    .line 708
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    invoke-virtual {v2}, Landroid/hardware/Camera;->startPreview()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 714
    const/4 v2, 0x1

    .end local v1    # "parameters":Landroid/hardware/Camera$Parameters;
    :goto_0
    return v2

    .line 709
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 711
    .local v0, "e":Ljava/lang/Exception;
    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    .line 712
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public pause()V
    .locals 1

    .prologue
    .line 641
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    .line 642
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->isPlaying()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 643
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->pause()V

    .line 646
    :cond_0
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    .line 647
    return-void
.end method

.method public resolveAdjustedSize(II)I
    .locals 3
    .param p1, "desiredSize"    # I
    .param p2, "measureSpec"    # I

    .prologue
    .line 167
    move v0, p1

    .line 168
    .local v0, "result":I
    invoke-static {p2}, Landroid/view/View$MeasureSpec;->getMode(I)I

    move-result v1

    .line 169
    .local v1, "specMode":I
    invoke-static {p2}, Landroid/view/View$MeasureSpec;->getSize(I)I

    move-result v2

    .line 171
    .local v2, "specSize":I
    sparse-switch v1, :sswitch_data_0

    .line 192
    :goto_0
    return v0

    .line 176
    :sswitch_0
    move v0, p1

    .line 177
    goto :goto_0

    .line 184
    :sswitch_1
    invoke-static {p1, v2}, Ljava/lang/Math;->min(II)I

    move-result v0

    .line 185
    goto :goto_0

    .line 189
    :sswitch_2
    move v0, v2

    goto :goto_0

    .line 171
    :sswitch_data_0
    .sparse-switch
        -0x80000000 -> :sswitch_1
        0x0 -> :sswitch_0
        0x40000000 -> :sswitch_2
    .end sparse-switch
.end method

.method public resume(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    .locals 6
    .param p1, "state"    # Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .prologue
    const/4 v4, 0x0

    .line 264
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    add-int/lit8 v2, v2, 0x1

    iput v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    const/16 v3, 0xa

    if-le v2, v3, :cond_0

    .line 269
    const/4 v2, 0x6

    const/16 v3, 0x15

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getString(II)Ljava/lang/String;

    move-result-object v1

    .line 270
    .local v1, "s":Ljava/lang/String;
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mContext:Landroid/content/Context;

    const/4 v3, 0x1

    invoke-static {v2, v1, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v2

    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    .line 271
    iput v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeTried:I

    .line 321
    .end local v1    # "s":Ljava/lang/String;
    :goto_0
    return-void

    .line 276
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSurfaceHolder:Landroid/view/SurfaceHolder;

    if-eqz v2, :cond_1

    move v0, v4

    .line 278
    .local v0, "delay":I
    :goto_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mHandler:Landroid/os/Handler;

    new-instance v3, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;

    invoke-direct {v3, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V

    int-to-long v4, v0

    invoke-virtual {v2, v3, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_0

    .line 276
    .end local v0    # "delay":I
    :cond_1
    const/16 v2, 0x3e8

    move v0, v2

    goto :goto_1
.end method

.method public resumeVideoPlay(Ljava/lang/String;IZ)V
    .locals 4
    .param p1, "path"    # Ljava/lang/String;
    .param p2, "position"    # I
    .param p3, "isPlay"    # Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    const-string v3, "JbedVideoView"

    .line 224
    :try_start_0
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setVideoPath(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 232
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-nez v1, :cond_2

    .line 239
    :cond_0
    :goto_1
    return-void

    .line 225
    :catch_0
    move-exception v0

    .line 226
    .local v0, "ioe":Ljava/lang/Exception;
    const-string v1, "JbedVideoView"

    const/4 v1, 0x6

    invoke-static {v3, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_1

    const-string v1, "JbedVideoView"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "failed to setVideoPath("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ")"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 227
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v1}, Landroid/media/MediaPlayer;->release()V

    .line 228
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    goto :goto_0

    .line 235
    .end local v0    # "ioe":Ljava/lang/Exception;
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v1, p2}, Landroid/media/MediaPlayer;->seekTo(I)V

    .line 236
    if-eqz p3, :cond_0

    .line 237
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->start()V

    goto :goto_1
.end method

.method public seekTo(I)V
    .locals 1
    .param p1, "msec"    # I

    .prologue
    .line 669
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    .line 670
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0, p1}, Landroid/media/MediaPlayer;->seekTo(I)V

    .line 674
    :goto_0
    return-void

    .line 672
    :cond_0
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSeekWhenPrepared:I

    goto :goto_0
.end method

.method public setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V
    .locals 1
    .param p1, "listener"    # Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    .prologue
    .line 900
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    if-eq v0, p1, :cond_0

    .line 901
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    .line 903
    :cond_0
    return-void
.end method

.method public setMediaController(Landroid/widget/MediaController;)V
    .locals 1
    .param p1, "controller"    # Landroid/widget/MediaController;

    .prologue
    .line 356
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    if-eqz v0, :cond_0

    .line 357
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    invoke-virtual {v0}, Landroid/widget/MediaController;->hide()V

    .line 359
    :cond_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaController:Landroid/widget/MediaController;

    .line 360
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->attachMediaController()V

    .line 361
    return-void
.end method

.method public setOnCompletionListener(Landroid/media/MediaPlayer$OnCompletionListener;)V
    .locals 0
    .param p1, "l"    # Landroid/media/MediaPlayer$OnCompletionListener;

    .prologue
    .line 555
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnCompletionListener:Landroid/media/MediaPlayer$OnCompletionListener;

    .line 556
    return-void
.end method

.method public setOnErrorListener(Landroid/media/MediaPlayer$OnErrorListener;)V
    .locals 0
    .param p1, "l"    # Landroid/media/MediaPlayer$OnErrorListener;

    .prologue
    .line 567
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnErrorListener:Landroid/media/MediaPlayer$OnErrorListener;

    .line 568
    return-void
.end method

.method public setOnPreparedListener(Landroid/media/MediaPlayer$OnPreparedListener;)V
    .locals 0
    .param p1, "l"    # Landroid/media/MediaPlayer$OnPreparedListener;

    .prologue
    .line 545
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mOnPreparedListener:Landroid/media/MediaPlayer$OnPreparedListener;

    .line 546
    return-void
.end method

.method public setParentView(Landroid/view/View;Landroid/view/View;)V
    .locals 0
    .param p1, "videoParent"    # Landroid/view/View;
    .param p2, "frameParent"    # Landroid/view/View;

    .prologue
    .line 215
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoParent:Landroid/view/View;

    .line 216
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mFrameParent:Landroid/view/View;

    .line 217
    return-void
.end method

.method public setVideoPath(Ljava/lang/String;)V
    .locals 1
    .param p1, "path"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    const/4 v0, 0x0

    .line 208
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDataSource:Ljava/lang/String;

    .line 209
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    .line 210
    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mSeekWhenPrepared:I

    .line 211
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->openVideo()V

    .line 212
    return-void
.end method

.method public setVideoRecordPath(Ljava/lang/String;)V
    .locals 0
    .param p1, "dataSource"    # Ljava/lang/String;

    .prologue
    .line 857
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mVideoRecordPath:Ljava/lang/String;

    .line 858
    return-void
.end method

.method public start()V
    .locals 1

    .prologue
    .line 631
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mIsPrepared:Z

    if-eqz v0, :cond_0

    .line 632
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->start()V

    .line 633
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    .line 637
    :goto_0
    return-void

    .line 635
    :cond_0
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mStartWhenPrepared:Z

    goto :goto_0
.end method

.method public startRecord()V
    .locals 1

    .prologue
    .line 882
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    invoke-virtual {v0}, Landroid/hardware/Camera;->release()V

    .line 883
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->initRecorder()V

    .line 884
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->start()V

    .line 885
    return-void
.end method

.method public stopPlayback()V
    .locals 1

    .prologue
    .line 248
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    if-eqz v0, :cond_0

    .line 249
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->stop()V

    .line 250
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->release()V

    .line 251
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mMediaPlayer:Landroid/media/MediaPlayer;

    .line 253
    :cond_0
    return-void
.end method

.method public stopRecord()V
    .locals 1

    .prologue
    .line 888
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->stop()V

    .line 889
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v0}, Landroid/media/MediaRecorder;->release()V

    .line 890
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->openCamera()Z

    .line 891
    return-void
.end method

.method public takePicture()[B
    .locals 6

    .prologue
    const-string v5, "JbedVideoView"

    .line 732
    const/4 v1, 0x0

    :try_start_0
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraData:[B

    .line 735
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_2

    if-nez v1, :cond_0

    .line 737
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    if-eqz v1, :cond_0

    .line 738
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mListener:Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;->restoreState()V
    :try_end_1
    .catch Landroid/os/RemoteException; {:try_start_1 .. :try_end_1} :catch_3
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_2

    .line 746
    :cond_0
    :goto_0
    :try_start_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    monitor-enter v1
    :try_end_2
    .catch Ljava/lang/Throwable; {:try_start_2 .. :try_end_2} :catch_2

    .line 748
    :goto_1
    :try_start_3
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    if-nez v2, :cond_1

    .line 750
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    const-wide/16 v3, 0x3e8

    invoke-virtual {v2, v3, v4}, Ljava/lang/Object;->wait(J)V
    :try_end_3
    .catch Ljava/lang/InterruptedException; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_1

    .line 752
    :catch_0
    move-exception v2

    .line 755
    :cond_1
    :try_start_4
    monitor-exit v1
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 778
    :try_start_5
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCamera:Landroid/hardware/Camera;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mShutterCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$TestShutterCallback;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mRawPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mJpegPictureCallback:Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;

    invoke-virtual {v1, v2, v3, v4}, Landroid/hardware/Camera;->takePicture(Landroid/hardware/Camera$ShutterCallback;Landroid/hardware/Camera$PictureCallback;Landroid/hardware/Camera$PictureCallback;)V
    :try_end_5
    .catch Ljava/lang/Throwable; {:try_start_5 .. :try_end_5} :catch_2

    .line 785
    :cond_2
    :goto_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    monitor-enter v1

    .line 787
    :goto_3
    :try_start_6
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraData:[B

    if-nez v2, :cond_3

    .line 788
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraMutex:[B

    const-wide/16 v3, 0x3e8

    invoke-virtual {v2, v3, v4}, Ljava/lang/Object;->wait(J)V
    :try_end_6
    .catch Ljava/lang/InterruptedException; {:try_start_6 .. :try_end_6} :catch_1
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    goto :goto_3

    .line 791
    :catch_1
    move-exception v2

    .line 794
    :cond_3
    :try_start_7
    monitor-exit v1
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_1

    .line 795
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mCameraData:[B

    return-object v1

    .line 755
    :catchall_0
    move-exception v2

    :try_start_8
    monitor-exit v1
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_0

    :try_start_9
    throw v2
    :try_end_9
    .catch Ljava/lang/Throwable; {:try_start_9 .. :try_end_9} :catch_2

    .line 781
    :catch_2
    move-exception v1

    move-object v0, v1

    .line 782
    .local v0, "t":Ljava/lang/Throwable;
    const-string v1, "JbedVideoView"

    const/4 v1, 0x6

    invoke-static {v5, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_2

    const-string v1, "JbedVideoView"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v5, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_2

    .line 794
    .end local v0    # "t":Ljava/lang/Throwable;
    :catchall_1
    move-exception v2

    :try_start_a
    monitor-exit v1
    :try_end_a
    .catchall {:try_start_a .. :try_end_a} :catchall_1

    throw v2

    .line 740
    :catch_3
    move-exception v1

    goto :goto_0
.end method
