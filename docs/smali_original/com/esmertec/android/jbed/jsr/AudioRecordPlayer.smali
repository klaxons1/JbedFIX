.class Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;
.super Ljava/lang/Object;
.source "JbedMediaPlayer.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;


# static fields
.field static final TAG:Ljava/lang/String; = "AudioRecordPlayer"


# instance fields
.field private mDataSource:Ljava/lang/String;

.field private mHandler:Landroid/os/Handler;

.field private mMediaRecorder:Landroid/media/MediaRecorder;

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
    .line 341
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 342
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mNativeContext:I

    .line 343
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mDataSource:Ljava/lang/String;

    .line 344
    iput-object p3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mHandler:Landroid/os/Handler;

    .line 345
    return-void
.end method


# virtual methods
.method public getDataSource()Ljava/lang/String;
    .locals 2

    .prologue
    .line 418
    new-instance v0, Ljava/lang/UnsupportedOperationException;

    const-string v1, "Audio record doesn\'t suport MetaDataControl"

    invoke-direct {v0, v1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public getNativeContext()I
    .locals 1

    .prologue
    .line 348
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mNativeContext:I

    return v0
.end method

.method public getPrepareDataMethod()I
    .locals 1

    .prologue
    .line 352
    const/4 v0, 0x0

    return v0
.end method

.method public operation(IIIII)I
    .locals 9
    .param p1, "playerId"    # I
    .param p2, "opId"    # I
    .param p3, "param1"    # I
    .param p4, "param2"    # I
    .param p5, "param3"    # I

    .prologue
    const/4 v7, -0x1

    const-string v8, "LGE"

    const-string v6, "AudioRecordPlayer"

    const-string v5, ","

    .line 356
    const-string v3, "AudioRecordPlayer"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "AudioRecordPlayer operation ("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ")"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 357
    const/4 v2, 0x0

    .line 358
    .local v2, "ret":I
    sparse-switch p2, :sswitch_data_0

    .line 405
    const/4 v2, -0x2

    :goto_0
    :sswitch_0
    move v3, v2

    .line 407
    :goto_1
    return v3

    .line 363
    :sswitch_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v3}, Landroid/media/MediaRecorder;->release()V

    goto :goto_0

    .line 366
    :sswitch_2
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v3

    const-string v4, "LGE"

    invoke-virtual {v3, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    .line 368
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->getVolume()I

    move-result v2

    goto :goto_0

    .line 371
    :cond_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedVolumn;->getVol()I

    move-result v2

    .line 372
    goto :goto_0

    .line 374
    :sswitch_3
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v3

    const-string v4, "LGE"

    invoke-virtual {v3, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 376
    invoke-static {p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->setVolume(I)I

    move-result v2

    goto :goto_0

    .line 379
    :cond_1
    invoke-static {p3}, Lcom/esmertec/android/jbed/jsr/JbedVolumn;->setVol(I)I

    move-result v2

    .line 380
    goto :goto_0

    .line 383
    :sswitch_4
    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroid/media/MediaRecorder;->setAudioSource(I)V

    .line 384
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroid/media/MediaRecorder;->setOutputFormat(I)V

    .line 385
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    const/4 v4, 0x1

    invoke-virtual {v3, v4}, Landroid/media/MediaRecorder;->setAudioEncoder(I)V

    .line 386
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mDataSource:Ljava/lang/String;

    invoke-virtual {v3, v4}, Landroid/media/MediaRecorder;->setOutputFile(Ljava/lang/String;)V

    .line 387
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v3}, Landroid/media/MediaRecorder;->prepare()V
    :try_end_0
    .catch Ljava/lang/IllegalStateException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1

    .line 395
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v3}, Landroid/media/MediaRecorder;->start()V

    goto :goto_0

    .line 388
    :catch_0
    move-exception v3

    move-object v1, v3

    .line 389
    .local v1, "ise":Ljava/lang/IllegalStateException;
    const-string v3, "AudioRecordPlayer"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "mMediaRecorder.prepare() throw IllegalStateException:"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v1}, Ljava/lang/IllegalStateException;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    move v3, v7

    .line 390
    goto :goto_1

    .line 391
    .end local v1    # "ise":Ljava/lang/IllegalStateException;
    :catch_1
    move-exception v3

    move-object v0, v3

    .line 392
    .local v0, "ioe":Ljava/io/IOException;
    const-string v3, "AudioRecordPlayer"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "mMediaRecorder.prepare() throw IOException: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/io/IOException;->getMessage()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    move v3, v7

    .line 393
    goto/16 :goto_1

    .line 398
    .end local v0    # "ioe":Ljava/io/IOException;
    :sswitch_5
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v3}, Landroid/media/MediaRecorder;->stop()V

    .line 399
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    invoke-virtual {v3}, Landroid/media/MediaRecorder;->reset()V

    .line 400
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->prepareData()V

    goto/16 :goto_0

    .line 403
    :sswitch_6
    new-instance v3, Ljava/lang/IllegalArgumentException;

    const-string v4, "AudioRecordPlayer : OP_STOPRECORD should not sent to Android"

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 358
    :sswitch_data_0
    .sparse-switch
        0x2 -> :sswitch_1
        0x3 -> :sswitch_0
        0x5 -> :sswitch_0
        0x9 -> :sswitch_2
        0xa -> :sswitch_3
        0x16 -> :sswitch_4
        0x17 -> :sswitch_5
        0x18 -> :sswitch_6
    .end sparse-switch
.end method

.method public prepareData()V
    .locals 1

    .prologue
    .line 411
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    if-nez v0, :cond_0

    .line 412
    new-instance v0, Landroid/media/MediaRecorder;

    invoke-direct {v0}, Landroid/media/MediaRecorder;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mMediaRecorder:Landroid/media/MediaRecorder;

    .line 414
    :cond_0
    return-void
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 423
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "[AUDIO]0x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mNativeContext:I

    invoke-static {v1}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;->mDataSource:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " SYNC_PREPAR_DATA "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
