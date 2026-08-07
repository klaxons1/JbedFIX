.class Lcom/esmertec/android/jbed/app/JbedAppActivity$3;
.super Ljava/lang/Object;
.source "JbedAppActivity.java"

# interfaces
.implements Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedAppActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V
    .locals 0

    .prologue
    .line 192
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public connect(Lcom/esmertec/android/jbed/app/JbedView$Callback;)V
    .locals 5
    .param p1, "callback"    # Lcom/esmertec/android/jbed/app/JbedView$Callback;

    .prologue
    .line 194
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$500(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Landroid/os/Handler;

    move-result-object v2

    const-wide/16 v3, 0x0

    invoke-virtual {v0, v1, v2, v3, v4}, Lcom/esmertec/android/jbed/JbedApp;->startService(Landroid/app/Activity;Landroid/os/Handler;J)V

    .line 195
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0, p1}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$002(Lcom/esmertec/android/jbed/app/JbedAppActivity;Lcom/esmertec/android/jbed/app/JbedView$Callback;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    .line 196
    return-void
.end method

.method public disconnect()V
    .locals 2

    .prologue
    .line 199
    const-string v0, "JbedAppActivity"

    const-string v1, "disconnect from service "

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 200
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$500(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Landroid/os/Handler;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->disconnet(Landroid/os/Handler;)V

    .line 201
    return-void
.end method

.method public getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;
    .locals 2

    .prologue
    .line 204
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$500(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Landroid/os/Handler;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedApp;->getAmsClient(Landroid/os/Handler;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    return-object v0
.end method

.method public getJbedConn()Lcom/esmertec/android/jbed/service/IJbedConnection;
    .locals 1

    .prologue
    .line 208
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v0, v0, Lcom/esmertec/android/jbed/JbedApp;->mJbedConn:Lcom/esmertec/android/jbed/service/IJbedConnection;

    return-object v0
.end method

.method public getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;
    .locals 1

    .prologue
    .line 212
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v0, v0, Lcom/esmertec/android/jbed/JbedApp;->mJbedService:Lcom/esmertec/android/jbed/service/IJbedService;

    return-object v0
.end method

.method public getTextFieldConn()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .locals 1

    .prologue
    .line 216
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$600(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/JbedApp;

    move-result-object v0

    iget-object v0, v0, Lcom/esmertec/android/jbed/JbedApp;->mJbedTextFieldConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    return-object v0
.end method
