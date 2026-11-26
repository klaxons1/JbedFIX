.class final Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;
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
    name = "RawPictureCallback"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V
    .locals 0

    .prologue
    .line 806
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/jsr/JbedVideoView$1;

    .prologue
    .line 806
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$RawPictureCallback;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V

    return-void
.end method


# virtual methods
.method public onPictureTaken([BLandroid/hardware/Camera;)V
    .locals 0
    .param p1, "rawData"    # [B
    .param p2, "camera"    # Landroid/hardware/Camera;

    .prologue
    .line 809
    return-void
.end method
