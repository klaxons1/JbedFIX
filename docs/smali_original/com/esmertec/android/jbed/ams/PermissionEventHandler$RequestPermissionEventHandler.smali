.class public Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "PermissionEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RequestPermissionEventHandler"
.end annotation


# static fields
.field private static mRequestPermissionAlert:Landroid/app/AlertDialog;


# instance fields
.field private mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

.field private mLabel:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 111
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 105
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method public static cancelPermissionEventHandler()V
    .locals 1

    .prologue
    .line 178
    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 179
    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->cancel()V

    .line 180
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    .line 182
    :cond_0
    return-void
.end method


# virtual methods
.method public parseData([B)V
    .locals 6
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 115
    if-nez p1, :cond_0

    .line 116
    new-instance v3, Ljava/lang/IllegalArgumentException;

    const-string v4, "pass the invalid data in REQUEST_PERMISSION event!!!"

    invoke-direct {v3, v4}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 118
    :cond_0
    new-instance v2, Ljava/io/DataInputStream;

    new-instance v3, Ljava/io/ByteArrayInputStream;

    invoke-direct {v3, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v2, v3}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 120
    .local v2, "in":Ljava/io/DataInputStream;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isSupportSoftKeyboard()Z

    move-result v3

    if-eqz v3, :cond_1

    .line 122
    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 125
    :cond_1
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readByte()B

    move-result v0

    .line 126
    .local v0, "allowedSet":B
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readByte()B

    move-result v1

    .line 128
    .local v1, "defaultAllowed":B
    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v3

    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mLabel:Ljava/lang/String;

    .line 131
    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 133
    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 134
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V

    .line 136
    new-instance v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mContext:Landroid/content/Context;

    invoke-direct {v3, v4, v0, v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;-><init>(Landroid/content/Context;BB)V

    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    .line 137
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v4, 0x1

    const v5, 0x7f0500c6

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 138
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v4, 0x2

    const v5, 0x7f0500c3

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 139
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v4, 0x4

    const v5, 0x7f0500c5

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 140
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v4, 0x8

    const v5, 0x7f0500c4

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 141
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v4, 0x10

    const v5, 0x7f0500c2

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 142
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v4, 0x20

    const v5, 0x7f0500c1

    invoke-virtual {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 144
    return-void
.end method

.method public run()V
    .locals 7

    .prologue
    .line 148
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mContext:Landroid/content/Context;

    const-string v5, "layout_inflater"

    invoke-virtual {v4, v5}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/LayoutInflater;

    .line 150
    .local v0, "inflater":Landroid/view/LayoutInflater;
    const v4, 0x7f03000a

    const/4 v5, 0x0

    invoke-virtual {v0, v4, v5}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/LinearLayout;

    .line 152
    .local v1, "layout":Landroid/widget/LinearLayout;
    const v4, 0x7f080021

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroid/widget/TextView;

    .line 153
    .local v3, "textLabel":Landroid/widget/TextView;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mLabel:Ljava/lang/String;

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 155
    const v4, 0x7f080022

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/Spinner;

    .line 156
    .local v2, "spinner":Landroid/widget/Spinner;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v4, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->bindToSpinner(Landroid/widget/Spinner;)V

    .line 158
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f050055

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v1}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040013

    new-instance v6, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;

    invoke-direct {v6, p0, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;Landroid/widget/Spinner;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v4

    sput-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    .line 169
    sget-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    new-instance v5, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$2;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;)V

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)V

    .line 174
    sget-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;->mRequestPermissionAlert:Landroid/app/AlertDialog;

    invoke-virtual {v4}, Landroid/app/AlertDialog;->show()V

    .line 175
    return-void
.end method
