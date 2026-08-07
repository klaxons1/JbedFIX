.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$1;
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
    .line 1338
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 0
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 1340
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 1341
    return-void
.end method
