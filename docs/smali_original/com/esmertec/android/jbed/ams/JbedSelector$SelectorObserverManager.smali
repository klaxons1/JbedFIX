.class public Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;
.super Ljava/lang/Object;
.source "JbedSelector.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/JbedSelector;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "SelectorObserverManager"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;
    }
.end annotation


# static fields
.field private static final REFRESH_DATA_MESSAGE:I


# instance fields
.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field private mObserver:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 154
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 134
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$1;-><init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mHandler:Landroid/os/Handler;

    .line 155
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mContext:Landroid/content/Context;

    .line 156
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;

    invoke-static {p1}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v1

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;-><init>(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mObserver:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;

    .line 157
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    .prologue
    .line 107
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    .prologue
    .line 107
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mContext:Landroid/content/Context;

    return-object v0
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 160
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mObserver:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->startWatching()V

    .line 161
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 164
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;->mObserver:Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager$SelectorObserver;->stopWatching()V

    .line 165
    return-void
.end method
