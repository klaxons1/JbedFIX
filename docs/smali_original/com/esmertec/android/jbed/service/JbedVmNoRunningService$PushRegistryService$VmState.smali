.class final enum Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;
.super Ljava/lang/Enum;
.source "JbedVmNoRunningService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x401a
    name = "VmState"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum",
        "<",
        "Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

.field public static final enum STARTED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

.field public static final enum STARTING:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

.field public static final enum STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;


# direct methods
.method static constructor <clinit>()V
    .locals 5

    .prologue
    const/4 v4, 0x2

    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 301
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    const-string v1, "STOPED"

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 302
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    const-string v1, "STARTING"

    invoke-direct {v0, v1, v3}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTING:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 303
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    const-string v1, "STARTED"

    invoke-direct {v0, v1, v4}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    .line 300
    const/4 v0, 0x3

    new-array v0, v0, [Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STOPED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    aput-object v1, v0, v2

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTING:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    aput-object v1, v0, v3

    sget-object v1, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->STARTED:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    aput-object v1, v0, v4

    sput-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->$VALUES:[Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .prologue
    .line 300
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;
    .locals 1
    .param p0, "name"    # Ljava/lang/String;

    .prologue
    .line 300
    const-class v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    .end local p0    # "name":Ljava/lang/String;
    check-cast p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    return-object p0
.end method

.method public static values()[Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;
    .locals 1

    .prologue
    .line 300
    sget-object v0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->$VALUES:[Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    invoke-virtual {v0}, [Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$PushRegistryService$VmState;

    return-object v0
.end method
