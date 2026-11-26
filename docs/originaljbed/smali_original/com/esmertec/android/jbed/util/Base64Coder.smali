.class public Lcom/esmertec/android/jbed/util/Base64Coder;
.super Ljava/lang/Object;
.source "Base64Coder.java"


# static fields
.field private static map1:[C

.field private static map2:[B


# direct methods
.method static constructor <clinit>()V
    .locals 7

    .prologue
    const/16 v6, 0x40

    .line 123
    new-array v3, v6, [C

    sput-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    .line 125
    const/4 v1, 0x0

    .line 126
    .local v1, "i":I
    const/16 v0, 0x41

    .local v0, "c":C
    move v2, v1

    .end local v1    # "i":I
    .local v2, "i":I
    :goto_0
    const/16 v3, 0x5a

    if-gt v0, v3, :cond_0

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    add-int/lit8 v1, v2, 0x1

    .end local v2    # "i":I
    .restart local v1    # "i":I
    aput-char v0, v3, v2

    add-int/lit8 v3, v0, 0x1

    int-to-char v0, v3

    move v2, v1

    .end local v1    # "i":I
    .restart local v2    # "i":I
    goto :goto_0

    .line 127
    :cond_0
    const/16 v0, 0x61

    :goto_1
    const/16 v3, 0x7a

    if-gt v0, v3, :cond_1

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    add-int/lit8 v1, v2, 0x1

    .end local v2    # "i":I
    .restart local v1    # "i":I
    aput-char v0, v3, v2

    add-int/lit8 v3, v0, 0x1

    int-to-char v0, v3

    move v2, v1

    .end local v1    # "i":I
    .restart local v2    # "i":I
    goto :goto_1

    .line 128
    :cond_1
    const/16 v0, 0x30

    :goto_2
    const/16 v3, 0x39

    if-gt v0, v3, :cond_2

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    add-int/lit8 v1, v2, 0x1

    .end local v2    # "i":I
    .restart local v1    # "i":I
    aput-char v0, v3, v2

    add-int/lit8 v3, v0, 0x1

    int-to-char v0, v3

    move v2, v1

    .end local v1    # "i":I
    .restart local v2    # "i":I
    goto :goto_2

    .line 129
    :cond_2
    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    add-int/lit8 v1, v2, 0x1

    .end local v2    # "i":I
    .restart local v1    # "i":I
    const/16 v4, 0x2b

    aput-char v4, v3, v2

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    add-int/lit8 v2, v1, 0x1

    .end local v1    # "i":I
    .restart local v2    # "i":I
    const/16 v4, 0x2f

    aput-char v4, v3, v1

    .line 132
    const/16 v3, 0x80

    new-array v3, v3, [B

    sput-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    .line 134
    const/4 v1, 0x0

    .end local v2    # "i":I
    .restart local v1    # "i":I
    :goto_3
    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    array-length v3, v3

    if-ge v1, v3, :cond_3

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    const/4 v4, -0x1

    aput-byte v4, v3, v1

    add-int/lit8 v1, v1, 0x1

    goto :goto_3

    .line 135
    :cond_3
    const/4 v1, 0x0

    :goto_4
    if-ge v1, v6, :cond_4

    sget-object v3, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    sget-object v4, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    aget-char v4, v4, v1

    int-to-byte v5, v1

    aput-byte v5, v3, v4

    add-int/lit8 v1, v1, 0x1

    goto :goto_4

    :cond_4
    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .prologue
    .line 239
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static decode(Ljava/lang/String;)[B
    .locals 1
    .param p0, "s"    # Ljava/lang/String;

    .prologue
    .line 198
    invoke-virtual {p0}, Ljava/lang/String;->toCharArray()[C

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/util/Base64Coder;->decode([C)[B

    move-result-object v0

    return-object v0
.end method

.method public static decode([C)[B
    .locals 11
    .param p0, "in"    # [C

    .prologue
    .line 208
    array-length v0, p0

    .line 209
    .local v0, "iLen":I
    rem-int/lit8 v1, v0, 0x4

    if-eqz v1, :cond_a

    new-instance p0, Ljava/lang/IllegalArgumentException;

    .end local p0    # "in":[C
    const-string v0, "Length of Base64 encoded input string is not a multiple of 4."

    .end local v0    # "iLen":I
    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 210
    .local v4, "iLen":I
    .restart local p0    # "in":[C
    :goto_0
    if-lez v4, :cond_0

    const/4 v0, 0x1

    sub-int v0, v4, v0

    aget-char v0, p0, v0

    const/16 v1, 0x3d

    if-ne v0, v1, :cond_0

    add-int/lit8 v0, v4, -0x1

    .end local v4    # "iLen":I
    .restart local v0    # "iLen":I
    move v4, v0

    .end local v0    # "iLen":I
    .restart local v4    # "iLen":I
    goto :goto_0

    .line 211
    :cond_0
    mul-int/lit8 v0, v4, 0x3

    div-int/lit8 v6, v0, 0x4

    .line 212
    .local v6, "oLen":I
    new-array v8, v6, [B

    .line 213
    .local v8, "out":[B
    const/4 v0, 0x0

    .line 214
    .local v0, "ip":I
    const/4 v1, 0x0

    .local v1, "op":I
    move v7, v1

    .line 215
    .end local v1    # "op":I
    .local v7, "op":I
    :goto_1
    if-ge v0, v4, :cond_7

    .line 216
    add-int/lit8 v1, v0, 0x1

    .end local v0    # "ip":I
    .local v1, "ip":I
    aget-char v0, p0, v0

    .line 217
    .local v0, "i0":I
    add-int/lit8 v2, v1, 0x1

    .end local v1    # "ip":I
    .local v2, "ip":I
    aget-char v1, p0, v1

    .line 218
    .local v1, "i1":I
    if-ge v2, v4, :cond_2

    add-int/lit8 v3, v2, 0x1

    .end local v2    # "ip":I
    .local v3, "ip":I
    aget-char v2, p0, v2

    move v5, v3

    .line 219
    .end local v3    # "ip":I
    .local v2, "i2":I
    .local v5, "ip":I
    :goto_2
    if-ge v5, v4, :cond_3

    add-int/lit8 v3, v5, 0x1

    .end local v5    # "ip":I
    .restart local v3    # "ip":I
    aget-char v5, p0, v5

    move v10, v5

    move v5, v3

    .end local v3    # "ip":I
    .restart local v5    # "ip":I
    move v3, v10

    .line 220
    .local v3, "i3":I
    :goto_3
    const/16 v9, 0x7f

    if-gt v0, v9, :cond_1

    const/16 v9, 0x7f

    if-gt v1, v9, :cond_1

    const/16 v9, 0x7f

    if-gt v2, v9, :cond_1

    const/16 v9, 0x7f

    if-le v3, v9, :cond_4

    .line 221
    :cond_1
    new-instance p0, Ljava/lang/IllegalArgumentException;

    .end local p0    # "in":[C
    const-string v0, "Illegal character in Base64 encoded data."

    .end local v0    # "i0":I
    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 218
    .end local v3    # "i3":I
    .end local v5    # "ip":I
    .restart local v0    # "i0":I
    .local v2, "ip":I
    .restart local p0    # "in":[C
    :cond_2
    const/16 v3, 0x41

    move v5, v2

    .end local v2    # "ip":I
    .restart local v5    # "ip":I
    move v2, v3

    goto :goto_2

    .line 219
    .local v2, "i2":I
    :cond_3
    const/16 v3, 0x41

    goto :goto_3

    .line 222
    .restart local v3    # "i3":I
    :cond_4
    sget-object v9, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    aget-byte v0, v9, v0

    .line 223
    .local v0, "b0":I
    sget-object v9, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    aget-byte v1, v9, v1

    .line 224
    .local v1, "b1":I
    sget-object v9, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    aget-byte v2, v9, v2

    .line 225
    .local v2, "b2":I
    sget-object v9, Lcom/esmertec/android/jbed/util/Base64Coder;->map2:[B

    aget-byte v3, v9, v3

    .line 226
    .local v3, "b3":I
    if-ltz v0, :cond_5

    if-ltz v1, :cond_5

    if-ltz v2, :cond_5

    if-gez v3, :cond_6

    .line 227
    :cond_5
    new-instance p0, Ljava/lang/IllegalArgumentException;

    .end local p0    # "in":[C
    const-string v0, "Illegal character in Base64 encoded data."

    .end local v0    # "b0":I
    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 228
    .restart local v0    # "b0":I
    .restart local p0    # "in":[C
    :cond_6
    shl-int/lit8 v0, v0, 0x2

    ushr-int/lit8 v9, v1, 0x4

    or-int/2addr v0, v9

    .line 229
    .local v0, "o0":I
    and-int/lit8 v1, v1, 0xf

    shl-int/lit8 v1, v1, 0x4

    ushr-int/lit8 v9, v2, 0x2

    or-int/2addr v1, v9

    .line 230
    .local v1, "o1":I
    and-int/lit8 v2, v2, 0x3

    shl-int/lit8 v2, v2, 0x6

    or-int/2addr v2, v3

    .line 231
    .local v2, "o2":I
    add-int/lit8 v3, v7, 0x1

    .end local v7    # "op":I
    .local v3, "op":I
    int-to-byte v0, v0

    aput-byte v0, v8, v7

    .line 232
    .end local v0    # "o0":I
    if-ge v3, v6, :cond_9

    add-int/lit8 v0, v3, 0x1

    .end local v3    # "op":I
    .local v0, "op":I
    int-to-byte v1, v1

    aput-byte v1, v8, v3

    .end local v1    # "o1":I
    move v1, v0

    .line 233
    .end local v0    # "op":I
    .local v1, "op":I
    :goto_4
    if-ge v1, v6, :cond_8

    add-int/lit8 v0, v1, 0x1

    .end local v1    # "op":I
    .restart local v0    # "op":I
    int-to-byte v2, v2

    aput-byte v2, v8, v1

    .end local v2    # "o2":I
    :goto_5
    move v7, v0

    .end local v0    # "op":I
    .restart local v7    # "op":I
    move v0, v5

    .end local v5    # "ip":I
    .local v0, "ip":I
    goto/16 :goto_1

    .line 234
    :cond_7
    return-object v8

    .end local v0    # "ip":I
    .end local v7    # "op":I
    .restart local v1    # "op":I
    .restart local v2    # "o2":I
    .restart local v5    # "ip":I
    :cond_8
    move v0, v1

    .end local v1    # "op":I
    .local v0, "op":I
    goto :goto_5

    .end local v0    # "op":I
    .local v1, "o1":I
    .restart local v3    # "op":I
    :cond_9
    move v1, v3

    .end local v3    # "op":I
    .local v1, "op":I
    goto :goto_4

    .end local v1    # "op":I
    .end local v2    # "o2":I
    .end local v4    # "iLen":I
    .end local v5    # "ip":I
    .end local v6    # "oLen":I
    .end local v8    # "out":[B
    .local v0, "iLen":I
    :cond_a
    move v4, v0

    .end local v0    # "iLen":I
    .restart local v4    # "iLen":I
    goto/16 :goto_0
.end method

.method public static decodeString(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "s"    # Ljava/lang/String;

    .prologue
    .line 189
    new-instance v0, Ljava/lang/String;

    invoke-static {p0}, Lcom/esmertec/android/jbed/util/Base64Coder;->decode(Ljava/lang/String;)[B

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    return-object v0
.end method

.method public static encode([B)[C
    .locals 1
    .param p0, "in"    # [B

    .prologue
    .line 153
    array-length v0, p0

    invoke-static {p0, v0}, Lcom/esmertec/android/jbed/util/Base64Coder;->encode([BI)[C

    move-result-object v0

    return-object v0
.end method

.method public static encode([BI)[C
    .locals 11
    .param p0, "in"    # [B
    .param p1, "iLen"    # I

    .prologue
    .line 163
    mul-int/lit8 v0, p1, 0x4

    add-int/lit8 v0, v0, 0x2

    div-int/lit8 v5, v0, 0x3

    .line 164
    .local v5, "oDataLen":I
    add-int/lit8 v0, p1, 0x2

    div-int/lit8 v0, v0, 0x3

    mul-int/lit8 v0, v0, 0x4

    .line 165
    .local v0, "oLen":I
    new-array v8, v0, [C

    .line 166
    .local v8, "out":[C
    const/4 v0, 0x0

    .line 167
    .local v0, "ip":I
    const/4 v1, 0x0

    .local v1, "op":I
    move v7, v1

    .line 168
    .end local v1    # "op":I
    .local v7, "op":I
    :goto_0
    if-ge v0, p1, :cond_4

    .line 169
    add-int/lit8 v1, v0, 0x1

    .end local v0    # "ip":I
    .local v1, "ip":I
    aget-byte v0, p0, v0

    and-int/lit16 v0, v0, 0xff

    .line 170
    .local v0, "i0":I
    if-ge v1, p1, :cond_0

    add-int/lit8 v2, v1, 0x1

    .end local v1    # "ip":I
    .local v2, "ip":I
    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    move v3, v2

    .line 171
    .end local v2    # "ip":I
    .local v1, "i1":I
    .local v3, "ip":I
    :goto_1
    if-ge v3, p1, :cond_1

    add-int/lit8 v2, v3, 0x1

    .end local v3    # "ip":I
    .restart local v2    # "ip":I
    aget-byte v3, p0, v3

    and-int/lit16 v3, v3, 0xff

    move v10, v3

    move v3, v2

    .end local v2    # "ip":I
    .restart local v3    # "ip":I
    move v2, v10

    .line 172
    .local v2, "i2":I
    :goto_2
    ushr-int/lit8 v4, v0, 0x2

    .line 173
    .local v4, "o0":I
    and-int/lit8 v0, v0, 0x3

    shl-int/lit8 v0, v0, 0x4

    ushr-int/lit8 v6, v1, 0x4

    or-int/2addr v0, v6

    .line 174
    .local v0, "o1":I
    and-int/lit8 v1, v1, 0xf

    shl-int/lit8 v1, v1, 0x2

    ushr-int/lit8 v6, v2, 0x6

    or-int/2addr v1, v6

    .line 175
    .local v1, "o2":I
    and-int/lit8 v2, v2, 0x3f

    .line 176
    .local v2, "o3":I
    add-int/lit8 v6, v7, 0x1

    .end local v7    # "op":I
    .local v6, "op":I
    sget-object v9, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    aget-char v4, v9, v4

    .end local v4    # "o0":I
    aput-char v4, v8, v7

    .line 177
    add-int/lit8 v4, v6, 0x1

    .end local v6    # "op":I
    .local v4, "op":I
    sget-object v7, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    aget-char v0, v7, v0

    .end local v0    # "o1":I
    aput-char v0, v8, v6

    .line 178
    if-ge v4, v5, :cond_2

    sget-object v0, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    aget-char v0, v0, v1

    :goto_3
    aput-char v0, v8, v4

    add-int/lit8 v0, v4, 0x1

    .line 179
    .end local v4    # "op":I
    .local v0, "op":I
    if-ge v0, v5, :cond_3

    sget-object v1, Lcom/esmertec/android/jbed/util/Base64Coder;->map1:[C

    .end local v1    # "o2":I
    aget-char v1, v1, v2

    :goto_4
    aput-char v1, v8, v0

    add-int/lit8 v0, v0, 0x1

    move v7, v0

    .end local v0    # "op":I
    .restart local v7    # "op":I
    move v0, v3

    .end local v3    # "ip":I
    .local v0, "ip":I
    goto :goto_0

    .line 170
    .end local v2    # "o3":I
    .local v0, "i0":I
    .local v1, "ip":I
    :cond_0
    const/4 v2, 0x0

    move v3, v1

    .end local v1    # "ip":I
    .restart local v3    # "ip":I
    move v1, v2

    goto :goto_1

    .line 171
    .local v1, "i1":I
    :cond_1
    const/4 v2, 0x0

    goto :goto_2

    .line 178
    .end local v0    # "i0":I
    .end local v7    # "op":I
    .local v1, "o2":I
    .restart local v2    # "o3":I
    .restart local v4    # "op":I
    :cond_2
    const/16 v0, 0x3d

    goto :goto_3

    .line 179
    .end local v4    # "op":I
    .local v0, "op":I
    :cond_3
    const/16 v1, 0x3d

    goto :goto_4

    .line 180
    .end local v1    # "o2":I
    .end local v2    # "o3":I
    .end local v3    # "ip":I
    .local v0, "ip":I
    .restart local v7    # "op":I
    :cond_4
    return-object v8
.end method

.method public static encodeString(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    .param p0, "s"    # Ljava/lang/String;

    .prologue
    .line 144
    new-instance v0, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    invoke-static {v1}, Lcom/esmertec/android/jbed/util/Base64Coder;->encode([B)[C

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([C)V

    return-object v0
.end method
