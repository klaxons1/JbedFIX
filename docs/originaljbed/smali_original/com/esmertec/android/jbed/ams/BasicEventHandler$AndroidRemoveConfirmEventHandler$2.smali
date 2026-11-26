.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;
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
    .line 481
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 484
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x7

    if-ne v1, v2, :cond_1

    .line 485
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->access$300(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)Z

    move-result v0

    .line 488
    .local v0, "isSuccess":Z
    :goto_0
    if-eqz v0, :cond_0

    .line 489
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271a

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 490
    :cond_0
    return-void

    .line 487
    .end local v0    # "isSuccess":Z
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;->access$400(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;)Z

    move-result v0

    .restart local v0    # "isSuccess":Z
    goto :goto_0
.end method
