.class public abstract Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;
.super Landroid/media/MediaPlayer;
.source "JbedMediaPlayer.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnCompletionListener;
.implements Landroid/media/MediaPlayer$OnPreparedListener;
.implements Landroid/media/MediaPlayer$OnErrorListener;
.implements Landroid/view/SurfaceHolder$Callback;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;
    }
.end annotation


# static fields
.field public static final ASYNC_PREPAR_DATA:I = 0x1

.field public static DEBUG:Z = false

.field public static final OP_CLOSE:I = 0x2

.field public static final OP_DRAIN:I = 0xc

.field public static final OP_GETCHUNKSIZE:I = 0xb

.field public static final OP_GETDURATION:I = 0x6

.field public static final OP_GETMEDIATYPE:I = 0x10

.field public static final OP_GETMETADATA:I = 0x12

.field public static final OP_GETPOSITION:I = 0x7

.field public static final OP_GETRECSIZE:I = 0xd

.field public static final OP_GETSUPPORTEDCONTROLS:I = 0x11

.field public static final OP_GETVOLUME:I = 0x9

.field public static final OP_ISPLAYING:I = 0x3e9

.field public static final OP_PAUSE:I = 0x4

.field public static final OP_PAUSERECORD:I = 0x17

.field public static final OP_PLAY:I = 0x3

.field public static final OP_RELEASEDEVICE:I = 0xf

.field public static final OP_RESET:I = 0x1

.field public static final OP_SETDATASIZE:I = 0xe

.field public static final OP_SETPOSITION:I = 0x8

.field public static final OP_SETVOLUME:I = 0xa

.field public static final OP_STARTRECORD:I = 0x16

.field public static final OP_STOP:I = 0x5

.field public static final OP_STOPRECORD:I = 0x18

.field public static final RC_ERROR_COMMAND_IGNORED:I = -0x2

.field public static final RC_ERROR_OPERATION_FAILED:I = -0x1

.field public static final RC_OK:I = 0x0

.field public static final SYNC_PREPAR_DATA:I = 0x0

.field public static final TAG:Ljava/lang/String; = "JbedMediaPlayer"

.field private static VIDEO_EXT_NAMES:[Ljava/lang/String;


# instance fields
.field protected isValid:Z

.field protected mDataSource:Ljava/lang/String;

.field private mHandler:Landroid/os/Handler;

.field private seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 30
    sput-boolean v2, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->DEBUG:Z

    .line 94
    const/4 v0, 0x3

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, ".mp4"

    aput-object v1, v0, v2

    const/4 v1, 0x1

    const-string v2, ".3gp"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, ".3g2"

    aput-object v2, v0, v1

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->VIDEO_EXT_NAMES:[Ljava/lang/String;

    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Landroid/os/Handler;)V
    .locals 1
    .param p1, "url"    # Ljava/lang/String;
    .param p2, "handler"    # Landroid/os/Handler;

    .prologue
    .line 110
    invoke-direct {p0}, Landroid/media/MediaPlayer;-><init>()V

    .line 111
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->mDataSource:Ljava/lang/String;

    .line 112
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->mHandler:Landroid/os/Handler;

    .line 113
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isValid:Z

    .line 114
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    .line 115
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;

    .prologue
    .line 25
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getPosition()I

    move-result v0

    return v0
.end method

.method private getPosition()I
    .locals 3

    .prologue
    .line 144
    :try_start_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getCurrentPosition()I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result v1

    .line 149
    :goto_0
    return v1

    .line 145
    :catch_0
    move-exception v0

    .line 146
    .local v0, "e":Ljava/lang/Exception;
    const-string v1, "JbedMediaPlayer"

    const-string v2, "getPosition() There\'s a excpetion "

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 149
    const/4 v1, 0x0

    goto :goto_0
.end method

.method static isAudioRecord(Ljava/lang/String;)Z
    .locals 1
    .param p0, "url"    # Ljava/lang/String;

    .prologue
    .line 302
    const-string v0, "capture://audio"

    invoke-virtual {p0, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method static isVideoUrl(Ljava/lang/String;)Z
    .locals 6
    .param p0, "url"    # Ljava/lang/String;

    .prologue
    const/4 v5, 0x1

    .line 289
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p0

    .line 290
    const-string v4, "capture://video"

    invoke-virtual {p0, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_0

    move v4, v5

    .line 298
    :goto_0
    return v4

    .line 294
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->VIDEO_EXT_NAMES:[Ljava/lang/String;

    .local v0, "arr$":[Ljava/lang/String;
    array-length v3, v0

    .local v3, "len$":I
    const/4 v2, 0x0

    .local v2, "i$":I
    :goto_1
    if-ge v2, v3, :cond_2

    aget-object v1, v0, v2

    .line 295
    .local v1, "ext":Ljava/lang/String;
    invoke-virtual {p0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    move v4, v5

    .line 296
    goto :goto_0

    .line 294
    :cond_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 298
    .end local v1    # "ext":Ljava/lang/String;
    :cond_2
    const/4 v4, 0x0

    goto :goto_0
.end method


# virtual methods
.method public getDataSource()Ljava/lang/String;
    .locals 1

    .prologue
    .line 139
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->mDataSource:Ljava/lang/String;

    return-object v0
.end method

.method public getPrepareDataMethod()I
    .locals 2

    .prologue
    .line 132
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->mDataSource:Ljava/lang/String;

    const-string v1, "/"

    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 133
    const/4 v0, 0x0

    .line 135
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x1

    goto :goto_0
.end method

.method public abstract onCompletion(Landroid/media/MediaPlayer;)V
.end method

.method public onError(Landroid/media/MediaPlayer;II)Z
    .locals 2
    .param p1, "mp"    # Landroid/media/MediaPlayer;
    .param p2, "arg1"    # I
    .param p3, "arg2"    # I

    .prologue
    const/4 v1, 0x0

    .line 306
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    if-eqz v0, :cond_0

    .line 307
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->seekError()V

    .line 308
    :cond_0
    iput-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isValid:Z

    .line 309
    return v1
.end method

.method public abstract onPrepared(Landroid/media/MediaPlayer;)V
.end method

.method public operation(IIIII)I
    .locals 4
    .param p1, "playerId"    # I
    .param p2, "opId"    # I
    .param p3, "param1"    # I
    .param p4, "param2"    # I
    .param p5, "param3"    # I

    .prologue
    const/4 v2, 0x0

    const-string v3, "JbedMediaPlayer"

    .line 210
    const/4 v0, 0x0

    .line 214
    .local v0, "ret":I
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isValid:Z

    if-nez v1, :cond_0

    .line 215
    packed-switch p2, :pswitch_data_0

    .line 230
    :cond_0
    :pswitch_0
    sparse-switch p2, :sswitch_data_0

    .line 282
    const/4 v0, -0x1

    :cond_1
    :goto_0
    move v1, v0

    .line 285
    :goto_1
    return v1

    .line 223
    :pswitch_1
    const-string v1, "JbedMediaPlayer"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "WARNING: try to operate a invalid media, opId="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 224
    const/4 v1, -0x1

    goto :goto_1

    .line 234
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->seekAndWait(I)I

    goto :goto_0

    .line 238
    :sswitch_1
    :try_start_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-eqz v1, :cond_1

    .line 239
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->stop()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 240
    :catch_0
    move-exception v1

    goto :goto_0

    .line 246
    :sswitch_2
    :try_start_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 247
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->stop()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    .line 249
    :cond_2
    :goto_2
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->release()V

    goto :goto_0

    .line 252
    :sswitch_3
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-eqz v1, :cond_3

    .line 253
    const-string v1, "JbedMediaPlayer"

    const-string v1, "WARNING: try to start a playing player"

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 254
    :cond_3
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->start()V

    goto :goto_0

    .line 257
    :sswitch_4
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-nez v1, :cond_4

    .line 258
    const-string v1, "JbedMediaPlayer"

    const-string v1, "WARNING: try to pause a unplayed player"

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 260
    :cond_4
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->pause()V

    goto :goto_0

    .line 263
    :sswitch_5
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-nez v1, :cond_5

    .line 264
    const-string v1, "JbedMediaPlayer"

    const-string v1, "WARNING: try to stop a unplaying player"

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 265
    :cond_5
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->pause()V

    goto :goto_0

    .line 268
    :sswitch_6
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getDuration()I

    move-result v0

    .line 269
    goto :goto_0

    .line 271
    :sswitch_7
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getPosition()I

    move-result v0

    .line 272
    goto :goto_0

    .line 274
    :sswitch_8
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    invoke-virtual {v1, p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->seekAndWait(I)I

    move-result v0

    .line 275
    if-nez v0, :cond_1

    .line 276
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getPosition()I

    move-result v0

    goto/16 :goto_0

    .line 279
    :sswitch_9
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isPlaying()Z

    move-result v1

    if-eqz v1, :cond_6

    const/4 v1, 0x1

    move v0, v1

    .line 280
    :goto_3
    goto/16 :goto_0

    :cond_6
    move v0, v2

    .line 279
    goto :goto_3

    .line 248
    :catch_1
    move-exception v1

    goto :goto_2

    .line 215
    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_0
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
    .end packed-switch

    .line 230
    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x2 -> :sswitch_2
        0x3 -> :sswitch_3
        0x4 -> :sswitch_4
        0x5 -> :sswitch_5
        0x6 -> :sswitch_6
        0x7 -> :sswitch_7
        0x8 -> :sswitch_8
        0xf -> :sswitch_1
        0x3e9 -> :sswitch_9
    .end sparse-switch
.end method

.method public prepareData()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 118
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->mDataSource:Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setDataSource(Ljava/lang/String;)V

    .line 119
    const/4 v0, 0x3

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setAudioStreamType(I)V

    .line 120
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->getPrepareDataMethod()I

    move-result v0

    if-nez v0, :cond_0

    .line 121
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->prepare()V

    .line 125
    :goto_0
    invoke-virtual {p0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setOnPreparedListener(Landroid/media/MediaPlayer$OnPreparedListener;)V

    .line 126
    invoke-virtual {p0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setOnCompletionListener(Landroid/media/MediaPlayer$OnCompletionListener;)V

    .line 127
    invoke-virtual {p0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setOnErrorListener(Landroid/media/MediaPlayer$OnErrorListener;)V

    .line 128
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seeker:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->setOnSeekCompleteListener(Landroid/media/MediaPlayer$OnSeekCompleteListener;)V

    .line 129
    return-void

    .line 123
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->prepareAsync()V

    goto :goto_0
.end method

.method public surfaceChanged(Landroid/view/SurfaceHolder;III)V
    .locals 2
    .param p1, "surfaceholder"    # Landroid/view/SurfaceHolder;
    .param p2, "i"    # I
    .param p3, "j"    # I
    .param p4, "k"    # I

    .prologue
    .line 314
    const-string v0, "JbedMediaPlayer"

    const-string v1, "surfaceChanged called"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 316
    return-void
.end method

.method public surfaceCreated(Landroid/view/SurfaceHolder;)V
    .locals 2
    .param p1, "holder"    # Landroid/view/SurfaceHolder;

    .prologue
    .line 325
    const-string v0, "JbedMediaPlayer"

    const-string v1, "surfaceCreated called"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 326
    return-void
.end method

.method public surfaceDestroyed(Landroid/view/SurfaceHolder;)V
    .locals 2
    .param p1, "surfaceholder"    # Landroid/view/SurfaceHolder;

    .prologue
    .line 319
    const-string v0, "JbedMediaPlayer"

    const-string v1, "surfaceDestroyed called"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 320
    return-void
.end method
