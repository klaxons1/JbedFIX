.class public abstract Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;
.super Landroid/os/Binder;
.source "IJbedVideoClient.java"

# interfaces
.implements Lcom/esmertec/android/jbed/app/IJbedVideoClient;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/IJbedVideoClient;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub$Proxy;
    }
.end annotation


# static fields
.field private static final DESCRIPTOR:Ljava/lang/String; = "com.esmertec.android.jbed.app.IJbedVideoClient"

.field static final TRANSACTION_getSnapshotFromCamera:I = 0x5

.field static final TRANSACTION_getSnapshotFromMedia:I = 0x4

.field static final TRANSACTION_operation:I = 0x2

.field static final TRANSACTION_prepareData:I = 0x1

.field static final TRANSACTION_reconnectCamera:I = 0x6

.field static final TRANSACTION_restorePlayerState:I = 0x7

.field static final TRANSACTION_setListener:I = 0x3

.field static final TRANSACTION_updateDisplayRect:I = 0x8

.field static final TRANSACTION_updateRegionRect:I = 0x9


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 14
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    .line 15
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p0, p0, v0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    .line 16
    return-void
.end method

.method public static asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/app/IJbedVideoClient;
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
    const-string v1, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-interface {p0, v1}, Landroid/os/IBinder;->queryLocalInterface(Ljava/lang/String;)Landroid/os/IInterface;

    move-result-object v0

    .line 27
    .local v0, "iin":Landroid/os/IInterface;
    if-eqz v0, :cond_1

    instance-of v1, v0, Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    if-eqz v1, :cond_1

    .line 28
    check-cast v0, Lcom/esmertec/android/jbed/app/IJbedVideoClient;

    .end local v0    # "iin":Landroid/os/IInterface;
    move-object v1, v0

    goto :goto_0

    .line 30
    .restart local v0    # "iin":Landroid/os/IInterface;
    :cond_1
    new-instance v1, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub$Proxy;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub$Proxy;-><init>(Landroid/os/IBinder;)V

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
    .locals 9
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
    const/4 v7, 0x1

    const-string v8, "com.esmertec.android.jbed.app.IJbedVideoClient"

    .line 38
    sparse-switch p1, :sswitch_data_0

    .line 154
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result v0

    :goto_0
    return v0

    .line 42
    :sswitch_0
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p3, v8}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    move v0, v7

    .line 43
    goto :goto_0

    .line 47
    :sswitch_1
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 49
    invoke-virtual {p2}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v1

    .line 50
    .local v1, "_arg0":Ljava/lang/String;
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->prepareData(Ljava/lang/String;)I

    move-result v6

    .line 51
    .local v6, "_result":I
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 52
    invoke-virtual {p3, v6}, Landroid/os/Parcel;->writeInt(I)V

    move v0, v7

    .line 53
    goto :goto_0

    .line 57
    .end local v1    # "_arg0":Ljava/lang/String;
    .end local v6    # "_result":I
    :sswitch_2
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 59
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 61
    .local v1, "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 63
    .local v2, "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 65
    .local v3, "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v4

    .line 67
    .local v4, "_arg3":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v5

    .local v5, "_arg4":I
    move-object v0, p0

    .line 68
    invoke-virtual/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->operation(IIIII)I

    move-result v6

    .line 69
    .restart local v6    # "_result":I
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 70
    invoke-virtual {p3, v6}, Landroid/os/Parcel;->writeInt(I)V

    move v0, v7

    .line 71
    goto :goto_0

    .line 75
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":I
    .end local v5    # "_arg4":I
    .end local v6    # "_result":I
    :sswitch_3
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 77
    invoke-virtual {p2}, Landroid/os/Parcel;->readStrongBinder()Landroid/os/IBinder;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/IJbedVideoClientListener$Stub;->asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;

    move-result-object v1

    .line 78
    .local v1, "_arg0":Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->setListener(Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;)V

    .line 79
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v0, v7

    .line 80
    goto :goto_0

    .line 84
    .end local v1    # "_arg0":Lcom/esmertec/android/jbed/app/IJbedVideoClientListener;
    :sswitch_4
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 85
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->getSnapshotFromMedia()Landroid/graphics/Bitmap;

    move-result-object v6

    .line 86
    .local v6, "_result":Landroid/graphics/Bitmap;
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 87
    if-eqz v6, :cond_0

    .line 88
    invoke-virtual {p3, v7}, Landroid/os/Parcel;->writeInt(I)V

    .line 89
    invoke-virtual {v6, p3, v7}, Landroid/graphics/Bitmap;->writeToParcel(Landroid/os/Parcel;I)V

    :goto_1
    move v0, v7

    .line 94
    goto :goto_0

    .line 92
    :cond_0
    const/4 v0, 0x0

    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeInt(I)V

    goto :goto_1

    .line 98
    .end local v6    # "_result":Landroid/graphics/Bitmap;
    :sswitch_5
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 99
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->getSnapshotFromCamera()[B

    move-result-object v6

    .line 100
    .local v6, "_result":[B
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 101
    invoke-virtual {p3, v6}, Landroid/os/Parcel;->writeByteArray([B)V

    move v0, v7

    .line 102
    goto/16 :goto_0

    .line 106
    .end local v6    # "_result":[B
    :sswitch_6
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 107
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->reconnectCamera()V

    .line 108
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v0, v7

    .line 109
    goto/16 :goto_0

    .line 113
    :sswitch_7
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 115
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_1

    .line 116
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->CREATOR:Landroid/os/Parcelable$Creator;

    invoke-interface {v0, p2}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;

    .line 121
    .local v1, "_arg0":Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    :goto_2
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->restorePlayerState(Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;)V

    .line 122
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v0, v7

    .line 123
    goto/16 :goto_0

    .line 119
    .end local v1    # "_arg0":Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    :cond_1
    const/4 v1, 0x0

    .restart local v1    # "_arg0":Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    goto :goto_2

    .line 127
    .end local v1    # "_arg0":Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
    :sswitch_8
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 129
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_2

    .line 130
    sget-object v0, Landroid/graphics/Rect;->CREATOR:Landroid/os/Parcelable$Creator;

    invoke-interface {v0, p2}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/Rect;

    .line 135
    .local v1, "_arg0":Landroid/graphics/Rect;
    :goto_3
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->updateDisplayRect(Landroid/graphics/Rect;)V

    .line 136
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v0, v7

    .line 137
    goto/16 :goto_0

    .line 133
    .end local v1    # "_arg0":Landroid/graphics/Rect;
    :cond_2
    const/4 v1, 0x0

    .restart local v1    # "_arg0":Landroid/graphics/Rect;
    goto :goto_3

    .line 141
    .end local v1    # "_arg0":Landroid/graphics/Rect;
    :sswitch_9
    const-string v0, "com.esmertec.android.jbed.app.IJbedVideoClient"

    invoke-virtual {p2, v8}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 143
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_3

    .line 144
    sget-object v0, Landroid/graphics/Rect;->CREATOR:Landroid/os/Parcelable$Creator;

    invoke-interface {v0, p2}, Landroid/os/Parcelable$Creator;->createFromParcel(Landroid/os/Parcel;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/graphics/Rect;

    .line 149
    .restart local v1    # "_arg0":Landroid/graphics/Rect;
    :goto_4
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/IJbedVideoClient$Stub;->updateRegionRect(Landroid/graphics/Rect;)V

    .line 150
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    move v0, v7

    .line 151
    goto/16 :goto_0

    .line 147
    .end local v1    # "_arg0":Landroid/graphics/Rect;
    :cond_3
    const/4 v1, 0x0

    .restart local v1    # "_arg0":Landroid/graphics/Rect;
    goto :goto_4

    .line 38
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_1
        0x2 -> :sswitch_2
        0x3 -> :sswitch_3
        0x4 -> :sswitch_4
        0x5 -> :sswitch_5
        0x6 -> :sswitch_6
        0x7 -> :sswitch_7
        0x8 -> :sswitch_8
        0x9 -> :sswitch_9
        0x5f4e5446 -> :sswitch_0
    .end sparse-switch
.end method
