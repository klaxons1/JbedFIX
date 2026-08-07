.class Lcom/esmertec/android/jbed/ams/FolderNameI18N;
.super Ljava/lang/Object;
.source "AmsActivity.java"


# static fields
.field public static final FOLDER_NAME_DOWNLOAD_APPLICATIONS:Ljava/lang/String; = "Download Applications"

.field public static final FOLDER_NAME_DOWNLOAD_GAMES:Ljava/lang/String; = "Download Games"

.field public static final FOLDER_NUMBERS:I = 0x2

.field public static final REQUEST_FOLDER_DOWNLOAD_APPS:I = 0x2

.field public static final REQUEST_FOLDER_DOWNLOAD_GAMES:I = 0x1

.field public static final URL_KR:Ljava/lang/String; = "http://wap.lge.com"


# instance fields
.field private mContext:Landroid/content/Context;

.field private telMgr:Landroid/telephony/TelephonyManager;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 1413
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 1414
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->mContext:Landroid/content/Context;

    .line 1415
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->mContext:Landroid/content/Context;

    const-string v1, "phone"

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/telephony/TelephonyManager;

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->telMgr:Landroid/telephony/TelephonyManager;

    .line 1416
    return-void
.end method


# virtual methods
.method public getFolderUrl()Ljava/lang/String;
    .locals 6

    .prologue
    const-string v5, "http://mobile.orange.ch/games"

    const-string v4, "http://wap.lge.com"

    .line 1493
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->telMgr:Landroid/telephony/TelephonyManager;

    if-nez v2, :cond_0

    .line 1495
    const-string v2, "http://wap.lge.com"

    move-object v2, v4

    .line 1534
    :goto_0
    return-object v2

    .line 1499
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->telMgr:Landroid/telephony/TelephonyManager;

    invoke-virtual {v2}, Landroid/telephony/TelephonyManager;->getSubscriberId()Ljava/lang/String;

    move-result-object v0

    .line 1500
    .local v0, "imsi":Ljava/lang/String;
    if-nez v0, :cond_1

    .line 1502
    const-string v2, "http://wap.lge.com"

    move-object v2, v4

    goto :goto_0

    .line 1506
    :cond_1
    const/4 v2, 0x0

    const/4 v3, 0x3

    invoke-virtual {v0, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 1508
    .local v1, "mcc":Ljava/lang/String;
    if-nez v1, :cond_2

    .line 1510
    const-string v2, "http://wap.lge.com"

    move-object v2, v4

    goto :goto_0

    .line 1512
    :cond_2
    const-string v2, "206"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3

    .line 1514
    const-string v2, "http://mobile.orange.ch/games"

    move-object v2, v5

    goto :goto_0

    .line 1516
    :cond_3
    const-string v2, "228"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_4

    .line 1518
    const-string v2, "http://mobile.orange.ch/games"

    move-object v2, v5

    goto :goto_0

    .line 1520
    :cond_4
    const-string v2, "214"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_5

    .line 1522
    const/4 v2, 0x0

    goto :goto_0

    .line 1524
    :cond_5
    const-string v2, "208"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_6

    .line 1526
    const-string v2, "http://jeux2.mob2.orange.fr"

    goto :goto_0

    .line 1528
    :cond_6
    const-string v2, "450"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_7

    .line 1530
    const-string v2, "http://wap.lge.com"

    move-object v2, v4

    goto :goto_0

    .line 1534
    :cond_7
    const-string v2, "http://wap.lge.com"

    move-object v2, v4

    goto :goto_0
.end method

.method public getI18NStrings(I)Ljava/lang/String;
    .locals 9
    .param p1, "whichfolder"    # I

    .prologue
    const/4 v5, 0x0

    const/4 v4, 0x1

    const-string v8, "Games"

    const-string v7, "Download Games"

    const-string v6, "Download Applications"

    .line 1419
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->telMgr:Landroid/telephony/TelephonyManager;

    if-nez v2, :cond_1

    .line 1421
    if-ne p1, v4, :cond_0

    .line 1422
    const-string v2, "Download Games"

    move-object v2, v7

    .line 1486
    :goto_0
    return-object v2

    .line 1424
    :cond_0
    const-string v2, "Download Applications"

    move-object v2, v6

    goto :goto_0

    .line 1428
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->telMgr:Landroid/telephony/TelephonyManager;

    invoke-virtual {v2}, Landroid/telephony/TelephonyManager;->getSubscriberId()Ljava/lang/String;

    move-result-object v0

    .line 1429
    .local v0, "imsi":Ljava/lang/String;
    if-nez v0, :cond_3

    .line 1431
    if-ne p1, v4, :cond_2

    .line 1432
    const-string v2, "Download Games"

    move-object v2, v7

    goto :goto_0

    .line 1434
    :cond_2
    const-string v2, "Download Applications"

    move-object v2, v6

    goto :goto_0

    .line 1438
    :cond_3
    const/4 v2, 0x0

    const/4 v3, 0x3

    invoke-virtual {v0, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v1

    .line 1439
    .local v1, "mcc":Ljava/lang/String;
    if-nez v1, :cond_5

    .line 1441
    if-ne p1, v4, :cond_4

    .line 1442
    const-string v2, "Download Games"

    move-object v2, v7

    goto :goto_0

    .line 1444
    :cond_4
    const-string v2, "Download Applications"

    move-object v2, v6

    goto :goto_0

    .line 1446
    :cond_5
    const-string v2, "206"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_7

    .line 1448
    if-ne p1, v4, :cond_6

    .line 1449
    const-string v2, "Games"

    move-object v2, v8

    goto :goto_0

    :cond_6
    move-object v2, v5

    .line 1451
    goto :goto_0

    .line 1453
    :cond_7
    const-string v2, "228"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_9

    .line 1455
    if-ne p1, v4, :cond_8

    .line 1456
    const-string v2, "Games"

    move-object v2, v8

    goto :goto_0

    :cond_8
    move-object v2, v5

    .line 1458
    goto :goto_0

    .line 1460
    :cond_9
    const-string v2, "214"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_b

    .line 1462
    if-ne p1, v4, :cond_a

    move-object v2, v5

    .line 1463
    goto :goto_0

    :cond_a
    move-object v2, v5

    .line 1465
    goto :goto_0

    .line 1467
    :cond_b
    const-string v2, "208"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_d

    .line 1469
    if-ne p1, v4, :cond_c

    .line 1470
    const-string v2, "Plus de jeux"

    goto :goto_0

    :cond_c
    move-object v2, v5

    .line 1472
    goto :goto_0

    .line 1474
    :cond_d
    const-string v2, "450"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_f

    .line 1476
    if-ne p1, v4, :cond_e

    .line 1477
    const-string v2, "Download Games"

    move-object v2, v7

    goto :goto_0

    .line 1479
    :cond_e
    const-string v2, "Download Applications"

    move-object v2, v6

    goto :goto_0

    .line 1483
    :cond_f
    if-ne p1, v4, :cond_10

    .line 1484
    const-string v2, "Download Games"

    move-object v2, v7

    goto :goto_0

    .line 1486
    :cond_10
    const-string v2, "Download Applications"

    move-object v2, v6

    goto/16 :goto_0
.end method
