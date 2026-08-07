.class public Lcom/esmertec/android/jbed/util/SimpleEntry;
.super Ljava/lang/Object;
.source "SimpleEntry.java"

# interfaces
.implements Ljava/util/Map$Entry;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<K:",
        "Ljava/lang/Object;",
        "V:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;",
        "Ljava/util/Map$Entry",
        "<TK;TV;>;"
    }
.end annotation


# instance fields
.field key:Ljava/lang/Object;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "TK;"
        }
    .end annotation
.end field

.field value:Ljava/lang/Object;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "TV;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Ljava/lang/Object;Ljava/lang/Object;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TK;TV;)V"
        }
    .end annotation

    .prologue
    .line 60
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    .local p1, "key":Ljava/lang/Object;, "TK;"
    .local p2, "value":Ljava/lang/Object;, "TV;"
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 61
    iput-object p1, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->key:Ljava/lang/Object;

    .line 62
    iput-object p2, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    .line 63
    return-void
.end method

.method static eq(Ljava/lang/Object;Ljava/lang/Object;)Z
    .locals 1
    .param p0, "o1"    # Ljava/lang/Object;
    .param p1, "o2"    # Ljava/lang/Object;

    .prologue
    .line 96
    if-nez p0, :cond_1

    if-nez p1, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0

    :cond_1
    invoke-virtual {p0, p1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    goto :goto_0
.end method


# virtual methods
.method public equals(Ljava/lang/Object;)Z
    .locals 5
    .param p1, "o"    # Ljava/lang/Object;

    .prologue
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    const/4 v4, 0x0

    .line 80
    instance-of v2, p1, Ljava/util/Map$Entry;

    if-nez v2, :cond_0

    move v2, v4

    .line 83
    :goto_0
    return v2

    .line 82
    :cond_0
    move-object v0, p1

    check-cast v0, Ljava/util/Map$Entry;

    move-object v1, v0

    .line 83
    .local v1, "e":Ljava/util/Map$Entry;
    iget-object v2, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->key:Ljava/lang/Object;

    invoke-interface {v1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/util/SimpleEntry;->eq(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    iget-object v2, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    invoke-interface {v1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/util/SimpleEntry;->eq(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    const/4 v2, 0x1

    goto :goto_0

    :cond_1
    move v2, v4

    goto :goto_0
.end method

.method public getKey()Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()TK;"
        }
    .end annotation

    .prologue
    .line 66
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->key:Ljava/lang/Object;

    return-object v0
.end method

.method public getValue()Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()TV;"
        }
    .end annotation

    .prologue
    .line 70
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    .prologue
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    const/4 v2, 0x0

    .line 87
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->key:Ljava/lang/Object;

    if-nez v0, :cond_0

    move v0, v2

    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    if-nez v1, :cond_1

    move v1, v2

    :goto_1
    xor-int/2addr v0, v1

    return v0

    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->key:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    goto :goto_0

    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    invoke-virtual {v1}, Ljava/lang/Object;->hashCode()I

    move-result v1

    goto :goto_1
.end method

.method public setValue(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TV;)TV;"
        }
    .end annotation

    .prologue
    .line 74
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    .local p1, "value":Ljava/lang/Object;, "TV;"
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    .line 75
    .local v0, "oldValue":Ljava/lang/Object;, "TV;"
    iput-object p1, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    .line 76
    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 1

    .prologue
    .line 92
    .local p0, "this":Lcom/esmertec/android/jbed/util/SimpleEntry;, "Lcom/esmertec/android/jbed/util/SimpleEntry<TK;TV;>;"
    iget-object v0, p0, Lcom/esmertec/android/jbed/util/SimpleEntry;->value:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
