.class public Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;,
        Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;
    }
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z

.field static DEBUG:Z

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

.field static MAX_STORED_PARTS:I

.field public static TAG:Ljava/lang/String;


# instance fields
.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field private mMmsTransactionReceiver:Landroid/content/BroadcastReceiver;

.field mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

.field private mReceivedMessages:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;",
            ">;"
        }
    .end annotation
.end field

.field private mRegPorts:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;",
            ">;"
        }
    .end annotation
.end field

.field private mSendResultNativeContextMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Long;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .prologue
    const/4 v1, 0x0

    .line 49
    const-class v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->$assertionsDisabled:Z

    .line 51
    const-string v0, "JbedMmsManager"

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    .line 53
    sput-boolean v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    .line 58
    const/16 v0, 0x40

    sput v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->MAX_STORED_PARTS:I

    return-void

    :cond_0
    move v0, v1

    .line 49
    goto :goto_0
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 1
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 85
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 60
    sget v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->MAX_STORED_PARTS:I

    new-array v0, v0, [Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .line 71
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    .line 77
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mSendResultNativeContextMap:Ljava/util/HashMap;

    .line 83
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    .line 94
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mMmsTransactionReceiver:Landroid/content/BroadcastReceiver;

    .line 86
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mHandler:Landroid/os/Handler;

    .line 87
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    .line 88
    return-void
.end method

.method static synthetic access$000(Ljava/lang/String;)V
    .locals 0
    .param p0, "x0"    # Ljava/lang/String;

    .prologue
    .line 49
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Ljava/lang/String;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    .param p1, "x1"    # Landroid/net/Uri;
    .param p2, "x2"    # Ljava/lang/String;

    .prologue
    .line 49
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->handleRetrieve(Landroid/net/Uri;Ljava/lang/String;)V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    .param p1, "x1"    # Landroid/net/Uri;
    .param p2, "x2"    # Z

    .prologue
    .line 49
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->handleSendResult(Landroid/net/Uri;Z)V

    return-void
.end method

.method static synthetic access$300(Z)V
    .locals 0
    .param p0, "x0"    # Z

    .prologue
    .line 49
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->nativeNotifyNewMms(Z)V

    return-void
.end method

.method private static checkPushMessage(Ljava/lang/String;)[B
    .locals 3
    .param p0, "appId"    # Ljava/lang/String;

    .prologue
    .line 362
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    .line 363
    .local v1, "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getAppId()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->isChecked()Z

    move-result v2

    if-nez v2, :cond_0

    .line 364
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->setCheck(Z)V

    .line 365
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getFrom()[B

    move-result-object v2

    .line 368
    .end local v1    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :goto_0
    return-object v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method static decodeBytesToStrings([B)[Ljava/lang/String;
    .locals 7
    .param p0, "bytes"    # [B

    .prologue
    .line 399
    new-instance v3, Ljava/util/ArrayList;

    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    .line 400
    .local v3, "result":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    const/4 v1, 0x0

    .line 401
    .local v1, "from":I
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    array-length v4, p0

    if-ge v2, v4, :cond_1

    .line 403
    aget-byte v4, p0, v2

    if-nez v4, :cond_0

    .line 405
    :try_start_0
    new-instance v4, Ljava/lang/String;

    sub-int v5, v2, v1

    const-string v6, "UTF-8"

    invoke-direct {v4, p0, v1, v5, v6}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    .line 406
    add-int/lit8 v1, v2, 0x1

    .line 401
    :cond_0
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 407
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 408
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    const-string v4, "error encoding"

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 409
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v5, "decodeBytesToStrings UnsupportedEncodingException "

    invoke-static {v4, v5, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_1

    .line 413
    .end local v0    # "e":Ljava/io/UnsupportedEncodingException;
    :cond_1
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v4

    new-array v4, v4, [Ljava/lang/String;

    invoke-interface {v3, v4}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "bytes":[B
    check-cast p0, [Ljava/lang/String;

    return-object p0
.end method

.method private deregisterInternal(Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;)I
    .locals 5
    .param p1, "port"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/util/ConcurrentModificationException;
        }
    .end annotation

    .prologue
    .line 381
    const/4 v2, 0x0

    .line 382
    .local v2, "ret":I
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    .line 383
    .local v1, "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getAppId()Ljava/lang/String;

    move-result-object v3

    iget-object v4, p1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    .line 384
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->dispose()V

    .line 385
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v3, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    goto :goto_0

    .line 388
    .end local v1    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    invoke-interface {v3, p1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_2

    .line 389
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v4, "deregister remove a un-registe app ID"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 390
    const/4 v2, -0x1

    .line 392
    :cond_2
    return v2
.end method

.method static deregisterPort(Ljava/lang/String;ZZ)I
    .locals 4
    .param p0, "appId"    # Ljava/lang/String;
    .param p1, "isStatic"    # Z
    .param p2, "isPush"    # Z

    .prologue
    .line 547
    const/4 v1, 0x0

    .line 549
    .local v1, "ret":I
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    new-instance v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    invoke-direct {v3, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;-><init>(Ljava/lang/String;ZZ)V

    invoke-direct {v2, v3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->deregisterInternal(Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;)I
    :try_end_0
    .catch Ljava/util/ConcurrentModificationException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v1

    .line 552
    :goto_0
    return v1

    .line 550
    :catch_0
    move-exception v2

    move-object v0, v2

    .local v0, "cmp":Ljava/util/ConcurrentModificationException;
    const-string v2, "deregisterInternal makes CME"

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    goto :goto_0
.end method

.method private static disposeMessagePart(I)V
    .locals 2
    .param p0, "index"    # I

    .prologue
    .line 527
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    const/4 v1, 0x0

    aput-object v1, v0, p0

    .line 528
    return-void
.end method

.method private static disposePendingMessage()V
    .locals 1

    .prologue
    .line 518
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->disposePendingMessageInternal()V

    .line 519
    return-void
.end method

.method private disposePendingMessageInternal()V
    .locals 3

    .prologue
    .line 354
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    .line 355
    .local v1, "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->dispose()V

    goto :goto_0

    .line 357
    .end local v1    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 358
    return-void
.end method

.method static getDataPiece(III)[B
    .locals 1
    .param p0, "index"    # I
    .param p1, "from"    # I
    .param p2, "len"    # I

    .prologue
    .line 499
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {v0, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->getDataPieceInternal(III)[B

    move-result-object v0

    return-object v0
.end method

.method private getDataPieceInternal(III)[B
    .locals 1
    .param p1, "index"    # I
    .param p2, "from"    # I
    .param p3, "len"    # I

    .prologue
    .line 250
    const-string v0, "getDataPieceInternal() enter..."

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 251
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->$assertionsDisabled:Z

    if-nez v0, :cond_1

    if-ltz p1, :cond_0

    sget v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->MAX_STORED_PARTS:I

    if-lt p1, v0, :cond_1

    :cond_0
    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0}, Ljava/lang/AssertionError;-><init>()V

    throw v0

    .line 252
    :cond_1
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->$assertionsDisabled:Z

    if-nez v0, :cond_2

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v0, v0, p1

    if-nez v0, :cond_2

    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0}, Ljava/lang/AssertionError;-><init>()V

    throw v0

    .line 253
    :cond_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v0, v0, p1

    invoke-virtual {v0, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->read(II)[B

    move-result-object v0

    return-object v0
.end method

.method public static getMmsAppIdAndType(Landroid/content/Context;Landroid/content/Intent;)Lcom/esmertec/android/jbed/util/SimpleEntry;
    .locals 11
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "intent"    # Landroid/content/Intent;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            "Landroid/content/Intent;",
            ")",
            "Lcom/esmertec/android/jbed/util/SimpleEntry",
            "<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation

    .prologue
    const/4 v2, 0x0

    .line 132
    const-string v0, "uri"

    invoke-virtual {p1, v0}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v1

    check-cast v1, Landroid/net/Uri;

    .line 133
    .local v1, "uri":Landroid/net/Uri;
    const-string v0, "state"

    invoke-virtual {p1, v0, v2}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v10

    .line 134
    .local v10, "state":I
    const/4 v7, 0x0

    .line 135
    .local v7, "c":Landroid/database/Cursor;
    const/4 v6, 0x0

    .line 136
    .local v6, "appId":Ljava/lang/String;
    const/4 v9, -0x1

    .line 138
    .local v9, "messageType":I
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const/4 v2, 0x2

    new-array v2, v2, [Ljava/lang/String;

    const/4 v3, 0x0

    const-string v4, "apl_id"

    aput-object v4, v2, v3

    const/4 v3, 0x1

    const-string v4, "m_type"

    aput-object v4, v2, v3

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v7

    .line 140
    if-eqz v7, :cond_0

    invoke-interface {v7}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 141
    const/4 v0, 0x0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v6

    .line 142
    const/4 v0, 0x1

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getInt(I)I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result v9

    .line 147
    :cond_0
    if-eqz v7, :cond_1

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 149
    :cond_1
    :goto_0
    new-instance v0, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-direct {v0, v6, v2}, Lcom/esmertec/android/jbed/util/SimpleEntry;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    return-object v0

    .line 144
    :catch_0
    move-exception v0

    move-object v8, v0

    .line 145
    .local v8, "e":Ljava/lang/Exception;
    :try_start_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "failed to query "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "! ignore it"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 147
    if-eqz v7, :cond_1

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    goto :goto_0

    .end local v8    # "e":Ljava/lang/Exception;
    :catchall_0
    move-exception v0

    if-eqz v7, :cond_2

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    :cond_2
    throw v0
.end method

.method private handleRetrieve(Landroid/net/Uri;Ljava/lang/String;)V
    .locals 6
    .param p1, "uri"    # Landroid/net/Uri;
    .param p2, "appId"    # Ljava/lang/String;

    .prologue
    .line 153
    invoke-direct {p0, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->isRegisteredAppId(Ljava/lang/String;)Z

    move-result v3

    if-eqz v3, :cond_0

    .line 155
    :try_start_0
    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    invoke-direct {v2, v3, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;-><init>(Landroid/content/Context;Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Ljava/lang/String;)V

    .line 156
    .local v2, "newMessage":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v3, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 157
    invoke-direct {p0, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->isPushPort(Ljava/lang/String;)Z

    move-result v3

    invoke-direct {p0, v3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->notifyNewMessage(Z)V
    :try_end_0
    .catch Ljava/lang/ClassCastException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 166
    .end local v2    # "newMessage":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :goto_0
    return-void

    .line 158
    :catch_0
    move-exception v3

    move-object v1, v3

    .line 159
    .local v1, "e1":Ljava/lang/ClassCastException;
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "get a NotificationTransation defered type message! ingore it. "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 160
    .end local v1    # "e1":Ljava/lang/ClassCastException;
    :catch_1
    move-exception v3

    move-object v0, v3

    .line 161
    .local v0, "e":Ljava/lang/Exception;
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "failed to receive message "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " appid="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 164
    .end local v0    # "e":Ljava/lang/Exception;
    :cond_0
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v4, " get a Mms with appid not for jbed!!!"

    invoke-static {v3, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method private handleSendResult(Landroid/net/Uri;Z)V
    .locals 7
    .param p1, "uri"    # Landroid/net/Uri;
    .param p2, "isSucceed"    # Z

    .prologue
    .line 188
    :try_start_0
    invoke-static {p1}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide v2

    .line 189
    .local v2, "uriId":J
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mSendResultNativeContextMap:Ljava/util/HashMap;

    invoke-static {v2, v3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    .line 190
    .local v1, "nativeContext":Ljava/lang/Integer;
    if-eqz v1, :cond_1

    .line 191
    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v4

    invoke-static {v4, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->nativeNotifyMmsSendResult(IZ)V

    .line 198
    .end local v1    # "nativeContext":Ljava/lang/Integer;
    .end local v2    # "uriId":J
    :cond_0
    :goto_0
    return-void

    .line 193
    .restart local v1    # "nativeContext":Ljava/lang/Integer;
    .restart local v2    # "uriId":J
    :cond_1
    sget-boolean v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v4, :cond_0

    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v5, "Received a sending result message which sent by other app"

    invoke-static {v4, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 195
    .end local v1    # "nativeContext":Ljava/lang/Integer;
    .end local v2    # "uriId":J
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 196
    .local v0, "e":Ljava/lang/Exception;
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "failed to send message by "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method private isPushPort(Ljava/lang/String;)Z
    .locals 3
    .param p1, "appId"    # Ljava/lang/String;

    .prologue
    .line 178
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    .line 179
    .local v1, "port":Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    iget-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 180
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->isPush()Z

    move-result v2

    .line 183
    .end local v1    # "port":Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    :goto_0
    return v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method private isRegisteredAppId(Ljava/lang/String;)Z
    .locals 3
    .param p1, "appId"    # Ljava/lang/String;

    .prologue
    .line 169
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    .line 170
    .local v1, "port":Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    iget-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 171
    const/4 v2, 0x1

    .line 174
    .end local v1    # "port":Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    :goto_0
    return v2

    :cond_1
    const/4 v2, 0x0

    goto :goto_0
.end method

.method private static log(Ljava/lang/String;)V
    .locals 1
    .param p0, "msg"    # Ljava/lang/String;

    .prologue
    .line 91
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    invoke-static {v0, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 92
    :cond_0
    return-void
.end method

.method private static native nativeNotifyMmsSendResult(IZ)V
.end method

.method private static native nativeNotifyNewMms(Z)V
.end method

.method private notifyNewMessage(Z)V
    .locals 3
    .param p1, "isPush"    # Z

    .prologue
    .line 556
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mHandler:Landroid/os/Handler;

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 557
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;

    invoke-direct {v1, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Z)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 563
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 564
    return-void
.end method

.method private registerInternal(Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;)I
    .locals 3
    .param p1, "port"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    .prologue
    const/4 v2, -0x1

    .line 372
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v0

    if-eq v0, v2, :cond_0

    .line 373
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v1, "register a appID which has been reigstered"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    move v0, v2

    .line 377
    :goto_0
    return v0

    .line 376
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mRegPorts:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 377
    const/4 v0, 0x0

    goto :goto_0
.end method

.method static registerPort(Ljava/lang/String;ZZ)I
    .locals 2
    .param p0, "appId"    # Ljava/lang/String;
    .param p1, "isStatic"    # Z
    .param p2, "isPush"    # Z

    .prologue
    .line 537
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;-><init>(Ljava/lang/String;ZZ)V

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->registerInternal(Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;)I

    move-result v0

    return v0
.end method

.method static retrieveMessage()[B
    .locals 3

    .prologue
    .line 453
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->retrieveMessageInternal()[B

    move-result-object v0

    .line 454
    .local v0, "result":[B
    if-nez v0, :cond_0

    .line 455
    const-string v1, " retrieveMessage() have no more message!"

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 459
    :goto_0
    return-object v0

    .line 457
    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " retrieveMessage() data size="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    array-length v2, v0

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    goto :goto_0
.end method

.method private retrieveMessageInternal()[B
    .locals 4

    .prologue
    .line 321
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    monitor-enter v1

    .line 322
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    if-nez v0, :cond_0

    .line 323
    const/4 v0, 0x0

    monitor-exit v1

    .line 325
    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    :goto_0
    return-object v0

    .line 324
    .restart local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "retrieveMessagePartInternal() "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    const/4 v3, 0x0

    invoke-interface {v0, v3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 325
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    const/4 v2, 0x0

    invoke-interface {v0, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    check-cast p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->toBytes()[B

    move-result-object v0

    monitor-exit v1

    goto :goto_0

    .line 326
    :catchall_0
    move-exception v0

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v0
.end method

.method static retrieveMessagePart(II)[B
    .locals 5
    .param p0, "msgId"    # I
    .param p1, "partArrayIndex"    # I

    .prologue
    const-string v4, " partIndex="

    .line 470
    const/4 v1, 0x0

    .line 472
    .local v1, "result":[B
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {v2, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->retrieveMessagePartInternal(II)[B
    :try_end_0
    .catch Ljava/util/ConcurrentModificationException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    .line 474
    :goto_0
    if-nez v1, :cond_0

    .line 475
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " retrieveMessagePart() have no more message! msgId="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " partIndex="

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 481
    :goto_1
    return-object v1

    .line 473
    :catch_0
    move-exception v2

    move-object v0, v2

    .local v0, "cme":Ljava/util/ConcurrentModificationException;
    const-string v2, "retrieveMessagePartInternal() makes CME"

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    goto :goto_0

    .line 478
    .end local v0    # "cme":Ljava/util/ConcurrentModificationException;
    :cond_0
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " retrieveMessagePart() msgId="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " partIndex="

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "data size="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    array-length v3, v1

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    goto :goto_1
.end method

.method private retrieveMessagePartInternal(II)[B
    .locals 7
    .param p1, "msgId"    # I
    .param p2, "partArrayIndex"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/util/ConcurrentModificationException;
        }
    .end annotation

    .prologue
    const/4 v6, 0x0

    .line 333
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_4

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;

    .line 335
    .local v2, "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getId()I

    move-result v4

    if-ne v4, p1, :cond_0

    .line 336
    invoke-virtual {v2, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getPart(I)Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    move-result-object v3

    .line 337
    .local v3, "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    add-int/lit8 v4, p2, 0x1

    iget-object v5, v2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v5}, Ljava/util/List;->size()I

    move-result v5

    if-ne v4, v5, :cond_2

    const/4 v4, 0x1

    move v1, v4

    .line 339
    .local v1, "isLastPart":Z
    :goto_0
    if-eqz v1, :cond_1

    .line 341
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v4, v2}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 344
    :cond_1
    iget-object v4, v2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mContentId:Ljava/lang/String;

    const-string v5, "<dummy>"

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_3

    move-object v4, v6

    .line 351
    .end local v1    # "isLastPart":Z
    .end local v2    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    .end local v3    # "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    :goto_1
    return-object v4

    .line 337
    .restart local v2    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    .restart local v3    # "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    :cond_2
    const/4 v4, 0x0

    move v1, v4

    goto :goto_0

    .line 347
    .restart local v1    # "isLastPart":Z
    :cond_3
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "retrieveMessagePartInternal() "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " isLastPart="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v4}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 348
    invoke-virtual {v3, v1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->toBytes(Z)[B

    move-result-object v4

    goto :goto_1

    .end local v1    # "isLastPart":Z
    .end local v2    # "msg":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    .end local v3    # "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    :cond_4
    move-object v4, v6

    .line 351
    goto :goto_1
.end method

.method static send(I[B[B[I)I
    .locals 1
    .param p0, "nativeContext"    # I
    .param p1, "headerFields"    # [B
    .param p2, "partHeaderFields"    # [B
    .param p3, "partIndex"    # [I

    .prologue
    .line 509
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {v0, p0, p1, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->sendInternal(I[B[B[I)I

    move-result v0

    return v0
.end method

.method private sendInternal(I[B[B[I)I
    .locals 18
    .param p1, "nativeContext"    # I
    .param p2, "headerFields"    # [B
    .param p3, "partHeaderFields"    # [B
    .param p4, "partIndex"    # [I

    .prologue
    .line 259
    invoke-static/range {p2 .. p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->decodeBytesToStrings([B)[Ljava/lang/String;

    move-result-object v2

    .line 260
    .local v2, "allHeaderFields":[Ljava/lang/String;
    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getStartContentId([Ljava/lang/String;)Ljava/lang/String;

    move-result-object v13

    .line 263
    .local v13, "startContentId":Ljava/lang/String;
    invoke-static/range {p3 .. p3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->decodeBytesToStrings([B)[Ljava/lang/String;

    move-result-object v3

    .line 264
    .local v3, "allPartHeaderFields":[Ljava/lang/String;
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_0

    sget-object v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v16, Ljava/lang/StringBuilder;

    invoke-direct/range {v16 .. v16}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v0, p2

    array-length v0, v0

    move/from16 v17, v0

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    const-string v17, "  "

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    move-object/from16 v0, p3

    array-length v0, v0

    move/from16 v17, v0

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-static/range {v15 .. v16}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 267
    :cond_0
    move-object/from16 v0, p4

    array-length v0, v0

    move v15, v0

    new-array v12, v15, [Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .line 268
    .local v12, "parts":[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    const/4 v6, 0x0

    .local v6, "i":I
    :goto_0
    move-object/from16 v0, p4

    array-length v0, v0

    move v15, v0

    if-ge v6, v15, :cond_2

    .line 269
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    move-object v15, v0

    aget v16, p4, v6

    aget-object v11, v15, v16

    .line 271
    .local v11, "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    const/4 v8, 0x0

    .local v8, "j":I
    :goto_1
    iget-object v15, v11, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    array-length v15, v15

    if-ge v8, v15, :cond_1

    .line 272
    iget-object v15, v11, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    move-object v0, v11

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    move-object/from16 v16, v0

    move-object/from16 v0, v16

    array-length v0, v0

    move/from16 v16, v0

    mul-int v16, v16, v6

    add-int v16, v16, v8

    aget-object v16, v3, v16

    aput-object v16, v15, v8

    .line 271
    add-int/lit8 v8, v8, 0x1

    goto :goto_1

    .line 274
    :cond_1
    invoke-virtual {v11}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->fillPduPart()V

    .line 275
    aput-object v11, v12, v6

    .line 268
    add-int/lit8 v6, v6, 0x1

    goto :goto_0

    .line 279
    .end local v8    # "j":I
    .end local v11    # "part":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    :cond_2
    if-eqz v13, :cond_3

    .line 280
    new-instance v15, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;

    invoke-direct {v15, v13}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;-><init>(Ljava/lang/String;)V

    invoke-static {v12, v15}, Ljava/util/Arrays;->sort([Ljava/lang/Object;Ljava/util/Comparator;)V

    .line 282
    :cond_3
    new-instance v5, Lcom/google/android/mms/pdu/PduBody;

    invoke-direct {v5}, Lcom/google/android/mms/pdu/PduBody;-><init>()V

    .line 283
    .local v5, "body":Lcom/google/android/mms/pdu/PduBody;
    move-object v4, v12

    .local v4, "arr$":[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    array-length v10, v4

    .local v10, "len$":I
    const/4 v7, 0x0

    .local v7, "i$":I
    :goto_2
    if-ge v7, v10, :cond_4

    aget-object v9, v4, v7

    .line 284
    .local v9, "jbedMmsMessagePart":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    invoke-virtual {v9}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->getPduPart()Lcom/google/android/mms/pdu/PduPart;

    move-result-object v15

    invoke-virtual {v5, v15}, Lcom/google/android/mms/pdu/PduBody;->addPart(Lcom/google/android/mms/pdu/PduPart;)Z

    .line 283
    add-int/lit8 v7, v7, 0x1

    goto :goto_2

    .line 290
    .end local v9    # "jbedMmsMessagePart":Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    :cond_4
    array-length v15, v12

    if-nez v15, :cond_5

    .line 291
    new-instance v11, Lcom/google/android/mms/pdu/PduPart;

    invoke-direct {v11}, Lcom/google/android/mms/pdu/PduPart;-><init>()V

    .line 292
    .local v11, "part":Lcom/google/android/mms/pdu/PduPart;
    const/16 v15, 0x6a

    invoke-virtual {v11, v15}, Lcom/google/android/mms/pdu/PduPart;->setCharset(I)V

    .line 293
    const-string v15, "dummy"

    invoke-virtual {v15}, Ljava/lang/String;->getBytes()[B

    move-result-object v15

    invoke-virtual {v11, v15}, Lcom/google/android/mms/pdu/PduPart;->setContentId([B)V

    .line 294
    const-string v15, "text/html"

    invoke-virtual {v15}, Ljava/lang/String;->getBytes()[B

    move-result-object v15

    invoke-virtual {v11, v15}, Lcom/google/android/mms/pdu/PduPart;->setContentType([B)V

    .line 295
    const/4 v15, 0x1

    new-array v15, v15, [B

    const/16 v16, 0x0

    const/16 v17, 0x20

    aput-byte v17, v15, v16

    invoke-virtual {v11, v15}, Lcom/google/android/mms/pdu/PduPart;->setContentLocation([B)V

    .line 296
    const/4 v15, 0x1

    new-array v15, v15, [B

    const/16 v16, 0x0

    const/16 v17, 0x20

    aput-byte v17, v15, v16

    invoke-virtual {v11, v15}, Lcom/google/android/mms/pdu/PduPart;->setData([B)V

    .line 297
    invoke-virtual {v5, v11}, Lcom/google/android/mms/pdu/PduBody;->addPart(Lcom/google/android/mms/pdu/PduPart;)Z

    .line 299
    .end local v11    # "part":Lcom/google/android/mms/pdu/PduPart;
    :cond_5
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_c

    .line 300
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_6

    sget-object v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v16, Ljava/lang/StringBuilder;

    invoke-direct/range {v16 .. v16}, Ljava/lang/StringBuilder;-><init>()V

    const-string v17, " startContentId="

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    move-object/from16 v0, v16

    move-object v1, v13

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-static/range {v15 .. v16}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 301
    :cond_6
    const/4 v6, 0x0

    :goto_3
    array-length v15, v2

    if-ge v6, v15, :cond_8

    .line 302
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_7

    sget-object v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v16, Ljava/lang/StringBuilder;

    invoke-direct/range {v16 .. v16}, Ljava/lang/StringBuilder;-><init>()V

    const-string v17, "sendInternal()  header["

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    move-object/from16 v0, v16

    move v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    const-string v17, "]="

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    aget-object v17, v2, v6

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-static/range {v15 .. v16}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 301
    :cond_7
    add-int/lit8 v6, v6, 0x1

    goto :goto_3

    .line 304
    :cond_8
    const/4 v6, 0x0

    :goto_4
    array-length v15, v3

    if-ge v6, v15, :cond_a

    .line 305
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_9

    sget-object v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v16, Ljava/lang/StringBuilder;

    invoke-direct/range {v16 .. v16}, Ljava/lang/StringBuilder;-><init>()V

    const-string v17, "sendInternal()  partheader["

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    move-object/from16 v0, v16

    move v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    const-string v17, "]="

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    aget-object v17, v3, v6

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-static/range {v15 .. v16}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 304
    :cond_9
    add-int/lit8 v6, v6, 0x1

    goto :goto_4

    .line 307
    :cond_a
    const/4 v6, 0x0

    :goto_5
    move-object/from16 v0, p4

    array-length v0, v0

    move v15, v0

    if-ge v6, v15, :cond_c

    .line 308
    sget-boolean v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v15, :cond_b

    sget-object v15, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v16, Ljava/lang/StringBuilder;

    invoke-direct/range {v16 .. v16}, Ljava/lang/StringBuilder;-><init>()V

    const-string v17, "sendInternal()  partindex["

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    move-object/from16 v0, v16

    move v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    const-string v17, "]="

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v16

    aget v17, p4, v6

    invoke-virtual/range {v16 .. v17}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v16

    invoke-virtual/range {v16 .. v16}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-static/range {v15 .. v16}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 307
    :cond_b
    add-int/lit8 v6, v6, 0x1

    goto :goto_5

    .line 311
    :cond_c
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    move-object v15, v0

    invoke-static {v15, v2, v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->send(Landroid/content/Context;[Ljava/lang/String;Lcom/google/android/mms/pdu/PduBody;)Landroid/net/Uri;

    move-result-object v14

    .line 312
    .local v14, "uri":Landroid/net/Uri;
    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    const-string v16, "sendInternal nativeContext="

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    move-object v0, v15

    move/from16 v1, p1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v15

    const-string v16, " uri="

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    invoke-virtual {v14}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v16

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    invoke-virtual {v15}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v15

    invoke-static {v15}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 313
    if-nez v14, :cond_d

    .line 314
    const/4 v15, -0x1

    .line 317
    :goto_6
    return v15

    .line 316
    :cond_d
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mSendResultNativeContextMap:Ljava/util/HashMap;

    move-object v15, v0

    invoke-static {v14}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide v16

    invoke-static/range {v16 .. v17}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v16

    invoke-static/range {p1 .. p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v17

    invoke-virtual/range {v15 .. v17}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 317
    const/4 v15, 0x0

    goto :goto_6
.end method

.method static storeDataPiece(I[BI)I
    .locals 1
    .param p0, "index"    # I
    .param p1, "data"    # [B
    .param p2, "len"    # I

    .prologue
    .line 490
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-virtual {v0, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->storeDataPieceInternal(I[BI)I

    move-result v0

    return v0
.end method


# virtual methods
.method findEmptyIndex()I
    .locals 4

    .prologue
    .line 222
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    array-length v1, v1

    if-ge v0, v1, :cond_1

    .line 223
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v1, v1, v0

    if-nez v1, :cond_0

    .line 224
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    invoke-direct {v2, v3, v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;-><init>(Landroid/content/Context;I)V

    aput-object v2, v1, v0

    move v1, v0

    .line 229
    :goto_1
    return v1

    .line 222
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 228
    :cond_1
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v2, "findEmptyIndex() have no memory to hold this part!!"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 229
    const/4 v1, -0x1

    goto :goto_1
.end method

.method public onCreate(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 202
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    .line 203
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 204
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.TRANSACTION_COMPLETED_ACTION"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 205
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mMmsTransactionReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 206
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 209
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    sget v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->MAX_STORED_PARTS:I

    if-ge v0, v1, :cond_0

    .line 210
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    const/4 v2, 0x0

    aput-object v2, v1, v0

    .line 209
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 212
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mSendResultNativeContextMap:Ljava/util/HashMap;

    invoke-virtual {v1}, Ljava/util/HashMap;->clear()V

    .line 213
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mReceivedMessages:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 214
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mMmsTransactionReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {v1, v2}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 215
    return-void
.end method

.method storeDataPieceInternal(I[BI)I
    .locals 3
    .param p1, "index"    # I
    .param p2, "data"    # [B
    .param p3, "len"    # I

    .prologue
    const/4 v2, -0x1

    .line 237
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "storeDataPieceInternal() index:"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "len:"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->log(Ljava/lang/String;)V

    .line 239
    if-ne p1, v2, :cond_0

    .line 240
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->findEmptyIndex()I

    move-result p1

    .line 242
    :cond_0
    if-ne p1, v2, :cond_1

    move v0, v2

    .line 246
    :goto_0
    return v0

    .line 245
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v0, v0, p1

    invoke-virtual {v0, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->write([BI)V

    move v0, p1

    .line 246
    goto :goto_0
.end method
