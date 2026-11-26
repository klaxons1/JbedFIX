.class Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"


# static fields
.field private static final DEBUG:Z

.field static final DUMMY_CONTENTID:Ljava/lang/String; = "dummy"

.field static final MMS_APP_ID_FLAG:B = 0x5t

.field static final MMS_CC_ADRS_FLAG:B = 0x9t

.field static final MMS_DATE_FLAG:B = 0x6t

.field static final MMS_DELIVERY_FLAG:B = 0x3t

.field static final MMS_FROM_FLAG:B = 0x1t

.field static final MMS_PRIORITY_FLAG:B = 0x4t

.field public static final MMS_PROTOCOL:Ljava/lang/String; = "mms://"

.field static final MMS_START_CONTENT_ID_FLAG:B = 0x7t

.field static final MMS_SUBJECT_FLAG:B = 0x2t

.field static final MMS_TO_ADRS_FLAG:B = 0x8t


# instance fields
.field private mAppId:Ljava/lang/String;

.field public mContentId:Ljava/lang/String;

.field private mContext:Landroid/content/Context;

.field private mId:J

.field private mIsChecked:Z

.field private mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

.field mParts:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;",
            ">;"
        }
    .end annotation
.end field

.field private mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 631
    sget-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->DEBUG:Z

    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->DEBUG:Z

    return-void
.end method

.method constructor <init>(Landroid/content/Context;Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Landroid/net/Uri;Ljava/lang/String;)V
    .locals 7
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "manager"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    .param p3, "uri"    # Landroid/net/Uri;
    .param p4, "appId"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .prologue
    .line 687
    invoke-static {p1}, Lcom/google/android/mms/pdu/PduPersister;->getPduPersister(Landroid/content/Context;)Lcom/google/android/mms/pdu/PduPersister;

    move-result-object v0

    invoke-virtual {v0, p3}, Lcom/google/android/mms/pdu/PduPersister;->load(Landroid/net/Uri;)Lcom/google/android/mms/pdu/GenericPdu;

    move-result-object v3

    check-cast v3, Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-static {p3}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide v4

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move-object v6, p4

    invoke-direct/range {v0 .. v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;-><init>(Landroid/content/Context;Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Lcom/google/android/mms/pdu/RetrieveConf;JLjava/lang/String;)V

    .line 690
    return-void
.end method

.method constructor <init>(Landroid/content/Context;Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Lcom/google/android/mms/pdu/RetrieveConf;JLjava/lang/String;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "manager"    # Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
    .param p3, "retrieveConf"    # Lcom/google/android/mms/pdu/RetrieveConf;
    .param p4, "uriId"    # J
    .param p6, "appId"    # Ljava/lang/String;

    .prologue
    .line 676
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 673
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    .line 677
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mContext:Landroid/content/Context;

    .line 678
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    .line 679
    iput-object p3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    .line 680
    iput-wide p4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mId:J

    .line 681
    iput-object p6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mAppId:Ljava/lang/String;

    .line 683
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->buildParts()V

    .line 684
    return-void
.end method

.method private buildParts()V
    .locals 6

    .prologue
    .line 849
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v3}, Lcom/google/android/mms/pdu/RetrieveConf;->getBody()Lcom/google/android/mms/pdu/PduBody;

    move-result-object v3

    invoke-virtual {v3}, Lcom/google/android/mms/pdu/PduBody;->getPartsNum()I

    move-result v2

    .line 850
    .local v2, "partNum":I
    sget-boolean v3, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->DEBUG:Z

    if-eqz v3, :cond_0

    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "MmsMessage: buildParts() partNum ="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 851
    :cond_0
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    if-ge v0, v2, :cond_2

    .line 852
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->findEmptyIndex()I

    move-result v1

    .line 853
    .local v1, "index":I
    const/4 v3, -0x1

    if-ne v1, v3, :cond_1

    .line 854
    new-instance v3, Ljava/lang/RuntimeException;

    const-string v4, " have no memory to hold the message part!"

    invoke-direct {v3, v4}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 856
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v3, v3, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v3, v3, v1

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v4}, Lcom/google/android/mms/pdu/RetrieveConf;->getBody()Lcom/google/android/mms/pdu/PduBody;

    move-result-object v4

    invoke-virtual {v4, v0}, Lcom/google/android/mms/pdu/PduBody;->getPart(I)Lcom/google/android/mms/pdu/PduPart;

    move-result-object v4

    invoke-virtual {v3, v4}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->setPduPart(Lcom/google/android/mms/pdu/PduPart;)V

    .line 857
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v4, v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    aget-object v4, v4, v1

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 851
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 859
    .end local v1    # "index":I
    :cond_2
    return-void
.end method

.method static convertToMmsProtocolAddress(Lcom/google/android/mms/pdu/EncodedStringValue;)[B
    .locals 3
    .param p0, "esv"    # Lcom/google/android/mms/pdu/EncodedStringValue;

    .prologue
    .line 894
    invoke-virtual {p0}, Lcom/google/android/mms/pdu/EncodedStringValue;->getString()Ljava/lang/String;

    move-result-object v0

    .line 897
    .local v0, "s":Ljava/lang/String;
    const-string v1, "@"

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    const/4 v2, -0x1

    if-ne v1, v2, :cond_0

    .line 898
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "mms://"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 900
    :cond_0
    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Ljava/lang/String;)[B

    move-result-object v1

    return-object v1
.end method

.method static decodeAddress(Ljava/lang/String;)[Ljava/lang/String;
    .locals 7
    .param p0, "address"    # Ljava/lang/String;

    .prologue
    const/4 v5, 0x0

    const/4 v4, 0x1

    const/4 v3, 0x0

    const-string v6, "mms://"

    .line 756
    const/4 v2, 0x2

    new-array v1, v2, [Ljava/lang/String;

    .line 757
    .local v1, "result":[Ljava/lang/String;
    const-string v2, "mms://"

    invoke-virtual {p0, v6}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 758
    const-string v2, "mms://"

    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v2

    invoke-virtual {p0, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object p0

    .line 759
    const-string v2, ":"

    invoke-virtual {p0, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v0

    .line 760
    .local v0, "pos":I
    const/4 v2, -0x1

    if-eq v0, v2, :cond_0

    .line 761
    invoke-virtual {p0, v3, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v2

    aput-object v2, v1, v3

    .line 762
    add-int/lit8 v2, v0, 0x1

    invoke-virtual {p0, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2

    aput-object v2, v1, v4

    .line 773
    .end local v0    # "pos":I
    :goto_0
    return-object v1

    .line 765
    .restart local v0    # "pos":I
    :cond_0
    aput-object p0, v1, v3

    .line 766
    aput-object v5, v1, v4

    goto :goto_0

    .line 770
    .end local v0    # "pos":I
    :cond_1
    aput-object p0, v1, v3

    .line 771
    aput-object v5, v1, v4

    goto :goto_0
.end method

.method static getFromAddress(Lcom/google/android/mms/pdu/RetrieveConf;)[B
    .locals 3
    .param p0, "retrieveConf"    # Lcom/google/android/mms/pdu/RetrieveConf;

    .prologue
    .line 904
    if-eqz p0, :cond_0

    invoke-virtual {p0}, Lcom/google/android/mms/pdu/RetrieveConf;->getFrom()Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v1

    if-nez v1, :cond_1

    .line 905
    :cond_0
    const/4 v1, 0x0

    .line 916
    :goto_0
    return-object v1

    .line 907
    :cond_1
    invoke-virtual {p0}, Lcom/google/android/mms/pdu/RetrieveConf;->getFrom()Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v1

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/EncodedStringValue;->getString()Ljava/lang/String;

    move-result-object v0

    .line 910
    .local v0, "fromAddr":Ljava/lang/String;
    const-string v1, "@"

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v1

    const/4 v2, -0x1

    if-ne v1, v2, :cond_2

    .line 911
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "mms://"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 916
    :cond_2
    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Ljava/lang/String;)[B

    move-result-object v1

    goto :goto_0
.end method

.method static getStartContentId([Ljava/lang/String;)Ljava/lang/String;
    .locals 4
    .param p0, "headerFields"    # [Ljava/lang/String;

    .prologue
    .line 839
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    array-length v3, p0

    if-ge v0, v3, :cond_1

    .line 840
    aget-object v1, p0, v0

    .line 841
    .local v1, "name":Ljava/lang/String;
    add-int/lit8 v3, v0, 0x1

    aget-object v2, p0, v3

    .line 842
    .local v2, "value":Ljava/lang/String;
    const-string v3, "StartContentId"

    invoke-virtual {v1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    move-object v3, v2

    .line 845
    .end local v1    # "name":Ljava/lang/String;
    .end local v2    # "value":Ljava/lang/String;
    :goto_1
    return-object v3

    .line 839
    .restart local v1    # "name":Ljava/lang/String;
    .restart local v2    # "value":Ljava/lang/String;
    :cond_0
    add-int/lit8 v0, v0, 0x2

    goto :goto_0

    .line 845
    .end local v1    # "name":Ljava/lang/String;
    .end local v2    # "value":Ljava/lang/String;
    :cond_1
    const/4 v3, 0x0

    goto :goto_1
.end method

.method private static getUtf8Bytes(Lcom/google/android/mms/pdu/EncodedStringValue;)[B
    .locals 4
    .param p0, "s"    # Lcom/google/android/mms/pdu/EncodedStringValue;

    .prologue
    const/4 v3, 0x0

    .line 882
    if-eqz p0, :cond_0

    :try_start_0
    invoke-virtual {p0}, Lcom/google/android/mms/pdu/EncodedStringValue;->getString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_1

    :cond_0
    move-object v1, v3

    .line 887
    :goto_0
    return-object v1

    .line 884
    :cond_1
    invoke-virtual {p0}, Lcom/google/android/mms/pdu/EncodedStringValue;->getString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "utf-8"

    invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    goto :goto_0

    .line 885
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 886
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v2, "getUtf8Bytes UnsupportedEncodingException"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    move-object v1, v3

    .line 887
    goto :goto_0
.end method

.method private static getUtf8Bytes(Ljava/lang/String;)[B
    .locals 4
    .param p0, "s"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    .line 871
    :try_start_0
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v1

    if-nez v1, :cond_0

    move-object v1, v3

    .line 876
    :goto_0
    return-object v1

    .line 873
    :cond_0
    const-string v1, "utf-8"

    invoke-virtual {p0, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v1

    goto :goto_0

    .line 874
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 875
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v2, "getUtf8Bytes UnsupportedEncodingException"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    move-object v1, v3

    .line 876
    goto :goto_0
.end method

.method static send(Landroid/content/Context;[Ljava/lang/String;Lcom/google/android/mms/pdu/PduBody;)Landroid/net/Uri;
    .locals 8
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "headerFields"    # [Ljava/lang/String;
    .param p2, "body"    # Lcom/google/android/mms/pdu/PduBody;

    .prologue
    .line 730
    new-instance v3, Lcom/google/android/mms/pdu/SendReq;

    invoke-direct {v3}, Lcom/google/android/mms/pdu/SendReq;-><init>()V

    .line 731
    .local v3, "request":Lcom/google/android/mms/pdu/SendReq;
    invoke-static {v3, p1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->setHeaderFields(Lcom/google/android/mms/pdu/SendReq;[Ljava/lang/String;)V

    .line 732
    invoke-virtual {v3, p2}, Lcom/google/android/mms/pdu/SendReq;->setBody(Lcom/google/android/mms/pdu/PduBody;)V

    .line 733
    const/4 v4, 0x0

    .line 735
    .local v4, "uri":Landroid/net/Uri;
    :try_start_0
    invoke-static {p0}, Lcom/google/android/mms/pdu/PduPersister;->getPduPersister(Landroid/content/Context;)Lcom/google/android/mms/pdu/PduPersister;

    move-result-object v5

    sget-object v6, Landroid/provider/Telephony$Mms$Outbox;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v5, v3, v6}, Lcom/google/android/mms/pdu/PduPersister;->persist(Lcom/google/android/mms/pdu/GenericPdu;Landroid/net/Uri;)Landroid/net/Uri;
    :try_end_0
    .catch Lcom/google/android/mms/MmsException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v4

    .line 740
    new-instance v5, Landroid/content/Intent;

    invoke-direct {v5}, Landroid/content/Intent;-><init>()V

    const-string v6, "com.android.mms"

    const-string v7, "com.android.mms.transaction.TransactionService"

    invoke-virtual {v5, v6, v7}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    move-result-object v2

    .line 742
    .local v2, "intent":Landroid/content/Intent;
    new-instance v0, Landroid/os/Bundle;

    invoke-direct {v0}, Landroid/os/Bundle;-><init>()V

    .line 743
    .local v0, "bundle":Landroid/os/Bundle;
    const-string v5, "type"

    const/4 v6, 0x2

    invoke-virtual {v0, v5, v6}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V

    .line 744
    const-string v5, "uri"

    invoke-virtual {v4}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v0, v5, v6}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 745
    invoke-virtual {v2, v0}, Landroid/content/Intent;->putExtras(Landroid/os/Bundle;)Landroid/content/Intent;

    .line 746
    sget-boolean v5, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->DEBUG:Z

    if-eqz v5, :cond_0

    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v6, "Starting service"

    invoke-static {v5, v6}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    .line 747
    :cond_0
    invoke-virtual {p0, v2}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    .line 748
    sget-boolean v5, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->DEBUG:Z

    if-eqz v5, :cond_1

    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v6, "Service started"

    invoke-static {v5, v6}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    :cond_1
    move-object v5, v4

    .line 749
    .end local v0    # "bundle":Landroid/os/Bundle;
    .end local v2    # "intent":Landroid/content/Intent;
    :goto_0
    return-object v5

    .line 736
    :catch_0
    move-exception v5

    move-object v1, v5

    .line 737
    .local v1, "e":Lcom/google/android/mms/MmsException;
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v6, "failed to send mms "

    invoke-static {v5, v6, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 738
    const/4 v5, 0x0

    goto :goto_0
.end method

.method private static setHeaderFields(Lcom/google/android/mms/pdu/SendReq;[Ljava/lang/String;)V
    .locals 11
    .param p0, "request"    # Lcom/google/android/mms/pdu/SendReq;
    .param p1, "headerFields"    # [Ljava/lang/String;

    .prologue
    const/4 v10, 0x1

    const/4 v9, 0x0

    const/16 v8, 0x6a

    .line 777
    const/4 v3, 0x0

    .local v3, "i":I
    :goto_0
    array-length v6, p1

    if-ge v3, v6, :cond_a

    .line 778
    aget-object v4, p1, v3

    .line 779
    .local v4, "name":Ljava/lang/String;
    add-int/lit8 v6, v3, 0x1

    aget-object v5, p1, v6

    .line 780
    .local v5, "value":Ljava/lang/String;
    new-instance v2, Lcom/google/android/mms/pdu/EncodedStringValue;

    invoke-virtual {v5}, Ljava/lang/String;->getBytes()[B

    move-result-object v6

    invoke-direct {v2, v8, v6}, Lcom/google/android/mms/pdu/EncodedStringValue;-><init>(I[B)V

    .line 783
    .local v2, "encodingValue":Lcom/google/android/mms/pdu/EncodedStringValue;
    const-string v6, "X-Mms-Delivery-Time"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_1

    .line 785
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v7, "WARNING: android doesn\'t support X-Mms-Delivery-Time"

    invoke-static {v6, v7}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 777
    :cond_0
    :goto_1
    add-int/lit8 v3, v3, 0x2

    goto :goto_0

    .line 786
    :cond_1
    const-string v6, "StartContentId"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-nez v6, :cond_0

    .line 788
    const-string v6, "X-Mms-To"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_2

    .line 789
    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->decodeAddress(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 790
    .local v0, "addr":[Ljava/lang/String;
    new-instance v6, Lcom/google/android/mms/pdu/EncodedStringValue;

    aget-object v7, v0, v9

    invoke-virtual {v7}, Ljava/lang/String;->getBytes()[B

    move-result-object v7

    invoke-direct {v6, v8, v7}, Lcom/google/android/mms/pdu/EncodedStringValue;-><init>(I[B)V

    invoke-virtual {p0, v6}, Lcom/google/android/mms/pdu/SendReq;->addTo(Lcom/google/android/mms/pdu/EncodedStringValue;)V

    .line 798
    aget-object v6, v0, v10

    if-eqz v6, :cond_0

    goto :goto_1

    .line 802
    .end local v0    # "addr":[Ljava/lang/String;
    :cond_2
    const-string v6, "X-Mms-CC"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_3

    .line 803
    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->decodeAddress(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 804
    .restart local v0    # "addr":[Ljava/lang/String;
    new-instance v6, Lcom/google/android/mms/pdu/EncodedStringValue;

    aget-object v7, v0, v9

    invoke-virtual {v7}, Ljava/lang/String;->getBytes()[B

    move-result-object v7

    invoke-direct {v6, v8, v7}, Lcom/google/android/mms/pdu/EncodedStringValue;-><init>(I[B)V

    invoke-virtual {p0, v6}, Lcom/google/android/mms/pdu/SendReq;->addCc(Lcom/google/android/mms/pdu/EncodedStringValue;)V

    goto :goto_1

    .line 806
    .end local v0    # "addr":[Ljava/lang/String;
    :cond_3
    const-string v6, "X-Mms-BCC"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_4

    .line 807
    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->decodeAddress(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 808
    .restart local v0    # "addr":[Ljava/lang/String;
    new-instance v6, Lcom/google/android/mms/pdu/EncodedStringValue;

    aget-object v7, v0, v9

    invoke-virtual {v7}, Ljava/lang/String;->getBytes()[B

    move-result-object v7

    invoke-direct {v6, v8, v7}, Lcom/google/android/mms/pdu/EncodedStringValue;-><init>(I[B)V

    invoke-virtual {p0, v6}, Lcom/google/android/mms/pdu/SendReq;->addBcc(Lcom/google/android/mms/pdu/EncodedStringValue;)V

    goto :goto_1

    .line 810
    .end local v0    # "addr":[Ljava/lang/String;
    :cond_4
    const-string v6, "X-Mms-From"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_5

    .line 812
    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->decodeAddress(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    .line 814
    .restart local v0    # "addr":[Ljava/lang/String;
    aget-object v6, v0, v10

    if-eqz v6, :cond_0

    goto :goto_1

    .line 818
    .end local v0    # "addr":[Ljava/lang/String;
    :cond_5
    const-string v6, "X-Mms-Priority"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_6

    .line 820
    :try_start_0
    invoke-static {v5}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v6

    invoke-virtual {p0, v6}, Lcom/google/android/mms/pdu/SendReq;->setPriority(I)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 821
    :catch_0
    move-exception v6

    move-object v1, v6

    .line 822
    .local v1, "e":Ljava/lang/Exception;
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v7, "failed to setPriority"

    invoke-static {v6, v7, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto/16 :goto_1

    .line 824
    .end local v1    # "e":Ljava/lang/Exception;
    :cond_6
    const-string v6, "X-Mms-Subject"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_7

    .line 825
    invoke-virtual {p0, v2}, Lcom/google/android/mms/pdu/SendReq;->setSubject(Lcom/google/android/mms/pdu/EncodedStringValue;)V

    goto/16 :goto_1

    .line 826
    :cond_7
    const-string v6, "Date"

    invoke-virtual {v4, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_9

    .line 827
    const-string v6, "unknown"

    invoke-virtual {v5, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_8

    .line 828
    new-instance v6, Ljava/util/Date;

    invoke-direct {v6}, Ljava/util/Date;-><init>()V

    invoke-virtual {v6}, Ljava/util/Date;->getTime()J

    move-result-wide v6

    invoke-virtual {p0, v6, v7}, Lcom/google/android/mms/pdu/SendReq;->setDate(J)V

    goto/16 :goto_1

    .line 830
    :cond_8
    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v6

    if-lez v6, :cond_0

    .line 831
    invoke-static {v5}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v6

    invoke-virtual {p0, v6, v7}, Lcom/google/android/mms/pdu/SendReq;->setDate(J)V

    goto/16 :goto_1

    .line 833
    :cond_9
    new-instance v6, Ljava/lang/IllegalArgumentException;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "unknow field "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-direct {v6, v7}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v6

    .line 836
    .end local v2    # "encodingValue":Lcom/google/android/mms/pdu/EncodedStringValue;
    .end local v4    # "name":Ljava/lang/String;
    .end local v5    # "value":Ljava/lang/String;
    :cond_a
    return-void
.end method

.method private writeString(Ljava/io/DataOutputStream;B[B)V
    .locals 1
    .param p1, "out"    # Ljava/io/DataOutputStream;
    .param p2, "flag"    # B
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 862
    if-eqz p3, :cond_0

    .line 863
    invoke-virtual {p1, p2}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 864
    invoke-virtual {p1, p3}, Ljava/io/DataOutputStream;->write([B)V

    .line 865
    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 867
    :cond_0
    return-void
.end method


# virtual methods
.method public dispose()V
    .locals 4

    .prologue
    .line 722
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 723
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mManager:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->mPartStore:[Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    iget v1, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mIndex:I

    const/4 v3, 0x0

    aput-object v3, v2, v1

    .line 722
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 725
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 726
    return-void
.end method

.method public getAppId()Ljava/lang/String;
    .locals 1

    .prologue
    .line 705
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mAppId:Ljava/lang/String;

    return-object v0
.end method

.method public getFrom()[B
    .locals 1

    .prologue
    .line 701
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getFromAddress(Lcom/google/android/mms/pdu/RetrieveConf;)[B

    move-result-object v0

    return-object v0
.end method

.method public getId()I
    .locals 2

    .prologue
    .line 711
    iget-wide v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mId:J

    long-to-int v0, v0

    return v0
.end method

.method public getPart(I)Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    .locals 1
    .param p1, "arrayIndex"    # I

    .prologue
    .line 715
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    if-lt p1, v0, :cond_0

    .line 716
    const/4 v0, 0x0

    .line 718
    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :goto_0
    return-object v0

    .restart local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mParts:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;
    check-cast p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    move-object v0, p0

    goto :goto_0
.end method

.method public isChecked()Z
    .locals 1

    .prologue
    .line 697
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mIsChecked:Z

    return v0
.end method

.method public setCheck(Z)V
    .locals 0
    .param p1, "isChecked"    # Z

    .prologue
    .line 693
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mIsChecked:Z

    .line 694
    return-void
.end method

.method toBytes()[B
    .locals 8

    .prologue
    .line 921
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 922
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 925
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getId()I

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 926
    const/4 v5, 0x2

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/RetrieveConf;->getSubject()Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v6

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Lcom/google/android/mms/pdu/EncodedStringValue;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 927
    const/4 v5, 0x1

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getFromAddress(Lcom/google/android/mms/pdu/RetrieveConf;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 928
    const/4 v5, 0x6

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/RetrieveConf;->getDate()J

    move-result-wide v6

    invoke-static {v6, v7}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Ljava/lang/String;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 929
    const/4 v5, 0x4

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/RetrieveConf;->getPriority()I

    move-result v6

    invoke-static {v6}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Ljava/lang/String;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 932
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/RetrieveConf;->getBody()Lcom/google/android/mms/pdu/PduBody;

    move-result-object v5

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/PduBody;->getPartsNum()I

    move-result v5

    if-lez v5, :cond_0

    .line 933
    new-instance v5, Ljava/lang/String;

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/RetrieveConf;->getBody()Lcom/google/android/mms/pdu/PduBody;

    move-result-object v6

    const/4 v7, 0x0

    invoke-virtual {v6, v7}, Lcom/google/android/mms/pdu/PduBody;->getPart(I)Lcom/google/android/mms/pdu/PduPart;

    move-result-object v6

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/PduPart;->getContentId()[B

    move-result-object v6

    invoke-direct {v5, v6}, Ljava/lang/String;-><init>([B)V

    iput-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mContentId:Ljava/lang/String;

    .line 934
    const/4 v5, 0x7

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mContentId:Ljava/lang/String;

    invoke-virtual {v6}, Ljava/lang/String;->getBytes()[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 936
    :cond_0
    const/4 v5, 0x5

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mAppId:Ljava/lang/String;

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->getUtf8Bytes(Ljava/lang/String;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 940
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/RetrieveConf;->getTo()[Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v4

    .line 941
    .local v4, "tmp":[Lcom/google/android/mms/pdu/EncodedStringValue;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    if-eqz v4, :cond_1

    array-length v5, v4

    if-ge v2, v5, :cond_1

    .line 942
    const/16 v5, 0x8

    aget-object v6, v4, v2

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->convertToMmsProtocolAddress(Lcom/google/android/mms/pdu/EncodedStringValue;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 941
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 945
    :cond_1
    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/RetrieveConf;->getCc()[Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v4

    .line 946
    const/4 v2, 0x0

    :goto_1
    if-eqz v4, :cond_2

    array-length v5, v4

    if-ge v2, v5, :cond_2

    .line 947
    const/16 v5, 0x9

    aget-object v6, v4, v2

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->convertToMmsProtocolAddress(Lcom/google/android/mms/pdu/EncodedStringValue;)[B

    move-result-object v6

    invoke-direct {p0, v3, v5, v6}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->writeString(Ljava/io/DataOutputStream;B[B)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 946
    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 950
    .end local v2    # "i":I
    .end local v4    # "tmp":[Lcom/google/android/mms/pdu/EncodedStringValue;
    :catch_0
    move-exception v5

    move-object v1, v5

    .line 951
    .local v1, "e":Ljava/lang/Exception;
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v6, " failed to convert the mms message to bytes"

    invoke-static {v5, v6, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 952
    const/4 v5, 0x0

    .line 954
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_2
    return-object v5

    .restart local v2    # "i":I
    .restart local v4    # "tmp":[Lcom/google/android/mms/pdu/EncodedStringValue;
    :cond_2
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v5

    goto :goto_2
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    .prologue
    .line 959
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "id="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-wide v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mId:J

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " subject="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/RetrieveConf;->getSubject()Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " from="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/RetrieveConf;->getFrom()Lcom/google/android/mms/pdu/EncodedStringValue;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " date="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/RetrieveConf;->getDate()J

    move-result-wide v1

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " priority="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessage;->mRetrieveConf:Lcom/google/android/mms/pdu/RetrieveConf;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/RetrieveConf;->getPriority()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
