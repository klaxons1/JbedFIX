.class Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"

# interfaces
.implements Ljava/util/Comparator;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "StartCotentIdCompartor"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/Comparator",
        "<",
        "Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;",
        ">;"
    }
.end annotation


# instance fields
.field private mStartContentId:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;)V
    .locals 0
    .param p1, "startCotentId"    # Ljava/lang/String;

    .prologue
    .line 989
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 990
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;->mStartContentId:Ljava/lang/String;

    .line 991
    return-void
.end method


# virtual methods
.method public compare(Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;)I
    .locals 2
    .param p1, "p1"    # Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;
    .param p2, "p2"    # Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .prologue
    .line 993
    new-instance v0, Ljava/lang/String;

    invoke-static {p1}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;->access$000(Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;)Lcom/google/android/mms/pdu/PduPart;

    move-result-object v1

    invoke-virtual {v1}, Lcom/google/android/mms/pdu/PduPart;->getContentId()[B

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    .line 994
    .local v0, "p1ContentId":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;->mStartContentId:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, -0x1

    :goto_0
    return v1

    :cond_0
    const/4 v1, 0x1

    goto :goto_0
.end method

.method public bridge synthetic compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .locals 1
    .param p1, "x0"    # Ljava/lang/Object;
    .param p2, "x1"    # Ljava/lang/Object;

    .prologue
    .line 985
    check-cast p1, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .end local p1    # "x0":Ljava/lang/Object;
    check-cast p2, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;

    .end local p2    # "x1":Ljava/lang/Object;
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart$StartCotentIdCompartor;->compare(Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;Lcom/esmertec/android/jbed/jsr/JbedMmsMessagePart;)I

    move-result v0

    return v0
.end method
