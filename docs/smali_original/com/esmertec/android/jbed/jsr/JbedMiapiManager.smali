.class public Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;
.super Ljava/lang/Object;
.source "JbedMiapiManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# static fields
.field private static final ANDROID_LONG:I = 0x1

.field private static final ANDROID_MEDIUM:I = 0x2

.field private static final ANDROID_SHORT:I = 0x3

.field private static final COLLATER_BASE_HANDLE:I = 0x2710

.field private static final FORMATTER_DATETIME_LONG:I = 0x5

.field private static final FORMATTER_DATETIME_SHORT:I = 0x4

.field private static final FORMATTER_DATE_LONG:I = 0x1

.field private static final FORMATTER_DATE_SHORT:I = 0x0

.field private static final FORMATTER_TIME_LONG:I = 0x3

.field private static final FORMATTER_TIME_SHORT:I = 0x2

.field private static final TAG:Ljava/lang/String; = "JbedMiapiManager"

.field private static collaterHandles:Ljava/util/Hashtable;

.field private static collators:Ljava/util/Hashtable;

.field private static localesOfCollator:[Ljava/lang/String;

.field private static localesOfFormatter:[Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 48
    new-instance v0, Ljava/util/Hashtable;

    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collaterHandles:Ljava/util/Hashtable;

    .line 54
    new-instance v0, Ljava/util/Hashtable;

    invoke-direct {v0}, Ljava/util/Hashtable;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collators:Ljava/util/Hashtable;

    .line 59
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getCollatorLocales()[Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfCollator:[Ljava/lang/String;

    .line 64
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getFormatterLocales()[Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfFormatter:[Ljava/lang/String;

    .line 68
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->nativeInitialization()V

    .line 69
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 0
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 71
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 72
    return-void
.end method

.method public static closeCollator(I)I
    .locals 1
    .param p0, "collatorHandle"    # I

    .prologue
    .line 107
    const/4 v0, 0x0

    return v0
.end method

.method public static compare(IILjava/lang/String;Ljava/lang/String;)I
    .locals 3
    .param p0, "collatorHandle"    # I
    .param p1, "level"    # I
    .param p2, "str1"    # Ljava/lang/String;
    .param p3, "str2"    # Ljava/lang/String;

    .prologue
    .line 111
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collators:Ljava/util/Hashtable;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/text/Collator;

    .line 112
    .local v0, "collator":Ljava/text/Collator;
    sparse-switch p1, :sswitch_data_0

    .line 124
    const/4 v1, 0x3

    invoke-virtual {v0, v1}, Ljava/text/Collator;->setStrength(I)V

    .line 127
    :goto_0
    invoke-virtual {v0, p2, p3}, Ljava/text/Collator;->compare(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    return v1

    .line 114
    :sswitch_0
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/text/Collator;->setStrength(I)V

    goto :goto_0

    .line 117
    :sswitch_1
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/text/Collator;->setStrength(I)V

    goto :goto_0

    .line 121
    :sswitch_2
    const/4 v1, 0x2

    invoke-virtual {v0, v1}, Ljava/text/Collator;->setStrength(I)V

    goto :goto_0

    .line 112
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x2 -> :sswitch_1
        0x3 -> :sswitch_2
        0xf -> :sswitch_2
    .end sparse-switch
.end method

.method private static convertLocales([Ljava/util/Locale;)[Ljava/lang/String;
    .locals 8
    .param p0, "locales"    # [Ljava/util/Locale;

    .prologue
    const/4 v7, 0x0

    .line 264
    array-length v5, p0

    new-array v3, v5, [Ljava/lang/String;

    .line 267
    .local v3, "localesStr":[Ljava/lang/String;
    const/4 v1, 0x0

    .line 268
    .local v1, "index":I
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    array-length v5, p0

    if-ge v0, v5, :cond_3

    .line 269
    aget-object v5, p0, v0

    invoke-virtual {v5}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    if-nez v5, :cond_0

    aget-object v5, p0, v0

    invoke-virtual {v5}, Ljava/util/Locale;->getVariant()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    if-nez v5, :cond_1

    :cond_0
    aget-object v5, p0, v0

    invoke-virtual {v5}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/String;->length()I

    move-result v5

    const/4 v6, 0x2

    if-le v5, v6, :cond_2

    .line 268
    :cond_1
    :goto_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 272
    :cond_2
    add-int/lit8 v2, v1, 0x1

    .end local v1    # "index":I
    .local v2, "index":I
    aget-object v5, p0, v0

    invoke-static {v5}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleNameStr(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v5

    aput-object v5, v3, v1

    move v1, v2

    .end local v2    # "index":I
    .restart local v1    # "index":I
    goto :goto_1

    .line 275
    :cond_3
    new-array v4, v1, [Ljava/lang/String;

    .line 276
    .local v4, "result":[Ljava/lang/String;
    invoke-static {v3, v7, v4, v7, v1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 278
    return-object v4
.end method

.method public static formatCurrency(Ljava/lang/String;D)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "value"    # D

    .prologue
    .line 198
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 199
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {v0}, Ljava/text/NumberFormat;->getCurrencyInstance(Ljava/util/Locale;)Ljava/text/NumberFormat;

    move-result-object v1

    .line 200
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(D)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatCurrency(Ljava/lang/String;DLjava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "value"    # D
    .param p3, "currencyCode"    # Ljava/lang/String;

    .prologue
    .line 204
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 205
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {v0}, Ljava/text/NumberFormat;->getCurrencyInstance(Ljava/util/Locale;)Ljava/text/NumberFormat;

    move-result-object v1

    .line 206
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-static {p3}, Ljava/util/Currency;->getInstance(Ljava/lang/String;)Ljava/util/Currency;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/text/NumberFormat;->setCurrency(Ljava/util/Currency;)V

    .line 207
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(D)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatDateTime(Ljava/lang/String;IJ)Ljava/lang/String;
    .locals 4
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "style"    # I
    .param p2, "timeInMillis"    # J

    .prologue
    const/4 v3, 0x3

    const/4 v2, 0x1

    .line 213
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v1

    .line 214
    .local v1, "locale":Ljava/util/Locale;
    const/4 v0, 0x0

    .line 216
    .local v0, "df":Ljava/text/DateFormat;
    packed-switch p1, :pswitch_data_0

    .line 236
    new-instance v2, Ljava/lang/IllegalArgumentException;

    const-string v3, "Wrong date time style!"

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 218
    :pswitch_0
    invoke-static {v2, v1}, Ljava/text/DateFormat;->getDateInstance(ILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 239
    :goto_0
    new-instance v2, Ljava/util/Date;

    invoke-direct {v2, p2, p3}, Ljava/util/Date;-><init>(J)V

    invoke-virtual {v0, v2}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v2

    return-object v2

    .line 221
    :pswitch_1
    invoke-static {v3, v1}, Ljava/text/DateFormat;->getDateInstance(ILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 222
    goto :goto_0

    .line 224
    :pswitch_2
    invoke-static {v2, v1}, Ljava/text/DateFormat;->getTimeInstance(ILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 225
    goto :goto_0

    .line 227
    :pswitch_3
    invoke-static {v3, v1}, Ljava/text/DateFormat;->getTimeInstance(ILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 228
    goto :goto_0

    .line 230
    :pswitch_4
    invoke-static {v2, v2, v1}, Ljava/text/DateFormat;->getDateTimeInstance(IILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 231
    goto :goto_0

    .line 233
    :pswitch_5
    invoke-static {v3, v3, v1}, Ljava/text/DateFormat;->getDateTimeInstance(IILjava/util/Locale;)Ljava/text/DateFormat;

    move-result-object v0

    .line 234
    goto :goto_0

    .line 216
    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_1
        :pswitch_0
        :pswitch_3
        :pswitch_2
        :pswitch_5
        :pswitch_4
    .end packed-switch
.end method

.method public static formatNumber(Ljava/lang/String;D)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "number"    # D

    .prologue
    .line 160
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 161
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {v0}, Ljava/text/NumberFormat;->getNumberInstance(Ljava/util/Locale;)Ljava/text/NumberFormat;

    move-result-object v1

    .line 162
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(D)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatNumber(Ljava/lang/String;DI)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "number"    # D
    .param p3, "decimals"    # I

    .prologue
    .line 172
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 173
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {}, Ljava/text/NumberFormat;->getNumberInstance()Ljava/text/NumberFormat;

    move-result-object v1

    .line 174
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p3}, Ljava/text/NumberFormat;->setMinimumFractionDigits(I)V

    .line 175
    invoke-virtual {v1, p3}, Ljava/text/NumberFormat;->setMaximumFractionDigits(I)V

    .line 176
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(D)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatNumber(Ljava/lang/String;J)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "number"    # J

    .prologue
    .line 166
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 167
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {v0}, Ljava/text/NumberFormat;->getNumberInstance(Ljava/util/Locale;)Ljava/text/NumberFormat;

    move-result-object v1

    .line 168
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(J)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatPercent(Ljava/lang/String;FI)Ljava/lang/String;
    .locals 4
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "value"    # F
    .param p2, "decimals"    # I

    .prologue
    .line 188
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 189
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {}, Ljava/text/NumberFormat;->getPercentInstance()Ljava/text/NumberFormat;

    move-result-object v1

    .line 190
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p2}, Ljava/text/NumberFormat;->setMinimumFractionDigits(I)V

    .line 191
    invoke-virtual {v1, p2}, Ljava/text/NumberFormat;->setMaximumFractionDigits(I)V

    .line 192
    float-to-double v2, p1

    invoke-virtual {v1, v2, v3}, Ljava/text/NumberFormat;->format(D)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static formatPercent(Ljava/lang/String;J)Ljava/lang/String;
    .locals 3
    .param p0, "localeName"    # Ljava/lang/String;
    .param p1, "value"    # J

    .prologue
    .line 182
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v0

    .line 183
    .local v0, "locale":Ljava/util/Locale;
    invoke-static {v0}, Ljava/text/NumberFormat;->getPercentInstance(Ljava/util/Locale;)Ljava/text/NumberFormat;

    move-result-object v1

    .line 184
    .local v1, "nf":Ljava/text/NumberFormat;
    invoke-virtual {v1, p1, p2}, Ljava/text/NumberFormat;->format(J)Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method public static getCollatorLocaleLen(I)I
    .locals 1
    .param p0, "idx"    # I

    .prologue
    .line 135
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfCollator:[Ljava/lang/String;

    aget-object v0, v0, p0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    return v0
.end method

.method public static getCollatorLocaleName(I)Ljava/lang/String;
    .locals 1
    .param p0, "idx"    # I

    .prologue
    .line 139
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfCollator:[Ljava/lang/String;

    aget-object v0, v0, p0

    return-object v0
.end method

.method private static getCollatorLocales()[Ljava/lang/String;
    .locals 5

    .prologue
    .line 246
    invoke-static {}, Ljava/text/Collator;->getAvailableLocales()[Ljava/util/Locale;

    move-result-object v3

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->convertLocales([Ljava/util/Locale;)[Ljava/lang/String;

    move-result-object v0

    .line 247
    .local v0, "availableLocales":[Ljava/lang/String;
    array-length v3, v0

    add-int/lit8 v3, v3, 0x1

    new-array v1, v3, [Ljava/lang/String;

    .line 249
    .local v1, "collatorLocales":[Ljava/lang/String;
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_0
    array-length v3, v0

    if-ge v2, v3, :cond_0

    .line 250
    aget-object v3, v0, v2

    aput-object v3, v1, v2

    .line 249
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 254
    :cond_0
    array-length v3, v0

    const-string v4, "generic"

    aput-object v4, v1, v3

    .line 256
    return-object v1
.end method

.method public static getCollatorLocalesNum()I
    .locals 1

    .prologue
    .line 131
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfCollator:[Ljava/lang/String;

    array-length v0, v0

    return v0
.end method

.method public static getFormatterLocaleLen(I)I
    .locals 1
    .param p0, "idx"    # I

    .prologue
    .line 150
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfFormatter:[Ljava/lang/String;

    aget-object v0, v0, p0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    return v0
.end method

.method public static getFormatterLocaleName(I)Ljava/lang/String;
    .locals 1
    .param p0, "idx"    # I

    .prologue
    .line 154
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfFormatter:[Ljava/lang/String;

    aget-object v0, v0, p0

    return-object v0
.end method

.method private static getFormatterLocales()[Ljava/lang/String;
    .locals 1

    .prologue
    .line 260
    invoke-static {}, Ljava/text/NumberFormat;->getAvailableLocales()[Ljava/util/Locale;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->convertLocales([Ljava/util/Locale;)[Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getFormatterLocalesNum()I
    .locals 1

    .prologue
    .line 146
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfFormatter:[Ljava/lang/String;

    array-length v0, v0

    return v0
.end method

.method private static getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;
    .locals 6
    .param p0, "localeName"    # Ljava/lang/String;

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 314
    const-string v2, "-"

    const/4 v3, 0x3

    invoke-virtual {p0, v2, v3}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v0

    .line 315
    .local v0, "fields":[Ljava/lang/String;
    const/4 v1, 0x0

    .line 317
    .local v1, "result":Ljava/util/Locale;
    array-length v2, v0

    packed-switch v2, :pswitch_data_0

    .line 325
    new-instance v1, Ljava/util/Locale;

    .end local v1    # "result":Ljava/util/Locale;
    aget-object v2, v0, v4

    invoke-direct {v1, v2}, Ljava/util/Locale;-><init>(Ljava/lang/String;)V

    .line 328
    .restart local v1    # "result":Ljava/util/Locale;
    :goto_0
    return-object v1

    .line 319
    :pswitch_0
    new-instance v1, Ljava/util/Locale;

    .end local v1    # "result":Ljava/util/Locale;
    aget-object v2, v0, v4

    aget-object v3, v0, v5

    const/4 v4, 0x2

    aget-object v4, v0, v4

    invoke-direct {v1, v2, v3, v4}, Ljava/util/Locale;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    .line 320
    .restart local v1    # "result":Ljava/util/Locale;
    goto :goto_0

    .line 322
    :pswitch_1
    new-instance v1, Ljava/util/Locale;

    .end local v1    # "result":Ljava/util/Locale;
    aget-object v2, v0, v4

    aget-object v3, v0, v5

    invoke-direct {v1, v2, v3}, Ljava/util/Locale;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 323
    .restart local v1    # "result":Ljava/util/Locale;
    goto :goto_0

    .line 317
    nop

    :pswitch_data_0
    .packed-switch 0x2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private static getLocaleNameStr(Ljava/util/Locale;)Ljava/lang/String;
    .locals 11
    .param p0, "locale"    # Ljava/util/Locale;

    .prologue
    const/16 v10, 0x2d

    const/4 v9, 0x1

    const/4 v8, 0x0

    .line 288
    invoke-virtual {p0}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    move-result-object v3

    .line 289
    .local v3, "language":Ljava/lang/String;
    invoke-virtual {p0}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object v1

    .line 290
    .local v1, "country":Ljava/lang/String;
    invoke-virtual {p0}, Ljava/util/Locale;->getVariant()Ljava/lang/String;

    move-result-object v6

    .line 292
    .local v6, "variant":Ljava/lang/String;
    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v7

    if-eqz v7, :cond_4

    move v2, v9

    .line 293
    .local v2, "l":Z
    :goto_0
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v7

    if-eqz v7, :cond_5

    move v0, v9

    .line 294
    .local v0, "c":Z
    :goto_1
    invoke-virtual {v6}, Ljava/lang/String;->length()I

    move-result v7

    if-eqz v7, :cond_6

    move v5, v9

    .line 295
    .local v5, "v":Z
    :goto_2
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 296
    .local v4, "result":Ljava/lang/StringBuilder;
    if-nez v0, :cond_0

    if-eqz v2, :cond_1

    if-eqz v5, :cond_1

    .line 297
    :cond_0
    invoke-virtual {v4, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 299
    :cond_1
    if-eqz v5, :cond_3

    if-nez v2, :cond_2

    if-eqz v0, :cond_3

    .line 300
    :cond_2
    invoke-virtual {v4, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 303
    :cond_3
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    return-object v7

    .end local v0    # "c":Z
    .end local v2    # "l":Z
    .end local v4    # "result":Ljava/lang/StringBuilder;
    .end local v5    # "v":Z
    :cond_4
    move v2, v8

    .line 292
    goto :goto_0

    .restart local v2    # "l":Z
    :cond_5
    move v0, v8

    .line 293
    goto :goto_1

    .restart local v0    # "c":Z
    :cond_6
    move v5, v8

    .line 294
    goto :goto_2
.end method

.method private static native nativeInitialization()V
.end method

.method public static openCollator(Ljava/lang/String;)I
    .locals 6
    .param p0, "localeName"    # Ljava/lang/String;

    .prologue
    .line 85
    const/4 v2, 0x0

    .line 86
    .local v2, "index":I
    :goto_0
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->localesOfCollator:[Ljava/lang/String;

    aget-object v4, v4, v2

    invoke-virtual {v4, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_0

    .line 87
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 90
    :cond_0
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->getLocaleInstance(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v3

    .line 92
    .local v3, "locale":Ljava/util/Locale;
    const/4 v1, 0x0

    .line 93
    .local v1, "handle":I
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collaterHandles:Ljava/util/Hashtable;

    invoke-virtual {v4, v3}, Ljava/util/Hashtable;->containsKey(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 94
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collaterHandles:Ljava/util/Hashtable;

    invoke-virtual {v4, v3}, Ljava/util/Hashtable;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "localeName":Ljava/lang/String;
    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result v1

    .line 102
    :goto_1
    return v1

    .line 96
    .restart local p0    # "localeName":Ljava/lang/String;
    :cond_1
    invoke-static {v3}, Ljava/text/Collator;->getInstance(Ljava/util/Locale;)Ljava/text/Collator;

    move-result-object v0

    .line 97
    .local v0, "collator":Ljava/text/Collator;
    add-int/lit16 v1, v2, 0x2710

    .line 98
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collators:Ljava/util/Hashtable;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-virtual {v4, v5, v0}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 99
    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedMiapiManager;->collaterHandles:Ljava/util/Hashtable;

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-virtual {v4, v3, v5}, Ljava/util/Hashtable;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_1
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 75
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 78
    return-void
.end method
