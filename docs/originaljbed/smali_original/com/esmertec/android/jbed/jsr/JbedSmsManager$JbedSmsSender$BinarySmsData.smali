.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;
.super Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
.source "JbedSmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "BinarySmsData"
.end annotation


# instance fields
.field private mData:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<[B>;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Ljava/lang/String;ILjava/lang/String;[B)V
    .locals 1
    .param p1, "dstAddr"    # Ljava/lang/String;
    .param p2, "dstPort"    # I
    .param p3, "srcAddr"    # Ljava/lang/String;
    .param p4, "payload"    # [B

    .prologue
    .line 846
    invoke-direct {p0, p1, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;-><init>(Ljava/lang/String;ILjava/lang/String;)V

    .line 847
    invoke-direct {p0, p4}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->divideMessageWithPort([B)Ljava/util/List;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mData:Ljava/util/List;

    .line 848
    return-void
.end method

.method private static calculateLength([B)[I
    .locals 6
    .param p0, "payload"    # [B

    .prologue
    const/16 v5, 0x84

    const/4 v4, 0x2

    const/4 v3, 0x0

    const/4 v2, 0x1

    .line 856
    const/4 v1, 0x3

    new-array v0, v1, [I

    .line 857
    .local v0, "ret":[I
    array-length v1, p0

    aput v1, v0, v2

    .line 859
    aget v1, v0, v2

    if-le v1, v5, :cond_0

    .line 860
    aget v1, v0, v2

    div-int/lit16 v1, v1, 0x80

    add-int/lit8 v1, v1, 0x1

    aput v1, v0, v3

    .line 861
    aget v1, v0, v2

    rem-int/lit16 v1, v1, 0x80

    aput v1, v0, v4

    .line 866
    :goto_0
    return-object v0

    .line 863
    :cond_0
    aput v2, v0, v3

    .line 864
    aget v1, v0, v2

    sub-int v1, v5, v1

    aput v1, v0, v4

    goto :goto_0
.end method

.method private divideMessageWithPort([B)Ljava/util/List;
    .locals 12
    .param p1, "payload"    # [B
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([B)",
            "Ljava/util/List",
            "<[B>;"
        }
    .end annotation

    .prologue
    const/4 v11, 0x0

    const/4 v10, 0x1

    .line 870
    invoke-static {p1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->calculateLength([B)[I

    move-result-object v6

    .line 876
    .local v6, "params":[I
    aget v5, v6, v11

    .line 877
    .local v5, "messageCount":I
    new-instance v7, Ljava/util/ArrayList;

    invoke-direct {v7, v5}, Ljava/util/ArrayList;-><init>(I)V

    .line 880
    .local v7, "result":Ljava/util/List;, "Ljava/util/List<[B>;"
    array-length v8, p1

    if-nez v8, :cond_1

    .line 881
    new-array v8, v11, [B

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 904
    :cond_0
    return-object v7

    .line 887
    :cond_1
    if-le v5, v10, :cond_2

    .line 888
    const/16 v0, 0x80

    .line 893
    .local v0, "contentAvailableSize":I
    :goto_0
    const/4 v4, 0x0

    .line 894
    .local v4, "fragmentStart":I
    const/4 v2, 0x0

    .line 895
    .local v2, "fragmentEnd":I
    :goto_1
    aget v8, v6, v10

    if-ge v4, v8, :cond_0

    .line 896
    add-int v8, v4, v0

    aget v9, v6, v10

    if-ge v8, v9, :cond_3

    add-int v8, v4, v0

    move v2, v8

    .line 898
    :goto_2
    sub-int v3, v2, v4

    .line 899
    .local v3, "fragmentLen":I
    new-array v1, v3, [B

    .line 900
    .local v1, "fragment":[B
    invoke-static {p1, v4, v1, v11, v3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 901
    invoke-interface {v7, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 902
    move v4, v2

    .line 903
    goto :goto_1

    .line 890
    .end local v0    # "contentAvailableSize":I
    .end local v1    # "fragment":[B
    .end local v2    # "fragmentEnd":I
    .end local v3    # "fragmentLen":I
    .end local v4    # "fragmentStart":I
    :cond_2
    const/16 v0, 0x84

    .restart local v0    # "contentAvailableSize":I
    goto :goto_0

    .line 896
    .restart local v2    # "fragmentEnd":I
    .restart local v4    # "fragmentStart":I
    :cond_3
    aget v8, v6, v10

    move v2, v8

    goto :goto_2
.end method


# virtual methods
.method public getSubmitPdu(I[B)Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    .locals 8
    .param p1, "index"    # I
    .param p2, "concatenatedElementData"    # [B

    .prologue
    const/4 v7, 0x4

    const/4 v6, 0x0

    .line 940
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mData:Ljava/util/List;

    invoke-interface {v3, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [B

    .line 941
    .local v1, "fragment":[B
    array-length v3, v1

    const/16 v4, 0x80

    if-le v3, v4, :cond_0

    .line 942
    const-string v3, "JbedSmsManager"

    const-string v4, "SMS data message may only contain 128 bytes"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 944
    const/4 v3, 0x0

    .line 992
    :goto_0
    return-object v3

    .line 953
    :cond_0
    new-instance v2, Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    invoke-direct {v2}, Landroid/telephony/gsm/SmsMessage$SubmitPdu;-><init>()V

    .line 954
    .local v2, "ret":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mSrcAddr:Ljava/lang/String;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstAddr:Ljava/lang/String;

    const/16 v5, 0x41

    invoke-static {v3, v4, v5, v6, v2}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$800(Ljava/lang/String;Ljava/lang/String;BZLandroid/telephony/gsm/SmsMessage$SubmitPdu;)Ljava/io/ByteArrayOutputStream;

    move-result-object v0

    .line 961
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    invoke-virtual {v0, v7}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 966
    array-length v3, v1

    add-int/lit8 v3, v3, 0xc

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 969
    const/16 v3, 0xb

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 972
    invoke-virtual {v0, v6}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 974
    const/4 v3, 0x3

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 976
    array-length v3, p2

    invoke-virtual {v0, p2, v6, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 979
    const/4 v3, 0x5

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 982
    invoke-virtual {v0, v7}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 983
    iget v3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstPort:I

    shr-int/lit8 v3, v3, 0x8

    and-int/lit16 v3, v3, 0xff

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 984
    iget v3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstPort:I

    and-int/lit16 v3, v3, 0xff

    invoke-virtual {v0, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 985
    invoke-virtual {v0, v6}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 986
    invoke-virtual {v0, v6}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 989
    array-length v3, v1

    invoke-virtual {v0, v1, v6, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 991
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v3

    iput-object v3, v2, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedMessage:[B

    move-object v3, v2

    .line 992
    goto :goto_0
.end method

.method public sendByDefault(Ljava/util/List;)V
    .locals 2
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
    .line 997
    .local p1, "sentIntents":Ljava/util/List;, "Ljava/util/List<Landroid/app/PendingIntent;>;"
    new-instance v0, Ljava/lang/UnsupportedOperationException;

    const-string v1, "don\'t support send binary without port"

    invoke-direct {v0, v1}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public sendSinglepartMessage(Landroid/app/PendingIntent;)V
    .locals 7
    .param p1, "sentIntent"    # Landroid/app/PendingIntent;

    .prologue
    const/4 v4, 0x0

    .line 914
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstAddr:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 915
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Invalid destinationAddress"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 918
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mData:Ljava/util/List;

    invoke-interface {v0, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_1

    .line 919
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Invalid message data"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 922
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mSrcAddr:Ljava/lang/String;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstAddr:Ljava/lang/String;

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mDstPort:I

    int-to-short v2, v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mData:Ljava/util/List;

    invoke-interface {v3, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;
    check-cast p0, [B

    invoke-static {v0, v1, v2, p0, v4}, Landroid/telephony/gsm/SmsMessage;->getSubmitPdu(Ljava/lang/String;Ljava/lang/String;S[BZ)Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    move-result-object v6

    .line 924
    .local v6, "pdus":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    iget-object v0, v6, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedScAddress:[B

    iget-object v1, v6, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedMessage:[B

    const/4 v3, 0x0

    move-object v2, p1

    move v5, v4

    invoke-static/range {v0 .. v5}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$700([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V

    .line 925
    return-void
.end method

.method public size()I
    .locals 1

    .prologue
    .line 852
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;->mData:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    return v0
.end method
