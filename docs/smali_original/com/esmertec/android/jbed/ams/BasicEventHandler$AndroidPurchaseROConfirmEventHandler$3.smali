.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;)V
    .locals 0

    .prologue
    .line 1573
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 1575
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object p0, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler$3;
    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;->access$1800(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;Ljava/lang/String;)Z

    .line 1576
    return-void
.end method
