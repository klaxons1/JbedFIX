.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnCompletionListener;


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
    .line 460
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCompletion(Landroid/media/MediaPlayer;)V
    .locals 2
    .param p1, "mp"    # Landroid/media/MediaPlayer;

    .prologue
    .line 464
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 465
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/MediaController;->hide()V

    .line 467
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnCompletionListener;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 468
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnCompletionListener;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v1

    invoke-interface {v0, v1}, Landroid/media/MediaPlayer$OnCompletionListener;->onCompletion(Landroid/media/MediaPlayer;)V

    .line 471
    :cond_1
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2100(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    move-result-object v0

    if-eqz v0, :cond_2

    .line 472
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2100(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    move-result-object v0

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;->onCompletion()V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 477
    :cond_2
    :goto_0
    return-void

    .line 474
    :catch_0
    move-exception v0

    goto :goto_0
.end method
