.class Lcom/esmertec/android/jbed/ams/AmsClientBase$2;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;
.source "AmsClientBase.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsClientBase;->getDrmMethodType(Ljava/lang/String;)I
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field mResult:I

.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V
    .locals 0
    .param p2, "x0"    # [I

    .prologue
    .line 477
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;-><init>(Lcom/esmertec/android/jbed/ams/AmsClientBase;[I)V

    return-void
.end method


# virtual methods
.method getResponse()Ljava/lang/Object;
    .locals 2

    .prologue
    .line 488
    new-instance v0, Ljava/lang/Integer;

    iget v1, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$2;->mResult:I

    invoke-direct {v0, v1}, Ljava/lang/Integer;-><init>(I)V

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
    .line 483
    iput p2, p0, Lcom/esmertec/android/jbed/ams/AmsClientBase$2;->mResult:I

    .line 484
    return-void
.end method
