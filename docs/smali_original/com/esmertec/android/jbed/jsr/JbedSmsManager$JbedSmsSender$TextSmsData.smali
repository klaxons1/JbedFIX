.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;
.super Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
.source "JbedSmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "TextSmsData"
.end annotation


# instance fields
.field private mData:Ljava/util/List;
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
.method constructor <init>(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p1, "dstAddr"    # Ljava/lang/String;
    .param p2, "dstPort"    # I
    .param p3, "srcAddr"    # Ljava/lang/String;
    .param p4, "text"    # Ljava/lang/String;

    .prologue
    .line 569
    invoke-direct {p0, p1, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;-><init>(Ljava/lang/String;ILjava/lang/String;)V

    .line 570
    invoke-static {p4}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->divideMessageWithPort(Ljava/lang/String;)Ljava/util/List;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mData:Ljava/util/List;

    .line 571
    return-void
.end method

.method private static calculateLength(Ljava/lang/String;)[I
    .locals 11
    .param p0, "messageBody"    # Ljava/lang/String;

    .prologue
    const/16 v10, 0x84

    const/4 v9, 0x3

    const/4 v8, 0x2

    const/4 v7, 0x0

    const/4 v6, 0x1

    .line 582
    const/4 v4, 0x4

    new-array v2, v4, [I

    .line 586
    .local v2, "ret":[I
    const/4 v4, 0x1

    :try_start_0
    invoke-static {p0, v4}, Lcom/android/internal/telephony/GsmAlphabet;->countGsmSeptets(Ljava/lang/CharSequence;Z)I

    move-result v3

    .line 587
    .local v3, "septets":I
    const/4 v4, 0x1

    aput v3, v2, v4

    .line 589
    const/16 v4, 0x99

    if-le v3, v4, :cond_0

    .line 590
    const/4 v4, 0x0

    div-int/lit16 v5, v3, 0x92

    add-int/lit8 v5, v5, 0x1

    aput v5, v2, v4

    .line 591
    const/4 v4, 0x2

    rem-int/lit16 v5, v3, 0x92

    aput v5, v2, v4

    .line 596
    :goto_0
    const/4 v4, 0x3

    const/4 v5, 0x1

    aput v5, v2, v4

    .line 612
    .end local v3    # "septets":I
    :goto_1
    return-object v2

    .line 593
    .restart local v3    # "septets":I
    :cond_0
    const/4 v4, 0x0

    const/4 v5, 0x1

    aput v5, v2, v4

    .line 594
    const/4 v4, 0x2

    const/16 v5, 0x99

    sub-int/2addr v5, v3

    aput v5, v2, v4
    :try_end_0
    .catch Lcom/android/internal/telephony/EncodeException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 597
    .end local v3    # "septets":I
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 599
    .local v0, "ex":Lcom/android/internal/telephony/EncodeException;
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v4

    mul-int/lit8 v1, v4, 0x2

    .line 600
    .local v1, "octets":I
    aput v1, v2, v6

    .line 601
    if-le v1, v10, :cond_1

    .line 603
    div-int/lit16 v4, v1, 0x80

    add-int/lit8 v4, v4, 0x1

    aput v4, v2, v7

    .line 604
    rem-int/lit16 v4, v1, 0x80

    aput v4, v2, v8

    .line 609
    :goto_2
    aput v9, v2, v9

    goto :goto_1

    .line 606
    :cond_1
    aput v6, v2, v7

    .line 607
    sub-int v4, v10, v1

    aput v4, v2, v8

    goto :goto_2
.end method

.method private static divideMessageWithPort(Ljava/lang/String;)Ljava/util/List;
    .locals 9
    .param p0, "text"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")",
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    const/4 v8, 0x3

    .line 627
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->calculateLength(Ljava/lang/String;)[I

    move-result-object v4

    .line 634
    .local v4, "params":[I
    const/4 v7, 0x0

    aget v3, v4, v7

    .line 635
    .local v3, "messageCount":I
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5, v3}, Ljava/util/ArrayList;-><init>(I)V

    .line 638
    .local v5, "result":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v7

    if-nez v7, :cond_1

    .line 639
    const-string v7, ""

    invoke-interface {v5, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 674
    :cond_0
    return-object v5

    .line 645
    :cond_1
    const/4 v7, 0x1

    if-le v3, v7, :cond_3

    .line 646
    aget v7, v4, v8

    if-ne v7, v8, :cond_2

    const/16 v7, 0x80

    move v0, v7

    .line 653
    .local v0, "contentAvailableSize":I
    :goto_0
    const/4 v2, 0x0

    .line 654
    .local v2, "fragmentStart":I
    const/4 v1, 0x0

    .line 655
    .local v1, "fragmentEnd":I
    aget v7, v4, v8

    if-ne v7, v8, :cond_5

    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v7

    mul-int/lit8 v7, v7, 0x2

    move v6, v7

    .line 658
    .local v6, "textSize":I
    :goto_1
    aget v7, v4, v8

    if-ne v7, v8, :cond_7

    .line 659
    :goto_2
    if-ge v2, v6, :cond_0

    .line 660
    add-int v7, v2, v0

    if-ge v7, v6, :cond_6

    add-int v7, v2, v0

    move v1, v7

    .line 662
    :goto_3
    div-int/lit8 v7, v2, 0x2

    div-int/lit8 v8, v1, 0x2

    invoke-virtual {p0, v7, v8}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v7

    invoke-interface {v5, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 663
    move v2, v1

    goto :goto_2

    .line 646
    .end local v0    # "contentAvailableSize":I
    .end local v1    # "fragmentEnd":I
    .end local v2    # "fragmentStart":I
    .end local v6    # "textSize":I
    :cond_2
    const/16 v7, 0x92

    move v0, v7

    goto :goto_0

    .line 649
    :cond_3
    aget v7, v4, v8

    if-ne v7, v8, :cond_4

    const/16 v7, 0x84

    move v0, v7

    .restart local v0    # "contentAvailableSize":I
    :goto_4
    goto :goto_0

    .end local v0    # "contentAvailableSize":I
    :cond_4
    const/16 v7, 0x99

    move v0, v7

    goto :goto_4

    .line 655
    .restart local v0    # "contentAvailableSize":I
    .restart local v1    # "fragmentEnd":I
    .restart local v2    # "fragmentStart":I
    :cond_5
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v7

    move v6, v7

    goto :goto_1

    .restart local v6    # "textSize":I
    :cond_6
    move v1, v6

    .line 660
    goto :goto_3

    .line 667
    :cond_7
    :goto_5
    if-ge v2, v6, :cond_0

    .line 668
    invoke-static {p0, v2, v0}, Lcom/android/internal/telephony/GsmAlphabet;->findGsmSeptetLimitIndex(Ljava/lang/String;II)I

    move-result v1

    .line 670
    invoke-virtual {p0, v2, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v7

    invoke-interface {v5, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 671
    move v2, v1

    goto :goto_5
.end method


# virtual methods
.method public getSubmitPdu(I[B)Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    .locals 13
    .param p1, "index"    # I
    .param p2, "concatenatedElementData"    # [B

    .prologue
    .line 720
    iget-object v10, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mData:Ljava/util/List;

    invoke-interface {v10, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 721
    .local v2, "fragment":Ljava/lang/String;
    if-eqz v2, :cond_0

    iget-object v10, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstAddr:Ljava/lang/String;

    if-nez v10, :cond_1

    .line 722
    :cond_0
    const/4 v10, 0x0

    .line 837
    :goto_0
    return-object v10

    .line 725
    :cond_1
    new-instance v7, Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    invoke-direct {v7}, Landroid/telephony/gsm/SmsMessage$SubmitPdu;-><init>()V

    .line 728
    .local v7, "ret":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    const/16 v5, 0x41

    .line 729
    .local v5, "mtiByte":B
    iget-object v10, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mSrcAddr:Ljava/lang/String;

    iget-object v11, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstAddr:Ljava/lang/String;

    const/4 v12, 0x0

    invoke-static {v10, v11, v5, v12, v7}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$800(Ljava/lang/String;Ljava/lang/String;BZLandroid/telephony/gsm/SmsMessage$SubmitPdu;)Ljava/io/ByteArrayOutputStream;

    move-result-object v0

    .line 730
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    const/4 v10, 0x4

    new-array v6, v10, [B

    .line 738
    .local v6, "portData":[B
    :try_start_0
    new-instance v3, Lcom/android/internal/telephony/SmsHeader;

    invoke-direct {v3}, Lcom/android/internal/telephony/SmsHeader;-><init>()V

    .line 740
    .local v3, "header":Lcom/android/internal/telephony/SmsHeader;
    if-eqz p2, :cond_2

    .line 747
    new-instance v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;

    invoke-direct {v4}, Lcom/android/internal/telephony/SmsHeader$MiscElt;-><init>()V

    .line 748
    .local v4, "misc":Lcom/android/internal/telephony/SmsHeader$MiscElt;
    const/4 v10, 0x0

    iput v10, v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;->id:I

    .line 749
    iput-object p2, v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;->data:[B

    .line 750
    iget-object v10, v3, Lcom/android/internal/telephony/SmsHeader;->miscEltList:Ljava/util/ArrayList;

    invoke-virtual {v10, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 754
    .end local v4    # "misc":Lcom/android/internal/telephony/SmsHeader$MiscElt;
    :cond_2
    const/4 v10, 0x0

    iget v11, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstPort:I

    shr-int/lit8 v11, v11, 0x8

    and-int/lit16 v11, v11, 0xff

    int-to-byte v11, v11

    aput-byte v11, v6, v10

    .line 755
    const/4 v10, 0x1

    iget v11, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstPort:I

    and-int/lit16 v11, v11, 0xff

    int-to-byte v11, v11

    aput-byte v11, v6, v10

    .line 756
    const/4 v10, 0x2

    const/4 v11, 0x0

    aput-byte v11, v6, v10

    .line 757
    const/4 v10, 0x3

    const/4 v11, 0x0

    aput-byte v11, v6, v10

    .line 759
    new-instance v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;

    invoke-direct {v4}, Lcom/android/internal/telephony/SmsHeader$MiscElt;-><init>()V

    .line 760
    .restart local v4    # "misc":Lcom/android/internal/telephony/SmsHeader$MiscElt;
    const/4 v10, 0x5

    iput v10, v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;->id:I

    .line 761
    iput-object v6, v4, Lcom/android/internal/telephony/SmsHeader$MiscElt;->data:[B

    .line 762
    iget-object v10, v3, Lcom/android/internal/telephony/SmsHeader;->miscEltList:Ljava/util/ArrayList;

    invoke-virtual {v10, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 769
    invoke-static {v3}, Lcom/android/internal/telephony/SmsHeader;->toByteArray(Lcom/android/internal/telephony/SmsHeader;)[B

    move-result-object v10

    invoke-static {v2, v10}, Lcom/android/internal/telephony/GsmAlphabet;->stringToGsm7BitPackedWithHeader(Ljava/lang/String;[B)[B

    move-result-object v9

    .line 771
    .local v9, "userData":[B
    const/4 v10, 0x0

    aget-byte v10, v9, v10

    and-int/lit16 v10, v10, 0xff

    const/16 v11, 0xa0

    if-le v10, v11, :cond_3

    .line 772
    const-string v10, "JbedSmsManager"

    const-string v11, "getSubmitPdu Message too long"

    invoke-static {v10, v11}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 773
    const/4 v10, 0x0

    goto :goto_0

    .line 778
    :cond_3
    const/4 v10, 0x0

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 782
    const/4 v10, 0x0

    array-length v11, v9

    invoke-virtual {v0, v9, v10, v11}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    :try_end_0
    .catch Lcom/android/internal/telephony/EncodeException; {:try_start_0 .. :try_end_0} :catch_0

    .line 836
    .end local v3    # "header":Lcom/android/internal/telephony/SmsHeader;
    .end local v4    # "misc":Lcom/android/internal/telephony/SmsHeader$MiscElt;
    :goto_1
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v10

    iput-object v10, v7, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedMessage:[B

    move-object v10, v7

    .line 837
    goto :goto_0

    .line 783
    .end local v9    # "userData":[B
    :catch_0
    move-exception v10

    move-object v1, v10

    .line 790
    .local v1, "ex":Lcom/android/internal/telephony/EncodeException;
    :try_start_1
    const-string v10, "utf-16be"

    invoke-virtual {v2, v10}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    :try_end_1
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_1 .. :try_end_1} :catch_1

    move-result-object v9

    .line 795
    .restart local v9    # "userData":[B
    array-length v10, v9

    const/16 v11, 0x8c

    if-le v10, v11, :cond_4

    .line 796
    const-string v10, "JbedSmsManager"

    const-string v11, "getSubmitPdu Message too long"

    invoke-static {v10, v11}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 797
    const/4 v10, 0x0

    goto/16 :goto_0

    .line 791
    .end local v9    # "userData":[B
    :catch_1
    move-exception v10

    move-object v8, v10

    .line 792
    .local v8, "uex":Ljava/io/UnsupportedEncodingException;
    const/4 v10, 0x0

    goto/16 :goto_0

    .line 802
    .end local v8    # "uex":Ljava/io/UnsupportedEncodingException;
    .restart local v9    # "userData":[B
    :cond_4
    const/16 v10, 0xb

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 808
    array-length v10, v9

    if-nez p2, :cond_6

    const/4 v11, 0x7

    :goto_2
    add-int/2addr v10, v11

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 812
    if-nez p2, :cond_7

    const/4 v10, 0x6

    :goto_3
    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 814
    if-eqz p2, :cond_5

    .line 816
    const/4 v10, 0x0

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 818
    const/4 v10, 0x3

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 820
    const/4 v10, 0x0

    array-length v11, p2

    invoke-virtual {v0, p2, v10, v11}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 824
    :cond_5
    const/4 v10, 0x5

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 826
    const/4 v10, 0x4

    invoke-virtual {v0, v10}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 828
    const/4 v10, 0x0

    array-length v11, v6

    invoke-virtual {v0, v6, v10, v11}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 833
    const/4 v10, 0x0

    array-length v11, v9

    invoke-virtual {v0, v9, v10, v11}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_1

    .line 808
    :cond_6
    const/16 v11, 0xc

    goto :goto_2

    .line 812
    :cond_7
    const/16 v10, 0xb

    goto :goto_3
.end method

.method public sendByDefault(Ljava/util/List;)V
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Landroid/app/PendingIntent;",
            ">;)V"
        }
    .end annotation

    .prologue
    .local p1, "sentIntents":Ljava/util/List;, "Ljava/util/List<Landroid/app/PendingIntent;>;"
    const/4 v3, 0x0

    .line 700
    invoke-static {}, Landroid/telephony/gsm/SmsManager;->getDefault()Landroid/telephony/gsm/SmsManager;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstAddr:Ljava/lang/String;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mData:Ljava/util/List;

    check-cast v4, Ljava/util/ArrayList;

    move-object v0, p1

    check-cast v0, Ljava/util/ArrayList;

    move-object v5, v0

    move-object v6, v3

    invoke-virtual/range {v1 .. v6}, Landroid/telephony/gsm/SmsManager;->sendMultipartTextMessage(Ljava/lang/String;Ljava/lang/String;Ljava/util/ArrayList;Ljava/util/ArrayList;Ljava/util/ArrayList;)V

    .line 703
    return-void
.end method

.method public sendSinglepartMessage(Landroid/app/PendingIntent;)V
    .locals 8
    .param p1, "sentIntent"    # Landroid/app/PendingIntent;

    .prologue
    const/4 v3, 0x0

    const/4 v4, 0x0

    .line 683
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mDstAddr:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 684
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Invalid destinationAddress"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 686
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->hasPort()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 687
    invoke-virtual {p0, v4, v3}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->getSubmitPdu(I[B)Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    move-result-object v6

    .line 688
    .local v6, "pdus":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    iget-object v0, v6, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedScAddress:[B

    iget-object v1, v6, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedMessage:[B

    move-object v2, p1

    move v5, v4

    invoke-static/range {v0 .. v5}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$700([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V

    .line 695
    .end local v6    # "pdus":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    :goto_0
    return-void

    .line 691
    :cond_1
    new-instance v7, Ljava/util/ArrayList;

    invoke-direct {v7}, Ljava/util/ArrayList;-><init>()V

    .line 692
    .local v7, "sentIntents":Ljava/util/ArrayList;, "Ljava/util/ArrayList<Landroid/app/PendingIntent;>;"
    invoke-virtual {v7, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 693
    invoke-virtual {p0, v7}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->sendByDefault(Ljava/util/List;)V

    goto :goto_0
.end method

.method public size()I
    .locals 1

    .prologue
    .line 575
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;->mData:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    return v0
.end method
