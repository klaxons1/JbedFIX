.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry$1;
.super Ljava/util/TimerTask;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->register(Ljava/lang/String;Ljava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;)V
    .locals 0

    .prologue
    .line 359
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry$1;->this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 362
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry$1;->this$1:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;->access$900(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    .line 363
    return-void
.end method
