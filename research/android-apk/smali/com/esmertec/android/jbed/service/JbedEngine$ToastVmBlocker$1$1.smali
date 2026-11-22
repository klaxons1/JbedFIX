.class Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;)V
    .locals 0

    .prologue
    .line 228
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 230
    const/4 v1, 0x6

    const/16 v2, 0x16

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getString(II)Ljava/lang/String;

    move-result-object v0

    .line 231
    .local v0, "text":Ljava/lang/String;
    const-string v1, "%1"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, ""

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;

    iget-object v3, v3, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->access$800(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)I

    move-result v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 232
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->val$toast:Landroid/widget/Toast;

    invoke-virtual {v1, v0}, Landroid/widget/Toast;->setText(Ljava/lang/CharSequence;)V

    .line 233
    return-void
.end method
