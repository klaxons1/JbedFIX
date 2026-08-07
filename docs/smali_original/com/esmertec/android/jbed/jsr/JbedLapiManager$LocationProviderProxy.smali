.class Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;
.super Ljava/lang/Object;
.source "JbedLapiManager.java"

# interfaces
.implements Landroid/location/LocationListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedLapiManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "LocationProviderProxy"
.end annotation


# instance fields
.field private mEnableNotifiers:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private mInstance:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

.field private mLastLocation:Landroid/location/Location;

.field private mProvider:Landroid/location/LocationProvider;

.field private mStatus:I

.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;Ljava/lang/String;)V
    .locals 1
    .param p2, "name"    # Ljava/lang/String;

    .prologue
    .line 90
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 91
    invoke-static {p1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v0

    invoke-virtual {v0, p2}, Landroid/location/LocationManager;->getProvider(Ljava/lang/String;)Landroid/location/LocationProvider;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    .line 92
    new-instance v0, Landroid/location/Location;

    invoke-direct {v0, p2}, Landroid/location/Location;-><init>(Ljava/lang/String;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mLastLocation:Landroid/location/Location;

    .line 93
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mStatus:I

    .line 94
    iput-object p0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mInstance:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    .line 95
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    .line 96
    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)Landroid/location/LocationProvider;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    .prologue
    .line 83
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    .prologue
    .line 83
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mInstance:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    return-object v0
.end method


# virtual methods
.method public disable(I)I
    .locals 1
    .param p1, "nativeId"    # I

    .prologue
    .line 195
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    if-nez v0, :cond_0

    .line 196
    const/4 v0, -0x1

    .line 208
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public enable(I)I
    .locals 5
    .param p1, "nativeId"    # I

    .prologue
    const/4 v3, 0x2

    .line 141
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    if-nez v2, :cond_0

    .line 142
    const/4 v2, -0x1

    .line 181
    :goto_0
    return v2

    .line 145
    :cond_0
    const/4 v1, -0x3

    .line 147
    .local v1, "res":I
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->getLocation()Landroid/location/Location;

    move-result-object v0

    .line 148
    .local v0, "loc":Landroid/location/Location;
    if-eqz v0, :cond_1

    .line 149
    iput v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mStatus:I

    .line 152
    :cond_1
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mStatus:I

    if-ne v2, v3, :cond_2

    .line 154
    const/4 v1, 0x0

    :goto_1
    move v2, v1

    .line 181
    goto :goto_0

    .line 162
    :cond_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    monitor-enter v2

    .line 163
    :try_start_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v3

    if-gtz v3, :cond_3

    .line 177
    :cond_3
    if-eqz p1, :cond_4

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-interface {v3, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 178
    :cond_4
    monitor-exit v2

    goto :goto_1

    :catchall_0
    move-exception v3

    monitor-exit v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v3
.end method

.method public getLocation()Landroid/location/Location;
    .locals 3

    .prologue
    .line 114
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    invoke-virtual {v2}, Landroid/location/LocationProvider;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/location/LocationManager;->getLastKnownLocation(Ljava/lang/String;)Landroid/location/Location;

    move-result-object v0

    .line 116
    .local v0, "loc":Landroid/location/Location;
    if-nez v0, :cond_0

    .line 118
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v1

    const-string v2, "network"

    invoke-virtual {v1, v2}, Landroid/location/LocationManager;->getLastKnownLocation(Ljava/lang/String;)Landroid/location/Location;

    move-result-object v0

    .line 120
    :cond_0
    if-eqz v0, :cond_1

    .line 121
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mLastLocation:Landroid/location/Location;

    invoke-virtual {v1, v0}, Landroid/location/Location;->set(Landroid/location/Location;)V

    .line 126
    :goto_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mLastLocation:Landroid/location/Location;

    return-object v1

    .line 123
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mLastLocation:Landroid/location/Location;

    invoke-virtual {v1}, Landroid/location/Location;->reset()V

    goto :goto_0
.end method

.method public getProvider()Landroid/location/LocationProvider;
    .locals 1

    .prologue
    .line 111
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    return-object v0
.end method

.method public getProviderState()I
    .locals 1

    .prologue
    .line 258
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mStatus:I

    packed-switch v0, :pswitch_data_0

    .line 264
    const/4 v0, 0x3

    :goto_0
    return v0

    .line 260
    :pswitch_0
    const/4 v0, 0x1

    goto :goto_0

    .line 262
    :pswitch_1
    const/4 v0, 0x2

    goto :goto_0

    .line 258
    nop

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public interrupt()V
    .locals 5

    .prologue
    .line 217
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    monitor-enter v2

    .line 218
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 219
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    const/4 v4, -0x2

    invoke-static {v3, v1, v4}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V

    .line 218
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 220
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 221
    monitor-exit v2

    .line 222
    return-void

    .line 221
    :catchall_0
    move-exception v1

    monitor-exit v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public isEnabled()Z
    .locals 2

    .prologue
    .line 245
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    invoke-virtual {v1}, Landroid/location/LocationProvider;->getName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/location/LocationManager;->isProviderEnabled(Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public notifyTimeout(I)V
    .locals 4
    .param p1, "nativeId"    # I

    .prologue
    .line 231
    const/4 v0, 0x0

    .line 232
    .local v0, "i":I
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    monitor-enter v1

    .line 233
    :goto_0
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v2, v3}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v0

    const/4 v2, -0x1

    if-eq v0, v2, :cond_0

    .line 234
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v2, v0}, Ljava/util/List;->remove(I)Ljava/lang/Object;

    goto :goto_0

    .line 236
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2

    :cond_0
    :try_start_1
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 237
    return-void
.end method

.method public onCreate()V
    .locals 2

    .prologue
    .line 99
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$300(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/os/Handler;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 105
    return-void
.end method

.method public onDestroy()V
    .locals 1

    .prologue
    .line 108
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/location/LocationManager;->removeUpdates(Landroid/location/LocationListener;)V

    .line 109
    return-void
.end method

.method public onLocationChanged(Landroid/location/Location;)V
    .locals 1
    .param p1, "loc"    # Landroid/location/Location;

    .prologue
    .line 276
    if-eqz p1, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mLastLocation:Landroid/location/Location;

    invoke-virtual {v0, p1}, Landroid/location/Location;->set(Landroid/location/Location;)V

    .line 277
    :cond_0
    return-void
.end method

.method public onProviderDisabled(Ljava/lang/String;)V
    .locals 5
    .param p1, "provider"    # Ljava/lang/String;

    .prologue
    .line 345
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    if-eqz v1, :cond_1

    if-eqz p1, :cond_1

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    invoke-virtual {v1}, Landroid/location/LocationProvider;->getName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 346
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    monitor-enter v2

    .line 347
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 348
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    const/4 v4, -0x1

    invoke-static {v3, v1, v4}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V

    .line 347
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 349
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->clear()V

    .line 350
    monitor-exit v2

    .line 352
    .end local v0    # "i":I
    :cond_1
    return-void

    .line 350
    .restart local v0    # "i":I
    :catchall_0
    move-exception v1

    monitor-exit v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method

.method public onProviderEnabled(Ljava/lang/String;)V
    .locals 0
    .param p1, "provider"    # Ljava/lang/String;

    .prologue
    .line 330
    return-void
.end method

.method public onStatusChanged(Ljava/lang/String;ILandroid/os/Bundle;)V
    .locals 5
    .param p1, "provider"    # Ljava/lang/String;
    .param p2, "status"    # I
    .param p3, "extras"    # Landroid/os/Bundle;

    .prologue
    .line 304
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    if-eqz v2, :cond_2

    if-eqz p1, :cond_2

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mProvider:Landroid/location/LocationProvider;

    invoke-virtual {v2}, Landroid/location/LocationProvider;->getName()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 305
    iput p2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mStatus:I

    .line 307
    const/4 v2, 0x2

    if-ne p2, v2, :cond_0

    const/4 v2, 0x0

    move v1, v2

    .line 308
    .local v1, "res":I
    :goto_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    monitor-enter v3

    .line 309
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_1
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v2

    if-ge v0, v2, :cond_1

    .line 310
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    invoke-static {v4, v2, v1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$400(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V

    .line 309
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 307
    .end local v0    # "i":I
    .end local v1    # "res":I
    :cond_0
    const/4 v2, -0x1

    move v1, v2

    goto :goto_0

    .line 311
    .restart local v0    # "i":I
    .restart local v1    # "res":I
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->mEnableNotifiers:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 312
    monitor-exit v3

    .line 314
    .end local v0    # "i":I
    .end local v1    # "res":I
    :cond_2
    return-void

    .line 312
    .restart local v0    # "i":I
    .restart local v1    # "res":I
    :catchall_0
    move-exception v2

    monitor-exit v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2
.end method
