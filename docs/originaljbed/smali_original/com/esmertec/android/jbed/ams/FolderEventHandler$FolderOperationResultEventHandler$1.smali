.class Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler$1;
.super Ljava/lang/Object;
.source "FolderEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;)V
    .locals 0

    .prologue
    .line 121
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 0
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 123
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 124
    return-void
.end method
