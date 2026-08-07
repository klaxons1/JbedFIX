.class Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;
.super Ljava/lang/Object;
.source "JbedLcduiManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "SoftBar"
.end annotation


# instance fields
.field private mLeft:Ljava/lang/String;

.field private mRight:Ljava/lang/String;

.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V
    .locals 1

    .prologue
    const/4 v0, 0x0

    .line 51
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 52
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mLeft:Ljava/lang/String;

    .line 53
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mRight:Ljava/lang/String;

    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;

    .prologue
    .line 51
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V

    return-void
.end method


# virtual methods
.method onSoftButtonChanged()V
    .locals 3

    .prologue
    .line 65
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isSupportSoftKeyboard()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 66
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mLeft:Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mRight:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V

    .line 68
    :cond_0
    return-void
.end method

.method onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p1, "left"    # Ljava/lang/String;
    .param p2, "right"    # Ljava/lang/String;

    .prologue
    .line 56
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mLeft:Ljava/lang/String;

    .line 57
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mRight:Ljava/lang/String;

    .line 58
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 59
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mLeft:Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mRight:Ljava/lang/String;

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;->onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V

    .line 62
    :cond_0
    return-void
.end method

.method reset()V
    .locals 1

    .prologue
    const/4 v0, 0x0

    .line 71
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mLeft:Ljava/lang/String;

    .line 72
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$SoftBar;->mRight:Ljava/lang/String;

    .line 73
    return-void
.end method
