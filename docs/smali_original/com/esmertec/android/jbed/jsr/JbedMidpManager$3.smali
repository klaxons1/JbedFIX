.class Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;
.super Ljava/lang/Object;
.source "JbedMidpManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V
    .locals 0

    .prologue
    .line 119
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
    .locals 1
    .param p1, "client"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 122
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$202(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 123
    return-void
.end method

.method public onClientDetached()V
    .locals 2

    .prologue
    .line 126
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$202(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .line 127
    return-void
.end method
