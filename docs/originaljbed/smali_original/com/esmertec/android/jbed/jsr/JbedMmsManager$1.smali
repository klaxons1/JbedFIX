.class Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;
.super Landroid/content/BroadcastReceiver;
.source "JbedMmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;)V
    .locals 0

    .prologue
    .line 94
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 10
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    const/4 v9, 0x0

    const/4 v8, 0x1

    .line 97
    const-string v6, "uri"

    invoke-virtual {p2, v6}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v5

    check-cast v5, Landroid/net/Uri;

    .line 98
    .local v5, "uri":Landroid/net/Uri;
    const-string v6, "state"

    invoke-virtual {p2, v6, v9}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v4

    .line 100
    .local v4, "state":I
    invoke-static {p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->getMmsAppIdAndType(Landroid/content/Context;Landroid/content/Intent;)Lcom/esmertec/android/jbed/util/SimpleEntry;

    move-result-object v1

    .line 101
    .local v1, "info":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/String;Ljava/lang/Integer;>;"
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getKey()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 102
    .local v0, "appId":Ljava/lang/String;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getValue()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/Integer;

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v2

    .line 104
    .local v2, "messageType":I
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, " get TRANSACTION_COMPLETED_ACTION type="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " uri="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " state="

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->access$000(Ljava/lang/String;)V

    .line 105
    sparse-switch v2, :sswitch_data_0

    .line 119
    sget-boolean v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v6, :cond_0

    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v7, " get a MMS TRANSACTION notification with unknown type!!"

    invoke-static {v6, v7}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 122
    :cond_0
    :goto_0
    return-void

    .line 108
    :sswitch_0
    if-ne v4, v8, :cond_1

    if-eqz v0, :cond_1

    .line 109
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-static {v6, v5, v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Ljava/lang/String;)V

    goto :goto_0

    .line 111
    :cond_1
    sget-boolean v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    if-eqz v6, :cond_0

    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v7, "get failed MESSAGE_TYPE_RETRIEVE_CONF message"

    invoke-static {v6, v7}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 115
    :sswitch_1
    if-ne v4, v8, :cond_2

    move v3, v8

    .line 116
    .local v3, "sendResult":Z
    :goto_1
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-static {v6, v5, v3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->access$200(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Z)V

    goto :goto_0

    .end local v3    # "sendResult":Z
    :cond_2
    move v3, v9

    .line 115
    goto :goto_1

    .line 105
    :sswitch_data_0
    .sparse-switch
        0x80 -> :sswitch_1
        0x84 -> :sswitch_0
    .end sparse-switch
.end method
