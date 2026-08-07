.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$2;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 326
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 328
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->access$000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)V

    .line 329
    return-void
.end method
