.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnCancelListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;)V
    .locals 0

    .prologue
    .line 1670
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCancel(Landroid/content/DialogInterface;)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;

    .prologue
    .line 1672
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;

    iget-object p0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/16 v0, 0xf

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestPlatformRequestAnswer(I)V

    .line 1673
    return-void
.end method
