.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

.field final synthetic val$edtText:Landroid/widget/EditText;

.field final synthetic val$oldName:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;Landroid/widget/EditText;Ljava/lang/String;)V
    .locals 0

    .prologue
    .line 1366
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->val$edtText:Landroid/widget/EditText;

    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->val$oldName:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 1368
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->val$edtText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    .line 1369
    .local v0, "newName":Ljava/lang/String;
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->val$oldName:Ljava/lang/String;

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    .line 1370
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object p0, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1, p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRenameSuite(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)V

    .line 1372
    :cond_0
    return-void
.end method
