.class Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;
.super Ljava/lang/Object;
.source "JbedShowInfoActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V
    .locals 0

    .prologue
    .line 73
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 6
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    const/4 v5, 0x0

    .line 75
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v2

    invoke-virtual {v2, v5}, Landroid/content/pm/PackageManager;->getInstalledPackages(I)Ljava/util/List;

    move-result-object v1

    .line 76
    .local v1, "packageList":Ljava/util/List;, "Ljava/util/List<Landroid/content/pm/PackageInfo;>;"
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v2

    if-ge v0, v2, :cond_0

    .line 77
    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/pm/PackageInfo;

    iget-object v2, v2, Landroid/content/pm/PackageInfo;->packageName:Ljava/lang/String;

    invoke-static {}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->access$000()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 78
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v2

    invoke-static {}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->access$000()Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4, v5}, Landroid/content/pm/PackageManager;->deletePackage(Ljava/lang/String;Landroid/content/pm/IPackageDeleteObserver;I)V

    .line 81
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->finish()V

    .line 82
    return-void

    .line 76
    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0
.end method
