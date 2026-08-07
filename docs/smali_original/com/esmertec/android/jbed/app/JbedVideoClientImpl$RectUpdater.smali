.class Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;
.super Ljava/lang/Object;
.source "JbedVideoClientImpl.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "RectUpdater"
.end annotation


# static fields
.field private static final DEBUG:Z = false

.field private static final TAG:Ljava/lang/String; = "RectUpdater"


# instance fields
.field private mHandler:Landroid/os/Handler;

.field private mHeight:I

.field private mLeft:I

.field private mTop:I

.field private mView:Landroid/view/View;

.field private mWidth:I

.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;Landroid/view/View;Landroid/os/Handler;IIII)V
    .locals 0
    .param p2, "v"    # Landroid/view/View;
    .param p3, "hd"    # Landroid/os/Handler;
    .param p4, "x"    # I
    .param p5, "y"    # I
    .param p6, "w"    # I
    .param p7, "h"    # I

    .prologue
    .line 53
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 54
    iput-object p2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mView:Landroid/view/View;

    .line 55
    iput-object p3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mHandler:Landroid/os/Handler;

    .line 56
    iput p4, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mLeft:I

    .line 57
    iput p5, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mTop:I

    .line 58
    iput p6, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mWidth:I

    .line 59
    iput p7, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mHeight:I

    .line 60
    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    const/4 v6, 0x0

    .line 65
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mView:Landroid/view/View;

    new-instance v1, Landroid/widget/AbsoluteLayout$LayoutParams;

    iget v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mWidth:I

    iget v3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mHeight:I

    iget v4, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mLeft:I

    iget v5, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mTop:I

    invoke-direct {v1, v2, v3, v4, v5}, Landroid/widget/AbsoluteLayout$LayoutParams;-><init>(IIII)V

    invoke-virtual {v0, v1}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 67
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mView:Landroid/view/View;

    invoke-virtual {v0, v6}, Landroid/view/View;->setVisibility(I)V

    .line 68
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$000(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0, v6}, Landroid/view/View;->setVisibility(I)V

    .line 69
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$100(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/view/View;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/View;->postInvalidate()V

    .line 70
    return-void
.end method

.method public update()V
    .locals 1

    .prologue
    .line 73
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$RectUpdater;->mHandler:Landroid/os/Handler;

    invoke-virtual {v0, p0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    .line 74
    return-void
.end method
