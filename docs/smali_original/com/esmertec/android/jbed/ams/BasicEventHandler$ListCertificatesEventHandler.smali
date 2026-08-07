.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ListCertificatesEventHandler"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    }
.end annotation


# instance fields
.field private final INDEX_FINGERPRINT:C

.field private final INDEX_ISSUER:C

.field private final INDEX_NOTAFTER:C

.field private final INDEX_NOTBEFORE:C

.field private final INDEX_SHORT_SUBJECT:C

.field private final INDEX_SUBJECT:C

.field private certificateInfos:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private duedates:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private fingerprints:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private issuers:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private mInflater:Landroid/view/LayoutInflater;

.field private shortsubjects:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private subjects:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 1399
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 1401
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->certificateInfos:Ljava/util/List;

    .line 1402
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->shortsubjects:Ljava/util/List;

    .line 1403
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->subjects:Ljava/util/List;

    .line 1404
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->issuers:Ljava/util/List;

    .line 1405
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->duedates:Ljava/util/List;

    .line 1406
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->fingerprints:Ljava/util/List;

    .line 1410
    const/4 v0, 0x0

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_SHORT_SUBJECT:C

    .line 1411
    const/4 v0, 0x1

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_SUBJECT:C

    .line 1412
    const/4 v0, 0x2

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_ISSUER:C

    .line 1413
    const/4 v0, 0x3

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_NOTBEFORE:C

    .line 1414
    const/4 v0, 0x4

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_NOTAFTER:C

    .line 1415
    const/4 v0, 0x5

    iput-char v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->INDEX_FINGERPRINT:C

    .line 1508
    return-void
.end method

.method static synthetic access$1200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Landroid/view/LayoutInflater;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mInflater:Landroid/view/LayoutInflater;

    return-object v0
.end method

.method static synthetic access$1300(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->shortsubjects:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$1400(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->fingerprints:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$1500(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->duedates:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$1600(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->subjects:Ljava/util/List;

    return-object v0
.end method

.method static synthetic access$1700(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .prologue
    .line 1399
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->issuers:Ljava/util/List;

    return-object v0
.end method


# virtual methods
.method protected parseData([B)V
    .locals 12
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 1419
    if-nez p1, :cond_0

    .line 1420
    new-instance v9, Ljava/lang/IllegalArgumentException;

    const-string v10, "pass the invalid data in SelectStorageEventHandler event!!!"

    invoke-direct {v9, v10}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v9

    .line 1422
    :cond_0
    new-instance v3, Ljava/io/DataInputStream;

    new-instance v9, Ljava/io/ByteArrayInputStream;

    invoke-direct {v9, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v3, v9}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 1424
    .local v3, "in":Ljava/io/DataInputStream;
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readInt()I

    move-result v4

    .line 1435
    .local v4, "len":I
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    if-ge v2, v4, :cond_4

    .line 1436
    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v0

    .line 1443
    .local v0, "certificateInfo":Ljava/lang/String;
    const-string v9, "CN="

    invoke-virtual {v0, v9}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v8

    .line 1445
    .local v8, "start":I
    const/4 v9, -0x1

    if-ne v8, v9, :cond_1

    .line 1446
    const-string v9, "OU="

    invoke-virtual {v0, v9}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v8

    .line 1448
    :cond_1
    const/4 v9, -0x1

    if-ne v8, v9, :cond_2

    .line 1449
    const-string v9, "O="

    invoke-virtual {v0, v9}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v8

    .line 1450
    :cond_2
    const/4 v9, -0x1

    if-ne v8, v9, :cond_3

    .line 1451
    const-string v9, "AmsEventHandler"

    const-string v10, "ListCertificatesEventHandler can not find infomation"

    invoke-static {v9, v10}, Lcom/esmertec/android/jbed/LogTag;->amsWarning(Ljava/lang/String;Ljava/lang/String;)V

    .line 1452
    :cond_3
    invoke-virtual {v0, v8}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    .line 1453
    const-string v9, "="

    invoke-virtual {v0, v9}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v9

    add-int/lit8 v9, v9, 0x1

    invoke-virtual {v0, v9}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    .line 1454
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->certificateInfos:Ljava/util/List;

    invoke-interface {v9, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1435
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 1457
    .end local v0    # "certificateInfo":Ljava/lang/String;
    .end local v8    # "start":I
    :cond_4
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->certificateInfos:Ljava/util/List;

    sget-object v10, Ljava/lang/String;->CASE_INSENSITIVE_ORDER:Ljava/util/Comparator;

    invoke-static {v9, v10}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 1459
    const/4 v2, 0x0

    .end local p1    # "data":[B
    :goto_1
    if-ge v2, v4, :cond_7

    .line 1460
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->certificateInfos:Ljava/util/List;

    invoke-interface {v9, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    const-string v9, "\r\n"

    invoke-virtual {p1, v9}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v5

    .line 1463
    .local v5, "lines":[Ljava/lang/String;
    const/4 v9, 0x0

    aget-object v9, v5, v9

    const-string v10, ";"

    invoke-virtual {v9, v10}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    .line 1464
    .local v1, "end":I
    const/4 v9, -0x1

    if-eq v1, v9, :cond_5

    .line 1465
    const/4 v9, 0x0

    const/4 v10, 0x0

    aget-object v10, v5, v10

    const/4 v11, 0x0

    invoke-virtual {v10, v11, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v10

    aput-object v10, v5, v9

    .line 1466
    :cond_5
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->shortsubjects:Ljava/util/List;

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "   "

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const/4 v11, 0x0

    aget-object v11, v5, v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-interface {v9, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1467
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v9

    if-eqz v9, :cond_6

    .line 1468
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->subjects:Ljava/util/List;

    const/4 v10, 0x1

    aget-object v10, v5, v10

    invoke-interface {v9, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1471
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->issuers:Ljava/util/List;

    const/4 v10, 0x2

    aget-object v10, v5, v10

    invoke-interface {v9, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1475
    new-instance v7, Ljava/util/Date;

    new-instance v9, Ljava/lang/Long;

    const/4 v10, 0x3

    aget-object v10, v5, v10

    invoke-direct {v9, v10}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual {v9}, Ljava/lang/Long;->longValue()J

    move-result-wide v9

    invoke-direct {v7, v9, v10}, Ljava/util/Date;-><init>(J)V

    .line 1476
    .local v7, "notbeforeDate":Ljava/util/Date;
    new-instance v6, Ljava/util/Date;

    new-instance v9, Ljava/lang/Long;

    const/4 v10, 0x4

    aget-object v10, v5, v10

    invoke-direct {v9, v10}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual {v9}, Ljava/lang/Long;->longValue()J

    move-result-wide v9

    invoke-direct {v6, v9, v10}, Ljava/util/Date;-><init>(J)V

    .line 1477
    .local v6, "notafterDate":Ljava/util/Date;
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->duedates:Ljava/util/List;

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v7}, Ljava/util/Date;->getYear()I

    move-result v11

    add-int/lit16 v11, v11, 0x76c

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "."

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v7}, Ljava/util/Date;->getMonth()I

    move-result v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "."

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v7}, Ljava/util/Date;->getDay()I

    move-result v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "-"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v6}, Ljava/util/Date;->getYear()I

    move-result v11

    add-int/lit16 v11, v11, 0x76c

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "."

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v6}, Ljava/util/Date;->getMonth()I

    move-result v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "."

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v6}, Ljava/util/Date;->getDay()I

    move-result v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-interface {v9, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1481
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->fingerprints:Ljava/util/List;

    const/4 v10, 0x5

    aget-object v10, v5, v10

    invoke-interface {v9, v10}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 1459
    .end local v6    # "notafterDate":Ljava/util/Date;
    .end local v7    # "notbeforeDate":Ljava/util/Date;
    :cond_6
    add-int/lit8 v2, v2, 0x1

    goto/16 :goto_1

    .line 1485
    .end local v1    # "end":I
    .end local v5    # "lines":[Ljava/lang/String;
    :cond_7
    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mContext:Landroid/content/Context;

    const-string v10, "layout_inflater"

    invoke-virtual {v9, v10}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/view/LayoutInflater;

    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mInflater:Landroid/view/LayoutInflater;

    .line 1486
    return-void
.end method

.method public run()V
    .locals 7

    .prologue
    const/4 v6, 0x0

    .line 1490
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mInflater:Landroid/view/LayoutInflater;

    const v5, 0x7f030005

    invoke-virtual {v4, v5, v6}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v3

    .line 1491
    .local v3, "view":Landroid/view/View;
    const v4, 0x7f080010

    invoke-virtual {v3, v4}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ListView;

    .line 1492
    .local v2, "listView":Landroid/widget/ListView;
    new-instance v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->shortsubjects:Ljava/util/List;

    invoke-direct {v0, p0, v4, v6}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;Ljava/util/List;Lcom/esmertec/android/jbed/ams/BasicEventHandler$1;)V

    .line 1493
    .local v0, "certificatesitemadapter":Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    invoke-virtual {v2, v0}, Landroid/widget/ListView;->setAdapter(Landroid/widget/ListAdapter;)V

    .line 1494
    invoke-virtual {v2, v0}, Landroid/widget/ListView;->setOnItemClickListener(Landroid/widget/AdapterView$OnItemClickListener;)V

    .line 1496
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v4, v2}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f05017b

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x104000a

    sget-object v6, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v1

    .line 1505
    .local v1, "dialog":Landroid/app/AlertDialog;
    invoke-virtual {v1}, Landroid/app/AlertDialog;->show()V

    .line 1506
    return-void
.end method
