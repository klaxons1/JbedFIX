.class Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;
.super Ljava/lang/Object;
.source "JbedLapiManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->notifyNewState(II)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

.field final synthetic val$nativeId:I

.field final synthetic val$res:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLapiManager;II)V
    .locals 0

    .prologue
    .line 654
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iput p2, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;->val$nativeId:I

    iput p3, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;->val$res:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 656
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;->val$nativeId:I

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLapiManager$1;->val$res:I

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;->access$500(II)V

    .line 657
    return-void
.end method
