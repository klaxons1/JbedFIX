.class Lcom/esmertec/android/jbed/service/JbedService$2;
.super Landroid/content/BroadcastReceiver;
.source "JbedService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedService;)V
    .locals 0

    .prologue
    .line 321
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 324
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedService;->access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->updateSystemTime()V

    .line 325
    return-void
.end method
