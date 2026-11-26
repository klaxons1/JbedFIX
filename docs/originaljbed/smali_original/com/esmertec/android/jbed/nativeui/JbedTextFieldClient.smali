.class public Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;
    }
.end annotation


# static fields
.field static final DEBUG:Z = false

.field private static final DEBUG_CALSIZEHINT:Z = false

.field private static INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient; = null

.field private static RESERVE_WIDTH:I = 0x0

.field static final TAG:Ljava/lang/String; = "NativeTextField"

.field private static focusId:I

.field private static mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;


# instance fields
.field private mClient:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field private mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

.field private mContainerView:Landroid/widget/AbsoluteLayout;

.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field private mMaxWidth:I

.field private mMutex:Ljava/lang/Object;

.field private mTextFieldMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Lcom/esmertec/android/jbed/nativeui/JbedEditText;",
            ">;"
        }
    .end annotation
.end field

.field private pendingFocusId:I


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 56
    const/4 v0, -0x1

    sput v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->focusId:I

    .line 62
    const/16 v0, 0x14

    sput v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->RESERVE_WIDTH:I

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;I)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "containerView"    # Landroid/widget/AbsoluteLayout;
    .param p3, "connection"    # Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .param p4, "maxWidth"    # I

    .prologue
    .line 92
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 42
    new-instance v1, Landroid/os/Handler;

    invoke-direct {v1}, Landroid/os/Handler;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mHandler:Landroid/os/Handler;

    .line 52
    new-instance v1, Ljava/lang/Object;

    invoke-direct {v1}, Ljava/lang/Object;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mMutex:Ljava/lang/Object;

    .line 54
    new-instance v1, Ljava/util/HashMap;

    invoke-direct {v1}, Ljava/util/HashMap;-><init>()V

    iput-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mTextFieldMap:Ljava/util/HashMap;

    .line 57
    const/4 v1, -0x1

    iput v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->pendingFocusId:I

    .line 65
    new-instance v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    invoke-direct {v1, p0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)V

    iput-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mClient:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    .line 93
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mContext:Landroid/content/Context;

    .line 94
    iput-object p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mContainerView:Landroid/widget/AbsoluteLayout;

    .line 95
    iput-object p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    .line 96
    iput p4, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mMaxWidth:I

    .line 98
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mClient:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;->setClient(Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 103
    return-void

    .line 99
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 100
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "fail to call setClient"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static synthetic access$1000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/lang/Object;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mMutex:Ljava/lang/Object;

    return-object v0
.end method

.method static synthetic access$200()Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .locals 1

    .prologue
    .line 32
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    return-object v0
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Ljava/util/HashMap;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mTextFieldMap:Ljava/util/HashMap;

    return-object v0
.end method

.method static synthetic access$500(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)Landroid/widget/AbsoluteLayout;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mContainerView:Landroid/widget/AbsoluteLayout;

    return-object v0
.end method

.method static synthetic access$600(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mMaxWidth:I

    return v0
.end method

.method static synthetic access$700()I
    .locals 1

    .prologue
    .line 32
    sget v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->focusId:I

    return v0
.end method

.method static synthetic access$702(I)I
    .locals 0
    .param p0, "x0"    # I

    .prologue
    .line 32
    sput p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->focusId:I

    return p0
.end method

.method static synthetic access$800(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;)I
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .prologue
    .line 32
    iget v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->pendingFocusId:I

    return v0
.end method

.method static synthetic access$802(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;I)I
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;
    .param p1, "x1"    # I

    .prologue
    .line 32
    iput p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->pendingFocusId:I

    return p1
.end method

.method static synthetic access$900()I
    .locals 1

    .prologue
    .line 32
    sget v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->RESERVE_WIDTH:I

    return v0
.end method

.method public static create(Lcom/esmertec/android/jbed/service/IJbedUiListener;Landroid/content/Context;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;I)Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;
    .locals 2
    .param p0, "listener"    # Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "nativeWidgetView"    # Landroid/widget/AbsoluteLayout;
    .param p3, "conn"    # Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;
    .param p4, "maxWidth"    # I

    .prologue
    .line 68
    sput-object p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mJbedUiListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .line 69
    if-nez p2, :cond_0

    .line 70
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "NativeTextField create  nativeWidgetView is null"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 71
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    if-nez v0, :cond_1

    .line 72
    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    invoke-direct {v0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;-><init>(Landroid/content/Context;Landroid/widget/AbsoluteLayout;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;I)V

    sput-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .line 74
    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    return-object v0
.end method

.method public static dispose()V
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 78
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 80
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    const/4 v2, 0x0

    invoke-interface {v1, v2}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;->setClient(Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 85
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mTextFieldMap:Ljava/util/HashMap;

    invoke-virtual {v1}, Ljava/util/HashMap;->clear()V

    .line 86
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->mContainerView:Landroid/widget/AbsoluteLayout;

    invoke-virtual {v1}, Landroid/widget/AbsoluteLayout;->removeAllViews()V

    .line 88
    sput-object v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient;

    .line 90
    :cond_0
    return-void

    .line 81
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 82
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "failed to call setClient"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method
