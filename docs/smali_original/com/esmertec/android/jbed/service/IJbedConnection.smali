.class public interface abstract Lcom/esmertec/android/jbed/service/IJbedConnection;
.super Ljava/lang/Object;
.source "IJbedConnection.java"

# interfaces
.implements Landroid/os/IInterface;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/IJbedConnection$Stub;
    }
.end annotation


# virtual methods
.method public abstract getUiListener()Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method

.method public abstract setJbedClient(Lcom/esmertec/android/jbed/app/IJbedClient;)V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method
