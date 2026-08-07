.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/view/SurfaceHolder$Callback;


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
    .line 570
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public surfaceChanged(Landroid/view/SurfaceHolder;III)V
    .locals 2
    .param p1, "holder"    # Landroid/view/SurfaceHolder;
    .param p2, "format"    # I
    .param p3, "w"    # I
    .param p4, "h"    # I

    .prologue
    .line 573
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, p3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2602(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 574
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, p4}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2702(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 575
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1400(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-ne v0, p3, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$900(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-ne v0, p4, :cond_1

    .line 576
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 577
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1800(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)I

    move-result v1

    invoke-virtual {v0, v1}, Landroid/media/MediaPlayer;->seekTo(I)V

    .line 578
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 581
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 582
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/MediaController;->show()V

    .line 585
    :cond_1
    return-void
.end method

.method public surfaceCreated(Landroid/view/SurfaceHolder;)V
    .locals 1
    .param p1, "holder"    # Landroid/view/SurfaceHolder;

    .prologue
    .line 589
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$302(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/SurfaceHolder;)Landroid/view/SurfaceHolder;

    .line 590
    return-void
.end method

.method public surfaceDestroyed(Landroid/view/SurfaceHolder;)V
    .locals 2
    .param p1, "holder"    # Landroid/view/SurfaceHolder;

    .prologue
    const/4 v1, 0x0

    .line 595
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$302(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/view/SurfaceHolder;)Landroid/view/SurfaceHolder;

    .line 596
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/MediaController;->hide()V

    .line 597
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 598
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->reset()V

    .line 599
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v0

    invoke-virtual {v0}, Landroid/media/MediaPlayer;->release()V

    .line 600
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$7;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1602(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Landroid/media/MediaPlayer;)Landroid/media/MediaPlayer;

    .line 602
    :cond_1
    return-void
.end method
