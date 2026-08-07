.class Lcom/esmertec/android/jbed/ams/AmsClient$4;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.source "AmsClient.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsClient;->checkPermissionAnswer(BB)Ljava/util/Map$Entry;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field mResult:Ljava/util/Map$Entry;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map$Entry",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClient;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V
    .locals 0
    .param p2, "x0"    # [I

    .prologue
    .line 750
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClient$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    return-void
.end method


# virtual methods
.method getResponse()Ljava/lang/Object;
    .locals 1

    .prologue
    .line 762
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient$4;->mResult:Ljava/util/Map$Entry;

    return-object v0
.end method

.method onResponseReceived(II[B)V
    .locals 3
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 757
    new-instance v0, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    if-nez p3, :cond_0

    const/4 v2, 0x0

    :goto_0
    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/util/SimpleEntry;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient$4;->mResult:Ljava/util/Map$Entry;

    .line 758
    return-void

    .line 757
    :cond_0
    new-instance v2, Ljava/lang/String;

    invoke-direct {v2, p3}, Ljava/lang/String;-><init>([B)V

    goto :goto_0
.end method
