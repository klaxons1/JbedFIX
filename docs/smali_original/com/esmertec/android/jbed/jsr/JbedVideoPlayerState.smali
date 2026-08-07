.class public Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;
.super Ljava/lang/Object;
.source "JbedVideoPlayerState.java"

# interfaces
.implements Landroid/os/Parcelable;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;
    }
.end annotation


# static fields
.field public static final CREATOR:Landroid/os/Parcelable$Creator;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Landroid/os/Parcelable$Creator",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;",
            ">;"
        }
    .end annotation
.end field

.field private static final TAG:Ljava/lang/String; = "JbedVideoPlayerState"


# instance fields
.field public dataSource:Ljava/lang/String;

.field public displayViewRect:Landroid/graphics/Rect;

.field public isCapture:Z

.field public isPlaying:Z

.field public isVisible:Z

.field public position:I

.field public regionViewRect:Landroid/graphics/Rect;

.field public suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 139
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$1;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$1;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->CREATOR:Landroid/os/Parcelable$Creator;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .prologue
    const/4 v1, 0x0

    .line 26
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 16
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0, v1, v1, v1, v1}, Landroid/graphics/Rect;-><init>(IIII)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    .line 17
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0, v1, v1, v1, v1}, Landroid/graphics/Rect;-><init>(IIII)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    .line 22
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    .line 26
    return-void
.end method

.method public constructor <init>(Landroid/os/Parcel;)V
    .locals 4
    .param p1, "source"    # Landroid/os/Parcel;

    .prologue
    const/4 v2, 0x1

    const/4 v1, 0x0

    const-class v3, Landroid/graphics/Rect;

    .line 28
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 16
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0, v1, v1, v1, v1}, Landroid/graphics/Rect;-><init>(IIII)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    .line 17
    new-instance v0, Landroid/graphics/Rect;

    invoke-direct {v0, v1, v1, v1, v1}, Landroid/graphics/Rect;-><init>(IIII)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    .line 22
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    .line 29
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    .line 30
    const-class v0, Landroid/graphics/Rect;

    invoke-virtual {v3}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/os/Parcel;->readParcelable(Ljava/lang/ClassLoader;)Landroid/os/Parcelable;

    move-result-object v0

    check-cast v0, Landroid/graphics/Rect;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    .line 31
    const-class v0, Landroid/graphics/Rect;

    invoke-virtual {v3}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroid/os/Parcel;->readParcelable(Ljava/lang/ClassLoader;)Landroid/os/Parcelable;

    move-result-object v0

    check-cast v0, Landroid/graphics/Rect;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    .line 32
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    iput v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    .line 33
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-ne v0, v2, :cond_0

    move v0, v2

    :goto_0
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    .line 34
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-ne v0, v2, :cond_1

    move v0, v2

    :goto_1
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    .line 35
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    if-ne v0, v2, :cond_2

    move v0, v2

    :goto_2
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    .line 36
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    packed-switch v0, :pswitch_data_0

    .line 41
    :goto_3
    return-void

    :cond_0
    move v0, v1

    .line 33
    goto :goto_0

    :cond_1
    move v0, v1

    .line 34
    goto :goto_1

    :cond_2
    move v0, v1

    .line 35
    goto :goto_2

    .line 37
    :pswitch_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    goto :goto_3

    .line 38
    :pswitch_1
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DOING:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    goto :goto_3

    .line 39
    :pswitch_2
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    goto :goto_3

    .line 36
    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_1
        :pswitch_2
    .end packed-switch
.end method


# virtual methods
.method public describeContents()I
    .locals 1

    .prologue
    .line 119
    const/4 v0, 0x0

    return v0
.end method

.method public printToString()V
    .locals 2

    .prologue
    const-string v1, "JbedVideoPlayerState"

    .line 44
    const-string v0, "JbedVideoPlayerState"

    const/4 v0, 0x3

    invoke-static {v1, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "JbedVideoPlayerState"

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 45
    :cond_0
    return-void
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    .prologue
    const-string v3, ", "

    .line 49
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    .line 50
    .local v0, "msg":Ljava/lang/String;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 51
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 52
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 53
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 54
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 55
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 56
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ", "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-boolean v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 57
    return-object v0
.end method

.method public updateDisplayViewRect(ZII)Z
    .locals 3
    .param p1, "isLoc"    # Z
    .param p2, "param1"    # I
    .param p3, "param2"    # I

    .prologue
    .line 99
    const/4 v0, 0x0

    .line 100
    .local v0, "changed":Z
    if-eqz p1, :cond_2

    .line 101
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v1, v1, Landroid/graphics/Rect;->left:I

    if-ne v1, p2, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v1, v1, Landroid/graphics/Rect;->top:I

    if-eq v1, p3, :cond_1

    .line 102
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->width()I

    move-result v2

    add-int/2addr v2, p2

    iput v2, v1, Landroid/graphics/Rect;->right:I

    .line 103
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->height()I

    move-result v2

    add-int/2addr v2, p3

    iput v2, v1, Landroid/graphics/Rect;->bottom:I

    .line 104
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iput p2, v1, Landroid/graphics/Rect;->left:I

    .line 105
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iput p3, v1, Landroid/graphics/Rect;->top:I

    .line 106
    const/4 v0, 0x1

    .line 115
    :cond_1
    :goto_0
    return v0

    .line 109
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->width()I

    move-result v1

    if-ne v1, p2, :cond_3

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->height()I

    move-result v1

    if-eq v1, p3, :cond_1

    .line 110
    :cond_3
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v2, v2, Landroid/graphics/Rect;->left:I

    add-int/2addr v2, p2

    iput v2, v1, Landroid/graphics/Rect;->right:I

    .line 111
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    iget v2, v2, Landroid/graphics/Rect;->top:I

    add-int/2addr v2, p3

    iput v2, v1, Landroid/graphics/Rect;->bottom:I

    .line 112
    const/4 v0, 0x1

    goto :goto_0
.end method

.method public updateRegionViewRect(ZII)Z
    .locals 3
    .param p1, "isLoc"    # Z
    .param p2, "param1"    # I
    .param p3, "param2"    # I

    .prologue
    .line 70
    const/4 v0, 0x0

    .line 71
    .local v0, "changed":Z
    if-eqz p1, :cond_2

    .line 72
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v1, v1, Landroid/graphics/Rect;->left:I

    if-ne v1, p2, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v1, v1, Landroid/graphics/Rect;->top:I

    if-eq v1, p3, :cond_1

    .line 73
    :cond_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->width()I

    move-result v2

    add-int/2addr v2, p2

    iput v2, v1, Landroid/graphics/Rect;->right:I

    .line 74
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v2}, Landroid/graphics/Rect;->height()I

    move-result v2

    add-int/2addr v2, p3

    iput v2, v1, Landroid/graphics/Rect;->bottom:I

    .line 75
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iput p2, v1, Landroid/graphics/Rect;->left:I

    .line 76
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iput p3, v1, Landroid/graphics/Rect;->top:I

    .line 77
    const/4 v0, 0x1

    .line 86
    :cond_1
    :goto_0
    return v0

    .line 80
    :cond_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->width()I

    move-result v1

    if-ne v1, p2, :cond_3

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {v1}, Landroid/graphics/Rect;->height()I

    move-result v1

    if-eq v1, p3, :cond_1

    .line 81
    :cond_3
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v2, v2, Landroid/graphics/Rect;->left:I

    add-int/2addr v2, p2

    iput v2, v1, Landroid/graphics/Rect;->right:I

    .line 82
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    iget v2, v2, Landroid/graphics/Rect;->top:I

    add-int/2addr v2, p3

    iput v2, v1, Landroid/graphics/Rect;->bottom:I

    .line 83
    const/4 v0, 0x1

    goto :goto_0
.end method

.method public writeToParcel(Landroid/os/Parcel;I)V
    .locals 4
    .param p1, "parcel"    # Landroid/os/Parcel;
    .param p2, "arg1"    # I

    .prologue
    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 123
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->dataSource:Ljava/lang/String;

    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 124
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->regionViewRect:Landroid/graphics/Rect;

    invoke-virtual {p1, v0, v2}, Landroid/os/Parcel;->writeParcelable(Landroid/os/Parcelable;I)V

    .line 125
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->displayViewRect:Landroid/graphics/Rect;

    invoke-virtual {p1, v0, v2}, Landroid/os/Parcel;->writeParcelable(Landroid/os/Parcelable;I)V

    .line 126
    iget v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->position:I

    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    .line 127
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isPlaying:Z

    if-eqz v0, :cond_1

    move v0, v3

    :goto_0
    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    .line 128
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isVisible:Z

    if-eqz v0, :cond_2

    move v0, v3

    :goto_1
    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    .line 129
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->isCapture:Z

    if-eqz v0, :cond_3

    move v0, v3

    :goto_2
    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    .line 130
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->NONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v0, v1, :cond_4

    .line 131
    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeInt(I)V

    .line 137
    :cond_0
    :goto_3
    return-void

    :cond_1
    move v0, v2

    .line 127
    goto :goto_0

    :cond_2
    move v0, v2

    .line 128
    goto :goto_1

    :cond_3
    move v0, v2

    .line 129
    goto :goto_2

    .line 132
    :cond_4
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DOING:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v0, v1, :cond_5

    .line 133
    invoke-virtual {p1, v3}, Landroid/os/Parcel;->writeInt(I)V

    goto :goto_3

    .line 134
    :cond_5
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState;->suspend:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;->DONE:Lcom/esmertec/android/jbed/jsr/JbedVideoPlayerState$Suspend;

    if-ne v0, v1, :cond_0

    .line 135
    const/4 v0, 0x2

    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    goto :goto_3
.end method
