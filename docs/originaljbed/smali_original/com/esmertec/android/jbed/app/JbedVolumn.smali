.class Lcom/esmertec/android/jbed/app/JbedVolumn;
.super Ljava/lang/Object;
.source "JbedVideoClientImpl.java"


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 614
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static getVol()I
    .locals 1

    .prologue
    .line 616
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

    .line 620
    invoke-static {v0, p0}, Landroid/media/AudioSystem;->setStreamVolumeIndex(II)I

    .line 621
    invoke-static {v0}, Landroid/media/AudioSystem;->getStreamVolumeIndex(I)I

    move-result v0

    return v0
.end method
