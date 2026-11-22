.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;
.super Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;)V
    .locals 0

    .prologue
    .line 624
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;-><init>()V

    return-void
.end method


# virtual methods
.method public execute(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 626
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstrallPreviewJadEvent(Z)V

    .line 627
    return-void
.end method
