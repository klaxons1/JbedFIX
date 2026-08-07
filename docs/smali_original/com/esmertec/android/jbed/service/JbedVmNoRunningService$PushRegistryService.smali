.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "PushRegistryService"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;,
        Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;
    }
.end annotation


# static fields
.field private static final SCHEMA_ALARM:Ljava/lang/String; = "alarm"

.field private static final SCHEMA_MMS:Ljava/lang/String; = "mms"

.field private static final SCHEMA_SMS:Ljava/lang/String; = "sms"

.field private static TAG:Ljava/lang/String;


# instance fields
.field private mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/ArrayBlockingQueue",
            "<",
            "Landroid/content/Intent;",
            ">;"
        }
    .end annotation
.end field

.field private mContext:Landroid/content/Context;

.field private mMmsPushEntry:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

.field private mPushEntries:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;",
            ">;"
        }
    .end annotation
.end field

.field private mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

.field private mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 298
    const-string v0, "PushRegistryService"

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    return-void
.end method

.method private constructor <init>()V
    .locals 2

    .prologue
    .line 297
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 306
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 310
    new-instance v0, Ljava/util/concurrent/ArrayBlockingQueue;

    const/16 v1, 0xa

    invoke-direct {v0, v1}, Ljava/util/concurrent/ArrayBlockingQueue;-><init>(I)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;

    .line 312
    new-instance v0, Ljava/util/ArrayList;

    const/16 v1, 0x8

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mPushEntries:Ljava/util/List;

    .line 429
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;

    .prologue
    .line 297
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;-><init>()V

    return-void
.end method

.method static synthetic access$1102(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .prologue
    .line 297
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    return-object p1
.end method

.method static synthetic access$1200(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->unregisterAllPushPorts()V

    return-void
.end method

.method static synthetic access$1300(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Ljava/util/concurrent/ArrayBlockingQueue;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;

    return-object v0
.end method

.method static synthetic access$1400(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->registerAllPushPorts()V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmStatelistener:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Landroid/content/Intent;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    .param p1, "x1"    # Landroid/content/Intent;

    .prologue
    .line 297
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->cachePushIntent(Landroid/content/Intent;)V

    return-void
.end method

.method static synthetic access$700()Ljava/lang/String;
    .locals 1

    .prologue
    .line 297
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    .prologue
    .line 297
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->startVmIfNeed()V

    return-void
.end method

.method private buildPushEntry(Ljava/lang/String;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;
    .locals 3
    .param p1, "schema"    # Ljava/lang/String;

    .prologue
    const/4 v1, 0x0

    .line 461
    const-string v0, "sms"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 462
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$SmsPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V

    .line 470
    :goto_0
    return-object v0

    .line 463
    :cond_0
    const-string v0, "mms"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    .line 466
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mMmsPushEntry:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

    if-nez v0, :cond_1

    .line 467
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$MmsPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mMmsPushEntry:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

    .line 468
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mMmsPushEntry:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

    goto :goto_0

    .line 469
    :cond_2
    const-string v0, "alarm"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_3

    .line 470
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V

    goto :goto_0

    .line 472
    :cond_3
    new-instance v0, Ljava/lang/RuntimeException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "unsupport schema "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " at push entry"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private cachePushIntent(Landroid/content/Intent;)V
    .locals 2
    .param p1, "intent"    # Landroid/content/Intent;

    .prologue
    .line 537
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    if-ne v0, v1, :cond_0

    .line 538
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    const-string v1, "WARNING: Get the sms message while jbedvm is started!!!"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 548
    :goto_0
    return-void

    .line 542
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;

    invoke-virtual {v0}, Ljava/util/concurrent/ArrayBlockingQueue;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 543
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    const-string v1, " get the push sms and launch the vm"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 544
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->startVmIfNeed()V

    .line 547
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;

    invoke-virtual {v0, p1}, Ljava/util/concurrent/ArrayBlockingQueue;->add(Ljava/lang/Object;)Z

    goto :goto_0
.end method

.method private getPushListText()Ljava/lang/String;
    .locals 7

    .prologue
    .line 477
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    invoke-static {v5}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v5

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "pushlist.txt"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 478
    .local v3, "fileName":Ljava/lang/String;
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 479
    .local v2, "file":Ljava/io/File;
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 481
    invoke-virtual {v2}, Ljava/io/File;->length()J

    move-result-wide v4

    long-to-int v4, v4

    new-array v0, v4, [B

    .line 483
    .local v0, "data":[B
    :try_start_0
    new-instance v4, Ljava/io/FileInputStream;

    invoke-direct {v4, v2}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {v4, v0}, Ljava/io/FileInputStream;->read([B)I

    .line 484
    new-instance v4, Ljava/lang/String;

    invoke-direct {v4, v0}, Ljava/lang/String;-><init>([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 490
    .end local v0    # "data":[B
    :goto_0
    return-object v4

    .line 485
    .restart local v0    # "data":[B
    :catch_0
    move-exception v4

    move-object v1, v4

    .line 486
    .local v1, "e":Ljava/io/IOException;
    sget-object v4, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, " failed to read the content of "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 489
    .end local v0    # "data":[B
    .end local v1    # "e":Ljava/io/IOException;
    :cond_0
    sget-object v4, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Have no push information at "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 490
    const-string v4, ""

    goto :goto_0
.end method

.method private registerAllPushPorts()V
    .locals 9

    .prologue
    .line 499
    new-instance v4, Ljava/util/Scanner;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->getPushListText()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v4, v6}, Ljava/util/Scanner;-><init>(Ljava/lang/String;)V

    .line 500
    .local v4, "s":Ljava/util/Scanner;
    const-string v6, "P(\\w+)://:?([\\d|\\w]*),(.*?),.*"

    invoke-static {v6}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v1

    .line 501
    .local v1, "p":Ljava/util/regex/Pattern;
    :cond_0
    :goto_0
    invoke-virtual {v4, v1}, Ljava/util/Scanner;->hasNext(Ljava/util/regex/Pattern;)Z

    move-result v6

    if-eqz v6, :cond_1

    .line 502
    invoke-virtual {v4, v1}, Ljava/util/Scanner;->next(Ljava/util/regex/Pattern;)Ljava/lang/String;

    .line 503
    invoke-virtual {v4}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x1

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v5

    .line 504
    .local v5, "schema":Ljava/lang/String;
    invoke-virtual {v4}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x2

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v3

    .line 505
    .local v3, "port":Ljava/lang/String;
    invoke-virtual {v4}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x3

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v2

    .line 506
    .local v2, "param1":Ljava/lang/String;
    sget-object v6, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->TAG:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, " register "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ": "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 507
    invoke-direct {p0, v5}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->buildPushEntry(Ljava/lang/String;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

    move-result-object v0

    .line 508
    .local v0, "entry":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;
    if-eqz v0, :cond_0

    .line 509
    invoke-interface {v0, v3, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;->register(Ljava/lang/String;Ljava/lang/String;)V

    .line 511
    iget-object v6, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mPushEntries:Ljava/util/List;

    invoke-interface {v6, v0}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v6

    const/4 v7, -0x1

    if-ne v6, v7, :cond_0

    .line 512
    iget-object v6, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mPushEntries:Ljava/util/List;

    invoke-interface {v6, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 516
    .end local v0    # "entry":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;
    .end local v2    # "param1":Ljava/lang/String;
    .end local v3    # "port":Ljava/lang/String;
    .end local v5    # "schema":Ljava/lang/String;
    :cond_1
    return-void
.end method

.method private startVmIfNeed()V
    .locals 4

    .prologue
    .line 552
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    sget-object v2, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    if-ne v1, v2, :cond_0

    .line 553
    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTING:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    iput-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mVmState:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 554
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 555
    .local v0, "jbedIntent":Landroid/content/Intent;
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    invoke-virtual {v3}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ".app.JbedAppActivity"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 556
    const/high16 v1, 0x10000000

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 558
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    invoke-virtual {v1, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 560
    .end local v0    # "jbedIntent":Landroid/content/Intent;
    :cond_0
    return-void
.end method

.method private unregisterAllPushPorts()V
    .locals 3

    .prologue
    .line 523
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mPushEntries:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;

    .line 524
    .local v0, "entry":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;
    invoke-interface {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;->unregister()V

    goto :goto_0

    .line 526
    .end local v0    # "entry":Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mPushEntries:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 527
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mCachedPushIntentQueue:Ljava/util/concurrent/ArrayBlockingQueue;

    invoke-virtual {v2}, Ljava/util/concurrent/ArrayBlockingQueue;->clear()V

    .line 528
    return-void
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 451
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->mContext:Landroid/content/Context;

    .line 452
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->registerAllPushPorts()V

    .line 454
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 457
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->unregisterAllPushPorts()V

    .line 458
    return-void
.end method
