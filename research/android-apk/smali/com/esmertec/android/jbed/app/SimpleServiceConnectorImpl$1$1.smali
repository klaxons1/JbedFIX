.class Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->handleMessage(Landroid/os/Message;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;)V
    .locals 0

    .prologue
    .line 591
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;->this$1:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 593
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;->this$1:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$000(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 594
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1$1;->this$1:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl$1;->this$0:Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;->access$000(Lcom/esmertec/android/jbed/app/SimpleServiceConnectorImpl;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    move-result-object v0

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$Callback;->onMidletStarted()V

    .line 597
    :goto_0
    return-void

    .line 596
    :cond_0
    const-string v0, "SimpleConnector"

    const-string v1, "WARNING: mConnectListener is null! failed to callback onMidletStarted"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method
