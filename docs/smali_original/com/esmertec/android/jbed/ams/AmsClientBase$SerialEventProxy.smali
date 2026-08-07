.class abstract Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.super Ljava/lang/Object;
.source "AmsClientBase.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsClientBase;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x400
    name = "SerialEventProxy"
.end annotation


# instance fields
.field private mExpectedResponseEventIds:[I

.field mIsFinish:Z

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V
    .locals 0
    .param p2, "expectedResponseEventIds"    # [I

    .prologue
    .line 411
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 412
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->mExpectedResponseEventIds:[I

    .line 413
    return-void
.end method


# virtual methods
.method abstract getResponse()Ljava/lang/Object;
.end method

.method isExpectedEvent(I)Z
    .locals 5
    .param p1, "actualEventId"    # I

    .prologue
    .line 416
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->mExpectedResponseEventIds:[I

    .local v0, "arr$":[I
    array-length v3, v0

    .local v3, "len$":I
    const/4 v2, 0x0

    .local v2, "i$":I
    :goto_0
    if-ge v2, v3, :cond_1

    aget v1, v0, v2

    .line 417
    .local v1, "eventId":I
    if-ne v1, p1, :cond_0

    .line 418
    const/4 v4, 0x1

    .line 420
    .end local v1    # "eventId":I
    :goto_1
    return v4

    .line 416
    .restart local v1    # "eventId":I
    :cond_0
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 420
    .end local v1    # "eventId":I
    :cond_1
    const/4 v4, 0x0

    goto :goto_1
.end method

.method abstract onResponseReceived(II[B)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation
.end method

.method requestEvent(II[B)V
    .locals 3
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    .line 426
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 428
    monitor-enter p0

    .line 430
    :try_start_0
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->mIsFinish:Z

    if-nez v0, :cond_0

    .line 434
    const-wide/16 v0, 0xbb8

    invoke-virtual {p0, v0, v1}, Ljava/lang/Object;->wait(J)V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 440
    :goto_0
    :try_start_1
    monitor-exit p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 441
    return-void

    .line 436
    :cond_0
    :try_start_2
    const-string v0, "AmsClient"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " requestSerialEvent() "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " has done before this! doesn\'t wait"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/InterruptedException; {:try_start_2 .. :try_end_2} :catch_0
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_0

    .line 439
    :catch_0
    move-exception v0

    goto :goto_0

    .line 440
    :catchall_0
    move-exception v0

    :try_start_3
    monitor-exit p0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v0
.end method
