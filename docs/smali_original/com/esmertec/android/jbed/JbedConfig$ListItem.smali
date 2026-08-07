.class public Lcom/esmertec/android/jbed/JbedConfig$ListItem;
.super Ljava/lang/Object;
.source "JbedConfig.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedConfig;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "ListItem"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 439
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static isDateDisabled()Z
    .locals 1

    .prologue
    .line 445
    const-string v0, "LISTITEM.DATE.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isSizeDisabled()Z
    .locals 1

    .prologue
    .line 452
    const-string v0, "LISTITEM.SIZE.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public static isVendorDisabled()Z
    .locals 1

    .prologue
    .line 459
    const-string v0, "LISTITEM.VENDOR.DISABLE"

    invoke-static {v0}, Lcom/esmertec/android/jbed/JbedConfig;->access$000(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method
