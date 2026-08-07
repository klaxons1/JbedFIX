.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DrmGetConstraintEventHandler"
.end annotation


# static fields
.field public static final DELIMITER:Ljava/lang/String; = " : "


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 198
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 19

    .prologue
    .line 204
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v14

    const-string v15, "LGE"

    invoke-virtual {v14, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_9

    .line 205
    new-instance v9, Ljava/lang/StringBuffer;

    invoke-direct {v9}, Ljava/lang/StringBuffer;-><init>()V

    .line 206
    .local v9, "mInfo":Ljava/lang/StringBuffer;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0x1b

    if-eq v14, v15, :cond_6

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0xf

    if-eq v14, v15, :cond_6

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0x8

    if-eq v14, v15, :cond_6

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-eqz v14, :cond_6

    .line 208
    new-instance v8, Ljava/io/DataInputStream;

    new-instance v14, Ljava/io/ByteArrayInputStream;

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v15, v0

    iget-object v3, v15, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    check-cast v3, [B

    invoke-direct {v14, v3}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v8, v14}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 209
    .local v8, "in":Ljava/io/DataInputStream;
    const/4 v13, 0x0

    .line 210
    .local v13, "token":Ljava/lang/String;
    const/4 v14, 0x1

    const/4 v15, 0x1

    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v16

    invoke-static/range {v14 .. v16}, Ljava/text/DateFormat;->getDateTimeInstance(IILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v6

    .line 211
    .local v6, "dateFormat":Ljava/text/DateFormat;
    const/4 v4, 0x0

    .line 212
    .local v4, "cnt":I
    const/4 v12, 0x0

    .line 214
    .local v12, "suiteId":Ljava/lang/String;
    :cond_0
    :goto_0
    :try_start_0
    invoke-virtual {v8}, Ljava/io/DataInputStream;->available()I

    move-result v14

    if-lez v14, :cond_2

    .line 215
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v13

    .line 216
    const-string v14, "drmConstraintCount"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_1

    .line 217
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v14

    invoke-static {v14}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v4

    goto :goto_0

    .line 218
    :cond_1
    const-string v14, "suiteId"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_0

    .line 219
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v12

    goto :goto_0

    .line 222
    :cond_2
    const/4 v14, 0x1

    if-ne v4, v14, :cond_3

    if-eqz v12, :cond_3

    .line 223
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object v14, v0

    invoke-virtual {v14, v12}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v10

    .line 224
    .local v10, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v10, :cond_4

    .line 225
    const-string v14, "AmsEventHandler"

    const-string v15, "DrmGetConstraintEventHandler midlet is null"

    invoke-static {v14, v15}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 288
    .end local v4    # "cnt":I
    .end local v6    # "dateFormat":Ljava/text/DateFormat;
    .end local v8    # "in":Ljava/io/DataInputStream;
    .end local v9    # "mInfo":Ljava/lang/StringBuffer;
    .end local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v12    # "suiteId":Ljava/lang/String;
    .end local v13    # "token":Ljava/lang/String;
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    :cond_3
    :goto_1
    return-void

    .line 228
    .restart local v4    # "cnt":I
    .restart local v6    # "dateFormat":Ljava/text/DateFormat;
    .restart local v8    # "in":Ljava/io/DataInputStream;
    .restart local v9    # "mInfo":Ljava/lang/StringBuffer;
    .restart local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local v12    # "suiteId":Ljava/lang/String;
    .restart local v13    # "token":Ljava/lang/String;
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    :cond_4
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object v3, v0

    check-cast v3, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v3, v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getDrmMethodType(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v14

    const/4 v15, 0x3

    if-ne v14, v15, :cond_5

    .line 229
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object/from16 p0, v0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v14, 0x0

    move-object/from16 v0, p0

    move v1, v14

    move-object v2, v10

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_1

    .line 237
    .end local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :catch_0
    move-exception v14

    goto :goto_1

    .line 232
    .restart local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    :cond_5
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f05038b

    const/16 v16, 0x1

    move/from16 v0, v16

    new-array v0, v0, [Ljava/lang/Object;

    move-object/from16 v16, v0

    const/16 v17, 0x0

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v18

    aput-object v18, v16, v17

    invoke-virtual/range {v14 .. v16}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 233
    invoke-virtual {v9}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v14

    move-object/from16 v0, p0

    move-object v1, v14

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->showInfo(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    .line 238
    .end local v4    # "cnt":I
    .end local v6    # "dateFormat":Ljava/text/DateFormat;
    .end local v8    # "in":Ljava/io/DataInputStream;
    .end local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v12    # "suiteId":Ljava/lang/String;
    .end local v13    # "token":Ljava/lang/String;
    :cond_6
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0x1b

    if-ne v14, v15, :cond_3

    .line 239
    const/4 v12, 0x0

    .line 240
    .restart local v12    # "suiteId":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-eqz v14, :cond_3

    .line 241
    new-instance v12, Ljava/lang/String;

    .end local v12    # "suiteId":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-direct {v12, v14}, Ljava/lang/String;-><init>([B)V

    .line 242
    .restart local v12    # "suiteId":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object v14, v0

    invoke-virtual {v14, v12}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v10

    .line 243
    .restart local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v10, :cond_7

    .line 244
    const-string v14, "AmsEventHandler"

    const-string v15, "DrmGetConstraintEventHandler midlet is null"

    invoke-static {v14, v15}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_1

    .line 247
    :cond_7
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object v3, v0

    check-cast v3, Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-virtual {v3, v10}, Lcom/esmertec/android/jbed/ams/AmsClient;->getDrmMethodType(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v14

    const/4 v15, 0x3

    if-ne v14, v15, :cond_8

    .line 248
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object/from16 p0, v0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsClient;

    const/4 v14, 0x1

    move-object/from16 v0, p0

    move v1, v14

    move-object v2, v10

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDrmPurchaseRoConfirmEvent(ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_1

    .line 250
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;
    :cond_8
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f05038c

    invoke-virtual {v14, v15}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 251
    invoke-virtual {v9}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v14

    move-object/from16 v0, p0

    move-object v1, v14

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->showInfo(Ljava/lang/String;)V

    goto/16 :goto_1

    .line 256
    .end local v9    # "mInfo":Ljava/lang/StringBuffer;
    .end local v10    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v12    # "suiteId":Ljava/lang/String;
    :cond_9
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0x1b

    if-eq v14, v15, :cond_3

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0xf

    if-eq v14, v15, :cond_3

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v15, 0x8

    if-eq v14, v15, :cond_3

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v14, v0

    iget-object v14, v14, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-eqz v14, :cond_3

    .line 258
    new-instance v9, Ljava/lang/StringBuffer;

    invoke-direct {v9}, Ljava/lang/StringBuffer;-><init>()V

    .line 259
    .restart local v9    # "mInfo":Ljava/lang/StringBuffer;
    new-instance v8, Ljava/io/DataInputStream;

    new-instance v14, Ljava/io/ByteArrayInputStream;

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    move-object v15, v0

    iget-object v3, v15, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    check-cast v3, [B

    invoke-direct {v14, v3}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v8, v14}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 260
    .restart local v8    # "in":Ljava/io/DataInputStream;
    const/4 v13, 0x0

    .line 261
    .restart local v13    # "token":Ljava/lang/String;
    const/4 v14, 0x1

    const/4 v15, 0x1

    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v16

    invoke-static/range {v14 .. v16}, Ljava/text/DateFormat;->getDateTimeInstance(IILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v6

    .line 263
    .restart local v6    # "dateFormat":Ljava/text/DateFormat;
    :cond_a
    :goto_2
    :try_start_1
    invoke-virtual {v8}, Ljava/io/DataInputStream;->available()I

    move-result v14

    if-lez v14, :cond_e

    .line 264
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v13

    .line 265
    const-string v14, "drmConstraintCount"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_b

    .line 266
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f05036f

    invoke-virtual {v14, v15}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const-string v15, " : "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 267
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const/16 v15, 0xa

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto :goto_2

    .line 285
    :catch_1
    move-exception v14

    goto/16 :goto_1

    .line 268
    :cond_b
    const-string v14, "drmConstraintStartDate"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_c

    .line 269
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f050370

    invoke-virtual {v14, v15}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const-string v15, " : "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 270
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v11

    .line 271
    .local v11, "startDate":Ljava/lang/String;
    new-instance v5, Ljava/util/Date;

    new-instance v14, Ljava/lang/Long;

    invoke-direct {v14, v11}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual {v14}, Ljava/lang/Long;->longValue()J

    move-result-wide v14

    invoke-direct {v5, v14, v15}, Ljava/util/Date;-><init>(J)V

    .line 272
    .local v5, "date":Ljava/util/Date;
    const-string v14, "  "

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    invoke-virtual {v6, v5}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const/16 v15, 0xa

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto :goto_2

    .line 273
    .end local v5    # "date":Ljava/util/Date;
    .end local v11    # "startDate":Ljava/lang/String;
    :cond_c
    const-string v14, "drmConstraintEndDate"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_d

    .line 274
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v7

    .line 275
    .local v7, "endDate":Ljava/lang/String;
    new-instance v5, Ljava/util/Date;

    new-instance v14, Ljava/lang/Long;

    invoke-direct {v14, v7}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual {v14}, Ljava/lang/Long;->longValue()J

    move-result-wide v14

    invoke-direct {v5, v14, v15}, Ljava/util/Date;-><init>(J)V

    .line 276
    .restart local v5    # "date":Ljava/util/Date;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f050371

    invoke-virtual {v14, v15}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const-string v15, " : "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 277
    const-string v14, "  "

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    invoke-virtual {v6, v5}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const/16 v15, 0xa

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 278
    .end local v5    # "date":Ljava/util/Date;
    .end local v7    # "endDate":Ljava/lang/String;
    :cond_d
    const-string v14, "drmConstraintInterval"

    invoke-virtual {v14, v13}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_a

    .line 279
    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v3

    .line 280
    .local v3, "Interval":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->mContext:Landroid/content/Context;

    move-object v14, v0

    const v15, 0x7f050284

    invoke-virtual {v14, v15}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v14

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const-string v15, " : "

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 281
    const-string v14, "  "

    invoke-virtual {v9, v14}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    invoke-virtual {v14, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v14

    const/16 v15, 0xa

    invoke-virtual {v14, v15}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 284
    .end local v3    # "Interval":Ljava/lang/String;
    :cond_e
    invoke-virtual {v9}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v14

    move-object/from16 v0, p0

    move-object v1, v14

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;->showToast(Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_1

    goto/16 :goto_1
.end method
