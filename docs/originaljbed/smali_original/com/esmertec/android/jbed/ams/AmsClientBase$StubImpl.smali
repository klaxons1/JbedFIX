.class public Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;
.super Lcom/esmertec/android/jbed/ams/IJbedAmsClient$Stub;
.source "AmsClientBase.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsClientBase;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "StubImpl"
.end annotation


# instance fields
.field private mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;)V
    .locals 0
    .param p1, "owner"    # Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .prologue
    .line 65
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient$Stub;-><init>()V

    .line 66
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .line 67
    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;Lcom/esmertec/android/jbed/ams/AmsClientBase$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/ams/AmsClientBase;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/ams/AmsClientBase$1;

    .prologue
    .line 61
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;)V

    return-void
.end method


# virtual methods
.method public declared-synchronized finish()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 70
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    if-eqz v0, :cond_0

    .line 71
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->finish()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 73
    :cond_0
    monitor-exit p0

    return-void

    .line 70
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized getId()J
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 76
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    if-eqz v0, :cond_0

    .line 77
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getId()J
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-wide v0

    .line 79
    :goto_0
    monitor-exit p0

    return-wide v0

    :cond_0
    const-wide/16 v0, -0x1

    goto :goto_0

    .line 76
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized handleEvent(II[B)V
    .locals 1
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 84
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    if-eqz v0, :cond_0

    .line 85
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->handleEvent(II[B)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 87
    :cond_0
    monitor-exit p0

    return-void

    .line 84
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized release()V
    .locals 1

    .prologue
    .line 96
    monitor-enter p0

    const/4 v0, 0x0

    :try_start_0
    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 97
    monitor-exit p0

    return-void

    .line 96
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized requestBackground()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 90
    monitor-enter p0

    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    if-eqz v0, :cond_0

    .line 91
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->mOwner:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->requestBackground()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 93
    :cond_0
    monitor-exit p0

    return-void

    .line 90
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method
