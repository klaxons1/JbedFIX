.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;

.field final synthetic val$suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 0

    .prologue
    .line 646
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;->val$suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "arg0"    # Landroid/content/DialogInterface;
    .param p2, "arg1"    # I

    .prologue
    .line 648
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler$1;->val$suite:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRemoveEvent(Ljava/lang/String;)V

    .line 649
    return-void
.end method
