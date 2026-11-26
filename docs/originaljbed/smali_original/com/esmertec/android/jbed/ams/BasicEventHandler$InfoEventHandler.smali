.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InfoEventHandler"
.end annotation


# static fields
.field public static final DELIMITER:Ljava/lang/String; = " : "


# instance fields
.field dateFormat:Ljava/text/DateFormat;

.field mInfo:Ljava/lang/StringBuffer;


# direct methods
.method public constructor <init>()V
    .locals 2

    .prologue
    const/4 v1, 0x1

    .line 668
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 670
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    .line 674
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    invoke-static {v1, v1, v0}, Ljava/text/DateFormat;->getDateTimeInstance(IILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->dateFormat:Ljava/text/DateFormat;

    return-void
.end method

.method private convertDrmDateTime(J)Ljava/lang/String;
    .locals 11
    .param p1, "remainedMills"    # J

    .prologue
    const-string v10, ":"

    const-string v9, "  "

    .line 867
    new-instance v1, Ljava/lang/StringBuffer;

    const-string v6, ""

    invoke-direct {v1, v6}, Ljava/lang/StringBuffer;-><init>(Ljava/lang/String;)V

    .line 868
    .local v1, "drmDateTimeStr":Ljava/lang/StringBuffer;
    const-wide/16 v6, 0x0

    cmp-long v6, p1, v6

    if-gez v6, :cond_0

    .line 869
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v6

    .line 892
    :goto_0
    return-object v6

    .line 870
    :cond_0
    const/4 v0, 0x0

    .local v0, "day":I
    const/4 v2, 0x0

    .local v2, "hour":I
    const/4 v3, 0x0

    .local v3, "minute":I
    const/4 v5, 0x0

    .line 871
    .local v5, "second":I
    new-instance v6, Ljava/lang/Long;

    const-wide/16 v7, 0x3e8

    div-long v7, p1, v7

    invoke-direct {v6, v7, v8}, Ljava/lang/Long;-><init>(J)V

    invoke-virtual {v6}, Ljava/lang/Long;->intValue()I

    move-result v4

    .line 872
    .local v4, "remainedSec":I
    rem-int/lit8 v5, v4, 0x3c

    .line 873
    div-int/lit8 v6, v4, 0x3c

    rem-int/lit8 v3, v6, 0x3c

    .line 874
    div-int/lit16 v6, v4, 0xe10

    rem-int/lit8 v2, v6, 0x18

    .line 875
    const v6, 0x15180

    div-int v0, v4, v6

    .line 876
    const-string v6, "AmsEventHandler"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "convertDrmDateTime<"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ":"

    invoke-virtual {v7, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ":"

    invoke-virtual {v7, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ":"

    invoke-virtual {v7, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, ">"

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 877
    if-eqz v0, :cond_1

    .line 878
    invoke-virtual {v1, v0}, Ljava/lang/StringBuffer;->append(I)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 879
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f050286

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 881
    :cond_1
    if-eqz v2, :cond_2

    .line 882
    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(I)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 883
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f050287

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 885
    :cond_2
    if-eqz v3, :cond_3

    .line 886
    invoke-virtual {v1, v3}, Ljava/lang/StringBuffer;->append(I)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 887
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f050288

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 890
    :cond_3
    invoke-virtual {v1, v5}, Ljava/lang/StringBuffer;->append(I)Ljava/lang/StringBuffer;

    move-result-object v6

    const-string v7, "  "

    invoke-virtual {v6, v9}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 891
    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    const v7, 0x7f050289

    invoke-virtual {v6, v7}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 892
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v6

    goto/16 :goto_0
.end method


# virtual methods
.method public parseData([B)V
    .locals 40
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 678
    if-nez p1, :cond_0

    .line 856
    :goto_0
    return-void

    .line 681
    :cond_0
    new-instance v14, Ljava/io/DataInputStream;

    new-instance v37, Ljava/io/ByteArrayInputStream;

    move-object/from16 v0, v37

    move-object/from16 v1, p1

    invoke-direct {v0, v1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    move-object v0, v14

    move-object/from16 v1, v37

    invoke-direct {v0, v1}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 682
    .local v14, "in":Ljava/io/DataInputStream;
    const/16 v32, 0x0

    .line 683
    .local v32, "token":Ljava/lang/String;
    const/16 v20, 0x0

    .line 684
    .local v20, "isTrusted":Ljava/lang/String;
    const-string v13, ""

    .line 685
    .local v13, "id":Ljava/lang/String;
    const/16 v23, 0x0

    .local v23, "numMidlets":I
    const/4 v12, 0x0

    .line 686
    .local v12, "i":I
    new-instance v7, Ljava/lang/StringBuffer;

    invoke-direct {v7}, Ljava/lang/StringBuffer;-><init>()V

    .line 688
    .local v7, "drmProtectionInfo":Ljava/lang/StringBuffer;
    :cond_1
    invoke-virtual {v14}, Ljava/io/DataInputStream;->available()I

    move-result v37

    if-lez v37, :cond_22

    .line 689
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v32

    .line 690
    const-string v37, "trusted"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_6

    .line 691
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v20

    .line 692
    const-string v37, "false"

    move-object/from16 v0, v37

    move-object/from16 v1, v20

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_4

    .line 693
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f05015a

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 699
    :goto_1
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 834
    :cond_2
    :goto_2
    const/4 v12, 0x1

    :goto_3
    move v0, v12

    move/from16 v1, v23

    if-gt v0, v1, :cond_1

    .line 835
    new-instance v37, Ljava/lang/StringBuilder;

    invoke-direct/range {v37 .. v37}, Ljava/lang/StringBuilder;-><init>()V

    const-string v38, "MIDlet-"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v37

    move-object/from16 v0, v37

    move v1, v12

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v37

    invoke-virtual/range {v37 .. v37}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v22

    .line 836
    .local v22, "midletstr":Ljava/lang/String;
    move-object/from16 v0, v22

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_3

    .line 837
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v21

    .line 838
    .local v21, "midletNInfro":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, v37

    move-object/from16 v1, v22

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object/from16 v1, v21

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 834
    .end local v21    # "midletNInfro":Ljava/lang/String;
    :cond_3
    add-int/lit8 v12, v12, 0x1

    goto :goto_3

    .line 694
    .end local v22    # "midletstr":Ljava/lang/String;
    :cond_4
    const-string v37, "true"

    move-object/from16 v0, v37

    move-object/from16 v1, v20

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_5

    .line 695
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050159

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto :goto_1

    .line 697
    :cond_5
    const-string v37, "AmsEventHandler"

    const-string v38, "unknown if trusted"

    invoke-static/range {v37 .. v38}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto/16 :goto_1

    .line 700
    :cond_6
    const-string v37, "domain"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_7

    .line 701
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, "\n"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 702
    :cond_7
    const-string v37, "name"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_8

    .line 703
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050075

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 704
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, "\n"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 705
    :cond_8
    const-string v37, "id"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_9

    .line 706
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v13

    goto/16 :goto_2

    .line 707
    :cond_9
    const-string v37, "signer"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_e

    .line 708
    const-string v37, "true"

    move-object/from16 v0, v37

    move-object/from16 v1, v20

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 709
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050376

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 710
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v28

    .line 713
    .local v28, "signerString":Ljava/lang/String;
    const-string v37, "O="

    move-object/from16 v0, v28

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v29

    .line 715
    .local v29, "start":I
    const/16 v37, -0x1

    move/from16 v0, v29

    move/from16 v1, v37

    if-ne v0, v1, :cond_a

    .line 716
    const-string v37, "OU="

    move-object/from16 v0, v28

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v29

    .line 718
    :cond_a
    const/16 v37, -0x1

    move/from16 v0, v29

    move/from16 v1, v37

    if-ne v0, v1, :cond_b

    .line 719
    const-string v37, "CN="

    move-object/from16 v0, v28

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v29

    .line 720
    :cond_b
    const/16 v37, -0x1

    move/from16 v0, v29

    move/from16 v1, v37

    if-ne v0, v1, :cond_c

    .line 721
    const-string v37, "AmsEventHandler"

    const-string v38, "InfoEventHandler can not find signer"

    invoke-static/range {v37 .. v38}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 722
    :cond_c
    const-string v37, ";"

    move-object/from16 v0, v28

    move-object/from16 v1, v37

    move/from16 v2, v29

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v8

    .line 723
    .local v8, "end":I
    const/16 v37, -0x1

    move v0, v8

    move/from16 v1, v37

    if-ne v0, v1, :cond_d

    .line 724
    invoke-virtual/range {v28 .. v29}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v27

    .line 727
    .local v27, "signer":Ljava/lang/String;
    :goto_4
    if-eqz v27, :cond_2

    .line 728
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    const-string v38, "="

    move-object/from16 v0, v27

    move-object/from16 v1, v38

    invoke-virtual {v0, v1}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v38

    add-int/lit8 v38, v38, 0x1

    move-object/from16 v0, v27

    move/from16 v1, v38

    invoke-virtual {v0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, "\n"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 726
    .end local v27    # "signer":Ljava/lang/String;
    :cond_d
    move-object/from16 v0, v28

    move/from16 v1, v29

    move v2, v8

    invoke-virtual {v0, v1, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v27

    .restart local v27    # "signer":Ljava/lang/String;
    goto :goto_4

    .line 731
    .end local v8    # "end":I
    .end local v27    # "signer":Ljava/lang/String;
    .end local v28    # "signerString":Ljava/lang/String;
    .end local v29    # "start":I
    :cond_e
    const-string v37, "drmProtected"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_12

    .line 733
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_f

    .line 734
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05038e

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 737
    :goto_5
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v19

    .line 738
    .local v19, "isDrmProtected":Ljava/lang/String;
    const-string v37, "true"

    move-object/from16 v0, v37

    move-object/from16 v1, v19

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_10

    .line 739
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050124

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 736
    .end local v19    # "isDrmProtected":Ljava/lang/String;
    :cond_f
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05036d

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto :goto_5

    .line 740
    .restart local v19    # "isDrmProtected":Ljava/lang/String;
    :cond_10
    const-string v37, "false"

    move-object/from16 v0, v37

    move-object/from16 v1, v19

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_11

    .line 741
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050125

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 743
    :cond_11
    const-string v37, "AmsEventHandler"

    const-string v38, "unknown whether drm protected"

    invoke-static/range {v37 .. v38}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto/16 :goto_2

    .line 745
    .end local v19    # "isDrmProtected":Ljava/lang/String;
    :cond_12
    const-string v37, "drmIsForwardLocked"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_15

    .line 747
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05036e

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 748
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v19

    .line 749
    .restart local v19    # "isDrmProtected":Ljava/lang/String;
    const-string v37, "false"

    move-object/from16 v0, v37

    move-object/from16 v1, v19

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_13

    .line 750
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050124

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 751
    :cond_13
    const-string v37, "true"

    move-object/from16 v0, v37

    move-object/from16 v1, v19

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_14

    .line 752
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050125

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 754
    :cond_14
    const-string v37, "AmsEventHandler"

    const-string v38, "unknown whether forward lock"

    invoke-static/range {v37 .. v38}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto/16 :goto_2

    .line 756
    .end local v19    # "isDrmProtected":Ljava/lang/String;
    :cond_15
    const-string v37, "drmConstraintCount"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_17

    .line 757
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_16

    .line 758
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05038f

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 761
    :goto_6
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 762
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 763
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050390

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 764
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050397

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 760
    :cond_16
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05036f

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    goto :goto_6

    .line 766
    :cond_17
    const-string v37, "drmConstraintStartDate"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_18

    .line 767
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050370

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 768
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v30

    .line 769
    .local v30, "startDate":Ljava/lang/String;
    new-instance v5, Ljava/util/Date;

    new-instance v37, Ljava/lang/Long;

    move-object/from16 v0, v37

    move-object/from16 v1, v30

    invoke-direct {v0, v1}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual/range {v37 .. v37}, Ljava/lang/Long;->longValue()J

    move-result-wide v37

    move-object v0, v5

    move-wide/from16 v1, v37

    invoke-direct {v0, v1, v2}, Ljava/util/Date;-><init>(J)V

    .line 770
    .local v5, "date":Ljava/util/Date;
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->dateFormat:Ljava/text/DateFormat;

    move-object/from16 v38, v0

    move-object/from16 v0, v38

    move-object v1, v5

    invoke-virtual {v0, v1}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 771
    .end local v5    # "date":Ljava/util/Date;
    .end local v30    # "startDate":Ljava/lang/String;
    :cond_18
    const-string v37, "drmConstraintEndDate"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1a

    .line 772
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v9

    .line 773
    .local v9, "endDate":Ljava/lang/String;
    new-instance v5, Ljava/util/Date;

    new-instance v37, Ljava/lang/Long;

    move-object/from16 v0, v37

    move-object v1, v9

    invoke-direct {v0, v1}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual/range {v37 .. v37}, Ljava/lang/Long;->longValue()J

    move-result-wide v37

    move-object v0, v5

    move-wide/from16 v1, v37

    invoke-direct {v0, v1, v2}, Ljava/util/Date;-><init>(J)V

    .line 775
    .restart local v5    # "date":Ljava/util/Date;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_19

    .line 776
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v3

    .line 777
    .local v3, "currentMills":J
    new-instance v37, Ljava/lang/Long;

    move-object/from16 v0, v37

    move-object v1, v9

    invoke-direct {v0, v1}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual/range {v37 .. v37}, Ljava/lang/Long;->longValue()J

    move-result-wide v10

    .line 778
    .local v10, "endMills":J
    sub-long v25, v10, v3

    .line 779
    .local v25, "remainedMills":J
    const-string v37, "AmsEventHandler"

    new-instance v38, Ljava/lang/StringBuilder;

    invoke-direct/range {v38 .. v38}, Ljava/lang/StringBuilder;-><init>()V

    const-string v39, "InfoEventHandler remainedMills:"

    invoke-virtual/range {v38 .. v39}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    move-object/from16 v0, v38

    move-wide/from16 v1, v25

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v38

    invoke-virtual/range {v38 .. v38}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v38

    invoke-static/range {v37 .. v38}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 780
    const-wide/16 v37, 0x0

    cmp-long v37, v25, v37

    if-lez v37, :cond_2

    .line 781
    move-object/from16 v0, p0

    move-wide/from16 v1, v25

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->convertDrmDateTime(J)Ljava/lang/String;

    move-result-object v6

    .line 782
    .local v6, "drmDateTimeStr":Ljava/lang/String;
    const-string v37, "AmsEventHandler"

    new-instance v38, Ljava/lang/StringBuilder;

    invoke-direct/range {v38 .. v38}, Ljava/lang/StringBuilder;-><init>()V

    const-string v39, "InfoEventHandler drmDateTimeStr:"

    invoke-virtual/range {v38 .. v39}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    move-object/from16 v0, v38

    move-object v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    invoke-virtual/range {v38 .. v38}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v38

    invoke-static/range {v37 .. v38}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 783
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050390

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 784
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 788
    .end local v3    # "currentMills":J
    .end local v6    # "drmDateTimeStr":Ljava/lang/String;
    .end local v10    # "endMills":J
    .end local v25    # "remainedMills":J
    :cond_19
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050371

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 789
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->dateFormat:Ljava/text/DateFormat;

    move-object/from16 v38, v0

    move-object/from16 v0, v38

    move-object v1, v5

    invoke-virtual {v0, v1}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 791
    .end local v5    # "date":Ljava/util/Date;
    .end local v9    # "endDate":Ljava/lang/String;
    :cond_1a
    const-string v37, "drmExpired"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1b

    .line 793
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 794
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v18

    .line 795
    .local v18, "isDrmExpired":Ljava/lang/String;
    const-string v37, "true"

    move-object/from16 v0, v37

    move-object/from16 v1, v18

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 796
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050390

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 797
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050397

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 798
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05038f

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 799
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050397

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 802
    .end local v18    # "isDrmExpired":Ljava/lang/String;
    :cond_1b
    const-string v37, "MIDlet-Vendor"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1c

    .line 803
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v33

    .line 804
    .local v33, "vendor":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050072

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object/from16 v1, v33

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 806
    .end local v33    # "vendor":Ljava/lang/String;
    :cond_1c
    const-string v37, "MIDlet-Version"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1d

    .line 807
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v34

    .line 808
    .local v34, "version":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050071

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object/from16 v1, v34

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 810
    .end local v34    # "version":Ljava/lang/String;
    :cond_1d
    const-string v37, "MicroEdition-Configuration"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1e

    .line 811
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v35

    .line 812
    .local v35, "versionOfCLDC":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    const-string v38, "MicroEdition-Configuration"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object/from16 v1, v35

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 813
    .end local v35    # "versionOfCLDC":Ljava/lang/String;
    :cond_1e
    const-string v37, "MicroEdition-Profile"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_1f

    .line 814
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v36

    .line 815
    .local v36, "versionOfMIDP":Ljava/lang/String;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    const-string v38, "MicroEdition-Profile"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, v37

    move-object/from16 v1, v36

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 816
    .end local v36    # "versionOfMIDP":Ljava/lang/String;
    :cond_1f
    const-string v37, "numMidlets"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_20

    .line 817
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v24

    .line 818
    .local v24, "numMidlets_str":Ljava/lang/String;
    invoke-static/range {v24 .. v24}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v23

    .line 819
    goto/16 :goto_2

    .end local v24    # "numMidlets_str":Ljava/lang/String;
    :cond_20
    const-string v37, "drmConstraintInterval"

    move-object/from16 v0, v37

    move-object/from16 v1, v32

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 820
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v37

    const-string v38, "LGE"

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_2

    .line 821
    invoke-static {v14}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v17

    .line 822
    .local v17, "intervalStr":Ljava/lang/String;
    new-instance v37, Ljava/lang/Long;

    move-object/from16 v0, v37

    move-object/from16 v1, v17

    invoke-direct {v0, v1}, Ljava/lang/Long;-><init>(Ljava/lang/String;)V

    invoke-virtual/range {v37 .. v37}, Ljava/lang/Long;->longValue()J

    move-result-wide v15

    .line 823
    .local v15, "interval":J
    const-wide/16 v37, -0x1

    cmp-long v37, v15, v37

    if-nez v37, :cond_21

    .line 824
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05038f

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 825
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050391

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 826
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f050390

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 827
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050391

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 829
    :cond_21
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v37, v0

    const v38, 0x7f05038f

    invoke-virtual/range {v37 .. v38}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v37

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 830
    const-string v37, "  "

    move-object v0, v7

    move-object/from16 v1, v37

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050397

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_2

    .line 842
    .end local v15    # "interval":J
    .end local v17    # "intervalStr":Ljava/lang/String;
    :cond_22
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    move-object/from16 v37, v0

    move-object/from16 v0, v37

    move-object v1, v13

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findSuite(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v31

    .line 843
    .local v31, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-nez v31, :cond_23

    .line 844
    new-instance v37, Ljava/lang/IllegalStateException;

    new-instance v38, Ljava/lang/StringBuilder;

    invoke-direct/range {v38 .. v38}, Ljava/lang/StringBuilder;-><init>()V

    const-string v39, "can\'t find the suite "

    invoke-virtual/range {v38 .. v39}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    move-object/from16 v0, v38

    move-object v1, v13

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    const-string v39, "! but it is in the suite deaitls"

    invoke-virtual/range {v38 .. v39}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v38

    invoke-virtual/range {v38 .. v38}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v38

    invoke-direct/range {v37 .. v38}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v37

    .line 846
    :cond_23
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050070

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 847
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    move-object/from16 v0, v31

    move-object/from16 v1, v38

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeText(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 848
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, v37

    move-object v1, v7

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 850
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f050374

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const-string v38, " : "

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 851
    const-string v37, "Phone"

    invoke-virtual/range {v31 .. v31}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSimpleStorageName()Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v37

    if-eqz v37, :cond_24

    .line 852
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mContext:Landroid/content/Context;

    move-object/from16 v38, v0

    const v39, 0x7f05029f

    invoke-virtual/range {v38 .. v39}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_0

    .line 854
    :cond_24
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    move-object/from16 v37, v0

    invoke-virtual/range {v31 .. v31}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSimpleStorageName()Ljava/lang/String;

    move-result-object v38

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v37

    const/16 v38, 0xa

    invoke-virtual/range {v37 .. v38}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    goto/16 :goto_0
.end method

.method public run()V
    .locals 2

    .prologue
    .line 860
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 861
    const v0, 0x7f05012b

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->showDialg(ILjava/lang/String;)V

    .line 864
    :goto_0
    return-void

    .line 863
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->mInfo:Ljava/lang/StringBuffer;

    invoke-virtual {v0}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;->showInfo(Ljava/lang/String;)V

    goto :goto_0
.end method
