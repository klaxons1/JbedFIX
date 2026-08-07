.class Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;
.super Ljava/lang/Thread;
.source "JbedEngine.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->showMessage()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

.field final synthetic val$toast:Landroid/widget/Toast;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;Landroid/widget/Toast;)V
    .locals 0

    .prologue
    .line 225
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    iput-object p2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->val$toast:Landroid/widget/Toast;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 227
    :goto_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->access$800(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)I

    move-result v0

    if-lez v0, :cond_0

    .line 228
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->access$900(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    new-instance v1, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 236
    const-wide/16 v0, 0x3e8

    :try_start_0
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_0

    .line 239
    :goto_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->access$810(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)I

    goto :goto_0

    .line 237
    :catch_0
    move-exception v0

    goto :goto_1

    .line 242
    :cond_0
    return-void
.end method
