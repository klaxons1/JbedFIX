.class Lcom/esmertec/android/jbed/ams/AmsClientBase$1;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.source "AmsClientBase.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsClientBase;->checkExpiredMidlet(Ljava/lang/String;)Z
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field mResult:Z

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V
    .locals 0
    .param p2, "x0"    # [I

    .prologue
    .line 452
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$1;->this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    return-void
.end method


# virtual methods
.method getResponse()Ljava/lang/Object;
    .locals 3

    .prologue
    .line 464
    const/4 v0, 0x1

    new-array v0, v0, [Z

    const/4 v1, 0x0

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$1;->mResult:Z

    aput-boolean v2, v0, v1

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
    const/4 v0, 0x1

    .line 459
    if-ne p2, v0, :cond_0

    const/4 v0, 0x0

    :cond_0
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$1;->mResult:Z

    .line 460
    return-void
.end method
