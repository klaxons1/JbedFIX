.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunningMidletManagerEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "RunningMidletManagerEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1221
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 1224
    new-instance v0, Landroid/content/Intent;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunningMidletManagerEventHandler;->mContext:Landroid/content/Context;

    const-class v2, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 1227
    .local v0, "taskManagerIntent":Landroid/content/Intent;
    iget-object p0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunningMidletManagerEventHandler;->mContext:Landroid/content/Context;

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunningMidletManagerEventHandler;
    check-cast p0, Landroid/app/Activity;

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V

    .line 1228
    return-void
.end method
