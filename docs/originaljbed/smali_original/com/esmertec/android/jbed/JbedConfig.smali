.class public Lcom/esmertec/android/jbed/JbedConfig;
.super Ljava/lang/Object;
.source "JbedConfig.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/JbedConfig$ListItem;,
        Lcom/esmertec/android/jbed/JbedConfig$Menu;,
        Lcom/esmertec/android/jbed/JbedConfig$Ams;
    }
.end annotation


# static fields
.field private static final CONFIG_PROPERTIES_FILE:Ljava/lang/String; = "config.properties"

.field private static INSTANCE:Lcom/esmertec/android/jbed/JbedConfig; = null

.field private static final TAG:Ljava/lang/String; = "JbedConfig"

.field private static mContext:Landroid/content/Context;


# instance fields
.field private mConfigProperties:Ljava/util/Properties;


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 26
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 439
    return-void
.end method

.method static synthetic access$000(Ljava/lang/String;)Z
    .locals 1
    .param p0, "x0"    # Ljava/lang/String;

    .prologue
    .line 26
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method static synthetic access$100()Lcom/esmertec/android/jbed/JbedConfig;
    .locals 1

    .prologue
    .line 26
    sget-object v0, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    return-object v0
.end method

.method static synthetic access$200()Landroid/content/Context;
    .locals 1

    .prologue
    .line 26
    sget-object v0, Lcom/esmertec/android/jbed/JbedConfig;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$300(Ljava/io/File;)Ljava/util/Properties;
    .locals 1
    .param p0, "x0"    # Ljava/io/File;

    .prologue
    .line 26
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedConfig;->getProperties(Ljava/io/File;)Ljava/util/Properties;

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$400(Ljava/lang/String;)Ljava/lang/String;
    .locals 1
    .param p0, "x0"    # Ljava/lang/String;

    .prologue
    .line 26
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static getBoolean(Ljava/lang/String;)Z
    .locals 2
    .param p0, "name"    # Ljava/lang/String;

    .prologue
    .line 136
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 137
    .local v0, "value":Ljava/lang/String;
    if-eqz v0, :cond_0

    const-string v1, "true"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x1

    :goto_0
    return v1

    :cond_0
    const/4 v1, 0x0

    goto :goto_0
.end method

.method public static getBuildDate()Ljava/lang/String;
    .locals 1

    .prologue
    .line 104
    const-string v0, "20110713"

    return-object v0
.end method

.method public static getBuildP4No()Ljava/lang/String;
    .locals 1

    .prologue
    .line 94
    const-string v0, "195487"

    return-object v0
.end method

.method public static getBuildVersion()Ljava/lang/String;
    .locals 2

    .prologue
    .line 111
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getBuildDate()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "-"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getBuildP4No()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private getConfigProperties()Ljava/util/Properties;
    .locals 1

    .prologue
    .line 84
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedConfig;->mConfigProperties:Ljava/util/Properties;

    if-nez v0, :cond_0

    .line 85
    const-string v0, "config.properties"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedConfig;->getProperties(Ljava/lang/String;)Ljava/util/Properties;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/JbedConfig;->mConfigProperties:Ljava/util/Properties;

    .line 87
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedConfig;->mConfigProperties:Ljava/util/Properties;

    return-object v0
.end method

.method public static getCustomerName()Ljava/lang/String;
    .locals 1

    .prologue
    .line 243
    const-string v0, "CUSTOMER.NAME"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getDisplayLandscapeHeight()I
    .locals 1

    .prologue
    .line 231
    const-string v0, "DISPLAY.LANDSCAPE.HEIGHT"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    return v0
.end method

.method public static getDisplayLandscapeWidth()I
    .locals 1

    .prologue
    .line 227
    const-string v0, "DISPLAY.LANDSCAPE.WIDTH"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    return v0
.end method

.method public static getDisplayPortraitHeight()I
    .locals 1

    .prologue
    .line 223
    const-string v0, "DISPLAY.PORTRAIT.HEIGHT"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    return v0
.end method

.method public static getDisplayPortraitWidth()I
    .locals 1

    .prologue
    .line 219
    const-string v0, "DISPLAY.PORTRAIT.WIDTH"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    return v0
.end method

.method public static getExcludeSearchFolder()Ljava/lang/String;
    .locals 1

    .prologue
    .line 251
    const-string v0, "SEARCHFOLDER.EXCLUDE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getFontSize()I
    .locals 2

    .prologue
    .line 204
    const-string v0, "DISPLAY.FONT.SIZE.SMALL"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    const-string v1, "DISPLAY.FONT.SIZE.NORMAL"

    invoke-static {v1}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v1

    shl-int/lit8 v1, v1, 0x8

    add-int/2addr v0, v1

    const-string v1, "DISPLAY.FONT.SIZE.LARGE"

    invoke-static {v1}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v1

    shl-int/lit8 v1, v1, 0x10

    add-int/2addr v0, v1

    return v0
.end method

.method public static getHeapSizeString()Ljava/lang/String;
    .locals 1

    .prologue
    .line 200
    const-string v0, "HEAPSIZE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static getInteger(Ljava/lang/String;)I
    .locals 2
    .param p0, "name"    # Ljava/lang/String;

    .prologue
    .line 141
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 142
    .local v0, "value":Ljava/lang/String;
    const-string v1, ""

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 143
    const/4 v1, 0x0

    .line 145
    :goto_0
    return v1

    :cond_0
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v1

    goto :goto_0
.end method

.method private static getProperties(Ljava/io/File;)Ljava/util/Properties;
    .locals 7
    .param p0, "file"    # Ljava/io/File;

    .prologue
    const-string v4, "JbedConfig"

    .line 65
    new-instance v3, Ljava/util/Properties;

    invoke-direct {v3}, Ljava/util/Properties;-><init>()V

    .line 66
    .local v3, "result":Ljava/util/Properties;
    const/4 v1, 0x0

    .line 69
    .local v1, "in":Ljava/io/InputStream;
    :try_start_0
    new-instance v2, Ljava/io/FileInputStream;

    invoke-direct {v2, p0}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 70
    .end local v1    # "in":Ljava/io/InputStream;
    .local v2, "in":Ljava/io/InputStream;
    :try_start_1
    invoke-virtual {v3, v2}, Ljava/util/Properties;->load(Ljava/io/InputStream;)V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 75
    if-eqz v2, :cond_0

    :try_start_2
    invoke-virtual {v2}, Ljava/io/InputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    :cond_0
    move-object v1, v2

    .line 79
    .end local v2    # "in":Ljava/io/InputStream;
    .restart local v1    # "in":Ljava/io/InputStream;
    :cond_1
    :goto_0
    return-object v3

    .line 76
    .end local v1    # "in":Ljava/io/InputStream;
    .restart local v2    # "in":Ljava/io/InputStream;
    :catch_0
    move-exception v4

    move-object v1, v2

    .line 78
    .end local v2    # "in":Ljava/io/InputStream;
    .restart local v1    # "in":Ljava/io/InputStream;
    goto :goto_0

    .line 71
    :catch_1
    move-exception v4

    move-object v0, v4

    .line 72
    .local v0, "e":Ljava/io/IOException;
    :goto_1
    :try_start_3
    const-string v4, "JbedConfig"

    const/4 v5, 0x5

    invoke-static {v4, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_2

    const-string v4, "JbedConfig"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "WARNNING: fail to open actual config file "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {p0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 75
    :cond_2
    if-eqz v1, :cond_1

    :try_start_4
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_2

    goto :goto_0

    .line 76
    :catch_2
    move-exception v4

    goto :goto_0

    .line 74
    .end local v0    # "e":Ljava/io/IOException;
    :catchall_0
    move-exception v4

    .line 75
    :goto_2
    if-eqz v1, :cond_3

    :try_start_5
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_3

    .line 77
    :cond_3
    :goto_3
    throw v4

    .line 76
    :catch_3
    move-exception v5

    goto :goto_3

    .line 74
    .end local v1    # "in":Ljava/io/InputStream;
    .restart local v2    # "in":Ljava/io/InputStream;
    :catchall_1
    move-exception v4

    move-object v1, v2

    .end local v2    # "in":Ljava/io/InputStream;
    .restart local v1    # "in":Ljava/io/InputStream;
    goto :goto_2

    .line 71
    .end local v1    # "in":Ljava/io/InputStream;
    .restart local v2    # "in":Ljava/io/InputStream;
    :catch_4
    move-exception v4

    move-object v0, v4

    move-object v1, v2

    .end local v2    # "in":Ljava/io/InputStream;
    .restart local v1    # "in":Ljava/io/InputStream;
    goto :goto_1
.end method

.method private getProperties(Ljava/lang/String;)Ljava/util/Properties;
    .locals 6
    .param p1, "fileName"    # Ljava/lang/String;

    .prologue
    const-string v3, "JbedConfig"

    .line 47
    new-instance v2, Ljava/util/Properties;

    invoke-direct {v2}, Ljava/util/Properties;-><init>()V

    .line 48
    .local v2, "result":Ljava/util/Properties;
    const/4 v1, 0x0

    .line 51
    .local v1, "in":Ljava/io/InputStream;
    :try_start_0
    sget-object v3, Lcom/esmertec/android/jbed/JbedConfig;->mContext:Landroid/content/Context;

    invoke-virtual {v3}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v3

    invoke-virtual {v3, p1}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v1

    .line 52
    invoke-virtual {v2, v1}, Ljava/util/Properties;->load(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 57
    if-eqz v1, :cond_0

    :try_start_1
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_2

    .line 61
    :cond_0
    :goto_0
    return-object v2

    .line 53
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 54
    .local v0, "e":Ljava/io/IOException;
    :try_start_2
    const-string v3, "JbedConfig"

    const/4 v4, 0x6

    invoke-static {v3, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v3

    if-eqz v3, :cond_1

    const-string v3, "JbedConfig"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "ERROR: fail to open asset build file "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 57
    :cond_1
    if-eqz v1, :cond_0

    :try_start_3
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_1

    goto :goto_0

    .line 58
    :catch_1
    move-exception v3

    goto :goto_0

    .line 56
    .end local v0    # "e":Ljava/io/IOException;
    :catchall_0
    move-exception v3

    .line 57
    if-eqz v1, :cond_2

    :try_start_4
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_3

    .line 59
    :cond_2
    :goto_1
    throw v3

    .line 58
    :catch_2
    move-exception v3

    goto :goto_0

    :catch_3
    move-exception v4

    goto :goto_1
.end method

.method private static getString(Ljava/lang/String;)Ljava/lang/String;
    .locals 5
    .param p0, "name"    # Ljava/lang/String;

    .prologue
    const/4 v2, 0x3

    const-string v4, ""

    const-string v3, "JbedConfig"

    .line 115
    sget-object v1, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    if-nez v1, :cond_1

    .line 116
    const-string v1, "JbedConfig"

    invoke-static {v3, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "JbedConfig"

    const-string v1, "WARNING:getString, INSTANCE is null"

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 117
    :cond_0
    const-string v1, ""

    move-object v1, v4

    .line 124
    :goto_0
    return-object v1

    .line 119
    :cond_1
    sget-object v1, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    invoke-direct {v1}, Lcom/esmertec/android/jbed/JbedConfig;->getConfigProperties()Ljava/util/Properties;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 120
    .local v0, "result":Ljava/lang/String;
    if-nez v0, :cond_3

    .line 121
    const-string v1, "JbedConfig"

    invoke-static {v3, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_2

    const-string v1, "JbedConfig"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "WARNING:getString, property:"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " is null"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 122
    :cond_2
    const-string v1, ""

    move-object v1, v4

    goto :goto_0

    .line 124
    :cond_3
    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->removeQuotation(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    goto :goto_0
.end method

.method public static getToggleSoftInputDelay()I
    .locals 1

    .prologue
    .line 215
    const-string v0, "TOGGLE.SOFTINPUT.DELAY"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getInteger(Ljava/lang/String;)I

    move-result v0

    return v0
.end method

.method public static getUserAgent()Ljava/lang/String;
    .locals 9

    .prologue
    const-string v8, "USER.AGENT"

    .line 154
    :try_start_0
    const-string v1, "ua_string"

    .line 155
    .local v1, "UA_STRING_KEY":Ljava/lang/String;
    const-string v6, "content://customization_settings/SettingTable/force_change_J2ME"

    invoke-static {v6}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    .line 157
    .local v0, "UADATA_TABLE_URI":Landroid/net/Uri;
    sget-object v6, Lcom/esmertec/android/jbed/JbedConfig;->mContext:Landroid/content/Context;

    const/4 v7, 0x0

    invoke-static {v6, v0, v7}, Lcom/esmertec/android/jbed/JbedCustomizationUtils;->loadCustomizationData(Landroid/content/Context;Landroid/net/Uri;Ljava/lang/String;)Landroid/os/Bundle;

    move-result-object v4

    .line 159
    .local v4, "uaDataBundle":Landroid/os/Bundle;
    invoke-static {v4, v1}, Lcom/esmertec/android/jbed/JbedCustomizationUtils;->getUaData(Landroid/os/Bundle;Ljava/lang/String;)Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v6

    .line 170
    .end local v0    # "UADATA_TABLE_URI":Landroid/net/Uri;
    .end local v1    # "UA_STRING_KEY":Ljava/lang/String;
    .end local v4    # "uaDataBundle":Landroid/os/Bundle;
    :goto_0
    return-object v6

    .line 160
    :catch_0
    move-exception v6

    move-object v3, v6

    .line 164
    .local v3, "re":Ljava/lang/RuntimeException;
    const/4 v5, 0x0

    .line 165
    .local v5, "userAgentStr":Ljava/lang/String;
    new-instance v2, Ljava/io/File;

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v7, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    sget-object v7, Lcom/esmertec/android/jbed/JbedConfig;->mContext:Landroid/content/Context;

    invoke-static {v7}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v7

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/JbedSettings;->getRootDir()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "config.properties"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v2, v6}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 166
    .local v2, "configFile":Ljava/io/File;
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v6

    if-eqz v6, :cond_0

    .line 167
    invoke-static {v2}, Lcom/esmertec/android/jbed/JbedConfig;->getProperties(Ljava/io/File;)Ljava/util/Properties;

    move-result-object v6

    const-string v7, "USER.AGENT"

    invoke-virtual {v6, v8}, Ljava/util/Properties;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    .line 170
    :cond_0
    if-eqz v5, :cond_1

    move-object v6, v5

    goto :goto_0

    :cond_1
    const-string v6, "USER.AGENT"

    invoke-static {v8}, Lcom/esmertec/android/jbed/JbedConfig;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    goto :goto_0
.end method

.method public static init(Landroid/content/Context;)V
    .locals 1
    .param p0, "context"    # Landroid/content/Context;

    .prologue
    .line 42
    new-instance v0, Lcom/esmertec/android/jbed/JbedConfig;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/JbedConfig;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    .line 43
    sget-object v0, Lcom/esmertec/android/jbed/JbedConfig;->INSTANCE:Lcom/esmertec/android/jbed/JbedConfig;

    sput-object p0, Lcom/esmertec/android/jbed/JbedConfig;->mContext:Landroid/content/Context;

    .line 44
    return-void
.end method

.method public static isBlockVMAfterPhoneHangup()Z
    .locals 1

    .prologue
    .line 239
    const-string v0, "BLOCKVM.AFTER.PHONE.HANGUP.ENABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isCustomiseNetworkErrorNotify()Z
    .locals 2

    .prologue
    .line 247
    const-string v0, "HTC"

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method private static isDebugSample1()Z
    .locals 1

    .prologue
    .line 183
    const-string v0, "DEBUG"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method private static isDebugSample2()Z
    .locals 1

    .prologue
    .line 195
    const/4 v0, 0x0

    return v0
.end method

.method public static isJadShowNecessary()Z
    .locals 1

    .prologue
    .line 467
    const-string v0, "JADINFO.SHOWNECESSARY"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isSupportSoftKeyboard()Z
    .locals 1

    .prologue
    .line 210
    const-string v0, "SOFT.KEYBOARD.SUPPORT"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static launchPowerOn()Z
    .locals 1

    .prologue
    .line 235
    const-string v0, "LAUNCH.POWER.ON"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->getBoolean(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method private static removeQuotation(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p0, "value"    # Ljava/lang/String;

    .prologue
    const/4 v1, 0x1

    const-string v2, "\""

    .line 129
    const-string v0, "\""

    invoke-virtual {p0, v2}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "\""

    invoke-virtual {p0, v2}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 130
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    sub-int/2addr v0, v1

    invoke-virtual {p0, v1, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object p0

    .line 132
    :cond_0
    return-object p0
.end method
