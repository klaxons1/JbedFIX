.class Lcom/esmertec/android/jbed/ams/AmsConnection$6;
.super Ljava/lang/Object;
.source "AmsConnection.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V
    .locals 0

    .prologue
    .line 337
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onEvent(II[B)Z
    .locals 8
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const/4 v7, 0x1

    const-string v2, "AmsConnection"

    .line 340
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v1, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    .line 341
    .local v1, "event":Lcom/esmertec/android/jbed/ams/AmsEvent;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$800(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v2

    if-nez v2, :cond_0

    .line 342
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$500(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/concurrent/BlockingQueue;

    move-result-object v2

    invoke-interface {v2, v1}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 343
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$1000(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    move v2, v7

    .line 360
    :goto_0
    return v2

    .line 346
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v2

    monitor-enter v2

    .line 348
    :try_start_0
    const-string v3, "AmsConnection"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "mRequestPushFilter jbedclient="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "  mRunEventProcessing="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$200(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 350
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v3

    if-nez v3, :cond_1

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$200(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    move-result-object v3

    sget-object v4, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v3, v4, :cond_1

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v3

    if-eqz v3, :cond_1

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v3

    invoke-interface {v3}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->getId()J

    move-result-wide v3

    const-wide/16 v5, 0x0

    cmp-long v3, v3, v5

    if-eqz v3, :cond_1

    .line 352
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$500(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/concurrent/BlockingQueue;

    move-result-object v3

    invoke-interface {v3, v1}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 353
    :try_start_1
    monitor-exit v2

    move v2, v7

    goto :goto_0

    .line 355
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 356
    .local v0, "e":Landroid/os/RemoteException;
    const-string v3, "AmsConnection"

    const-string v4, "fail to call getId"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 358
    .end local v0    # "e":Landroid/os/RemoteException;
    :cond_1
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 359
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$202(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 360
    const/4 v2, 0x0

    goto :goto_0

    .line 358
    :catchall_0
    move-exception v3

    :try_start_2
    monitor-exit v2
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v3
.end method
