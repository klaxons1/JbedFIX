.class Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;
.super Ljava/lang/Object;
.source "JbedVideoView.java"

# interfaces
.implements Landroid/media/MediaPlayer$OnErrorListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedVideoView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)V
    .locals 0

    .prologue
    .line 481
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onError(Landroid/media/MediaPlayer;II)Z
    .locals 6
    .param p1, "mp"    # Landroid/media/MediaPlayer;
    .param p2, "a"    # I
    .param p3, "b"    # I

    .prologue
    const/4 v5, 0x1

    .line 484
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v2

    if-eqz v2, :cond_0

    .line 485
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1700(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/widget/MediaController;

    move-result-object v2

    invoke-virtual {v2}, Landroid/widget/MediaController;->hide()V

    .line 489
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2200(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnErrorListener;

    move-result-object v2

    if-eqz v2, :cond_1

    .line 490
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2200(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer$OnErrorListener;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$1600(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/media/MediaPlayer;

    move-result-object v3

    invoke-interface {v2, v3, p2, p3}, Landroid/media/MediaPlayer$OnErrorListener;->onError(Landroid/media/MediaPlayer;II)Z

    move-result v2

    if-eqz v2, :cond_1

    move v2, v5

    .line 527
    :goto_0
    return v2

    .line 500
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->getWindowToken()Landroid/os/IBinder;

    move-result-object v2

    if-eqz v2, :cond_2

    .line 501
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v2}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2300(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    .line 504
    .local v1, "r":Landroid/content/res/Resources;
    const/16 v2, 0xc8

    if-ne p2, v2, :cond_3

    .line 505
    const v0, 0x1040015

    .line 510
    .local v0, "messageId":I
    :goto_1
    new-instance v2, Landroid/app/AlertDialog$Builder;

    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;->this$0:Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    invoke-static {v3}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->access$2400(Lcom/esmertec/android/jbed/jsr/JbedVideoView;)Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v3, 0x1040012

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2, v0}, Landroid/app/AlertDialog$Builder;->setMessage(I)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const v3, 0x1040010

    new-instance v4, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoView$5$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedVideoView$5;)V

    invoke-virtual {v2, v3, v4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    move-result-object v2

    invoke-virtual {v2}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .end local v0    # "messageId":I
    .end local v1    # "r":Landroid/content/res/Resources;
    :cond_2
    move v2, v5

    .line 527
    goto :goto_0

    .line 507
    .restart local v1    # "r":Landroid/content/res/Resources;
    :cond_3
    const v0, 0x1040011

    .restart local v0    # "messageId":I
    goto :goto_1
.end method
