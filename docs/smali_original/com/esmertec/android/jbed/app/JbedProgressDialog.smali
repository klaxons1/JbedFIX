.class public Lcom/esmertec/android/jbed/app/JbedProgressDialog;
.super Landroid/app/AlertDialog;
.source "JbedProgressDialog.java"


# static fields
.field public static final STYLE_HORIZONTAL:I = 0x1

.field public static final STYLE_SPINNER:I


# instance fields
.field private mBackKeyAvailable:Z

.field private mHasStarted:Z

.field private mIncrementBy:I

.field private mIncrementSecondaryBy:I

.field private mIndeterminate:Z

.field private mIndeterminateDrawable:Landroid/graphics/drawable/Drawable;

.field private mJbedContext:Landroid/content/Context;

.field private mMax:I

.field private mMessage:Ljava/lang/CharSequence;

.field private mMessageView:Landroid/widget/TextView;

.field private mProgress:Landroid/widget/ProgressBar;

.field private mProgressDescView:Landroid/widget/TextView;

.field private mProgressDrawable:Landroid/graphics/drawable/Drawable;

.field private mProgressStyle:I

.field private mProgressVal:I

.field private mSecondaryProgressVal:I

.field private mViewUpdateHandler:Landroid/os/Handler;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 68
    const v0, 0x10300a3

    invoke-direct {p0, p1, v0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;-><init>(Landroid/content/Context;I)V

    .line 69
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;I)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "theme"    # I

    .prologue
    .line 72
    invoke-direct {p0, p1, p2}, Landroid/app/AlertDialog;-><init>(Landroid/content/Context;I)V

    .line 48
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressStyle:I

    .line 73
    new-instance v0, Landroid/view/ContextThemeWrapper;

    if-nez p2, :cond_0

    const v1, 0x103000b

    :goto_0
    invoke-direct {v0, p1, v1}, Landroid/view/ContextThemeWrapper;-><init>(Landroid/content/Context;I)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mJbedContext:Landroid/content/Context;

    .line 75
    return-void

    :cond_0
    move v1, p2

    .line 73
    goto :goto_0
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/app/JbedProgressDialog;)Landroid/widget/ProgressBar;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    .prologue
    .line 34
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    return-object v0
.end method

.method private onProgressChanged()V
    .locals 2

    .prologue
    .line 297
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressStyle:I

    const/4 v1, 0x1

    if-ne v0, v1, :cond_0

    .line 298
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mViewUpdateHandler:Landroid/os/Handler;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/os/Handler;->sendEmptyMessage(I)Z

    .line 300
    :cond_0
    return-void
.end method

.method public static show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Lcom/esmertec/android/jbed/app/JbedProgressDialog;
    .locals 1
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/CharSequence;
    .param p2, "message"    # Ljava/lang/CharSequence;

    .prologue
    .line 79
    const/4 v0, 0x0

    invoke-static {p0, p1, p2, v0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Z)Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    move-result-object v0

    return-object v0
.end method

.method public static show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Z)Lcom/esmertec/android/jbed/app/JbedProgressDialog;
    .locals 6
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/CharSequence;
    .param p2, "message"    # Ljava/lang/CharSequence;
    .param p3, "indeterminate"    # Z

    .prologue
    .line 84
    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move v3, p3

    invoke-static/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZZLandroid/content/DialogInterface$OnCancelListener;)Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    move-result-object v0

    return-object v0
.end method

.method public static show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZZ)Lcom/esmertec/android/jbed/app/JbedProgressDialog;
    .locals 6
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/CharSequence;
    .param p2, "message"    # Ljava/lang/CharSequence;
    .param p3, "indeterminate"    # Z
    .param p4, "cancelable"    # Z

    .prologue
    .line 89
    const/4 v5, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move v3, p3

    move v4, p4

    invoke-static/range {v0 .. v5}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZZLandroid/content/DialogInterface$OnCancelListener;)Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    move-result-object v0

    return-object v0
.end method

.method public static show(Landroid/content/Context;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZZLandroid/content/DialogInterface$OnCancelListener;)Lcom/esmertec/android/jbed/app/JbedProgressDialog;
    .locals 1
    .param p0, "context"    # Landroid/content/Context;
    .param p1, "title"    # Ljava/lang/CharSequence;
    .param p2, "message"    # Ljava/lang/CharSequence;
    .param p3, "indeterminate"    # Z
    .param p4, "cancelable"    # Z
    .param p5, "cancelListener"    # Landroid/content/DialogInterface$OnCancelListener;

    .prologue
    .line 95
    new-instance v0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;-><init>(Landroid/content/Context;)V

    .line 96
    .local v0, "dialog":Lcom/esmertec/android/jbed/app/JbedProgressDialog;
    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setTitle(Ljava/lang/CharSequence;)V

    .line 97
    invoke-virtual {v0, p2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 98
    invoke-virtual {v0, p3}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setIndeterminate(Z)V

    .line 99
    invoke-virtual {v0, p4}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setCancelable(Z)V

    .line 100
    invoke-virtual {v0, p5}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)V

    .line 101
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->show()V

    .line 102
    return-object v0
.end method


# virtual methods
.method public enableBackKey(Z)V
    .locals 0
    .param p1, "available"    # Z

    .prologue
    .line 325
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mBackKeyAvailable:Z

    .line 326
    return-void
.end method

.method public getMax()I
    .locals 1

    .prologue
    .line 209
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 210
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0}, Landroid/widget/ProgressBar;->getMax()I

    move-result v0

    .line 212
    :goto_0
    return v0

    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMax:I

    goto :goto_0
.end method

.method public getProgress()I
    .locals 1

    .prologue
    .line 195
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 196
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0}, Landroid/widget/ProgressBar;->getProgress()I

    move-result v0

    .line 198
    :goto_0
    return v0

    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressVal:I

    goto :goto_0
.end method

.method public getSecondaryProgress()I
    .locals 1

    .prologue
    .line 202
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 203
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0}, Landroid/widget/ProgressBar;->getSecondaryProgress()I

    move-result v0

    .line 205
    :goto_0
    return v0

    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mSecondaryProgressVal:I

    goto :goto_0
.end method

.method public incrementProgressBy(I)V
    .locals 1
    .param p1, "diff"    # I

    .prologue
    .line 225
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 226
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->incrementProgressBy(I)V

    .line 227
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 231
    :goto_0
    return-void

    .line 229
    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementBy:I

    add-int/2addr v0, p1

    iput v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementBy:I

    goto :goto_0
.end method

.method public incrementSecondaryProgressBy(I)V
    .locals 1
    .param p1, "diff"    # I

    .prologue
    .line 234
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 235
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->incrementSecondaryProgressBy(I)V

    .line 236
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 240
    :goto_0
    return-void

    .line 238
    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementSecondaryBy:I

    add-int/2addr v0, p1

    iput v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementSecondaryBy:I

    goto :goto_0
.end method

.method public isIndeterminate()Z
    .locals 1

    .prologue
    .line 267
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 268
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0}, Landroid/widget/ProgressBar;->isIndeterminate()Z

    move-result v0

    .line 270
    :goto_0
    return v0

    :cond_0
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminate:Z

    goto :goto_0
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 5
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .prologue
    const/4 v4, 0x0

    const/4 v3, 0x1

    .line 107
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mBackKeyAvailable:Z

    .line 108
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mJbedContext:Landroid/content/Context;

    invoke-static {v2}, Landroid/view/LayoutInflater;->from(Landroid/content/Context;)Landroid/view/LayoutInflater;

    move-result-object v0

    .line 109
    .local v0, "inflater":Landroid/view/LayoutInflater;
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressStyle:I

    if-ne v2, v3, :cond_8

    .line 113
    new-instance v2, Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog$1;-><init>(Lcom/esmertec/android/jbed/app/JbedProgressDialog;)V

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mViewUpdateHandler:Landroid/os/Handler;

    .line 124
    const v2, 0x7f030004

    invoke-virtual {v0, v2, v4}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    .line 125
    .local v1, "view":Landroid/view/View;
    const v2, 0x7f08000e

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ProgressBar;

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    .line 126
    const v2, 0x7f08000f

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/TextView;

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDescView:Landroid/widget/TextView;

    .line 127
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setView(Landroid/view/View;)V

    .line 135
    :goto_0
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMax:I

    if-lez v2, :cond_0

    .line 136
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMax:I

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setMax(I)V

    .line 138
    :cond_0
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressVal:I

    if-lez v2, :cond_1

    .line 139
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressVal:I

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setProgress(I)V

    .line 141
    :cond_1
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mSecondaryProgressVal:I

    if-lez v2, :cond_2

    .line 142
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mSecondaryProgressVal:I

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setSecondaryProgress(I)V

    .line 144
    :cond_2
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementBy:I

    if-lez v2, :cond_3

    .line 145
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementBy:I

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->incrementProgressBy(I)V

    .line 147
    :cond_3
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementSecondaryBy:I

    if-lez v2, :cond_4

    .line 148
    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIncrementSecondaryBy:I

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->incrementSecondaryProgressBy(I)V

    .line 150
    :cond_4
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDrawable:Landroid/graphics/drawable/Drawable;

    if-eqz v2, :cond_5

    .line 151
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDrawable:Landroid/graphics/drawable/Drawable;

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setProgressDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 153
    :cond_5
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminateDrawable:Landroid/graphics/drawable/Drawable;

    if-eqz v2, :cond_6

    .line 154
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminateDrawable:Landroid/graphics/drawable/Drawable;

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setIndeterminateDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 156
    :cond_6
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMessage:Ljava/lang/CharSequence;

    if-eqz v2, :cond_7

    .line 157
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMessage:Ljava/lang/CharSequence;

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 159
    :cond_7
    iget-boolean v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminate:Z

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setIndeterminate(Z)V

    .line 160
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 161
    invoke-super {p0, p1}, Landroid/app/AlertDialog;->onCreate(Landroid/os/Bundle;)V

    .line 162
    return-void

    .line 130
    .end local v1    # "view":Landroid/view/View;
    :cond_8
    const v2, 0x7f030009

    invoke-virtual {v0, v2, v4}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    .line 131
    .restart local v1    # "view":Landroid/view/View;
    const v2, 0x7f08001f

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/ProgressBar;

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    .line 132
    const v2, 0x7f080020

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/TextView;

    iput-object v2, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMessageView:Landroid/widget/TextView;

    .line 133
    invoke-virtual {p0, v1}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->setView(Landroid/view/View;)V

    goto :goto_0
.end method

.method public onKeyDown(ILandroid/view/KeyEvent;)Z
    .locals 1
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    .line 321
    invoke-super {p0, p1, p2}, Landroid/app/AlertDialog;->onKeyDown(ILandroid/view/KeyEvent;)Z

    move-result v0

    return v0
.end method

.method public onKeyUp(ILandroid/view/KeyEvent;)Z
    .locals 1
    .param p1, "keyCode"    # I
    .param p2, "event"    # Landroid/view/KeyEvent;

    .prologue
    .line 310
    invoke-super {p0, p1, p2}, Landroid/app/AlertDialog;->onKeyUp(ILandroid/view/KeyEvent;)Z

    move-result v0

    return v0
.end method

.method public onStart()V
    .locals 1

    .prologue
    .line 166
    invoke-super {p0}, Landroid/app/AlertDialog;->onStart()V

    .line 167
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mHasStarted:Z

    .line 168
    return-void
.end method

.method protected onStop()V
    .locals 1

    .prologue
    .line 172
    invoke-super {p0}, Landroid/app/AlertDialog;->onStop()V

    .line 173
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mHasStarted:Z

    .line 174
    return-void
.end method

.method public setDescMessage(Ljava/lang/String;)V
    .locals 1
    .param p1, "message"    # Ljava/lang/String;

    .prologue
    .line 287
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDescView:Landroid/widget/TextView;

    if-eqz v0, :cond_0

    .line 288
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDescView:Landroid/widget/TextView;

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 290
    :cond_0
    return-void
.end method

.method public setIndeterminate(Z)V
    .locals 1
    .param p1, "indeterminate"    # Z

    .prologue
    .line 259
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 260
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setIndeterminate(Z)V

    .line 264
    :goto_0
    return-void

    .line 262
    :cond_0
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminate:Z

    goto :goto_0
.end method

.method public setIndeterminateDrawable(Landroid/graphics/drawable/Drawable;)V
    .locals 1
    .param p1, "d"    # Landroid/graphics/drawable/Drawable;

    .prologue
    .line 251
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 252
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setIndeterminateDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 256
    :goto_0
    return-void

    .line 254
    :cond_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mIndeterminateDrawable:Landroid/graphics/drawable/Drawable;

    goto :goto_0
.end method

.method public setMax(I)V
    .locals 1
    .param p1, "max"    # I

    .prologue
    .line 216
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 217
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setMax(I)V

    .line 218
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 222
    :goto_0
    return-void

    .line 220
    :cond_0
    iput p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMax:I

    goto :goto_0
.end method

.method public setMessage(Ljava/lang/CharSequence;)V
    .locals 2
    .param p1, "message"    # Ljava/lang/CharSequence;

    .prologue
    .line 275
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_1

    .line 276
    iget v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressStyle:I

    const/4 v1, 0x1

    if-ne v0, v1, :cond_0

    .line 277
    invoke-super {p0, p1}, Landroid/app/AlertDialog;->setMessage(Ljava/lang/CharSequence;)V

    .line 284
    :goto_0
    return-void

    .line 279
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMessageView:Landroid/widget/TextView;

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    goto :goto_0

    .line 282
    :cond_1
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mMessage:Ljava/lang/CharSequence;

    goto :goto_0
.end method

.method public setProgress(I)V
    .locals 1
    .param p1, "value"    # I

    .prologue
    .line 177
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mHasStarted:Z

    if-eqz v0, :cond_0

    .line 178
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setProgress(I)V

    .line 179
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 183
    :goto_0
    return-void

    .line 181
    :cond_0
    iput p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressVal:I

    goto :goto_0
.end method

.method public setProgressDrawable(Landroid/graphics/drawable/Drawable;)V
    .locals 1
    .param p1, "d"    # Landroid/graphics/drawable/Drawable;

    .prologue
    .line 243
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 244
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setProgressDrawable(Landroid/graphics/drawable/Drawable;)V

    .line 248
    :goto_0
    return-void

    .line 246
    :cond_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressDrawable:Landroid/graphics/drawable/Drawable;

    goto :goto_0
.end method

.method public setProgressStyle(I)V
    .locals 0
    .param p1, "style"    # I

    .prologue
    .line 293
    iput p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgressStyle:I

    .line 294
    return-void
.end method

.method public setSecondaryProgress(I)V
    .locals 1
    .param p1, "secondaryProgress"    # I

    .prologue
    .line 186
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    if-eqz v0, :cond_0

    .line 187
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mProgress:Landroid/widget/ProgressBar;

    invoke-virtual {v0, p1}, Landroid/widget/ProgressBar;->setSecondaryProgress(I)V

    .line 188
    invoke-direct {p0}, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->onProgressChanged()V

    .line 192
    :goto_0
    return-void

    .line 190
    :cond_0
    iput p1, p0, Lcom/esmertec/android/jbed/app/JbedProgressDialog;->mSecondaryProgressVal:I

    goto :goto_0
.end method
