.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 492
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 494
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 495
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v0

    const-string v1, "LGE"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v1, 0x7

    if-ne v0, v1, :cond_0

    .line 496
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2712

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 498
    :cond_0
    return-void
.end method
