.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;
.super Ljava/lang/Object;
.source "JbedSmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "JbedSmsSender"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;,
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;,
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
    }
.end annotation


# static fields
.field private static final MAX_USER_DATA_BYTES:I = 0x8c

.field private static final MAX_USER_DATA_BYTES_LONG_PORT_SMS:I = 0x80

.field private static final MAX_USER_DATA_BYTES_PORT_SMS:I = 0x84

.field private static final MAX_USER_DATA_SEPTETS:I = 0xa0

.field private static final MAX_USER_DATA_SEPTETS_LONG_PORT_SMS:I = 0x92

.field private static final MAX_USER_DATA_SEPTETS_PORT_SMS:I = 0x99


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 385
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 842
    return-void
.end method

.method static synthetic access$600(III)[B
    .locals 1
    .param p0, "x0"    # I
    .param p1, "x1"    # I
    .param p2, "x2"    # I

    .prologue
    .line 385
    invoke-static {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->getConcatenatedData(III)[B

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$700([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V
    .locals 0
    .param p0, "x0"    # [B
    .param p1, "x1"    # [B
    .param p2, "x2"    # Landroid/app/PendingIntent;
    .param p3, "x3"    # Landroid/app/PendingIntent;
    .param p4, "x4"    # Z
    .param p5, "x5"    # Z

    .prologue
    .line 385
    invoke-static/range {p0 .. p5}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->sendRawPdu([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V

    return-void
.end method

.method static synthetic access$800(Ljava/lang/String;Ljava/lang/String;BZLandroid/telephony/gsm/SmsMessage$SubmitPdu;)Ljava/io/ByteArrayOutputStream;
    .locals 1
    .param p0, "x0"    # Ljava/lang/String;
    .param p1, "x1"    # Ljava/lang/String;
    .param p2, "x2"    # B
    .param p3, "x3"    # Z
    .param p4, "x4"    # Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    .prologue
    .line 385
    invoke-static {p0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;->getSubmitPduHead(Ljava/lang/String;Ljava/lang/String;BZLandroid/telephony/gsm/SmsMessage$SubmitPdu;)Ljava/io/ByteArrayOutputStream;

    move-result-object v0

    return-object v0
.end method

.method private static getConcatenatedData(III)[B
    .locals 3
    .param p0, "refId"    # I
    .param p1, "totalParts"    # I
    .param p2, "currentPart"    # I

    .prologue
    .line 421
    const/4 v1, 0x3

    new-array v0, v1, [B

    .line 422
    .local v0, "data":[B
    const/4 v1, 0x0

    int-to-byte v2, p0

    aput-byte v2, v0, v1

    .line 423
    const/4 v1, 0x1

    int-to-byte v2, p1

    aput-byte v2, v0, v1

    .line 424
    const/4 v1, 0x2

    add-int/lit8 v2, p2, 0x1

    int-to-byte v2, v2

    aput-byte v2, v0, v1

    .line 426
    return-object v0
.end method

.method private static getSubmitPduHead(Ljava/lang/String;Ljava/lang/String;BZLandroid/telephony/gsm/SmsMessage$SubmitPdu;)Ljava/io/ByteArrayOutputStream;
    .locals 7
    .param p0, "scAddress"    # Ljava/lang/String;
    .param p1, "destinationAddress"    # Ljava/lang/String;
    .param p2, "mtiByte"    # B
    .param p3, "statusReportRequested"    # Z
    .param p4, "ret"    # Landroid/telephony/gsm/SmsMessage$SubmitPdu;

    .prologue
    const/4 v6, 0x1

    const/4 v5, 0x0

    .line 480
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    const/16 v2, 0xb4

    invoke-direct {v0, v2}, Ljava/io/ByteArrayOutputStream;-><init>(I)V

    .line 483
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    if-nez p0, :cond_1

    .line 484
    const/4 v2, 0x0

    iput-object v2, p4, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedScAddress:[B

    .line 490
    :goto_0
    if-eqz p3, :cond_0

    .line 492
    or-int/lit8 v2, p2, 0x20

    int-to-byte p2, v2

    .line 494
    :cond_0
    invoke-virtual {v0, p2}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 497
    invoke-virtual {v0, v5}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 501
    invoke-static {p1}, Landroid/telephony/PhoneNumberUtils;->networkPortionToCalledPartyBCD(Ljava/lang/String;)[B

    move-result-object v1

    .line 506
    .local v1, "daBytes":[B
    array-length v2, v1

    sub-int/2addr v2, v6

    mul-int/lit8 v2, v2, 0x2

    array-length v3, v1

    sub-int/2addr v3, v6

    aget-byte v3, v1, v3

    and-int/lit16 v3, v3, 0xf0

    const/16 v4, 0xf0

    if-ne v3, v4, :cond_2

    move v3, v6

    :goto_1
    sub-int/2addr v2, v3

    invoke-virtual {v0, v2}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 509
    array-length v2, v1

    invoke-virtual {v0, v1, v5, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    .line 512
    invoke-virtual {v0, v5}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 513
    return-object v0

    .line 486
    .end local v1    # "daBytes":[B
    :cond_1
    invoke-static {p0}, Landroid/telephony/PhoneNumberUtils;->networkPortionToCalledPartyBCDWithLength(Ljava/lang/String;)[B

    move-result-object v2

    iput-object v2, p4, Landroid/telephony/gsm/SmsMessage$SubmitPdu;->encodedScAddress:[B

    goto :goto_0

    .restart local v1    # "daBytes":[B
    :cond_2
    move v3, v5

    .line 506
    goto :goto_1
.end method

.method private static sendRawPdu([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V
    .locals 7
    .param p0, "smsc"    # [B
    .param p1, "pdu"    # [B
    .param p2, "sentIntent"    # Landroid/app/PendingIntent;
    .param p3, "deliveryIntent"    # Landroid/app/PendingIntent;
    .param p4, "bFirstOfAll"    # Z
    .param p5, "bLastOfAll"    # Z

    .prologue
    .line 455
    :try_start_0
    const-string v1, "isms"

    invoke-static {v1}, Landroid/os/ServiceManager;->getService(Ljava/lang/String;)Landroid/os/IBinder;

    move-result-object v1

    invoke-static {v1}, Lcom/android/internal/telephony/ISms$Stub;->asInterface(Landroid/os/IBinder;)Lcom/android/internal/telephony/ISms;

    move-result-object v0

    .line 456
    .local v0, "simISms":Lcom/android/internal/telephony/ISms;
    if-eqz v0, :cond_0

    move-object v1, p0

    move-object v2, p1

    move-object v3, p2

    move-object v4, p3

    move v5, p4

    move v6, p5

    .line 457
    invoke-interface/range {v0 .. v6}, Lcom/android/internal/telephony/ISms;->sendRawPdu([B[BLandroid/app/PendingIntent;Landroid/app/PendingIntent;ZZ)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 462
    .end local v0    # "simISms":Lcom/android/internal/telephony/ISms;
    :cond_0
    :goto_0
    return-void

    .line 459
    :catch_0
    move-exception v1

    goto :goto_0
.end method
