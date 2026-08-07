.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


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
    .line 629
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 631
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v0, 0x0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstrallPreviewJadEvent(Z)V

    .line 632
    return-void
.end method
