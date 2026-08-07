.class Lcom/esmertec/android/jbed/app/JbedView$1;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Landroid/view/SurfaceHolder$Callback;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedView;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedView;)V
    .locals 0

    .prologue
    .line 302
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public surfaceChanged(Landroid/view/SurfaceHolder;III)V
    .locals 2
    .param p1, "holder"    # Landroid/view/SurfaceHolder;
    .param p2, "f"    # I
    .param p3, "w"    # I
    .param p4, "h"    # I

    .prologue
    .line 334
    const-string v0, "JbedView"

    const-string v1, "surfaceChanged..."

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 338
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$200(Lcom/esmertec/android/jbed/app/JbedView;)V

    .line 339
    return-void
.end method

.method public surfaceCreated(Landroid/view/SurfaceHolder;)V
    .locals 3
    .param p1, "holder"    # Landroid/view/SurfaceHolder;

    .prologue
    .line 304
    const-string v0, "JbedView"

    const-string v1, "surfaceCreated..."

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 306
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-interface {p1}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$000(Lcom/esmertec/android/jbed/app/JbedView;Landroid/view/Surface;)V

    .line 308
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    new-instance v1, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {v1, v2}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;-><init>(Lcom/esmertec/android/jbed/app/JbedView;)V

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$102(Lcom/esmertec/android/jbed/app/JbedView;Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    .line 309
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->start()V

    .line 310
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/app/JbedView$1$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/JbedView$1$1;-><init>(Lcom/esmertec/android/jbed/app/JbedView$1;)V

    invoke-interface {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->connect(Lcom/esmertec/android/jbed/app/JbedView$Callback;)V

    .line 330
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;

    move-result-object v0

    const v1, 0x1d4c0

    invoke-static {v0, v1}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 331
    return-void
.end method

.method public surfaceDestroyed(Landroid/view/SurfaceHolder;)V
    .locals 3
    .param p1, "holder"    # Landroid/view/SurfaceHolder;

    .prologue
    const-string v2, "JbedView"

    .line 351
    const-string v0, "JbedView"

    const-string v0, "disconnect from service..."

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 352
    invoke-static {}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->dispose()V

    .line 353
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$300(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;

    move-result-object v0

    invoke-interface {v0}, Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;->disconnect()V

    .line 354
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$702(Lcom/esmertec/android/jbed/app/JbedView;Z)Z

    .line 356
    const-string v0, "JbedView"

    const-string v0, "repaint workthread is quiting..."

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 357
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->quit()V

    .line 359
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$100(Lcom/esmertec/android/jbed/app/JbedView;)Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedView$JbedPainter;->join()V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_0

    .line 362
    :goto_0
    const-string v0, "JbedView"

    const-string v0, "finalize the native app view...."

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 365
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-interface {p1}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/app/JbedView;->access$800(Lcom/esmertec/android/jbed/app/JbedView;Landroid/view/Surface;)V

    .line 368
    const-string v0, "JbedView"

    const-string v0, "Surface destroyed"

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 369
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedView$1;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedView;->access$600(Lcom/esmertec/android/jbed/app/JbedView;)Landroid/os/Handler;

    move-result-object v0

    const v1, 0x1d4c1

    invoke-static {v0, v1}, Landroid/os/Message;->obtain(Landroid/os/Handler;I)Landroid/os/Message;

    .line 370
    return-void

    .line 360
    :catch_0
    move-exception v0

    goto :goto_0
.end method
