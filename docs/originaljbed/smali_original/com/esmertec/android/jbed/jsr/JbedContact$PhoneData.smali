.class Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;
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
    name = "PhoneData"
.end annotation


# static fields
.field private static final phoneAttrMap:Ljava/util/HashMap;
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
.field private data:Ljava/lang/String;

.field private label:Ljava/lang/String;

.field private type:I


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .prologue
    .line 143
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    .line 147
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "PREF"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 148
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x1

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "HOME"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 149
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "CELL"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 150
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x3

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "WORK"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 151
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "FAX"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x6

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "PAGER"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 154
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    const/4 v1, 0x7

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-string v2, "X-JBED-OTHER"

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 156
    return-void
.end method

.method constructor <init>()V
    .locals 0

    .prologue
    .line 142
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$102(Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;Ljava/lang/String;)Ljava/lang/String;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;
    .param p1, "x1"    # Ljava/lang/String;

    .prologue
    .line 142
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->data:Ljava/lang/String;

    return-object p1
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;
    .param p1, "x1"    # I

    .prologue
    .line 142
    iput p1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    return p1
.end method

.method static synthetic access$302(Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;Ljava/lang/String;)Ljava/lang/String;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;
    .param p1, "x1"    # Ljava/lang/String;

    .prologue
    .line 142
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->label:Ljava/lang/String;

    return-object p1
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;J)Landroid/content/ContentValues;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;
    .param p1, "x1"    # J

    .prologue
    .line 142
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->toValues(J)Landroid/content/ContentValues;

    move-result-object v0

    return-object v0
.end method

.method private toValues(J)Landroid/content/ContentValues;
    .locals 5
    .param p1, "rawContactId"    # J

    .prologue
    const-string v4, "JbedPIMContact"

    .line 164
    new-instance v1, Landroid/content/ContentValues;

    invoke-direct {v1}, Landroid/content/ContentValues;-><init>()V

    .line 166
    .local v1, "result":Landroid/content/ContentValues;
    const-string v2, "raw_contact_id"

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 167
    const-string v2, "mimetype"

    const-string v3, "vnd.android.cursor.item/phone_v2"

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 169
    const-string v2, "data2"

    iget v3, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 170
    const-string v2, "JbedPIMContact"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "type "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 171
    const-string v2, "data1"

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->data:Ljava/lang/String;

    invoke-virtual {v1, v2, v3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 172
    const-string v2, "JbedPIMContact"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "PhoneData "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->data:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 174
    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    if-nez v2, :cond_0

    const-string v2, "Custom"

    move-object v0, v2

    .line 175
    .local v0, "label":Ljava/lang/String;
    :goto_0
    const-string v2, "JbedPIMContact"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Label "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 176
    const-string v2, "data3"

    invoke-virtual {v1, v2, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 177
    return-object v1

    .line 174
    .end local v0    # "label":Ljava/lang/String;
    :cond_0
    const/4 v2, 0x0

    move-object v0, v2

    goto :goto_0
.end method


# virtual methods
.method public getAttribute()Ljava/lang/String;
    .locals 3

    .prologue
    .line 194
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->phoneAttrMap:Ljava/util/HashMap;

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 195
    .local v0, "attr":Ljava/lang/String;
    if-nez v0, :cond_0

    new-instance v1, Ljava/lang/IllegalArgumentException;

    const-string v2, "unkown attribute type"

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 196
    :cond_0
    return-object v0
.end method

.method public getData()Ljava/lang/String;
    .locals 1

    .prologue
    .line 190
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->data:Ljava/lang/String;

    return-object v0
.end method

.method public getKeyWord()Ljava/lang/String;
    .locals 1

    .prologue
    .line 186
    const-string v0, "TEL"

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 182
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "[PhoneData]type="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->type:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " data="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedContact$PhoneData;->data:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
