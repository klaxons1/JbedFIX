.class public interface abstract Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;
.super Ljava/lang/Object;
.source "JbedMediaManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "Playable"
.end annotation


# virtual methods
.method public abstract getDataSource()Ljava/lang/String;
.end method

.method public abstract getNativeContext()I
.end method

.method public abstract getPrepareDataMethod()I
.end method

.method public abstract operation(IIIII)I
.end method

.method public abstract prepareData()V
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation
.end method
