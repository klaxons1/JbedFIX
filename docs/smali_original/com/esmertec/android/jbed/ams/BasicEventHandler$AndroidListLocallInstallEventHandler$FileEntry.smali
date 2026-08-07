.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;
.super Ljava/lang/Object;
.source "BasicEventHandler.java"

# interfaces
.implements Ljava/lang/CharSequence;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "FileEntry"
.end annotation


# static fields
.field private static FILE_COMPARATOR:Ljava/util/Comparator;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field mExtendName:Ljava/lang/String;

.field mName:Ljava/lang/String;

.field mPath:Ljava/lang/String;

.field mRawName:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 1099
    new-instance v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry$1;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry$1;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->FILE_COMPARATOR:Ljava/util/Comparator;

    return-void
.end method

.method constructor <init>(Ljava/io/File;)V
    .locals 4
    .param p1, "file"    # Ljava/io/File;

    .prologue
    const/16 v3, 0x2e

    .line 1092
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 1093
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    .line 1094
    invoke-virtual {p1}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mPath:Ljava/lang/String;

    .line 1095
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    invoke-virtual {v1, v3}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mExtendName:Ljava/lang/String;

    .line 1096
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mPath:Ljava/lang/String;

    const/4 v1, 0x0

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mPath:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mRawName:Ljava/lang/String;

    .line 1097
    return-void
.end method

.method static synthetic access$500()Ljava/util/Comparator;
    .locals 1

    .prologue
    .line 1087
    sget-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->FILE_COMPARATOR:Ljava/util/Comparator;

    return-object v0
.end method


# virtual methods
.method public charAt(I)C
    .locals 1
    .param p1, "index"    # I

    .prologue
    .line 1107
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    invoke-virtual {v0, p1}, Ljava/lang/String;->charAt(I)C

    move-result v0

    return v0
.end method

.method public length()I
    .locals 1

    .prologue
    .line 1111
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    return v0
.end method

.method public subSequence(II)Ljava/lang/CharSequence;
    .locals 1
    .param p1, "start"    # I
    .param p2, "end"    # I

    .prologue
    .line 1115
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    invoke-virtual {v0, p1, p2}, Ljava/lang/String;->subSequence(II)Ljava/lang/CharSequence;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    .prologue
    .line 1120
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    const/4 v1, 0x0

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler$FileEntry;->mName:Ljava/lang/String;

    const/16 v3, 0x2e

    invoke-virtual {v2, v3}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v2

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
