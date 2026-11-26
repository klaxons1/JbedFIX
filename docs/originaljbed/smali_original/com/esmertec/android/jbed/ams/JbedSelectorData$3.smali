.class final Lcom/esmertec/android/jbed/ams/JbedSelectorData$3;
.super Ljava/lang/Object;
.source "JbedSelectorData.java"

# interfaces
.implements Ljava/util/Comparator;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/JbedSelectorData;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/Comparator",
        "<",
        "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
        ">;"
    }
.end annotation


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 68
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I
    .locals 5
    .param p1, "m1"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "m2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 70
    invoke-static {p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->sortFolderToTop(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    .line 71
    .local v0, "ret":I
    if-nez v0, :cond_0

    .line 72
    iget-wide v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    iget-wide v3, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    sub-long/2addr v1, v3

    long-to-int v1, v1

    .line 74
    :goto_0
    return v1

    :cond_0
    move v1, v0

    goto :goto_0
.end method

.method public bridge synthetic compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .locals 1
    .param p1, "x0"    # Ljava/lang/Object;
    .param p2, "x1"    # Ljava/lang/Object;

    .prologue
    .line 68
    check-cast p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p1    # "x0":Ljava/lang/Object;
    check-cast p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p2    # "x1":Ljava/lang/Object;
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$3;->compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    return v0
.end method
