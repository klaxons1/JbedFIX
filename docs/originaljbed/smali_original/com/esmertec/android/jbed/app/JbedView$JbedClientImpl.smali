.class Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;
.super Lcom/esmertec/android/jbed/app/IJbedClient$Stub;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "JbedClientImpl"
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z


# instance fields
.field private mHandler:Landroid/os/Handler;

.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedView;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 467
    const-class v0, Lcom/esmertec/android/jbed/app/JbedView;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->$assertionsDisabled:Z

    return-void

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedView;)V
    .locals 1

    .prologue
    .line 467
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;-><init>()V

    .line 469
    new-instance v0, Landroid/os/Handler;

    invoke-direct {v0}, Landroid/os/Handler;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->mHandler:Landroid/os/Handler;

    return-void
.end method


# virtual methods
.method public finish()V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 475
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v0

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->access$1002(Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;Z)Z

    .line 476
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;

    move-result-object v0

    const v1, 0x1d4c2

    invoke-static {v0, v1}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 477
    return-void
.end method

.method public getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    .line 497
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/JbedView;->mVideoClient:Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    return-object v0
.end method

.method public onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p1, "leftButton"    # Ljava/lang/String;
    .param p2, "rightButton"    # Ljava/lang/String;

    .prologue
    .line 501
    const/4 v1, 0x2

    new-array v0, v1, [Ljava/lang/String;

    const/4 v1, 0x0

    aput-object p1, v0, v1

    const/4 v1, 0x1

    aput-object p2, v0, v1

    .line 502
    .local v0, "buttonText":[Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;

    move-result-object v1

    const v2, 0x1d4c7

    invoke-virtual {v1, v2, v0}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 503
    return-void
.end method

.method public repaint(IIIIIIFF)V
    .locals 7
    .param p1, "clipLeft"    # I
    .param p2, "clipTop"    # I
    .param p3, "clipRight"    # I
    .param p4, "clipBottom"    # I
    .param p5, "width"    # I
    .param p6, "height"    # I
    .param p7, "pScale"    # F
    .param p8, "lScale"    # F
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    const/4 v2, 0x4

    const v3, 0xffff

    .line 483
    sget-boolean v1, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->$assertionsDisabled:Z

    if-nez v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mHandler:Landroid/os/Handler;

    if-nez v1, :cond_0

    new-instance v1, Ljava/lang/AssertionError;

    invoke-direct {v1}, Ljava/lang/AssertionError;-><init>()V

    throw v1

    .line 486
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v2}, Landroid/os/Handler;->removeMessages(I)V

    .line 488
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v6

    .line 489
    .local v6, "msg":Landroid/os/Message;
    and-int v1, p1, v3

    shl-int/lit8 v1, v1, 0x10

    and-int v2, p2, v3

    or-int/2addr v1, v2

    iput v1, v6, Landroid/os/Message;->arg1:I

    .line 490
    and-int v1, p3, v3

    shl-int/lit8 v1, v1, 0x10

    and-int v2, p4, v3

    or-int/2addr v1, v2

    iput v1, v6, Landroid/os/Message;->arg2:I

    .line 491
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    move v2, p5

    move v3, p6

    move v4, p7

    move v5, p8

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;-><init>(Lcom/esmertec/android/jbed/app/JbedView;IIFF)V

    .line 492
    .local v0, "msi":Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;
    iput-object v0, v6, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 493
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedClientImpl;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v1

    invoke-virtual {v1, v6}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->handleOrEnqueue(Landroid/os/Message;)V

    .line 494
    return-void
.end method
