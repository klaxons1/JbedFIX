.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$6;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->showMultiChooseConfirm()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 313
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$6;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 315
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler$6;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;->access$500(Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;)V

    .line 316
    return-void
.end method
