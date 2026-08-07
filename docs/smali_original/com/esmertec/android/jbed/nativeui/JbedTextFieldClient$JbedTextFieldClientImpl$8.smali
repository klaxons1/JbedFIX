.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->replaceText(IIILjava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field final synthetic val$id:I

.field final synthetic val$length:I

.field final synthetic val$offset:I

.field final synthetic val$text:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;ILjava/lang/String;II)V
    .locals 0

    .prologue
    .line 282
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$id:I

    iput-object p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$text:Ljava/lang/String;

    iput p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$offset:I

    iput p5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$length:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    .prologue
    .line 284
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v2, v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v2

    iget v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$id:I

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 285
    .local v1, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v1, :cond_0

    .line 293
    :goto_0
    return-void

    .line 288
    :cond_0
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getText()Landroid/text/Editable;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 289
    .local v0, "originalText":Ljava/lang/String;
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$text:Ljava/lang/String;

    if-eqz v2, :cond_1

    .line 290
    new-instance v2, Ljava/lang/StringBuffer;

    invoke-direct {v2, v0}, Ljava/lang/StringBuffer;-><init>(Ljava/lang/String;)V

    iget v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$offset:I

    iget v4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$offset:I

    iget v5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$length:I

    add-int/2addr v4, v5

    iget-object v5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$text:Ljava/lang/String;

    invoke-virtual {v2, v3, v4, v5}, Ljava/lang/StringBuffer;->replace(IILjava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setText(Ljava/lang/CharSequence;)V

    goto :goto_0

    .line 292
    :cond_1
    new-instance v2, Ljava/lang/StringBuffer;

    invoke-direct {v2, v0}, Ljava/lang/StringBuffer;-><init>(Ljava/lang/String;)V

    iget v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$offset:I

    iget v4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$offset:I

    iget v5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;->val$length:I

    add-int/2addr v4, v5

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuffer;->delete(II)Ljava/lang/StringBuffer;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setText(Ljava/lang/CharSequence;)V

    goto :goto_0
.end method
