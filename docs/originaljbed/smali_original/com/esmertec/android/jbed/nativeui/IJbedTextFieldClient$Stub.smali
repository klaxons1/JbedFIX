.class public abstract Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;
.super Landroid/os/Binder;
.source "IJbedTextFieldClient.java"

# interfaces
.implements Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x409
    name = "Stub"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub$Proxy;
    }
.end annotation


# static fields
.field private static final DESCRIPTOR:Ljava/lang/String; = "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

.field static final TRANSACTION_calculateSizeHints:I = 0x3

.field static final TRANSACTION_create:I = 0x1

.field static final TRANSACTION_dispose:I = 0x5

.field static final TRANSACTION_getCaretPosition:I = 0xb

.field static final TRANSACTION_replaceText:I = 0x8

.field static final TRANSACTION_setClip:I = 0x7

.field static final TRANSACTION_setConstraints:I = 0x9

.field static final TRANSACTION_setFocus:I = 0x4

.field static final TRANSACTION_setMaxSize:I = 0xa

.field static final TRANSACTION_setPosition:I = 0x2

.field static final TRANSACTION_setText:I = 0x6


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 14
    invoke-direct {p0}, Landroid/os/Binder;-><init>()V

    .line 15
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p0, p0, v0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->attachInterface(Landroid/os/IInterface;Ljava/lang/String;)V

    .line 16
    return-void
.end method

.method public static asInterface(Landroid/os/IBinder;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;
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
    const-string v1, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-interface {p0, v1}, Landroid/os/IBinder;->queryLocalInterface(Ljava/lang/String;)Landroid/os/IInterface;

    move-result-object v0

    .line 27
    .local v0, "iin":Landroid/os/IInterface;
    if-eqz v0, :cond_1

    instance-of v1, v0, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_1

    .line 28
    check-cast v0, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    .end local v0    # "iin":Landroid/os/IInterface;
    move-object v1, v0

    goto :goto_0

    .line 30
    .restart local v0    # "iin":Landroid/os/IInterface;
    :cond_1
    new-instance v1, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub$Proxy;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub$Proxy;-><init>(Landroid/os/IBinder;)V

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

    .line 193
    invoke-super {p0, p1, p2, p3, p4}, Landroid/os/Binder;->onTransact(ILandroid/os/Parcel;Landroid/os/Parcel;I)Z

    move-result v0

    :goto_0
    return v0

    .line 42
    :sswitch_0
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p3, v0}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 43
    const/4 v0, 0x1

    goto :goto_0

    .line 47
    :sswitch_1
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 49
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 50
    .local v1, "_arg0":I
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->create(I)V

    .line 51
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 52
    const/4 v0, 0x1

    goto :goto_0

    .line 56
    .end local v1    # "_arg0":I
    :sswitch_2
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 58
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 60
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 62
    .local v2, "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 64
    .local v3, "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v4

    .line 66
    .local v4, "_arg3":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v5

    .line 68
    .local v5, "_arg4":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    move v6, v0

    .line 70
    .local v6, "_arg5":Z
    :goto_1
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v7

    .local v7, "_arg6":I
    move-object v0, p0

    .line 71
    invoke-virtual/range {v0 .. v7}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setPosition(IIIIIZI)V

    .line 72
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 73
    const/4 v0, 0x1

    goto :goto_0

    .line 68
    .end local v6    # "_arg5":Z
    .end local v7    # "_arg6":I
    :cond_0
    const/4 v0, 0x0

    move v6, v0

    goto :goto_1

    .line 77
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":I
    .end local v5    # "_arg4":I
    :sswitch_3
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 79
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 81
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 83
    .restart local v2    # "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 85
    .restart local v3    # "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v8

    .line 86
    .local v8, "_arg3_length":I
    if-gez v8, :cond_1

    .line 87
    const/4 v4, 0x0

    .line 92
    .local v4, "_arg3":[I
    :goto_2
    invoke-virtual {p0, v1, v2, v3, v4}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->calculateSizeHints(III[I)V

    .line 93
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 94
    invoke-virtual {p3, v4}, Landroid/os/Parcel;->writeIntArray([I)V

    .line 95
    const/4 v0, 0x1

    goto :goto_0

    .line 90
    .end local v4    # "_arg3":[I
    :cond_1
    new-array v4, v8, [I

    .restart local v4    # "_arg3":[I
    goto :goto_2

    .line 99
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":[I
    .end local v8    # "_arg3_length":I
    :sswitch_4
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 101
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 103
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-eqz v0, :cond_2

    const/4 v0, 0x1

    move v2, v0

    .line 104
    .local v2, "_arg1":Z
    :goto_3
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setFocus(IZ)V

    .line 105
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 106
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 103
    .end local v2    # "_arg1":Z
    :cond_2
    const/4 v0, 0x0

    move v2, v0

    goto :goto_3

    .line 110
    .end local v1    # "_arg0":I
    :sswitch_5
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 112
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 113
    .restart local v1    # "_arg0":I
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->dispose(I)V

    .line 114
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 115
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 119
    .end local v1    # "_arg0":I
    :sswitch_6
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 121
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 123
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v2

    .line 124
    .local v2, "_arg1":Ljava/lang/String;
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setText(ILjava/lang/String;)V

    .line 125
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 126
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 130
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":Ljava/lang/String;
    :sswitch_7
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 132
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 134
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 136
    .local v2, "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 138
    .restart local v3    # "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v4

    .line 140
    .local v4, "_arg3":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v5

    .restart local v5    # "_arg4":I
    move-object v0, p0

    .line 141
    invoke-virtual/range {v0 .. v5}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setClip(IIIII)V

    .line 142
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 143
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 147
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":I
    .end local v5    # "_arg4":I
    :sswitch_8
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 149
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 151
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 153
    .restart local v2    # "_arg1":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v3

    .line 155
    .restart local v3    # "_arg2":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v4

    .line 156
    .local v4, "_arg3":Ljava/lang/String;
    invoke-virtual {p0, v1, v2, v3, v4}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->replaceText(IIILjava/lang/String;)V

    .line 157
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 158
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 162
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    .end local v3    # "_arg2":I
    .end local v4    # "_arg3":Ljava/lang/String;
    :sswitch_9
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 164
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 166
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 167
    .restart local v2    # "_arg1":I
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setConstraints(II)V

    .line 168
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 169
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 173
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    :sswitch_a
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 175
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 177
    .restart local v1    # "_arg0":I
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v2

    .line 178
    .restart local v2    # "_arg1":I
    invoke-virtual {p0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->setMaxSize(II)V

    .line 179
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 180
    const/4 v0, 0x1

    goto/16 :goto_0

    .line 184
    .end local v1    # "_arg0":I
    .end local v2    # "_arg1":I
    :sswitch_b
    const-string v0, "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient"

    invoke-virtual {p2, v0}, Landroid/os/Parcel;->enforceInterface(Ljava/lang/String;)V

    .line 186
    invoke-virtual {p2}, Landroid/os/Parcel;->readInt()I

    move-result v1

    .line 187
    .restart local v1    # "_arg0":I
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;->getCaretPosition(I)I

    move-result v9

    .line 188
    .local v9, "_result":I
    invoke-virtual {p3}, Landroid/os/Parcel;->writeNoException()V

    .line 189
    invoke-virtual {p3, v9}, Landroid/os/Parcel;->writeInt(I)V

    .line 190
    const/4 v0, 0x1

    goto/16 :goto_0

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
        0xa -> :sswitch_a
        0xb -> :sswitch_b
        0x5f4e5446 -> :sswitch_0
    .end sparse-switch
.end method
