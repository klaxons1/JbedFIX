.class Lcom/esmertec/android/jbed/JbedApp$1;
.super Ljava/lang/Object;
.source "JbedApp.java"

# interfaces
.implements Landroid/content/ServiceConnection;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/JbedApp;->startService(Landroid/app/Activity;Landroid/os/Handler;J)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/JbedApp;

.field final synthetic val$activity:Landroid/app/Activity;

.field final synthetic val$handler:Landroid/os/Handler;

.field final synthetic val$id:J


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/JbedApp;Landroid/app/Activity;Landroid/os/Handler;J)V
    .locals 0

    .prologue
    .line 124
    iput-object p1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iput-object p2, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$activity:Landroid/app/Activity;

    iput-object p3, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$handler:Landroid/os/Handler;

    iput-wide p4, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$id:J

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onServiceConnected(Landroid/content/ComponentName;Landroid/os/IBinder;)V
    .locals 6
    .param p1, "className"    # Landroid/content/ComponentName;
    .param p2, "service"    # Landroid/os/IBinder;

    .prologue
    .line 126
    const-string v1, "JbedApp"

    const-string v2, "Connecte Service successfully"

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 132
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    invoke-static {p2}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/service/IJbedService;

    move-result-object v2

    iput-object v2, v1, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    .line 134
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, v2, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/service/IJbedService;->openConnection()Lcom/esmertec/android/jbed/service/IJbedConnection;

    move-result-object v2

    iput-object v2, v1, Lcom/esmertec/android/jbed/JbedApp;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    .line 135
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, v2, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/service/IJbedService;->openAmsConnection()Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v2

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/JbedApp;->access$002(Lcom/esmertec/android/jbed/JbedApp;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .line 136
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, v2, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    invoke-interface {v2}, Lcom/esmertec/android/jbed/service/IJbedService;->openTextFieldConnection()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v2

    iput-object v2, v1, Lcom/esmertec/android/jbed/JbedApp;->mJbedTextFieldConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 141
    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    iget-object v2, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$activity:Landroid/app/Activity;

    iget-object v3, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$handler:Landroid/os/Handler;

    iget-wide v4, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$id:J

    invoke-static {v1, v2, v3, v4, v5}, Lcom/esmertec/android/jbed/JbedApp;->access$100(Lcom/esmertec/android/jbed/JbedApp;Landroid/app/Activity;Landroid/os/Handler;J)V

    .line 142
    return-void

    .line 138
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 139
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call mJbedService.openConnection() "

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public onServiceDisconnected(Landroid/content/ComponentName;)V
    .locals 3
    .param p1, "className"    # Landroid/content/ComponentName;

    .prologue
    .line 145
    const-string v0, "JbedApp"

    const-string v1, "WARNING: diconnect from Service!"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 154
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp$1;->val$activity:Landroid/app/Activity;

    const v1, 0x7f050372

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;II)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 156
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedApp$1;->this$0:Lcom/esmertec/android/jbed/JbedApp;

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedApp;->access$200(Lcom/esmertec/android/jbed/JbedApp;)V

    .line 157
    return-void
.end method
