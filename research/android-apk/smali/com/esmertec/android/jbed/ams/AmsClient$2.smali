.class Lcom/esmertec/android/jbed/ams/AmsClient$2;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.source "AmsClient.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveToFolderEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)I
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field mResult:I

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClient;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V
    .locals 0
    .param p2, "x0"    # [I

    .prologue
    .line 631
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClient$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    return-void
.end method


# virtual methods
.method getResponse()Ljava/lang/Object;
    .locals 1

    .prologue
    .line 635
    iget v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient$2;->mResult:I

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    return-object v0
.end method

.method onResponseReceived(II[B)V
    .locals 0
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 639
    iput p2, p0, Lcom/esmertec/android/jbed/ams/AmsClient$2;->mResult:I

    .line 640
    return-void
.end method
