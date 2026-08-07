.class Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;
.super Ljava/lang/Object;
.source "JbedLapiManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->onCreate()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)V
    .locals 0

    .prologue
    .line 99
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    .prologue
    .line 101
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;)Landroid/location/LocationManager;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->access$100(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)Landroid/location/LocationProvider;

    move-result-object v1

    invoke-virtual {v1}, Landroid/location/LocationProvider;->getName()Ljava/lang/String;

    move-result-object v1

    const-wide/16 v2, 0x0

    const/4 v4, 0x0

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;->access$200(Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;)Lcom/esmertec/android/jbed/jsr/JbedLapiManager$LocationProviderProxy;

    move-result-object v5

    invoke-virtual/range {v0 .. v5}, Landroid/location/LocationManager;->requestLocationUpdates(Ljava/lang/String;JFLandroid/location/LocationListener;)V

    .line 103
    return-void
.end method
