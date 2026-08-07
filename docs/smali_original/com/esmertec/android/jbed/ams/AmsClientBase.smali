.class public Lcom/esmertec/android/jbed/ams/AmsClientBase;
.super Ljava/lang/Object;
.source "AmsClientBase.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;,
        Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;
    }
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "AmsClient"

.field protected static mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

.field private static sIdCounter:J


# instance fields
.field private mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

.field protected mContext:Landroid/content/Context;

.field private mFactory:Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;

.field private mHandler:Landroid/os/Handler;

.field private mId:I

.field private mSelector:Lcom/esmertec/android/jbed/ams/JbedSelector;

.field public mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .prologue
    .line 48
    const-wide/16 v0, 0x0

    sput-wide v0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->sIdCounter:J

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/os/Handler;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;JLcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "handler"    # Landroid/os/Handler;
    .param p3, "conn"    # Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .param p4, "id"    # J
    .param p6, "factory"    # Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;

    .prologue
    const/4 v1, 0x0

    .line 101
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 52
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    .line 102
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mContext:Landroid/content/Context;

    .line 103
    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .line 104
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    .line 105
    iput-object p6, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mFactory:Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;

    .line 106
    long-to-int v0, p4

    iput v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mId:I

    .line 107
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;Lcom/esmertec/android/jbed/ams/AmsClientBase$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    .line 108
    return-void
.end method

.method public static getEventName(I)Ljava/lang/String;
    .locals 2
    .param p0, "eventId"    # I

    .prologue
    const/16 v1, 0x2710

    .line 322
    if-ge p0, v1, :cond_0

    .line 323
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->eventNames:[Ljava/lang/String;

    aget-object v0, v0, p0

    .line 325
    :goto_0
    return-object v0

    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->eventAndroidNames:[Ljava/lang/String;

    sub-int v1, p0, v1

    aget-object v0, v0, v1

    goto :goto_0
.end method

.method private processSerialEvent(II[B)Z
    .locals 6
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 116
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    if-eqz v1, :cond_1

    .line 117
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Thread;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " processSerialEvent "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->log(Ljava/lang/String;)V

    .line 118
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->isExpectedEvent(I)Z

    move-result v1

    if-nez v1, :cond_0

    .line 119
    const-string v1, "AmsClient"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "WARNING: mSerialEventProxy get a unexptected event "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    move v1, v4

    .line 133
    :goto_0
    return v1

    .line 123
    :cond_0
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v1, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->onResponseReceived(II[B)V

    .line 124
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    monitor-enter v1
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 125
    :try_start_1
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    const/4 v3, 0x1

    iput-boolean v3, v2, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->mIsFinish:Z

    .line 126
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v2}, Ljava/lang/Object;->notifyAll()V

    .line 127
    monitor-exit v1

    move v1, v5

    .line 131
    goto :goto_0

    .line 127
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    throw v2
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    .line 128
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 129
    .local v0, "e":Ljava/io/IOException;
    new-instance v1, Ljava/lang/IllegalArgumentException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Failed to setResponseRawData() "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .end local v0    # "e":Ljava/io/IOException;
    :cond_1
    move v1, v4

    .line 133
    goto :goto_0
.end method


# virtual methods
.method public bringMidletToForeground(Z)V
    .locals 3
    .param p1, "isFullScreen"    # Z

    .prologue
    .line 329
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2710

    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 330
    return-void
.end method

.method checkExpiredMidlet(Ljava/lang/String;)Z
    .locals 6
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    const/16 v5, 0x42

    const/4 v4, 0x0

    .line 451
    const-string v1, "AmsClient"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "checkExpiredMidlet root:"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 452
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsClientBase$1;

    const/4 v2, 0x1

    new-array v2, v2, [I

    aput v5, v2, v4

    invoke-direct {v1, p0, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$1;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 467
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {v1, v5, v4, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->requestEvent(II[B)V

    .line 468
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->getResponse()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/AmsClientBase;
    check-cast p0, [Z

    check-cast p0, [Z

    aget-boolean v0, p0, v4

    .line 470
    .local v0, "result":Z
    const/4 v1, 0x0

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 472
    return v0
.end method

.method public destroyMidlet(Ljava/lang/String;)V
    .locals 4
    .param p1, "name"    # Ljava/lang/String;

    .prologue
    .line 310
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidletByName(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 311
    .local v0, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v0, :cond_0

    .line 312
    new-instance v1, Ljava/lang/IllegalArgumentException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Midlet"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "not found"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 313
    :cond_0
    iget-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDestroyEvent(Ljava/lang/String;I)V

    .line 314
    return-void
.end method

.method findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 580
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    return-object v0
.end method

.method findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 599
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    return-object v0
.end method

.method public finish()V
    .locals 2

    .prologue
    .line 187
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2711

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 188
    return-void
.end method

.method public getAllFolders(ZZZ)Ljava/util/List;
    .locals 1
    .param p1, "includeHidden"    # Z
    .param p2, "includeReadonly"    # Z
    .param p3, "includeRoot"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 553
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllFolders(ZZZ)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getAllFolders(ZZZZ)Ljava/util/List;
    .locals 1
    .param p1, "includeHidden"    # Z
    .param p2, "includeReadonly"    # Z
    .param p3, "includeRoot"    # Z
    .param p4, "sdcardSelected"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 566
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllFolders(ZZZZ)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;
    .locals 1
    .param p1, "folder"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "includeHidden"    # Z
    .param p3, "includeReadonly"    # Z
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            "ZZ)",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 570
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getDrmMethodType(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 504
    iget v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    if-nez v1, :cond_0

    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 505
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ".drm"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 506
    .local v0, "drmFileName":Ljava/lang/String;
    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedDrmManager;->getDrmMethodType(Ljava/lang/String;)I

    move-result v1

    iput v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    .line 508
    .end local v0    # "drmFileName":Ljava/lang/String;
    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "getDrmMethodType : mDrmMethodType = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->log(Ljava/lang/String;)V

    .line 509
    iget v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmMethodType:I

    return v1
.end method

.method public getDrmMethodType(Ljava/lang/String;)I
    .locals 6
    .param p1, "filePath"    # Ljava/lang/String;

    .prologue
    const/16 v5, 0x44

    const/4 v4, 0x0

    .line 476
    const-string v1, "AmsClient"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "getDrmMethodType filePath:"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 477
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsClientBase$2;

    const/4 v2, 0x1

    new-array v2, v2, [I

    aput v5, v2, v4

    invoke-direct {v1, p0, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$2;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 491
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {v1, v5, v4, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->requestEvent(II[B)V

    .line 492
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->getResponse()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/AmsClientBase;
    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 494
    .local v0, "result":I
    const/4 v1, 0x0

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 496
    return v0
.end method

.method getFolderByMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 590
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getFolderByMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    return-object v0
.end method

.method public getId()J
    .locals 2

    .prologue
    .line 192
    iget v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mId:I

    int-to-long v0, v0

    return-wide v0
.end method

.method public getMergedChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;
    .locals 1
    .param p1, "parent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ")",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 542
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getMergedChildren(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getMildetByHierarchyNames([Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "names"    # [Ljava/lang/String;

    .prologue
    .line 534
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findByHierarchyNames([Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    return-object v0
.end method

.method public getRunningMidletList()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 384
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v1

    .line 386
    .local v1, "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->getRunningMidletList()Ljava/util/List;
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    .line 390
    return-object v1

    .line 387
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 388
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v2, Ljava/lang/RuntimeException;

    const-string v3, "failed to call getRunningMidletList"

    invoke-direct {v2, v3}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method protected getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;
    .locals 2

    .prologue
    .line 513
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSelector:Lcom/esmertec/android/jbed/ams/JbedSelector;

    if-nez v0, :cond_0

    .line 514
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelector;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mContext:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSelector:Lcom/esmertec/android/jbed/ams/JbedSelector;

    .line 516
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSelector:Lcom/esmertec/android/jbed/ams/JbedSelector;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 517
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mSelector:Lcom/esmertec/android/jbed/ams/JbedSelector;

    return-object v0
.end method

.method public handleEvent(II[B)V
    .locals 4
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    .line 161
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "handleEvent : event = "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "   result = "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->log(Ljava/lang/String;)V

    .line 164
    invoke-direct {p0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->processSerialEvent(II[B)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 180
    :cond_0
    :goto_0
    return-void

    .line 169
    :cond_1
    const/4 v2, 0x0

    invoke-virtual {p0, p1, p2, p3, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 171
    const/16 v2, 0xb

    if-ne p1, v2, :cond_0

    .line 172
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v2

    const-string v3, "LGE"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 173
    new-instance v2, Ljava/lang/String;

    invoke-direct {v2, p3}, Ljava/lang/String;-><init>([B)V

    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 174
    .local v0, "drmRoot":Ljava/lang/String;
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v2

    invoke-virtual {v2, v0, p2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    .line 175
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eqz v1, :cond_0

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 176
    invoke-virtual {p0, v0, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDrmConstraint(Ljava/lang/String;I)V

    goto :goto_0
.end method

.method protected handleEventInternal(II[BLjava/lang/Object;)V
    .locals 5
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .param p4, "obj"    # Ljava/lang/Object;

    .prologue
    .line 137
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mFactory:Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;

    invoke-interface {v2, p1}, Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;->buildAmsHandler(I)Lcom/esmertec/android/jbed/ams/AmsEventHandler;

    move-result-object v1

    .line 138
    .local v1, "eventHandler":Lcom/esmertec/android/jbed/ams/AmsEventHandler;
    if-nez v1, :cond_0

    .line 155
    :goto_0
    return-void

    .line 142
    :cond_0
    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v2, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    iput-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    .line 143
    iget-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iput-object p4, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .line 144
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mContext:Landroid/content/Context;

    iput-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mContext:Landroid/content/Context;

    .line 145
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    iput-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mHandler:Landroid/os/Handler;

    .line 146
    iput-object p0, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .line 148
    :try_start_0
    iget-object v2, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->parseData([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 154
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    invoke-virtual {v2, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_0

    .line 149
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 150
    .local v0, "e1":Ljava/io/IOException;
    const-string v2, "AmsClient"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "ERROR: failed to "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ".parseData()"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 151
    new-instance v2, Ljava/lang/IllegalArgumentException;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Failed to parseData() "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    iget-object v4, v1, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2
.end method

.method protected isRuningMidlet(Ljava/lang/String;I)Z
    .locals 4
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 365
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getRunningMidletList()Ljava/util/List;

    move-result-object v2

    .line 366
    .local v2, "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 367
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v3, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    iget v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-eq v3, p2, :cond_1

    if-nez p2, :cond_0

    .line 368
    :cond_1
    const/4 v3, 0x1

    .line 371
    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    return v3

    :cond_2
    const/4 v3, 0x0

    goto :goto_0
.end method

.method public isRuningSuite(Ljava/lang/String;)Z
    .locals 1
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 380
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->isRuningMidlet(Ljava/lang/String;I)Z

    move-result v0

    return v0
.end method

.method log(Ljava/lang/String;)V
    .locals 3
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 400
    const-string v0, "AmsClient"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 401
    return-void
.end method

.method public refreshSelector()V
    .locals 1

    .prologue
    .line 525
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 526
    return-void
.end method

.method public requestBackground()V
    .locals 1

    .prologue
    .line 183
    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->bringMidletToForeground(Z)V

    .line 184
    return-void
.end method

.method public requestDestroyEvent(Ljava/lang/String;I)V
    .locals 1
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 306
    const/16 v0, 0xa

    invoke-virtual {p0, v0, p2, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(IILjava/lang/String;)V

    .line 307
    return-void
.end method

.method public requestDrmConstraint(Ljava/lang/String;I)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    .line 302
    const/16 v0, 0x43

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {p0, v0, p2, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 303
    return-void
.end method

.method public requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 2
    .param p1, "event"    # I
    .param p2, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 333
    const/16 v0, 0x271e

    iget-object v1, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {p0, v0, p1, v1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 334
    return-void
.end method

.method protected requestEvent(I)V
    .locals 2
    .param p1, "eventId"    # I

    .prologue
    .line 211
    const/4 v1, 0x0

    const/4 v0, 0x0

    check-cast v0, [B

    invoke-virtual {p0, p1, v1, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 212
    return-void
.end method

.method protected requestEvent(II)V
    .locals 1
    .param p1, "eventId"    # I
    .param p2, "result"    # I

    .prologue
    .line 215
    const/4 v0, 0x0

    check-cast v0, [B

    invoke-virtual {p0, p1, p2, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 216
    return-void
.end method

.method protected requestEvent(IILjava/lang/String;)V
    .locals 5
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "strData"    # Ljava/lang/String;

    .prologue
    .line 219
    const/4 v0, 0x0

    .line 220
    .local v0, "data":[B
    if-eqz p3, :cond_0

    .line 222
    :try_start_0
    const-string v2, "UTF-8"

    invoke-virtual {p3, v2}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v0

    .line 227
    :cond_0
    :goto_0
    invoke-virtual {p0, p1, p2, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 228
    return-void

    .line 223
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 224
    .local v1, "e":Ljava/io/UnsupportedEncodingException;
    const-string v2, "AmsClient"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Failed to decode ["

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, "] to utf-8"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method protected requestEvent(II[B)V
    .locals 3
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    .line 199
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "requestEvent : event = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "   result = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->log(Ljava/lang/String;)V

    .line 201
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    invoke-interface {v1, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->requestEvent(II[B)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 208
    :goto_0
    return-void

    .line 202
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 206
    .local v0, "e":Landroid/os/RemoteException;
    const-string v1, "AmsClient"

    const-string v2, "failed to call requestEvent"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method public requestPlatformRequestAnswer(I)V
    .locals 1
    .param p1, "result"    # I

    .prologue
    .line 337
    const/16 v0, 0x4a

    invoke-virtual {p0, v0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II)V

    .line 338
    return-void
.end method

.method public requestRunEvent(Ljava/lang/String;)V
    .locals 4
    .param p1, "name"    # Ljava/lang/String;

    .prologue
    .line 291
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    invoke-virtual {v1, p1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->findMidletByName(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 292
    .local v0, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v0, :cond_0

    .line 293
    new-instance v1, Ljava/lang/IllegalArgumentException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Midlet"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "not found"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 294
    :cond_0
    iget-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestRunEvent(Ljava/lang/String;I)V

    .line 295
    return-void
.end method

.method public requestRunEvent(Ljava/lang/String;I)V
    .locals 7
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    const/16 v6, 0x2711

    const/4 v5, 0x7

    const/4 v3, 0x3

    const/4 v4, 0x2

    .line 235
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isNotifyDrmConstraintEnable()Z

    move-result v1

    if-eqz v1, :cond_6

    .line 236
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v0

    .line 237
    .local v0, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v1

    if-eqz v1, :cond_6

    .line 238
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "LGE"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 240
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->isRuningMidlet(Ljava/lang/String;I)Z

    move-result v1

    if-nez v1, :cond_6

    .line 241
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->checkExpiredMidlet(Ljava/lang/String;)Z

    move-result v1

    iput-boolean v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    .line 242
    iget-boolean v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    if-eqz v1, :cond_6

    .line 243
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getDrmMethodType(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v1

    if-ne v1, v3, :cond_1

    .line 244
    invoke-virtual {p0, v4, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 286
    .end local v0    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_0
    :goto_0
    return-void

    .line 247
    .restart local v0    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    iget-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {p0, v6, v5, v1, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_0

    .line 253
    :cond_2
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "TW"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_5

    .line 254
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->isRuningMidlet(Ljava/lang/String;I)Z

    move-result v1

    if-nez v1, :cond_6

    .line 255
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->checkExpiredMidlet(Ljava/lang/String;)Z

    move-result v1

    iput-boolean v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    .line 256
    iget-boolean v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    if-eqz v1, :cond_6

    .line 257
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getDrmMethodType(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v1

    if-ne v1, v3, :cond_4

    .line 262
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmPending()Z

    move-result v1

    if-eqz v1, :cond_3

    .line 263
    invoke-virtual {p0, v3, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_0

    .line 265
    :cond_3
    invoke-virtual {p0, v4, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_0

    .line 268
    :cond_4
    iget-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {p0, v6, v5, v1, v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_0

    .line 274
    :cond_5
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestDrmConstraint(Ljava/lang/String;I)V

    .line 277
    .end local v0    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_6
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mHandler:Landroid/os/Handler;

    const/16 v3, 0x271c

    invoke-virtual {v2, v3}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/os/Handler;->sendMessageAtFrontOfQueue(Landroid/os/Message;)Z

    .line 279
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mContext:Landroid/content/Context;

    invoke-virtual {v1, p1, p2, v2}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getPreMIDletWithSameClass(Ljava/lang/String;ILandroid/content/Context;)I

    move-result p2

    .line 280
    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-virtual {p0, v4, p2, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestEvent(II[B)V

    .line 283
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->isRuningMidlet(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 284
    const/4 v1, 0x1

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {p0, v4, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_0
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    .prologue
    .line 396
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "amsclient-"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/JbedConstants;->JBED_ACTIVITY_NAMES:[Ljava/lang/String;

    iget v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mId:I

    aget-object v1, v1, v2

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
