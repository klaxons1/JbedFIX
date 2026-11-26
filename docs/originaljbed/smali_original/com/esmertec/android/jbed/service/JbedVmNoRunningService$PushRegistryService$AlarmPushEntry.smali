.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$PushEntry;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "AlarmPushEntry"
.end annotation


# instance fields
.field private mTimer:Ljava/util/Timer;

.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V
    .locals 1

    .prologue
    .line 349
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 351
    new-instance v0, Ljava/util/Timer;

    invoke-direct {v0}, Ljava/util/Timer;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->mTimer:Ljava/util/Timer;

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$1;

    .prologue
    .line 349
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;)V

    return-void
.end method


# virtual methods
.method public register(Ljava/lang/String;Ljava/lang/String;)V
    .locals 6
    .param p1, "port"    # Ljava/lang/String;
    .param p2, "param1"    # Ljava/lang/String;

    .prologue
    .line 354
    const/16 v4, 0x10

    invoke-static {p2, v4}, Ljava/lang/Long;->parseLong(Ljava/lang/String;I)J

    move-result-wide v2

    .line 355
    .local v2, "launchTime":J
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v4

    sub-long v0, v2, v4

    .line 356
    .local v0, "delayMillis":J
    const-wide/16 v4, 0x0

    cmp-long v4, v0, v4

    if-gez v4, :cond_0

    .line 357
    const-wide/16 v0, 0x0

    .line 359
    :cond_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->mTimer:Ljava/util/Timer;

    new-instance v5, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry$1;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry$1;-><init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;)V

    invoke-virtual {v4, v5, v0, v1}, Ljava/util/Timer;->schedule(Ljava/util/TimerTask;J)V

    .line 365
    return-void
.end method

.method public unregister()V
    .locals 1

    .prologue
    .line 368
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$AlarmPushEntry;->mTimer:Ljava/util/Timer;

    invoke-virtual {v0}, Ljava/util/Timer;->cancel()V

    .line 369
    return-void
.end method
