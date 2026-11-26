.class Lcom/esmertec/android/jbed/service/JbedEngine$2;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedEngine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/service/JbedEngine;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 0

    .prologue
    .line 170
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$2;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 173
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 177
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$2;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->stopVmAndWait()V

    .line 178
    return-void
.end method
