.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;
.super Ljava/lang/Thread;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->onCreate()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;)V
    .locals 0

    .prologue
    .line 85
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 88
    const-string v0, "JbedVmNoRunningService"

    const-string v1, "JbedVmNoRunningService Run()"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 89
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->onInit()V

    .line 91
    return-void
.end method
