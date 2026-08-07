.class Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1$1;
.super Ljava/lang/Object;
.source "JbedLcduiManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->notifyOnKey(Landroid/view/KeyEvent;)Z
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;)V
    .locals 0

    .prologue
    .line 114
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 116
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$300(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V

    .line 117
    return-void
.end method
