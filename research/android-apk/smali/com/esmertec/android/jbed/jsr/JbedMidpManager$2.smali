.class Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;
.super Landroid/content/BroadcastReceiver;
.source "JbedMidpManager.java"


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
    .line 108
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 114
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    .line 115
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    .line 116
    return-void
.end method
