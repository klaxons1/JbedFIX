.class public Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
.super Ljava/lang/Object;
.source "JbedMediaManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;,
        Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;,
        Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;,
        Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    }
.end annotation


# static fields
.field public static ANDRIOD_MAX_MUSIC_STREM_VOLUME:I = 0x0

.field private static final AUDIO_RECORD_PROTOCOL:Ljava/lang/String; = "capture://audio"

.field public static final DEBUG:Z = false

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager; = null

.field private static final OP_SET_VISIBLE:I = 0x196

.field private static final TAG:Ljava/lang/String; = "JbedMediaManager"

.field private static mAudioManager:Landroid/media/AudioManager;

.field private static final mMetaKeyMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field static playerMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;",
            ">;"
        }
    .end annotation
.end field

.field private static residue:I


# instance fields
.field private mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

.field public final mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field mMediaEventListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 49
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    .line 107
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->nativeInitialization()V

    .line 108
    new-instance v0, Ljava/util/HashMap;

    const/16 v1, 0x10

    invoke-direct {v0, v1}, Ljava/util/HashMap;-><init>(I)V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    .line 109
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "cd track number"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 110
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "album"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 111
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "artist"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 112
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x3

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "author"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 113
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "composer"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 114
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x5

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "date"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 115
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x6

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "genre"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 116
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/4 v1, 0x7

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "title"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 117
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x8

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "year"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 118
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0x9

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "duration"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 119
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xa

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "num tracks"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 120
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xb

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "writer"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 121
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xc

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "mimetype"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 122
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xd

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "albumartist"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 123
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xe

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "disc number"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 124
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    const/16 v1, 0xf

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "compilation"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 125
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 2
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 129
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 67
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 127
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x2

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMediaEventListeners:Ljava/util/List;

    .line 130
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mHandler:Landroid/os/Handler;

    .line 131
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    .line 132
    return-void
.end method

.method static synthetic access$000()Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
    .locals 1

    .prologue
    .line 39
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    .prologue
    .line 39
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object v0
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 39
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object p1
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    .prologue
    .line 39
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$500(I)V
    .locals 0
    .param p0, "x0"    # I

    .prologue
    .line 39
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->nativeNotifyMediaFinishPlay(I)V

    return-void
.end method

.method static synthetic access$600(I)V
    .locals 0
    .param p0, "x0"    # I

    .prologue
    .line 39
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->nativeNotifyMediaCreatePlayer(I)V

    return-void
.end method

.method public static declared-synchronized convertHW2SWVolume(I)I
    .locals 4
    .param p0, "inSwVolume"    # I

    .prologue
    .line 456
    const-class v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    monitor-enter v1

    mul-int/lit8 v2, p0, 0x64

    :try_start_0
    sget v3, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->residue:I

    add-int/2addr v2, v3

    sget v3, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->ANDRIOD_MAX_MUSIC_STREM_VOLUME:I

    div-int v0, v2, v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 459
    .local v0, "adjustedVol":I
    monitor-exit v1

    return v0

    .line 456
    .end local v0    # "adjustedVol":I
    :catchall_0
    move-exception v2

    monitor-exit v1

    throw v2
.end method

.method public static declared-synchronized convertSW2HWVolume(I)I
    .locals 3
    .param p0, "inSwVolume"    # I

    .prologue
    .line 445
    const-class v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    monitor-enter v1

    :try_start_0
    sget v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->ANDRIOD_MAX_MUSIC_STREM_VOLUME:I

    mul-int/2addr v2, p0

    div-int/lit8 v0, v2, 0x64

    .line 446
    .local v0, "adjustedVol":I
    sget v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->ANDRIOD_MAX_MUSIC_STREM_VOLUME:I

    mul-int/2addr v2, p0

    rem-int/lit8 v2, v2, 0x64

    sput v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->residue:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 449
    monitor-exit v1

    return v0

    .line 445
    .end local v0    # "adjustedVol":I
    :catchall_0
    move-exception v2

    monitor-exit v1

    throw v2
.end method

.method public static createPlayer(ILjava/lang/String;)I
    .locals 5
    .param p0, "nativeContext"    # I
    .param p1, "url"    # Ljava/lang/String;

    .prologue
    .line 183
    move-object v0, p1

    .line 185
    .local v0, "mediaUrl":Ljava/lang/String;
    const-string v1, "/"

    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 186
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "file://"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .end local v0    # "mediaUrl":Ljava/lang/String;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 189
    .restart local v0    # "mediaUrl":Ljava/lang/String;
    :cond_0
    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    .line 190
    .local v1, "uri":Landroid/net/Uri;
    invoke-virtual {v1}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v0

    .line 192
    .local v0, "scheme":Ljava/lang/String;
    const-string v2, "file"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3

    .line 194
    invoke-virtual {v1}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v0

    .local v0, "urlfixed":Ljava/lang/String;
    move-object v1, v0

    .line 203
    .end local v0    # "urlfixed":Ljava/lang/String;
    .local v1, "urlfixed":Ljava/lang/String;
    :goto_0
    :try_start_0
    invoke-static {p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isVideoUrl(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_8

    .line 204
    const/4 v2, 0x0

    .line 205
    .local v2, "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    if-nez v0, :cond_7

    .line 207
    const-string v0, "JbedMediaManager"

    const/4 v3, 0x5

    invoke-static {v0, v3}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "JbedMediaManager"

    const-string v3, "WARNING: try to play a video without any jbed client connecting"

    invoke-static {v0, v3}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 209
    :cond_1
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    monitor-enter v3
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 211
    :try_start_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-virtual {v0}, Ljava/lang/Object;->wait()V
    :try_end_1
    .catch Ljava/lang/InterruptedException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 215
    :cond_2
    :goto_1
    :try_start_2
    monitor-exit v3
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-object v0, v2

    .line 219
    .end local v2    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .local v0, "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    :goto_2
    :try_start_3
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    .end local v0    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v2

    invoke-direct {v0, p0, v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;-><init>(ILjava/lang/String;Lcom/esmertec/android/jbed/app/IJbedVideoClient;)V

    .line 229
    .end local v1    # "urlfixed":Ljava/lang/String;
    .local v0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    :goto_3
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 230
    invoke-interface {v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->prepareData()V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    .line 236
    sget-object p1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    .end local p1    # "url":Ljava/lang/String;
    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    .end local p0    # "nativeContext":I
    invoke-virtual {p1, p0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 238
    .end local v0    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .local p0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    if-nez p0, :cond_a

    .line 240
    const/4 p0, -0x1

    .line 243
    .end local p0    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    :goto_4
    return p0

    .line 195
    .local v0, "scheme":Ljava/lang/String;
    .local v1, "uri":Landroid/net/Uri;
    .local p0, "nativeContext":I
    .restart local p1    # "url":Ljava/lang/String;
    :cond_3
    const-string v2, "http"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_4

    const-string v2, "rtsp"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_4

    const-string v2, "capture"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    .end local v0    # "scheme":Ljava/lang/String;
    if-eqz v0, :cond_5

    .line 196
    :cond_4
    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v0

    .local v0, "urlfixed":Ljava/lang/String;
    move-object v1, v0

    .end local v0    # "urlfixed":Ljava/lang/String;
    .local v1, "urlfixed":Ljava/lang/String;
    goto :goto_0

    .line 198
    .local v1, "uri":Landroid/net/Uri;
    :cond_5
    new-instance p0, Ljava/lang/IllegalArgumentException;

    .end local p0    # "nativeContext":I
    new-instance p1, Ljava/lang/StringBuilder;

    .end local p1    # "url":Ljava/lang/String;
    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "unknown uri "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 212
    .local v1, "urlfixed":Ljava/lang/String;
    .restart local v2    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .restart local p0    # "nativeContext":I
    .restart local p1    # "url":Ljava/lang/String;
    :catch_0
    move-exception v0

    .line 213
    .local v0, "ie":Ljava/lang/InterruptedException;
    :try_start_4
    const-string v0, "JbedMediaManager"

    .end local v0    # "ie":Ljava/lang/InterruptedException;
    const/4 v4, 0x5

    invoke-static {v0, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v0, "JbedMediaManager"

    const-string v4, "InterruptedException"

    invoke-static {v0, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_1

    .line 215
    :catchall_0
    move-exception v0

    monitor-exit v3
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    :try_start_5
    throw v0
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_1

    .line 231
    .end local v1    # "urlfixed":Ljava/lang/String;
    .end local v2    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    :catch_1
    move-exception v0

    .line 232
    .local v0, "e":Ljava/lang/Exception;
    const-string v1, "JbedMediaManager"

    const/4 v2, 0x5

    invoke-static {v1, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_6

    const-string v1, "JbedMediaManager"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "failed to create player "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    .end local p0    # "nativeContext":I
    const-string v2, " "

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 233
    :cond_6
    const/4 p0, -0x1

    goto :goto_4

    .line 217
    .end local v0    # "e":Ljava/lang/Exception;
    .restart local v1    # "urlfixed":Ljava/lang/String;
    .restart local v2    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .restart local p0    # "nativeContext":I
    :cond_7
    :try_start_6
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v0

    .end local v2    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .local v0, "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    goto/16 :goto_2

    .line 220
    .end local v0    # "videoClient":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    :cond_8
    invoke-static {p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->isAudioRecord(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_9

    .line 222
    const-string v0, "capture://audio"

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    .line 223
    .local v0, "len":I
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    invoke-virtual {v1, v0, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 224
    .local v1, "urlfixed_audiorecord":Ljava/lang/String;
    new-instance v0, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;

    .end local v0    # "len":I
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mHandler:Landroid/os/Handler;

    invoke-direct {v0, p0, v1, v2}, Lcom/esmertec/android/jbed/jsr/AudioRecordPlayer;-><init>(ILjava/lang/String;Landroid/os/Handler;)V

    .line 225
    .local v0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    goto/16 :goto_3

    .line 226
    .end local v0    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .local v1, "urlfixed":Ljava/lang/String;
    :cond_9
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mHandler:Landroid/os/Handler;

    invoke-direct {v0, p0, v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$AudioPlayer;-><init>(ILjava/lang/String;Landroid/os/Handler;)V
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_1

    .restart local v0    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    goto/16 :goto_3

    .line 243
    .end local v0    # "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .end local v1    # "urlfixed":Ljava/lang/String;
    .end local p1    # "url":Ljava/lang/String;
    .local p0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    :cond_a
    invoke-interface {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getPrepareDataMethod()I

    move-result p0

    goto/16 :goto_4
.end method

.method private static getMetaData(I)[B
    .locals 7
    .param p0, "nativeContext"    # I

    .prologue
    const-string v5, "utf-8"

    const-string v6, "JbedMediaManager"

    .line 402
    :try_start_0
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->getMetaList(I)Ljava/util/List;

    move-result-object v3

    .line 403
    .local v3, "metaList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/String;Ljava/lang/String;>;>;"
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 404
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v4, Ljava/io/DataOutputStream;

    invoke-direct {v4, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 405
    .local v4, "out":Ljava/io/DataOutputStream;
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v5

    invoke-virtual {v4, v5}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 407
    const/4 v1, 0x0

    .end local p0    # "nativeContext":I
    .local v1, "i":I
    :goto_0
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v5

    if-ge v1, v5, :cond_0

    .line 408
    invoke-interface {v3, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getKey()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    const-string v5, "utf-8"

    invoke-virtual {p0, v5}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/io/DataOutputStream;->write([B)V

    .line 409
    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Ljava/io/DataOutputStream;->write(I)V

    .line 410
    invoke-interface {v3, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getValue()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    const-string v5, "utf-8"

    invoke-virtual {p0, v5}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/io/DataOutputStream;->write([B)V

    .line 411
    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Ljava/io/DataOutputStream;->write(I)V

    .line 407
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 413
    :cond_0
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v5

    .line 417
    .end local v0    # "bo":Ljava/io/ByteArrayOutputStream;
    .end local v1    # "i":I
    .end local v3    # "metaList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/String;Ljava/lang/String;>;>;"
    .end local v4    # "out":Ljava/io/DataOutputStream;
    :goto_1
    return-object v5

    .line 415
    :catch_0
    move-exception v5

    move-object v2, v5

    .line 416
    .local v2, "ioe":Ljava/io/IOException;
    const-string v5, "JbedMediaManager"

    const/4 v5, 0x6

    invoke-static {v6, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v5

    if-eqz v5, :cond_1

    const-string v5, "JbedMediaManager"

    const-string v5, "getMetaData throw IOException"

    invoke-static {v6, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 417
    :cond_1
    const/4 v5, 0x0

    goto :goto_1
.end method

.method private static getMetaList(I)Ljava/util/List;
    .locals 10
    .param p0, "nativeContext"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/util/SimpleEntry",
            "<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation

    .prologue
    const-string v9, "JbedMediaManager"

    .line 422
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 423
    .local v2, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 424
    .local v4, "result":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/String;Ljava/lang/String;>;>;"
    new-instance v1, Landroid/media/MediaMetadataRetriever;

    invoke-direct {v1}, Landroid/media/MediaMetadataRetriever;-><init>()V

    .line 426
    .local v1, "metadataRetriever":Landroid/media/MediaMetadataRetriever;
    :try_start_0
    invoke-interface {v2}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getDataSource()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Landroid/media/MediaMetadataRetriever;->setDataSource(Ljava/lang/String;)V

    .line 427
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    invoke-virtual {v6}, Ljava/util/HashMap;->size()I

    move-result v6

    if-ge v0, v6, :cond_1

    .line 428
    invoke-virtual {v1, v0}, Landroid/media/MediaMetadataRetriever;->extractMetadata(I)Ljava/lang/String;

    move-result-object v5

    .line 429
    .local v5, "value":Ljava/lang/String;
    if-nez v5, :cond_0

    .line 427
    :goto_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 432
    :cond_0
    new-instance v6, Lcom/esmertec/android/jbed/util/SimpleEntry;

    sget-object v7, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMetaKeyMap:Ljava/util/HashMap;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    invoke-direct {v6, v7, v5}, Lcom/esmertec/android/jbed/util/SimpleEntry;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    invoke-interface {v4, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 434
    .end local v0    # "i":I
    .end local v5    # "value":Ljava/lang/String;
    :catch_0
    move-exception v6

    move-object v3, v6

    .line 435
    .local v3, "re":Ljava/lang/RuntimeException;
    const-string v6, "JbedMediaManager"

    const/4 v6, 0x5

    invoke-static {v9, v6}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v6

    if-eqz v6, :cond_1

    const-string v6, "JbedMediaManager"

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "getMetaList catch RuntimeException : "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v9, v6}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 438
    .end local v3    # "re":Ljava/lang/RuntimeException;
    :cond_1
    return-object v4
.end method

.method private static getSnapshot(ILjava/lang/String;)I
    .locals 13
    .param p0, "nativeContext"    # I
    .param p1, "filename"    # Ljava/lang/String;

    .prologue
    const/4 v5, -0x1

    const/4 v12, 0x6

    const/4 v2, 0x0

    const-string v11, "JbedMediaManager"

    .line 309
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 310
    .local v10, "tmp":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    if-nez v10, :cond_2

    .line 311
    const-string v2, "JbedMediaManager"

    invoke-static {v11, v12}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "JbedMediaManager"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "can\'t find this video player with "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v11, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_0
    move v2, v5

    .line 348
    :cond_1
    :goto_0
    return v2

    .line 314
    :cond_2
    instance-of v3, v10, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    if-nez v3, :cond_4

    .line 315
    const-string v2, "JbedMediaManager"

    invoke-static {v11, v12}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_3

    const-string v2, "JbedMediaManager"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "the player "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " isn\'t a video player"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v11, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_3
    move v2, v5

    .line 316
    goto :goto_0

    .line 319
    :cond_4
    move-object v0, v10

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;

    move-object v1, v0

    .line 320
    .local v1, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;
    const/16 v3, 0x3e9

    move v4, v2

    move v5, v2

    move v6, v2

    invoke-virtual/range {v1 .. v6}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->operation(IIIII)I

    move-result v3

    if-nez v3, :cond_5

    .line 321
    const-string v3, "JbedMediaManager"

    invoke-static {v11, v12}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v3

    if-eqz v3, :cond_1

    const-string v3, "JbedMediaManager"

    const-string v3, "video is not palying when get snapshot"

    invoke-static {v11, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 325
    :cond_5
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->isCameraPlaying()Z

    move-result v2

    if-eqz v2, :cond_7

    .line 326
    const/4 v8, 0x0

    .line 328
    .local v8, "jpegData":[B
    :try_start_0
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->getSnapshotFromCamera()[B
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v8

    .line 342
    :cond_6
    :goto_1
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->reconnectCamera()V

    .line 344
    invoke-static {v8, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->storeImage([BLjava/lang/String;)I

    move-result v2

    goto :goto_0

    .line 329
    :catch_0
    move-exception v9

    .line 330
    .local v9, "t":Ljava/lang/Throwable;
    const-string v2, "JbedMediaManager"

    invoke-static {v11, v12}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_6

    const-string v2, "JbedMediaManager"

    invoke-virtual {v9}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v2

    invoke-static {v11, v2, v9}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_1

    .line 347
    .end local v8    # "jpegData":[B
    .end local v9    # "t":Ljava/lang/Throwable;
    :cond_7
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$VideoPlayerProxy;->getSnapshotFromMedia()Landroid/graphics/Bitmap;

    move-result-object v7

    .line 348
    .local v7, "bitmap":Landroid/graphics/Bitmap;
    invoke-static {v7, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->storeImage(Landroid/graphics/Bitmap;Ljava/lang/String;)I

    move-result v2

    goto :goto_0
.end method

.method public static declared-synchronized getVolume()I
    .locals 4

    .prologue
    .line 463
    const-class v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    monitor-enter v1

    const/4 v0, -0x1

    .line 465
    .local v0, "ret":I
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    if-eqz v2, :cond_0

    .line 466
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    const/4 v3, 0x3

    invoke-virtual {v2, v3}, Landroid/media/AudioManager;->getStreamVolume(I)I

    move-result v0

    .line 467
    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->convertHW2SWVolume(I)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result v0

    .line 470
    :cond_0
    monitor-exit v1

    return v0

    .line 463
    :catchall_0
    move-exception v2

    monitor-exit v1

    throw v2
.end method

.method private static handleVolume(III)I
    .locals 1
    .param p0, "context"    # I
    .param p1, "opId"    # I
    .param p2, "param1"    # I

    .prologue
    .line 274
    const/16 v0, 0x9

    if-ne p1, v0, :cond_0

    .line 275
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->getVolume()I

    move-result v0

    .line 278
    :goto_0
    return v0

    :cond_0
    invoke-static {p2}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->setVolume(I)I

    move-result v0

    goto :goto_0
.end method

.method private static native nativeInitialization()V
.end method

.method private static native nativeNotifyMediaCreatePlayer(I)V
.end method

.method private static native nativeNotifyMediaFinishPlay(I)V
.end method

.method public static openStreamDev(II)I
    .locals 3
    .param p0, "nativeContext"    # I
    .param p1, "mediaType"    # I

    .prologue
    .line 250
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 251
    .local v0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    return p0
.end method

.method public static operation(IIIIII)I
    .locals 6
    .param p0, "nativeContext"    # I
    .param p1, "mediaType"    # I
    .param p2, "opId"    # I
    .param p3, "param1"    # I
    .param p4, "param2"    # I
    .param p5, "param3"    # I

    .prologue
    const-string v3, "JbedMediaManager"

    .line 257
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .line 258
    .local v0, "player":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    if-nez v0, :cond_1

    .line 259
    const-string v1, "JbedMediaManager"

    const/4 v1, 0x6

    invoke-static {v3, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "JbedMediaManager"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "failed to get player accroding to contextid "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " opId="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 260
    :cond_0
    const/4 v1, -0x1

    .line 270
    :goto_0
    return v1

    .line 263
    :cond_1
    const/4 v1, 0x2

    if-ne p2, v1, :cond_2

    .line 264
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 266
    :cond_2
    const/16 v1, 0x9

    if-eq p2, v1, :cond_3

    const/16 v1, 0xa

    if-ne p2, v1, :cond_4

    .line 267
    :cond_3
    invoke-static {p0, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->handleVolume(III)I

    move-result v1

    goto :goto_0

    :cond_4
    move v1, p0

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    .line 270
    invoke-interface/range {v0 .. v5}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->operation(IIIII)I

    move-result v1

    goto :goto_0
.end method

.method public static declared-synchronized setVolume(I)I
    .locals 5
    .param p0, "inVol"    # I

    .prologue
    .line 475
    const-class v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    monitor-enter v1

    const/4 v0, -0x1

    .line 477
    .local v0, "ret":I
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    if-eqz v2, :cond_0

    .line 478
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->convertSW2HWVolume(I)I

    move-result v0

    .line 479
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    const/4 v3, 0x3

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v0, v4}, Landroid/media/AudioManager;->setStreamVolume(III)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 480
    move v0, p0

    .line 483
    :cond_0
    monitor-exit v1

    return v0

    .line 475
    :catchall_0
    move-exception v2

    monitor-exit v1

    throw v2
.end method

.method private static storeImage(Landroid/graphics/Bitmap;Ljava/lang/String;)I
    .locals 8
    .param p0, "data"    # Landroid/graphics/Bitmap;
    .param p1, "filename"    # Ljava/lang/String;

    .prologue
    const/4 v7, -0x1

    const-string v4, "JbedMediaManager"

    .line 353
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 354
    .local v1, "file":Ljava/io/File;
    if-eqz p0, :cond_4

    .line 355
    const/4 v2, 0x0

    .line 357
    .local v2, "stream":Ljava/io/OutputStream;
    :try_start_0
    new-instance v3, Ljava/io/FileOutputStream;

    invoke-direct {v3, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 358
    .end local v2    # "stream":Ljava/io/OutputStream;
    .local v3, "stream":Ljava/io/OutputStream;
    :try_start_1
    sget-object v4, Landroid/graphics/Bitmap$CompressFormat;->JPEG:Landroid/graphics/Bitmap$CompressFormat;

    const/16 v5, 0x64

    invoke-virtual {p0, v4, v5, v3}, Landroid/graphics/Bitmap;->compress(Landroid/graphics/Bitmap$CompressFormat;ILjava/io/OutputStream;)Z
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 363
    if-eqz v3, :cond_0

    .line 365
    :try_start_2
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_1

    .line 373
    :cond_0
    :goto_0
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v4

    long-to-int v4, v4

    .end local v3    # "stream":Ljava/io/OutputStream;
    :goto_1
    return v4

    .line 359
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 360
    .local v0, "e":Ljava/lang/Exception;
    :goto_2
    :try_start_3
    const-string v4, "JbedMediaManager"

    const/4 v5, 0x6

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_1

    const-string v4, "JbedMediaManager"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "getSnapshot, fails to write bitmap file : "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 363
    :cond_1
    if-eqz v2, :cond_2

    .line 365
    :try_start_4
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_2

    :cond_2
    :goto_3
    move v4, v7

    .line 366
    goto :goto_1

    .line 363
    .end local v0    # "e":Ljava/lang/Exception;
    :catchall_0
    move-exception v4

    :goto_4
    if-eqz v2, :cond_3

    .line 365
    :try_start_5
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_3

    .line 366
    :cond_3
    :goto_5
    throw v4

    .end local v2    # "stream":Ljava/io/OutputStream;
    :cond_4
    move v4, v7

    .line 371
    goto :goto_1

    .line 366
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_1
    move-exception v4

    goto :goto_0

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v0    # "e":Ljava/lang/Exception;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_2
    move-exception v4

    goto :goto_3

    .end local v0    # "e":Ljava/lang/Exception;
    :catch_3
    move-exception v5

    goto :goto_5

    .line 363
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catchall_1
    move-exception v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_4

    .line 359
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_4
    move-exception v4

    move-object v0, v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_2
.end method

.method private static storeImage([BLjava/lang/String;)I
    .locals 8
    .param p0, "data"    # [B
    .param p1, "filename"    # Ljava/lang/String;

    .prologue
    const/4 v7, -0x1

    const-string v4, "JbedMediaManager"

    .line 378
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 379
    .local v1, "file":Ljava/io/File;
    if-eqz p0, :cond_4

    .line 380
    const/4 v2, 0x0

    .line 382
    .local v2, "stream":Ljava/io/OutputStream;
    :try_start_0
    new-instance v3, Ljava/io/FileOutputStream;

    invoke-direct {v3, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 383
    .end local v2    # "stream":Ljava/io/OutputStream;
    .local v3, "stream":Ljava/io/OutputStream;
    const/4 v4, 0x0

    :try_start_1
    array-length v5, p0

    invoke-virtual {v3, p0, v4, v5}, Ljava/io/OutputStream;->write([BII)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 388
    if-eqz v3, :cond_0

    .line 390
    :try_start_2
    invoke-virtual {v3}, Ljava/io/OutputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_1

    .line 397
    :cond_0
    :goto_0
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v4

    long-to-int v4, v4

    .end local v3    # "stream":Ljava/io/OutputStream;
    :goto_1
    return v4

    .line 384
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 385
    .local v0, "e":Ljava/lang/Exception;
    :goto_2
    :try_start_3
    const-string v4, "JbedMediaManager"

    const/4 v5, 0x6

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_1

    const-string v4, "JbedMediaManager"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "getSnapshot, fails to write bitmap file : "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 388
    :cond_1
    if-eqz v2, :cond_2

    .line 390
    :try_start_4
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_2

    :cond_2
    :goto_3
    move v4, v7

    .line 391
    goto :goto_1

    .line 388
    .end local v0    # "e":Ljava/lang/Exception;
    :catchall_0
    move-exception v4

    :goto_4
    if-eqz v2, :cond_3

    .line 390
    :try_start_5
    invoke-virtual {v2}, Ljava/io/OutputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_3

    .line 391
    :cond_3
    :goto_5
    throw v4

    .end local v2    # "stream":Ljava/io/OutputStream;
    :cond_4
    move v4, v7

    .line 395
    goto :goto_1

    .line 391
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_1
    move-exception v4

    goto :goto_0

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v0    # "e":Ljava/lang/Exception;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    :catch_2
    move-exception v4

    goto :goto_3

    .end local v0    # "e":Ljava/lang/Exception;
    :catch_3
    move-exception v5

    goto :goto_5

    .line 388
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catchall_1
    move-exception v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_4

    .line 384
    .end local v2    # "stream":Ljava/io/OutputStream;
    .restart local v3    # "stream":Ljava/io/OutputStream;
    :catch_4
    move-exception v4

    move-object v0, v4

    move-object v2, v3

    .end local v3    # "stream":Ljava/io/OutputStream;
    .restart local v2    # "stream":Ljava/io/OutputStream;
    goto :goto_2
.end method


# virtual methods
.method public notifyCompletion(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
    .locals 3
    .param p1, "mp"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .prologue
    .line 282
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMediaEventListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;

    .line 283
    .local v1, "listener":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;
    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;->onCompletion(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    goto :goto_0

    .line 285
    .end local v1    # "listener":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;
    :cond_0
    return-void
.end method

.method public notifyError(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;II)V
    .locals 2
    .param p1, "mp"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
    .param p2, "arg1"    # I
    .param p3, "arg2"    # I

    .prologue
    .line 299
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    monitor-enter v0

    .line 300
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-virtual {v1}, Ljava/lang/Object;->notifyAll()V

    .line 301
    monitor-exit v0

    .line 302
    return-void

    .line 301
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public notifyPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
    .locals 4
    .param p1, "mp"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .prologue
    const-string v3, "JbedMediaManager"

    .line 289
    invoke-interface {p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getPrepareDataMethod()I

    move-result v2

    if-nez v2, :cond_1

    .line 290
    const-string v2, "JbedMediaManager"

    const/4 v2, 0x4

    invoke-static {v3, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "JbedMediaManager"

    const-string v2, " the player is prepared with sync! ignore the prepare event!"

    invoke-static {v3, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 296
    :cond_0
    return-void

    .line 293
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMediaEventListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;

    .line 294
    .local v1, "listener":Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;
    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;->onPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    goto :goto_0
.end method

.method public onCreate(Landroid/content/Context;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 135
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mContext:Landroid/content/Context;

    .line 136
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    if-nez v0, :cond_0

    .line 137
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mContext:Landroid/content/Context;

    const-string v1, "audio"

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/media/AudioManager;

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    .line 138
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mAudioManager:Landroid/media/AudioManager;

    const/4 v1, 0x3

    invoke-virtual {v0, v1}, Landroid/media/AudioManager;->getStreamMaxVolume(I)I

    move-result v0

    sput v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->ANDRIOD_MAX_MUSIC_STREM_VOLUME:I

    .line 142
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMediaEventListeners:Ljava/util/List;

    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)V

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 170
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 173
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->playerMap:Ljava/util/HashMap;

    invoke-virtual {v0}, Ljava/util/HashMap;->clear()V

    .line 174
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mMediaEventListeners:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 175
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    .line 176
    return-void
.end method
