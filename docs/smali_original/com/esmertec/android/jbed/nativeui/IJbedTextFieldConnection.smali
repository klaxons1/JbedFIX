.class public interface abstract Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
.super Ljava/lang/Object;
.source "IJbedTextFieldConnection.java"

# interfaces
.implements Landroid/os/IInterface;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection$Stub;
    }
.end annotation


# virtual methods
.method public abstract onTextChanged(ILjava/lang/String;)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method

.method public abstract requestRefresh(I)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method

.method public abstract setClient(Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method
