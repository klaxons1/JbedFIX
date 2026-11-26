.class public interface abstract Lcom/esmertec/android/jbed/service/IJbedUiListener;
.super Ljava/lang/Object;
.source "IJbedUiListener.java"

# interfaces
.implements Landroid/os/IInterface;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/IJbedUiListener$Stub;
    }
.end annotation


# virtual methods
.method public abstract notifyOnKey(Landroid/view/KeyEvent;)Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method

.method public abstract notifyOnTouchEvent(III)Z
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/RemoteException;
        }
    .end annotation
.end method
