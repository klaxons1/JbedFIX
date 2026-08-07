.class public Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;
.super Ljava/lang/Object;
.source "AmsInstallerProxy.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# static fields
.field private static FILENAME_COLUMN_NAME:Ljava/lang/String; = null

.field public static final JAD_MIMIE_TYPE:Ljava/lang/String; = "text/vnd.sun.j2me.app-descriptor"

.field public static final JAR_MIMIE_TYPE:Ljava/lang/String; = "application/java-archive"

.field private static final TAG:Ljava/lang/String; = "AmsDownloads"


# instance fields
.field private final DRM_DATA:Ljava/lang/String;

.field private final DRM_ID:Ljava/lang/String;

.field private final MIDLET_PROJECTION:[Ljava/lang/String;

.field private mClient:Lcom/esmertec/android/jbed/ams/AmsClient;

.field private mContext:Landroid/content/Context;

.field private mLocalJadUri:Landroid/net/Uri;

.field private mLocalUri:Landroid/net/Uri;

.field private mMimeType:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 89
    const-string v0, "_data"

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->FILENAME_COLUMN_NAME:Ljava/lang/String;

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/net/Uri;Ljava/lang/String;)V
    .locals 5
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "client"    # Lcom/esmertec/android/jbed/ams/AmsClient;
    .param p3, "localUri"    # Landroid/net/Uri;
    .param p4, "mimeType"    # Ljava/lang/String;

    .prologue
    const-string v4, "_id"

    const-string v3, "_data"

    .line 69
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 61
    const-string v0, "_id"

    iput-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->DRM_ID:Ljava/lang/String;

    .line 62
    const-string v0, "_data"

    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->DRM_DATA:Ljava/lang/String;

    .line 64
    const/4 v0, 0x2

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "_id"

    aput-object v4, v0, v1

    const/4 v1, 0x1

    const-string v2, "_data"

    aput-object v3, v0, v1

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->MIDLET_PROJECTION:[Ljava/lang/String;

    .line 70
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mContext:Landroid/content/Context;

    .line 71
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mClient:Lcom/esmertec/android/jbed/ams/AmsClient;

    .line 72
    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalUri:Landroid/net/Uri;

    .line 73
    iput-object p4, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    .line 74
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    .line 75
    const-string v0, "AmsDownloads"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AmsInstallerProxy()1 mMimeType = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ",mLocalUri.getPath() = "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalUri:Landroid/net/Uri;

    invoke-virtual {v2}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 76
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/net/Uri;Ljava/lang/String;Landroid/net/Uri;)V
    .locals 5
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "client"    # Lcom/esmertec/android/jbed/ams/AmsClient;
    .param p3, "localUri"    # Landroid/net/Uri;
    .param p4, "mimeType"    # Ljava/lang/String;
    .param p5, "localJadUri"    # Landroid/net/Uri;

    .prologue
    const-string v4, "_id"

    const-string v3, "_data"

    .line 78
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 61
    const-string v0, "_id"

    iput-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->DRM_ID:Ljava/lang/String;

    .line 62
    const-string v0, "_data"

    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->DRM_DATA:Ljava/lang/String;

    .line 64
    const/4 v0, 0x2

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "_id"

    aput-object v4, v0, v1

    const/4 v1, 0x1

    const-string v2, "_data"

    aput-object v3, v0, v1

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->MIDLET_PROJECTION:[Ljava/lang/String;

    .line 79
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mContext:Landroid/content/Context;

    .line 80
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mClient:Lcom/esmertec/android/jbed/ams/AmsClient;

    .line 81
    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalUri:Landroid/net/Uri;

    .line 82
    iput-object p4, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    .line 83
    iput-object p5, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    .line 85
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "//@"

    const-string v2, "//"

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->replaceFirst(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    .line 86
    return-void
.end method

.method private convertIntoJbedInstallPath(Ljava/lang/String;)Ljava/lang/String;
    .locals 7
    .param p1, "url"    # Ljava/lang/String;

    .prologue
    const/16 v5, 0x8

    const-string v6, "/"

    .line 168
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v0

    .line 169
    .local v0, "lowerCasePath":Ljava/lang/String;
    const-string v2, "file:////"

    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_0

    .line 171
    const-string v2, "file:///"

    invoke-virtual {v0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 173
    invoke-virtual {p1, v5}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v1

    .line 174
    .local v1, "subStr":Ljava/lang/String;
    const-string v2, "/"

    invoke-virtual {v1, v6}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_0

    .line 176
    new-instance v2, Ljava/lang/String;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v4, 0x0

    invoke-virtual {p1, v4, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, "/"

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 181
    .end local v1    # "subStr":Ljava/lang/String;
    :goto_0
    return-object v2

    :cond_0
    move-object v2, p1

    goto :goto_0
.end method

.method private getSourceJadUri(Landroid/net/Uri;)Landroid/net/Uri;
    .locals 9
    .param p1, "jadLocalUri"    # Landroid/net/Uri;

    .prologue
    const/4 v2, 0x0

    const-string v4, "AmsDownloads"

    .line 95
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "("

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->FILENAME_COLUMN_NAME:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "=? AND "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "status"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "=?)"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 96
    .local v3, "where":Ljava/lang/String;
    const-string v0, "AmsDownloads"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "getSourceJadUri() where = "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v4, v0}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 98
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    sget-object v1, Landroid/provider/Downloads;->CONTENT_URI:Landroid/net/Uri;

    const/4 v4, 0x2

    new-array v4, v4, [Ljava/lang/String;

    const/4 v5, 0x0

    invoke-virtual {p1}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v8

    aput-object v8, v4, v5

    const/4 v5, 0x1

    const/16 v8, 0xc8

    invoke-static {v8}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;

    move-result-object v8

    aput-object v8, v4, v5

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 101
    .local v6, "c":Landroid/database/Cursor;
    if-eqz v6, :cond_1

    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 102
    const-string v0, "uri"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v7

    .line 103
    .local v7, "uri":Ljava/lang/String;
    invoke-static {v7}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v0

    .line 108
    if-eqz v6, :cond_0

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 110
    .end local v7    # "uri":Ljava/lang/String;
    :cond_0
    :goto_0
    return-object v0

    .line 105
    :cond_1
    :try_start_1
    const-string v0, "AmsDownloads"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "ERROR: getSourceJadUri() failed to query download.uri. where= "

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 108
    if-eqz v6, :cond_2

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_2
    move-object v0, v2

    .line 110
    goto :goto_0

    .line 108
    :catchall_0
    move-exception v0

    if-eqz v6, :cond_3

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_3
    throw v0
.end method


# virtual methods
.method public copyFileTo(Ljava/lang/String;Ljava/lang/String;)Landroid/net/Uri;
    .locals 5
    .param p1, "srcFullName"    # Ljava/lang/String;
    .param p2, "fileName"    # Ljava/lang/String;

    .prologue
    .line 226
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "java.io.tmpdir"

    const-string v4, "/data/data/com.esmertec.android.jbed/"

    invoke-static {v3, v4}, Ljava/lang/System;->getProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "/"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 227
    .local v1, "destFullName":Ljava/lang/String;
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 228
    .local v0, "destFile":Ljava/io/File;
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-static {v2, v0}, Landroid/os/FileUtils;->copyFile(Ljava/io/File;Ljava/io/File;)Z

    .line 229
    invoke-static {v0}, Landroid/net/Uri;->fromFile(Ljava/io/File;)Landroid/net/Uri;

    move-result-object v2

    return-object v2
.end method

.method fixRelativeJarUrl(Ljava/lang/String;Landroid/net/Uri;)[B
    .locals 3
    .param p1, "jadUrl"    # Ljava/lang/String;
    .param p2, "jadLocalUri"    # Landroid/net/Uri;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    .line 160
    new-instance v0, Ljava/io/FileInputStream;

    new-instance v1, Ljava/io/File;

    invoke-virtual {p2}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-direct {v0, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {p0, p1, v0}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->fixRelativeJarUrl(Ljava/lang/String;Ljava/io/InputStream;)[B

    move-result-object v0

    return-object v0
.end method

.method fixRelativeJarUrl(Ljava/lang/String;Ljava/io/InputStream;)[B
    .locals 9
    .param p1, "jadUrl"    # Ljava/lang/String;
    .param p2, "jadStream"    # Ljava/io/InputStream;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    const-string v8, "utf-8"

    .line 133
    new-instance v4, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v4}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 134
    .local v4, "result":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/BufferedReader;

    new-instance v6, Ljava/io/InputStreamReader;

    const-string v7, "utf-8"

    invoke-direct {v6, p2, v8}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    invoke-direct {v3, v6}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 135
    .local v3, "reader":Ljava/io/BufferedReader;
    new-instance v5, Ljava/io/BufferedWriter;

    new-instance v6, Ljava/io/OutputStreamWriter;

    const-string v7, "utf-8"

    invoke-direct {v6, v4, v8}, Ljava/io/OutputStreamWriter;-><init>(Ljava/io/OutputStream;Ljava/lang/String;)V

    invoke-direct {v5, v6}, Ljava/io/BufferedWriter;-><init>(Ljava/io/Writer;)V

    .line 138
    .local v5, "writer":Ljava/io/BufferedWriter;
    :goto_0
    :try_start_0
    invoke-virtual {v3}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object v2

    .local v2, "line":Ljava/lang/String;
    if-eqz v2, :cond_1

    .line 140
    const-string v6, "MIDlet-Jar-URL"

    invoke-virtual {v2, v6}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v6

    if-eqz v6, :cond_0

    .line 141
    const/16 v6, 0x3a

    invoke-virtual {v2, v6}, Ljava/lang/String;->indexOf(I)I

    move-result v0

    .line 142
    .local v0, "delimiter":I
    const/4 v6, -0x1

    if-eq v0, v6, :cond_0

    .line 143
    add-int/lit8 v6, v0, 0x1

    invoke-virtual {v2, v6}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v1

    .line 144
    .local v1, "jarUrl":Ljava/lang/String;
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v6

    if-eqz v6, :cond_0

    .line 145
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "MIDlet-Jar-URL: "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {p0, p1, v1}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->getAbsoluteJarUrl(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    .line 149
    .end local v0    # "delimiter":I
    .end local v1    # "jarUrl":Ljava/lang/String;
    :cond_0
    invoke-virtual {v5, v2}, Ljava/io/BufferedWriter;->write(Ljava/lang/String;)V

    .line 150
    const/16 v6, 0xa

    invoke-virtual {v5, v6}, Ljava/io/BufferedWriter;->write(I)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 153
    .end local v2    # "line":Ljava/lang/String;
    :catchall_0
    move-exception v6

    invoke-virtual {v3}, Ljava/io/BufferedReader;->close()V

    .line 154
    invoke-virtual {v5}, Ljava/io/BufferedWriter;->close()V

    throw v6

    .line 153
    .restart local v2    # "line":Ljava/lang/String;
    :cond_1
    invoke-virtual {v3}, Ljava/io/BufferedReader;->close()V

    .line 154
    invoke-virtual {v5}, Ljava/io/BufferedWriter;->close()V

    .line 156
    invoke-virtual {v4}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v6

    return-object v6
.end method

.method getAbsoluteJarUrl(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .locals 6
    .param p1, "jadUrl"    # Ljava/lang/String;
    .param p2, "jarUrl"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    .line 117
    const-string v3, "AmsDownloads"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "getAbsoluteJarUrl() jadUrl = "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "   jarUrl = "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 118
    invoke-static {p2}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 119
    .local v0, "jarUri":Landroid/net/Uri;
    invoke-virtual {v0}, Landroid/net/Uri;->isRelative()Z

    move-result v3

    if-eqz v3, :cond_0

    .line 120
    const-string v3, "/"

    invoke-virtual {p1, v3}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I

    move-result v1

    .line 121
    .local v1, "lastSlashPos":I
    const/4 v3, -0x1

    if-eq v1, v3, :cond_0

    .line 122
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v4, 0x0

    add-int/lit8 v5, v1, 0x1

    invoke-virtual {p1, v4, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Ljava/net/URI;->create(Ljava/lang/String;)Ljava/net/URI;

    move-result-object v3

    invoke-virtual {v3}, Ljava/net/URI;->normalize()Ljava/net/URI;

    move-result-object v2

    .line 123
    .local v2, "uri":Ljava/net/URI;
    invoke-virtual {v2}, Ljava/net/URI;->toString()Ljava/lang/String;

    move-result-object v3

    .line 126
    .end local v1    # "lastSlashPos":I
    .end local v2    # "uri":Ljava/net/URI;
    :goto_0
    return-object v3

    :cond_0
    move-object v3, p2

    goto :goto_0
.end method

.method public requestInstall()V
    .locals 11

    .prologue
    const/4 v9, 0x1

    const-string v10, "AmsDownloads"

    .line 188
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalUri:Landroid/net/Uri;

    .line 190
    .local v1, "destInstallUri":Landroid/net/Uri;
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    const-string v2, "text/vnd.sun.j2me.app-descriptor"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 192
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    if-eqz v0, :cond_0

    .line 193
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mLocalJadUri:Landroid/net/Uri;

    .line 213
    :cond_0
    :goto_0
    const-string v0, "AmsDownloads"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "requestInstall  "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " mMimeType="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 214
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mClient:Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, v2}, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->convertIntoJbedInstallPath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallEvent(Ljava/lang/String;)V

    .line 220
    :goto_1
    return-void

    .line 195
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mMimeType:Ljava/lang/String;

    const-string v2, "application/java-archive"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 196
    invoke-virtual {v1}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    const-string v2, "content"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 197
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->MIDLET_PROJECTION:[Ljava/lang/String;

    const/4 v3, 0x0

    const/4 v4, 0x0

    const-string v5, "_id"

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v6

    .line 199
    .local v6, "c":Landroid/database/Cursor;
    if-eqz v6, :cond_2

    :try_start_1
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 200
    const/4 v0, 0x1

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v8

    .line 201
    .local v8, "uriString":Ljava/lang/String;
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "file:///"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    .line 202
    invoke-static {v8}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    move-result-object v1

    .line 207
    .end local v8    # "uriString":Ljava/lang/String;
    :goto_2
    if-eqz v6, :cond_0

    :try_start_2
    invoke-interface {v6}, Landroid/database/Cursor;->close()V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    goto/16 :goto_0

    .line 215
    .end local v6    # "c":Landroid/database/Cursor;
    :catch_0
    move-exception v0

    move-object v7, v0

    .line 216
    .local v7, "e":Ljava/lang/Exception;
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mClient:Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsInstallerProxy;->mContext:Landroid/content/Context;

    const v3, 0x7f05008f

    new-array v4, v9, [Ljava/lang/Object;

    const/4 v5, 0x0

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v9

    aput-object v9, v4, v5

    invoke-virtual {v2, v3, v4}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestShowError(Ljava/lang/String;)V

    .line 218
    const-string v0, "AmsDownloads"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " faile to install "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v10, v0, v7}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto/16 :goto_1

    .line 204
    .end local v7    # "e":Ljava/lang/Exception;
    .restart local v6    # "c":Landroid/database/Cursor;
    :cond_2
    :try_start_3
    const-string v0, "AmsDownloads"

    const-string v2, "ERROR: requestInstall() failed to query drm uri"

    invoke-static {v0, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    goto :goto_2

    .line 207
    :catchall_0
    move-exception v0

    if-eqz v6, :cond_3

    :try_start_4
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_3
    throw v0
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0
.end method
