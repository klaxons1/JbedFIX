.class Lcom/esmertec/android/jbed/ams/AmsConnection$1;
.super Ljava/lang/Object;
.source "AmsConnection.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;


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
    .line 77
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
    .locals 3
    .param p1, "client"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 80
    const-string v0, "AmsConnection"

    const-string v1, "onClientAttached"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 81
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 82
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1, p1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$102(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 83
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$200(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    if-ne v1, v2, :cond_0

    .line 84
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$202(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    .line 86
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->notify()V

    .line 87
    monitor-exit v0

    .line 88
    return-void

    .line 87
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public onClientDetached()V
    .locals 3

    .prologue
    .line 91
    const-string v0, "AmsConnection"

    const-string v1, "onClientDetached"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 92
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 93
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    const/4 v2, 0x0

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$102(Lcom/esmertec/android/jbed/ams/AmsConnection;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 94
    monitor-exit v0

    .line 95
    return-void

    .line 94
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method
