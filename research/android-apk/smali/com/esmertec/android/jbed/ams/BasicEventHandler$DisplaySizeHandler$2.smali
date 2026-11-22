.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)V
    .locals 0

    .prologue
    .line 1736
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 5
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 1738
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->access$1900(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->access$2000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)I

    move-result v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->access$2100(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)[Ljava/lang/String;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-static {v4}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;->access$2200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;)I

    move-result v4

    aget-object v3, v3, v4

    invoke-virtual {v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestSetDisplaySize(Ljava/lang/String;ILjava/lang/String;)V

    .line 1739
    return-void
.end method
