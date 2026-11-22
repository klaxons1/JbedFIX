.class Lcom/esmertec/android/jbed/ams/AmsActivity$7;
.super Ljava/lang/Thread;
.source "AmsActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;->onServiceConnected()V
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
    .line 354
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 12

    .prologue
    .line 358
    new-instance v11, Landroid/graphics/PixelFormat;

    invoke-direct {v11}, Landroid/graphics/PixelFormat;-><init>()V

    .line 359
    .local v11, "pixFormat":Landroid/graphics/PixelFormat;
    const/4 v0, 0x4

    invoke-static {v0, v11}, Landroid/graphics/PixelFormat;->getPixelFormatInfo(ILandroid/graphics/PixelFormat;)V

    .line 361
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1100(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v0, v0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v1

    invoke-interface {v1}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/Display;->getWidth()I

    move-result v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v2

    invoke-interface {v2}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/Display;->getHeight()I

    move-result v2

    iget v3, v11, Landroid/graphics/PixelFormat;->bytesPerPixel:I

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v4

    invoke-interface {v4}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v4

    invoke-virtual {v4}, Landroid/view/Display;->getWidth()I

    move-result v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getWindowManager()Landroid/view/WindowManager;

    move-result-object v5

    invoke-interface {v5}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v5

    invoke-virtual {v5}, Landroid/view/Display;->getHeight()I

    move-result v5

    const/4 v6, 0x0

    const/4 v7, 0x0

    invoke-interface/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/IJbedService;->startVm(IIIIIZZ)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 369
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const/4 v1, 0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1202(Lcom/esmertec/android/jbed/ams/AmsActivity;Z)Z

    .line 370
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$000(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/os/Handler;

    move-result-object v0

    const/16 v1, 0x2712

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 371
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$000(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/os/Handler;

    move-result-object v0

    const/16 v1, 0x271d

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 374
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1300(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/util/ArrayList;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v9

    .local v9, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v9}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {v9}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Landroid/os/Message;

    .line 375
    .local v10, "message":Landroid/os/Message;
    invoke-virtual {v10}, Landroid/os/Message;->sendToTarget()V

    goto :goto_0

    .line 365
    .end local v9    # "i$":Ljava/util/Iterator;
    .end local v10    # "message":Landroid/os/Message;
    :catch_0
    move-exception v0

    move-object v8, v0

    .line 366
    .local v8, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "failed to call mJbedService.startVm()"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 377
    .end local v8    # "e":Landroid/os/RemoteException;
    .restart local v9    # "i$":Ljava/util/Iterator;
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1300(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/util/ArrayList;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 378
    return-void
.end method
