.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallPreviewJadEventHandler"
.end annotation


# static fields
.field private static mDenyDelete:Z

.field private static mSize:Ljava/lang/String;


# instance fields
.field private mJadPreviewText:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 526
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method private static decodeBytesToStrings([B)[Ljava/lang/String;
    .locals 7
    .param p0, "bytes"    # [B

    .prologue
    .line 533
    new-instance v3, Ljava/util/ArrayList;

    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    .line 534
    .local v3, "result":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    const/4 v1, 0x0

    .line 535
    .local v1, "from":I
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    array-length v4, p0

    if-ge v2, v4, :cond_1

    .line 537
    aget-byte v4, p0, v2

    if-nez v4, :cond_0

    .line 539
    :try_start_0
    new-instance v4, Ljava/lang/String;

    sub-int v5, v2, v1

    const-string v6, "UTF-8"

    invoke-direct {v4, p0, v1, v5, v6}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    .line 540
    add-int/lit8 v1, v2, 0x1

    .line 535
    :cond_0
    :goto_1
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 541
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 542
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    const-string v4, "error encoding"

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 543
    const-string v4, "AmsEventHandler"

    const-string v5, "UnsupportedEncodingException "

    invoke-static {v4, v5, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_1

    .line 547
    .end local v0    # "e":Ljava/io/UnsupportedEncodingException;
    :cond_1
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v4

    new-array v4, v4, [Ljava/lang/String;

    invoke-interface {v3, v4}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "bytes":[B
    check-cast p0, [Ljava/lang/String;

    return-object p0
.end method

.method public static denyDelete()Z
    .locals 1

    .prologue
    .line 551
    sget-boolean v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mDenyDelete:Z

    return v0
.end method

.method public static getJarSize()Ljava/lang/String;
    .locals 1

    .prologue
    .line 554
    sget-object v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mSize:Ljava/lang/String;

    return-object v0
.end method


# virtual methods
.method public parseData([B)V
    .locals 13
    .param p1, "rawData"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const-string v12, "MIDlet-Jar-Size"

    const-string v11, "\n"

    .line 562
    if-eqz p1, :cond_0

    array-length v9, p1

    if-nez v9, :cond_2

    .line 563
    :cond_0
    const-string v9, "AmsEventHandler"

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "JadPreviewEventHandle.parseData(), No any data for event"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    iget-object v11, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v11, v11, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    invoke-static {v11}, Lcom/esmertec/android/jbed/ams/AmsClient;->getEventName(I)Ljava/lang/String;

    move-result-object v11

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v9, v10}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 614
    :cond_1
    :goto_0
    return-void

    .line 567
    :cond_2
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    .line 568
    .local v0, "buf":Ljava/lang/StringBuffer;
    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->decodeBytesToStrings([B)[Ljava/lang/String;

    move-result-object v4

    .line 570
    .local v4, "lines":[Ljava/lang/String;
    const/4 v6, 0x0

    .line 571
    .local v6, "suiteName":Ljava/lang/String;
    const/4 v7, 0x0

    .line 572
    .local v7, "vendor":Ljava/lang/String;
    const/4 v8, 0x0

    .line 573
    .local v8, "version":Ljava/lang/String;
    const/4 v1, 0x0

    .line 574
    .local v1, "description":Ljava/lang/String;
    const/4 v5, 0x0

    .line 575
    .local v5, "size":Ljava/lang/String;
    const/4 v9, 0x0

    sput-boolean v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mDenyDelete:Z

    .line 577
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isJadShowNecessary()Z

    move-result v9

    if-eqz v9, :cond_b

    .line 578
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_1
    array-length v9, v4

    if-ge v2, v9, :cond_9

    .line 579
    aget-object v3, v4, v2

    .line 580
    .local v3, "key":Ljava/lang/String;
    const-string v9, "MIDlet-Name"

    invoke-virtual {v3, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_4

    .line 581
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "Name: "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "\n"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    .line 578
    :cond_3
    :goto_2
    add-int/lit8 v2, v2, 0x2

    goto :goto_1

    .line 582
    :cond_4
    const-string v9, "MIDlet-Jar-Size"

    invoke-virtual {v3, v12}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_5

    .line 583
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "Size: "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "bytes\n"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 584
    add-int/lit8 v9, v2, 0x1

    aget-object v9, v4, v9

    sput-object v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mSize:Ljava/lang/String;

    goto :goto_2

    .line 585
    :cond_5
    const-string v9, "MIDlet-Vendor"

    invoke-virtual {v3, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_6

    .line 586
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "Vendor: "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "\n"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    goto :goto_2

    .line 587
    :cond_6
    const-string v9, "MIDlet-Version"

    invoke-virtual {v3, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_7

    .line 588
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "Version: "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "\n"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    goto :goto_2

    .line 589
    :cond_7
    const-string v9, "MIDlet-Description"

    invoke-virtual {v3, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_8

    .line 590
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "Description: "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "\n"

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    goto/16 :goto_2

    .line 591
    :cond_8
    const-string v9, "LGE-MIDlet-Mgr-User-Denied"

    invoke-virtual {v3, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_3

    .line 592
    add-int/lit8 v9, v2, 0x1

    aget-object v9, v4, v9

    const-string v10, "delete"

    invoke-virtual {v9, v10}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_3

    .line 593
    const/4 v9, 0x1

    sput-boolean v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mDenyDelete:Z

    goto/16 :goto_2

    .line 596
    .end local v3    # "key":Ljava/lang/String;
    :cond_9
    iput-object v6, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    .line 597
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    iput-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    .line 598
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    iput-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    .line 599
    if-nez v1, :cond_a

    .line 600
    const-string v1, "Description: N/A\n"

    .line 602
    :cond_a
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    iput-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    .line 603
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    iput-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    goto/16 :goto_0

    .line 605
    .end local v2    # "i":I
    :cond_b
    const/4 v2, 0x0

    .restart local v2    # "i":I
    :goto_3
    array-length v9, v4

    if-ge v2, v9, :cond_1

    .line 606
    aget-object v9, v4, v2

    invoke-virtual {v0, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v9

    const-string v10, ": "

    invoke-virtual {v9, v10}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v9

    add-int/lit8 v10, v2, 0x1

    aget-object v10, v4, v10

    invoke-virtual {v9, v10}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v9

    const/16 v10, 0xa

    invoke-virtual {v9, v10}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 607
    aget-object v9, v4, v2

    const-string v10, "MIDlet-Jar-Size"

    invoke-virtual {v9, v12}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v9

    if-eqz v9, :cond_c

    .line 608
    add-int/lit8 v9, v2, 0x1

    aget-object v9, v4, v9

    sput-object v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mSize:Ljava/lang/String;

    .line 610
    :cond_c
    invoke-virtual {v0}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v9

    iput-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    .line 605
    add-int/lit8 v2, v2, 0x2

    goto :goto_3
.end method

.method public run()V
    .locals 3

    .prologue
    .line 621
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f05006f

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;->mJadPreviewText:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040013

    new-instance v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    const v1, 0x1040009

    new-instance v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;)V

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 641
    return-void
.end method
