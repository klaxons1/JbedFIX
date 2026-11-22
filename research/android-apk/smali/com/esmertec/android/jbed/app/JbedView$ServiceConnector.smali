.class public interface abstract Lcom/esmertec/android/jbed/app/JbedView$ServiceConnector;
.super Ljava/lang/Object;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "ServiceConnector"
.end annotation


# virtual methods
.method public abstract connect(Lcom/esmertec/android/jbed/app/JbedView$Callback;)V
.end method

.method public abstract disconnect()V
.end method

.method public abstract getAmsClient()Lcom/esmertec/android/jbed/ams/AmsClientBase;
.end method

.method public abstract getJbedConn()Lcom/esmertec/android/jbed/service/IJbedConnection;
.end method

.method public abstract getJbedService()Lcom/esmertec/android/jbed/service/IJbedService;
.end method

.method public abstract getTextFieldConn()Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
.end method
