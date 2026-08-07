.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->setPosition(IIIIIZI)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field final synthetic val$height:I

.field final synthetic val$id:I

.field final synthetic val$isTextBox:Z

.field final synthetic val$maxScrollbarWidth:I

.field final synthetic val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

.field final synthetic val$width:I

.field final synthetic val$x:I

.field final synthetic val$y:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;IIIIIZI)V
    .locals 0

    .prologue
    .line 146
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput-object p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    iput p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$x:I

    iput p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$y:I

    iput p5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$width:I

    iput p6, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$maxScrollbarWidth:I

    iput p7, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$height:I

    iput-boolean p8, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$isTextBox:Z

    iput p9, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$id:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    .prologue
    const/16 v4, -0x3e8

    .line 148
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setVisibility(I)V

    .line 149
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v0

    check-cast v0, Landroid/widget/AbsoluteLayout$LayoutParams;

    .line 150
    .local v0, "layout":Landroid/widget/AbsoluteLayout$LayoutParams;
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$x:I

    iput v1, v0, Landroid/widget/AbsoluteLayout$LayoutParams;->x:I

    .line 151
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$y:I

    iput v1, v0, Landroid/widget/AbsoluteLayout$LayoutParams;->y:I

    .line 155
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$width:I

    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v2, v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$600(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)I

    move-result v2

    iget v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$maxScrollbarWidth:I

    sub-int/2addr v2, v3

    invoke-static {v1, v2}, Ljava/lang/Math;->min(II)I

    move-result v1

    iput v1, v0, Landroid/widget/AbsoluteLayout$LayoutParams;->width:I

    .line 156
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$height:I

    iput v1, v0, Landroid/widget/AbsoluteLayout$LayoutParams;->height:I

    .line 157
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1, v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 158
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$isTextBox:Z

    if-eqz v1, :cond_0

    .line 159
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->requestFocus()Z

    .line 161
    :cond_0
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$x:I

    if-ne v1, v4, :cond_2

    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$y:I

    if-ne v1, v4, :cond_2

    .line 162
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clearFocus()V

    .line 175
    :cond_1
    :goto_0
    return-void

    .line 167
    :cond_2
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$id:I

    invoke-static {}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$700()I

    move-result v2

    if-ne v1, v2, :cond_3

    .line 168
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->requestFocus()Z

    .line 170
    :cond_3
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$id:I

    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v2, v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$800(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)I

    move-result v2

    if-ne v1, v2, :cond_1

    .line 171
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    const/4 v2, -0x1

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$802(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;I)I

    .line 172
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->requestFocus()Z

    goto :goto_0
.end method
