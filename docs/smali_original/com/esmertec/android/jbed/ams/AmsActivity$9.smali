.class Lcom/esmertec/android/jbed/ams/AmsActivity$9;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnCancelListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;->onCreateDialog(I)Landroid/app/Dialog;
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
    .line 640
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCancel(Landroid/content/DialogInterface;)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;

    .prologue
    .line 642
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallCancelEvent()V

    .line 643
    return-void
.end method
