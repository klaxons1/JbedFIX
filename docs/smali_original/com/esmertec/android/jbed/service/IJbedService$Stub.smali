.class public abstract Lcom/esmertec/android/jbed/service/IJbedService$Stub;
.super Landroid/os/Binder;
.source "IJbedService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/IJbedService;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/IJbedService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/IJbedService$Stub$Proxy;
    }
.end annotation


# static fields
.field private static final DESCRIPTOR:Ljava/lang/String; = "com.esmertec.android.jbed.service.IJbedService"

.field static final TRANSACTION_openAmsConnection:I = 0x4

.field static final TRANSACTION_openConnection:I = 0x3

.field static final TRANSACTION_openTextFieldConnection:I = 0x5

.field static final TRANSACTION_requestVmBackground:I = 0x9

.field static final TRANSACTION_setRotateHappen:I = 0x7

.field static final TRANSACTION_setStartWay:I = 0x8

.field static final TRANSACTION_setVmState:I = 0x6

.field static final TRANSACTION_shutdownVm:I = 0x2

.field static final TRANSACTION_startVm:I = 0x1


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 14
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    .line 15
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p0, p0, v0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    .line 16
    return-void
.end method

.method public static asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/service/IJbedService;
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
    const-string v1, "com.esmertec.android.jbed.service.IJbedService"

    invoke-interface {p0, v1}, Landroid/os/IBinder;->queryLocalInterface(Ljava/lang/String;)Landroid/os/IInterface;

    move-result-object v0

    .line 27
    .local v0, "iin":Landroid/os/IInterface;
    if-eqz v0, :cond_1

    instance-of v1, v0, Lcom/esmertec/android/jbed/service/IJbedService;

    if-eqz v1, :cond_1

    .line 28
    check-cast v0, Lcom/esmertec/android/jbed/service/IJbedService;

    .end local v0    # "iin":Landroid/os/IInterface;
    move-object v1, v0

    goto :goto_0

    .line 30
    .restart local v0    # "iin":Landroid/os/IInterface;
    :cond_1
    new-instance v1, Lcom/esmertec/android/jbed/service/IJbedService$Stub$Proxy;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub$Proxy;-><init>(Landroid/os/IBinder;)V

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
    .line 38
    sparse-switch p1, :sswitch_data_0

    .line 134
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result v0

    :goto_0
    return v0

    .line 42
    :sswitch_0
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 43
    const/4 v0, 0x1

    goto :goto_0

    .line 47
    :sswitch_1
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

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

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    move v6, v0

    .line 61
    .local v6, "_arg5":Z
    :goto_1
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_1

    const/4 v0, 0x1

    move v7, v0

    .local v7, "_arg6":Z
    :goto_2
    move-object v0, p0

    .line 62
    invoke-virtual/range {v0 .. v7}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->startVm(IIIIIZZ)V

    .line 63
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 64
    const/4 v0, 0x1

    goto :goto_0

    .line 59
    .end local v6    # "_arg5":Z
    .end local v7    # "_arg6":Z
    :cond_0
    const/4 v0, 0x0

    move v6, v0

    goto :goto_1

    .line 61
    .restart local v6    # "_arg5":Z
    :cond_1
    const/4 v0, 0x0

    move v7, v0

    goto :goto_2

    .line 68
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":I
    .end local v5    # "_arg4":I
    .end local v6    # "_arg5":Z
    :sswitch_2
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 69
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->shutdownVm()V

    .line 70
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 71
    const/4 v0, 0x1

    goto :goto_0

    .line 75
    :sswitch_3
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 76
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->openConnection()Lcom/esmertec/android/jbed/service/IJbedConnection;

    move-result-object v8

    .line 77
    .local v8, "_result":Lcom/esmertec/android/jbed/service/IJbedConnection;
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 78
    if-eqz v8, :cond_2

    invoke-interface {v8}, Lcom/esmertec/android/jbed/service/IJbedConnection;->asBinder()Landroid/os/IBinder;

    move-result-object v0

    :goto_3
    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V

    .line 79
    const/4 v0, 0x1

    goto :goto_0

    .line 78
    :cond_2
    const/4 v0, 0x0

    goto :goto_3

    .line 83
    .end local v8    # "_result":Lcom/esmertec/android/jbed/service/IJbedConnection;
    :sswitch_4
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 84
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->openAmsConnection()Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;

    move-result-object v8

    .line 85
    .local v8, "_result":Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 86
    if-eqz v8, :cond_3

    invoke-interface {v8}, Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;->asBinder()Landroid/os/IBinder;

    move-result-object v0

    :goto_4
    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V

    .line 87
    const/4 v0, 0x1

    goto :goto_0

    .line 86
    :cond_3
    const/4 v0, 0x0

    goto :goto_4

    .line 91
    .end local v8    # "_result":Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    :sswitch_5
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 92
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->openTextFieldConnection()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v8

    .line 93
    .local v8, "_result":Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 94
    if-eqz v8, :cond_4

    invoke-interface {v8}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;->asBinder()Landroid/os/IBinder;

    move-result-object v0

    :goto_5
    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeStrongBinder(Landroid/os/IBinder;)V

    .line 95
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 94
    :cond_4
    const/4 v0, 0x0

    goto :goto_5

    .line 99
    .end local v8    # "_result":Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    :sswitch_6
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 101
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 103
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 104
    .restart local v2    # "_arg1":I
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->setVmState(II)V

    .line 105
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 106
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 110
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    :sswitch_7
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 112
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_5

    const/4 v0, 0x1

    move v1, v0

    .line 113
    .local v1, "_arg0":Z
    :goto_6
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->setRotateHappen(Z)V

    .line 114
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 115
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 112
    .end local v1    # "_arg0":Z
    :cond_5
    const/4 v0, 0x0

    move v1, v0

    goto :goto_6

    .line 119
    :sswitch_8
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 121
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_6

    const/4 v0, 0x1

    move v1, v0

    .line 122
    .restart local v1    # "_arg0":Z
    :goto_7
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->setStartWay(Z)V

    .line 123
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 124
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 121
    .end local v1    # "_arg0":Z
    :cond_6
    const/4 v0, 0x0

    move v1, v0

    goto :goto_7

    .line 128
    :sswitch_9
    const-string v0, "com.esmertec.android.jbed.service.IJbedService"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 129
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/IJbedService$Stub;->requestVmBackground()V

    .line 130
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 131
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 38
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
