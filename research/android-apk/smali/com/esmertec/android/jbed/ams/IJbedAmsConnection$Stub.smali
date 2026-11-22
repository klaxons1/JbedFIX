.class public abstract Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;
.super Landroid/os/Binder;
.source "IJbedAmsConnection.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub$Proxy;
    }
.end annotation


# static fields
.field private static final DESCRIPTOR:Ljava/lang/String; = "com.esmertec.android.jbed.ams.IJbedAmsConnection"

.field static final TRANSACTION_getRunningMidletList:I = 0x5

.field static final TRANSACTION_onClientConnected:I = 0x3

.field static final TRANSACTION_onClientDisconnected:I = 0x4

.field static final TRANSACTION_requestEvent:I = 0x1

.field static final TRANSACTION_setPowerOnMidlets:I = 0x2


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 14
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    .line 15
    const-string v0, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p0, p0, v0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    .line 16
    return-void
.end method

.method public static asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .locals 2
    .param p0, "obj"    # Landroid/os/IBinder;

    .prologue
    .line 23
    if-nez p0, :cond_0

    .line 24
    const/4 v1, 0x0

    .line 30
    :goto_0
    return-object v1

    .line 26
    :cond_0
    const-string v1, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-interface {p0, v1}, Landroid/os/IBinder;->queryLocalInterface(Ljava/lang/String;)Landroid/os/IInterface;

    move-result-object v0

    .line 27
    .local v0, "iin":Landroid/os/IInterface;
    if-eqz v0, :cond_1

    instance-of v1, v0, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    if-eqz v1, :cond_1

    .line 28
    check-cast v0, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    .end local v0    # "iin":Landroid/os/IInterface;
    move-object v1, v0

    goto :goto_0

    .line 30
    .restart local v0    # "iin":Landroid/os/IInterface;
    :cond_1
    new-instance v1, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub$Proxy;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub$Proxy;-><init>(Landroid/os/IBinder;)V

    goto :goto_0
.end method


# virtual methods
.method public asBinder()Landroid/os/IBinder;
    .locals 0

    .prologue
    .line 34
    return-object p0
.end method

.method public onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z
    .locals 8
    .param p1, "code"    # I
    .param p2, "data"    # Landroid/os/Parcel;
    .param p3, "reply"    # Landroid/os/Parcel;
    .param p4, "flags"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation

    .prologue
    const/4 v6, 0x1

    const-string v7, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    .line 38
    sparse-switch p1, :sswitch_data_0

    .line 94
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result v5

    :goto_0
    return v5

    .line 42
    :sswitch_0
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p3, v7}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    move v5, v6

    .line 43
    goto :goto_0

    .line 47
    :sswitch_1
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p2, v7}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 49
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    .line 51
    .local v0, "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 53
    .local v2, "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->createByteArray()[B

    move-result-object v3

    .line 54
    .local v3, "_arg2":[B
    invoke-virtual {p0, v0, v2, v3}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->requestEvent(II[B)V

    .line 55
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v5, v6

    .line 56
    goto :goto_0

    .line 60
    .end local v0    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":[B
    :sswitch_2
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p2, v7}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 62
    sget-object v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->CREATOR:Landroid/os/Parcelable$Creator;

    invoke-virtual {p2, v5}, Landroid/os/Parcel;->createTypedArrayList(Landroid/os/Parcelable$Creator;)Ljava/util/ArrayList;

    move-result-object v1

    .line 63
    .local v1, "_arg0":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->setPowerOnMidlets(Ljava/util/List;)V

    .line 64
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v5, v6

    .line 65
    goto :goto_0

    .line 69
    .end local v1    # "_arg0":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :sswitch_3
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p2, v7}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 71
    invoke-virtual {p2}, Landroid/os/Parcel;->readStrongBinder()Landroid/os/IBinder;

    move-result-object v5

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v0

    .line 72
    .local v0, "_arg0":Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->onClientConnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V

    .line 73
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v5, v6

    .line 74
    goto :goto_0

    .line 78
    .end local v0    # "_arg0":Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    :sswitch_4
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p2, v7}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 80
    invoke-virtual {p2}, Landroid/os/Parcel;->readStrongBinder()Landroid/os/IBinder;

    move-result-object v5

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/IJbedAmsClient$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v0

    .line 81
    .restart local v0    # "_arg0":Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->onClientDisconnected(Lcom/esmertec/android/jbed/ams/IJbedAmsClient;)V

    .line 82
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v5, v6

    .line 83
    goto :goto_0

    .line 87
    .end local v0    # "_arg0":Lcom/esmertec/android/jbed/ams/IJbedAmsClient;
    :sswitch_5
    const-string v5, "com.esmertec.android.jbed.ams.IJbedAmsConnection"

    invoke-virtual {p2, v7}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 88
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection$Stub;->getRunningMidletList()Ljava/util/List;

    move-result-object v4

    .line 89
    .local v4, "_result":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 90
    invoke-virtual {p3, v4}, Landroid/os/Parcel;->writeTypedList(Ljava/util/List;)V

    move v5, v6

    .line 91
    goto :goto_0

    .line 38
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_1
        0x2 -> :sswitch_2
        0x3 -> :sswitch_3
        0x4 -> :sswitch_4
        0x5 -> :sswitch_5
        0x5f4e5446 -> :sswitch_0
    .end sparse-switch
.end method
