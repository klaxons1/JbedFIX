.class Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;
    }
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z

.field static final MMS_CONTENTID_INDEX:B = 0x0t

.field static final MMS_ENCODING_INDEX:B = 0x3t

.field static final MMS_LOCATION_INDEX:B = 0x2t

.field static final MMS_MIMETYPE_INDEX:B = 0x1t


# instance fields
.field private mContext:Landroid/content/Context;

.field private mData:[B

.field mHeaderFields:[Ljava/lang/String;

.field mIndex:I

.field private mPduPart:Lcom/google/android/mms/pdu/PduPart;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 964
    const-class v0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->$assertionsDisabled:Z

    return-void

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method constructor <init>(Landroid/content/Context;I)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "index"    # I

    .prologue
    .line 998
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 976
    const/4 v0, 0x4

    new-array v0, v0, [Ljava/lang/String;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    .line 999
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mContext:Landroid/content/Context;

    .line 1000
    iput p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mIndex:I

    .line 1001
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;)Lcom/google/android/mms/pdu/PduPart;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .prologue
    .line 964
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    return-object v0
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
    .line 1136
    if-nez p3, :cond_0

    .line 1137
    const-string v0, "null"

    invoke-virtual {v0}, Ljava/lang/String;->getBytes()[B

    move-result-object p3

    .line 1138
    :cond_0
    invoke-virtual {p1, p2}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 1139
    invoke-virtual {p1, p3}, Ljava/io/DataOutputStream;->write([B)V

    .line 1140
    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Ljava/io/DataOutputStream;->writeByte(I)V

    .line 1141
    return-void
.end method


# virtual methods
.method public fillPduPart()V
    .locals 4

    .prologue
    .line 1039
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    if-nez v1, :cond_0

    .line 1040
    new-instance v1, Lcom/google/android/mms/pdu/PduPart;

    invoke-direct {v1}, Lcom/google/android/mms/pdu/PduPart;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    .line 1042
    :cond_0
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    const/4 v3, 0x3

    aget-object v2, v2, v3

    invoke-virtual {v2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/google/android/mms/pdu/CharacterSets;->getMibEnumValue(Ljava/lang/String;)I

    move-result v2

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setCharset(I)V
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    .line 1047
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    const/4 v3, 0x0

    aget-object v2, v2, v3

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setContentId([B)V

    .line 1048
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    const/4 v3, 0x1

    aget-object v2, v2, v3

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setContentType([B)V

    .line 1049
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mHeaderFields:[Ljava/lang/String;

    const/4 v3, 0x2

    aget-object v2, v2, v3

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setContentLocation([B)V

    .line 1050
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setData([B)V

    .line 1051
    return-void

    .line 1043
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 1045
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    const/16 v2, 0x6a

    invoke-virtual {v1, v2}, Lcom/google/android/mms/pdu/PduPart;->setCharset(I)V

    goto :goto_0
.end method

.method public getDataLength()I
    .locals 10

    .prologue
    const/4 v9, 0x0

    .line 1062
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    if-eqz v6, :cond_0

    .line 1063
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    array-length v6, v6

    .line 1096
    :goto_0
    return v6

    .line 1064
    :cond_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    if-eqz v6, :cond_7

    .line 1065
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/PduPart;->getData()[B

    move-result-object v2

    .line 1067
    .local v2, "data":[B
    if-eqz v2, :cond_1

    .line 1068
    array-length v6, v2

    goto :goto_0

    .line 1071
    :cond_1
    const/4 v4, 0x0

    .line 1073
    .local v4, "is":Ljava/io/InputStream;
    :try_start_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mContext:Landroid/content/Context;

    invoke-virtual {v6}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v7}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v7

    invoke-virtual {v6, v7}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v4

    .line 1074
    const/16 v6, 0x1fa0

    new-array v0, v6, [B

    .line 1075
    .local v0, "buf":[B
    const/4 v1, -0x1

    .line 1076
    .local v1, "bytesRead":I
    const/4 v5, 0x0

    .line 1077
    .local v5, "totalRead":I
    :goto_1
    invoke-virtual {v4, v0}, Ljava/io/InputStream;->read([B)I
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result v1

    const/4 v6, -0x1

    if-eq v1, v6, :cond_2

    .line 1078
    add-int/2addr v5, v1

    goto :goto_1

    .line 1088
    :cond_2
    if-eqz v4, :cond_3

    .line 1090
    :try_start_1
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_2

    :cond_3
    :goto_2
    move v6, v5

    .line 1091
    goto :goto_0

    .line 1081
    .end local v0    # "buf":[B
    .end local v1    # "bytesRead":I
    .end local v5    # "totalRead":I
    :catch_0
    move-exception v6

    move-object v3, v6

    .line 1082
    .local v3, "e":Ljava/io/FileNotFoundException;
    :try_start_2
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "failed to find "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v8}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v8}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 1088
    if-eqz v4, :cond_4

    .line 1090
    :try_start_3
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_3

    :cond_4
    :goto_3
    move v6, v9

    .line 1091
    goto :goto_0

    .line 1084
    .end local v3    # "e":Ljava/io/FileNotFoundException;
    :catch_1
    move-exception v6

    move-object v3, v6

    .line 1085
    .local v3, "e":Ljava/io/IOException;
    :try_start_4
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "failed to read "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v8}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v8}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 1088
    if-eqz v4, :cond_5

    .line 1090
    :try_start_5
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_4

    :cond_5
    :goto_4
    move v6, v9

    .line 1091
    goto/16 :goto_0

    .line 1088
    .end local v3    # "e":Ljava/io/IOException;
    :catchall_0
    move-exception v6

    if-eqz v4, :cond_6

    .line 1090
    :try_start_6
    invoke-virtual {v4}, Ljava/io/InputStream;->close()V
    :try_end_6
    .catch Ljava/io/IOException; {:try_start_6 .. :try_end_6} :catch_5

    .line 1091
    :cond_6
    :goto_5
    throw v6

    .end local v2    # "data":[B
    .end local v4    # "is":Ljava/io/InputStream;
    :cond_7
    move v6, v9

    .line 1096
    goto/16 :goto_0

    .line 1091
    .restart local v0    # "buf":[B
    .restart local v1    # "bytesRead":I
    .restart local v2    # "data":[B
    .restart local v4    # "is":Ljava/io/InputStream;
    .restart local v5    # "totalRead":I
    :catch_2
    move-exception v6

    goto :goto_2

    .end local v0    # "buf":[B
    .end local v1    # "bytesRead":I
    .end local v5    # "totalRead":I
    .local v3, "e":Ljava/io/FileNotFoundException;
    :catch_3
    move-exception v6

    goto :goto_3

    .local v3, "e":Ljava/io/IOException;
    :catch_4
    move-exception v6

    goto :goto_4

    .end local v3    # "e":Ljava/io/IOException;
    :catch_5
    move-exception v7

    goto :goto_5
.end method

.method public getPduPart()Lcom/google/android/mms/pdu/PduPart;
    .locals 1

    .prologue
    .line 1058
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    return-object v0
.end method

.method loadData()[B
    .locals 10

    .prologue
    const/4 v9, 0x0

    const-string v6, "failed to find "

    .line 1100
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v6}, Lcom/google/android/mms/pdu/PduPart;->getData()[B

    move-result-object v5

    .line 1102
    .local v5, "result":[B
    if-nez v5, :cond_2

    .line 1103
    const/4 v3, 0x0

    .line 1105
    .local v3, "is":Ljava/io/InputStream;
    :try_start_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mContext:Landroid/content/Context;

    invoke-virtual {v6}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v6

    iget-object v7, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v7}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v7

    invoke-virtual {v6, v7}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;

    move-result-object v3

    .line 1106
    new-instance v4, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v4}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 1107
    .local v4, "os":Ljava/io/ByteArrayOutputStream;
    const/16 v6, 0x1fa0

    new-array v0, v6, [B

    .line 1108
    .local v0, "buf":[B
    const/4 v1, -0x1

    .line 1111
    .local v1, "bytesRead":I
    :goto_0
    invoke-virtual {v3, v0}, Ljava/io/InputStream;->read([B)I

    move-result v1

    const/4 v6, -0x1

    if-eq v1, v6, :cond_1

    .line 1112
    const/4 v6, 0x0

    invoke-virtual {v4, v0, v6, v1}, Ljava/io/ByteArrayOutputStream;->write([BII)V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 1115
    .end local v0    # "buf":[B
    .end local v1    # "bytesRead":I
    .end local v4    # "os":Ljava/io/ByteArrayOutputStream;
    :catch_0
    move-exception v6

    move-object v2, v6

    .line 1116
    .local v2, "e":Ljava/io/FileNotFoundException;
    :try_start_1
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "failed to find "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v8}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v8}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 1122
    if-eqz v3, :cond_0

    .line 1124
    :try_start_2
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_3

    :cond_0
    :goto_1
    move-object v6, v9

    .line 1129
    .end local v2    # "e":Ljava/io/FileNotFoundException;
    .end local v3    # "is":Ljava/io/InputStream;
    :goto_2
    return-object v6

    .line 1114
    .restart local v0    # "buf":[B
    .restart local v1    # "bytesRead":I
    .restart local v3    # "is":Ljava/io/InputStream;
    .restart local v4    # "os":Ljava/io/ByteArrayOutputStream;
    :cond_1
    :try_start_3
    invoke-virtual {v4}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B
    :try_end_3
    .catch Ljava/io/FileNotFoundException; {:try_start_3 .. :try_end_3} :catch_0
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_1
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    move-result-object v5

    .line 1122
    if-eqz v3, :cond_2

    .line 1124
    :try_start_4
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_2

    .end local v0    # "buf":[B
    .end local v1    # "bytesRead":I
    .end local v3    # "is":Ljava/io/InputStream;
    .end local v4    # "os":Ljava/io/ByteArrayOutputStream;
    :cond_2
    :goto_3
    move-object v6, v5

    .line 1129
    goto :goto_2

    .line 1118
    .restart local v3    # "is":Ljava/io/InputStream;
    :catch_1
    move-exception v6

    move-object v2, v6

    .line 1119
    .local v2, "e":Ljava/io/IOException;
    :try_start_5
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "failed to find "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v8}, Lcom/google/android/mms/pdu/PduPart;->getDataUri()Landroid/net/Uri;

    move-result-object v8

    invoke-virtual {v8}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    .line 1122
    if-eqz v3, :cond_3

    .line 1124
    :try_start_6
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_6
    .catch Ljava/io/IOException; {:try_start_6 .. :try_end_6} :catch_4

    :cond_3
    :goto_4
    move-object v6, v9

    .line 1125
    goto :goto_2

    .line 1122
    .end local v2    # "e":Ljava/io/IOException;
    :catchall_0
    move-exception v6

    if-eqz v3, :cond_4

    .line 1124
    :try_start_7
    invoke-virtual {v3}, Ljava/io/InputStream;->close()V
    :try_end_7
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_7} :catch_5

    .line 1125
    :cond_4
    :goto_5
    throw v6

    .restart local v0    # "buf":[B
    .restart local v1    # "bytesRead":I
    .restart local v4    # "os":Ljava/io/ByteArrayOutputStream;
    :catch_2
    move-exception v6

    goto :goto_3

    .end local v0    # "buf":[B
    .end local v1    # "bytesRead":I
    .end local v4    # "os":Ljava/io/ByteArrayOutputStream;
    .local v2, "e":Ljava/io/FileNotFoundException;
    :catch_3
    move-exception v6

    goto :goto_1

    .local v2, "e":Ljava/io/IOException;
    :catch_4
    move-exception v6

    goto :goto_4

    .end local v2    # "e":Ljava/io/IOException;
    :catch_5
    move-exception v7

    goto :goto_5
.end method

.method public read(II)[B
    .locals 3
    .param p1, "from"    # I
    .param p2, "len"    # I

    .prologue
    .line 1020
    sget-boolean v1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->$assertionsDisabled:Z

    if-nez v1, :cond_0

    add-int v1, p1, p2

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    array-length v2, v2

    if-lt v1, v2, :cond_0

    new-instance v1, Ljava/lang/AssertionError;

    invoke-direct {v1}, Ljava/lang/AssertionError;-><init>()V

    throw v1

    .line 1022
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    if-nez v1, :cond_1

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    if-eqz v1, :cond_1

    .line 1023
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->loadData()[B

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    .line 1026
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    if-nez v1, :cond_2

    .line 1027
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v2, "[part] failed to read data which is null!!"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 1028
    const/4 v1, 0x0

    .line 1032
    :goto_0
    return-object v1

    .line 1030
    :cond_2
    new-array v0, p2, [B

    .line 1031
    .local v0, "ret":[B
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    const/4 v2, 0x0

    invoke-static {v1, p1, v0, v2, p2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    move-object v1, v0

    .line 1032
    goto :goto_0
.end method

.method public setPduPart(Lcom/google/android/mms/pdu/PduPart;)V
    .locals 0
    .param p1, "pduPart"    # Lcom/google/android/mms/pdu/PduPart;

    .prologue
    .line 1054
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    .line 1055
    return-void
.end method

.method public toBytes(Z)[B
    .locals 8
    .param p1, "isLastPart"    # Z

    .prologue
    const/4 v7, 0x0

    const/4 v6, 0x1

    const/4 v5, 0x0

    .line 1147
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    if-nez v4, :cond_0

    .line 1148
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v5, "part.toBytes() : the pdupart is null! can\'t get the bytes"

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move-object v4, v7

    .line 1171
    :goto_0
    return-object v4

    .line 1151
    :cond_0
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 1152
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 1154
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    iget v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mIndex:I

    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 1155
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->getDataLength()I

    move-result v4

    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 1156
    if-eqz p1, :cond_2

    move v4, v6

    :goto_1
    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 1158
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v4}, Lcom/google/android/mms/pdu/PduPart;->getCharset()I

    move-result v1

    .line 1159
    .local v1, "charset":I
    const/4 v4, -0x1

    if-ne v1, v4, :cond_1

    .line 1160
    const/16 v1, 0x6a

    .line 1163
    :cond_1
    const/4 v4, 0x1

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/PduPart;->getContentType()[B

    move-result-object v5

    invoke-direct {p0, v3, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 1164
    const/4 v4, 0x0

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/PduPart;->getContentId()[B

    move-result-object v5

    invoke-direct {p0, v3, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 1165
    const/4 v4, 0x2

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v5}, Lcom/google/android/mms/pdu/PduPart;->getContentLocation()[B

    move-result-object v5

    invoke-direct {p0, v3, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->writeString(Ljava/io/DataOutputStream;B[B)V

    .line 1166
    const/4 v4, 0x3

    invoke-static {v1}, Lcom/google/android/mms/pdu/CharacterSets;->getMimeName(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->getBytes()[B

    move-result-object v5

    invoke-direct {p0, v3, v4, v5}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->writeString(Ljava/io/DataOutputStream;B[B)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 1171
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v4

    goto :goto_0

    .end local v1    # "charset":I
    :cond_2
    move v4, v5

    .line 1156
    goto :goto_1

    .line 1167
    :catch_0
    move-exception v4

    move-object v2, v4

    .line 1168
    .local v2, "e":Ljava/lang/Exception;
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->TAG:Ljava/lang/String;

    const-string v5, " failed to convert the part to bytes"

    invoke-static {v4, v5, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    move-object v4, v7

    .line 1169
    goto :goto_0
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 1176
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "id="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mIndex:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " len="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->getDataLength()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " charset="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/PduPart;->getCharset()I

    move-result v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " location="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/PduPart;->getContentLocation()[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " mime="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/PduPart;->getContentType()[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " contentid="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mPduPart:Lcom/google/android/mms/pdu/PduPart;

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/PduPart;->getContentId()[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public write([BI)V
    .locals 5
    .param p1, "data"    # [B
    .param p2, "len"    # I

    .prologue
    const/4 v4, 0x0

    .line 1004
    const/4 v0, 0x0

    .line 1006
    .local v0, "from":I
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    if-nez v2, :cond_0

    .line 1007
    new-array v1, p2, [B

    .line 1015
    .local v1, "tmp":[B
    :goto_0
    invoke-static {p1, v4, v1, v0, p2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 1016
    iput-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    .line 1017
    return-void

    .line 1010
    .end local v1    # "tmp":[B
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    array-length v2, v2

    add-int/2addr v2, p2

    new-array v1, v2, [B

    .line 1011
    .restart local v1    # "tmp":[B
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    array-length v0, v2

    .line 1013
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->mData:[B

    array-length v3, v3

    invoke-static {v2, v4, v1, v4, v3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    goto :goto_0
.end method
