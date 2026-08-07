.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->showMultiChooseConfirm()V
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
    .line 388
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 390
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Z

    move-result-object v1

    array-length v1, v1

    if-ge v0, v1, :cond_1

    .line 391
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Z

    move-result-object v1

    aget-boolean v1, v1, v0

    if-eqz v1, :cond_0

    .line 392
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v1, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;->access$200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v2

    aget-object v2, v2, v0

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveEvent(Ljava/lang/String;)V

    .line 390
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 395
    :cond_1
    return-void
.end method
