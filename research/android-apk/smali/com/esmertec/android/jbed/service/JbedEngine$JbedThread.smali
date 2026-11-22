.class Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;
.super Ljava/lang/Thread;
.source "JbedEngine.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedEngine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "JbedThread"
.end annotation


# instance fields
.field private mBytesPerPixel:I

.field mIsVmInitialized:Z

.field private mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/BlockingQueue",
            "<",
            "Ljava/lang/Runnable;",
            ">;"
        }
    .end annotation
.end field

.field private mViewFullScreenHeight:I

.field private mViewFullScreenWidth:I

.field private mViewHeight:I

.field private mViewWidth:I

.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 2

    .prologue
    const/4 v1, -0x1

    .line 413
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    .line 414
    const-string v0, "JbedThread"

    invoke-direct {p0, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/String;)V

    .line 396
    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewWidth:I

    .line 398
    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewHeight:I

    .line 400
    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mBytesPerPixel:I

    .line 402
    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenWidth:I

    .line 404
    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenHeight:I

    .line 407
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mIsVmInitialized:Z

    .line 410
    new-instance v0, Ljava/util/concurrent/LinkedBlockingQueue;

    invoke-direct {v0}, Ljava/util/concurrent/LinkedBlockingQueue;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    .line 415
    return-void
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)Ljava/util/concurrent/BlockingQueue;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    return-object v0
.end method

.method static synthetic access$1100(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;IIIIIZZ)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;
    .param p1, "x1"    # I
    .param p2, "x2"    # I
    .param p3, "x3"    # I
    .param p4, "x4"    # I
    .param p5, "x5"    # I
    .param p6, "x6"    # Z
    .param p7, "x7"    # Z

    .prologue
    .line 395
    invoke-direct/range {p0 .. p7}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->setScreenInfo(IIIIIZZ)V

    return-void
.end method

.method static synthetic access$1200(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewWidth:I

    return v0
.end method

.method static synthetic access$1300(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewHeight:I

    return v0
.end method

.method static synthetic access$1400(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mBytesPerPixel:I

    return v0
.end method

.method static synthetic access$1500(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenWidth:I

    return v0
.end method

.method static synthetic access$1600(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    .prologue
    .line 395
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenHeight:I

    return v0
.end method

.method private setScreenInfo(IIIIIZZ)V
    .locals 14
    .param p1, "viewWidth"    # I
    .param p2, "viewHeight"    # I
    .param p3, "bytesPerPixel"    # I
    .param p4, "viewFullScreenWidth"    # I
    .param p5, "viewFullScreenHeight"    # I
    .param p6, "isVmRunning"    # Z
    .param p7, "forceSizeChanged"    # Z

    .prologue
    .line 433
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$700(Lcom/esmertec/android/jbed/service/JbedEngine;)Landroid/content/Context;

    move-result-object v2

    const-string v3, "window"

    invoke-virtual {v2, v3}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v13

    check-cast v13, Landroid/view/WindowManager;

    .line 434
    .local v13, "windowManager":Landroid/view/WindowManager;
    invoke-interface {v13}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v9

    .line 435
    .local v9, "display":Landroid/view/Display;
    invoke-virtual {v9}, Landroid/view/Display;->getHeight()I

    move-result v10

    .line 436
    .local v10, "screenHeight":I
    invoke-virtual {v9}, Landroid/view/Display;->getWidth()I

    move-result v11

    .line 437
    .local v11, "screenWidth":I
    invoke-static {v10, v11}, Ljava/lang/Math;->max(II)I

    move-result v8

    .line 439
    .local v8, "maxSquareLength":I
    if-lez p1, :cond_0

    if-lez p2, :cond_0

    if-lez p4, :cond_0

    if-gtz p5, :cond_1

    .line 440
    :cond_0
    new-instance v2, Ljava/lang/IllegalArgumentException;

    const-string v3, "setScreenInfo() invalid screen size!!!!"

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 442
    :cond_1
    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewWidth:I

    if-ne v2, p1, :cond_2

    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewHeight:I

    move v0, v2

    move/from16 v1, p2

    if-ne v0, v1, :cond_2

    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenWidth:I

    move v0, v2

    move/from16 v1, p4

    if-ne v0, v1, :cond_2

    iget v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenHeight:I

    move v0, v2

    move/from16 v1, p5

    if-eq v0, v1, :cond_5

    :cond_2
    const/4 v2, 0x1

    move v12, v2

    .line 446
    .local v12, "sizeChanged":Z
    :goto_0
    iput p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewWidth:I

    .line 447
    move/from16 v0, p2

    move-object v1, p0

    iput v0, v1, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewHeight:I

    .line 448
    move/from16 v0, p3

    move-object v1, p0

    iput v0, v1, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mBytesPerPixel:I

    .line 449
    move/from16 v0, p4

    move-object v1, p0

    iput v0, v1, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenWidth:I

    .line 450
    move/from16 v0, p5

    move-object v1, p0

    iput v0, v1, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mViewFullScreenHeight:I

    .line 451
    if-nez v12, :cond_3

    if-eqz p7, :cond_4

    .line 452
    :cond_3
    const-string v2, "JbedEngine"

    const-string v3, "setScreenInfo(): Size changed!!"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 453
    if-eqz p6, :cond_6

    .line 454
    const-string v2, "JbedEngine"

    const-string v3, "Pending screen size change"

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 459
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    new-instance v3, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;

    invoke-direct {v3, p0, v8}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;I)V

    invoke-interface {v2, v3}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 464
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$300(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 470
    :cond_4
    :goto_1
    return-void

    .line 442
    .end local v12    # "sizeChanged":Z
    :cond_5
    const/4 v2, 0x0

    move v12, v2

    goto :goto_0

    .line 466
    .restart local v12    # "sizeChanged":Z
    :cond_6
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v5, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mBytesPerPixel:I

    move v3, p1

    move/from16 v4, p2

    move/from16 v6, p4

    move/from16 v7, p5

    invoke-static/range {v2 .. v8}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$1700(Lcom/esmertec/android/jbed/service/JbedEngine;IIIIII)V

    goto :goto_1
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    const/4 v6, 0x0

    const-string v7, "JbedEngine"

    .line 473
    const-string v3, "JbedEngine"

    const-string v3, "Jbed Thread Started"

    invoke-static {v7, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 477
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v4, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v4}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$1800(Lcom/esmertec/android/jbed/service/JbedEngine;)[Ljava/lang/String;

    move-result-object v4

    const/16 v5, 0x32

    invoke-static {v3, v4, v5}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$1900(Lcom/esmertec/android/jbed/service/JbedEngine;[Ljava/lang/String;I)V

    .line 479
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    const/4 v4, 0x2

    invoke-virtual {v3, v4}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v3

    invoke-virtual {v3}, Landroid/os/Message;->sendToTarget()V

    .line 484
    :cond_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2000(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 486
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2100(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 488
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    const/4 v4, 0x3

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2200(Lcom/esmertec/android/jbed/service/JbedEngine;I)V

    .line 491
    :cond_1
    :goto_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2300(Lcom/esmertec/android/jbed/service/JbedEngine;)Z

    move-result v3

    if-nez v3, :cond_4

    .line 497
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3, v6}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2402(Lcom/esmertec/android/jbed/service/JbedEngine;Z)Z

    .line 498
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2500(Lcom/esmertec/android/jbed/service/JbedEngine;)I

    move-result v0

    .line 506
    .local v0, "delay":I
    const/16 v3, 0xa

    if-lt v0, v3, :cond_3

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2300(Lcom/esmertec/android/jbed/service/JbedEngine;)Z

    move-result v3

    if-nez v3, :cond_3

    .line 507
    monitor-enter p0

    .line 514
    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2400(Lcom/esmertec/android/jbed/service/JbedEngine;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result v3

    if-nez v3, :cond_2

    .line 520
    int-to-long v3, v0

    const/4 v5, 0x0

    :try_start_1
    invoke-virtual {p0, v3, v4, v5}, Ljava/lang/Object;->wait(JI)V
    :try_end_1
    .catch Ljava/lang/InterruptedException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 525
    :cond_2
    :goto_1
    :try_start_2
    monitor-exit p0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 531
    :cond_3
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mPendingEventQueue:Ljava/util/concurrent/BlockingQueue;

    invoke-interface {v3}, Ljava/util/concurrent/BlockingQueue;->poll()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Runnable;

    .line 532
    .local v2, "r":Ljava/lang/Runnable;
    if-eqz v2, :cond_1

    .line 533
    invoke-interface {v2}, Ljava/lang/Runnable;->run()V

    goto :goto_0

    .line 521
    .end local v2    # "r":Ljava/lang/Runnable;
    :catch_0
    move-exception v1

    .line 522
    .local v1, "e":Ljava/lang/InterruptedException;
    :try_start_3
    invoke-virtual {v1}, Ljava/lang/InterruptedException;->printStackTrace()V

    goto :goto_1

    .line 525
    .end local v1    # "e":Ljava/lang/InterruptedException;
    :catchall_0
    move-exception v3

    monitor-exit p0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v3

    .line 537
    .end local v0    # "delay":I
    :cond_4
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3, v6}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2302(Lcom/esmertec/android/jbed/service/JbedEngine;Z)Z

    .line 538
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2600(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 539
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2700(Lcom/esmertec/android/jbed/service/JbedEngine;)Z

    move-result v3

    if-nez v3, :cond_0

    .line 540
    const-string v3, "JbedEngine"

    const-string v3, "--------- JBED SHUT DOWN ---------"

    invoke-static {v7, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 543
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2800(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    .line 546
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v3

    invoke-virtual {v3}, Landroid/os/Message;->sendToTarget()V

    .line 547
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v3, v6}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$2900(Lcom/esmertec/android/jbed/service/JbedEngine;Z)V

    .line 548
    return-void
.end method

.method startAndWait()V
    .locals 1

    .prologue
    .line 421
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mIsVmInitialized:Z

    .line 422
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->start()V

    .line 423
    monitor-enter p0

    .line 425
    :try_start_0
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->mIsVmInitialized:Z

    if-nez v0, :cond_0

    invoke-virtual {p0}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 427
    :cond_0
    :goto_0
    :try_start_1
    monitor-exit p0

    .line 428
    return-void

    .line 427
    :catchall_0
    move-exception v0

    monitor-exit p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v0

    .line 426
    :catch_0
    move-exception v0

    goto :goto_0
.end method
