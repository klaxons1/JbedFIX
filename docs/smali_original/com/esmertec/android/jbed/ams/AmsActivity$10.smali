.class Lcom/esmertec/android/jbed/ams/AmsActivity$10;
.super Ljava/lang/Thread;
.source "AmsActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;->onKeyDown(ILandroid/view/KeyEvent;)Z
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
    .line 678
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 680
    const/4 v1, 0x1

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$102(Z)Z

    .line 681
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1100(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_0

    .line 685
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1100(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v1

    iget-object v1, v1, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v1}, Lcom/esmertec/android/jbed/service/IJbedService;->shutdownVm()V

    .line 686
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1100(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedApp;->onTerminate()V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 691
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$10;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->finish()V

    .line 692
    const/4 v1, 0x0

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$102(Z)Z

    .line 693
    return-void

    .line 687
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 688
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call mJbedService.shutdownVm"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method
