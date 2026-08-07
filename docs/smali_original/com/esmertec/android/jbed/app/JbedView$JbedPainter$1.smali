.class Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;
.super Landroid/os/Handler;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

.field final synthetic val$this$0:Lcom/esmertec/android/jbed/app/JbedView;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;Lcom/esmertec/android/jbed/app/JbedView;)V
    .locals 0

    .prologue
    .line 388
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    iput-object p2, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;->val$this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 10
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const v5, 0xffff

    .line 391
    iget v0, p1, Landroid/os/Message;->arg1:I

    shr-int/lit8 v0, v0, 0x10

    and-int/lit16 v1, v0, 0xfff

    .line 392
    .local v1, "clipLeft":I
    iget v0, p1, Landroid/os/Message;->arg1:I

    and-int v2, v0, v5

    .line 394
    .local v2, "clipTop":I
    iget v0, p1, Landroid/os/Message;->arg2:I

    shr-int/lit8 v0, v0, 0x10

    and-int/lit16 v3, v0, 0xfff

    .line 395
    .local v3, "clipRight":I
    iget v0, p1, Landroid/os/Message;->arg2:I

    and-int v4, v0, v5

    .line 396
    .local v4, "clipBottom":I
    iget-object v9, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v9, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;

    .line 400
    .local v9, "msi":Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter$1;->this$1:Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    iget-object v0, v0, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    iget v5, v9, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->width:I

    iget v6, v9, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->height:I

    iget v7, v9, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->porScale:F

    iget v8, v9, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->landScale:F

    invoke-static/range {v0 .. v8}, Lcom/esmertec/android/jbed/app/JbedView;->access$900(Lcom/esmertec/android/jbed/app/JbedView;IIIIIIFF)V

    .line 401
    sget-boolean v0, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    if-eqz v0, :cond_0

    .line 402
    const/4 v0, 0x0

    sput-boolean v0, Lcom/esmertec/android/jbed/app/JbedView;->isMidletStarting:Z

    .line 403
    :cond_0
    return-void
.end method
