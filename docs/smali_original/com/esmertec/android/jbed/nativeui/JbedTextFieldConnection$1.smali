.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;
.super Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection$Stub;
.source "JbedTextFieldConnection.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)V
    .locals 0

    .prologue
    .line 40
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection$Stub;-><init>()V

    return-void
.end method


# virtual methods
.method public onTextChanged(ILjava/lang/String;)V
    .locals 3
    .param p1, "id"    # I
    .param p2, "text"    # Ljava/lang/String;

    .prologue
    .line 59
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 60
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;ILjava/lang/String;)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 65
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 66
    return-void
.end method

.method public requestRefresh(I)V
    .locals 3
    .param p1, "id"    # I

    .prologue
    .line 69
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 70
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;

    invoke-direct {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;I)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 75
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 76
    return-void
.end method

.method public setClient(Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)V
    .locals 4
    .param p1, "client"    # Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    .prologue
    .line 43
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    monitor-enter v1

    .line 44
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-static {v2, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$002(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    .line 45
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    move-result-object v2

    if-eqz v2, :cond_0

    .line 46
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Landroid/os/Handler;

    move-result-object v2

    const/4 v3, 0x3

    invoke-virtual {v2, v3}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 47
    .local v0, "msg":Landroid/os/Message;
    new-instance v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$1;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;)V

    iput-object v2, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 52
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 53
    sget-object v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 55
    .end local v0    # "msg":Landroid/os/Message;
    :cond_0
    monitor-exit v1

    .line 56
    return-void

    .line 55
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2
.end method
