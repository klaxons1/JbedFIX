.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RuntimeErrorEventHandler"
.end annotation


# instance fields
.field private mMessage:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1235
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public parseData([B)V
    .locals 5
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 1241
    if-nez p1, :cond_0

    .line 1242
    new-instance v2, Ljava/lang/IllegalArgumentException;

    const-string v3, "pass the invalid data in RUNTIME_ERROR event!!!"

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 1244
    :cond_0
    new-instance v0, Ljava/io/DataInputStream;

    new-instance v2, Ljava/io/ByteArrayInputStream;

    invoke-direct {v2, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v0, v2}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 1246
    .local v0, "in":Ljava/io/DataInputStream;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0}, Ljava/io/DataInputStream;->readInt()I

    move-result v4

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    .line 1247
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mMessage:Ljava/lang/String;

    .line 1248
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v3, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " : "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mMessage:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mMessage:Ljava/lang/String;

    .line 1249
    return-void
.end method

.method public run()V
    .locals 3

    .prologue
    .line 1253
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mContext:Landroid/content/Context;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;->mMessage:Ljava/lang/String;

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 1254
    return-void
.end method
