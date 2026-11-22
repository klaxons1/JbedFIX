.class public Lcom/esmertec/android/jbed/app/JbedAppActivity;
.super Landroid/app/Activity;
.source "JbedAppActivity.java"

# interfaces
.implements Lcom/esmertec/android/jbed/JbedConstants;


# static fields
.field private static final INTENT_EXTRA_NO:Ljava/lang/String; = "no"

.field private static final INTENT_EXTRA_ROOT:Ljava/lang/String; = "root"

.field public static final RESULT_NO_RUNNING_MIDLET:I = 0x2

.field private static SmsIntent:Landroid/content/Intent; = null

.field private static final TAG:Ljava/lang/String; = "JbedAppActivity"


# instance fields
.field private isInitialized:Z

.field private mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

.field private mHandler:Landroid/os/Handler;

.field private mIsFullScreen:Z

.field private mIsPendingSoftButtonChanged:Z

.field private mIsRotating:Z

.field private mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

.field private mJbedViewCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

.field private mLeftButton:Ljava/lang/String;

.field private mOrientation:I

.field private mPaused:Z

.field private mRightButton:Ljava/lang/String;

.field private mVideoClient:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

.field private mVmStateReceiver:Landroid/content/BroadcastReceiver;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 54
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    .line 80
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    .line 176
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedAppActivity$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$2;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    .line 192
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    .line 226
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mOrientation:I

    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView$Callback;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedViewCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

    return-object v0
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/app/JbedAppActivity;Lcom/esmertec/android/jbed/app/JbedView$Callback;)Lcom/esmertec/android/jbed/app/JbedView$Callback;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/app/JbedView$Callback;

    .prologue
    .line 54
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedViewCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

    return-object p1
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mIsFullScreen:Z

    return v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/app/JbedAppActivity;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;
    .param p1, "x1"    # Z

    .prologue
    .line 54
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->initialize(Z)V

    return-void
.end method

.method static synthetic access$400()Landroid/content/Intent;
    .locals 1

    .prologue
    .line 54
    sget-object v0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->SmsIntent:Landroid/content/Intent;

    return-object v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getApp()Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->restoreVideoPlayer()V

    return-void
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedAppActivity;

    .prologue
    .line 54
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->reserveVideoPlayer()V

    return-void
.end method

.method private getApp()Lcom/esmertec/android/jbed/JbedApp;
    .locals 0

    .prologue
    .line 221
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getApplication()Landroid/app/Application;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/app/JbedAppActivity;
    check-cast p0, Lcom/esmertec/android/jbed/JbedApp;

    return-object p0
.end method

.method private initialize(Z)V
    .locals 11
    .param p1, "force"    # Z

    .prologue
    const/4 v10, 0x1

    const-string v1, "JbedAppActivity"

    .line 265
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->isInitialized:Z

    if-eqz v0, :cond_0

    if-nez p1, :cond_0

    .line 266
    const-string v0, "JbedAppActivity"

    const-string v0, "initialize()========ingore it ==========="

    invoke-static {v1, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 317
    :goto_0
    return-void

    .line 269
    :cond_0
    const-string v0, "JbedAppActivity"

    const-string v0, "initialize()==================="

    invoke-static {v1, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 280
    const v0, 0x7f030003

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->setContentView(I)V

    .line 286
    const v0, 0x7f080008

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v5

    .line 287
    .local v5, "frameParent":Landroid/view/View;
    const v0, 0x7f08000a

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v4

    .line 288
    .local v4, "videoParent":Landroid/view/View;
    const v0, 0x7f08000b

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/AbsoluteLayout;

    .line 289
    .local v2, "videoRegionLayout":Landroid/widget/AbsoluteLayout;
    const v0, 0x7f08000c

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    .line 290
    .local v3, "vView":Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    invoke-virtual {v3, v10}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setZOrderMediaOverlay(Z)V

    .line 291
    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setParentView(Landroid/view/View;Landroid/view/View;)V

    .line 292
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVideoClient:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    if-nez v0, :cond_1

    .line 293
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;-><init>(Landroid/os/Handler;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/View;Landroid/view/View;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVideoClient:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    .line 298
    :goto_1
    const v0, 0x7f080009

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/app/JbedView;

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    .line 299
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVideoClient:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    iput-object v1, v0, Lcom/esmertec/android/jbed/app/JbedView;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .line 301
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->restoreVideoPlayer()V

    .line 303
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    iget-object v7, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mConnector:Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    invoke-virtual {v0, v1, v7}, Lcom/esmertec/android/jbed/app/JbedView;->setup(Landroid/os/Handler;Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;)V

    .line 304
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView;->requestFocus()Z

    .line 305
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    const/4 v1, -0x3

    invoke-virtual {v0, v1}, Landroid/view/Window;->setFormat(I)V

    .line 308
    new-instance v0, Landroid/widget/AbsoluteLayout$LayoutParams;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->width()I

    move-result v1

    sget-object v7, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v7}, Landroid/graphics/Rect;->height()I

    move-result v7

    sget-object v8, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    iget v8, v8, Landroid/graphics/Rect;->left:I

    sget-object v9, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    iget v9, v9, Landroid/graphics/Rect;->top:I

    invoke-direct {v0, v1, v7, v8, v9}, Landroid/widget/AbsoluteLayout$LayoutParams;-><init>(IIII)V

    invoke-virtual {v2, v0}, Landroid/widget/AbsoluteLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 314
    const v0, 0x7f08000d

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->findViewById(I)Landroid/view/View;

    move-result-object v6

    check-cast v6, Landroid/widget/AbsoluteLayout;

    .line 315
    .local v6, "nativeWidgetView":Landroid/widget/AbsoluteLayout;
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v0, v6}, Lcom/esmertec/android/jbed/app/JbedView;->setOverlayView(Landroid/widget/AbsoluteLayout;)V

    .line 316
    iput-boolean v10, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->isInitialized:Z

    goto/16 :goto_0

    .line 295
    .end local v6    # "nativeWidgetView":Landroid/widget/AbsoluteLayout;
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVideoClient:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-virtual {v0, v2, v3, v4, v5}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->updateView(Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/View;Landroid/view/View;)V

    goto :goto_1
.end method

.method private reserveVideoPlayer()V
    .locals 2

    .prologue
    .line 320
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/JbedView;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v0, :cond_0

    .line 321
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/JbedView;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    check-cast v0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->savePlayerState()V

    .line 327
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    const/4 v1, 0x4

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->dispatchWindowVisibilityChanged(I)V

    .line 328
    return-void
.end method

.method private restoreVideoPlayer()V
    .locals 2

    .prologue
    .line 331
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->dispatchWindowVisibilityChanged(I)V

    .line 332
    return-void
.end method

.method private updateTCKInfoIfNeed(Landroid/content/Intent;Landroid/content/Context;)V
    .locals 4
    .param p1, "mIntent"    # Landroid/content/Intent;
    .param p2, "context"    # Landroid/content/Context;

    .prologue
    .line 452
    invoke-virtual {p1}, Landroid/content/Intent;->getExtras()Landroid/os/Bundle;

    move-result-object v0

    .line 453
    .local v0, "b":Landroid/os/Bundle;
    if-eqz v0, :cond_0

    const-string v1, "tck_enable"

    invoke-virtual {v0, v1}, Landroid/os/Bundle;->containsKey(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 454
    invoke-static {p2}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v1

    const-string v2, "tck_url"

    invoke-virtual {v0, v2}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x1

    invoke-virtual {v1, v2, v3}, Lcom/esmertec/android/jbed/JbedSettings;->updateTckInfo(Ljava/lang/String;Z)V

    .line 455
    const-string v1, "JbedAppActivity"

    const-string v2, "Updated tck info: tck_enabled"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 457
    :cond_0
    return-void
.end method


# virtual methods
.method protected onActivityResult(IILandroid/content/Intent;)V
    .locals 1
    .param p1, "requestCode"    # I
    .param p2, "resultCode"    # I
    .param p3, "extras"    # Landroid/content/Intent;

    .prologue
    .line 426
    invoke-super {p0, p1, p2, p3}, Landroid/app/Activity;->onActivityResult(IILandroid/content/Intent;)V

    .line 427
    const/4 v0, 0x2

    if-ne p2, v0, :cond_0

    .line 428
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->finish()V

    .line 430
    :cond_0
    return-void
.end method

.method public onConfigurationChanged(Landroid/content/res/Configuration;)V
    .locals 6
    .param p1, "newConfig"    # Landroid/content/res/Configuration;

    .prologue
    const/16 v5, 0x2727

    const/4 v4, 0x1

    .line 233
    invoke-super {p0, p1}, Landroid/app/Activity;->onConfigurationChanged(Landroid/content/res/Configuration;)V

    .line 234
    const-string v1, "JbedAppActivity"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "onConfigurationChanged():"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mOrientation:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "->"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v3

    iget v3, v3, Landroid/content/res/Configuration;->orientation:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 235
    iget v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mOrientation:I

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v2

    iget v2, v2, Landroid/content/res/Configuration;->orientation:I

    if-eq v1, v2, :cond_0

    .line 236
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v1

    iget v1, v1, Landroid/content/res/Configuration;->orientation:I

    iput v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mOrientation:I

    .line 238
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    if-eqz v1, :cond_2

    .line 239
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mPaused:Z

    if-eqz v1, :cond_1

    .line 262
    :cond_0
    :goto_0
    return-void

    .line 245
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v1, v4}, Lcom/esmertec/android/jbed/app/JbedView;->setRotateHappen(Z)V

    .line 246
    iput-boolean v4, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mIsRotating:Z

    .line 249
    :cond_2
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->reserveVideoPlayer()V

    .line 256
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v5}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 257
    .local v0, "message":Landroid/os/Message;
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v5}, Landroid/os/Handler;->removeMessages(I)V

    .line 260
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    const-wide/16 v2, 0x4b0

    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->sendMessageDelayed(Landroid/os/Message;J)Z

    goto :goto_0
.end method

.method public onCreate(Landroid/os/Bundle;)V
    .locals 5
    .param p1, "icicle"    # Landroid/os/Bundle;

    .prologue
    const/4 v4, 0x1

    .line 339
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 340
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getIntent()Landroid/content/Intent;

    move-result-object v1

    .line 341
    .local v1, "intent":Landroid/content/Intent;
    const-string v2, "com.esmertec.android.jbed.action.PUSHSMS"

    invoke-virtual {v1, v2}, Landroid/content/Intent;->getExtra(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/Intent;

    sput-object v2, Lcom/esmertec/android/jbed/app/JbedAppActivity;->SmsIntent:Landroid/content/Intent;

    .line 342
    const-string v2, "isFullScreen"

    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v2

    iput-boolean v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mIsFullScreen:Z

    .line 344
    const-string v2, "JbedAppActivity"

    const-string v3, "JbedActivity onCreate "

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 346
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getWindow()Landroid/view/Window;

    move-result-object v2

    const/4 v3, -0x3

    invoke-virtual {v2, v3}, Landroid/view/Window;->setFormat(I)V

    .line 353
    invoke-virtual {p0, v4}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->requestWindowFeature(I)Z

    .line 355
    invoke-direct {p0, v4}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->initialize(Z)V

    .line 361
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getIntent()Landroid/content/Intent;

    move-result-object v2

    invoke-direct {p0, v2, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->updateTCKInfoIfNeed(Landroid/content/Intent;Landroid/content/Context;)V

    .line 363
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 364
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v2, "com.esmertec.android.jbed.action.VMSTARTED"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 365
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v2, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 367
    sput-boolean v4, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    .line 368
    return-void
.end method

.method protected onDestroy()V
    .locals 2

    .prologue
    .line 419
    const-string v0, "JbedAppActivity"

    const-string v1, "JbedActivity onDestroy"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 420
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mVmStateReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 421
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    .line 422
    return-void
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 3
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    const/4 v2, 0x1

    .line 435
    sget-boolean v1, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    if-eqz v1, :cond_0

    const/4 v1, 0x4

    if-ne p1, v1, :cond_0

    move v1, v2

    .line 438
    :goto_0
    return v1

    .line 437
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v1, p2}, Lcom/esmertec/android/jbed/app/JbedView;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    move-result v0

    .line 438
    .local v0, "isConsumed":Z
    if-eqz v0, :cond_1

    move v1, v2

    goto :goto_0

    :cond_1
    invoke-super {p0, p1, p2}, Landroid/app/Activity;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v1

    goto :goto_0
.end method

.method public onKeyUp(ILandroid/view/KeyEvent;)Z
    .locals 3
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    const/4 v2, 0x1

    .line 444
    sget-boolean v1, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    if-eqz v1, :cond_0

    const/4 v1, 0x4

    if-ne p1, v1, :cond_0

    move v1, v2

    .line 447
    :goto_0
    return v1

    .line 446
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v1, p2}, Lcom/esmertec/android/jbed/app/JbedView;->dispatchKeyEvent(Landroid/view/KeyEvent;)Z

    move-result v0

    .line 447
    .local v0, "isConsumed":Z
    if-eqz v0, :cond_1

    move v1, v2

    goto :goto_0

    :cond_1
    invoke-super {p0, p1, p2}, Landroid/app/Activity;->onKeyUp(ILandroid/view/KeyEvent;)Z

    move-result v1

    goto :goto_0
.end method

.method protected onPause()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 385
    const-string v0, "JbedAppActivity"

    const-string v1, "JbedActivity onPause"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 386
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mPaused:Z

    .line 387
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    if-eqz v0, :cond_0

    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mIsRotating:Z

    if-eqz v0, :cond_0

    .line 388
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v0, v2}, Lcom/esmertec/android/jbed/app/JbedView;->setRotateHappen(Z)V

    .line 389
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mJbedView:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView;->requestVmBackground()V

    .line 390
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mIsRotating:Z

    .line 392
    :cond_0
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->isInitialized:Z

    .line 393
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    new-instance v1, Lcom/esmertec/android/jbed/app/JbedAppActivity$5;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$5;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 408
    invoke-super {p0}, Landroid/app/Activity;->onPause()V

    .line 409
    return-void
.end method

.method protected onResume()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 372
    const-string v0, "JbedAppActivity"

    const-string v1, "JbedActivity onResume"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 373
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mPaused:Z

    .line 374
    invoke-direct {p0, v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->initialize(Z)V

    .line 375
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity;->mHandler:Landroid/os/Handler;

    new-instance v1, Lcom/esmertec/android/jbed/app/JbedAppActivity$4;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$4;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 380
    invoke-super {p0}, Landroid/app/Activity;->onResume()V

    .line 381
    return-void
.end method

.method protected onStop()V
    .locals 2

    .prologue
    .line 413
    const-string v0, "JbedAppActivity"

    const-string v1, "JbedActivity onStop"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 414
    invoke-super {p0}, Landroid/app/Activity;->onStop()V

    .line 415
    return-void
.end method
