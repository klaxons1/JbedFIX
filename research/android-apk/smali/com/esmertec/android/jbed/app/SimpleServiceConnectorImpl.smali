.class Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;


# static fields
.field public static final TAG:Ljava/lang/String; = "SimpleConnector"


# instance fields
.field private mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

.field private mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

.field mAmsHandler:Landroid/os/Handler;

.field private mCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

.field private mContext:Landroid/content/Context;

.field mEventhListenHandler:Landroid/os/Handler;

.field private mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

.field private mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

.field private mServiceConn:Landroid/content/ServiceConnection;


# direct methods
.method public constructor <init>(Landroid/content/Context;Landroid/os/Handler;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "eventListenHandler"    # Landroid/os/Handler;

    .prologue
    .line 646
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 583
    new-instance v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;-><init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsHandler:Landroid/os/Handler;

    .line 614
    new-instance v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;-><init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mServiceConn:Landroid/content/ServiceConnection;

    .line 647
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mContext:Landroid/content/Context;

    .line 648
    iput-object p2, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mEventhListenHandler:Landroid/os/Handler;

    .line 649
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/app/JbedView$Callback;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    .prologue
    .line 565
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/service/IJbedService;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    .prologue
    .line 565
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    return-object v0
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedService;)Lcom/esmertec/android/jbed/service/IJbedService;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/IJbedService;

    .prologue
    .line 565
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    return-object p1
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedConnection;)Lcom/esmertec/android/jbed/service/IJbedConnection;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/IJbedConnection;

    .prologue
    .line 565
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    return-object p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    .prologue
    .line 565
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    return-object v0
.end method

.method static synthetic access$302(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .prologue
    .line 565
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    return-object p1
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/ams/AmsClientBase;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    .prologue
    .line 565
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    return-object v0
.end method

.method static synthetic access$402(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/ams/AmsClientBase;)Lcom/esmertec/android/jbed/ams/AmsClientBase;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .prologue
    .line 565
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    return-object p1
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    .prologue
    .line 565
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mContext:Landroid/content/Context;

    return-object v0
.end method


# virtual methods
.method public connect(Lcom/esmertec/android/jbed/app/JbedView$Callback;)V
    .locals 4
    .param p1, "callback"    # Lcom/esmertec/android/jbed/app/JbedView$Callback;

    .prologue
    .line 673
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 674
    .local v0, "serviceIntent":Landroid/content/Intent;
    const-string v1, "com.esmertec.android.jbed"

    const-class v2, Lcom/esmertec/android/jbed/service/JbedService;

    invoke-virtual {v2}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 676
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mContext:Landroid/content/Context;

    invoke-virtual {v1, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 677
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mServiceConn:Landroid/content/ServiceConnection;

    const/4 v3, 0x1

    invoke-virtual {v1, v0, v2, v3}, Landroid/content/Context;->bindService(Landroid/content/Intent;Landroid/content/ServiceConnection;I)Z

    .line 678
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mCallback:Lcom/esmertec/android/jbed/app/JbedView$Callback;

    .line 679
    return-void
.end method

.method public disconnect()V
    .locals 3

    .prologue
    .line 682
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_0

    .line 685
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsConn:Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->onClientDisconnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V

    .line 686
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;->release()V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 690
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mContext:Landroid/content/Context;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mServiceConn:Landroid/content/ServiceConnection;

    invoke-virtual {v1, v2}, Landroid/content/Context;->unbindService(Landroid/content/ServiceConnection;)V

    .line 692
    :cond_0
    return-void

    .line 687
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 688
    .local v0, "e":Landroid/os/RemoteException;
    const-string v1, "SimpleConnector"

    const-string v2, " failed to onClientDisconnected !!"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method public getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;
    .locals 1

    .prologue
    .line 669
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    return-object v0
.end method

.method public getJbedConn()Lcom/esmertec/android/jbed/service/IJbedConnection;
    .locals 1

    .prologue
    .line 656
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    return-object v0
.end method

.method public getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;
    .locals 1

    .prologue
    .line 652
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    return-object v0
.end method

.method public getTextFieldConn()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .locals 3

    .prologue
    .line 661
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/IJbedService;->openTextFieldConnection()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    return-object v1

    .line 662
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 663
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "fail to call openTextFieldConnection"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method
