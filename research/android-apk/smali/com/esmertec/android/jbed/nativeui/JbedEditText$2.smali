.class Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;
.super Landroid/os/Handler;
.source "JbedEditText.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedEditText;->onTextChanged(Ljava/lang/CharSequence;III)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V
    .locals 0

    .prologue
    .line 103
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 5
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    .line 105
    iget v1, p1, Landroid/os/Message;->arg1:I

    .line 106
    .local v1, "id":I
    iget-object v2, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v2, Ljava/lang/String;

    .line 109
    .local v2, "text":Ljava/lang/String;
    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-static {v3}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 110
    iget-object v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-static {v3}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v3

    invoke-interface {v3, v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;->onTextChanged(ILjava/lang/String;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 114
    :cond_0
    return-void

    .line 111
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 112
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v3, Ljava/lang/RuntimeException;

    const-string v4, "NativeEditText fail to call onTextChanged"

    invoke-direct {v3, v4}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v3
.end method
