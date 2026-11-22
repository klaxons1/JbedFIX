.class public Lcom/esmertec/android/jbed/service/JbedService;
.super Landroid/app/Service;
.source "JbedService.java"

# interfaces
.implements Lcom/esmertec/android/jbed/JbedConstants;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;,
        Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;,
        Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;,
        Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    }
.end annotation


# static fields
.field public static final TAG:Ljava/lang/String; = "jbedservice"


# instance fields
.field public mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

.field private final mBinder:Lcom/esmertec/android/jbed/service/IJbedService$Stub;

.field private mClientChangedListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;",
            ">;"
        }
    .end annotation
.end field

.field private mIntentReceiver:Landroid/content/BroadcastReceiver;

.field private mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

.field private mLifecycleListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;",
            ">;"
        }
    .end annotation
.end field

.field private mOrientation:I

.field private mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;


# direct methods
.method static constructor <clinit>()V
    .locals 5

    .prologue
    const-string v4, "jbedvm"

    const-string v3, "jbedservice"

    .line 167
    const-string v1, "jbedservice"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "JNI search path is "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "java.library.path"

    invoke-static {v2}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 169
    const-string v1, "jbedservice"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "jbedvm becomes \'"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "jbedvm"

    invoke-static {v4}, Ljava/lang/System;->mapLibraryName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 172
    :try_start_0
    const-string v1, "jbedvm"

    invoke-static {v1}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/UnsatisfiedLinkError; {:try_start_0 .. :try_end_0} :catch_0

    .line 177
    :goto_0
    return-void

    .line 173
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 174
    .local v0, "ule":Ljava/lang/UnsatisfiedLinkError;
    const-string v1, "jbedservice"

    const-string v1, "WARNING: Could not load jbed native lib jbedvm"

    invoke-static {v3, v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method public constructor <init>()V
    .locals 1

    .prologue
    .line 58
    invoke-direct {p0}, Landroid/app/Service;-><init>()V

    .line 68
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    .line 70
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    .line 72
    const/4 v0, 0x0

    iput v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    .line 74
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedService$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedService$1;-><init>(Lcom/esmertec/android/jbed/service/JbedService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mBinder:Lcom/esmertec/android/jbed/service/IJbedService$Stub;

    .line 321
    new-instance v0, Lcom/esmertec/android/jbed/service/JbedService$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/service/JbedService$2;-><init>(Lcom/esmertec/android/jbed/service/JbedService;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mIntentReceiver:Landroid/content/BroadcastReceiver;

    .line 450
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/IJbedUiListener;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedService;

    .prologue
    .line 58
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    return-object v0
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/service/JbedService;)Lcom/esmertec/android/jbed/service/JbedEngine;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedService;

    .prologue
    .line 58
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    return-object v0
.end method

.method static synthetic access$200(Lcom/esmertec/android/jbed/service/JbedService;)Ljava/util/List;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/service/JbedService;

    .prologue
    .line 58
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    return-object v0
.end method

.method private initDisplayInfo()V
    .locals 7

    .prologue
    const-string v6, "jbedservice"

    const-string v5, ","

    .line 279
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/JbedService;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    .line 280
    .local v2, "res":Landroid/content/res/Resources;
    invoke-virtual {v2}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    .line 281
    .local v0, "config":Landroid/content/res/Configuration;
    new-instance v1, Landroid/util/DisplayMetrics;

    invoke-direct {v1}, Landroid/util/DisplayMetrics;-><init>()V

    .line 283
    .local v1, "metrics":Landroid/util/DisplayMetrics;
    invoke-virtual {v2}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v3

    iget v3, v3, Landroid/content/res/Configuration;->orientation:I

    iput v3, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    .line 284
    invoke-virtual {v2}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v1

    .line 285
    iget v3, v1, Landroid/util/DisplayMetrics;->densityDpi:I

    sput v3, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mDensityDpi:I

    .line 286
    const-string v3, "jbedservice"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "initDisplayMetrics() Metrics : W ,H, D = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    iget v4, v1, Landroid/util/DisplayMetrics;->widthPixels:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    iget v4, v1, Landroid/util/DisplayMetrics;->heightPixels:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    iget v4, v1, Landroid/util/DisplayMetrics;->densityDpi:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 309
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayLandscapeWidth()I

    move-result v3

    sput v3, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewWidth:I

    .line 310
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayLandscapeHeight()I

    move-result v3

    sput v3, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewHeight:I

    .line 311
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayPortraitWidth()I

    move-result v3

    sput v3, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewWidth:I

    .line 312
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayPortraitHeight()I

    move-result v3

    sput v3, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewHeight:I

    .line 315
    const-string v3, "jbedservice"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "initDisplayMetrics() : Land : "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    sget v4, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewWidth:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    sget v4, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewHeight:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ", Portrait : "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    sget v4, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewWidth:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ","

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    sget v4, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewHeight:I

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 319
    return-void
.end method


# virtual methods
.method public onBind(Landroid/content/Intent;)Landroid/os/IBinder;
    .locals 1
    .param p1, "intent"    # Landroid/content/Intent;

    .prologue
    .line 340
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mBinder:Lcom/esmertec/android/jbed/service/IJbedService$Stub;

    return-object v0
.end method

.method public onConfigurationChanged(Landroid/content/res/Configuration;)V
    .locals 7
    .param p1, "newConfig"    # Landroid/content/res/Configuration;

    .prologue
    .line 181
    invoke-super {p0, p1}, Landroid/app/Service;->onConfigurationChanged(Landroid/content/res/Configuration;)V

    .line 182
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/JbedService;->getResources()Landroid/content/res/Resources;

    move-result-object v3

    invoke-virtual {v3}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v3

    iget v3, v3, Landroid/content/res/Configuration;->orientation:I

    if-eq v0, v3, :cond_1

    .line 183
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/service/JbedService;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getConfiguration()Landroid/content/res/Configuration;

    move-result-object v0

    iget v0, v0, Landroid/content/res/Configuration;->orientation:I

    iput v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    .line 185
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getDisplayPortraitWidth()I

    move-result v0

    if-eqz v0, :cond_1

    .line 186
    const/4 v1, 0x0

    .line 187
    .local v1, "viewWidth":I
    const/4 v2, 0x0

    .line 188
    .local v2, "viewHeight":I
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    const/4 v3, 0x2

    if-ne v0, v3, :cond_2

    .line 189
    sget v1, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewWidth:I

    .line 190
    sget v2, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mLandscapeViewHeight:I

    .line 195
    :cond_0
    :goto_0
    new-instance v6, Landroid/graphics/PixelFormat;

    invoke-direct {v6}, Landroid/graphics/PixelFormat;-><init>()V

    .line 196
    .local v6, "pixFormat":Landroid/graphics/PixelFormat;
    const/4 v0, 0x4

    invoke-static {v0, v6}, Landroid/graphics/PixelFormat;->getPixelFormatInfo(ILandroid/graphics/PixelFormat;)V

    .line 197
    iget-object v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget v3, v6, Landroid/graphics/PixelFormat;->bytesPerPixel:I

    move v4, v1

    move v5, v2

    invoke-virtual/range {v0 .. v5}, Lcom/esmertec/android/jbed/service/JbedEngine;->changeScreenifVmBackground(IIIII)V

    .line 201
    .end local v1    # "viewWidth":I
    .end local v2    # "viewHeight":I
    .end local v6    # "pixFormat":Landroid/graphics/PixelFormat;
    :cond_1
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->updateLocale()V

    .line 202
    return-void

    .line 191
    .restart local v1    # "viewWidth":I
    .restart local v2    # "viewHeight":I
    :cond_2
    iget v0, p0, Lcom/esmertec/android/jbed/service/JbedService;->mOrientation:I

    const/4 v3, 0x1

    if-ne v0, v3, :cond_0

    .line 192
    sget v1, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewWidth:I

    .line 193
    sget v2, Lcom/esmertec/android/jbed/service/JbedService$DisplayInfo;->mPortraitViewHeight:I

    goto :goto_0
.end method

.method public onCreate()V
    .locals 11

    .prologue
    const/4 v10, 0x0

    .line 206
    invoke-super {p0}, Landroid/app/Service;->onCreate()V

    .line 217
    new-instance v7, Lcom/esmertec/android/jbed/service/JbedEngine;

    invoke-direct {v7, p0}, Lcom/esmertec/android/jbed/service/JbedEngine;-><init>(Landroid/app/Service;)V

    iput-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    .line 220
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    iget-object v8, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v8, v8, Lcom/esmertec/android/jbed/service/JbedEngine;->mLifecycleListener:Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 221
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v9, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v9, v9, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v8, v9}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;-><init>(Landroid/os/Handler;)V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 222
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iget-object v9, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v9, v9, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v8, v9}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;-><init>(Landroid/os/Handler;)V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 223
    new-instance v4, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;

    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v7, v7, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v4, v7}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;-><init>(Landroid/os/Handler;)V

    .line 224
    .local v4, "mediaManager":Lcom/esmertec/android/jbed/jsr/JbedMediaManager;
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v7, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 226
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    iget-object v9, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v9, v9, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v8, v9}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;-><init>(Landroid/os/Handler;)V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 227
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    invoke-direct {v8}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;-><init>()V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 228
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/PushJbedAlarmManager;

    invoke-direct {v8}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;-><init>()V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 233
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;

    iget-object v9, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v9, v9, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v8, v9}, Lcom/esmertec/android/jbed/jsr/JbedLapiManager;-><init>(Landroid/os/Handler;)V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 242
    new-instance v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v7, v7, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v5, v7}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;-><init>(Landroid/os/Handler;)V

    .line 243
    .local v5, "midpManager":Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v7, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 245
    new-instance v3, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;

    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v7, v7, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v3, v7}, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;-><init>(Landroid/os/Handler;)V

    .line 246
    .local v3, "lcduiManager":Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v7, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 249
    invoke-static {p0}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v6

    .line 250
    .local v6, "settings":Lcom/esmertec/android/jbed/JbedSettings;
    invoke-virtual {v6}, Lcom/esmertec/android/jbed/JbedSettings;->isNativeAms()Z

    move-result v7

    if-eqz v7, :cond_0

    .line 251
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    new-instance v8, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;

    invoke-direct {v8, p0}, Lcom/esmertec/android/jbed/ams/JbedSelector$SelectorObserverManager;-><init>(Landroid/content/Context;)V

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 254
    :cond_0
    new-instance v7, Lcom/esmertec/android/jbed/ams/AmsConnection;

    iget-object v8, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v8, v8, Lcom/esmertec/android/jbed/service/JbedEngine;->mHandler:Landroid/os/Handler;

    invoke-direct {v7, v8}, Lcom/esmertec/android/jbed/ams/AmsConnection;-><init>(Landroid/os/Handler;)V

    iput-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

    .line 255
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    iget-object v8, p0, Lcom/esmertec/android/jbed/service/JbedService;->mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 258
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    iget-object v8, p0, Lcom/esmertec/android/jbed/service/JbedService;->mJbedEngine:Lcom/esmertec/android/jbed/service/JbedEngine;

    iget-object v8, v8, Lcom/esmertec/android/jbed/service/JbedEngine;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 259
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    iget-object v8, v3, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 260
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    iget-object v8, v4, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 261
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    iget-object v8, p0, Lcom/esmertec/android/jbed/service/JbedService;->mAmsConnection:Lcom/esmertec/android/jbed/ams/AmsConnection;

    iget-object v8, v8, Lcom/esmertec/android/jbed/ams/AmsConnection;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 262
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mClientChangedListeners:Ljava/util/List;

    iget-object v8, v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    invoke-interface {v7, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 264
    iget-object v7, v3, Lcom/esmertec/android/jbed/jsr/JbedLcduiManager;->mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    iput-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mUiEventListener:Lcom/esmertec/android/jbed/service/IJbedUiListener;

    .line 266
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v7}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_1

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    .line 267
    .local v2, "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    invoke-interface {v2, p0}, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;->onCreate(Landroid/content/Context;)V

    goto :goto_0

    .line 270
    .end local v2    # "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    :cond_1
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 271
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v7, "android.intent.action.TIME_SET"

    invoke-virtual {v0, v7}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 272
    iget-object v7, p0, Lcom/esmertec/android/jbed/service/JbedService;->mIntentReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v7, v0, v10, v10}, Lcom/esmertec/android/jbed/service/JbedService;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Ljava/lang/String;Landroid/os/Handler;)Landroid/content/Intent;

    .line 274
    invoke-direct {p0}, Lcom/esmertec/android/jbed/service/JbedService;->initDisplayInfo()V

    .line 275
    return-void
.end method

.method public onDestroy()V
    .locals 3

    .prologue
    .line 330
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;

    .line 331
    .local v1, "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    invoke-interface {v1, p0}, Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;->onDestroy(Landroid/content/Context;)V

    goto :goto_0

    .line 333
    .end local v1    # "l":Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService;->mIntentReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/service/JbedService;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 334
    iget-object v2, p0, Lcom/esmertec/android/jbed/service/JbedService;->mLifecycleListeners:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->clear()V

    .line 335
    invoke-super {p0}, Landroid/app/Service;->onDestroy()V

    .line 336
    return-void
.end method
