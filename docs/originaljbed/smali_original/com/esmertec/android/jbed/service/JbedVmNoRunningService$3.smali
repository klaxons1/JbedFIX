.class Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;
.super Ljava/lang/Object;
.source "JbedVmNoRunningService.java"

# interfaces
.implements Landroid/content/ServiceConnection;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->launchPowerOnMidlets(Lcom/esmertec/android/jbed/ams/JbedSelector;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

.field final synthetic val$powerOnMidlets:Ljava/util/List;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;Ljava/util/List;)V
    .locals 0

    .prologue
    .line 166
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    iput-object p2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->val$powerOnMidlets:Ljava/util/List;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onServiceConnected(Landroid/content/ComponentName;Landroid/os/IBinder;)V
    .locals 14
    .param p1, "name"    # Landroid/content/ComponentName;
    .param p2, "service"    # Landroid/os/IBinder;

    .prologue
    .line 168
    invoke-static/range {p2 .. p2}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v0

    .line 171
    .local v0, "jbedService":Lcom/esmertec/android/jbed/service/IJbedService;
    :try_start_0
    new-instance v13, Landroid/graphics/PixelFormat;

    invoke-direct {v13}, Landroid/graphics/PixelFormat;-><init>()V

    .line 172
    .local v13, "pixFormat":Landroid/graphics/PixelFormat;
    const/4 v1, 0x4

    invoke-static {v1, v13}, Landroid/graphics/PixelFormat;->getPixelFormatInfo(ILandroid/graphics/PixelFormat;)V

    .line 173
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    const-string v2, "window"

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    .end local p1    # "name":Landroid/content/ComponentName;
    check-cast p1, Landroid/view/WindowManager;

    invoke-interface {p1}, Landroid/view/WindowManager;->getDefaultDisplay()Landroid/view/Display;

    move-result-object v9

    .line 174
    .local v9, "d":Landroid/view/Display;
    invoke-virtual {v9}, Landroid/view/Display;->getWidth()I

    move-result v1

    invoke-virtual {v9}, Landroid/view/Display;->getHeight()I

    move-result v2

    iget v3, v13, Landroid/graphics/PixelFormat;->bytesPerPixel:I

    invoke-virtual {v9}, Landroid/view/Display;->getWidth()I

    move-result v4

    invoke-virtual {v9}, Landroid/view/Display;->getHeight()I

    move-result v5

    const/4 v6, 0x0

    const/4 v7, 0x0

    invoke-interface/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/IJbedService;->startVm(IIIIIZZ)V

    .line 177
    invoke-interface {v0}, Lcom/esmertec/android/jbed/service/IJbedService;->openAmsConnection()Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v8

    .line 179
    .local v8, "amsConn":Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->val$powerOnMidlets:Ljava/util/List;

    invoke-interface {v8, v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->setPowerOnMidlets(Ljava/util/List;)V

    .line 181
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->val$powerOnMidlets:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v11

    .local v11, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v11}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v11}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 182
    .local v12, "m":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    const/4 v1, 0x2

    iget v2, v12, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    iget-object v3, v12, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->getBytes()[B

    move-result-object v3

    invoke-interface {v8, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->requestEvent(II[B)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 184
    .end local v8    # "amsConn":Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .end local v9    # "d":Landroid/view/Display;
    .end local v11    # "i$":Ljava/util/Iterator;
    .end local v12    # "m":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v13    # "pixFormat":Landroid/graphics/PixelFormat;
    :catch_0
    move-exception v1

    move-object v10, v1

    .line 185
    .local v10, "e":Landroid/os/RemoteException;
    :try_start_1
    new-instance v1, Ljava/lang/RuntimeException;

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "failed to call requestEvent: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 187
    .end local v10    # "e":Landroid/os/RemoteException;
    :catchall_0
    move-exception v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-virtual {v2, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->unbindService(Landroid/content/ServiceConnection;)V

    throw v1

    .restart local v8    # "amsConn":Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .restart local v9    # "d":Landroid/view/Display;
    .restart local v11    # "i$":Ljava/util/Iterator;
    .restart local v13    # "pixFormat":Landroid/graphics/PixelFormat;
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService$3;->this$0:Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;

    invoke-virtual {v1, p0}, Lcom/esmertec/android/jbed/service/JbedVmNoRunningService;->unbindService(Landroid/content/ServiceConnection;)V

    .line 189
    return-void
.end method

.method public onServiceDisconnected(Landroid/content/ComponentName;)V
    .locals 0
    .param p1, "name"    # Landroid/content/ComponentName;

    .prologue
    .line 193
    return-void
.end method
