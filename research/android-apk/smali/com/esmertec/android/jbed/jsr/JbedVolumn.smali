.class Lcom/esmertec/android/jbed/jsr/JbedVolumn;
.super Ljava/lang/Object;
.source "JbedMediaPlayer.java"


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 428
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static getVol()I
    .locals 1

    .prologue
    .line 430
    const/4 v0, 0x3

    invoke-static {v0}, Landroid/media/AudioSystem;->getStreamVolumeIndex(I)I

    move-result v0

    return v0
.end method

.method public static setVol(I)I
    .locals 1
    .param p0, "vol"    # I

    .prologue
    const/4 v0, 0x3

    .line 434
    invoke-static {v0, p0}, Landroid/media/AudioSystem;->setStreamVolumeIndex(II)I

    .line 435
    invoke-static {v0}, Landroid/media/AudioSystem;->getStreamVolumeIndex(I)I

    move-result v0

    return v0
.end method
