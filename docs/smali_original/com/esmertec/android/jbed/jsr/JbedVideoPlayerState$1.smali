.class final Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$1;
.super Ljava/lang/Object;
.source "JbedVideoPlayerState.java"

# interfaces
.implements Landroid/os/Parcelable$Creator;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Landroid/os/Parcelable$Creator",
        "<",
        "Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;",
        ">;"
    }
.end annotation


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 140
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public createFromParcel(Landroid/os/Parcel;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    .locals 1
    .param p1, "source"    # Landroid/os/Parcel;

    .prologue
    .line 142
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    invoke-direct {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;-><init>(Landroid/os/Parcel;)V

    return-object v0
.end method

.method public bridge synthetic createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;
    .locals 1
    .param p1, "x0"    # Landroid/os/Parcel;

    .prologue
    .line 140
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$1;->createFromParcel(Landroid/os/Parcel;)Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    move-result-object v0

    return-object v0
.end method

.method public newArray(I)[Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    .locals 1
    .param p1, "size"    # I

    .prologue
    .line 146
    new-array v0, p1, [Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    return-object v0
.end method

.method public bridge synthetic newArray(I)[Ljava/lang/Object;
    .locals 1
    .param p1, "x0"    # I

    .prologue
    .line 140
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$1;->newArray(I)[Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    move-result-object v0

    return-object v0
.end method
