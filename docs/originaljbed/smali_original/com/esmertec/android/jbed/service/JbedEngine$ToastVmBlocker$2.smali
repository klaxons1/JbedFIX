.class Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$2;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->requestBlockVm()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)V
    .locals 0

    .prologue
    .line 248
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$2;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 251
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$2;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->access$900(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    monitor-enter v0
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_0

    .line 252
    const-wide/16 v1, 0xdac

    :try_start_1
    invoke-static {v1, v2}, Ljava/lang/Thread;->sleep(J)V

    .line 253
    monitor-exit v0

    .line 256
    :goto_0
    return-void

    .line 253
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    throw v1
    :try_end_2
    .catch Ljava/lang/InterruptedException; {:try_start_2 .. :try_end_2} :catch_0

    .line 254
    :catch_0
    move-exception v0

    goto :goto_0
.end method
