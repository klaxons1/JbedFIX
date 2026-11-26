.class public Lcom/esmertec/android/jbed/jsr/JbedFileManager;
.super Ljava/lang/Object;
.source "JbedFileManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;
    }
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z

.field public static final EXTERNAL_STORAGE_NAME:Ljava/lang/String;

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedFileManager; = null

.field public static final ROOT_STORAGE_DIR:Ljava/lang/String; = "data"

.field public static final SDCARD_FOLDER_NAME:Ljava/lang/String; = "sdcard"

.field public static final SDCARD_FOLDER_PATH:Ljava/lang/String; = "/mnt/sdcard"

.field private static final TAG:Ljava/lang/String; = "JbedFileManager"

.field public static final rootNames:[Ljava/lang/String;

.field public static final rootPaths:[Ljava/lang/String;


# instance fields
.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field mListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;",
            ">;"
        }
    .end annotation
.end field

.field private rootChangeReceiver:Landroid/content/BroadcastReceiver;


# direct methods
.method static constructor <clinit>()V
    .locals 4

    .prologue
    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 30
    const-class v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    move v0, v3

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->$assertionsDisabled:Z

    .line 45
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "sdcard"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v1, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    .line 77
    new-array v0, v3, [Ljava/lang/String;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    aput-object v1, v0, v2

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    .line 81
    new-array v0, v3, [Ljava/lang/String;

    const-string v1, "/mnt/sdcard"

    aput-object v1, v0, v2

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootPaths:[Ljava/lang/String;

    return-void

    :cond_0
    move v0, v2

    .line 30
    goto :goto_0
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/os/Handler;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "handler"    # Landroid/os/Handler;

    .prologue
    .line 141
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 92
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mListeners:Ljava/util/List;

    .line 98
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootChangeReceiver:Landroid/content/BroadcastReceiver;

    .line 142
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mContext:Landroid/content/Context;

    .line 143
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mHandler:Landroid/os/Handler;

    .line 144
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    .line 145
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 1
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 138
    const/4 v0, 0x0

    invoke-direct {p0, v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;-><init>(Landroid/content/Context;Landroid/os/Handler;)V

    .line 139
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    .prologue
    .line 30
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    .prologue
    .line 30
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$200(Ljava/lang/String;Ljava/lang/String;Z)V
    .locals 0
    .param p0, "x0"    # Ljava/lang/String;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # Z

    .prologue
    .line 30
    invoke-static {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->nativeNotifyRootChanged(Ljava/lang/String;Ljava/lang/String;Z)V

    return-void
.end method

.method static convertFilePath(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "path"    # Ljava/lang/String;

    .prologue
    .line 189
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->$assertionsDisabled:Z

    if-nez v0, :cond_0

    if-nez p0, :cond_0

    new-instance v0, Ljava/lang/AssertionError;

    invoke-direct {v0}, Ljava/lang/AssertionError;-><init>()V

    throw v0

    .line 190
    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    const/4 v1, 0x1

    sub-int/2addr v0, v1

    invoke-virtual {p0, v0}, Ljava/lang/String;->charAt(I)C

    move-result v0

    sget-char v1, Ljava/io/File;->separatorChar:C

    if-eq v0, v1, :cond_1

    .line 191
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-char v1, Ljava/io/File;->separatorChar:C

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    .line 192
    :cond_1
    return-object p0
.end method

.method private static getRootCount()I
    .locals 2

    .prologue
    .line 182
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v0

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    array-length v0, v0

    :goto_0
    return v0

    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    array-length v0, v0

    const/4 v1, 0x1

    sub-int/2addr v0, v1

    goto :goto_0
.end method

.method static getRootNames()[B
    .locals 6

    .prologue
    .line 196
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 197
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 199
    .local v3, "out":Ljava/io/DataOutputStream;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    :try_start_0
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    array-length v4, v4

    if-ge v2, v4, :cond_1

    .line 201
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    aget-object v4, v4, v2

    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_0

    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v4

    if-nez v4, :cond_0

    .line 199
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 204
    :cond_0
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootNames:[Ljava/lang/String;

    aget-object v4, v4, v2

    invoke-static {v4}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->convertFilePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    const-string v5, "utf-8"

    invoke-virtual {v4, v5}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->write([B)V

    .line 205
    const/4 v4, 0x0

    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->writeByte(I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 207
    :catch_0
    move-exception v4

    move-object v1, v4

    .line 208
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Ljava/lang/IllegalArgumentException;

    const-string v5, "incrroect root name definition"

    invoke-direct {v4, v5}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v4

    .line 210
    .end local v1    # "e":Ljava/lang/Exception;
    :cond_1
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v4

    return-object v4
.end method

.method static getRootPaths()[B
    .locals 8

    .prologue
    .line 214
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 215
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 217
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->getRootPathList()Ljava/util/List;

    move-result-object v5

    .line 218
    .local v5, "roots":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    invoke-interface {v5}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    .local v2, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_0

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 219
    .local v4, "path":Ljava/lang/String;
    invoke-static {v4}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->convertFilePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    const-string v7, "utf-8"

    invoke-virtual {v6, v7}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v6

    invoke-virtual {v3, v6}, Ljava/io/DataOutputStream;->write([B)V

    .line 220
    const/4 v6, 0x0

    invoke-virtual {v3, v6}, Ljava/io/DataOutputStream;->writeByte(I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 222
    .end local v2    # "i$":Ljava/util/Iterator;
    .end local v4    # "path":Ljava/lang/String;
    .end local v5    # "roots":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    :catch_0
    move-exception v6

    move-object v1, v6

    .line 223
    .local v1, "e":Ljava/lang/Exception;
    new-instance v6, Ljava/lang/IllegalArgumentException;

    const-string v7, "incrroect root name definition"

    invoke-direct {v6, v7}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v6

    .line 225
    .end local v1    # "e":Ljava/lang/Exception;
    .restart local v2    # "i$":Ljava/util/Iterator;
    .restart local v5    # "roots":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    :cond_0
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v6

    return-object v6
.end method

.method static getRoots()[B
    .locals 7

    .prologue
    .line 249
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 250
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 253
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->getRootCount()I

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 254
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->getRootNames()[B

    move-result-object v2

    .line 256
    .local v2, "names":[B
    array-length v5, v2

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeShort(I)V

    .line 257
    invoke-virtual {v3, v2}, Ljava/io/DataOutputStream;->write([B)V

    .line 259
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->getRootPaths()[B

    move-result-object v4

    .line 260
    .local v4, "paths":[B
    array-length v5, v4

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeShort(I)V

    .line 261
    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->write([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 267
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v5

    return-object v5

    .line 262
    .end local v2    # "names":[B
    .end local v4    # "paths":[B
    :catch_0
    move-exception v5

    move-object v1, v5

    .line 263
    .local v1, "e":Ljava/io/IOException;
    const-string v5, "JbedFileManager"

    const-string v6, " failed to get the roots"

    invoke-static {v5, v6}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 264
    invoke-virtual {v1}, Ljava/io/IOException;->printStackTrace()V

    .line 265
    new-instance v5, Ljava/lang/IllegalArgumentException;

    const-string v6, "failed to get the roots."

    invoke-direct {v5, v6}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v5
.end method

.method public static isExternalStorageReady()Z
    .locals 2

    .prologue
    .line 175
    invoke-static {}, Landroid/os/Environment;->getExternalStorageState()Ljava/lang/String;

    move-result-object v0

    .line 176
    .local v0, "state":Ljava/lang/String;
    const-string v1, "mounted"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    const-string v1, "mounted_ro"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    :cond_0
    const/4 v1, 0x1

    :goto_0
    return v1

    :cond_1
    const/4 v1, 0x0

    goto :goto_0
.end method

.method private static native nativeNotifyRootChanged(Ljava/lang/String;Ljava/lang/String;Z)V
.end method


# virtual methods
.method public getRootPathList()Ljava/util/List;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    .line 229
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 230
    .local v4, "result":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootPaths:[Ljava/lang/String;

    .local v0, "arr$":[Ljava/lang/String;
    array-length v2, v0

    .local v2, "len$":I
    const/4 v1, 0x0

    .local v1, "i$":I
    :goto_0
    if-ge v1, v2, :cond_2

    aget-object v3, v0, v1

    .line 231
    .local v3, "path":Ljava/lang/String;
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v3, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_1

    .line 232
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->isExternalStorageReady()Z

    move-result v5

    if-eqz v5, :cond_0

    .line 233
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v5

    invoke-virtual {v5}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v5

    invoke-interface {v4, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 230
    :cond_0
    :goto_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 235
    :cond_1
    invoke-interface {v4, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_1

    .line 238
    .end local v3    # "path":Ljava/lang/String;
    :cond_2
    return-object v4
.end method

.method public onCreate(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 149
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mContext:Landroid/content/Context;

    .line 150
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 151
    .local v0, "externalStorageFilter":Landroid/content/IntentFilter;
    const-string v1, "android.intent.action.MEDIA_MOUNTED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 152
    const-string v1, "android.intent.action.MEDIA_UNMOUNTED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 153
    const-string v1, "android.intent.action.MEDIA_REMOVED"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 154
    const-string v1, "android.intent.action.MEDIA_BAD_REMOVAL"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 155
    const-string v1, "android.intent.action.MEDIA_EJECT"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 156
    const-string v1, "file"

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addDataScheme(Ljava/lang/String;)V

    .line 157
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootChangeReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v1, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 159
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mListeners:Ljava/util/List;

    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedFileManager$2;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/jsr/JbedFileManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)V

    invoke-interface {v1, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 166
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 169
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->rootChangeReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 170
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mListeners:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 171
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    .line 172
    return-void
.end method
