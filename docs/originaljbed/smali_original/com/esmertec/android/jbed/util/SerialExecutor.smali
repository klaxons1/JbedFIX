.class public Lcom/esmertec/android/jbed/util/SerialExecutor;
.super Ljava/lang/Object;
.source "SerialExecutor.java"


# instance fields
.field private mIsDone:Z


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 14
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/util/SerialExecutor;->mIsDone:Z

    return-void
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/util/SerialExecutor;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/util/SerialExecutor;
    .param p1, "x1"    # Z

    .prologue
    .line 12
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor;->mIsDone:Z

    return p1
.end method


# virtual methods
.method public execute(Landroid/os/Handler;Ljava/lang/Runnable;)V
    .locals 2
    .param p1, "handler"    # Landroid/os/Handler;
    .param p2, "r"    # Ljava/lang/Runnable;

    .prologue
    .line 21
    new-instance v0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;

    invoke-direct {v0, p0, p2}, Lcom/esmertec/android/jbed/util/SerialExecutor$1;-><init>(Lcom/esmertec/android/jbed/util/SerialExecutor;Ljava/lang/Runnable;)V

    .line 33
    .local v0, "myRunnable":Ljava/lang/Runnable;
    invoke-virtual {p1, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 34
    monitor-enter p0

    .line 35
    :try_start_0
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor;->mIsDone:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v1, :cond_0

    .line 38
    :try_start_1
    invoke-virtual {p0}, Ljava/lang/Object;->wait()V
    :try_end_1
    .catch Ljava/lang/InterruptedException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 42
    :cond_0
    :goto_0
    :try_start_2
    monitor-exit p0

    .line 43
    return-void

    .line 42
    :catchall_0
    move-exception v1

    monitor-exit p0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v1

    .line 39
    :catch_0
    move-exception v1

    goto :goto_0
.end method
