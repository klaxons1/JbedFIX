.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnPreparedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V
    .locals 0

    .prologue
    .line 400
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onPrepared(Landroid/media/MediaPlayer;)V
    .locals 5
    .param p1, "mp"    # Landroid/media/MediaPlayer;

    .prologue
    const/4 v4, 0x1

    const/4 v3, 0x0

    .line 405
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1402(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z

    .line 407
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnPreparedListener;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 408
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnPreparedListener;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v1

    invoke-interface {v0, v1}, Landroid/media/MediaPlayer$OnPreparedListener;->onPrepared(Landroid/media/MediaPlayer;)V

    .line 410
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 411
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/widget/MediaController;->setEnabled(Z)V

    .line 414
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {p1}, Landroid/media/MediaPlayer;->getVideoWidth()I

    move-result v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 415
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {p1}, Landroid/media/MediaPlayer;->getVideoHeight()I

    move-result v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 416
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_7

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_7

    .line 418
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v2

    invoke-interface {v0, v1, v2}, Landroid/view/SurfaceHolder;->setFixedSize(II)V

    .line 420
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_2

    .line 421
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v1

    invoke-virtual {v0, v1}, Landroid/media/MediaPlayer;->seekTo(I)V

    .line 422
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 424
    :cond_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Z

    move-result v0

    if-eqz v0, :cond_5

    .line 425
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->start()V

    .line 426
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z

    .line 427
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_3

    .line 428
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/MediaController;->show()V

    .line 437
    :cond_3
    :goto_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1202(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z

    .line 438
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 441
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->notifyAll()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 443
    :goto_1
    :try_start_1
    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 456
    :cond_4
    :goto_2
    return-void

    .line 430
    :cond_5
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->isPlaying()Z

    move-result v0

    if-nez v0, :cond_3

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-nez v0, :cond_6

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getCurrentPosition()I

    move-result v0

    if-lez v0, :cond_3

    .line 431
    :cond_6
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_3

    .line 433
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0, v3}, Landroid/widget/MediaController;->show(I)V

    goto :goto_0

    .line 443
    :catchall_0
    move-exception v1

    :try_start_2
    monitor-exit v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v1

    .line 447
    :cond_7
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_8

    .line 448
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v1

    invoke-virtual {v0, v1}, Landroid/media/MediaPlayer;->seekTo(I)V

    .line 449
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 451
    :cond_8
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Z

    move-result v0

    if-eqz v0, :cond_4

    .line 452
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->start()V

    .line 453
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z

    goto :goto_2

    .line 442
    :catch_0
    move-exception v1

    goto :goto_1
.end method
