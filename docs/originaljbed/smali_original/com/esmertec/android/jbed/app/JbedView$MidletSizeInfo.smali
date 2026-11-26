.class Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;
.super Ljava/lang/Object;
.source "JbedView.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedView;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "MidletSizeInfo"
.end annotation


# instance fields
.field public height:I

.field public landScale:F

.field public porScale:F

.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedView;

.field public width:I


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/app/JbedView;IIFF)V
    .locals 0
    .param p2, "w"    # I
    .param p3, "h"    # I
    .param p4, "pScale"    # F
    .param p5, "lScale"    # F

    .prologue
    .line 448
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->this$0:Lcom/esmertec/android/jbed/app/JbedView;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 449
    iput p2, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->width:I

    .line 450
    iput p3, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->height:I

    .line 451
    iput p4, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->porScale:F

    .line 452
    iput p5, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->landScale:F

    .line 453
    return-void
.end method


# virtual methods
.method public set(IIFF)V
    .locals 0
    .param p1, "w"    # I
    .param p2, "h"    # I
    .param p3, "pScale"    # F
    .param p4, "lScale"    # F

    .prologue
    .line 456
    iput p1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->width:I

    .line 457
    iput p2, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->height:I

    .line 458
    iput p3, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->porScale:F

    .line 459
    iput p4, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->landScale:F

    .line 460
    return-void
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .prologue
    .line 463
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "width="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->width:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", height="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->height:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", pScale="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->porScale:F

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", lScale="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget v1, p0, Lcom/esmertec/android/jbed/app/JbedView$MidletSizeInfo;->landScale:F

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
