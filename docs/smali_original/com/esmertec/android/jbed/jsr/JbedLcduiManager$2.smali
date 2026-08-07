.class Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;
.super Ljava/lang/Object;
.source "JbedLcduiManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V
    .locals 0

    .prologue
    .line 200
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
    .locals 2
    .param p1, "client"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 203
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$002(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 204
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$700(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 206
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->repaintAll()V

    .line 207
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$702(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Z)Z

    .line 209
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$800(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->onSoftButtonChanged()V

    .line 210
    return-void
.end method

.method public onClientDetached()V
    .locals 2

    .prologue
    .line 213
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$002(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 214
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$800(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->reset()V

    .line 215
    return-void
.end method
