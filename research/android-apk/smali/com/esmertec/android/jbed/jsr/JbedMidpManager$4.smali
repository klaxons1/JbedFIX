.class Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;
.super Landroid/content/BroadcastReceiver;
.source "JbedMidpManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V
    .locals 0

    .prologue
    .line 194
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 7
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    const/4 v6, 0x2

    const/4 v5, 0x0

    .line 197
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v3

    const-string v4, "android.intent.action.PHONE_STATE"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 198
    const-string v3, "state"

    invoke-virtual {p2, v3}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 199
    .local v1, "phoneState":Ljava/lang/String;
    const-class v3, Lcom/android/internal/telephony/Phone$State;

    invoke-static {v3, v1}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object v2

    check-cast v2, Lcom/android/internal/telephony/Phone$State;

    .line 201
    .local v2, "state":Lcom/android/internal/telephony/Phone$State;
    const/4 v0, 0x0

    .line 202
    .local v0, "msg":Landroid/os/Message;
    sget-object v3, Lcom/android/internal/telephony/Phone$State;->RINGING:Lcom/android/internal/telephony/Phone$State;

    if-eq v2, v3, :cond_0

    sget-object v3, Lcom/android/internal/telephony/Phone$State;->OFFHOOK:Lcom/android/internal/telephony/Phone$State;

    if-ne v2, v3, :cond_2

    .line 203
    :cond_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$300(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/os/Handler;

    move-result-object v3

    const/4 v4, 0x6

    invoke-virtual {v3, v4, v6, v5}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    .line 223
    :goto_0
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 225
    .end local v0    # "msg":Landroid/os/Message;
    .end local v1    # "phoneState":Ljava/lang/String;
    .end local v2    # "state":Lcom/android/internal/telephony/Phone$State;
    :cond_1
    return-void

    .line 205
    .restart local v0    # "msg":Landroid/os/Message;
    .restart local v1    # "phoneState":Ljava/lang/String;
    .restart local v2    # "state":Lcom/android/internal/telephony/Phone$State;
    :cond_2
    sget-object v3, Lcom/android/internal/telephony/Phone$State;->IDLE:Lcom/android/internal/telephony/Phone$State;

    if-ne v2, v3, :cond_4

    .line 211
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isBlockVMAfterPhoneHangup()Z

    move-result v3

    if-eqz v3, :cond_3

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/content/Context;

    move-result-object v3

    check-cast v3, Lcom/esmertec/android/jbed/service/JbedService;

    iget-object v3, v3, Lcom/esmertec/android/jbed/service/JbedService;->mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsConnection;->getRunningMidletList()Ljava/util/List;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_3

    .line 212
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$300(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/os/Handler;

    move-result-object v3

    const/16 v4, 0x9

    invoke-virtual {v3, v4}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v3

    invoke-virtual {v3}, Landroid/os/Message;->sendToTarget()V

    .line 218
    :cond_3
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$300(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/os/Handler;

    move-result-object v3

    const/16 v4, 0x8

    invoke-virtual {v3, v4, v6, v5}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    goto :goto_0

    .line 221
    :cond_4
    new-instance v3, Ljava/lang/IllegalArgumentException;

    const-string v4, "incrroect phone state"

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3
.end method
