.class public Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "PermissionEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "PermissionsEventHandler"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;,
        Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;
    }
.end annotation


# instance fields
.field private mInflater:Landroid/view/LayoutInflater;

.field private mPermissionItemList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 189
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 191
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mPermissionItemList:Ljava/util/List;

    .line 247
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Landroid/view/LayoutInflater;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    .prologue
    .line 189
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mInflater:Landroid/view/LayoutInflater;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    .prologue
    .line 189
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mPermissionItemList:Ljava/util/List;

    return-object v0
.end method


# virtual methods
.method public parseData([B)V
    .locals 13
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 197
    if-nez p1, :cond_0

    .line 198
    new-instance v10, Ljava/lang/IllegalArgumentException;

    const-string v11, "pass the invalid data in RUNTIME_ERROR event!!!"

    invoke-direct {v10, v11}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v10

    .line 200
    :cond_0
    new-instance v6, Ljava/io/DataInputStream;

    new-instance v10, Ljava/io/ByteArrayInputStream;

    invoke-direct {v10, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v6, v10}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 202
    .local v6, "in":Ljava/io/DataInputStream;
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readInt()I

    move-result v2

    .line 203
    .local v2, "fgCount":I
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readInt()I

    move-result v4

    .line 206
    .local v4, "fgTypeCount":I
    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 208
    const/4 v5, 0x0

    .local v5, "i":I
    :goto_0
    if-ge v5, v4, :cond_3

    .line 209
    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v9

    .line 211
    .local v9, "typeText":Ljava/lang/String;
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readInt()I

    move-result v3

    .line 213
    .local v3, "fgCountPerType":I
    const/4 v8, 0x0

    .local v8, "j":I
    :goto_1
    if-ge v8, v3, :cond_2

    .line 214
    new-instance v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    invoke-direct {v7}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;-><init>()V

    .line 215
    .local v7, "item":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;
    iput-object v9, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mTypeText:Ljava/lang/String;

    .line 216
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readInt()I

    move-result v10

    int-to-byte v10, v10

    iput-byte v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mIndex:B

    .line 217
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readByte()B

    move-result v0

    .line 218
    .local v0, "allowedSet":B
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readByte()B

    move-result v1

    .line 219
    .local v1, "currentAllowed":B
    invoke-virtual {v6}, Ljava/io/DataInputStream;->readBoolean()Z

    move-result v10

    iput-boolean v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mChangable:Z

    .line 220
    invoke-static {v6}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v10

    iput-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mLabel:Ljava/lang/String;

    .line 222
    new-instance v10, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    iget-object v11, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mContext:Landroid/content/Context;

    invoke-direct {v10, v11, v0, v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;-><init>(Landroid/content/Context;BB)V

    iput-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    .line 223
    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v11, 0x1

    const v12, 0x7f0500dd

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 224
    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v11, 0x2

    const v12, 0x7f0500db

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 225
    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v11, 0x4

    const v12, 0x7f0500dc

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 226
    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v11, 0x8

    const v12, 0x7f0502d7

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 227
    iget-object v10, v7, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v11, 0x10

    const v12, 0x7f0502d8

    invoke-virtual {v10, v11, v12}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 229
    const-string v10, "reserved"

    invoke-virtual {v10, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v10

    if-nez v10, :cond_1

    .line 230
    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mPermissionItemList:Ljava/util/List;

    invoke-interface {v10, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 213
    :cond_1
    add-int/lit8 v8, v8, 0x1

    goto :goto_1

    .line 208
    .end local v0    # "allowedSet":B
    .end local v1    # "currentAllowed":B
    .end local v7    # "item":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;
    :cond_2
    add-int/lit8 v5, v5, 0x1

    goto :goto_0

    .line 234
    .end local v3    # "fgCountPerType":I
    .end local v8    # "j":I
    .end local v9    # "typeText":Ljava/lang/String;
    :cond_3
    invoke-virtual {v6}, Ljava/io/DataInputStream;->close()V

    .line 236
    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mContext:Landroid/content/Context;

    const-string v11, "layout_inflater"

    invoke-virtual {v10, v11}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Landroid/view/LayoutInflater;

    iput-object v10, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mInflater:Landroid/view/LayoutInflater;

    .line 237
    return-void
.end method

.method public run()V
    .locals 5

    .prologue
    .line 319
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mInflater:Landroid/view/LayoutInflater;

    const v3, 0x7f030005

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    .line 320
    .local v1, "view":Landroid/view/View;
    const v2, 0x7f080010

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/ListView;

    .line 321
    .local v0, "listView":Landroid/widget/ListView;
    const/4 v2, 0x0

    invoke-virtual {v0, v2}, Landroid/widget/ListView;->setFocusable(Z)V

    .line 322
    new-instance v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mPermissionItemList:Ljava/util/List;

    invoke-direct {v2, p0, v3}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;Ljava/util/List;)V

    invoke-virtual {v0, v2}, Landroid/widget/ListView;->setAdapter(Landroid/widget/ListAdapter;)V

    .line 324
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f050055

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040013

    new-instance v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040009

    sget-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 335
    return-void
.end method
