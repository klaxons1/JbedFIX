.class public Lcom/esmertec/android/jbed/nativeui/JbedEditText;
.super Landroid/widget/EditText;
.source "JbedEditText.java"


# static fields
.field static final HANDLE_TEXT_CHANGED:I = 0x2711

.field private static mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;


# instance fields
.field private clipHeight:I

.field private clipWdith:I

.field private clipX:I

.field private clipY:I

.field private editable:Z

.field private mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

.field private mHandler:Landroid/os/Handler;

.field private mId:I

.field private onKeyDownReturn:Z


# direct methods
.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "attrs"    # Landroid/util/AttributeSet;

    .prologue
    .line 47
    invoke-direct {p0, p1, p2}, Landroid/widget/EditText;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    .line 30
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->editable:Z

    .line 34
    const v0, 0x7fffffff

    iput v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipX:I

    .line 42
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    .line 48
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    .prologue
    .line 28
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    return-object v0
.end method


# virtual methods
.method public draw(Landroid/graphics/Canvas;)V
    .locals 6
    .param p1, "canvas"    # Landroid/graphics/Canvas;

    .prologue
    .line 142
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->editable:Z

    if-eqz v1, :cond_0

    .line 143
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v0

    check-cast v0, Landroid/widget/AbsoluteLayout$LayoutParams;

    .line 144
    .local v0, "layout":Landroid/widget/AbsoluteLayout$LayoutParams;
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 149
    .end local v0    # "layout":Landroid/widget/AbsoluteLayout$LayoutParams;
    :cond_0
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipX:I

    const v2, 0x7fffffff

    if-eq v1, v2, :cond_1

    .line 150
    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipX:I

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipY:I

    iget v3, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipX:I

    iget v4, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipWdith:I

    add-int/2addr v3, v4

    iget v4, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipY:I

    iget v5, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipHeight:I

    add-int/2addr v4, v5

    invoke-virtual {p1, v1, v2, v3, v4}, Landroid/graphics/Canvas;->clipRect(IIII)Z

    .line 151
    :cond_1
    invoke-super {p0, p1}, Landroid/widget/EditText;->draw(Landroid/graphics/Canvas;)V

    .line 152
    return-void
.end method

.method init(Lcom/esmertec/android/jbed/service/IJbedUiListener;ILandroid/content/Context;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;)V
    .locals 0
    .param p1, "listener"    # Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .param p2, "id"    # I
    .param p3, "context"    # Landroid/content/Context;
    .param p4, "connection"    # Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    .prologue
    .line 51
    sput-object p1, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .line 52
    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mId:I

    .line 53
    iput-object p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    .line 54
    return-void
.end method

.method public onCheckIsTextEditor()Z
    .locals 1

    .prologue
    .line 58
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->editable:Z

    if-nez v0, :cond_0

    .line 59
    const/4 v0, 0x0

    .line 61
    :goto_0
    return v0

    :cond_0
    invoke-super {p0}, Landroid/widget/EditText;->onCheckIsTextEditor()Z

    move-result v0

    goto :goto_0
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 1
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    .line 82
    invoke-super {p0, p1, p2}, Landroid/widget/EditText;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->onKeyDownReturn:Z

    .line 83
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->onKeyDownReturn:Z

    return v0
.end method

.method public onKeyUp(ILandroid/view/KeyEvent;)Z
    .locals 1
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    .line 93
    invoke-super {p0, p1, p2}, Landroid/widget/EditText;->onKeyUp(ILandroid/view/KeyEvent;)Z

    .line 94
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->onKeyDownReturn:Z

    return v0
.end method

.method public onTextChanged(Ljava/lang/CharSequence;III)V
    .locals 6
    .param p1, "text"    # Ljava/lang/CharSequence;
    .param p2, "start"    # I
    .param p3, "before"    # I
    .param p4, "after"    # I

    .prologue
    const/16 v5, 0x2711

    .line 99
    invoke-super {p0, p1, p2, p3, p4}, Landroid/widget/EditText;->onTextChanged(Ljava/lang/CharSequence;III)V

    .line 102
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    if-nez v1, :cond_0

    .line 103
    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText$2;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V

    iput-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    .line 117
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    iget v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mId:I

    const/4 v3, 0x0

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v1, v5, v2, v3, v4}, Landroid/os/Handler;->obtainMessage(IIILjava/lang/Object;)Landroid/os/Message;

    move-result-object v0

    .line 118
    .local v0, "message":Landroid/os/Message;
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v5}, Landroid/os/Handler;->removeMessages(I)V

    .line 119
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mHandler:Landroid/os/Handler;

    const-wide/16 v2, 0x15e

    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->sendMessageDelayed(Landroid/os/Message;J)Z

    .line 120
    return-void
.end method

.method public onTouchEvent(Landroid/view/MotionEvent;)Z
    .locals 8
    .param p1, "motionEvent"    # Landroid/view/MotionEvent;

    .prologue
    .line 124
    invoke-super {p0, p1}, Landroid/widget/EditText;->onTouchEvent(Landroid/view/MotionEvent;)Z

    .line 125
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v1

    check-cast v1, Landroid/widget/AbsoluteLayout$LayoutParams;

    .line 127
    .local v1, "layout":Landroid/widget/AbsoluteLayout$LayoutParams;
    :try_start_0
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getX()F

    move-result v4

    float-to-int v2, v4

    .line 128
    .local v2, "x":I
    invoke-virtual {p1}, Landroid/view/MotionEvent;->getY()F

    move-result v4

    float-to-int v3, v4

    .line 129
    .local v3, "y":I
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->requestFocusFromTouch()Z

    .line 130
    sget-object v4, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    if-eqz v4, :cond_0

    sget-object v4, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    iget v5, v1, Landroid/widget/AbsoluteLayout$LayoutParams;->x:I

    add-int/2addr v5, v2

    iget v6, v1, Landroid/widget/AbsoluteLayout$LayoutParams;->y:I

    add-int/2addr v6, v3

    invoke-virtual {p1}, Landroid/view/MotionEvent;->getAction()I

    move-result v7

    invoke-interface {v4, v5, v6, v7}, Lcom/esmertec/android/jbed/service/IJbedUiListener;->notifyOnTouchEvent(III)Z
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v4

    :goto_0
    return v4

    :cond_0
    const/4 v4, 0x1

    goto :goto_0

    .line 131
    .end local v2    # "x":I
    .end local v3    # "y":I
    :catch_0
    move-exception v4

    move-object v0, v4

    .line 133
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v4, Ljava/lang/RuntimeException;

    const-string v5, " failed to call notifyOnTouchEvent"

    invoke-direct {v4, v5}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v4
.end method

.method public setClip(IIII)V
    .locals 0
    .param p1, "x"    # I
    .param p2, "y"    # I
    .param p3, "width"    # I
    .param p4, "height"    # I

    .prologue
    .line 155
    iput p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipX:I

    .line 156
    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipY:I

    .line 157
    iput p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipWdith:I

    .line 158
    iput p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->clipHeight:I

    .line 159
    return-void
.end method

.method setUneditable()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 67
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->editable:Z

    .line 68
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setCursorVisible(Z)V

    .line 69
    invoke-static {}, Landroid/text/method/ScrollingMovementMethod;->getInstance()Landroid/text/method/MovementMethod;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setMovementMethod(Landroid/text/method/MovementMethod;)V

    .line 70
    const/4 v0, 0x1

    new-array v0, v0, [Landroid/text/InputFilter;

    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedEditText$1;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText$1;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V

    aput-object v1, v0, v2

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setFilters([Landroid/text/InputFilter;)V

    .line 78
    return-void
.end method
