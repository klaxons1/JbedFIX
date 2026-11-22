.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;
.super Landroid/content/BroadcastReceiver;
.source "JbedSmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "SmsReceiver"
.end annotation


# instance fields
.field private mHandler:Landroid/os/Handler;

.field private mPort:I


# direct methods
.method constructor <init>(ILandroid/os/Handler;)V
    .locals 0
    .param p1, "port"    # I
    .param p2, "handler"    # Landroid/os/Handler;

    .prologue
    .line 276
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    .line 277
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->mPort:I

    .line 278
    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->mHandler:Landroid/os/Handler;

    .line 279
    return-void
.end method

.method private getMessagesFromIntent(Landroid/content/Intent;)[Landroid/telephony/gsm/SmsMessage;
    .locals 6
    .param p1, "intent"    # Landroid/content/Intent;

    .prologue
    .line 282
    const-string v5, "pdus"

    invoke-virtual {p1, v5}, Landroid/content/Intent;->getSerializableExtra(Ljava/lang/String;)Ljava/io/Serializable;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;
    check-cast p0, [Ljava/lang/Object;

    move-object v0, p0

    check-cast v0, [Ljava/lang/Object;

    move-object v3, v0

    .line 283
    .local v3, "messages":[Ljava/lang/Object;
    array-length v2, v3

    .line 284
    .local v2, "len":I
    new-array v4, v2, [Landroid/telephony/gsm/SmsMessage;

    .line 285
    .local v4, "msgs":[Landroid/telephony/gsm/SmsMessage;
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_0
    if-ge v1, v2, :cond_0

    .line 286
    aget-object p0, v3, v1

    check-cast p0, [B

    check-cast p0, [B

    invoke-static {p0}, Landroid/telephony/gsm/SmsMessage;->createFromPdu([B)Landroid/telephony/gsm/SmsMessage;

    move-result-object v5

    aput-object v5, v4, v1

    .line 285
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 288
    :cond_0
    return-object v4
.end method

.method private mergeData([[B)[B
    .locals 8
    .param p1, "data"    # [[B

    .prologue
    const/4 v7, 0x0

    .line 348
    array-length v3, p1

    .line 349
    .local v3, "segmentLen":I
    const/4 v5, 0x1

    if-ne v3, v5, :cond_0

    .line 350
    aget-object v5, p1, v7

    .line 362
    :goto_0
    return-object v5

    .line 352
    :cond_0
    const/4 v4, 0x0

    .line 353
    .local v4, "totalSize":I
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    if-ge v1, v3, :cond_1

    .line 354
    aget-object v5, p1, v1

    array-length v5, v5

    add-int/2addr v4, v5

    .line 353
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 356
    :cond_1
    new-array v2, v4, [B

    .line 357
    .local v2, "ret":[B
    const/4 v0, 0x0

    .line 358
    .local v0, "curPos":I
    const/4 v1, 0x0

    :goto_2
    if-ge v1, v3, :cond_2

    .line 359
    aget-object v5, p1, v1

    aget-object v6, p1, v1

    array-length v6, v6

    invoke-static {v5, v7, v2, v0, v6}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 360
    aget-object v5, p1, v1

    array-length v5, v5

    add-int/2addr v0, v5

    .line 358
    add-int/lit8 v1, v1, 0x1

    goto :goto_2

    :cond_2
    move-object v5, v2

    .line 362
    goto :goto_0
.end method


# virtual methods
.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 19
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 295
    const-string v3, "com.esmertec.android.jbed.action.PUSHSMS"

    move-object/from16 v0, p2

    move-object v1, v3

    invoke-virtual {v0, v1}, Landroid/content/Intent;->getExtra(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Landroid/content/Intent;

    .line 298
    .local v10, "SmsIntent":Landroid/content/Intent;
    invoke-virtual {v10}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v17

    .line 299
    .local v17, "uri":Landroid/net/Uri;
    invoke-virtual/range {v17 .. v17}, Landroid/net/Uri;->getPort()I

    move-result v3

    move-object/from16 v0, p0

    iget v0, v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->mPort:I

    move v4, v0

    if-eq v3, v4, :cond_1

    .line 342
    .end local p1    # "context":Landroid/content/Context;
    :cond_0
    return-void

    .line 301
    .restart local p1    # "context":Landroid/content/Context;
    :cond_1
    move-object/from16 v0, p0

    move-object v1, v10

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->getMessagesFromIntent(Landroid/content/Intent;)[Landroid/telephony/gsm/SmsMessage;

    move-result-object v16

    .line 304
    .local v16, "messages":[Landroid/telephony/gsm/SmsMessage;
    move-object/from16 v0, v16

    array-length v0, v0

    move v14, v0

    .line 306
    .local v14, "len":I
    const/4 v9, 0x0

    .line 307
    .local v9, "payload":[B
    const/4 v3, 0x0

    aget-object v3, v16, v3

    move-object v0, v3

    iget-object v0, v0, Landroid/telephony/gsm/SmsMessage;->mWrappedSmsMessage:Lcom/android/internal/telephony/SmsMessageBase;

    move-object/from16 p1, v0

    .end local p1    # "context":Landroid/content/Context;
    check-cast p1, Lcom/android/internal/telephony/gsm/SmsMessage;

    move-object/from16 v0, p1

    iget v0, v0, Lcom/android/internal/telephony/gsm/SmsMessage;->encodingType:I

    move v6, v0

    .line 309
    .local v6, "encoding":I
    const/4 v3, 0x2

    if-eq v6, v3, :cond_2

    if-nez v6, :cond_4

    .line 312
    :cond_2
    const/4 v6, 0x1

    .line 313
    move v0, v14

    new-array v0, v0, [[B

    move-object/from16 v18, v0

    .line 314
    .local v18, "userdata":[[B
    const/4 v12, 0x0

    .local v12, "i":I
    :goto_0
    if-ge v12, v14, :cond_3

    .line 315
    aget-object v3, v16, v12

    invoke-virtual {v3}, Landroid/telephony/gsm/SmsMessage;->getUserData()[B

    move-result-object v3

    aput-object v3, v18, v12

    .line 314
    add-int/lit8 v12, v12, 0x1

    goto :goto_0

    .line 317
    :cond_3
    move-object/from16 v0, p0

    move-object/from16 v1, v18

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->mergeData([[B)[B

    move-result-object v9

    .line 318
    const-string v3, "JbedSmsManager"

    const-string v4, "onReceive get binary message ="

    invoke-static {v3, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 319
    const/4 v12, 0x0

    :goto_1
    array-length v3, v9

    if-ge v12, v3, :cond_6

    .line 320
    const-string v3, "JbedSmsManager"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "  data["

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v12}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "]= "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    aget-byte v5, v9, v12

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 319
    add-int/lit8 v12, v12, 0x1

    goto :goto_1

    .line 322
    .end local v12    # "i":I
    .end local v18    # "userdata":[[B
    :cond_4
    const/4 v6, 0x2

    .line 323
    const-string v15, ""

    .line 326
    .local v15, "messageText":Ljava/lang/String;
    const/4 v12, 0x0

    .restart local v12    # "i":I
    :goto_2
    if-ge v12, v14, :cond_5

    .line 327
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    aget-object v4, v16, v12

    invoke-virtual {v4}, Landroid/telephony/gsm/SmsMessage;->getMessageBody()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v15

    .line 326
    add-int/lit8 v12, v12, 0x1

    goto :goto_2

    .line 330
    :cond_5
    :try_start_0
    const-string v3, "UTF-16BE"

    invoke-virtual {v15, v3}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v9

    .line 334
    :goto_3
    const-string v3, "JbedSmsManager"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "onReceive get text message ="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 336
    .end local v15    # "messageText":Ljava/lang/String;
    :cond_6
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->access$500()Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    move-result-object v3

    iget-object v3, v3, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mListeners:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v13

    .local v13, "i$":Ljava/util/Iterator;
    :goto_4
    invoke-interface {v13}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-interface {v13}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;

    .line 338
    .local v2, "listener":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;
    const/4 v3, 0x0

    aget-object v3, v16, v3

    invoke-virtual {v3}, Landroid/telephony/gsm/SmsMessage;->getOriginatingAddress()Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x0

    move-object/from16 v0, p0

    iget v0, v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;->mPort:I

    move v5, v0

    const/4 v7, 0x0

    aget-object v7, v16, v7

    invoke-virtual {v7}, Landroid/telephony/gsm/SmsMessage;->getTimestampMillis()J

    move-result-wide v7

    invoke-interface/range {v2 .. v9}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;->notifyNewSms(Ljava/lang/String;IIIJ[B)V

    goto :goto_4

    .line 331
    .end local v2    # "listener":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;
    .end local v13    # "i$":Ljava/util/Iterator;
    .restart local v15    # "messageText":Ljava/lang/String;
    :catch_0
    move-exception v3

    move-object v11, v3

    .line 332
    .local v11, "e":Ljava/io/UnsupportedEncodingException;
    const-string v3, "JbedSmsManager"

    const-string v4, "UnsupportedEncodingException"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_3
.end method
