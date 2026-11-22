.class Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;
.super Landroid/os/Handler;
.source "JbedProgressDialog.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedProgressDialog;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedProgressDialog;)V
    .locals 0

    .prologue
    .line 113
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;->this$0:Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 8
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    .line 116
    invoke-super {p0, p1}, Landroid/os/Handler;->handleMessage(Landroid/os/Message;)V

    .line 119
    iget-object v4, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;->this$0:Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    invoke-static {v4}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->access$000(Lcom/esmertec/android/jbed/app/JbedProgressDialog;)Landroid/widget/ProgressBar;

    move-result-object v4

    invoke-virtual {v4}, Landroid/widget/ProgressBar;->getProgress()I

    move-result v3

    .line 120
    .local v3, "progress":I
    iget-object v4, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;->this$0:Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    invoke-static {v4}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->access$000(Lcom/esmertec/android/jbed/app/JbedProgressDialog;)Landroid/widget/ProgressBar;

    move-result-object v4

    invoke-virtual {v4}, Landroid/widget/ProgressBar;->getMax()I

    move-result v0

    .line 121
    .local v0, "max":I
    int-to-double v4, v3

    int-to-double v6, v0

    div-double v1, v4, v6

    .line 122
    .local v1, "percent":D
    return-void
.end method
