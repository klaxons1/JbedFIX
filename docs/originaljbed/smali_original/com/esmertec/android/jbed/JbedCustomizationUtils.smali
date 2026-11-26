.class Lcom/esmertec/android/jbed/JbedCustomizationUtils;
.super Ljava/lang/Object;
.source "JbedConfig.java"


# static fields
.field private static final LOG_TAG:Ljava/lang/String; = "CustomizationUtils"

.field private static final UADATA_VALUE_KEY:Ljava/lang/String; = "value"

.field private static final VALUE_COLUMN_NAME:Ljava/lang/String; = "value"


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 472
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static byteArray2Bundle([B)Landroid/os/Bundle;
    .locals 4
    .param p0, "data"    # [B

    .prologue
    const/4 v3, 0x0

    .line 508
    invoke-static {}, Landroid/os/Parcel;->obtain()Landroid/os/Parcel;

    move-result-object v1

    .line 509
    .local v1, "parcel":Landroid/os/Parcel;
    array-length v2, p0

    invoke-virtual {v1, p0, v3, v2}, Landroid/os/Parcel;->unmarshall([BII)V

    .line 510
    invoke-virtual {v1, v3}, Landroid/os/Parcel;->setDataPosition(I)V

    .line 511
    new-instance v0, Landroid/os/Bundle;

    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V

    .line 512
    .local v0, "bundle":Landroid/os/Bundle;
    invoke-virtual {v0, v1}, Landroid/os/Bundle;->readFromParcel(Landroid/os/Parcel;)V

    .line 513
    return-object v0
.end method

.method public static getUaData(Landroid/os/Bundle;Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "bundle"    # Landroid/os/Bundle;
    .param p1, "key"    # Ljava/lang/String;

    .prologue
    .line 519
    invoke-virtual {p0, p1}, Landroid/os/Bundle;->getBundle(Ljava/lang/String;)Landroid/os/Bundle;

    move-result-object v0

    .line 520
    .local v0, "ua_stringBundle":Landroid/os/Bundle;
    if-nez v0, :cond_0

    const/4 v1, 0x0

    .line 521
    :goto_0
    return-object v1

    :cond_0
    const-string v1, "value"

    invoke-virtual {v0, v1}, Landroid/os/Bundle;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    goto :goto_0
.end method

.method public static loadCustomizationData(Landroid/content/Context;Landroid/net/Uri;Ljava/lang/String;)Landroid/os/Bundle;
    .locals 10
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "customizeURI"    # Landroid/net/Uri;
    .param p2, "selection"    # Ljava/lang/String;

    .prologue
    const/4 v9, 0x0

    const-string v1, "CustomizationUtils"

    .line 477
    const/4 v7, 0x0

    .line 478
    .local v7, "c":Landroid/database/Cursor;
    const/4 v6, 0x0

    .line 481
    .local v6, "bundle":Landroid/os/Bundle;
    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    .line 482
    .local v0, "cr":Landroid/content/ContentResolver;
    const/4 v1, 0x1

    new-array v2, v1, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v3, "value"

    aput-object v3, v2, v1

    .line 483
    .local v2, "projection":[Ljava/lang/String;
    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v1, p1

    move-object v3, p2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v7

    .line 485
    if-nez v7, :cond_2

    .line 486
    const-string v1, "CustomizationUtils"

    const/4 v3, 0x6

    invoke-static {v1, v3}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "CustomizationUtils"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "load customize URI failed, Cursor is null: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v1, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 499
    :cond_0
    if-eqz v7, :cond_1

    .line 500
    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 501
    const/4 v7, 0x0

    :cond_1
    move-object v1, v9

    .line 504
    :goto_0
    return-object v1

    .line 490
    :cond_2
    :try_start_1
    invoke-interface {v7}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v1

    if-nez v1, :cond_5

    .line 491
    const-string v1, "CustomizationUtils"

    const/4 v3, 0x6

    invoke-static {v1, v3}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v1

    if-eqz v1, :cond_3

    const-string v1, "CustomizationUtils"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "load customize URI failed, !c.moveToFirst(): "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {p1}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v1, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 499
    :cond_3
    if-eqz v7, :cond_4

    .line 500
    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 501
    const/4 v7, 0x0

    :cond_4
    move-object v1, v9

    goto :goto_0

    .line 496
    :cond_5
    const/4 v1, 0x0

    :try_start_2
    invoke-interface {v7, v1}, Landroid/database/Cursor;->getBlob(I)[B

    move-result-object v8

    .line 497
    .local v8, "data":[B
    invoke-static {v8}, Lcom/esmertec/android/jbed/JbedCustomizationUtils;->byteArray2Bundle([B)Landroid/os/Bundle;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-result-object v6

    .line 499
    if-eqz v7, :cond_6

    .line 500
    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 501
    const/4 v7, 0x0

    :cond_6
    move-object v1, v6

    .line 504
    goto :goto_0

    .line 499
    .end local v0    # "cr":Landroid/content/ContentResolver;
    .end local v2    # "projection":[Ljava/lang/String;
    .end local v8    # "data":[B
    :catchall_0
    move-exception v1

    if-eqz v7, :cond_7

    .line 500
    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 501
    const/4 v7, 0x0

    :cond_7
    throw v1
.end method
