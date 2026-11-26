.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$3;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnMultiChoiceClickListener;


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
    .line 320
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;IZ)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichItem"    # I
    .param p3, "isChecked"    # Z

    .prologue
    .line 323
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Z

    move-result-object v0

    aput-boolean p3, v0, p2

    .line 324
    return-void
.end method
