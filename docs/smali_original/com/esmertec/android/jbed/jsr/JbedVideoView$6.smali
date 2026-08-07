.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnBufferingUpdateListener;


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
    .line 532
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onBufferingUpdate(Landroid/media/MediaPlayer;I)V
    .locals 1
    .param p1, "mp"    # Landroid/media/MediaPlayer;
    .param p2, "percent"    # I

    .prologue
    .line 534
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$6;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, p2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2502(Lcom/esmertec/android/jbed/jsr/JbedVideoView;I)I

    .line 535
    return-void
.end method
