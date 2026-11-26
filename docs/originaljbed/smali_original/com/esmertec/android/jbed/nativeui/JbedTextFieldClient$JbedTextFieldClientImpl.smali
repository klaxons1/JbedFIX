.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;
.super Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;
.source "JbedTextFieldClient.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "JbedTextFieldClientImpl"
.end annotation


# static fields
.field private static final HIDEN_POSITION:I = -0x3e8


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)V
    .locals 0

    .prologue
    .line 105
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient$Stub;-><init>()V

    return-void
.end method

.method private createAndRefresh(I)V
    .locals 3
    .param p1, "id"    # I

    .prologue
    .line 128
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->cretateTextField(I)V

    .line 130
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$300(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    move-result-object v1

    invoke-interface {v1, p1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;->requestRefresh(I)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 134
    return-void

    .line 131
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 132
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "NativeEditText fail to call requestRefresh"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private cretateTextField(I)V
    .locals 3
    .param p1, "id"    # I

    .prologue
    .line 112
    new-instance v0, Lcom/esmertec/android/jbed/util/SerialExecutor;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/util/SerialExecutor;-><init>()V

    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;

    invoke-direct {v2, p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$1;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;I)V

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/util/SerialExecutor;->execute(Landroid/os/Handler;Ljava/lang/Runnable;)V

    .line 125
    return-void
.end method


# virtual methods
.method public calculateSizeHints(III[I)V
    .locals 7
    .param p1, "id"    # I
    .param p2, "widthHint"    # I
    .param p3, "heightHint"    # I
    .param p4, "info"    # [I

    .prologue
    const/4 v6, 0x0

    const/high16 v5, -0x80000000

    .line 184
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 187
    .local v2, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v2, :cond_0

    .line 189
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->createAndRefresh(I)V

    .line 216
    :goto_0
    return-void

    .line 192
    :cond_0
    if-lez p2, :cond_1

    invoke-static {p2, v5}, Landroid/view/View$MeasureSpec;->makeMeasureSpec(II)I

    move-result v0

    move v3, v0

    .line 193
    .local v3, "widthSpec":I
    :goto_1
    if-lez p3, :cond_2

    invoke-static {p3, v5}, Landroid/view/View$MeasureSpec;->makeMeasureSpec(II)I

    move-result v0

    move v4, v0

    .line 195
    .local v4, "heightSpec":I
    :goto_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v6

    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;

    move-object v1, p0

    move-object v5, p4

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$3;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;II[I)V

    invoke-virtual {v6, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 211
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$1000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 213
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$1000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 215
    :goto_3
    :try_start_1
    monitor-exit v0

    goto :goto_0

    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v1

    .end local v3    # "widthSpec":I
    .end local v4    # "heightSpec":I
    :cond_1
    move v3, v6

    .line 192
    goto :goto_1

    .restart local v3    # "widthSpec":I
    :cond_2
    move v4, v6

    .line 193
    goto :goto_2

    .line 214
    .restart local v4    # "heightSpec":I
    :catch_0
    move-exception v1

    goto :goto_3
.end method

.method public create(I)V
    .locals 0
    .param p1, "id"    # I

    .prologue
    .line 180
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->cretateTextField(I)V

    .line 181
    return-void
.end method

.method public dispose(I)V
    .locals 2
    .param p1, "id"    # I

    .prologue
    .line 244
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;

    invoke-direct {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$5;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;I)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 251
    return-void
.end method

.method public getCaretPosition(I)I
    .locals 3
    .param p1, "id"    # I

    .prologue
    .line 321
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 322
    .local v0, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v0, :cond_0

    .line 323
    const/4 v1, -0x1

    .line 325
    :goto_0
    return v1

    :cond_0
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getSelectionEnd()I

    move-result v1

    goto :goto_0
.end method

.method public replaceText(IIILjava/lang/String;)V
    .locals 7
    .param p1, "id"    # I
    .param p2, "offset"    # I
    .param p3, "length"    # I
    .param p4, "text"    # Ljava/lang/String;

    .prologue
    .line 282
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v6

    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;

    move-object v1, p0

    move v2, p1

    move-object v3, p4

    move v4, p2

    move v5, p3

    invoke-direct/range {v0 .. v5}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$8;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;ILjava/lang/String;II)V

    invoke-virtual {v6, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 295
    return-void
.end method

.method public setClip(IIIII)V
    .locals 3
    .param p1, "id"    # I
    .param p2, "x"    # I
    .param p3, "y"    # I
    .param p4, "width"    # I
    .param p5, "height"    # I

    .prologue
    .line 267
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 268
    .local v0, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v0, :cond_0

    .line 279
    :goto_0
    return-void

    .line 271
    :cond_0
    invoke-static {}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$900()I

    move-result v1

    add-int/2addr v1, p4

    invoke-virtual {v0, p2, p3, v1, p5}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setClip(IIII)V

    .line 273
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;

    invoke-direct {v2, p0, v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V

    invoke-virtual {v1, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_0
.end method

.method public setConstraints(II)V
    .locals 2
    .param p1, "id"    # I
    .param p2, "constraints"    # I

    .prologue
    .line 298
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$9;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$9;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;II)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 310
    return-void
.end method

.method public setFocus(IZ)V
    .locals 2
    .param p1, "id"    # I
    .param p2, "focus"    # Z

    .prologue
    .line 219
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$4;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$4;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;IZ)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 241
    return-void
.end method

.method public setMaxSize(II)V
    .locals 3
    .param p1, "id"    # I
    .param p2, "maxSize"    # I

    .prologue
    .line 313
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 314
    .local v0, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v0, :cond_0

    .line 318
    :goto_0
    return-void

    .line 317
    :cond_0
    invoke-static {v0, p2}, Lcom/esmertec/android/jbed/util/EditTextHelper;->setMaxSize(Landroid/widget/EditText;I)V

    goto :goto_0
.end method

.method public setPosition(IIIIIZI)V
    .locals 11
    .param p1, "id"    # I
    .param p2, "x"    # I
    .param p3, "y"    # I
    .param p4, "width"    # I
    .param p5, "height"    # I
    .param p6, "isTextBox"    # Z
    .param p7, "maxScrollbarWidth"    # I

    .prologue
    .line 138
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;

    move-result-object v0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .line 140
    .local v2, "textField":Lcom/esmertec/android/jbed/nativeui/JbedEditText;
    if-nez v2, :cond_0

    .line 142
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->createAndRefresh(I)V

    .line 177
    :goto_0
    return-void

    .line 146
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v10

    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;

    move-object v1, p0

    move v3, p2

    move v4, p3

    move v5, p4

    move/from16 v6, p7

    move/from16 v7, p5

    move/from16 v8, p6

    move v9, p1

    invoke-direct/range {v0 .. v9}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$2;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;IIIIIZI)V

    invoke-virtual {v10, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_0
.end method

.method public setText(ILjava/lang/String;)V
    .locals 2
    .param p1, "id"    # I
    .param p2, "text"    # Ljava/lang/String;

    .prologue
    .line 255
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-static {v0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$6;

    invoke-direct {v1, p0, p1, p2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$6;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;ILjava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 264
    return-void
.end method
