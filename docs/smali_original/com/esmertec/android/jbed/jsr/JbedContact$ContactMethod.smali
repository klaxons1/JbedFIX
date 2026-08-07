.class Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;
.super Ljava/lang/Object;
.source "JbedContact.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedContact$Mergeable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedContact;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x8
    name = "ContactMethod"
.end annotation


# static fields
.field private static final addrAttrMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private static final emailAttrMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private static final urlAttrMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field public data:Ljava/lang/String;

.field public kind:I

.field public type:I


# direct methods
.method static constructor <clinit>()V
    .locals 8

    .prologue
    const/4 v3, 0x0

    const-string v7, "X-JBED-OTHER"

    const-string v6, "WORK"

    const-string v5, "PREF"

    const-string v4, "HOME"

    .line 243
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    .line 245
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    .line 247
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    .line 251
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "PREF"

    invoke-virtual {v0, v1, v5}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 252
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "HOME"

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 253
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "WORK"

    invoke-virtual {v0, v1, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 254
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x3

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "X-JBED-OTHER"

    invoke-virtual {v0, v1, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 256
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "PREF"

    invoke-virtual {v0, v1, v5}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 257
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "HOME"

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 258
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "WORK"

    invoke-virtual {v0, v1, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 259
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x3

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "X-JBED-OTHER"

    invoke-virtual {v0, v1, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 261
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "PREF"

    invoke-virtual {v0, v1, v5}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 262
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "HOME"

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 263
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x5

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "WORK"

    invoke-virtual {v0, v1, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 264
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x7

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "X-JBED-OTHER"

    invoke-virtual {v0, v1, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 266
    return-void
.end method

.method constructor <init>()V
    .locals 0

    .prologue
    .line 241
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;J)Landroid/content/ContentValues;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;
    .param p1, "x1"    # J

    .prologue
    .line 241
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->toValues(J)Landroid/content/ContentValues;

    move-result-object v0

    return-object v0
.end method

.method private toValues(J)Landroid/content/ContentValues;
    .locals 9
    .param p1, "rawContactId"    # J

    .prologue
    const/4 v4, 0x0

    const-string v8, "data3"

    const-string v7, "data2"

    const-string v6, "data1"

    const-string v5, "Custom"

    .line 276
    new-instance v1, Landroid/content/ContentValues;

    invoke-direct {v1}, Landroid/content/ContentValues;-><init>()V

    .line 277
    .local v1, "result":Landroid/content/ContentValues;
    const-string v2, "raw_contact_id"

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 279
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v3, 0x4

    if-ne v2, v3, :cond_2

    .line 281
    const-string v2, "mimetype"

    const-string v3, "vnd.android.cursor.item/email_v2"

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 282
    const-string v2, "data1"

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    invoke-virtual {v1, v6, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 283
    const-string v2, "data2"

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v7, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 284
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    if-nez v2, :cond_1

    const-string v2, "Custom"

    move-object v0, v5

    .line 285
    .local v0, "label":Ljava/lang/String;
    :goto_0
    const-string v2, "data3"

    invoke-virtual {v1, v8, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 305
    .end local v0    # "label":Ljava/lang/String;
    :cond_0
    :goto_1
    return-object v1

    :cond_1
    move-object v0, v4

    .line 284
    goto :goto_0

    .line 287
    :cond_2
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v3, 0x5

    if-ne v2, v3, :cond_4

    .line 289
    const-string v2, "mimetype"

    const-string v3, "vnd.android.cursor.item/postal-address_v2"

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 290
    const-string v2, "data1"

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    invoke-virtual {v1, v6, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 291
    const-string v2, "data2"

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v7, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 292
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    if-nez v2, :cond_3

    const-string v2, "Custom"

    move-object v0, v5

    .line 293
    .restart local v0    # "label":Ljava/lang/String;
    :goto_2
    const-string v2, "data3"

    invoke-virtual {v1, v8, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_1

    .end local v0    # "label":Ljava/lang/String;
    :cond_3
    move-object v0, v4

    .line 292
    goto :goto_2

    .line 295
    :cond_4
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v3, 0x6

    if-ne v2, v3, :cond_0

    .line 297
    const-string v2, "mimetype"

    const-string v3, "vnd.android.cursor.item/website"

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 298
    const-string v2, "data1"

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    invoke-virtual {v1, v6, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 299
    const-string v2, "data2"

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v7, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 300
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    if-nez v2, :cond_5

    const-string v2, "Custom"

    move-object v0, v5

    .line 301
    .restart local v0    # "label":Ljava/lang/String;
    :goto_3
    const-string v2, "data3"

    invoke-virtual {v1, v8, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_1

    .end local v0    # "label":Ljava/lang/String;
    :cond_5
    move-object v0, v4

    .line 300
    goto :goto_3
.end method


# virtual methods
.method public getAttribute()Ljava/lang/String;
    .locals 3

    .prologue
    .line 325
    const/4 v0, 0x0

    .line 327
    .local v0, "attr":Ljava/lang/String;
    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v2, 0x4

    if-ne v1, v2, :cond_1

    .line 328
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->emailAttrMap:Ljava/util/HashMap;

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "attr":Ljava/lang/String;
    check-cast v0, Ljava/lang/String;

    .line 334
    .restart local v0    # "attr":Ljava/lang/String;
    :cond_0
    :goto_0
    if-nez v0, :cond_3

    new-instance v1, Ljava/lang/IllegalArgumentException;

    const-string v2, "unkown attribute type"

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 329
    :cond_1
    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v2, 0x5

    if-ne v1, v2, :cond_2

    .line 330
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->addrAttrMap:Ljava/util/HashMap;

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "attr":Ljava/lang/String;
    check-cast v0, Ljava/lang/String;

    .restart local v0    # "attr":Ljava/lang/String;
    goto :goto_0

    .line 331
    :cond_2
    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v2, 0x6

    if-ne v1, v2, :cond_0

    .line 332
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->urlAttrMap:Ljava/util/HashMap;

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .end local v0    # "attr":Ljava/lang/String;
    check-cast v0, Ljava/lang/String;

    .restart local v0    # "attr":Ljava/lang/String;
    goto :goto_0

    .line 335
    :cond_3
    return-object v0
.end method

.method public getData()Ljava/lang/String;
    .locals 2

    .prologue
    .line 339
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x4

    if-ne v0, v1, :cond_0

    .line 340
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    .line 348
    :goto_0
    return-object v0

    .line 341
    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x5

    if-ne v0, v1, :cond_1

    .line 342
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedContact;->access$000(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    goto :goto_0

    .line 343
    :cond_1
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x6

    if-ne v0, v1, :cond_2

    .line 344
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    goto :goto_0

    .line 348
    :cond_2
    const-string v0, ""

    goto :goto_0
.end method

.method public getKeyWord()Ljava/lang/String;
    .locals 2

    .prologue
    .line 314
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x4

    if-ne v0, v1, :cond_0

    .line 315
    const-string v0, "EMAIL"

    .line 319
    :goto_0
    return-object v0

    .line 316
    :cond_0
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x5

    if-ne v0, v1, :cond_1

    .line 317
    const-string v0, "LABEL"

    goto :goto_0

    .line 318
    :cond_1
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    const/4 v1, 0x6

    if-ne v0, v1, :cond_2

    .line 319
    const-string v0, "URL"

    goto :goto_0

    .line 321
    :cond_2
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "unkown contact type"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 310
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "[contactmethod]kind="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->kind:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " type="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->type:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " data="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$ContactMethod;->data:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
