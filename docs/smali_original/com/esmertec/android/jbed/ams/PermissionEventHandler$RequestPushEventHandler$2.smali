.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;
.super Ljava/lang/Object;
.source "PermissionEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnCancelListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;)V
    .locals 0

    .prologue
    .line 412
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCancel(Landroid/content/DialogInterface;)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;

    .prologue
    .line 414
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v2, 0x4

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestPushAnswer(IB)V

    .line 415
    return-void
.end method
