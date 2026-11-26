.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "PlatformRequestHandler"
.end annotation


# static fields
.field public static midletName:Ljava/lang/String;

.field private static platformRequestDialog:Landroid/app/AlertDialog;


# instance fields
.field private url:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 1634
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1630
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method public static cancelPlatformReqeust()V
    .locals 2

    .prologue
    .line 1680
    const-string v0, "AmsEventHandler"

    const-string v1, "[PlatformRequestHandler]cancelPlatformReqeust()"

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 1681
    sget-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    if-eqz v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->isShowing()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 1682
    sget-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    invoke-virtual {v0}, Landroid/app/AlertDialog;->cancel()V

    .line 1683
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    .line 1685
    :cond_0
    return-void
.end method


# virtual methods
.method public parseData([B)V
    .locals 3
    .param p1, "data"    # [B
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 1638
    if-nez p1, :cond_0

    .line 1639
    new-instance v1, Ljava/lang/IllegalArgumentException;

    const-string v2, "pass the invalid data in REQUEST_PLATFORM_REQUEST event!!!"

    invoke-direct {v1, v2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 1641
    :cond_0
    new-instance v0, Ljava/io/DataInputStream;

    new-instance v1, Ljava/io/ByteArrayInputStream;

    invoke-direct {v1, p1}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v0, v1}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 1644
    .local v0, "in":Ljava/io/DataInputStream;
    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v1

    sput-object v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->midletName:Ljava/lang/String;

    .line 1647
    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->readJbedString(Ljava/io/DataInputStream;)Ljava/lang/String;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->url:Ljava/lang/String;

    .line 1648
    invoke-virtual {v0}, Ljava/io/DataInputStream;->close()V

    .line 1649
    return-void
.end method

.method public run()V
    .locals 9

    .prologue
    const/4 v8, 0x0

    const-string v7, "\'"

    .line 1653
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0502db

    const/4 v3, 0x2

    new-array v3, v3, [Ljava/lang/Object;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "\'"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    sget-object v5, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->midletName:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\'"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    aput-object v4, v3, v8

    const/4 v4, 0x1

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "\'"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    iget-object v6, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->url:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "\'"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    aput-object v5, v3, v4

    invoke-virtual {v1, v2, v3}, Landroid/content/Context;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 1655
    .local v0, "msg":Ljava/lang/String;
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->mContext:Landroid/content/Context;

    const v3, 0x7f0502da

    invoke-virtual {v2, v3}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040013

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$3;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x1040009

    new-instance v3, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$2;

    invoke-direct {v3, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;)V

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;)V

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1, v8}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    move-result-object v1

    sput-object v1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;->platformRequestDialog:Landroid/app/AlertDialog;

    .line 1677
    return-void
.end method
