.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

.field final synthetic val$edtPwd:Landroid/widget/EditText;

.field final synthetic val$edtText:Landroid/widget/EditText;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;Landroid/widget/EditText;Landroid/widget/EditText;)V
    .locals 0

    .prologue
    .line 409
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->val$edtText:Landroid/widget/EditText;

    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->val$edtPwd:Landroid/widget/EditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 411
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->val$edtText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;->val$edtPwd:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x1

    invoke-virtual {v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallAuthorization(Ljava/lang/String;Ljava/lang/String;Z)V

    .line 413
    return-void
.end method
