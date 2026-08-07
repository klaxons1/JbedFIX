.class abstract Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
.super Ljava/lang/Object;
.source "JbedSmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x40a
    name = "SmsData"
.end annotation


# instance fields
.field protected mDstAddr:Ljava/lang/String;

.field protected mDstPort:I

.field protected mSrcAddr:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;ILjava/lang/String;)V
    .locals 0
    .param p1, "dstAddr"    # Ljava/lang/String;
    .param p2, "dstPort"    # I
    .param p3, "srcAddr"    # Ljava/lang/String;

    .prologue
    .line 521
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 522
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mDstAddr:Ljava/lang/String;

    .line 523
    iput p2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mDstPort:I

    .line 524
    iput-object p3, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mSrcAddr:Ljava/lang/String;

    .line 525
    return-void
.end method


# virtual methods
.method abstract getSubmitPdu(I[B)Landroid/telephony/gsm/SmsMessage$SubmitPdu;
.end method

.method hasPort()Z
    .locals 2

    .prologue
    .line 561
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mDstPort:I

    const/4 v1, -0x1

    if-eq v0, v1, :cond_0

    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mDstPort:I

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public abstract sendByDefault(Ljava/util/List;)V
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Landroid/app/PendingIntent;",
            ">;)V"
        }
    .end annotation
.end method

.method public sendMultipartMessage(Ljava/util/List;)V
    .locals 12
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
    const/4 v4, 0x0

    .line 536
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->mDstAddr:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 537
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Invalid destinationAddress"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 539
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->size()I

    move-result v0

    if-nez v0, :cond_1

    .line 540
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Invalid message body"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 543
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->hasPort()Z

    move-result v0

    if-nez v0, :cond_3

    .line 545
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->sendByDefault(Ljava/util/List;)V

    .line 558
    :cond_2
    return-void

    .line 547
    :cond_3
    new-instance v0, Ljava/util/Random;

    invoke-direct {v0}, Ljava/util/Random;-><init>()V

    const/16 v1, 0x100

    invoke-virtual {v0, v1}, Ljava/util/Random;->nextInt(I)I

    move-result v11

    .line 548
    .local v11, "sConcatenatedRef":I
    add-int/lit8 v11, v11, 0x1

    and-int/lit16 v10, v11, 0xff

    .line 550
    .local v10, "ref":I
    const/4 v8, 0x0

    .local v8, "i":I
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->size()I

    move-result v7

    .local v7, "count":I
    :goto_0
    if-ge v8, v7, :cond_2

    .line 551
    invoke-static {v10, v7, v8}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$600(III)[B

    move-result-object v6

    .line 553
    .local v6, "concatenatedInfo":[B
    invoke-virtual {p0, v8, v6}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->getSubmitPdu(I[B)Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    move-result-object v9

    .line 555
    .local v9, "pdus":Landroid/telephony/gsm/SmsMessage$SubmitPdu;
    iget-object v0, v9, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedScAddress:[B

    iget-object v1, v9, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedMessage:[B

    invoke-interface {p1, v8}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/app/PendingIntent;

    const/4 v3, 0x0

    move v5, v4

    invoke-static/range {v0 .. v5}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->access$700([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V

    .line 550
    add-int/lit8 v8, v8, 0x1

    goto :goto_0
.end method

.method public abstract sendSinglepartMessage(Landroid/app/PendingIntent;)V
.end method

.method public abstract size()I
.end method
