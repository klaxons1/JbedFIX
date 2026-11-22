.class final Lcom/esmertec/android/jbed/ams/JbedSelectorData$1;
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
    .line 48
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I
    .locals 3
    .param p1, "m1"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "m2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 50
    invoke-static {p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->sortFolderToTop(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    .line 51
    .local v0, "ret":I
    if-nez v0, :cond_0

    .line 52
    iget-object v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    iget-object v2, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    move-result v1

    .line 54
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
    .line 48
    check-cast p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p1    # "x0":Ljava/lang/Object;
    check-cast p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .end local p2    # "x1":Ljava/lang/Object;
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$1;->compare(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I

    move-result v0

    return v0
.end method
