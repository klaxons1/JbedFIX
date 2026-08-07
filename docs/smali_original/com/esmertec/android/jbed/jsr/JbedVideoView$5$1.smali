.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->onError(Landroid/media/MediaPlayer;II)Z
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;)V
    .locals 0

    .prologue
    .line 514
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 519
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnCompletionListener;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 520
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2000(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnCompletionListener;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v1

    invoke-interface {v0, v1}, Landroid/media/MediaPlayer$OnCompletionListener;->onCompletion(Landroid/media/MediaPlayer;)V

    .line 522
    :cond_0
    return-void
.end method
