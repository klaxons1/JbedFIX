.class Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;
.super Ljava/lang/Thread;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "JbedPainter"
.end annotation


# instance fields
.field public mHandler:Landroid/os/Handler;

.field private mIsAlive:Z

.field private mIsShutDown:Z

.field private mLooper:Landroid/os/Looper;

.field private mPendingQueue:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList",
            "<",
            "Landroid/os/Message;",
            ">;"
        }
    .end annotation
.end field

.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedView;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/app/JbedView;)V
    .locals 1

    .prologue
    .line 385
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    .line 386
    const-string v0, "[JbedPainter]"

    invoke-direct {p0, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/String;)V

    .line 383
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mIsAlive:Z

    .line 387
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;

    .line 388
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;

    invoke-direct {v0, p0, p1}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;-><init>(Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;Lcom/esmertec/android/jbed/app/JbedView;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mHandler:Landroid/os/Handler;

    .line 405
    return-void
.end method

.method static synthetic access$1002(Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;
    .param p1, "x1"    # Z

    .prologue
    .line 373
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mIsShutDown:Z

    return p1
.end method


# virtual methods
.method public declared-synchronized handleOrEnqueue(Landroid/os/Message;)V
    .locals 1
    .param p1, "message"    # Landroid/os/Message;

    .prologue
    .line 430
    monitor-enter p0

    :try_start_0
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mIsShutDown:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz v0, :cond_1

    .line 439
    :cond_0
    :goto_0
    monitor-exit p0

    return-void

    .line 433
    :cond_1
    :try_start_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;

    if-eqz v0, :cond_2

    .line 434
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;

    invoke-virtual {v0, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_0

    .line 430
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0

    .line 437
    :cond_2
    :try_start_2
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mIsAlive:Z

    if-eqz v0, :cond_0

    invoke-virtual {p1}, Landroid/os/Message;->sendToTarget()V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_0
.end method

.method public quit()V
    .locals 1

    .prologue
    .line 414
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mIsAlive:Z

    .line 415
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mLooper:Landroid/os/Looper;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mLooper:Landroid/os/Looper;

    invoke-virtual {v0}, Landroid/os/Looper;->quit()V

    .line 416
    :cond_0
    return-void
.end method

.method public run()V
    .locals 1

    .prologue
    .line 408
    invoke-static {}, Landroid/os/Looper;->prepare()V

    .line 409
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mLooper:Landroid/os/Looper;

    .line 410
    invoke-static {}, Landroid/os/Looper;->loop()V

    .line 411
    return-void
.end method

.method public declared-synchronized runPendingMessages()V
    .locals 3

    .prologue
    .line 419
    monitor-enter p0

    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v2, :cond_0

    .line 426
    :goto_0
    monitor-exit p0

    return-void

    .line 421
    :cond_0
    :try_start_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/os/Message;

    .line 422
    .local v1, "message":Landroid/os/Message;
    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_1

    .line 419
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "message":Landroid/os/Message;
    :catchall_0
    move-exception v2

    monitor-exit p0

    throw v2

    .line 424
    .restart local v0    # "i$":Ljava/util/Iterator;
    :cond_1
    :try_start_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->clear()V

    .line 425
    const/4 v2, 0x0

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mPendingQueue:Ljava/util/ArrayList;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_0
.end method
