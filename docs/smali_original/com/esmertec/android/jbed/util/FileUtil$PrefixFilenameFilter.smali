.class public Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;
.super Ljava/lang/Object;
.source "FileUtil.java"

# interfaces
.implements Ljava/io/FilenameFilter;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/util/FileUtil;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "PrefixFilenameFilter"
.end annotation


# instance fields
.field private mPrefix:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;)V
    .locals 0
    .param p1, "prefix"    # Ljava/lang/String;

    .prologue
    .line 16
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 17
    iput-object p1, p0, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;->mPrefix:Ljava/lang/String;

    .line 18
    return-void
.end method


# virtual methods
.method public accept(Ljava/io/File;Ljava/lang/String;)Z
    .locals 1
    .param p1, "f"    # Ljava/io/File;
    .param p2, "fileName"    # Ljava/lang/String;

    .prologue
    .line 21
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/FileUtil$PrefixFilenameFilter;->mPrefix:Ljava/lang/String;

    invoke-virtual {p2, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method
