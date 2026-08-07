.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;)V
    .locals 0

    .prologue
    .line 1331
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 1333
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->selected:I

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->access$1000(Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;I)I

    move-result v1

    iput v1, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->orderId:I

    .line 1334
    const-string v0, "AmsEventHandler"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "SortSettingEventHandler selected:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->selected:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " ,orderId:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->orderId:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1335
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x272e

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->orderId:I

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 1336
    return-void
.end method
