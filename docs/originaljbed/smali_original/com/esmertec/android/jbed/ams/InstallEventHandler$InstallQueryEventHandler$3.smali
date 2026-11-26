.class Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Ljava/lang/Runnable;


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
    .line 350
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 352
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->access$000(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 354
    :try_start_0
    invoke-static {}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->access$100()Landroid/app/AlertDialog;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog;->dismiss()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 358
    :goto_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallQueryEvent(Z)V

    .line 360
    :cond_0
    return-void

    .line 355
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;
    :catch_0
    move-exception v0

    goto :goto_0
.end method
