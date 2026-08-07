.class Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;
.super Landroid/os/Handler;
.source "JbedSelector.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)V
    .locals 0

    .prologue
    .line 134
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 2
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    .line 137
    new-instance v0, Landroid/content/Intent;

    const-string v1, "android.intent.action.SYNC"

    invoke-direct {v0, v1}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 138
    .local v0, "intent":Landroid/content/Intent;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$100(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;)V

    .line 139
    new-instance v1, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;-><init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;)V

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;->start()V

    .line 147
    return-void
.end method
