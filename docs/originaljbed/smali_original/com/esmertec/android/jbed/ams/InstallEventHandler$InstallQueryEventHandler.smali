.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "InstallEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "InstallQueryEventHandler"
.end annotation


# static fields
.field private static timeoutDialog:Landroid/app/AlertDialog;


# instance fields
.field private mIsActioned:Z


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 303
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->timeoutDialog:Landroid/app/AlertDialog;

    return-void
.end method

.method public constructor <init>()V
    .locals 1

    .prologue
    .line 300
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    .line 302
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mIsActioned:Z

    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)Z
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    .prologue
    .line 300
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mIsActioned:Z

    return v0
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;Z)Z
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;
    .param p1, "x1"    # Z

    .prologue
    .line 300
    iput-boolean p1, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mIsActioned:Z

    return p1
.end method

.method static synthetic access$100()Landroid/app/AlertDialog;
    .locals 1

    .prologue
    .line 300
    sget-object v0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->timeoutDialog:Landroid/app/AlertDialog;

    return-object v0
.end method


# virtual methods
.method public run()V
    .locals 13

    .prologue
    const v10, 0x1040009

    const v12, 0x7f05006d

    const v11, 0x1040013

    .line 307
    invoke-static {}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->dismissDialog()V

    .line 309
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v8}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v5

    .line 310
    .local v5, "msg":Ljava/lang/String;
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v8, v8, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/4 v9, 0x2

    if-ne v8, v9, :cond_1

    .line 311
    const/16 v8, 0x2c

    invoke-virtual {v5, v8}, Ljava/lang/String;->indexOf(I)I

    move-result v3

    .line 312
    .local v3, "index":I
    const/4 v8, 0x0

    invoke-virtual {v5, v8, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v8

    invoke-static {v8}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v6

    .line 313
    .local v6, "timeout":I
    add-int/lit8 v8, v3, 0x1

    invoke-virtual {v5, v8}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v5

    .line 314
    const-string v8, "AmsEventHandler"

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "InstallQueryEventHandler timeout:"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ", msg:"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-static {v8, v9}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 315
    if-eqz v6, :cond_0

    .line 327
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$2;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$1;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v8

    sput-object v8, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->timeoutDialog:Landroid/app/AlertDialog;

    .line 349
    sget-object v8, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->timeoutDialog:Landroid/app/AlertDialog;

    invoke-virtual {v8}, Landroid/app/AlertDialog;->show()V

    .line 350
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mHandler:Landroid/os/Handler;

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    int-to-long v10, v6

    invoke-virtual {v8, v9, v10, v11}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    .line 475
    .end local v3    # "index":I
    .end local v6    # "timeout":I
    :goto_0
    return-void

    .line 363
    .restart local v3    # "index":I
    .restart local v6    # "timeout":I
    :cond_0
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$5;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$4;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$4;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v0

    .line 386
    .local v0, "dialog":Landroid/app/AlertDialog;
    invoke-virtual {v0}, Landroid/app/AlertDialog;->show()V

    goto :goto_0

    .line 388
    .end local v0    # "dialog":Landroid/app/AlertDialog;
    .end local v3    # "index":I
    .end local v6    # "timeout":I
    :cond_1
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v8, v8, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    const/16 v9, 0x21

    if-ne v8, v9, :cond_2

    .line 402
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mContext:Landroid/content/Context;

    const-string v9, "layout_inflater"

    invoke-virtual {v8, v9}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Landroid/view/LayoutInflater;

    .line 403
    .local v4, "mInflater":Landroid/view/LayoutInflater;
    const v8, 0x7f030001

    const/4 v9, 0x0

    invoke-virtual {v4, v8, v9}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v7

    .line 404
    .local v7, "v":Landroid/view/View;
    const v8, 0x7f080002

    invoke-virtual {v7, v8}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/EditText;

    .line 405
    .local v2, "edtText":Landroid/widget/EditText;
    const v8, 0x7f080004

    invoke-virtual {v7, v8}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/EditText;

    .line 406
    .local v1, "edtPwd":Landroid/widget/EditText;
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v7}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;

    invoke-direct {v9, p0, v2, v1}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$8;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;Landroid/widget/EditText;Landroid/widget/EditText;)V

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$7;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$7;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v10, v9}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$6;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$6;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0

    .line 454
    .end local v1    # "edtPwd":Landroid/widget/EditText;
    .end local v2    # "edtText":Landroid/widget/EditText;
    .end local v4    # "mInflater":Landroid/view/LayoutInflater;
    .end local v7    # "v":Landroid/view/View;
    :cond_2
    new-instance v8, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->getContext()Landroid/content/Context;

    move-result-object v9

    invoke-direct {v8, v9}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v9, v12}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$11;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$11;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v11, v9}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$10;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$10;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v10, v9}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    new-instance v9, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$9;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler$9;-><init>(Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;)V

    invoke-virtual {v8, v9}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v8

    invoke-virtual {v8}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0
.end method
