.class Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Landroid/content/ServiceConnection;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)V
    .locals 0

    .prologue
    .line 614
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onServiceConnected(Landroid/content/ComponentName;Landroid/os/IBinder;)V
    .locals 9
    .param p1, "className"    # Landroid/content/ComponentName;
    .param p2, "service"    # Landroid/os/IBinder;

    .prologue
    .line 621
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {p2}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$102(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedService;)Lcom/esmertec/android/jbed/service/IJbedService;

    .line 623
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$100(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/IJbedService;->openConnection()Lcom/esmertec/android/jbed/service/IJbedConnection;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$202(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedConnection;)Lcom/esmertec/android/jbed/service/IJbedConnection;

    .line 624
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$100(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v1

    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/IJbedService;->openAmsConnection()Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$302(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .line 625
    iget-object v8, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsClientBase;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$500(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Landroid/content/Context;

    move-result-object v1

    check-cast v1, Landroid/app/Activity;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v2, v2, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mAmsHandler:Landroid/os/Handler;

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v3}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$300(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v3

    const-wide/16 v4, 0x0

    new-instance v6, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;

    invoke-direct {v6}, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;-><init>()V

    invoke-direct/range {v0 .. v6}, Lcom/esmertec/android/jbed/ams/AmsClientBase;-><init>(Landroid/content/Context;Landroid/os/Handler;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;JLcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;)V

    invoke-static {v8, v0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$402(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/ams/AmsClientBase;)Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .line 627
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$300(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$400(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsClientBase;->mStub:Lcom/esmertec/android/jbed/ams/AmsClientBase$StubImpl;

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->onClientConnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 632
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$000(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    move-result-object v0

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$Callback;->onServiceConnected()V

    .line 633
    return-void

    .line 628
    :catch_0
    move-exception v0

    move-object v7, v0

    .line 629
    .local v7, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to onClientConnected !!"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public onServiceDisconnected(Landroid/content/ComponentName;)V
    .locals 3
    .param p1, "className"    # Landroid/content/ComponentName;

    .prologue
    const/4 v2, 0x0

    .line 636
    const-string v0, ""

    const-string v1, "WARNING: diconnect from Service!"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 639
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0, v2}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$102(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedService;)Lcom/esmertec/android/jbed/service/IJbedService;

    .line 640
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0, v2}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$202(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/service/IJbedConnection;)Lcom/esmertec/android/jbed/service/IJbedConnection;

    .line 641
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0, v2}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$302(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .line 642
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$2;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->mEventhListenHandler:Landroid/os/Handler;

    const v1, 0x1d4c6

    invoke-static {v0, v1}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 643
    return-void
.end method
