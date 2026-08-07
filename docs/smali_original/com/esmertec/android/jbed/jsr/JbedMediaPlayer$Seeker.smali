.class Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;
.super Ljava/lang/Object;
.source "JbedMediaPlayer.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnSeekCompleteListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "Seeker"
.end annotation


# instance fields
.field mHasSeekFinished:Z

.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;)V
    .locals 0

    .prologue
    .line 153
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onSeekComplete(Landroid/media/MediaPlayer;)V
    .locals 3
    .param p1, "mp"    # Landroid/media/MediaPlayer;

    .prologue
    .line 192
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->DEBUG:Z

    if-eqz v0, :cond_0

    const-string v0, "JbedMediaPlayer"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " get onSeekComplete at "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 193
    :cond_0
    monitor-enter p0

    .line 194
    const/4 v0, 0x1

    :try_start_0
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->mHasSeekFinished:Z

    .line 195
    invoke-virtual {p0}, Ljava/lang/Object;->notify()V

    .line 196
    monitor-exit p0

    .line 197
    return-void

    .line 196
    :catchall_0
    move-exception v0

    monitor-exit p0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v0
.end method

.method public seekAndWait(I)I
    .locals 6
    .param p1, "position"    # I

    .prologue
    const/4 v5, -0x1

    const/4 v4, 0x0

    const-string v1, "JbedMediaPlayer"

    .line 166
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->access$000(Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;)I

    move-result v1

    if-ne v1, p1, :cond_0

    move v1, v4

    .line 188
    :goto_0
    return v1

    .line 168
    :cond_0
    iput-boolean v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->mHasSeekFinished:Z

    .line 170
    :try_start_0
    sget-boolean v1, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->DEBUG:Z

    if-eqz v1, :cond_1

    const-string v1, "JbedMediaPlayer"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " start to seek to "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 171
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;

    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer;->seekTo(I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 175
    monitor-enter p0

    .line 176
    :try_start_1
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->mHasSeekFinished:Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    if-nez v1, :cond_2

    .line 179
    const-wide/32 v1, 0x493e0

    :try_start_2
    invoke-virtual {p0, v1, v2}, Ljava/lang/Object;->wait(J)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 182
    :goto_1
    :try_start_3
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->mHasSeekFinished:Z

    if-nez v1, :cond_2

    .line 183
    const-string v1, "JbedMediaPlayer"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "------------WARNING timeout when seek to "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 184
    monitor-exit p0

    move v1, v5

    goto :goto_0

    .line 172
    :catch_0
    move-exception v1

    move-object v0, v1

    .local v0, "e":Ljava/lang/Exception;
    move v1, v5

    .line 173
    goto :goto_0

    .line 187
    .end local v0    # "e":Ljava/lang/Exception;
    :cond_2
    monitor-exit p0

    move v1, v4

    .line 188
    goto :goto_0

    .line 187
    :catchall_0
    move-exception v1

    monitor-exit p0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v1

    .line 180
    :catch_1
    move-exception v1

    goto :goto_1
.end method

.method public seekError()V
    .locals 1

    .prologue
    .line 200
    monitor-enter p0

    .line 201
    const/4 v0, 0x0

    :try_start_0
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaPlayer$Seeker;->mHasSeekFinished:Z

    .line 202
    invoke-virtual {p0}, Ljava/lang/Object;->notify()V

    .line 203
    monitor-exit p0

    .line 204
    return-void

    .line 203
    :catchall_0
    move-exception v0

    monitor-exit p0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v0
.end method
