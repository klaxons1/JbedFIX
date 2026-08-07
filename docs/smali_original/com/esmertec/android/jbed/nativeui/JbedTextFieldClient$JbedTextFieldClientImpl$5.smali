.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->dispose(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field final synthetic val$id:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;I)V
    .locals 0

    .prologue
    .line 244
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->val$id:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 246
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$500(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/widget/AbsoluteLayout;

    move-result-object v1

    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v0

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->val$id:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/View;

    invoke-virtual {v1, v0}, Landroid/widget/AbsoluteLayout;->removeView(Landroid/view/View;)V

    .line 247
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;->val$id:I

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 248
    return-void
.end method
