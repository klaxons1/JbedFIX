.class public Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;
.super Ljava/lang/Object;
.source "InstallEventHandler.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/InstallEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "DisposableClickListener"
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "DisposableClickListener"


# instance fields
.field executed:Z


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 644
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 645
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;->executed:Z

    return-void
.end method


# virtual methods
.method public execute(Landroid/content/DialogInterface;I)V
    .locals 0
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 657
    return-void
.end method

.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 649
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;->executed:Z

    if-nez v0, :cond_0

    .line 650
    invoke-virtual {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;->execute(Landroid/content/DialogInterface;I)V

    .line 651
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/InstallEventHandler$DisposableClickListener;->executed:Z

    .line 655
    :goto_0
    return-void

    .line 653
    :cond_0
    const-string v0, "DisposableClickListener"

    const-string v1, "multi pressing !"

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method
