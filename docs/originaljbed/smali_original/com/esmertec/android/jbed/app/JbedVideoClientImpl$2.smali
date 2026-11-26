.class Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$2;
.super Ljava/lang/Object;
.source "JbedVideoClientImpl.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->prepareData(Ljava/lang/String;)I
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)V
    .locals 0

    .prologue
    .line 384
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$2;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 386
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$2;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->callRequestLayout()V

    .line 387
    return-void
.end method
