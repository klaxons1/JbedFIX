.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;
.super Ljava/lang/Object;
.source "PermissionEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;

.field final synthetic val$spinner:Landroid/widget/Spinner;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;Landroid/widget/Spinner;)V
    .locals 0

    .prologue
    .line 161
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;->val$spinner:Landroid/widget/Spinner;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 163
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;->val$spinner:Landroid/widget/Spinner;

    invoke-virtual {v2}, Landroid/widget/Spinner;->getSelectedItem()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getKey()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Byte;

    invoke-virtual {p0}, Ljava/lang/Byte;->byteValue()B

    move-result v2

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestPermissionAnswer(IB)V

    .line 165
    return-void
.end method
