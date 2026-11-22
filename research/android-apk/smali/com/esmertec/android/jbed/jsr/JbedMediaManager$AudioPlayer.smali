.class Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;
.super Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;
.source "JbedMediaManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
.implements Landroid/media/MediaPlayer$OnCompletionListener;
.implements Landroid/media/MediaPlayer$OnPreparedListener;
.implements Landroid/media/MediaPlayer$OnErrorListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "AudioPlayer"
.end annotation


# instance fields
.field private mNativeContext:I


# direct methods
.method public constructor <init>(ILjava/lang/String;Landroid/os/Handler;)V
    .locals 0
    .param p1, "nativeContext"    # I
    .param p2, "url"    # Ljava/lang/String;
    .param p3, "handler"    # Landroid/os/Handler;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 797
    invoke-direct {p0, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;-><init>(Ljava/lang/String;Landroid/os/Handler;)V

    .line 798
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;->mNativeContext:I

    .line 799
    return-void
.end method


# virtual methods
.method public getNativeContext()I
    .locals 1

    .prologue
    .line 808
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;->mNativeContext:I

    return v0
.end method

.method public onCompletion(Landroid/media/MediaPlayer;)V
    .locals 1
    .param p1, "mp"    # Landroid/media/MediaPlayer;

    .prologue
    .line 813
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyCompletion(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    .line 814
    return-void
.end method

.method public onError(Landroid/media/MediaPlayer;II)Z
    .locals 1
    .param p1, "mp"    # Landroid/media/MediaPlayer;
    .param p2, "arg1"    # I
    .param p3, "arg2"    # I

    .prologue
    .line 823
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyError(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;II)V

    .line 824
    invoke-super {p0, p1, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->onError(Landroid/media/MediaPlayer;II)Z

    move-result v0

    return v0
.end method

.method public onPrepared(Landroid/media/MediaPlayer;)V
    .locals 1
    .param p1, "mp"    # Landroid/media/MediaPlayer;

    .prologue
    .line 818
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->notifyPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    .line 819
    return-void
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    .prologue
    const-string v2, " "

    .line 803
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "[AUDIO]0x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;->mNativeContext:I

    invoke-static {v1}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;->mDataSource:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;->getPrepareDataMethod()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
