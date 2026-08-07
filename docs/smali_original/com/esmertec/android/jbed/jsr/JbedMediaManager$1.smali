.class Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;
.super Ljava/lang/Object;
.source "JbedMediaManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)V
    .locals 0

    .prologue
    .line 67
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
    .locals 6
    .param p1, "client"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 71
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v4

    monitor-enter v4

    .line 72
    :try_start_0
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-static {v5, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$102(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 73
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-virtual {v5}, Ljava/util/HashMap;->values()Ljava/util/Collection;

    move-result-object v5

    invoke-interface {v5}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_2

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 74
    .local v2, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    instance-of v5, v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    if-eqz v5, :cond_0

    .line 75
    move-object v0, v2

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    move-object v3, v0

    .line 76
    .local v3, "proxy":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->access$200(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    move-result-object v5

    iget-boolean v5, v5, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    if-eqz v5, :cond_1

    .line 77
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v5

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v5

    invoke-virtual {v3, v5}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->updateVideoClient(Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 79
    :cond_1
    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->access$300(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Z

    move-result v5

    if-eqz v5, :cond_0

    .line 80
    invoke-virtual {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->restoreState()V

    .line 86
    .end local v2    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .end local v3    # "proxy":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
    :cond_2
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Object;->notifyAll()V

    .line 87
    monitor-exit v4

    .line 88
    return-void

    .line 87
    .end local v1    # "i$":Ljava/util/Iterator;
    :catchall_0
    move-exception v5

    monitor-exit v4
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v5
.end method

.method public onClientDetached()V
    .locals 7

    .prologue
    .line 92
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v4

    monitor-enter v4

    .line 93
    :try_start_0
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    const/4 v6, 0x0

    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$102(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 94
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-virtual {v5}, Ljava/util/HashMap;->values()Ljava/util/Collection;

    move-result-object v5

    invoke-interface {v5}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 95
    .local v2, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    instance-of v5, v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    if-eqz v5, :cond_0

    .line 96
    move-object v0, v2

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    move-object v3, v0

    .line 97
    .local v3, "proxy":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->access$200(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    move-result-object v5

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DOING:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v5, v6, :cond_0

    .line 98
    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->access$200(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    move-result-object v5

    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v6, v5, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    goto :goto_0

    .line 102
    .end local v1    # "i$":Ljava/util/Iterator;
    .end local v2    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .end local v3    # "proxy":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
    :catchall_0
    move-exception v5

    monitor-exit v4
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v5

    .restart local v1    # "i$":Ljava/util/Iterator;
    :cond_1
    :try_start_1
    monitor-exit v4
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 103
    return-void
.end method
