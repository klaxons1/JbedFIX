.class Lcom/esmertec/android/jbed/app/JbedAppActivity$2;
.super Landroid/content/BroadcastReceiver;
.source "JbedAppActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedAppActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V
    .locals 0

    .prologue
    .line 176
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$2;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 5
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    const-string v4, "com.esmertec.android.jbed.action.PUSHSMS"

    const-string v3, "JbedAppActivity"

    .line 178
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v1

    const-string v2, "com.esmertec.android.jbed.action.VMSTARTED"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 179
    const-string v1, "JbedAppActivity"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "get ACTION_JBED_VM_STARTED SmsIntent="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$400()Landroid/content/Intent;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 180
    invoke-static {}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$400()Landroid/content/Intent;

    move-result-object v1

    if-eqz v1, :cond_0

    .line 182
    const-string v1, "JbedAppActivity"

    const-string v1, "sendBroadcast(SmsIntent)"

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 183
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 184
    .local v0, "pushSmsIntent":Landroid/content/Intent;
    const-string v1, "com.esmertec.android.jbed.action.PUSHSMS"

    invoke-virtual {v0, v4}, Landroid/content/Intent;->setAction(Ljava/lang/String;)Landroid/content/Intent;

    .line 185
    const-string v1, "com.esmertec.android.jbed.action.PUSHSMS"

    invoke-static {}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$400()Landroid/content/Intent;

    move-result-object v1

    invoke-virtual {v0, v4, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;

    .line 186
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$2;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v1, v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->sendBroadcast(Landroid/content/Intent;)V

    .line 190
    .end local v0    # "pushSmsIntent":Landroid/content/Intent;
    :cond_0
    return-void
.end method
