.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;
.super Ljava/lang/Object;
.source "PermissionEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "PermissionBuilder"
.end annotation


# instance fields
.field private mAllowedMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Ljava/lang/Byte;",
            "Lcom/esmertec/android/jbed/util/SimpleEntry",
            "<",
            "Ljava/lang/Byte;",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation
.end field

.field private mAllowedSet:B

.field private mContext:Landroid/content/Context;

.field mCurrentAllowed:B

.field private mPermissionList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/util/SimpleEntry",
            "<",
            "Ljava/lang/Byte;",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>(Landroid/content/Context;BB)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "allowedSet"    # B
    .param p3, "defaultAllowed"    # B

    .prologue
    .line 61
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 49
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedMap:Ljava/util/Map;

    .line 62
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mContext:Landroid/content/Context;

    .line 63
    iput-byte p2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedSet:B

    .line 64
    iput-byte p3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mCurrentAllowed:B

    .line 65
    return-void
.end method


# virtual methods
.method addPermission(BI)V
    .locals 5
    .param p1, "value"    # B
    .param p2, "textResId"    # I

    .prologue
    .line 69
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedMap:Ljava/util/Map;

    invoke-static {p1}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-static {p1}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mContext:Landroid/content/Context;

    invoke-virtual {v4, p2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-direct {v2, v3, v4}, Lcom/esmertec/android/jbed/util/SimpleEntry;-><init>(Ljava/lang/Object;Ljava/lang/Object;)V

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 70
    return-void
.end method

.method bindToSpinner(Landroid/widget/Spinner;)V
    .locals 5
    .param p1, "spinner"    # Landroid/widget/Spinner;

    .prologue
    .line 91
    new-instance v0, Landroid/widget/ArrayAdapter;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mContext:Landroid/content/Context;

    const v2, 0x7f03000e

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getAvailablePermissions()Ljava/util/List;

    move-result-object v3

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getAvailablePermissions()Ljava/util/List;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/List;->size()I

    move-result v4

    new-array v4, v4, [Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-interface {v3, v4}, Ljava/util/List;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v3

    invoke-direct {v0, v1, v2, v3}, Landroid/widget/ArrayAdapter;-><init>(Landroid/content/Context;I[Ljava/lang/Object;)V

    .line 94
    .local v0, "adapter":Landroid/widget/ArrayAdapter;, "Landroid/widget/ArrayAdapter<Lcom/esmertec/android/jbed/util/SimpleEntry<Ljava/lang/Byte;Ljava/lang/String;>;>;"
    const v1, 0x7f03000d

    invoke-virtual {v0, v1}, Landroid/widget/ArrayAdapter;->setDropDownViewResource(I)V

    .line 96
    invoke-virtual {p1, v0}, Landroid/widget/Spinner;->setAdapter(Landroid/widget/SpinnerAdapter;)V

    .line 97
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getDefaultAllowedPos()I

    move-result v1

    invoke-virtual {p1, v1}, Landroid/widget/Spinner;->setSelection(I)V

    .line 98
    return-void
.end method

.method getAvailablePermissions()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/util/SimpleEntry",
            "<",
            "Ljava/lang/Byte;",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation

    .prologue
    .line 73
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mPermissionList:Ljava/util/List;

    if-nez v1, :cond_1

    .line 74
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mPermissionList:Ljava/util/List;

    .line 75
    const/4 v0, 0x1

    .line 76
    .local v0, "mask":I
    :goto_0
    const/16 v1, 0x7f

    if-gt v0, v1, :cond_1

    .line 77
    iget-byte v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedSet:B

    and-int/2addr v1, v0

    if-eqz v1, :cond_0

    .line 78
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mPermissionList:Ljava/util/List;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedMap:Ljava/util/Map;

    int-to-byte v3, v0

    invoke-static {v3}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v3

    invoke-interface {v2, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 80
    :cond_0
    shl-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 83
    .end local v0    # "mask":I
    :cond_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mPermissionList:Ljava/util/List;

    return-object v1
.end method

.method getDefaultAllowedPos()I
    .locals 3

    .prologue
    .line 87
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getAvailablePermissions()Ljava/util/List;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mAllowedMap:Ljava/util/Map;

    iget-byte v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mCurrentAllowed:B

    invoke-static {v2}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v0

    return v0
.end method
