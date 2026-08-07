.class Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;
.super Lcom/esmertec/android/jbed/service/IJbedUiListener$Stub;
.source "JbedLcduiManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)V
    .locals 0

    .prologue
    .line 98
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/IJbedUiListener$Stub;-><init>()V

    return-void
.end method

.method private sendRawEvent(I)V
    .locals 3
    .param p1, "event"    # I

    .prologue
    .line 101
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$200(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Landroid/os/Handler;

    move-result-object v0

    const/4 v1, 0x5

    const/4 v2, 0x0

    invoke-virtual {v0, v1, p1, v2}, Landroid/os/Handler;->obtainMessage(III)Landroid/os/Message;

    move-result-object v0

    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 102
    return-void
.end method


# virtual methods
.method public notifyOnKey(Landroid/view/KeyEvent;)Z
    .locals 13
    .param p1, "keyEvent"    # Landroid/view/KeyEvent;
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 105
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v6

    .line 106
    .local v6, "keyCode":I
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result v5

    .line 107
    .local v5, "keyAction":I
    move-object v0, p1

    .line 113
    .local v0, "event":Landroid/view/KeyEvent;
    const/16 v1, -0x64

    if-ne v6, v1, :cond_0

    .line 114
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$200(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x3

    new-instance v3, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1$1;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;)V

    invoke-virtual {v1, v2, v3}, Landroid/os/Handler;->obtainMessage(ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    invoke-virtual {v1}, Landroid/os/Message;->sendToTarget()V

    .line 119
    const/4 v1, 0x1

    .line 172
    :goto_0
    return v1

    .line 126
    :cond_0
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$400()Z

    move-result v1

    const/4 v2, 0x1

    if-ne v1, v2, :cond_4

    invoke-virtual {p1}, Landroid/view/KeyEvent;->isPrintingKey()Z

    move-result v1

    if-eqz v1, :cond_4

    const/16 v1, 0x1d

    if-eq v6, v1, :cond_4

    const/16 v1, 0x20

    if-eq v6, v1, :cond_4

    const/16 v1, 0x21

    if-eq v6, v1, :cond_4

    const/16 v1, 0x2a

    if-eq v6, v1, :cond_4

    const/16 v1, 0x29

    if-eq v6, v1, :cond_4

    const/16 v1, 0x33

    if-eq v6, v1, :cond_4

    const/16 v1, 0x2f

    if-eq v6, v1, :cond_4

    const/16 v1, 0x36

    if-eq v6, v1, :cond_4

    .line 129
    new-instance v0, Landroid/view/KeyEvent;

    .end local v0    # "event":Landroid/view/KeyEvent;
    const-wide/16 v1, 0x0

    const-wide/16 v3, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x2

    invoke-direct/range {v0 .. v8}, Landroid/view/KeyEvent;-><init>(JJIIII)V

    .line 134
    .restart local v0    # "event":Landroid/view/KeyEvent;
    :cond_1
    :goto_1
    const/4 v1, 0x1

    if-ne v5, v1, :cond_2

    .line 135
    const/16 v1, 0x39

    if-ne v6, v1, :cond_6

    const/4 v1, 0x1

    :goto_2
    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$402(Z)Z

    .line 136
    const/16 v1, 0x3b

    if-ne v6, v1, :cond_7

    const/4 v1, 0x1

    :goto_3
    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$502(Z)Z

    .line 142
    :cond_2
    const/4 v1, 0x1

    if-eq v6, v1, :cond_3

    const/4 v1, 0x4

    if-eq v6, v1, :cond_3

    const/16 v1, 0x18

    if-eq v6, v1, :cond_3

    const/16 v1, 0x19

    if-eq v6, v1, :cond_3

    const/4 v1, 0x5

    if-eq v6, v1, :cond_3

    const/16 v1, 0x52

    if-eq v6, v1, :cond_3

    const/16 v1, 0x3c

    if-eq v6, v1, :cond_3

    const/16 v1, 0x3a

    if-eq v6, v1, :cond_3

    const/16 v1, 0x3f

    if-ne v6, v1, :cond_8

    .line 154
    :cond_3
    const/4 v1, 0x0

    goto :goto_0

    .line 130
    :cond_4
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$500()Z

    move-result v1

    const/4 v2, 0x1

    if-ne v1, v2, :cond_1

    invoke-virtual {p1}, Landroid/view/KeyEvent;->isPrintingKey()Z

    move-result v1

    if-eqz v1, :cond_1

    const/4 v1, 0x7

    if-lt v6, v1, :cond_5

    const/16 v1, 0x10

    if-le v6, v1, :cond_1

    :cond_5
    const/16 v1, 0x38

    if-eq v6, v1, :cond_1

    .line 132
    new-instance v0, Landroid/view/KeyEvent;

    .end local v0    # "event":Landroid/view/KeyEvent;
    const-wide/16 v1, 0x0

    const-wide/16 v3, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x1

    invoke-direct/range {v0 .. v8}, Landroid/view/KeyEvent;-><init>(JJIIII)V

    .restart local v0    # "event":Landroid/view/KeyEvent;
    goto :goto_1

    .line 135
    :cond_6
    const/4 v1, 0x0

    goto :goto_2

    .line 136
    :cond_7
    const/4 v1, 0x0

    goto :goto_3

    .line 157
    :cond_8
    packed-switch v5, :pswitch_data_0

    .line 172
    const/4 v1, 0x0

    goto/16 :goto_0

    .line 160
    :pswitch_0
    const/4 v1, 0x1

    if-ne v5, v1, :cond_9

    const/4 v1, 0x4

    move v10, v1

    .line 161
    .local v10, "lcduiAction":I
    :goto_4
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->access$600()Ljava/util/HashMap;

    move-result-object v1

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/lang/Integer;

    .line 162
    .local v12, "lcduiKeyObj":Ljava/lang/Integer;
    invoke-virtual {v0}, Landroid/view/KeyEvent;->getKeyboardDevice()I

    move-result v1

    invoke-static {v1}, Landroid/view/KeyCharacterMap;->load(I)Landroid/view/KeyCharacterMap;

    move-result-object v9

    .line 164
    .local v9, "kmap":Landroid/view/KeyCharacterMap;
    if-nez v12, :cond_a

    invoke-virtual {v0}, Landroid/view/KeyEvent;->getMetaState()I

    move-result v1

    invoke-virtual {v9, v6, v1}, Landroid/view/KeyCharacterMap;->get(II)I

    move-result v1

    move v11, v1

    .line 166
    .local v11, "lcduiKey":I
    :goto_5
    shl-int/lit8 v1, v11, 0x4

    or-int/2addr v1, v10

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->sendRawEvent(I)V

    .line 169
    const/4 v1, 0x1

    goto/16 :goto_0

    .line 160
    .end local v9    # "kmap":Landroid/view/KeyCharacterMap;
    .end local v10    # "lcduiAction":I
    .end local v11    # "lcduiKey":I
    .end local v12    # "lcduiKeyObj":Ljava/lang/Integer;
    :cond_9
    const/4 v1, 0x3

    move v10, v1

    goto :goto_4

    .line 164
    .restart local v9    # "kmap":Landroid/view/KeyCharacterMap;
    .restart local v10    # "lcduiAction":I
    .restart local v12    # "lcduiKeyObj":Ljava/lang/Integer;
    :cond_a
    invoke-virtual {v12}, Ljava/lang/Integer;->intValue()I

    move-result v1

    move v11, v1

    goto :goto_5

    .line 157
    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_0
    .end packed-switch
.end method

.method public notifyOnTouchEvent(III)Z
    .locals 4
    .param p1, "x"    # I
    .param p2, "y"    # I
    .param p3, "motionEvent"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 177
    const/4 v1, 0x0

    .line 178
    .local v1, "lcduiEvent":I
    const/4 v0, 0x0

    .line 179
    .local v0, "button":I
    packed-switch p3, :pswitch_data_0

    .line 192
    const/4 v2, 0x0

    .line 195
    :goto_0
    return v2

    .line 181
    :pswitch_0
    and-int/lit16 v2, p1, 0x1fff

    shl-int/lit8 v2, v2, 0x13

    or-int/lit8 v2, v2, 0x1

    and-int/lit16 v3, p2, 0x1fff

    shl-int/lit8 v3, v3, 0x6

    or-int/2addr v2, v3

    and-int/lit8 v3, v0, 0x3

    shl-int/lit8 v3, v3, 0x4

    or-int/lit8 v1, v2, 0x0

    .line 194
    :goto_1
    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager$1;->sendRawEvent(I)V

    .line 195
    const/4 v2, 0x1

    goto :goto_0

    .line 185
    :pswitch_1
    and-int/lit16 v2, p1, 0x1fff

    shl-int/lit8 v2, v2, 0x13

    or-int/lit8 v2, v2, 0x2

    and-int/lit16 v3, p2, 0x1fff

    shl-int/lit8 v3, v3, 0x6

    or-int/2addr v2, v3

    and-int/lit8 v3, v0, 0x3

    shl-int/lit8 v3, v3, 0x4

    or-int/lit8 v1, v2, 0x0

    .line 187
    goto :goto_1

    .line 189
    :pswitch_2
    and-int/lit16 v2, p1, 0x1fff

    shl-int/lit8 v2, v2, 0x13

    or-int/lit8 v2, v2, 0x0

    and-int/lit16 v3, p2, 0x1fff

    shl-int/lit8 v3, v3, 0x6

    or-int v1, v2, v3

    .line 190
    goto :goto_1

    .line 179
    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_1
        :pswitch_2
    .end packed-switch
.end method
