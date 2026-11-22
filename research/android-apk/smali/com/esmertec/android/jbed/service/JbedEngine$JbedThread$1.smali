.class Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;
.super Ljava/lang/Object;
.source "JbedEngine.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->setScreenInfo(IIIIIZZ)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

.field final synthetic val$maxSquareLength:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;I)V
    .locals 0

    .prologue
    .line 459
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    iput p2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->val$maxSquareLength:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    .line 461
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    iget-object v0, v0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->this$0:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1200(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I

    move-result v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-static {v2}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1300(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I

    move-result v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-static {v3}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1400(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I

    move-result v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-static {v4}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1500(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I

    move-result v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->this$1:Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    invoke-static {v5}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1600(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)I

    move-result v5

    iget v6, p0, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread$1;->val$maxSquareLength:I

    invoke-static/range {v0 .. v6}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$1700(Lcom/esmertec/android/jbed/service/JbedEngine;IIIIII)V

    .line 463
    return-void
.end method
