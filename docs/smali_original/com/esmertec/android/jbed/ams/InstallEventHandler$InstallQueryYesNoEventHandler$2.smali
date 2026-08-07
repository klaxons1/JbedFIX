.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;)V
    .locals 0

    .prologue
    .line 508
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 510
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler$2;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallQueryYesNoResponse(Z)V

    .line 511
    return-void
.end method
