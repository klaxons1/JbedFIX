.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;
.super Ljava/lang/Object;
.source "PermissionEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)V
    .locals 0

    .prologue
    .line 328
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 330
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestPermissionAnswerCommit()V

    .line 331
    return-void
.end method
