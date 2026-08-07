.class Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMmsManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "JbedMmsPort"
.end annotation


# instance fields
.field mAppId:Ljava/lang/String;

.field mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;


# direct methods
.method public constructor <init>(Ljava/lang/String;ZZ)V
    .locals 1
    .param p1, "port"    # Ljava/lang/String;
    .param p2, "isStatic"    # Z
    .param p3, "isPush"    # Z

    .prologue
    .line 421
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 420
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->NONE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    .line 422
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    .line 423
    if-eqz p2, :cond_0

    .line 424
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->STATIC:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    .line 430
    :goto_0
    return-void

    .line 425
    :cond_0
    if-eqz p3, :cond_1

    .line 426
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->DYNMAIC:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    goto :goto_0

    .line 428
    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->NONE:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    goto :goto_0
.end method


# virtual methods
.method public equals(Ljava/lang/Object;)Z
    .locals 5
    .param p1, "o"    # Ljava/lang/Object;

    .prologue
    const/4 v4, 0x0

    .line 435
    move-object v0, p1

    check-cast v0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;

    move-object v1, v0

    .line 436
    .local v1, "mmsPort":Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;
    if-nez p1, :cond_0

    move v2, v4

    .line 437
    :goto_0
    return v2

    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    iget-object v3, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mAppId:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    iget-object v3, v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    if-ne v2, v3, :cond_1

    const/4 v2, 0x1

    goto :goto_0

    :cond_1
    move v2, v4

    goto :goto_0
.end method

.method public isPush()Z
    .locals 2

    .prologue
    .line 441
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->STATIC:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    if-eq v0, v1, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$JbedMmsPort;->mType:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;->DYNMAIC:Lcom/esmertec/android/jbed/jsr/JbedMmsManager$PushType;

    if-ne v0, v1, :cond_1

    :cond_0
    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_1
    const/4 v0, 0x0

    goto :goto_0
.end method
