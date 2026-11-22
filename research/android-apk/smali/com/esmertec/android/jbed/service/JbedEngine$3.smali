.class Lcom/esmertec/android/jbed/service/JbedEngine$3;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedEngine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0

    .prologue
    .line 181
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$3;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
    .locals 4
    .param p1, "client"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 184
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$3;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$102(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 185
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$3;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    const/4 v1, 0x7

    const/4 v2, 0x4

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 187
    return-void
.end method

.method public onClientDetached()V
    .locals 3

    .prologue
    const/16 v2, 0x8

    .line 190
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$3;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$102(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 191
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$3;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    const/4 v1, 0x0

    invoke-virtual {v0, v2, v2, v1}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 193
    return-void
.end method
