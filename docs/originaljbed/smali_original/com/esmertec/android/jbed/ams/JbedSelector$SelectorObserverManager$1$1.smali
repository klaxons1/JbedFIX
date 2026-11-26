.class Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;
.super Ljava/lang/Thread;
.source "JbedSelector.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;->handleMessage(Landroid/os/Message;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;)V
    .locals 0

    .prologue
    .line 139
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;->this$1:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 141
    const-string v1, "JbedSelector"

    const-string v2, "start to parse selector files and save them to db!!!"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 142
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelector;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;->this$1:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$100(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/content/Context;

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    .line 143
    .local v0, "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->loadFromFiles()V

    .line 144
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1$1;->this$1:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;->this$0:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->access$100(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->storeToDb(Landroid/content/Context;)V

    .line 145
    return-void
.end method
