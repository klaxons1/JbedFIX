.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;)V
    .locals 0

    .prologue
    .line 1284
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 1286
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v1, 0x2725

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->selected:I

    const/4 v3, -0x1

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 1287
    return-void
.end method
