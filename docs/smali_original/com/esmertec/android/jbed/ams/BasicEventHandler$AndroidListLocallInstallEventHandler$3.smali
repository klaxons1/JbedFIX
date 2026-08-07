.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;
.super Ljava/lang/Thread;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->run()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V
    .locals 0

    .prologue
    .line 1011
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    const/4 v0, 0x1

    .line 1013
    sput-boolean v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mThreadIsRunning:Z

    .line 1014
    sput-boolean v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mFileCollected:Z

    .line 1015
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->access$600(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V

    .line 1016
    const/4 v0, 0x0

    sput-boolean v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mThreadIsRunning:Z

    .line 1017
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    iget-boolean v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mIsOnlySdcard:Z

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestListLocalInstall(Z)V

    .line 1018
    return-void
.end method
