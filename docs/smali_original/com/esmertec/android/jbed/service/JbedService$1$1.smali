.class Lcom/esmertec/android/jbed/service/JbedService$1$1;
.super Lcom/esmertec/android/jbed/service/IJbedConnection$Stub;
.source "JbedService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedService$1;->openConnection()Lcom/esmertec/android/jbed/service/IJbedConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/service/JbedService$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedService$1;)V
    .locals 0

    .prologue
    .line 98
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedService$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedService$1;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/IJbedConnection$Stub;-><init>()V

    return-void
.end method


# virtual methods
.method public getUiListener()Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 101
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedService$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$000(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/IJbedUiListener;

    move-result-object v0

    return-object v0
.end method

.method public setJbedClient(Lcom/esmertec/android/jbed/app/IJbedClient;)V
    .locals 4
    .param p1, "client"    # Lcom/esmertec/android/jbed/app/IJbedClient;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 105
    if-nez p1, :cond_0

    const/4 v3, 0x0

    move-object v0, v3

    .line 106
    .local v0, "clientProxy":Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    :goto_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedService$1$1;->this$1:Lcom/esmertec/android/jbed/service/JbedService$1;

    iget-object v3, v3, Lcom/esmertec/android/jbed/service/JbedService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedService;->access$200(Lcom/esmertec/android/jbed/service/JbedService;)Ljava/util/List;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 107
    .local v2, "l":Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;
    if-eqz v0, :cond_1

    .line 108
    invoke-interface {v2, v0}, Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;->onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V

    goto :goto_1

    .line 105
    .end local v0    # "clientProxy":Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .end local v1    # "i$":Ljava/util/Iterator;
    .end local v2    # "l":Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;
    :cond_0
    new-instance v3, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    invoke-direct {v3, p1}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;-><init>(Lcom/esmertec/android/jbed/app/IJbedClient;)V

    move-object v0, v3

    goto :goto_0

    .line 111
    .restart local v0    # "clientProxy":Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .restart local v1    # "i$":Ljava/util/Iterator;
    .restart local v2    # "l":Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;
    :cond_1
    invoke-interface {v2}, Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;->onClientDetached()V

    goto :goto_1

    .line 114
    .end local v2    # "l":Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;
    :cond_2
    return-void
.end method
