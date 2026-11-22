.class Lcom/esmertec/android/jbed/ams/AmsConnection$4;
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
    .line 258
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onEvent(II[B)Z
    .locals 6
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const/4 v5, 0x1

    const-string v4, "AmsConnection"

    .line 260
    if-eq p2, v5, :cond_1

    .line 261
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$200(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    move-result-object v2

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v2, v3, :cond_0

    .line 262
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$202(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 264
    :cond_0
    const/4 v2, 0x0

    .line 293
    :goto_0
    return v2

    .line 268
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$800(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v2

    if-nez v2, :cond_4

    .line 272
    new-instance v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    new-instance v2, Ljava/lang/String;

    invoke-direct {v2, p3}, Ljava/lang/String;-><init>([B)V

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2, v5}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;I)V

    .line 274
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$900(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/List;

    move-result-object v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$900(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_3

    :cond_2
    if-ne p2, v5, :cond_3

    .line 275
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$1000(Lcom/esmertec/android/jbed/ams/AmsConnection;)V

    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_3
    :goto_1
    move v2, v5

    .line 293
    goto :goto_0

    .line 279
    :cond_4
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v2

    invoke-interface {v2, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->handleEvent(II[B)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 283
    :goto_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v2

    monitor-enter v2

    .line 284
    :try_start_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    move-result-object v3

    if-nez v3, :cond_5

    .line 286
    :try_start_2
    const-string v3, "AmsConnection"

    const-string v4, "mRunFilter(): block vm to wait the jbedclient ready!"

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 287
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->wait()V

    .line 288
    const-string v3, "AmsConnection"

    const-string v4, "mRunFilter(): wakeup vm since jbedclient is ready!"

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 291
    :cond_5
    :goto_3
    :try_start_3
    monitor-exit v2

    goto :goto_1

    :catchall_0
    move-exception v3

    monitor-exit v2
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v3

    .line 280
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 281
    .local v0, "e":Landroid/os/RemoteException;
    const-string v2, "AmsConnection"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " faile to handle the ams event "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_2

    .line 289
    .end local v0    # "e":Landroid/os/RemoteException;
    :catch_1
    move-exception v3

    goto :goto_3
.end method
