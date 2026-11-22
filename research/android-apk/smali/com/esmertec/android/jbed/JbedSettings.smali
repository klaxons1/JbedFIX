.class public Lcom/esmertec/android/jbed/JbedSettings;
.super Ljava/lang/Object;
.source "JbedSettings.java"


# static fields
.field public static final ANDROID_TRUSTSTORE_FILE_SIZE:Ljava/lang/String; = "jbed.android.cert.size"

.field static final CERT_FILE_PREFIX:Ljava/lang/String; = "android"

.field private static INSTANCE:Lcom/esmertec/android/jbed/JbedSettings; = null

.field public static final IS_ALLOWED_HIDDEN_MENU_PROPERTY:Ljava/lang/String; = "is_allowed_hidden_menu"

.field public static final IS_RUNTCK_PROPERTY:Ljava/lang/String; = "is_runtck"

.field public static final SETTINGS_NAME:Ljava/lang/String; = "settings"

.field private static final TAG:Ljava/lang/String; = "JbedSettings"

.field public static final TCK_URL_PROPERTY:Ljava/lang/String; = "tck_url"


# instance fields
.field private mBaseDir:Ljava/lang/String;

.field private mCertsRootDir:Ljava/lang/String;

.field private mContext:Landroid/content/Context;

.field private mExtraCommandLine:Ljava/lang/String;

.field private mIsAMSListLaunch:Z

.field private mIsAllowedHiddenMenu:Z

.field private mIsNativeAms:Z

.field private mIsRunTck:Z

.field private mLocalinstallDir:Ljava/lang/String;

.field private mRootDir:Ljava/lang/String;

.field mSyncCertsDate:J

.field mSyncCertsSize:J

.field private mTckUrl:Ljava/lang/String;


# direct methods
.method private constructor <init>(Landroid/content/Context;Z)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "isSyncCert"    # Z

    .prologue
    const/4 v0, 0x0

    .line 88
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 54
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsNativeAms:Z

    .line 56
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsRunTck:Z

    .line 60
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAllowedHiddenMenu:Z

    .line 62
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAMSListLaunch:Z

    .line 89
    iput-object p1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    .line 90
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedSettings;->loadSettinData()V

    .line 91
    if-eqz p2, :cond_0

    .line 98
    new-instance v0, Lcom/esmertec/android/jbed/JbedSettings$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/JbedSettings$1;-><init>(Lcom/esmertec/android/jbed/JbedSettings;)V

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/JbedSettings$1;->start()V

    .line 104
    :cond_0
    const-string v0, "LocalInstall"

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getLocalInstallDir()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedSettings;->extractAssetFiles(Ljava/lang/String;Ljava/lang/String;)V

    .line 105
    const-string v0, "Installed"

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedSettings;->extractAssetFiles(Ljava/lang/String;Ljava/lang/String;)V

    .line 107
    const-string v0, "certs"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getCertsRootDir()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "DEVICE/"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/JbedSettings;->extractAssetFiles(Ljava/lang/String;Ljava/lang/String;)V

    .line 108
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->init(Landroid/content/Context;)V

    .line 109
    return-void
.end method

.method private extractAssetFile(Ljava/lang/String;Ljava/lang/String;)V
    .locals 7
    .param p1, "srcFile"    # Ljava/lang/String;
    .param p2, "destFile"    # Ljava/lang/String;

    .prologue
    .line 153
    const/4 v2, 0x0

    .line 155
    .local v2, "in":Ljava/io/InputStream;
    :try_start_0
    iget-object v5, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v5}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v5

    invoke-virtual {v5, p1}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v2

    .line 156
    new-instance v3, Ljava/io/FileOutputStream;

    invoke-direct {v3, p2}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V

    .line 160
    .local v3, "out":Ljava/io/FileOutputStream;
    invoke-virtual {v2}, Ljava/io/InputStream;->available()I

    move-result v4

    .line 163
    .local v4, "size":I
    new-array v0, v4, [B

    .line 164
    .local v0, "buffer":[B
    invoke-virtual {v2, v0}, Ljava/io/InputStream;->read([B)I

    .line 165
    invoke-virtual {v3, v0}, Ljava/io/FileOutputStream;->write([B)V

    .line 166
    invoke-virtual {v3}, Ljava/io/FileOutputStream;->close()V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 172
    if-eqz v2, :cond_0

    :try_start_1
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_1

    .line 176
    :cond_0
    :goto_0
    return-void

    .line 167
    .end local v0    # "buffer":[B
    .end local v3    # "out":Ljava/io/FileOutputStream;
    .end local v4    # "size":I
    :catch_0
    move-exception v5

    move-object v1, v5

    .line 169
    .local v1, "e":Ljava/io/IOException;
    :try_start_2
    new-instance v5, Ljava/lang/RuntimeException;

    invoke-direct {v5, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw v5
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 171
    .end local v1    # "e":Ljava/io/IOException;
    :catchall_0
    move-exception v5

    .line 172
    if-eqz v2, :cond_1

    :try_start_3
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_2

    .line 174
    :cond_1
    :goto_1
    throw v5

    .line 173
    .restart local v0    # "buffer":[B
    .restart local v3    # "out":Ljava/io/FileOutputStream;
    .restart local v4    # "size":I
    :catch_1
    move-exception v5

    goto :goto_0

    .end local v0    # "buffer":[B
    .end local v3    # "out":Ljava/io/FileOutputStream;
    .end local v4    # "size":I
    :catch_2
    move-exception v6

    goto :goto_1
.end method

.method private extractAssetFiles(Ljava/lang/String;Ljava/lang/String;)V
    .locals 9
    .param p1, "srcFolder"    # Ljava/lang/String;
    .param p2, "destFolder"    # Ljava/lang/String;

    .prologue
    .line 181
    :try_start_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v6}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v6

    invoke-virtual {v6, p1}, Landroid/content/res/AssetManager;->list(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v2

    .line 182
    .local v2, "assets":[Ljava/lang/String;
    move-object v0, v2

    .local v0, "arr$":[Ljava/lang/String;
    array-length v5, v0

    .local v5, "len$":I
    const/4 v4, 0x0

    .local v4, "i$":I
    :goto_0
    if-ge v4, v5, :cond_1

    aget-object v1, v0, v4

    .line 183
    .local v1, "asset":Ljava/lang/String;
    new-instance v3, Ljava/io/File;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v3, v6}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 184
    .local v3, "destFile":Ljava/io/File;
    invoke-virtual {v3}, Ljava/io/File;->exists()Z

    move-result v6

    if-nez v6, :cond_0

    .line 185
    const-string v6, "JbedSettings"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, " extract file "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, " to "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v3}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 186
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    sget-object v7, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v3}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v7

    invoke-direct {p0, v6, v7}, Lcom/esmertec/android/jbed/JbedSettings;->extractAssetFile(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 182
    :cond_0
    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    .line 189
    .end local v0    # "arr$":[Ljava/lang/String;
    .end local v1    # "asset":Ljava/lang/String;
    .end local v2    # "assets":[Ljava/lang/String;
    .end local v3    # "destFile":Ljava/io/File;
    .end local v4    # "i$":I
    .end local v5    # "len$":I
    :catch_0
    move-exception v6

    .line 192
    :cond_1
    return-void
.end method

.method public static getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;
    .locals 2
    .param p0, "context"    # Landroid/content/Context;

    .prologue
    .line 76
    sget-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    if-nez v0, :cond_0

    .line 77
    new-instance v0, Lcom/esmertec/android/jbed/JbedSettings;

    const/4 v1, 0x1

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/JbedSettings;-><init>(Landroid/content/Context;Z)V

    sput-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    .line 78
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    return-object v0
.end method

.method public static getInstanceWithoutSyncCert(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;
    .locals 2
    .param p0, "context"    # Landroid/content/Context;

    .prologue
    .line 83
    sget-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    if-nez v0, :cond_0

    .line 84
    new-instance v0, Lcom/esmertec/android/jbed/JbedSettings;

    const/4 v1, 0x0

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/JbedSettings;-><init>(Landroid/content/Context;Z)V

    sput-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    .line 85
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/JbedSettings;->INSTANCE:Lcom/esmertec/android/jbed/JbedSettings;

    return-object v0
.end method

.method private loadSettinData()V
    .locals 9

    .prologue
    const/4 v2, 0x0

    const/4 v8, 0x1

    const/4 v7, 0x0

    .line 323
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    move-object v3, v2

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 325
    .local v6, "cursor":Landroid/database/Cursor;
    if-nez v6, :cond_2

    .line 326
    const-string v0, "JbedSettings"

    const-string v1, "SettingsProvider.query: failed"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 360
    :goto_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mBaseDir:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mLocalinstallDir:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 361
    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "miss some important information at "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 362
    :cond_1
    return-void

    .line 329
    :cond_2
    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_3

    .line 330
    const-string v0, "root_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    .line 332
    const-string v0, "base_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mBaseDir:Ljava/lang/String;

    .line 334
    const-string v0, "localinstall_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mLocalinstallDir:Ljava/lang/String;

    .line 336
    const-string v0, "certs_root_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mCertsRootDir:Ljava/lang/String;

    .line 339
    const-string v0, "is_nativeams"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    if-eqz v0, :cond_4

    move v0, v8

    :goto_1
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsNativeAms:Z

    .line 341
    const-string v0, "is_runtck"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    if-eqz v0, :cond_5

    move v0, v8

    :goto_2
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsRunTck:Z

    .line 343
    const-string v0, "tck_url"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mTckUrl:Ljava/lang/String;

    .line 345
    const-string v0, "is_allowed_hidden_menu"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    if-eqz v0, :cond_6

    move v0, v8

    :goto_3
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAllowedHiddenMenu:Z

    .line 347
    const-string v0, "is_launch_ams_list"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    if-eqz v0, :cond_7

    move v0, v8

    :goto_4
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAMSListLaunch:Z

    .line 349
    const-string v0, "extra_command_line"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mExtraCommandLine:Ljava/lang/String;

    .line 351
    const-string v0, "sync_certs_size"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsSize:J

    .line 353
    const-string v0, "sync_certs_date"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsDate:J
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 357
    :cond_3
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    goto/16 :goto_0

    :cond_4
    move v0, v7

    .line 339
    goto :goto_1

    :cond_5
    move v0, v7

    .line 341
    goto :goto_2

    :cond_6
    move v0, v7

    .line 345
    goto :goto_3

    :cond_7
    move v0, v7

    .line 347
    goto :goto_4

    .line 357
    :catchall_0
    move-exception v0

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    throw v0
.end method


# virtual methods
.method public getBaseDir()Ljava/lang/String;
    .locals 1

    .prologue
    .line 129
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mBaseDir:Ljava/lang/String;

    return-object v0
.end method

.method public getCertDeviceDir()Ljava/lang/String;
    .locals 2

    .prologue
    .line 121
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getCertsRootDir()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "SIM/DF/trustedCertificates/"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getCertsRootDir()Ljava/lang/String;
    .locals 1

    .prologue
    .line 133
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mCertsRootDir:Ljava/lang/String;

    return-object v0
.end method

.method public getCommands()[Ljava/lang/String;
    .locals 14

    .prologue
    .line 246
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    .line 247
    .local v2, "commandList":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    const-string v12, "-rootdir"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 248
    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    invoke-static {v12}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v12

    if-nez v12, :cond_3

    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    :goto_0
    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 251
    const-string v12, "-basedir"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 252
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v12

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 254
    const-string v12, "-localInstall"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 255
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getLocalInstallDir()Ljava/lang/String;

    move-result-object v12

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 257
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getHeapSizeString()Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    .line 259
    .local v5, "heapsizeString":Ljava/lang/String;
    const-string v12, ""

    invoke-virtual {v5, v12}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v12

    if-nez v12, :cond_0

    .line 260
    const-string v12, "-heapsize"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 261
    invoke-interface {v2, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 264
    :cond_0
    iget-boolean v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsNativeAms:Z

    if-eqz v12, :cond_1

    .line 265
    const-string v12, "-native-ams"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 268
    :cond_1
    iget-boolean v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsRunTck:Z

    if-eqz v12, :cond_2

    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mTckUrl:Ljava/lang/String;

    invoke-static {v12}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v12

    if-nez v12, :cond_2

    .line 269
    const-string v12, "-tck"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 270
    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mTckUrl:Ljava/lang/String;

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 273
    :cond_2
    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mExtraCommandLine:Ljava/lang/String;

    invoke-static {v12}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v12

    if-nez v12, :cond_4

    .line 274
    iget-object v12, p0, Lcom/esmertec/android/jbed/JbedSettings;->mExtraCommandLine:Ljava/lang/String;

    const-string v13, " "

    invoke-static {v12, v13}, Landroid/text/TextUtils;->split(Ljava/lang/String;Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v4

    .line 275
    .local v4, "extraCommands":[Ljava/lang/String;
    move-object v0, v4

    .local v0, "arr$":[Ljava/lang/String;
    array-length v7, v0

    .local v7, "len$":I
    const/4 v6, 0x0

    .local v6, "i$":I
    :goto_1
    if-ge v6, v7, :cond_4

    aget-object v1, v0, v6

    .line 276
    .local v1, "command":Ljava/lang/String;
    invoke-interface {v2, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 275
    add-int/lit8 v6, v6, 0x1

    goto :goto_1

    .line 248
    .end local v0    # "arr$":[Ljava/lang/String;
    .end local v1    # "command":Ljava/lang/String;
    .end local v4    # "extraCommands":[Ljava/lang/String;
    .end local v5    # "heapsizeString":Ljava/lang/String;
    .end local v6    # "i$":I
    .end local v7    # "len$":I
    :cond_3
    const-string v12, "/data/data/com.esmertec.android.jbed/"

    goto :goto_0

    .line 281
    .restart local v5    # "heapsizeString":Ljava/lang/String;
    :cond_4
    const-string v11, "/data/data/com.esmertec.android.jbed/Installed/selector.utf"

    .line 282
    .local v11, "selectorFileName":Ljava/lang/String;
    const-string v9, "/data/data/com.esmertec.android.jbed/PreInstall/"

    .line 283
    .local v9, "preInstallFolderName":Ljava/lang/String;
    new-instance v10, Ljava/io/File;

    invoke-direct {v10, v11}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 284
    .local v10, "selectorFile":Ljava/io/File;
    new-instance v8, Ljava/io/File;

    invoke-direct {v8, v9}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 285
    .local v8, "preInstallFolder":Ljava/io/File;
    invoke-virtual {v10}, Ljava/io/File;->exists()Z

    move-result v12

    if-nez v12, :cond_5

    invoke-virtual {v8}, Ljava/io/File;->exists()Z

    move-result v12

    if-eqz v12, :cond_5

    .line 286
    const-string v12, "JbedSettings"

    const-string v13, "need to do preinstall"

    invoke-static {v12, v13}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 287
    const-string v12, "-preinstall"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 288
    const-string v12, "/data/data/com.esmertec.android.jbed/PreInstall/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 292
    :cond_5
    const-string v12, "-DLandmarkStore.dir=/data/data/com.esmertec.android.jbed/location/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 295
    const-string v12, "-Dfileconn.dir.photos=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 296
    const-string v12, "-Dfileconn.dir.videos=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 297
    const-string v12, "-Dfileconn.dir.graphics=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 298
    const-string v12, "-Dfileconn.dir.tones=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 299
    const-string v12, "-Dfileconn.dir.music=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 300
    const-string v12, "-Dfileconn.dir.recordings=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 301
    const-string v12, "-Dfileconn.dir.memorycard=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 302
    const-string v12, "-Dfileconn.dir.private=file:///sdcard/"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 303
    const-string v12, "-Dfileconn.dir.photos.name=Photos"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 304
    const-string v12, "-Dfileconn.dir.videos.name=Videos"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 305
    const-string v12, "-Dfileconn.dir.graphics.name=Graphics"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 306
    const-string v12, "-Dfileconn.dir.tones.name=Tones"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 307
    const-string v12, "-Dfileconn.dir.music.name=Music"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 308
    const-string v12, "-Dfileconn.dir.recordings.name=Recording"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 309
    const-string v12, "-Dfileconn.dir.private.name=Private"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 312
    const-string v12, "-Dmicroedition.commports=USB1"

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 315
    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    const-string v13, "-Dmicroedition.locale="

    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getLocaleString()Ljava/lang/String;

    move-result-object v13

    invoke-virtual {v12, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v12

    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v12

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 317
    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v12

    new-array v12, v12, [Ljava/lang/String;

    invoke-interface {v2, v12}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v3

    check-cast v3, [Ljava/lang/String;

    .line 318
    .local v3, "commands":[Ljava/lang/String;
    return-object v3
.end method

.method public getLocalInstallDir()Ljava/lang/String;
    .locals 1

    .prologue
    .line 125
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mLocalinstallDir:Ljava/lang/String;

    return-object v0
.end method

.method public getRootDir()Ljava/lang/String;
    .locals 1

    .prologue
    .line 112
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    return-object v0
.end method

.method public isAMSListLaunch()Z
    .locals 1

    .prologue
    .line 149
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAMSListLaunch:Z

    return v0
.end method

.method public isAllowedHiddenMenu()Z
    .locals 1

    .prologue
    .line 145
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsAllowedHiddenMenu:Z

    return v0
.end method

.method public isNativeAms()Z
    .locals 1

    .prologue
    .line 137
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsNativeAms:Z

    return v0
.end method

.method public isRunTck()Z
    .locals 1

    .prologue
    .line 141
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsRunTck:Z

    return v0
.end method

.method syncCerts(Ljava/lang/String;)V
    .locals 23
    .param p1, "certDir"    # Ljava/lang/String;

    .prologue
    .line 201
    const-string v19, "javax.net.ssl.trustStore"

    invoke-static/range {v19 .. v19}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v18

    .line 202
    .local v18, "trustStoreName":Ljava/lang/String;
    new-instance v14, Ljava/io/File;

    move-object v0, v14

    move-object/from16 v1, v18

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 204
    .local v14, "storeFile":Ljava/io/File;
    invoke-virtual {v14}, Ljava/io/File;->exists()Z

    move-result v19

    if-nez v19, :cond_1

    .line 205
    const-string v19, "JbedSettings"

    new-instance v20, Ljava/lang/StringBuilder;

    invoke-direct/range {v20 .. v20}, Ljava/lang/StringBuilder;-><init>()V

    const-string v21, "WARNING: "

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    move-object/from16 v0, v20

    move-object/from16 v1, v18

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    const-string v21, " is not exit! do nothing! "

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v20

    invoke-static/range {v19 .. v20}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 243
    :cond_0
    :goto_0
    return-void

    .line 208
    :cond_1
    const-string v19, "JbedSettings"

    new-instance v20, Ljava/lang/StringBuilder;

    invoke-direct/range {v20 .. v20}, Ljava/lang/StringBuilder;-><init>()V

    const-string v21, "storeFileSize="

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual {v14}, Ljava/io/File;->length()J

    move-result-wide v21

    invoke-virtual/range {v20 .. v22}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v20

    const-string v21, " oldStoreFileSize="

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    move-object/from16 v0, p0

    iget-wide v0, v0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsSize:J

    move-wide/from16 v21, v0

    invoke-virtual/range {v20 .. v22}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v20

    invoke-static/range {v19 .. v20}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 209
    const-string v19, "JbedSettings"

    new-instance v20, Ljava/lang/StringBuilder;

    invoke-direct/range {v20 .. v20}, Ljava/lang/StringBuilder;-><init>()V

    const-string v21, "lastModified ="

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual {v14}, Ljava/io/File;->lastModified()J

    move-result-wide v21

    invoke-virtual/range {v20 .. v22}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v20

    const-string v21, " oldlastModified="

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    move-object/from16 v0, p0

    iget-wide v0, v0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsDate:J

    move-wide/from16 v21, v0

    invoke-virtual/range {v20 .. v22}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v20

    invoke-static/range {v19 .. v20}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 211
    invoke-virtual {v14}, Ljava/io/File;->length()J

    move-result-wide v19

    move-object/from16 v0, p0

    iget-wide v0, v0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsSize:J

    move-wide/from16 v21, v0

    cmp-long v19, v19, v21

    if-nez v19, :cond_2

    invoke-virtual {v14}, Ljava/io/File;->lastModified()J

    move-result-wide v19

    move-object/from16 v0, p0

    iget-wide v0, v0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsDate:J

    move-wide/from16 v21, v0

    cmp-long v19, v19, v21

    if-eqz v19, :cond_0

    .line 216
    :cond_2
    const-string v19, "android"

    move-object/from16 v0, p1

    move-object/from16 v1, v19

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/util/FileUtil;->cleanFiles(Ljava/lang/String;Ljava/lang/String;)V

    .line 218
    const/4 v11, 0x0

    .line 220
    .local v11, "mDefaultTrustManager":Ljavax/net/ssl/X509TrustManager;
    :try_start_0
    const-string v19, "X509"

    invoke-static/range {v19 .. v19}, Ljavax/net/ssl/TrustManagerFactory;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/TrustManagerFactory;

    move-result-object v16

    .line 221
    .local v16, "tmf":Ljavax/net/ssl/TrustManagerFactory;
    const/4 v5, 0x0

    check-cast v5, Ljava/security/KeyStore;

    move-object/from16 v0, v16

    move-object v1, v5

    invoke-virtual {v0, v1}, Ljavax/net/ssl/TrustManagerFactory;->init(Ljava/security/KeyStore;)V

    .line 222
    invoke-virtual/range {v16 .. v16}, Ljavax/net/ssl/TrustManagerFactory;->getTrustManagers()[Ljavax/net/ssl/TrustManager;

    move-result-object v17

    .line 223
    .local v17, "tms":[Ljavax/net/ssl/TrustManager;
    if-eqz v17, :cond_3

    .line 224
    move-object/from16 v5, v17

    .local v5, "arr$":[Ljavax/net/ssl/TrustManager;
    array-length v10, v5

    .local v10, "len$":I
    const/4 v9, 0x0

    .local v9, "i$":I
    :goto_1
    if-ge v9, v10, :cond_3

    aget-object v15, v5, v9

    .line 225
    .local v15, "tm":Ljavax/net/ssl/TrustManager;
    move-object v0, v15

    instance-of v0, v0, Ljavax/net/ssl/X509TrustManager;

    move/from16 v19, v0

    if-eqz v19, :cond_4

    .line 226
    move-object v0, v15

    check-cast v0, Ljavax/net/ssl/X509TrustManager;

    move-object v11, v0

    .line 231
    .end local v5    # "arr$":[Ljavax/net/ssl/TrustManager;
    .end local v9    # "i$":I
    .end local v10    # "len$":I
    .end local v15    # "tm":Ljavax/net/ssl/TrustManager;
    :cond_3
    invoke-interface {v11}, Ljavax/net/ssl/X509TrustManager;->getAcceptedIssuers()[Ljava/security/cert/X509Certificate;

    move-result-object v13

    .line 233
    .local v13, "roots":[Ljava/security/cert/X509Certificate;
    const/4 v8, 0x0

    .local v8, "i":I
    :goto_2
    move-object v0, v13

    array-length v0, v0

    move/from16 v19, v0

    move v0, v8

    move/from16 v1, v19

    if-ge v0, v1, :cond_5

    .line 234
    aget-object v19, v13, v8

    invoke-virtual/range {v19 .. v19}, Ljava/security/cert/X509Certificate;->getEncoded()[B

    move-result-object v6

    .line 235
    .local v6, "certData":[B
    new-instance v12, Ljava/io/FileOutputStream;

    new-instance v19, Ljava/lang/StringBuilder;

    invoke-direct/range {v19 .. v19}, Ljava/lang/StringBuilder;-><init>()V

    move-object/from16 v0, v19

    move-object/from16 v1, p1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v19

    const-string v20, "android"

    invoke-virtual/range {v19 .. v20}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v19

    move-object/from16 v0, v19

    move v1, v8

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v19

    const-string v20, ".cer"

    invoke-virtual/range {v19 .. v20}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v19

    invoke-virtual/range {v19 .. v19}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v19

    move-object v0, v12

    move-object/from16 v1, v19

    invoke-direct {v0, v1}, Ljava/io/FileOutputStream;-><init>(Ljava/lang/String;)V

    .line 236
    .local v12, "out":Ljava/io/FileOutputStream;
    invoke-virtual {v12, v6}, Ljava/io/FileOutputStream;->write([B)V

    .line 237
    invoke-virtual {v12}, Ljava/io/FileOutputStream;->close()V

    .line 233
    add-int/lit8 v8, v8, 0x1

    goto :goto_2

    .line 224
    .end local v6    # "certData":[B
    .end local v8    # "i":I
    .end local v12    # "out":Ljava/io/FileOutputStream;
    .end local v13    # "roots":[Ljava/security/cert/X509Certificate;
    .restart local v5    # "arr$":[Ljavax/net/ssl/TrustManager;
    .restart local v9    # "i$":I
    .restart local v10    # "len$":I
    .restart local v15    # "tm":Ljavax/net/ssl/TrustManager;
    :cond_4
    add-int/lit8 v9, v9, 0x1

    goto :goto_1

    .line 239
    .end local v5    # "arr$":[Ljavax/net/ssl/TrustManager;
    .end local v9    # "i$":I
    .end local v10    # "len$":I
    .end local v15    # "tm":Ljavax/net/ssl/TrustManager;
    .restart local v8    # "i":I
    .restart local v13    # "roots":[Ljava/security/cert/X509Certificate;
    :cond_5
    invoke-virtual {v14}, Ljava/io/File;->length()J

    move-result-wide v19

    invoke-virtual {v14}, Ljava/io/File;->lastModified()J

    move-result-wide v21

    move-object/from16 v0, p0

    move-wide/from16 v1, v19

    move-wide/from16 v3, v21

    invoke-virtual {v0, v1, v2, v3, v4}, Lcom/esmertec/android/jbed/JbedSettings;->updateSyncCertsInfo(JJ)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto/16 :goto_0

    .line 240
    .end local v8    # "i":I
    .end local v13    # "roots":[Ljava/security/cert/X509Certificate;
    .end local v16    # "tmf":Ljavax/net/ssl/TrustManagerFactory;
    .end local v17    # "tms":[Ljavax/net/ssl/TrustManager;
    :catch_0
    move-exception v19

    move-object/from16 v7, v19

    .line 241
    .local v7, "e":Ljava/lang/Exception;
    const-string v19, "JbedSettings"

    const-string v20, "Fail to syncRootCerts!!"

    move-object/from16 v0, v19

    move-object/from16 v1, v20

    move-object v2, v7

    invoke-static {v0, v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto/16 :goto_0
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    .prologue
    const-string v3, "]\n"

    const-string v2, "\n"

    .line 431
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "rootdir="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mRootDir:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\n"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "basedir="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mBaseDir:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\n"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "localInstall="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mLocalinstallDir:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\n"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "native-ams="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsNativeAms:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\n"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "isRunTck="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mIsRunTck:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " tckurl=["

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mTckUrl:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "]\n"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "mExtraCommandLine="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mExtraCommandLine:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\n SyncCertsSize=["

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-wide v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsSize:J

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "] mSyncCertsDate=["

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-wide v1, p0, Lcom/esmertec/android/jbed/JbedSettings;->mSyncCertsDate:J

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "]\n"

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "buildversion="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getBuildVersion()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public updateDirsInfo(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 7
    .param p1, "rootDir"    # Ljava/lang/String;
    .param p2, "baseDir"    # Ljava/lang/String;
    .param p3, "localInstallDir"    # Ljava/lang/String;
    .param p4, "certsRootDir"    # Ljava/lang/String;

    .prologue
    const/4 v2, 0x0

    .line 406
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    move-object v3, v2

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 408
    .local v6, "cursor":Landroid/database/Cursor;
    if-nez v6, :cond_0

    .line 409
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v2, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " is invalid"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 412
    :cond_0
    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 413
    const-string v0, "root_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p1}, Landroid/database/Cursor;->updateString(ILjava/lang/String;)Z

    .line 415
    const-string v0, "base_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p2}, Landroid/database/Cursor;->updateString(ILjava/lang/String;)Z

    .line 417
    const-string v0, "localinstall_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p3}, Landroid/database/Cursor;->updateString(ILjava/lang/String;)Z

    .line 419
    const-string v0, "certs_root_dir"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p4}, Landroid/database/Cursor;->updateString(ILjava/lang/String;)Z

    .line 421
    invoke-interface {v6}, Landroid/database/Cursor;->commitUpdates()Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 424
    :cond_1
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 426
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedSettings;->loadSettinData()V

    .line 427
    return-void

    .line 424
    :catchall_0
    move-exception v0

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    throw v0
.end method

.method public updateSyncCertsInfo(JJ)V
    .locals 7
    .param p1, "certsFileSize"    # J
    .param p3, "certsFileDate"    # J

    .prologue
    const/4 v2, 0x0

    .line 386
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    move-object v3, v2

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 388
    .local v6, "cursor":Landroid/database/Cursor;
    if-nez v6, :cond_0

    .line 389
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v2, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " is invalid"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 392
    :cond_0
    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 393
    const-string v0, "sync_certs_size"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p1, p2}, Landroid/database/Cursor;->updateLong(IJ)Z

    .line 395
    const-string v0, "sync_certs_date"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p3, p4}, Landroid/database/Cursor;->updateLong(IJ)Z

    .line 397
    invoke-interface {v6}, Landroid/database/Cursor;->commitUpdates()Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 400
    :cond_1
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 402
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedSettings;->loadSettinData()V

    .line 403
    return-void

    .line 400
    :catchall_0
    move-exception v0

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    throw v0
.end method

.method public updateTckInfo(Ljava/lang/String;Z)V
    .locals 7
    .param p1, "tckUrl"    # Ljava/lang/String;
    .param p2, "isRunTck"    # Z

    .prologue
    const/4 v2, 0x0

    .line 366
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    sget-object v1, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    move-object v3, v2

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 368
    .local v6, "cursor":Landroid/database/Cursor;
    if-nez v6, :cond_0

    .line 369
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v2, Lcom/esmertec/android/jbed/JbedProvider$Settings;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " is invalid"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    .line 372
    :cond_0
    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 373
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_1

    .line 374
    const-string v0, "tck_url"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0, p1}, Landroid/database/Cursor;->updateString(ILjava/lang/String;)Z

    .line 376
    :cond_1
    const-string v0, "is_runtck"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    if-eqz p2, :cond_3

    const/4 v1, 0x1

    :goto_0
    invoke-interface {v6, v0, v1}, Landroid/database/Cursor;->updateInt(II)Z

    .line 377
    invoke-interface {v6}, Landroid/database/Cursor;->commitUpdates()Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 380
    :cond_2
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 382
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedSettings;->loadSettinData()V

    .line 383
    return-void

    .line 376
    :cond_3
    const/4 v1, 0x0

    goto :goto_0

    .line 380
    :catchall_0
    move-exception v0

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    throw v0
.end method
