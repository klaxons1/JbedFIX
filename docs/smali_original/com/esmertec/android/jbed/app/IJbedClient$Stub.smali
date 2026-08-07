.class public abstract Lcom/esmertec/android/jbed/app/IJbedClient$Stub;
.super Landroid/os/Binder;
.source "IJbedClient.java"

# interfaces
.implements Lcom/esmertec/android/jbed/app/IJbedClient;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/IJbedClient;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/app/IJbedClient$Stub$Proxy;
    }
.end annotation


# static fields
.field private static final DESCRIPTOR:Ljava/lang/String; = "com.esmertec.android.jbed.app.IJbedClient"

.field static final TRANSACTION_finish:I = 0x2

.field static final TRANSACTION_getVideoClient:I = 0x3

.field static final TRANSACTION_onSoftButtonChanged:I = 0x4

.field static final TRANSACTION_repaint:I = 0x1


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 14
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    .line 15
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p0, p0, v0}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    .line 16
    return-void
.end method

.method public static asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/app/IJbedClient;
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
    const-string v1, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-interface {p0, v1}, Landroid/os/IBinder;->queryLocalInterface(Ljava/lang/String;)Landroid/os/IInterface;

    move-result-object v0

    .line 27
    .local v0, "iin":Landroid/os/IInterface;
    if-eqz v0, :cond_1

    instance-of v1, v0, Lcom/esmertec/android/jbed/app/IJbedClient;

    if-eqz v1, :cond_1

    .line 28
    check-cast v0, Lcom/esmertec/android/jbed/app/IJbedClient;

    .end local v0    # "iin":Landroid/os/IInterface;
    move-object v1, v0

    goto :goto_0

    .line 30
    .restart local v0    # "iin":Landroid/os/IInterface;
    :cond_1
    new-instance v1, Lcom/esmertec/android/jbed/app/IJbedClient$Stub$Proxy;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub$Proxy;-><init>(Landroid/os/IBinder;)V

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
    .locals 10
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
    .line 38
    sparse-switch p1, :sswitch_data_0

    .line 95
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result v0

    :goto_0
    return v0

    .line 42
    :sswitch_0
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 43
    const/4 v0, 0x1

    goto :goto_0

    .line 47
    :sswitch_1
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 49
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 51
    .local v1, "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 53
    .local v2, "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 55
    .local v3, "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v4

    .line 57
    .local v4, "_arg3":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v5

    .line 59
    .local v5, "_arg4":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v6

    .line 61
    .local v6, "_arg5":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readFloat()F

    move-result v7

    .line 63
    .local v7, "_arg6":F
    invoke-virtual {p2}, Landroid/os/Parcel;->readFloat()F

    move-result v8

    .local v8, "_arg7":F
    move-object v0, p0

    .line 64
    invoke-virtual/range {v0 .. v8}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;->repaint(IIIIIIFF)V

    .line 65
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 66
    const/4 v0, 0x1

    goto :goto_0

    .line 70
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":I
    .end local v5    # "_arg4":I
    .end local v6    # "_arg5":I
    .end local v7    # "_arg6":F
    .end local v8    # "_arg7":F
    :sswitch_2
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 71
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;->finish()V

    .line 72
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 73
    const/4 v0, 0x1

    goto :goto_0

    .line 77
    :sswitch_3
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 78
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;->getVideoClient()Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    move-result-object v9

    .line 79
    .local v9, "_result":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 80
    if-eqz v9, :cond_0

    invoke-interface {v9}, Lcom/esmertec/android/jbed/app/IJbedVideoClient;->asBinder()Landroid/os/IBinder;

    move-result-object v0

    :goto_1
    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V

    .line 81
    const/4 v0, 0x1

    goto :goto_0

    .line 80
    :cond_0
    const/4 v0, 0x0

    goto :goto_1

    .line 85
    .end local v9    # "_result":Lcom/esmertec/android/jbed/app/IJbedVideoClient;
    :sswitch_4
    const-string v0, "com.esmertec.android.jbed.app.IJbedClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 87
    invoke-virtual {p2}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v1

    .line 89
    .local v1, "_arg0":Ljava/lang/String;
    invoke-virtual {p2}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v2

    .line 90
    .local v2, "_arg1":Ljava/lang/String;
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/app/IJbedClient$Stub;->onSoftButtonChanged(Ljava/lang/String;Ljava/lang/String;)V

    .line 91
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 92
    const/4 v0, 0x1

    goto :goto_0

    .line 38
    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_1
        0x2 -> :sswitch_2
        0x3 -> :sswitch_3
        0x4 -> :sswitch_4
        0x5f4e5446 -> :sswitch_0
    .end sparse-switch
.end method
