.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidListLocallInstallEventHandler"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
    }
.end annotation


# static fields
.field static mFileCollected:Z

.field private static mLocalInsallFiles:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;",
            ">;"
        }
    .end annotation
.end field

.field static mThreadIsRunning:Z


# instance fields
.field private final excludeFolders:[Ljava/lang/String;

.field private final isCompressJarFile:Z

.field mIsOnlySdcard:Z


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    const/4 v0, 0x0

    .line 908
    sput-boolean v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mFileCollected:Z

    .line 909
    sput-boolean v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mThreadIsRunning:Z

    .line 915
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .prologue
    .line 900
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 906
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mIsOnlySdcard:Z

    .line 913
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->isCompressJarFile:Z

    .line 917
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getExcludeSearchFolder()Ljava/lang/String;

    move-result-object v0

    const-string v1, ":"

    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->excludeFolders:[Ljava/lang/String;

    .line 1087
    return-void
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    .prologue
    .line 900
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->collectLocalInstallFiles()V

    return-void
.end method

.method static synthetic access$700()Ljava/util/List;
    .locals 1

    .prologue
    .line 900
    sget-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Ljava/lang/String;Landroid/app/AlertDialog;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # Landroid/app/AlertDialog;

    .prologue
    .line 900
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->showSubDialog(Ljava/lang/String;Landroid/app/AlertDialog;)V

    return-void
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Ljava/io/File;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;
    .param p1, "x1"    # Ljava/io/File;

    .prologue
    .line 900
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->findAllMidlets(Ljava/io/File;)V

    return-void
.end method

.method private collectLocalInstallFiles()V
    .locals 6

    .prologue
    .line 920
    const/4 v0, 0x0

    .line 922
    .local v0, "dir":Ljava/io/File;
    iget-boolean v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mIsOnlySdcard:Z

    if-nez v4, :cond_0

    .line 923
    new-instance v0, Ljava/io/File;

    .end local v0    # "dir":Ljava/io/File;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mContext:Landroid/content/Context;

    invoke-static {v4}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v4

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/JbedSettings;->getLocalInstallDir()Ljava/lang/String;

    move-result-object v4

    invoke-direct {v0, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 924
    .restart local v0    # "dir":Ljava/io/File;
    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->findAllMidlets(Ljava/io/File;)V

    .line 928
    :cond_0
    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mContext:Landroid/content/Context;

    const/4 v5, 0x0

    invoke-direct {v2, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;-><init>(Landroid/content/Context;Landroid/os/Handler;)V

    .line 929
    .local v2, "manager":Lcom/esmertec/android/jbed/jsr/JbedFileManager;
    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->getRootPathList()Ljava/util/List;

    move-result-object v3

    .line 932
    .local v3, "roots":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_0
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v4

    if-ge v1, v4, :cond_1

    .line 933
    new-instance v0, Ljava/io/File;

    .end local v0    # "dir":Ljava/io/File;
    invoke-interface {v3, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-direct {v0, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 934
    .restart local v0    # "dir":Ljava/io/File;
    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->findAllMidlets(Ljava/io/File;)V

    .line 932
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 938
    :cond_1
    sget-object v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-static {}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->access$500()Ljava/util/Comparator;

    move-result-object v5

    invoke-static {v4, v5}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 941
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->compressJarFiles()V

    .line 943
    return-void
.end method

.method private compressJarFiles()V
    .locals 8

    .prologue
    .line 1129
    sget-object v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v5}, Ljava/util/List;->size()I

    move-result v4

    .line 1131
    .local v4, "size":I
    const/4 v5, 0x1

    sub-int v2, v4, v5

    .local v2, "i":I
    :goto_0
    if-ltz v2, :cond_3

    .line 1132
    sget-object v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v5, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;

    .line 1133
    .local v1, "fileEntry":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
    iget-object v5, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mExtendName:Ljava/lang/String;

    const-string v6, ".jar"

    invoke-virtual {v5, v6}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_0

    iget-object v5, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mExtendName:Ljava/lang/String;

    const-string v6, ".dm"

    invoke-virtual {v5, v6}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_0

    iget-object v5, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mExtendName:Ljava/lang/String;

    const-string v6, ".dcf"

    invoke-virtual {v5, v6}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v5

    if-eqz v5, :cond_2

    .line 1136
    :cond_0
    sget-object v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    .local v3, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_2

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;

    .line 1137
    .local v0, "e":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
    iget-object v5, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mPath:Ljava/lang/String;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v7, v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mRawName:Ljava/lang/String;

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, ".jad"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_1

    .line 1138
    sget-object v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v5, v1}, Ljava/util/List;->remove(Ljava/lang/Object;)Z

    .line 1131
    .end local v0    # "e":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
    .end local v3    # "i$":Ljava/util/Iterator;
    :cond_2
    add-int/lit8 v2, v2, -0x1

    goto :goto_0

    .line 1144
    .end local v1    # "fileEntry":Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
    :cond_3
    return-void
.end method

.method private findAllMidlets(Ljava/io/File;)V
    .locals 5
    .param p1, "root"    # Ljava/io/File;

    .prologue
    .line 1055
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->excludeFolders:[Ljava/lang/String;

    const/4 v3, 0x0

    aget-object v2, v2, v3

    const-string v3, ""

    if-eq v2, v3, :cond_2

    .line 1056
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->excludeFolders:[Ljava/lang/String;

    array-length v2, v2

    if-ge v1, v2, :cond_2

    .line 1057
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->excludeFolders:[Ljava/lang/String;

    aget-object v2, v2, v1

    invoke-virtual {p1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 1085
    .end local v1    # "i":I
    :cond_0
    return-void

    .line 1056
    .restart local v1    # "i":I
    :cond_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 1063
    .end local v1    # "i":I
    :cond_2
    new-instance v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$6;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$6;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V

    invoke-virtual {p1, v2}, Ljava/io/File;->listFiles(Ljava/io/FileFilter;)[Ljava/io/File;

    move-result-object v0

    .line 1080
    .local v0, "files":[Ljava/io/File;
    if-eqz v0, :cond_0

    .line 1081
    const/4 v1, 0x0

    .restart local v1    # "i":I
    :goto_1
    array-length v2, v0

    if-ge v1, v2, :cond_0

    .line 1082
    const-string v2, "AmsEventHandler"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Add a midlet file "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    aget-object v4, v0, v1

    invoke-virtual {v4}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1083
    sget-object v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;

    aget-object v4, v0, v1

    invoke-direct {v3, v4}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;-><init>(Ljava/io/File;)V

    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1081
    add-int/lit8 v1, v1, 0x1

    goto :goto_1
.end method

.method private showSubDialog(Ljava/lang/String;Landroid/app/AlertDialog;)V
    .locals 6
    .param p1, "fileUri"    # Ljava/lang/String;
    .param p2, "dialog"    # Landroid/app/AlertDialog;

    .prologue
    .line 946
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mContext:Landroid/content/Context;

    const v5, 0x7f05004f

    invoke-virtual {v4, v5}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 947
    .local v0, "s1":Ljava/lang/String;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mContext:Landroid/content/Context;

    const v5, 0x7f05012c

    invoke-virtual {v4, v5}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    .line 948
    .local v1, "s2":Ljava/lang/String;
    const/4 v4, 0x2

    new-array v2, v4, [Ljava/lang/String;

    const/4 v4, 0x0

    aput-object v0, v2, v4

    const/4 v4, 0x1

    aput-object v1, v2, v4

    .line 949
    .local v2, "ss":[Ljava/lang/String;
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    new-instance v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$1;

    invoke-direct {v5, p0, p1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Ljava/lang/String;)V

    invoke-virtual {v4, v2, v5}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v3

    .line 993
    .local v3, "subDialog":Landroid/app/AlertDialog;
    new-instance v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$2;

    invoke-direct {v4, p0, p2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Landroid/app/AlertDialog;)V

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)V

    .line 999
    invoke-virtual {v3}, Landroid/app/AlertDialog;->show()V

    .line 1000
    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 1004
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mIsOnlySdcard:Z

    .line 1006
    sget-boolean v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mThreadIsRunning:Z

    if-eqz v1, :cond_1

    .line 1052
    :cond_0
    :goto_0
    return-void

    .line 1008
    :cond_1
    sget-boolean v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mFileCollected:Z

    if-nez v1, :cond_2

    .line 1009
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271c

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->processMessageImmediately(Landroid/os/Message;)V

    .line 1010
    sget-object v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 1011
    new-instance v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$3;->start()V

    goto :goto_0

    .line 1022
    :cond_2
    const/4 v1, 0x0

    sput-boolean v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mFileCollected:Z

    .line 1023
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mHandler:Landroid/os/Handler;

    const/16 v2, 0x271d

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->processMessageImmediately(Landroid/os/Message;)V

    .line 1024
    sget-object v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_3

    .line 1025
    const v1, 0x7f050156

    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->showInfo(I)V

    goto :goto_0

    .line 1028
    :cond_3
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v2, 0x7f05006a

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    sget-object v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    sget-object v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mLocalInsallFiles:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v3

    new-array v3, v3, [Ljava/lang/CharSequence;

    invoke-interface {v1, v3}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/CharSequence;

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$4;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;)V

    invoke-virtual {v2, v1, v3}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v0

    .line 1038
    .local v0, "dialog":Landroid/app/AlertDialog;
    invoke-virtual {v0}, Landroid/app/AlertDialog;->show()V

    .line 1039
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;->mIsOnlySdcard:Z

    if-eqz v1, :cond_0

    .line 1041
    invoke-virtual {v0}, Landroid/app/AlertDialog;->getListView()Landroid/widget/ListView;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$5;

    invoke-direct {v2, p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$5;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;Landroid/app/AlertDialog;)V

    invoke-virtual {v1, v2}, Landroid/widget/ListView;->setOnItemLongClickListener(Landroid/widget/AdapterView$OnItemLongClickListener;)V

    goto :goto_0
.end method
