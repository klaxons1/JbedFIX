.class public Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;
.super Landroid/app/Activity;
.source "JbedShowInfoActivity.java"


# static fields
.field private static final DEBUG:Z = false

.field private static final TAG:Ljava/lang/String; = "JbedShowInfoActivity"

.field private static pkgName:Ljava/lang/String;


# instance fields
.field private str1:Ljava/lang/String;

.field private str2:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 24
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->pkgName:Ljava/lang/String;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 21
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    return-void
.end method

.method static synthetic access$000()Ljava/lang/String;
    .locals 1

    .prologue
    .line 21
    sget-object v0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->pkgName:Ljava/lang/String;

    return-object v0
.end method


# virtual methods
.method public onCreate(Landroid/os/Bundle;)V
    .locals 11
    .param p1, "savedInstanceState"    # Landroid/os/Bundle;

    .prologue
    const v10, 0x7f05029e

    const v9, 0x1040009

    const v6, 0x7f05006d

    const v8, 0x1040013

    const/4 v7, 0x0

    .line 31
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 32
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getIntent()Landroid/content/Intent;

    move-result-object v2

    .line 33
    .local v2, "intent":Landroid/content/Intent;
    const-string v4, "no_sdcard"

    invoke-virtual {v2, v4, v7}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v4

    if-eqz v4, :cond_1

    .line 36
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    const v5, 0x7f05030a

    invoke-virtual {p0, v5}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v7}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$1;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$1;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v8, v5}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 111
    :cond_0
    :goto_0
    return-void

    .line 45
    :cond_1
    const-string v4, "oom"

    invoke-virtual {v2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    iput-object v4, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->str1:Ljava/lang/String;

    if-eqz v4, :cond_2

    .line 46
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v5, 0x7f050222

    invoke-virtual {p0, v5}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->str1:Ljava/lang/String;

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v7}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v8, v5}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$2;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$2;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v9, v5}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0

    .line 63
    :cond_2
    const-string v4, "noRootInfo"

    invoke-virtual {v2, v4, v7}, Landroid/content/Intent;->getBooleanExtra(Ljava/lang/String;Z)Z

    move-result v4

    if-eqz v4, :cond_3

    .line 64
    const v4, 0x7f0501e9

    invoke-virtual {p0, v4}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 65
    .local v0, "application":Ljava/lang/String;
    const v4, 0x7f050384

    invoke-virtual {p0, v4}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v1

    .line 66
    .local v1, "deletion":Ljava/lang/String;
    const v4, 0x7f0502ed

    const/4 v5, 0x1

    new-array v5, v5, [Ljava/lang/Object;

    aput-object v0, v5, v7

    invoke-virtual {p0, v4, v5}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    .line 67
    .local v3, "msg":Ljava/lang/String;
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\n"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 68
    const-string v4, "packageName"

    invoke-virtual {v2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    sput-object v4, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->pkgName:Ljava/lang/String;

    .line 69
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v3}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v7}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$5;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v8, v5}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$4;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$4;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v9, v5}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0

    .line 90
    .end local v0    # "application":Ljava/lang/String;
    .end local v1    # "deletion":Ljava/lang/String;
    .end local v3    # "msg":Ljava/lang/String;
    :cond_3
    const-string v4, "init_error"

    invoke-virtual {v2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    iput-object v4, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->str1:Ljava/lang/String;

    if-eqz v4, :cond_4

    .line 91
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0, v10}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "\n"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const v6, 0x7f050372

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v7}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$6;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$6;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v8, v5}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0

    .line 100
    :cond_4
    const-string v4, "error"

    invoke-virtual {v2, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    iput-object v4, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->str2:Ljava/lang/String;

    if-eqz v4, :cond_0

    .line 101
    new-instance v4, Landroid/app/AlertDialog$Builder;

    invoke-direct {v4, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {p0, v6}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {p0, v10}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4, v7}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    new-instance v5, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$7;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$7;-><init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V

    invoke-virtual {v4, v8, v5}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v4

    invoke-virtual {v4}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0
.end method
