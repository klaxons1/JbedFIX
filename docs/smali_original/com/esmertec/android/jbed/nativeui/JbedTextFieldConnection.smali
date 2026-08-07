.class public Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
.super Ljava/lang/Object;
.source "JbedTextFieldConnection.java"


# static fields
.field private static final DEBUG:Z = false

.field private static final DEBUG_CALSIZEHINT:Z = false

.field public static INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection; = null

.field private static final TAG:Ljava/lang/String; = "JbedTextFieldConnection"

.field private static mIdCounter:I


# instance fields
.field private mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

.field public mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

.field private mHandler:Landroid/os/Handler;


# direct methods
.method public constructor <init>()V
    .locals 1

    .prologue
    .line 80
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 40
    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    .line 81
    sput-object p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .line 82
    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 1
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 35
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 40
    new-instance v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;-><init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mConnection:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldConnection;

    .line 36
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mHandler:Landroid/os/Handler;

    .line 37
    sput-object p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .line 38
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .prologue
    .line 19
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    return-object v0
.end method

.method static synthetic access$002(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;)Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    .prologue
    .line 19
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    return-object p1
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .prologue
    .line 19
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .prologue
    .line 19
    invoke-direct {p0}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->notifyTextFieldClientAttached()V

    return-void
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;ILjava/lang/String;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
    .param p1, "x1"    # I
    .param p2, "x2"    # Ljava/lang/String;

    .prologue
    .line 19
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->notifyTextFieldTextChanged(ILjava/lang/String;)V

    return-void
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;
    .param p1, "x1"    # I

    .prologue
    .line 19
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->notifyRefreshTextField(I)V

    return-void
.end method

.method private static calculateSizeHints(III[I)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "widthHint"    # I
    .param p2, "heightHint"    # I
    .param p3, "data"    # [I

    .prologue
    .line 143
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-nez v1, :cond_0

    .line 144
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    monitor-enter v1

    .line 147
    :try_start_0
    sget-object v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-virtual {v2}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 150
    :goto_0
    :try_start_1
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 152
    :cond_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_1

    .line 154
    :try_start_2
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1, p2, p3}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->calculateSizeHints(III[I)V
    :try_end_2
    .catch Landroid/os/RemoteException; {:try_start_2 .. :try_end_2} :catch_0

    .line 160
    :cond_1
    return-void

    .line 150
    :catchall_0
    move-exception v2

    :try_start_3
    monitor-exit v1
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v2

    .line 156
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 157
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call calculateSizeHints"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 148
    .end local v0    # "e":Landroid/os/RemoteException;
    :catch_1
    move-exception v2

    goto :goto_0
.end method

.method private static create(I)I
    .locals 5
    .param p0, "mask"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Landroid/os/DeadObjectException;
        }
    .end annotation

    .prologue
    .line 94
    sget-object v2, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    monitor-enter v2

    .line 95
    :try_start_0
    sget-object v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v3, v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-nez v3, :cond_0

    .line 96
    const/4 v3, -0x1

    monitor-exit v2

    move v2, v3

    .line 104
    :goto_0
    return v2

    .line 98
    :cond_0
    sget v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mIdCounter:I

    add-int/lit8 v4, v3, 0x1

    sput v4, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mIdCounter:I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    or-int v1, p0, v3

    .line 100
    .local v1, "id":I
    :try_start_1
    sget-object v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v3, v3, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v3, v1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->create(I)V
    :try_end_1
    .catch Landroid/os/RemoteException; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 104
    :try_start_2
    monitor-exit v2

    move v2, v1

    goto :goto_0

    .line 101
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 102
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v3, Ljava/lang/RuntimeException;

    const-string v4, "JbedTextFieldConnection fail to call create"

    invoke-direct {v3, v4}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v3

    .line 105
    .end local v0    # "e":Landroid/os/RemoteException;
    .end local v1    # "id":I
    :catchall_0
    move-exception v3

    monitor-exit v2
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v3
.end method

.method private static dispose(I)V
    .locals 3
    .param p0, "id"    # I

    .prologue
    .line 113
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 115
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->dispose(I)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 120
    :cond_0
    return-void

    .line 116
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 117
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call destroy"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private static getCaretPosition(I)I
    .locals 3
    .param p0, "id"    # I

    .prologue
    .line 266
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 268
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->getCaretPosition(I)I
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    move-result v1

    .line 274
    :goto_0
    return v1

    .line 269
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 270
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call getCaretPosition"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 273
    .end local v0    # "e":Landroid/os/RemoteException;
    :cond_0
    const-string v1, "JbedTextFieldConnection"

    const-string v2, "getCaretPosition return -1"

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 274
    const/4 v1, -0x1

    goto :goto_0
.end method

.method private native notifyRefreshTextField(I)V
.end method

.method private native notifyTextFieldClientAttached()V
.end method

.method private native notifyTextFieldTextChanged(ILjava/lang/String;)V
.end method

.method private static replaceText(IIILjava/lang/String;)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "offset"    # I
    .param p2, "len"    # I
    .param p3, "text"    # Ljava/lang/String;

    .prologue
    .line 223
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 225
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1, p2, p3}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->replaceText(IIILjava/lang/String;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 230
    :cond_0
    return-void

    .line 226
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 227
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call setFocus"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private static setClip(IIIII)V
    .locals 7
    .param p0, "id"    # I
    .param p1, "x"    # I
    .param p2, "y"    # I
    .param p3, "width"    # I
    .param p4, "height"    # I

    .prologue
    .line 195
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v0, :cond_0

    .line 197
    :try_start_0
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    move v1, p0

    move v2, p1

    move v3, p2

    move v4, p3

    move v5, p4

    invoke-interface/range {v0 .. v5}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setClip(IIIII)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 202
    :cond_0
    return-void

    .line 198
    :catch_0
    move-exception v0

    move-object v6, v0

    .line 199
    .local v6, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "JbedTextFieldConnection fail to call setClip"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static setConstraints(II)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "constraints"    # I

    .prologue
    .line 237
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 239
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setConstraints(II)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 244
    :cond_0
    return-void

    .line 240
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 241
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call setCosntraints"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private static setFocus(IZ)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "hasFocus"    # Z

    .prologue
    .line 209
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 211
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setFocus(IZ)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 216
    :cond_0
    return-void

    .line 212
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 213
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call setFocus"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private static setMaxSize(II)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "maxSize"    # I

    .prologue
    .line 251
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 253
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setMaxSize(II)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 258
    :cond_0
    return-void

    .line 254
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 255
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call setMaxSize"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method private static setPosition(IIIIIZI)V
    .locals 9
    .param p0, "id"    # I
    .param p1, "x"    # I
    .param p2, "y"    # I
    .param p3, "width"    # I
    .param p4, "height"    # I
    .param p5, "isTextBox"    # Z
    .param p6, "maxScrollbarWidth"    # I

    .prologue
    .line 170
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-nez v0, :cond_0

    .line 171
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    monitor-enter v0

    .line 174
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    invoke-virtual {v1}, Ljava/lang/Object;->wait()V
    :try_end_0
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 177
    :goto_0
    :try_start_1
    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 179
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v0, :cond_1

    .line 181
    :try_start_2
    sget-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    move v1, p0

    move v2, p1

    move v3, p2

    move v4, p3

    move v5, p4

    move v6, p5

    move v7, p6

    invoke-interface/range {v0 .. v7}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setPosition(IIIIIZI)V
    :try_end_2
    .catch Landroid/os/RemoteException; {:try_start_2 .. :try_end_2} :catch_0

    .line 188
    :cond_1
    return-void

    .line 177
    :catchall_0
    move-exception v1

    :try_start_3
    monitor-exit v0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v1

    .line 183
    :catch_0
    move-exception v0

    move-object v8, v0

    .line 184
    .local v8, "e":Landroid/os/RemoteException;
    new-instance v0, Ljava/lang/RuntimeException;

    const-string v1, "JbedTextFieldConnection fail to call setPosition"

    invoke-direct {v0, v1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 175
    .end local v8    # "e":Landroid/os/RemoteException;
    :catch_1
    move-exception v1

    goto :goto_0
.end method

.method private static setText(ILjava/lang/String;)V
    .locals 3
    .param p0, "id"    # I
    .param p1, "text"    # Ljava/lang/String;

    .prologue
    .line 127
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    if-eqz v1, :cond_0

    .line 129
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget-object v1, v1, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->mClient:Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;

    invoke-interface {v1, p0, p1}, Lcom/esmertec/android/jbed/nativeui/IJbedTextFieldClient;->setText(ILjava/lang/String;)V
    :try_end_0
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_0} :catch_0

    .line 135
    :cond_0
    return-void

    .line 131
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 132
    .local v0, "e":Landroid/os/RemoteException;
    new-instance v1, Ljava/lang/RuntimeException;

    const-string v2, "JbedTextFieldConnection fail to call setText"

    invoke-direct {v1, v2}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v1
.end method


# virtual methods
.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 85
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->INSTANCE:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    .line 86
    return-void
.end method
