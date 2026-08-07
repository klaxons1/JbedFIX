.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$VmStateListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;)V
    .locals 0

    .prologue
    .line 237
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onStarted()V
    .locals 2

    .prologue
    .line 239
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->access$402(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;Z)Z

    .line 240
    return-void
.end method

.method public onStopped()V
    .locals 2

    .prologue
    .line 243
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService$2;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;->access$402(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$SdcardService;Z)Z

    .line 244
    return-void
.end method
