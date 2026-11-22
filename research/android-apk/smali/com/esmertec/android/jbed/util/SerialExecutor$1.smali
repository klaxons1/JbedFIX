.class Lcom/esmertec/android/jbed/util/SerialExecutor$1;
.super Ljava/lang/Object;
.source "SerialExecutor.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/util/SerialExecutor;->execute(Landroid/os/Handler;Ljava/lang/Runnable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

.field final synthetic val$r:Ljava/lang/Runnable;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/util/SerialExecutor;Ljava/lang/Runnable;)V
    .locals 0

    .prologue
    .line 21
    iput-object p1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    iput-object p2, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->val$r:Ljava/lang/Runnable;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 24
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->val$r:Ljava/lang/Runnable;

    invoke-interface {v0}, Ljava/lang/Runnable;->run()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 26
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    monitor-enter v0

    .line 27
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    invoke-virtual {v1}, Ljava/lang/Object;->notify()V

    .line 28
    iget-object v1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    const/4 v2, 0x1

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/util/SerialExecutor;->access$002(Lcom/esmertec/android/jbed/util/SerialExecutor;Z)Z

    .line 29
    monitor-exit v0

    .line 31
    return-void

    .line 29
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v1

    .line 26
    :catchall_1
    move-exception v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    monitor-enter v1

    .line 27
    :try_start_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 28
    iget-object v2, p0, Lcom/esmertec/android/jbed/util/SerialExecutor$1;->this$0:Lcom/esmertec/android/jbed/util/SerialExecutor;

    const/4 v3, 0x1

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/util/SerialExecutor;->access$002(Lcom/esmertec/android/jbed/util/SerialExecutor;Z)Z

    .line 29
    monitor-exit v1
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_2

    throw v0

    :catchall_2
    move-exception v0

    :try_start_3
    monitor-exit v1
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    throw v0
.end method
