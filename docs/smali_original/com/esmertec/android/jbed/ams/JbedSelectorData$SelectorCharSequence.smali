.class public Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
.super Ljava/lang/Object;
.source "JbedSelectorData.java"

# interfaces
.implements Ljava/lang/CharSequence;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/JbedSelectorData;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SelectorCharSequence"
.end annotation


# instance fields
.field public mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

.field private mDisplayText:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 0
    .param p1, "displayText"    # Ljava/lang/String;
    .param p2, "data"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 858
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 859
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mDisplayText:Ljava/lang/String;

    .line 860
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 861
    return-void
.end method


# virtual methods
.method public charAt(I)C
    .locals 1
    .param p1, "index"    # I

    .prologue
    .line 864
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mDisplayText:Ljava/lang/String;

    invoke-virtual {v0, p1}, Ljava/lang/String;->charAt(I)C

    move-result v0

    return v0
.end method

.method public length()I
    .locals 1

    .prologue
    .line 868
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mDisplayText:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    return v0
.end method

.method public subSequence(II)Ljava/lang/CharSequence;
    .locals 1
    .param p1, "start"    # I
    .param p2, "end"    # I

    .prologue
    .line 872
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mDisplayText:Ljava/lang/String;

    invoke-virtual {v0, p1, p2}, Ljava/lang/String;->subSequence(II)Ljava/lang/CharSequence;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 1

    .prologue
    .line 877
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mDisplayText:Ljava/lang/String;

    return-object v0
.end method
