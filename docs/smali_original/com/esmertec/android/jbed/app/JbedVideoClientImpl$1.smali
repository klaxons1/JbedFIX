.class Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;
.super Ljava/lang/Object;
.source "JbedVideoClientImpl.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->setVisible(Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)V
    .locals 0

    .prologue
    .line 346
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    .prologue
    const v6, -0x7fffffff

    .line 348
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$300(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Landroid/widget/AbsoluteLayout;

    move-result-object v0

    new-instance v1, Landroid/widget/AbsoluteLayout$LayoutParams;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->width()I

    move-result v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v3}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v3}, Landroid/graphics/Rect;->height()I

    move-result v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v4}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v4, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    iget v4, v4, Landroid/graphics/Rect;->left:I

    iget-object v5, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v5}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    iget v5, v5, Landroid/graphics/Rect;->top:I

    invoke-direct {v1, v2, v3, v4, v5}, Landroid/widget/AbsoluteLayout$LayoutParams;-><init>(IIII)V

    invoke-virtual {v0, v1}, Landroid/widget/AbsoluteLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 353
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    move-result-object v0

    new-instance v1, Landroid/widget/AbsoluteLayout$LayoutParams;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->width()I

    move-result v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl$1;->this$0:Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;

    invoke-static {v3}, Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;->access$200(Lcom/esmertec/android/jbed/app/JbedVideoClientImpl;)Lcom/esmertec/android/jbed/jsr/JbedVideoView;

    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->mDefaultLocation:Landroid/graphics/Rect;

    invoke-virtual {v3}, Landroid/graphics/Rect;->height()I

    move-result v3

    invoke-direct {v1, v2, v3, v6, v6}, Landroid/widget/AbsoluteLayout$LayoutParams;-><init>(IIII)V

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedVideoView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 358
    return-void
.end method
