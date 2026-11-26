.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->cretateTextField(I)V
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
    .line 112
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->val$id:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .prologue
    .line 114
    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/content/Context;

    move-result-object v1

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    .line 115
    .local v0, "editText":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    invoke-static {}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$200()Lcom/esmertec/android/jbed/service/IJbedUiListener;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->val$id:I

    iget-object v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v3, v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v3}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/content/Context;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v4, v4, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v4}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$300(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v4

    invoke-virtual {v0, v1, v2, v3, v4}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->init(Lcom/esmertec/android/jbed/service/IJbedUiListener;ILandroid/content/Context;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;)V

    .line 116
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->val$id:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 117
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$500(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/widget/AbsoluteLayout;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/widget/AbsoluteLayout;->addView(Landroid/view/View;)V

    .line 120
    const/4 v1, 0x4

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setVisibility(I)V

    .line 121
    const/16 v1, 0x33

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setGravity(I)V

    .line 123
    return-void
.end method
