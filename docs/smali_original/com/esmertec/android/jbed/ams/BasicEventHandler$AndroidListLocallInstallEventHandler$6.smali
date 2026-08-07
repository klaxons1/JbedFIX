.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$6;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Ljava/io/FileFilter;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->findAllMidlets(Ljava/io/File;)V
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
    .line 1063
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$6;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public accept(Ljava/io/File;)Z
    .locals 6
    .param p1, "f"    # Ljava/io/File;

    .prologue
    const/4 v5, 0x0

    .line 1065
    invoke-virtual {p1}, Ljava/io/File;->isDirectory()Z

    move-result v4

    if-eqz v4, :cond_0

    .line 1068
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$6;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-static {v4, p1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->access$900(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Ljava/io/File;)V

    move v4, v5

    .line 1076
    :goto_0
    return v4

    .line 1071
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsConstants;->SUPPORTED_EXT_NAMES:[Ljava/lang/String;

    .local v0, "arr$":[Ljava/lang/String;
    array-length v3, v0

    .local v3, "len$":I
    const/4 v2, 0x0

    .local v2, "i$":I
    :goto_1
    if-ge v2, v3, :cond_2

    aget-object v1, v0, v2

    .line 1072
    .local v1, "extname":Ljava/lang/String;
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 1073
    const/4 v4, 0x1

    goto :goto_0

    .line 1071
    :cond_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .end local v1    # "extname":Ljava/lang/String;
    :cond_2
    move v4, v5

    .line 1076
    goto :goto_0
.end method
