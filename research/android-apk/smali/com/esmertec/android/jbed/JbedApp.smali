.class public Lcom/esmertec/android/jbed/JbedApp;
.super Landroid/app/Application;
.source "JbedApp.java"


# static fields
.field private static final EVENT_APP_BASE:I = 0x182b8

.field public static final EVENT_SERVICE_CONNECTED:I = 0x182b9

.field public static final EVENT_SERVICE_DISCONNECTED:I = 0x182ba

.field public static final TAG:Ljava/lang/String; = "JbedApp"


# instance fields
.field private amsClientMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Landroid/os/Handler;",
            "Lcom/esmertec/android/jbed/ams/AmsClient;",
            ">;"
        }
    .end annotation
.end field

.field private handlerCountMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Landroid/os/Handler;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

.field public mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

.field public mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

.field public mJbedTextFieldConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

.field private mServiceConn:Landroid/content/ServiceConnection;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 56
    invoke-direct {p0}, Landroid/app/Application;-><init>()V

    .line 50
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    .line 52
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    .line 57
    invoke-static {}, Lcom/esmertec/android/jbed/LogTag;->queryLoggingLevel()V

    .line 58
    return-void
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/JbedApp;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/JbedApp;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .prologue
    .line 33
    iput-object p1, p0, Lcom/esmertec/android/jbed/JbedApp;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    return-object p1
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/JbedApp;Landroid/app/Activity;Landroid/os/Handler;J)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/JbedApp;
    .param p1, "x1"    # Landroid/app/Activity;
    .param p2, "x2"    # Landroid/os/Handler;
    .param p3, "x3"    # J

    .prologue
    .line 33
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/JbedApp;->notifyServiceConntected(Landroid/app/Activity;Landroid/os/Handler;J)V

    return-void
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/JbedApp;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/JbedApp;

    .prologue
    .line 33
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedApp;->clearOnServiceDisconnect()V

    return-void
.end method

.method private clearOnServiceDisconnect()V
    .locals 5

    .prologue
    const/4 v4, 0x0

    .line 61
    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v2}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v3}, Ljava/util/Map;->size()I

    move-result v3

    new-array v3, v3, [Landroid/os/Handler;

    invoke-interface {v2, v3}, Ljava/util/Set;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Landroid/os/Handler;

    .line 62
    .local v0, "handlers":[Landroid/os/Handler;
    array-length v2, v0

    const/4 v3, 0x1

    sub-int v1, v2, v3

    .local v1, "i":I
    :goto_0
    if-ltz v1, :cond_0

    .line 63
    aget-object v2, v0, v1

    const v3, 0x182ba

    invoke-virtual {v2, v3}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v2

    invoke-virtual {v2}, Landroid/os/Message;->sendToTarget()V

    .line 64
    aget-object v2, v0, v1

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/JbedApp;->stopService(Landroid/os/Handler;)V

    .line 62
    add-int/lit8 v1, v1, -0x1

    goto :goto_0

    .line 66
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v2}, Ljava/util/Map;->clear()V

    .line 67
    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-interface {v2}, Ljava/util/Map;->clear()V

    .line 69
    iput-object v4, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    .line 70
    iput-object v4, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    .line 71
    iput-object v4, p0, Lcom/esmertec/android/jbed/JbedApp;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .line 72
    iput-object v4, p0, Lcom/esmertec/android/jbed/JbedApp;->mServiceConn:Landroid/content/ServiceConnection;

    .line 73
    return-void
.end method

.method private declared-synchronized notifyServiceConntected(Landroid/app/Activity;Landroid/os/Handler;J)V
    .locals 7
    .param p1, "activity"    # Landroid/app/Activity;
    .param p2, "handler"    # Landroid/os/Handler;
    .param p3, "id"    # J

    .prologue
    .line 169
    monitor-enter p0

    :try_start_0
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-object v1, p1

    move-object v2, p2

    move-wide v4, p3

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/ams/AmsClient;-><init>(Landroid/content/Context;Landroid/os/Handler;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;J)V

    .line 170
    .local v0, "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v1, p2, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 172
    :try_start_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->onClientConnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V
    :try_end_1
    .catch Landroid/os/RemoteException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 176
    :goto_0
    const v1, 0x182b9

    :try_start_2
    invoke-static {p2, v1}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 178
    monitor-exit p0

    return-void

    .line 173
    :catch_0
    move-exception v1

    move-object v6, v1

    .line 174
    .local v6, "e":Landroid/os/RemoteException;
    :try_start_3
    const-string v1, "JbedApp"

    const-string v2, " failed to onClientConnected !!"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_0

    .line 169
    .end local v0    # "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    .end local v6    # "e":Landroid/os/RemoteException;
    :catchall_0
    move-exception v1

    monitor-exit p0

    throw v1
.end method

.method private setVmState(II)V
    .locals 3
    .param p1, "state"    # I
    .param p2, "reason"    # I

    .prologue
    .line 232
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_0

    .line 234
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v1, p1, p2}, Lcom/esmertec/android/jbed/service/IJbedService;->setVmState(II)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 239
    :cond_0
    return-void

    .line 235
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 236
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call setVmState !!"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method


# virtual methods
.method public disconnet(Landroid/os/Handler;)V
    .locals 3
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 99
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_0

    .line 101
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    const/4 v2, 0x0

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/service/IJbedConnection;->setJbedClient(Lcom/esmertec/android/jbed/app/IJbedClient;)V

    .line 102
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/JbedApp;->stopService(Landroid/os/Handler;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 108
    :cond_0
    return-void

    .line 103
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 105
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, " failed to call disconnect"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public getAmsClient(Landroid/os/Handler;)Lcom/esmertec/android/jbed/ams/AmsClient;
    .locals 1
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 212
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/JbedApp;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    return-object p0
.end method

.method public notifyActivityBackground()V
    .locals 2

    .prologue
    .line 222
    const/4 v0, 0x2

    const/16 v1, 0x8

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->setVmState(II)V

    .line 224
    return-void
.end method

.method public notifyActivityForeground()V
    .locals 2

    .prologue
    .line 227
    const/4 v0, 0x3

    const/4 v1, 0x4

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->setVmState(II)V

    .line 229
    return-void
.end method

.method public notifyAmsForeground()V
    .locals 2

    .prologue
    .line 217
    const/4 v0, 0x2

    const/16 v1, 0x10

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->setVmState(II)V

    .line 219
    return-void
.end method

.method public onCreate()V
    .locals 2

    .prologue
    .line 77
    invoke-super {p0}, Landroid/app/Application;->onCreate()V

    .line 78
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    .line 79
    const-string v0, "JbedApp"

    const-string v1, "onCreate"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 80
    return-void
.end method

.method public onTerminate()V
    .locals 3

    .prologue
    const-string v2, "JbedApp"

    .line 84
    const-string v1, "JbedApp"

    const-string v1, "onTerminate"

    invoke-static {v2, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 86
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_0

    .line 87
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp;->mServiceConn:Landroid/content/ServiceConnection;

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/JbedApp;->unbindService(Landroid/content/ServiceConnection;)V
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    .line 93
    :cond_0
    :goto_0
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedApp;->clearOnServiceDisconnect()V

    .line 95
    invoke-super {p0}, Landroid/app/Application;->onTerminate()V

    .line 96
    return-void

    .line 89
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 90
    .local v0, "iae":Ljava/lang/IllegalArgumentException;
    const-string v1, "JbedApp"

    const-string v1, "mJbedService may not registered, ignore"

    invoke-static {v2, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0
.end method

.method public declared-synchronized startService(Landroid/app/Activity;Landroid/os/Handler;J)V
    .locals 8
    .param p1, "activity"    # Landroid/app/Activity;
    .param p2, "handler"    # Landroid/os/Handler;
    .param p3, "id"    # J

    .prologue
    const-string v0, "JbedApp"

    .line 115
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-interface {v0, p2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 116
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {v0, p2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 122
    :cond_0
    :goto_0
    const-string v0, "JbedApp"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "startService handler = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 123
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-nez v0, :cond_2

    .line 124
    new-instance v0, Lcom/esmertec/android/jbed/JbedApp$1;

    move-object v1, p0

    move-object v2, p1

    move-object v3, p2

    move-wide v4, p3

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/JbedApp$1;-><init>(Lcom/esmertec/android/jbed/JbedApp;Landroid/app/Activity;Landroid/os/Handler;J)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->mServiceConn:Landroid/content/ServiceConnection;

    .line 160
    new-instance v7, Landroid/content/Intent;

    const-class v0, Lcom/esmertec/android/jbed/service/JbedService;

    invoke-direct {v7, p0, v0}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 161
    .local v7, "serviceIntent":Landroid/content/Intent;
    invoke-virtual {p0, v7}, Lcom/esmertec/android/jbed/JbedApp;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 162
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->mServiceConn:Landroid/content/ServiceConnection;

    const/4 v1, 0x1

    invoke-virtual {p0, v7, v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->bindService(Landroid/content/Intent;Landroid/content/ServiceConnection;I)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 166
    .end local v7    # "serviceIntent":Landroid/content/Intent;
    :goto_1
    monitor-exit p0

    return-void

    .line 117
    :cond_1
    :try_start_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v0, p2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 118
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-interface {v0, p2}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 119
    .local v6, "count":I
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    add-int/lit8 v1, v6, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-interface {v0, p2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 120
    const-string v0, "JbedApp"

    const-string v1, "WARNING :startService() been called twice from the same Activity"

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_0

    .line 115
    .end local v6    # "count":I
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0

    .line 164
    :cond_2
    :try_start_2
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/JbedApp;->notifyServiceConntected(Landroid/app/Activity;Landroid/os/Handler;J)V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    goto :goto_1
.end method

.method public declared-synchronized stopService(Landroid/os/Handler;)V
    .locals 6
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    const-string v3, "JbedApp"

    .line 182
    monitor-enter p0

    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-interface {v3, p1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_0

    .line 183
    const-string v3, "JbedApp"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "stopService handlerCountMap doesn\'t contain handler "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 209
    :goto_0
    monitor-exit p0

    return-void

    .line 187
    :cond_0
    :try_start_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-interface {v3, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v1

    .line 188
    .local v1, "count":I
    add-int/lit8 v1, v1, -0x1

    .line 189
    if-nez v1, :cond_3

    .line 190
    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->amsClientMap:Ljava/util/Map;

    invoke-interface {v3, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    .line 191
    .local v0, "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    const-string v3, "JbedApp"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "stopService handler = "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " amsclient="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    if-nez v0, :cond_1

    const-string v5, "null"

    :goto_1
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 194
    if-nez v0, :cond_2

    .line 195
    const-string v3, "JbedApp"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "stopService() failed to remove the amslcient with handler "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "! stopService on this handler has been called before."

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_0

    .line 182
    .end local v0    # "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    .end local v1    # "count":I
    :catchall_0
    move-exception v3

    monitor-exit p0

    throw v3

    .line 191
    .restart local v0    # "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    .restart local v1    # "count":I
    :cond_1
    :try_start_2
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->toString()Ljava/lang/String;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-result-object v5

    goto :goto_1

    .line 201
    :cond_2
    :try_start_3
    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-interface {v3, v4}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->onClientDisconnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V

    .line 202
    iget-object v3, v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->release()V
    :try_end_3
    .catch Landroid/os/RemoteException; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_0

    .line 203
    :catch_0
    move-exception v3

    move-object v2, v3

    .line 204
    .local v2, "e":Landroid/os/RemoteException;
    :try_start_4
    const-string v3, "JbedApp"

    const-string v4, " failed to onClientDisconnected !!"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 207
    .end local v0    # "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    .end local v2    # "e":Landroid/os/RemoteException;
    :cond_3
    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp;->handlerCountMap:Ljava/util/Map;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-interface {v3, p1, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    goto/16 :goto_0
.end method
