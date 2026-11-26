.class Lcom/esmertec/android/jbed/ams/AmsActivity$1;
.super Landroid/content/BroadcastReceiver;
.source "AmsActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0

    .prologue
    .line 140
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    return-void
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 143
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$000(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/os/Handler;

    move-result-object v0

    const/16 v1, 0x2712

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 144
    return-void
.end method
