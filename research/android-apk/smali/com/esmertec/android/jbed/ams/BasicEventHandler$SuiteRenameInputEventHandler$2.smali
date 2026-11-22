.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$2;
.super Ljava/util/TimerTask;
.source "BasicEventHandler.java"


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


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;)V
    .locals 0

    .prologue
    .line 1381
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 1385
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;->mContext:Landroid/content/Context;

    const-string v2, "input_method"

    invoke-virtual {v1, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/inputmethod/InputMethodManager;

    .line 1386
    .local v0, "imm":Landroid/view/inputmethod/InputMethodManager;
    const/4 v1, 0x0

    const/4 v2, 0x2

    invoke-virtual {v0, v1, v2}, Landroid/view/inputmethod/InputMethodManager;->toggleSoftInput(II)V

    .line 1387
    return-void
.end method
