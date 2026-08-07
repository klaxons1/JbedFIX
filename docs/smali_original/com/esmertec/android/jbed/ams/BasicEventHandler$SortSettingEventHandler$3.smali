.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$3;
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
    .line 1326
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 1328
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    iput p2, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;->selected:I

    .line 1329
    return-void
.end method
