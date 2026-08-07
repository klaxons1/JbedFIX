.class final Lcom/esmertec/android/jbed/ams/JbedSelectorData$4;
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
    .line 78
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I
    .locals 3
    .param p1, "m1"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "m2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 80
    invoke-static {p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->sortFolderToTop(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    .line 81
    .local v0, "ret":I
    if-nez v0, :cond_2

    .line 82
    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v1

    if-eqz v1, :cond_0

    iget-object v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    :goto_0
    invoke-virtual {p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_1

    iget-object v2, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    :goto_1
    sub-int/2addr v1, v2

    .line 85
    :goto_2
    return v1

    .line 82
    :cond_0
    iget v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    goto :goto_0

    :cond_1
    iget v2, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    goto :goto_1

    :cond_2
    move v1, v0

    .line 85
    goto :goto_2
.end method

.method public bridge synthetic compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .locals 1
    .param p1, "x0"    # Ljava/lang/Object;
    .param p2, "x1"    # Ljava/lang/Object;

    .prologue
    .line 78
    check-cast p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p1    # "x0":Ljava/lang/Object;
    check-cast p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p2    # "x1":Ljava/lang/Object;
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$4;->compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    return v0
.end method
