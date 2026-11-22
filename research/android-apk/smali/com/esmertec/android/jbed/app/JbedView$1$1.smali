.class Lcom/esmertec/android/jbed/app/JbedView$1$1;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Lcom/esmertec/android/jbed/app/JbedView$Callback;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedView$1;->surfaceCreated(Landroid/view/SurfaceHolder;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/app/JbedView$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedView$1;)V
    .locals 0

    .prologue
    .line 310
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onMidletStarted()V
    .locals 1

    .prologue
    .line 327
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->runPendingMessages()V

    .line 328
    return-void
.end method

.method public onServiceConnected()V
    .locals 6

    .prologue
    .line 312
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$200(Lcom/esmertec/android/jbed/app/JbedView;)V

    .line 315
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    move-result-object v1

    invoke-interface {v1}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedConn()Lcom/esmertec/android/jbed/service/IJbedConnection;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v3, v3, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {v2, v3}, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/service/IJbedConnection;->setJbedClient(Lcom/esmertec/android/jbed/app/IJbedClient;)V

    .line 316
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v2, v2, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedView;->access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    move-result-object v2

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getJbedConn()Lcom/esmertec/android/jbed/service/IJbedConnection;

    move-result-object v2

    invoke-interface {v2}, Lcom/esmertec/android/jbed/service/IJbedConnection;->getUiListener()Lcom/esmertec/android/jbed/service/IJbedUiListener;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/app/JbedView;->access$402(Lcom/esmertec/android/jbed/app/JbedView;Lcom/esmertec/android/jbed/service/IJbedUiListener;)Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .line 317
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$400(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/service/IJbedUiListener;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v2, v2, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedView;->getContext()Landroid/content/Context;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v3, v3, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/app/JbedView;->access$500(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/widget/AbsoluteLayout;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v4, v4, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v4}, Lcom/esmertec/android/jbed/app/JbedView;->access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    move-result-object v4

    invoke-interface {v4}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->getTextFieldConn()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v5, v5, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/app/JbedView;->getWidth()I

    move-result v5

    invoke-static {v1, v2, v3, v4, v5}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->create(Lcom/esmertec/android/jbed/service/IJbedUiListener;Landroid/content/Context;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;I)Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 323
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$1$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;

    move-result-object v1

    const v2, 0x1d4c3

    invoke-static {v1, v2}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 324
    return-void

    .line 318
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 319
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to connect to jbed service!"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method
