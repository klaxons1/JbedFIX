.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;
.super Ljava/lang/Object;
.source "JbedSmsManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->onReceive(Landroid/content/Context;Landroid/content/Intent;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

.field final synthetic val$intent:Landroid/content/Intent;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;Landroid/content/Intent;)V
    .locals 0

    .prologue
    .line 235
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;->val$intent:Landroid/content/Intent;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 237
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->access$200()Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;->val$intent:Landroid/content/Intent;

    invoke-virtual {v2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 241
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;->val$intent:Landroid/content/Intent;

    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->access$300()Ljava/lang/String;

    move-result-object v2

    const/4 v3, -0x1

    invoke-virtual {v1, v2, v3}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v0

    .line 242
    .local v0, "nativeContext":I
    const-string v1, "JbedSmsManager"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, " success to send sms nativecontext="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 243
    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->access$400(IZ)V

    .line 245
    .end local v0    # "nativeContext":I
    :cond_0
    return-void
.end method
