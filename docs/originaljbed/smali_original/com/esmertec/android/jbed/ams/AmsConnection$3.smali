.class Lcom/esmertec/android/jbed/ams/AmsConnection$3;
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
    .line 199
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

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
    const/16 v1, 0xb

    const/4 v4, 0x0

    const-string v5, "AmsConnection"

    .line 204
    const/16 v0, 0x12

    if-eq p1, v0, :cond_0

    if-eq p1, v1, :cond_0

    const/16 v0, 0x11

    if-ne p1, v0, :cond_1

    .line 205
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$600(Lcom/esmertec/android/jbed/ams/AmsConnection;II[B)V

    .line 208
    :cond_1
    if-ne p1, v1, :cond_5

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$700(Lcom/esmertec/android/jbed/ams/AmsConnection;)Z

    move-result v0

    if-nez v0, :cond_5

    .line 211
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v0

    invoke-interface {v0}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient;->getId()J
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-wide v0

    const-wide/16 v2, 0x0

    cmp-long v0, v0, v2

    if-eqz v0, :cond_2

    move v0, v4

    .line 233
    :goto_0
    return v0

    .line 213
    :catch_0
    move-exception v0

    .line 216
    :cond_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    if-nez v0, :cond_3

    .line 217
    const-string v0, "AmsConnection"

    const-string v0, "mLifeCycleFilter onEvent() EVENT_DESTROYED it\'s special case"

    invoke-static {v5, v0}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    move v0, v4

    .line 218
    goto :goto_0

    .line 221
    :cond_3
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 222
    :goto_1
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    if-nez v1, :cond_4

    .line 224
    const-string v1, "AmsConnection"

    const-string v2, "want to finish jbed app activity, but it\'s unavailable! wait for a while! "

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsWarning(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 226
    :try_start_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->wait()V
    :try_end_2
    .catch Ljava/lang/InterruptedException; {:try_start_2 .. :try_end_2} :catch_1
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_1

    .line 227
    :catch_1
    move-exception v1

    goto :goto_1

    .line 230
    :cond_4
    :try_start_3
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->finish()V

    .line 231
    monitor-exit v0

    :cond_5
    move v0, v4

    .line 233
    goto :goto_0

    .line 231
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v1
.end method
