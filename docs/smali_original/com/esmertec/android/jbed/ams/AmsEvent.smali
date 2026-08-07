.class public Lcom/esmertec/android/jbed/ams/AmsEvent;
.super Ljava/lang/Object;
.source "AmsEvent.java"


# static fields
.field public static final TAG:Ljava/lang/String; = "AmsEvent"


# instance fields
.field public final mData:[B

.field public final mId:I

.field public mObj:Ljava/lang/Object;

.field public final mResult:I


# direct methods
.method public constructor <init>(II[B)V
    .locals 0
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    iput p1, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    .line 24
    iput p2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    .line 25
    iput-object p3, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    .line 26
    return-void
.end method


# virtual methods
.method public getDataAsUtf8()Ljava/lang/String;
    .locals 6

    .prologue
    const/4 v5, 0x1

    const-string v1, "utf-8"

    .line 29
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-eqz v1, :cond_1

    .line 32
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    array-length v2, v2

    sub-int/2addr v2, v5

    aget-byte v1, v1, v2

    if-nez v1, :cond_0

    .line 33
    new-instance v1, Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    const/4 v3, 0x0

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    array-length v4, v4

    sub-int/2addr v4, v5

    const-string v5, "utf-8"

    invoke-direct {v1, v2, v3, v4, v5}, Ljava/lang/String;-><init>([BIILjava/lang/String;)V

    .line 40
    :goto_0
    return-object v1

    .line 35
    :cond_0
    new-instance v1, Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    const-string v3, "utf-8"

    invoke-direct {v1, v2, v3}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 36
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 37
    .local v0, "e":Ljava/io/UnsupportedEncodingException;
    const-string v1, "AmsEvent"

    const-string v2, "Failed to decode data with Utf8"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 40
    .end local v0    # "e":Ljava/io/UnsupportedEncodingException;
    :cond_1
    const/4 v1, 0x0

    goto :goto_0
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    .prologue
    .line 45
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "["

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mId:I

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getEventName(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "] mResult="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 46
    .local v0, "ret":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-nez v1, :cond_0

    .line 47
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " with empty data"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 49
    :goto_0
    return-object v1

    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", len="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    array-length v2, v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    goto :goto_0
.end method
