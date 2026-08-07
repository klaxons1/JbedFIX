.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->calculateSizeHints(III[I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field final synthetic val$heightSpec:I

.field final synthetic val$info:[I

.field final synthetic val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

.field final synthetic val$widthSpec:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;II[I)V
    .locals 0

    .prologue
    .line 195
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput-object p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    iput p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$widthSpec:I

    iput p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$heightSpec:I

    iput-object p5, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$info:[I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    .line 199
    new-instance v0, Landroid/widget/EditText;

    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 200
    .local v0, "dummyMeasureEditText":Landroid/widget/EditText;
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 201
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$widthSpec:I

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$heightSpec:I

    invoke-virtual {v0, v1, v2}, Landroid/widget/EditText;->measure(II)V

    .line 202
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$info:[I

    const/4 v2, 0x0

    iget-object v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$info:[I

    const/4 v4, 0x2

    invoke-virtual {v0}, Landroid/widget/EditText;->getMeasuredWidth()I

    move-result v5

    invoke-static {}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$900()I

    move-result v6

    add-int/2addr v5, v6

    aput v5, v3, v4

    aput v5, v1, v2

    .line 203
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$info:[I

    const/4 v2, 0x1

    iget-object v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->val$info:[I

    const/4 v4, 0x3

    invoke-virtual {v0}, Landroid/widget/EditText;->getMeasuredHeight()I

    move-result v5

    aput v5, v3, v4

    aput v5, v1, v2

    .line 206
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$1000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/lang/Object;

    move-result-object v1

    monitor-enter v1

    .line 207
    :try_start_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iget-object v2, v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$1000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->notify()V

    .line 208
    monitor-exit v1

    .line 209
    return-void

    .line 208
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2
.end method
