.class Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;
.super Landroid/os/FileObserver;
.source "JbedSelector.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "SelectorObserver"
.end annotation


# instance fields
.field private mInstalledPath:Ljava/lang/String;

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;Ljava/lang/String;)V
    .locals 3
    .param p2, "installedPath"    # Ljava/lang/String;

    .prologue
    .line 116
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    .line 117
    const/16 v0, 0x84

    invoke-direct {p0, p2, v0}, Landroid/os/FileObserver;-><init>(Ljava/lang/String;I)V

    .line 118
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->mInstalledPath:Ljava/lang/String;

    .line 119
    const-string v0, "JbedSelector"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "SelectorObserverManager observing path="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 120
    return-void
.end method


# virtual methods
.method public onEvent(ILjava/lang/String;)V
    .locals 5
    .param p1, "event"    # I
    .param p2, "path"    # Ljava/lang/String;

    .prologue
    const/4 v4, 0x0

    .line 123
    const-string v1, "JbedSelector"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "SelectorObserver onEvent event="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " path="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->mInstalledPath:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 124
    if-eqz p2, :cond_0

    const-string v1, "selector.utf"

    invoke-virtual {p2, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_1

    .line 131
    :cond_0
    :goto_0
    return-void

    .line 127
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$000(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/os/Handler;

    move-result-object v1

    invoke-virtual {v1, v4}, Landroid/os/Handler;->removeMessages(I)V

    .line 128
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$000(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/os/Handler;

    move-result-object v1

    invoke-virtual {v1, v4}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 130
    .local v0, "msg":Landroid/os/Message;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$000(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/os/Handler;

    move-result-object v1

    const-wide/16 v2, 0x1f4

    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->sendMessageDelayed(Landroid/os/Message;J)Z

    goto :goto_0
.end method
