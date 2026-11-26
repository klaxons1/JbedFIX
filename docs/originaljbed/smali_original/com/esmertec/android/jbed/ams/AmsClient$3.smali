.class Lcom/esmertec/android/jbed/ams/AmsClient$3;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.source "AmsClient.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsClient;->requestMoveToStorageEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/AmsEvent;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field mResult:Lcom/esmertec/android/jbed/ams/AmsEvent;

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClient;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V
    .locals 0
    .param p2, "x0"    # [I

    .prologue
    .line 651
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClient$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsClient;

    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    return-void
.end method


# virtual methods
.method getResponse()Ljava/lang/Object;
    .locals 1

    .prologue
    .line 655
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient$3;->mResult:Lcom/esmertec/android/jbed/ams/AmsEvent;

    return-object v0
.end method

.method onResponseReceived(II[B)V
    .locals 1
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 659
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v0, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient$3;->mResult:Lcom/esmertec/android/jbed/ams/AmsEvent;

    .line 660
    return-void
.end method
