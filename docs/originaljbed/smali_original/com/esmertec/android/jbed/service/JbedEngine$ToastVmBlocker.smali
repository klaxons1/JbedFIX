.class Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;
.super Ljava/lang/Object;
.source "JbedEngine.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/service/JbedEngine;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "ToastVmBlocker"
.end annotation


# static fields
.field private static final DURATION_SECOND:I = 0x3

.field private static final INTERVAL_MILSECOND:I = 0x3e8

.field private static final MODULE_PROJECT:I = 0x6

.field private static final STRING_ID:I = 0x16

.field private static final VM_BLOCK_MILSECOND:I = 0xdac


# instance fields
.field private mDurationSecond:I

.field private mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V
    .locals 1
    .param p1, "engine"    # Lcom/esmertec/android/jbed/service/JbedEngine;

    .prologue
    .line 213
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 209
    const/4 v0, 0x3

    iput v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mDurationSecond:I

    .line 214
    iput-object p1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    .line 215
    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/service/JbedEngine;Lcom/esmertec/android/jbed/service/JbedEngine$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine;
    .param p2, "x1"    # Lcom/esmertec/android/jbed/service/JbedEngine$1;

    .prologue
    .line 201
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine;)V

    return-void
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    .prologue
    .line 201
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mDurationSecond:I

    return v0
.end method

.method static synthetic access$810(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)I
    .locals 2
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    .prologue
    .line 201
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mDurationSecond:I

    const/4 v1, 0x1

    sub-int v1, v0, v1

    iput v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mDurationSecond:I

    return v0
.end method

.method static synthetic access$900(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)Lcom/esmertec/android/jbed/service/JbedEngine;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;

    .prologue
    .line 201
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    return-object v0
.end method

.method private requestBlockVm()V
    .locals 2

    .prologue
    .line 247
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$000(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 248
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$000(Lcom/esmertec/android/jbed/service/JbedEngine;)Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;

    move-result-object v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;->access$1000(Lcom/esmertec/android/jbed/service/JbedEngine$JbedThread;)Ljava/util/concurrent/BlockingQueue;

    move-result-object v0

    new-instance v1, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$2;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$2;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;)V

    invoke-interface {v0, v1}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 259
    :cond_0
    return-void
.end method

.method private showMessage()V
    .locals 4

    .prologue
    .line 223
    iget-object v1, p0, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->mEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-static {v1}, Lcom/esmertec/android/jbed/service/JbedEngine;->access$700(Lcom/esmertec/android/jbed/service/JbedEngine;)Landroid/content/Context;

    move-result-object v1

    const-string v2, ""

    const/4 v3, 0x1

    invoke-static {v1, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    .line 224
    .local v0, "toast":Landroid/widget/Toast;
    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 225
    new-instance v1, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;

    invoke-direct {v1, p0, v0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;-><init>(Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;Landroid/widget/Toast;)V

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker$1;->start()V

    .line 244
    return-void
.end method


# virtual methods
.method public run()V
    .locals 0

    .prologue
    .line 218
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->showMessage()V

    .line 219
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedEngine$ToastVmBlocker;->requestBlockVm()V

    .line 220
    return-void
.end method
