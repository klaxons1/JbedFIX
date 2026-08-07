.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnVideoSizeChangedListener;


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
    .line 376
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onVideoSizeChanged(Landroid/media/MediaPlayer;II)V
    .locals 4
    .param p1, "mp"    # Landroid/media/MediaPlayer;
    .param p2, "width"    # I
    .param p3, "height"    # I

    .prologue
    const/4 v3, 0x0

    .line 378
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {p1}, Landroid/media/MediaPlayer;->getVideoWidth()I

    move-result v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 379
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {p1}, Landroid/media/MediaPlayer;->getVideoHeight()I

    move-result v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$902(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 380
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_1

    .line 381
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v2

    invoke-interface {v0, v1, v2}, Landroid/view/SurfaceHolder;->setFixedSize(II)V

    .line 382
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->isPlaying()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 384
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v0, v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setVisibility(I)V

    .line 385
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0, v3}, Landroid/view/View;->setVisibility(I)V

    .line 386
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1100(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/View;->invalidate()V

    .line 388
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1202(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Z)Z

    .line 389
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 393
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->notifyAll()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 395
    :goto_0
    :try_start_1
    monitor-exit v0

    .line 397
    :cond_1
    return-void

    .line 395
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v1

    .line 394
    :catch_0
    move-exception v1

    goto :goto_0
.end method
