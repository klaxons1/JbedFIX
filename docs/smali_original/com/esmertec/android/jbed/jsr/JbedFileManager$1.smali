.class Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;
.super Landroid/content/BroadcastReceiver;
.source "JbedFileManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedFileManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)V
    .locals 0

    .prologue
    .line 98
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 101
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)Landroid/os/Handler;

    move-result-object v1

    if-nez v1, :cond_0

    .line 133
    :goto_0
    return-void

    .line 103
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 104
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;

    invoke-direct {v1, p0, p2}, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;Landroid/content/Intent;)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 132
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0
.end method
