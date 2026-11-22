.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$2;
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
    .line 1279
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 1281
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    iput p2, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;->selected:I

    .line 1282
    return-void
.end method
