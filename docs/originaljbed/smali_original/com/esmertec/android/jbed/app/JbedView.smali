.class public Lcom/esmertec/android/jbed/app/JbedView;
.super Landroid/view/SurfaceView;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;,
        Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;,
        Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;,
        Lcom/esmertec/android/jbed/app/JbedView$Callback;,
        Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;
    }
.end annotation


# static fields
.field public static final DEBUG_PAINT:Z = false

.field public static final EVENT_ON_MIDLET_ERROR:I = 0x1d4c4

.field public static final EVENT_ON_MIDLET_STATE_CHANGED:I = 0x1d4c5

.field public static final EVENT_ON_SERVICE_DISCONNECTED:I = 0x1d4c6

.field public static final EVENT_ON_SERVICE_REQUEST_FINISH:I = 0x1d4c2

.field public static final EVENT_ON_SOFTBUTTON_CHANGED:I = 0x1d4c7

.field public static final EVENT_ON_SURFACE_CREATED:I = 0x1d4c0

.field public static final EVENT_ON_SURFACE_DESTROYED:I = 0x1d4c1

.field public static final EVENT_ON_VM_READY:I = 0x1d4c3

.field public static final JBED_VIEW_EVENT_BASE:I = 0x1d4c0

.field private static final TAG:Ljava/lang/String; = "JbedView"

.field public static isMidletStarting:Z


# instance fields
.field private isVmStarted:Z

.field private mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

.field private mEventListenHandler:Landroid/os/Handler;

.field private mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

.field private mNativeWidgetContainer:Landroid/widget/AbsoluteLayout;

.field private mPainter:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

.field mSufaceCallback:Landroid/view/SurfaceHolder$Callback;

.field mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 125
    const/4 v1, 0x0

    sput-boolean v1, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    .line 168
    :try_start_0
    const-string v1, "jbedvm"

    invoke-static {v1}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_0 .. :try_end_0} :catch_0

    .line 173
    :goto_0
    return-void

    .line 169
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 170
    .local v0, "ule":Ljava/lang/UnsatisfiedLinkError;
    const-string v1, "JbedView"

    const-string v2, "WARNING: Could not load jbed native lib jbedvm"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 215
    invoke-direct {p0, p1}, Landroid/view/SurfaceView;-><init>(Landroid/content/Context;)V

    .line 119
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z

    .line 302
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedView$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedView$1;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mSufaceCallback:Landroid/view/SurfaceHolder$Callback;

    .line 216
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedView;->setup()V

    .line 217
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "attrs"    # Landroid/util/AttributeSet;

    .prologue
    .line 210
    invoke-direct {p0, p1, p2}, Landroid/view/SurfaceView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    .line 119
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z

    .line 302
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedView$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedView$1;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mSufaceCallback:Landroid/view/SurfaceHolder$Callback;

    .line 211
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedView;->setup()V

    .line 212
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "attrs"    # Landroid/util/AttributeSet;
    .param p3, "defStyle"    # I

    .prologue
    .line 205
    invoke-direct {p0, p1, p2, p3}, Landroid/view/SurfaceView;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;I)V

    .line 119
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z

    .line 302
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedView$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedView$1;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mSufaceCallback:Landroid/view/SurfaceHolder$Callback;

    .line 206
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedView;->setup()V

    .line 207
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/app/JbedView;Landroid/view/Surface;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # Landroid/view/Surface;

    .prologue
    .line 46
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/app/JbedView;->nativeInitializeAppView(Landroid/view/Surface;)V

    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mPainter:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    return-object v0
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/app/JbedView;Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    .prologue
    .line 46
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mPainter:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    return-object p1
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/app/JbedView;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedView;->startVm()V

    return-void
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    return-object v0
.end method

.method static synthetic access$402(Lcom/esmertec/android/jbed/app/JbedView;Lcom/esmertec/android/jbed/service/IJbedUiListener;)Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .prologue
    .line 46
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    return-object p1
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/widget/AbsoluteLayout;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mNativeWidgetContainer:Landroid/widget/AbsoluteLayout;

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;

    .prologue
    .line 46
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mEventListenHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$702(Lcom/esmertec/android/jbed/app/JbedView;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # Z

    .prologue
    .line 46
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z

    return p1
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/app/JbedView;Landroid/view/Surface;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # Landroid/view/Surface;

    .prologue
    .line 46
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/app/JbedView;->nativeFinalizeAppView(Landroid/view/Surface;)V

    return-void
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/app/JbedView;IIIIIIFF)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView;
    .param p1, "x1"    # I
    .param p2, "x2"    # I
    .param p3, "x3"    # I
    .param p4, "x4"    # I
    .param p5, "x5"    # I
    .param p6, "x6"    # I
    .param p7, "x7"    # F
    .param p8, "x8"    # F

    .prologue
    .line 46
    invoke-direct/range {p0 .. p8}, Lcom/esmertec/android/jbed/app/JbedView;->nativeRepaint(IIIIIIFF)V

    return-void
.end method

.method private native nativeFinalizeAppView(Landroid/view/Surface;)V
.end method

.method private native nativeInitializeAppView(Landroid/view/Surface;)V
.end method

.method private native nativeRepaint(IIIIIIFF)V
.end method

.method private onKey(Landroid/view/KeyEvent;)Z
    .locals 4
    .param p1, "keyEvent"    # Landroid/view/KeyEvent;

    .prologue
    .line 244
    const-string v1, "JbedView"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "notifyOnKey keyCode="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->appVerbose(Ljava/lang/String;Ljava/lang/String;)V

    .line 246
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/service/IJbedUiListener;->notifyOnKey(Landroid/view/KeyEvent;)Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v1

    :goto_0
    return v1

    :cond_0
    const/4 v1, 0x1

    goto :goto_0

    .line 247
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 248
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedView failed to call onKey()"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private setup()V
    .locals 2

    .prologue
    .line 220
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mSufaceCallback:Landroid/view/SurfaceHolder$Callback;

    invoke-interface {v0, v1}, Landroid/view/SurfaceHolder;->addCallback(Landroid/view/SurfaceHolder$Callback;)V

    .line 221
    return-void
.end method

.method private startVm()V
    .locals 10

    .prologue
    .line 287
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v0

    if-nez v0, :cond_1

    .line 300
    :cond_0
    :goto_0
    return-void

    .line 289
    :cond_1
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z

    if-nez v0, :cond_0

    .line 290
    new-instance v9, Landroid/graphics/PixelFormat;

    invoke-direct {v9}, Landroid/graphics/PixelFormat;-><init>()V

    .line 291
    .local v9, "pixFormat":Landroid/graphics/PixelFormat;
    const/4 v0, 0x4

    invoke-static {v0, v9}, Landroid/graphics/PixelFormat;->getPixelFormatInfo(ILandroid/graphics/PixelFormat;)V

    .line 292
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v0

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getWidth()I

    move-result v1

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getHeight()I

    move-result v2

    iget v3, v9, Landroid/graphics/PixelFormat;->bytesPerPixel:I

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getWidth()I

    move-result v4

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getHeight()I

    move-result v5

    const/4 v6, 0x1

    const/4 v7, 0x1

    invoke-interface/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/IJbedService;->startVm(IIIIIZZ)V

    .line 295
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->isVmStarted:Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 297
    .end local v9    # "pixFormat":Landroid/graphics/PixelFormat;
    :catch_0
    move-exception v0

    move-object v8, v0

    .line 298
    .local v8, "e":Landroid/os/RemoteException;
    const-string v0, "JbedView"

    const-string v1, "failed to connect to jbed service!"

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method


# virtual methods
.method public destroyMidlet(Ljava/lang/String;)V
    .locals 2
    .param p1, "name"    # Ljava/lang/String;

    .prologue
    .line 529
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    if-nez v0, :cond_1

    .line 530
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "please set connector first"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 532
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->destroyMidlet(Ljava/lang/String;)V

    .line 533
    return-void
.end method

.method public destroyMidlet(Ljava/lang/String;I)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 522
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    if-nez v0, :cond_1

    .line 523
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "please set connector first"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 525
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDestroyEvent(Ljava/lang/String;I)V

    .line 526
    return-void
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 3
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    const/4 v2, 0x1

    .line 265
    sget-boolean v1, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    if-eqz v1, :cond_0

    const/4 v1, 0x4

    if-ne p1, v1, :cond_0

    move v1, v2

    .line 268
    :goto_0
    return v1

    .line 267
    :cond_0
    invoke-direct {p0, p2}, Lcom/esmertec/android/jbed/app/JbedView;->onKey(Landroid/view/KeyEvent;)Z

    move-result v0

    .line 268
    .local v0, "isConsumed":Z
    if-eqz v0, :cond_1

    move v1, v2

    goto :goto_0

    :cond_1
    invoke-super {p0, p1, p2}, Landroid/view/SurfaceView;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v1

    goto :goto_0
.end method

.method public onKeyUp(ILandroid/view/KeyEvent;)Z
    .locals 3
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    const/4 v2, 0x1

    .line 257
    sget-boolean v1, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    if-eqz v1, :cond_0

    const/4 v1, 0x4

    if-ne p1, v1, :cond_0

    move v1, v2

    .line 260
    :goto_0
    return v1

    .line 259
    :cond_0
    invoke-direct {p0, p2}, Lcom/esmertec/android/jbed/app/JbedView;->onKey(Landroid/view/KeyEvent;)Z

    move-result v0

    .line 260
    .local v0, "isConsumed":Z
    if-eqz v0, :cond_1

    move v1, v2

    goto :goto_0

    :cond_1
    invoke-super {p0, p1, p2}, Landroid/view/SurfaceView;->onKeyUp(ILandroid/view/KeyEvent;)Z

    move-result v1

    goto :goto_0
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 6
    .param p1, "motionEvent"    # Landroid/view/MotionEvent;

    .prologue
    .line 274
    :try_start_0
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getX()F

    move-result v3

    float-to-int v1, v3

    .line 275
    .local v1, "x":I
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getY()F

    move-result v3

    float-to-int v2, v3

    .line 276
    .local v2, "y":I
    const-string v3, "JbedView"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "notifyOnTouchEvent x="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " y="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->appVerbose(Ljava/lang/String;Ljava/lang/String;)V

    .line 277
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->requestFocusFromTouch()Z

    .line 278
    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    if-eqz v3, :cond_0

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedView;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getAction()I

    move-result v4

    invoke-interface {v3, v1, v2, v4}, Lcom/esmertec/android/jbed/service/IJbedUiListener;->notifyOnTouchEvent(III)Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v3

    :goto_0
    return v3

    :cond_0
    const/4 v3, 0x1

    goto :goto_0

    .line 279
    .end local v1    # "x":I
    .end local v2    # "y":I
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 281
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v3, Ljava/lang/RuntimeException;

    const-string v4, " failed to call notifyOnTouchEvent"

    invoke-direct {v3, v4}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v3
.end method

.method public pauseMidlet(Ljava/lang/String;I)V
    .locals 0
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 537
    return-void
.end method

.method public requestVmBackground()V
    .locals 3

    .prologue
    .line 142
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v2, :cond_0

    .line 143
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    .line 144
    .local v1, "s":Lcom/esmertec/android/jbed/service/IJbedService;
    if-eqz v1, :cond_0

    .line 146
    :try_start_0
    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/IJbedService;->requestVmBackground()V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 152
    .end local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :cond_0
    :goto_0
    return-void

    .line 147
    .restart local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :catch_0
    move-exception v0

    .line 148
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->printStackTrace()V

    goto :goto_0
.end method

.method public runMidlet(Ljava/lang/String;)V
    .locals 2
    .param p1, "name"    # Ljava/lang/String;

    .prologue
    .line 515
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    if-nez v0, :cond_1

    .line 516
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "please set connector first"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 518
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestRunEvent(Ljava/lang/String;)V

    .line 519
    return-void
.end method

.method public runMidlet(Ljava/lang/String;I)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 508
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    if-nez v0, :cond_1

    .line 509
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "please set connector first"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 511
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestRunEvent(Ljava/lang/String;I)V

    .line 512
    return-void
.end method

.method public setOverlayView(Landroid/widget/AbsoluteLayout;)V
    .locals 0
    .param p1, "nativeWidgetView"    # Landroid/widget/AbsoluteLayout;

    .prologue
    .line 540
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mNativeWidgetContainer:Landroid/widget/AbsoluteLayout;

    .line 541
    return-void
.end method

.method public setRotateHappen(Z)V
    .locals 3
    .param p1, "b"    # Z

    .prologue
    .line 129
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v2, :cond_0

    .line 130
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    .line 131
    .local v1, "s":Lcom/esmertec/android/jbed/service/IJbedService;
    if-eqz v1, :cond_0

    .line 133
    :try_start_0
    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/service/IJbedService;->setRotateHappen(Z)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 139
    .end local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :cond_0
    :goto_0
    return-void

    .line 134
    .restart local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :catch_0
    move-exception v0

    .line 135
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->printStackTrace()V

    goto :goto_0
.end method

.method public setStartWay(Z)V
    .locals 3
    .param p1, "b"    # Z

    .prologue
    .line 155
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-eqz v2, :cond_0

    .line 156
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    .line 157
    .local v1, "s":Lcom/esmertec/android/jbed/service/IJbedService;
    if-eqz v1, :cond_0

    .line 159
    :try_start_0
    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/service/IJbedService;->setStartWay(Z)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 165
    .end local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :cond_0
    :goto_0
    return-void

    .line 160
    .restart local v1    # "s":Lcom/esmertec/android/jbed/service/IJbedService;
    :catch_0
    move-exception v0

    .line 161
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->printStackTrace()V

    goto :goto_0
.end method

.method public setup(Landroid/os/Handler;Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;)V
    .locals 3
    .param p1, "eventListenHandler"    # Landroid/os/Handler;
    .param p2, "connector"    # Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    .prologue
    .line 232
    if-nez p1, :cond_0

    .line 233
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "connector doesn\'t allow to be null!"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 235
    :cond_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView;->mEventListenHandler:Landroid/os/Handler;

    .line 236
    iput-object p2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    .line 238
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    if-nez v0, :cond_1

    .line 239
    new-instance v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedView;->getContext()Landroid/content/Context;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView;->mEventListenHandler:Landroid/os/Handler;

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;-><init>(Landroid/content/Context;Landroid/os/Handler;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    .line 241
    :cond_1
    return-void
.end method
