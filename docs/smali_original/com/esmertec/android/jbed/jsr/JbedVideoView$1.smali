.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resume(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

.field final synthetic val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    .locals 0

    .prologue
    .line 278
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    const/4 v7, 0x0

    const-string v3, "JbedVideoView"

    .line 281
    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/SurfaceHolder;

    move-result-object v3

    if-nez v3, :cond_1

    .line 282
    const-string v3, "JbedVideoView"

    const/4 v4, 0x5

    invoke-static {v3, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v3

    if-eqz v3, :cond_0

    const-string v3, "JbedVideoView"

    const-string v4, "mSurfaceHolder still is not avaialbe!wait a while"

    invoke-static {v3, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 284
    :cond_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-virtual {v3, v4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resume(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 317
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3, v7}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 319
    :goto_0
    return-void

    .line 287
    :cond_1
    :try_start_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v3, v3, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v3, :cond_5

    .line 290
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v1, v3, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    .line 291
    .local v1, "recordpath":Ljava/lang/String;
    invoke-virtual {v1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v1

    .line 292
    const-string v3, "capture://video"

    invoke-virtual {v1, v3}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_3

    .line 293
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    const/16 v4, 0xf

    invoke-virtual {v1, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$402(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Ljava/lang/String;)Ljava/lang/String;

    .line 297
    :cond_2
    :goto_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->closeCamera()V

    .line 298
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->openCamera()Z

    .line 301
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)[B

    move-result-object v3

    monitor-enter v3
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 302
    :try_start_2
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)[B

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Object;->notify()V

    .line 303
    monitor-exit v3
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 317
    .end local v1    # "recordpath":Ljava/lang/String;
    :goto_2
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3, v7}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    goto :goto_0

    .line 295
    .restart local v1    # "recordpath":Ljava/lang/String;
    :cond_3
    :try_start_3
    const-string v3, "JbedVideoView"

    const/4 v4, 0x5

    invoke-static {v3, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v3

    if-eqz v3, :cond_2

    const-string v3, "JbedVideoView"

    const-string v4, "record path is invalid, can not be resumed!"

    invoke-static {v3, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    goto :goto_1

    .line 307
    .end local v1    # "recordpath":Ljava/lang/String;
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 308
    .local v0, "e":Ljava/lang/Exception;
    :try_start_4
    const-string v3, "JbedVideoView"

    const/4 v4, 0x5

    invoke-static {v3, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v3

    if-eqz v3, :cond_4

    const-string v3, "JbedVideoView"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Exception is thrown when restorePlayer():"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 314
    :cond_4
    const/4 v3, 0x6

    const/16 v4, 0x15

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getString(II)Ljava/lang/String;

    move-result-object v2

    .line 315
    .local v2, "s":Ljava/lang/String;
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;

    move-result-object v3

    const/4 v4, 0x1

    invoke-static {v3, v2, v4}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/Toast;->show()V
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    .line 317
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3, v7}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    goto/16 :goto_0

    .line 303
    .end local v0    # "e":Ljava/lang/Exception;
    .end local v2    # "s":Ljava/lang/String;
    .restart local v1    # "recordpath":Ljava/lang/String;
    :catchall_0
    move-exception v4

    :try_start_5
    monitor-exit v3
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    :try_start_6
    throw v4
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_0
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    .line 317
    .end local v1    # "recordpath":Ljava/lang/String;
    :catchall_1
    move-exception v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v4, v7}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    throw v3

    .line 305
    :cond_5
    :try_start_7
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-object v4, v4, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget v5, v5, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;->val$state:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    iget-boolean v6, v6, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    invoke-virtual {v3, v4, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->resumeVideoPlay(Ljava/lang/String;IZ)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_0
    .catchall {:try_start_7 .. :try_end_7} :catchall_1

    goto :goto_2
.end method
