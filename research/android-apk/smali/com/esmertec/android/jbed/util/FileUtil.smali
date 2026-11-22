.class public Lcom/esmertec/android/jbed/util/FileUtil;
.super Ljava/lang/Object;
.source "FileUtil.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;
    }
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 10
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 12
    return-void
.end method

.method public static cleanFiles(Ljava/lang/String;Ljava/io/FilenameFilter;)V
    .locals 4
    .param p0, "dirName"    # Ljava/lang/String;
    .param p1, "filenameFilter"    # Ljava/io/FilenameFilter;

    .prologue
    .line 27
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 28
    .local v0, "dir":Ljava/io/File;
    invoke-virtual {v0, p1}, Ljava/io/File;->listFiles(Ljava/io/FilenameFilter;)[Ljava/io/File;

    move-result-object v1

    .line 29
    .local v1, "files":[Ljava/io/File;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    if-eqz v1, :cond_0

    array-length v3, v1

    if-ge v2, v3, :cond_0

    .line 30
    aget-object v3, v1, v2

    invoke-virtual {v3}, Ljava/io/File;->delete()Z

    .line 29
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 32
    :cond_0
    return-void
.end method

.method public static cleanFiles(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "dirName"    # Ljava/lang/String;
    .param p1, "fileNamePrefex"    # Ljava/lang/String;

    .prologue
    .line 36
    new-instance v0, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;

    invoke-direct {v0, p1}, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;-><init>(Ljava/lang/String;)V

    invoke-static {p0, v0}, Lcom/esmertec/android/jbed/util/FileUtil;->cleanFiles(Ljava/lang/String;Ljava/io/FilenameFilter;)V

    .line 37
    return-void
.end method

.method public static getDirFileNum(Ljava/lang/String;Ljava/io/FilenameFilter;)I
    .locals 3
    .param p0, "dirName"    # Ljava/lang/String;
    .param p1, "filenameFilter"    # Ljava/io/FilenameFilter;

    .prologue
    .line 41
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 42
    .local v0, "dir":Ljava/io/File;
    invoke-virtual {v0, p1}, Ljava/io/File;->listFiles(Ljava/io/FilenameFilter;)[Ljava/io/File;

    move-result-object v1

    .line 43
    .local v1, "files":[Ljava/io/File;
    if-eqz v1, :cond_0

    array-length v2, v1

    :goto_0
    return v2

    :cond_0
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public static getDirFileNum(Ljava/lang/String;Ljava/lang/String;)I
    .locals 1
    .param p0, "dirName"    # Ljava/lang/String;
    .param p1, "fileNamePrefex"    # Ljava/lang/String;

    .prologue
    .line 48
    new-instance v0, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;

    invoke-direct {v0, p1}, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;-><init>(Ljava/lang/String;)V

    invoke-static {p0, v0}, Lcom/esmertec/android/jbed/util/FileUtil;->getDirFileNum(Ljava/lang/String;Ljava/io/FilenameFilter;)I

    move-result v0

    return v0
.end method

.method public static getFilesSizeWithPrefix(Ljava/lang/String;Ljava/lang/String;)I
    .locals 8
    .param p0, "dirName"    # Ljava/lang/String;
    .param p1, "fileNamePrefex"    # Ljava/lang/String;

    .prologue
    .line 52
    const/4 v3, 0x0

    .line 53
    .local v3, "result":I
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 54
    .local v0, "dir":Ljava/io/File;
    new-instance v4, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;

    invoke-direct {v4, p1}, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v4}, Ljava/io/File;->listFiles(Ljava/io/FilenameFilter;)[Ljava/io/File;

    move-result-object v1

    .line 55
    .local v1, "files":[Ljava/io/File;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    if-eqz v1, :cond_0

    array-length v4, v1

    if-ge v2, v4, :cond_0

    .line 56
    int-to-long v4, v3

    aget-object v6, v1, v2

    invoke-virtual {v6}, Ljava/io/File;->length()J

    move-result-wide v6

    add-long/2addr v4, v6

    long-to-int v3, v4

    .line 55
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 58
    :cond_0
    return v3
.end method
