.class final Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/hardware/Camera$PictureCallback;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "JpegPictureCallback"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V
    .locals 0

    .prologue
    .line 813
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;

    .prologue
    .line 813
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    return-void
.end method


# virtual methods
.method public onPictureTaken([BLandroid/hardware/Camera;)V
    .locals 2
    .param p1, "rawData"    # [B
    .param p2, "camera"    # Landroid/hardware/Camera;

    .prologue
    .line 817
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2802(Lcom/esmertec/android/jbed/jsr/JbedVideoView;[B)[B

    .line 821
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)[B

    move-result-object v0

    monitor-enter v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 822
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$JpegPictureCallback;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$500(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)[B

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->notify()V

    .line 823
    monitor-exit v0

    .line 827
    :goto_0
    return-void

    .line 823
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    throw v1
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 824
    :catch_0
    move-exception v0

    goto :goto_0
.end method
