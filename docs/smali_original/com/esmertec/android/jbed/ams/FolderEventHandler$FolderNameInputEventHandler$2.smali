.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$2;
.super Ljava/util/TimerTask;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;)V
    .locals 0

    .prologue
    .line 85
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 89
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;->mContext:Landroid/content/Context;

    const-string v2, "input_method"

    invoke-virtual {v1, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/inputmethod/InputMethodManager;

    .line 90
    .local v0, "imm":Landroid/view/inputmethod/InputMethodManager;
    const/4 v1, 0x0

    const/4 v2, 0x2

    invoke-virtual {v0, v1, v2}, Landroid/view/inputmethod/InputMethodManager;->toggleSoftInput(II)V

    .line 91
    return-void
.end method
