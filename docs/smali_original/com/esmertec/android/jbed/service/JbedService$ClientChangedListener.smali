.class public interface abstract Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;
.super Ljava/lang/Object;
.source "JbedService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "ClientChangedListener"
.end annotation


# virtual methods
.method public abstract onClientAttached(Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)V
.end method

.method public abstract onClientDetached()V
.end method
