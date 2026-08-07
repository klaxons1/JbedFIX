.class Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;
.super Ljava/lang/Object;
.source "JbedMediaManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedMediaManager$MediaEventListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->onCreate(Landroid/content/Context;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)V
    .locals 0

    .prologue
    .line 142
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCompletion(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
    .locals 3
    .param p1, "mp"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .prologue
    .line 146
    invoke-interface {p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getNativeContext()I

    move-result v1

    if-gtz v1, :cond_0

    .line 155
    :goto_0
    return-void

    .line 148
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 149
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$1;

    invoke-direct {v1, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 154
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0
.end method

.method public onPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
    .locals 3
    .param p1, "mp"    # Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    .prologue
    .line 159
    invoke-interface {p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getNativeContext()I

    move-result v1

    if-gtz v1, :cond_0

    .line 168
    :goto_0
    return-void

    .line 161
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedMediaManager;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 162
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;

    invoke-direct {v1, p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 167
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0
.end method
