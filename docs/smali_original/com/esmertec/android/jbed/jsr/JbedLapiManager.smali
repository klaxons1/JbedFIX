.class public Lcom/esmertec/android/jbed/jsr/JbedLapiManager;
.super Ljava/lang/Object;
.source "JbedLapiManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;
    }
.end annotation


# static fields
.field private static final AVAILABLE:I = 0x1

.field private static final DEBUG:Z = false

.field private static final DISTANCE_COARSE_ACCURACY:I = 0x19

.field private static final DISTANCE_FINER_ACCURACY:I = 0xa

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager; = null

.field private static final INVALID_NATIVE_ID:I = 0x0

.field private static final JPL_LOC_FAILURE:I = -0x1

.field private static final JPL_LOC_INTERRUPTED:I = -0x2

.field private static final JPL_LOC_SUCCESS:I = 0x0

.field private static final JPL_LOC_WOULDBLOCK:I = -0x3

.field private static final MTA_ASSISTED:I = 0x40000

.field private static final MTA_UNASSISTED:I = 0x80000

.field private static final MTE_ANGLEOFARRIVAL:I = 0x20

.field private static final MTE_CELLID:I = 0x8

.field private static final MTE_SATELLITE:I = 0x1

.field private static final MTE_SHORTRANGE:I = 0x10

.field private static final MTE_TIMEDIFFERENCE:I = 0x2

.field private static final MTE_TIMEOFARRIVAL:I = 0x4

.field private static final MTY_NETWORKBASED:I = 0x20000

.field private static final MTY_TERMINALBASED:I = 0x10000

.field private static final OUT_OF_SERVICE:I = 0x3

.field private static final RESPONSE_TIME:I = 0x1388

.field private static final TAG:Ljava/lang/String; = "JbedLapiManager"

.field private static final TEMPORARILY_UNAVAILABLE:I = 0x2


# instance fields
.field private mHandler:Landroid/os/Handler;

.field private mLocationManager:Landroid/location/LocationManager;

.field private mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 356
    const-string v0, "/data/data/com.esmertec.android.jbed/location/"

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->nativeInitialization(Ljava/lang/String;)V

    .line 357
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 0
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 359
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 360
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    .line 361
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mHandler:Landroid/os/Handler;

    .line 362
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    .prologue
    .line 18
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mLocationManager:Landroid/location/LocationManager;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    .prologue
    .line 18
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLapiManager;
    .param p1, "x1"    # I
    .param p2, "x2"    # I

    .prologue
    .line 18
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->notifyNewState(II)V

    return-void
.end method

.method static synthetic access$500(II)V
    .locals 0
    .param p0, "x0"    # I
    .param p1, "x1"    # I

    .prologue
    .line 18
    invoke-static {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->notifyNative(II)V

    return-void
.end method

.method private checkProviders()Z
    .locals 5

    .prologue
    .line 388
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    if-nez v2, :cond_1

    .line 389
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mLocationManager:Landroid/location/LocationManager;

    invoke-virtual {v2}, Landroid/location/LocationManager;->getAllProviders()Ljava/util/List;

    move-result-object v1

    .line 390
    .local v1, "names":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    if-nez v1, :cond_0

    const/4 v2, 0x0

    .line 398
    .end local v1    # "names":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    :goto_0
    return v2

    .line 392
    .restart local v1    # "names":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    :cond_0
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v2

    new-array v2, v2, [Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    iput-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    .line 393
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_1
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v2

    if-ge v0, v2, :cond_1

    .line 394
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    new-instance v4, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    invoke-direct {v4, p0, v2}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;Ljava/lang/String;)V

    aput-object v4, v3, v0

    .line 395
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v2, v2, v0

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->onCreate()V

    .line 393
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 398
    .end local v0    # "i":I
    .end local v1    # "names":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    :cond_1
    const/4 v2, 0x1

    goto :goto_0
.end method

.method private static closeProvider(II)I
    .locals 1
    .param p0, "providerId"    # I
    .param p1, "nativeId"    # I

    .prologue
    .line 615
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-lt p0, v0, :cond_1

    .line 616
    :cond_0
    const/4 v0, -0x1

    .line 619
    :goto_0
    return v0

    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->disable(I)I

    move-result v0

    goto :goto_0
.end method

.method private static finalize(I)V
    .locals 1
    .param p0, "providerId"    # I

    .prologue
    .line 631
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-ge p0, v0, :cond_0

    .line 632
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->onDestroy()V

    .line 634
    :cond_0
    return-void
.end method

.method private static getLocation(I)[B
    .locals 9
    .param p0, "providerId"    # I

    .prologue
    const-string v5, ""

    .line 551
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v5, v5, p0

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->getLocation()Landroid/location/Location;

    move-result-object v2

    .line 553
    .local v2, "loc":Landroid/location/Location;
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 554
    .local v0, "bout":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 556
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    invoke-virtual {v2}, Landroid/location/Location;->getBearing()F

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeFloat(F)V

    .line 557
    const v5, 0x50001

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 558
    invoke-virtual {v2}, Landroid/location/Location;->getAltitude()D

    move-result-wide v5

    double-to-float v5, v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeFloat(F)V

    .line 559
    invoke-virtual {v2}, Landroid/location/Location;->getLatitude()D

    move-result-wide v5

    invoke-virtual {v3, v5, v6}, Ljava/io/DataOutputStream;->writeDouble(D)V

    .line 560
    invoke-virtual {v2}, Landroid/location/Location;->getLongitude()D

    move-result-wide v5

    invoke-virtual {v3, v5, v6}, Ljava/io/DataOutputStream;->writeDouble(D)V

    .line 561
    invoke-virtual {v2}, Landroid/location/Location;->getAccuracy()F

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeFloat(F)V

    .line 562
    invoke-virtual {v2}, Landroid/location/Location;->getAccuracy()F

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeFloat(F)V

    .line 563
    invoke-virtual {v2}, Landroid/location/Location;->getSpeed()F

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeFloat(F)V

    .line 576
    invoke-static {}, Ljava/util/Calendar;->getInstance()Ljava/util/Calendar;

    move-result-object v1

    .line 577
    .local v1, "cal":Ljava/util/Calendar;
    invoke-virtual {v1}, Ljava/util/Calendar;->getTimeZone()Ljava/util/TimeZone;

    move-result-object v4

    .line 578
    .local v4, "tz":Ljava/util/TimeZone;
    invoke-virtual {v2}, Landroid/location/Location;->getTime()J

    move-result-wide v5

    invoke-virtual {v4}, Ljava/util/TimeZone;->getRawOffset()I

    move-result v7

    int-to-long v7, v7

    add-long/2addr v5, v7

    invoke-virtual {v3, v5, v6}, Ljava/io/DataOutputStream;->writeLong(J)V

    .line 580
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v5, v5, p0

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->isEnabled()Z

    move-result v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 586
    const/4 v5, 0x0

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 592
    const-string v5, ""

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeUTF(Ljava/lang/String;)V

    .line 593
    const-string v5, ""

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeUTF(Ljava/lang/String;)V

    .line 594
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, ""

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v2}, Landroid/location/Location;->getExtras()Landroid/os/Bundle;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v5}, Ljava/io/DataOutputStream;->writeUTF(Ljava/lang/String;)V

    .line 596
    invoke-virtual {v3}, Ljava/io/DataOutputStream;->flush()V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 601
    .end local v1    # "cal":Ljava/util/Calendar;
    .end local v4    # "tz":Ljava/util/TimeZone;
    :goto_0
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v5

    return-object v5

    .line 597
    :catch_0
    move-exception v5

    goto :goto_0
.end method

.method private static getProviderCount()I
    .locals 1

    .prologue
    .line 411
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->checkProviders()Z

    move-result v0

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    :goto_0
    return v0

    :cond_0
    const/4 v0, -0x1

    goto :goto_0
.end method

.method private static getProviderInfos()[B
    .locals 9

    .prologue
    const/4 v8, 0x0

    const/4 v7, 0x1

    const/4 v6, 0x0

    .line 466
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-direct {v5}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->checkProviders()Z

    move-result v5

    if-nez v5, :cond_0

    move-object v5, v8

    .line 500
    :goto_0
    return-object v5

    .line 468
    :cond_0
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 469
    .local v0, "bout":Ljava/io/ByteArrayOutputStream;
    new-instance v2, Ljava/io/DataOutputStream;

    invoke-direct {v2, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 473
    .local v2, "out":Ljava/io/DataOutputStream;
    :try_start_0
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v5, v5

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 475
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v5, v5

    if-ge v1, v5, :cond_5

    .line 477
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v5, v5, v1

    invoke-virtual {v5}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->getProvider()Landroid/location/LocationProvider;

    move-result-object v3

    .line 478
    .local v3, "provider":Landroid/location/LocationProvider;
    if-nez v3, :cond_1

    move-object v5, v8

    goto :goto_0

    .line 481
    :cond_1
    invoke-virtual {v2, v1}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 482
    invoke-virtual {v3}, Landroid/location/LocationProvider;->getAccuracy()I

    move-result v4

    .line 483
    .local v4, "value":I
    if-ne v4, v7, :cond_3

    const/16 v4, 0xa

    .line 485
    :cond_2
    :goto_2
    invoke-virtual {v2, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 486
    invoke-virtual {v2, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 487
    const/16 v5, 0x1388

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 488
    invoke-virtual {v3}, Landroid/location/LocationProvider;->getPowerRequirement()I

    move-result v5

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 489
    invoke-virtual {v3}, Landroid/location/LocationProvider;->hasMonetaryCost()Z

    move-result v5

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 490
    invoke-virtual {v3}, Landroid/location/LocationProvider;->supportsSpeed()Z

    move-result v5

    if-eqz v5, :cond_4

    invoke-virtual {v3}, Landroid/location/LocationProvider;->supportsBearing()Z

    move-result v5

    if-eqz v5, :cond_4

    move v5, v7

    :goto_3
    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 491
    invoke-virtual {v3}, Landroid/location/LocationProvider;->supportsAltitude()Z

    move-result v5

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 492
    const/4 v5, 0x0

    invoke-virtual {v2, v5}, Ljava/io/DataOutputStream;->writeBoolean(Z)V

    .line 475
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 484
    :cond_3
    const/4 v5, 0x2

    if-ne v4, v5, :cond_2

    const/16 v4, 0x19

    goto :goto_2

    :cond_4
    move v5, v6

    .line 490
    goto :goto_3

    .line 495
    .end local v3    # "provider":Landroid/location/LocationProvider;
    .end local v4    # "value":I
    :cond_5
    invoke-virtual {v2}, Ljava/io/DataOutputStream;->flush()V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 500
    .end local v1    # "i":I
    :goto_4
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v5

    goto :goto_0

    .line 496
    :catch_0
    move-exception v5

    goto :goto_4
.end method

.method private static getProviderState(I)I
    .locals 1
    .param p0, "providerId"    # I

    .prologue
    .line 645
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-lt p0, v0, :cond_1

    .line 646
    :cond_0
    const/4 v0, 0x3

    .line 649
    :goto_0
    return v0

    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->getProviderState()I

    move-result v0

    goto :goto_0
.end method

.method private static interrupt(I)V
    .locals 1
    .param p0, "providerId"    # I

    .prologue
    .line 624
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-ge p0, v0, :cond_0

    .line 625
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->interrupt()V

    .line 627
    :cond_0
    return-void
.end method

.method private static log(Ljava/lang/String;)V
    .locals 0
    .param p0, "msg"    # Ljava/lang/String;

    .prologue
    .line 664
    return-void
.end method

.method private static native nativeInitialization(Ljava/lang/String;)V
.end method

.method private static native notifyNative(II)V
.end method

.method private notifyNewState(II)V
    .locals 3
    .param p1, "nativeId"    # I
    .param p2, "res"    # I

    .prologue
    .line 653
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mHandler:Landroid/os/Handler;

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 654
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 659
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 660
    return-void
.end method

.method private static notifyTimeout(II)V
    .locals 1
    .param p0, "providerId"    # I
    .param p1, "nativeId"    # I

    .prologue
    .line 638
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-ge p0, v0, :cond_0

    .line 639
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->notifyTimeout(I)V

    .line 641
    :cond_0
    return-void
.end method

.method private static openProvider(II)I
    .locals 1
    .param p0, "providerId"    # I
    .param p1, "nativeId"    # I

    .prologue
    .line 606
    if-ltz p0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    array-length v0, v0

    if-lt p0, v0, :cond_1

    .line 607
    :cond_0
    const/4 v0, -0x1

    .line 610
    :goto_0
    return v0

    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    aget-object v0, v0, p0

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->enable(I)I

    move-result v0

    goto :goto_0
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 365
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mLocationManager:Landroid/location/LocationManager;

    if-nez v0, :cond_0

    if-eqz p1, :cond_0

    .line 366
    const-string v0, "location"

    invoke-virtual {p1, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/location/LocationManager;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mLocationManager:Landroid/location/LocationManager;

    .line 368
    :cond_0
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    const/4 v0, 0x0

    .line 377
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mProviders:[Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    .line 378
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mLocationManager:Landroid/location/LocationManager;

    .line 379
    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    .line 380
    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->mHandler:Landroid/os/Handler;

    .line 381
    return-void
.end method
