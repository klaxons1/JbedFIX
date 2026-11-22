.class public Lcom/esmertec/android/jbed/util/EditTextHelper;
.super Ljava/lang/Object;
.source "EditTextHelper.java"

# interfaces
.implements Lcom/esmertec/android/jbed/JbedConstants;


# direct methods
.method private constructor <init>()V
    .locals 0

    .prologue
    .line 21
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 22
    return-void
.end method

.method public static setConstraint(Landroid/widget/EditText;I)V
    .locals 9
    .param p0, "editText"    # Landroid/widget/EditText;
    .param p1, "constraint"    # I

    .prologue
    const/high16 v8, 0x10000

    const/4 v7, 0x1

    .line 25
    const/4 v5, 0x0

    .line 26
    .local v5, "l":Landroid/text/method/KeyListener;
    const/4 v4, 0x1

    .line 27
    .local v4, "isEnablePassword":Z
    const/4 v1, 0x0

    .line 29
    .local v1, "bakEditText":Landroid/widget/EditText;
    const v6, 0xffff

    and-int/2addr v6, p1

    packed-switch v6, :pswitch_data_0

    .line 54
    :pswitch_0
    if-eqz v4, :cond_3

    and-int v6, p1, v8

    if-eqz v6, :cond_3

    .line 55
    const v3, 0x20001

    .line 56
    .local v3, "inputType":I
    or-int/lit16 v6, v3, 0x80

    invoke-virtual {p0, v6}, Landroid/widget/EditText;->setInputType(I)V

    .line 91
    .end local v3    # "inputType":I
    :cond_0
    :goto_0
    return-void

    .line 31
    :pswitch_1
    const/4 v6, 0x0

    invoke-static {v7, v6}, Landroid/text/method/DigitsKeyListener;->getInstance(ZZ)Landroid/text/method/DigitsKeyListener;

    move-result-object v5

    .line 76
    :goto_1
    if-eqz v4, :cond_1

    and-int v6, p1, v8

    if-eqz v6, :cond_1

    .line 77
    invoke-static {}, Landroid/text/method/PasswordTransformationMethod;->getInstance()Landroid/text/method/PasswordTransformationMethod;

    move-result-object v6

    invoke-virtual {p0, v6}, Landroid/widget/EditText;->setTransformationMethod(Landroid/text/method/TransformationMethod;)V

    .line 80
    :cond_1
    const/high16 v6, 0x20000

    and-int/2addr v6, p1

    if-eqz v6, :cond_2

    .line 84
    move-object v1, p0

    .line 89
    :cond_2
    if-eq p0, v1, :cond_0

    .line 90
    invoke-virtual {p0, v5}, Landroid/widget/EditText;->setKeyListener(Landroid/text/method/KeyListener;)V

    goto :goto_0

    .line 34
    :pswitch_2
    invoke-static {v7, v7}, Landroid/text/method/DigitsKeyListener;->getInstance(ZZ)Landroid/text/method/DigitsKeyListener;

    move-result-object v5

    .line 35
    goto :goto_1

    .line 37
    :pswitch_3
    new-instance v5, Lcom/esmertec/android/jbed/util/EditTextHelper$1;

    .end local v5    # "l":Landroid/text/method/KeyListener;
    invoke-direct {v5}, Lcom/esmertec/android/jbed/util/EditTextHelper$1;-><init>()V

    .line 47
    .restart local v5    # "l":Landroid/text/method/KeyListener;
    goto :goto_1

    .line 60
    :cond_3
    sget-object v2, Landroid/text/method/TextKeyListener$Capitalize;->NONE:Landroid/text/method/TextKeyListener$Capitalize;

    .line 61
    .local v2, "capitalize":Landroid/text/method/TextKeyListener$Capitalize;
    const/4 v0, 0x1

    .line 62
    .local v0, "autotext":Z
    const/high16 v6, 0x200000

    and-int/2addr v6, p1

    if-eqz v6, :cond_4

    .line 63
    sget-object v2, Landroid/text/method/TextKeyListener$Capitalize;->SENTENCES:Landroid/text/method/TextKeyListener$Capitalize;

    .line 65
    :cond_4
    const/high16 v6, 0x100000

    and-int/2addr v6, p1

    if-eqz v6, :cond_5

    .line 66
    sget-object v2, Landroid/text/method/TextKeyListener$Capitalize;->WORDS:Landroid/text/method/TextKeyListener$Capitalize;

    .line 68
    :cond_5
    const/high16 v6, 0x40000

    and-int/2addr v6, p1

    if-eqz v6, :cond_6

    .line 69
    const/4 v0, 0x0

    .line 71
    :cond_6
    const/high16 v6, 0x80000

    and-int/2addr v6, p1

    if-eqz v6, :cond_7

    .line 72
    const/4 v0, 0x0

    .line 74
    :cond_7
    invoke-static {v0, v2}, Landroid/text/method/TextKeyListener;->getInstance(ZLandroid/text/method/TextKeyListener$Capitalize;)Landroid/text/method/TextKeyListener;

    move-result-object v5

    goto :goto_1

    .line 29
    nop

    :pswitch_data_0
    .packed-switch 0x2
        :pswitch_1
        :pswitch_3
        :pswitch_0
        :pswitch_2
    .end packed-switch
.end method

.method public static setMaxSize(Landroid/widget/EditText;I)V
    .locals 3
    .param p0, "editText"    # Landroid/widget/EditText;
    .param p1, "maxSize"    # I

    .prologue
    .line 94
    if-ltz p1, :cond_0

    .line 95
    const/4 v0, 0x1

    new-array v0, v0, [Landroid/text/InputFilter;

    const/4 v1, 0x0

    new-instance v2, Landroid/text/InputFilter$LengthFilter;

    invoke-direct {v2, p1}, Landroid/text/InputFilter$LengthFilter;-><init>(I)V

    aput-object v2, v0, v1

    invoke-virtual {p0, v0}, Landroid/widget/EditText;->setFilters([Landroid/text/InputFilter;)V

    .line 96
    :cond_0
    return-void
.end method
