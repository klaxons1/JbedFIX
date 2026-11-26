.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V
    .locals 0

    .prologue
    .line 366
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    const/4 v1, 0x1

    .line 368
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->access$002(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;Z)Z

    .line 369
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallQueryEvent(Z)V

    .line 370
    return-void
.end method
