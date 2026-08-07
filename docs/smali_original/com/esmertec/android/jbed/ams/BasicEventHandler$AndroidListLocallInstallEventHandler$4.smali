.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


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
    .line 1030
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "pos"    # I

    .prologue
    .line 1032
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "file:///"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->access$700()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1, p2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mPath:Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 1033
    .local v0, "fileUri":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    iget-object p0, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallEvent(Ljava/lang/String;)V

    .line 1034
    invoke-interface {p1}, Landroid/content/DialogInterface;->dismiss()V

    .line 1035
    return-void
.end method
