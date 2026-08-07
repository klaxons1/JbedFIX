.class public Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "PermissionEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RequestPushEventHandler"
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "RequestPushEventHandler"

.field private static mRequestPushAlert:Landroid/app/AlertDialog;


# instance fields
.field private allowedSet:B

.field private mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

.field private prompt:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 356
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 343
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method public static cancelPushEventHandler()V
    .locals 1

    .prologue
    .line 421
    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 422
    sget-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->cancel()V

    .line 423
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    .line 425
    :cond_0
    return-void
.end method


# virtual methods
.method public parseData([B)V
    .locals 5
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 360
    if-nez p1, :cond_0

    .line 361
    new-instance v2, Ljava/lang/IllegalArgumentException;

    const-string v3, "pass the invalid data in RUNTIME_ERROR event!!!"

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 363
    :cond_0
    new-instance v1, Ljava/io/DataInputStream;

    new-instance v2, Ljava/io/ByteArrayInputStream;

    invoke-direct {v2, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v1, v2}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 365
    .local v1, "in":Ljava/io/DataInputStream;
    invoke-virtual {v1}, Ljava/io/DataInputStream;->readByte()B

    move-result v2

    iput-byte v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->allowedSet:B

    .line 367
    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 369
    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 371
    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 373
    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    .line 375
    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v2

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->prompt:Ljava/lang/String;

    .line 376
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V

    .line 378
    const/16 v0, 0x10

    .line 379
    .local v0, "defaultAllowed":B
    new-instance v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mContext:Landroid/content/Context;

    iget-byte v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->allowedSet:B

    invoke-direct {v2, v3, v4, v0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;-><init>(Landroid/content/Context;BB)V

    iput-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    .line 380
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v3, 0x1

    const v4, 0x7f0500c6

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 381
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v3, 0x2

    const v4, 0x7f0500c3

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 382
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/4 v3, 0x4

    const v4, 0x7f0500c5

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 383
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v3, 0x8

    const v4, 0x7f0500c4

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 384
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v3, 0x10

    const v4, 0x7f0500c2

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 385
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    const/16 v3, 0x20

    const v4, 0x7f0500c1

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->addPermission(BI)V

    .line 387
    return-void
.end method

.method public run()V
    .locals 7

    .prologue
    .line 391
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mContext:Landroid/content/Context;

    const-string v5, "layout_inflater"

    invoke-virtual {v4, v5}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/LayoutInflater;

    .line 393
    .local v0, "inflater":Landroid/view/LayoutInflater;
    const v4, 0x7f03000a

    const/4 v5, 0x0

    invoke-virtual {v0, v4, v5}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/LinearLayout;

    .line 395
    .local v1, "layout":Landroid/widget/LinearLayout;
    const v4, 0x7f080021

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroid/widget/TextView;

    .line 396
    .local v3, "textLabel":Landroid/widget/TextView;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->prompt:Ljava/lang/String;

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 398
    const v4, 0x7f080022

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/Spinner;

    .line 399
    .local v2, "spinner":Landroid/widget/Spinner;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v4, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->bindToSpinner(Landroid/widget/Spinner;)V

    .line 401
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->getContext()Landroid/content/Context;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f050055

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v1}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x1040013

    new-instance v6, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$1;

    invoke-direct {v6, p0, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;Landroid/widget/Spinner;)V

    invoke-virtual {v4, v5, v6}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const/4 v5, 0x0

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v4

    sput-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    .line 412
    sget-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    new-instance v5, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;)V

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)V

    .line 417
    sget-object v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;->mRequestPushAlert:Landroid/app/AlertDialog;

    invoke-virtual {v4}, Landroid/app/AlertDialog;->show()V

    .line 418
    return-void
.end method
