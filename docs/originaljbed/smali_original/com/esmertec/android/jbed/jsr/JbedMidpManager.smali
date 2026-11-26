.class public Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
.super Ljava/lang/Object;
.source "JbedMidpManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;
.implements Lcom/esmertec/android/jbed/JbedConstants;


# static fields
.field static final synthetic $assertionsDisabled:Z

.field private static final ACTION_PHONE_STATE_CHANGED:Ljava/lang/String; = "android.intent.action.PHONE_STATE"

.field private static final DEBUG:Z = false

.field private static I18N_GETSTRINGID:Ljava/lang/reflect/Method; = null

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager; = null

.field private static final JBED_HTTP_PASSWORD:Ljava/lang/String; = "com.sun.midp.io.http.proxy.password"

.field private static final JBED_HTTP_PROXY:Ljava/lang/String; = "com.sun.midp.io.http.proxy"

.field private static final JBED_HTTP_USER:Ljava/lang/String; = "com.sun.midp.io.http.proxy.login"

.field private static final JBED_USER_AGENT:Ljava/lang/String; = "microedition.ua.default"

.field private static final TAG:Ljava/lang/String; = "JbedMidpManager"

.field static final UNKNOWN_STRING:Ljava/lang/String; = "<unknown>"


# instance fields
.field private apnObserver:Landroid/database/ContentObserver;

.field private mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

.field public final mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field private mIncomingCallReceiver:Landroid/content/BroadcastReceiver;

.field private mVibrator:Landroid/os/Vibrator;

.field private mVmStartedReceiver:Landroid/content/BroadcastReceiver;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 41
    const-class v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->$assertionsDisabled:Z

    .line 79
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeInitialization()V

    .line 80
    return-void

    .line 41
    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 2
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 82
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 67
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$1;

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mHandler:Landroid/os/Handler;

    invoke-direct {v0, p0, v1}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;Landroid/os/Handler;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->apnObserver:Landroid/database/ContentObserver;

    .line 108
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVmStartedReceiver:Landroid/content/BroadcastReceiver;

    .line 119
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$3;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mClientChangedListener:Lcom/esmertec/android/jbed/service/JbedService$ClientChangedListener;

    .line 194
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$4;-><init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mIncomingCallReceiver:Landroid/content/BroadcastReceiver;

    .line 83
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mHandler:Landroid/os/Handler;

    .line 84
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .line 85
    new-instance v0, Landroid/os/Vibrator;

    invoke-direct {v0}, Landroid/os/Vibrator;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVibrator:Landroid/os/Vibrator;

    .line 86
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .prologue
    .line 41
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->setJbedHttpProxy()V

    return-void
.end method

.method static synthetic access$100(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .prologue
    .line 41
    invoke-direct {p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->setJbedUserAgent()V

    return-void
.end method

.method static synthetic access$202(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
    .param p1, "x1"    # Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    .prologue
    .line 41
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mClient:Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    return-object p1
.end method

.method static synthetic access$300(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .prologue
    .line 41
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$400(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)Landroid/content/Context;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .prologue
    .line 41
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mContext:Landroid/content/Context;

    return-object v0
.end method

.method static getIntentActionByUrl(Ljava/lang/String;)Ljava/lang/String;
    .locals 7
    .param p0, "url"    # Ljava/lang/String;

    .prologue
    .line 229
    sget-boolean v4, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->$assertionsDisabled:Z

    if-nez v4, :cond_0

    if-nez p0, :cond_0

    new-instance v4, Ljava/lang/AssertionError;

    invoke-direct {v4}, Ljava/lang/AssertionError;-><init>()V

    throw v4

    .line 230
    :cond_0
    const/4 v3, 0x0

    .line 232
    .local v3, "uri":Landroid/net/Uri;
    :try_start_0
    invoke-static {p0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v3

    .line 238
    const/4 v1, 0x0

    .line 239
    .local v1, "intentAction":Ljava/lang/String;
    invoke-virtual {v3}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v2

    .line 240
    .local v2, "scheme":Ljava/lang/String;
    const-string v4, "http"

    invoke-virtual {v4, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    const-string v4, "https"

    invoke-virtual {v4, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_3

    .line 241
    :cond_1
    const-string v1, "android.intent.action.VIEW"

    :cond_2
    :goto_0
    move-object v4, v1

    .line 245
    .end local v1    # "intentAction":Ljava/lang/String;
    .end local v2    # "scheme":Ljava/lang/String;
    :goto_1
    return-object v4

    .line 233
    :catch_0
    move-exception v0

    .line 234
    .local v0, "e":Ljava/lang/Exception;
    const-string v4, "JbedMidpManager"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Throw exception when call parse(). url = "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 235
    const/4 v4, 0x0

    goto :goto_1

    .line 242
    .end local v0    # "e":Ljava/lang/Exception;
    .restart local v1    # "intentAction":Ljava/lang/String;
    .restart local v2    # "scheme":Ljava/lang/String;
    :cond_3
    const-string v4, "tel"

    invoke-virtual {v4, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_2

    .line 243
    const-string v1, "android.intent.action.CALL"

    goto :goto_0
.end method

.method public static getLocaleString()Ljava/lang/String;
    .locals 3

    .prologue
    .line 311
    invoke-static {}, Ljava/util/Locale;->getDefault()Ljava/util/Locale;

    move-result-object v0

    .line 312
    .local v0, "defLocale":Ljava/util/Locale;
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0}, Ljava/util/Locale;->getLanguage()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "-"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v0}, Ljava/util/Locale;->getCountry()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method public static getString(II)Ljava/lang/String;
    .locals 11
    .param p0, "mouduleId"    # I
    .param p1, "jbedId"    # I

    .prologue
    const-string v10, "JbedMidpManager"

    .line 285
    const/4 v4, -0x1

    .line 287
    .local v4, "retId":I
    :try_start_0
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->I18N_GETSTRINGID:Ljava/lang/reflect/Method;

    if-nez v5, :cond_0

    .line 288
    const-string v5, "com.esmertec.android.jbed.util.I18N"

    invoke-static {v5}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    .line 289
    .local v1, "i18n":Ljava/lang/Class;
    const-string v5, "getStringID"

    const/4 v6, 0x2

    new-array v6, v6, [Ljava/lang/Class;

    const/4 v7, 0x0

    sget-object v8, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v8, v6, v7

    const/4 v7, 0x1

    sget-object v8, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v8, v6, v7

    invoke-virtual {v1, v5, v6}, Ljava/lang/Class;->getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v5

    sput-object v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->I18N_GETSTRINGID:Ljava/lang/reflect/Method;

    .line 291
    .end local v1    # "i18n":Ljava/lang/Class;
    :cond_0
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->I18N_GETSTRINGID:Ljava/lang/reflect/Method;

    const/4 v6, 0x0

    const/4 v7, 0x2

    new-array v7, v7, [Ljava/lang/Object;

    const/4 v8, 0x0

    new-instance v9, Ljava/lang/Integer;

    invoke-direct {v9, p0}, Ljava/lang/Integer;-><init>(I)V

    aput-object v9, v7, v8

    const/4 v8, 0x1

    new-instance v9, Ljava/lang/Integer;

    invoke-direct {v9, p1}, Ljava/lang/Integer;-><init>(I)V

    aput-object v9, v7, v8

    invoke-virtual {v5, v6, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    .line 292
    .local v3, "retIDObj":Ljava/lang/Integer;
    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result v4

    .line 296
    .end local v3    # "retIDObj":Ljava/lang/Integer;
    :goto_0
    const/4 v5, -0x1

    if-ne v4, v5, :cond_1

    .line 297
    const-string v5, "JbedMidpManager"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "ERROR: i18n,fail to get string  mouduleId = "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "  jbedId = "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v10, v5}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 298
    const-string v5, "<unknown>"

    .line 303
    :goto_1
    return-object v5

    .line 293
    :catch_0
    move-exception v5

    move-object v0, v5

    .line 294
    .local v0, "e":Ljava/lang/Exception;
    const-string v5, "JbedMidpManager"

    const-string v5, "ERROR: can\'t invoke method I18N.getStringID"

    invoke-static {v10, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 302
    .end local v0    # "e":Ljava/lang/Exception;
    :cond_1
    sget-object v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    iget-object v5, v5, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mContext:Landroid/content/Context;

    invoke-virtual {v5}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v2

    .line 303
    .local v2, "resources":Landroid/content/res/Resources;
    invoke-virtual {v2, v4}, Landroid/content/res/Resources;->getString(I)Ljava/lang/String;

    move-result-object v5

    const-string v6, "$s"

    const-string v7, ""

    invoke-virtual {v5, v6, v7}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v5

    goto :goto_1
.end method

.method private static native nativeInitialization()V
.end method

.method private static platformRequest(Ljava/lang/String;)I
    .locals 5
    .param p0, "url"    # Ljava/lang/String;

    .prologue
    .line 253
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getIntentActionByUrl(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 254
    .local v1, "intentAction":Ljava/lang/String;
    if-eqz v1, :cond_0

    .line 255
    new-instance v0, Landroid/content/Intent;

    invoke-static {p0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v2

    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 257
    .local v0, "intent":Landroid/content/Intent;
    const/high16 v2, 0x10000000

    invoke-virtual {v0, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 258
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 259
    const/4 v2, 0x0

    .line 262
    .end local v0    # "intent":Landroid/content/Intent;
    :goto_0
    return v2

    .line 261
    :cond_0
    const-string v2, "JbedMidpManager"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "ERROR: fail to call platformRequest(). url = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 262
    const/4 v2, -0x1

    goto :goto_0
.end method

.method private setJbedHttpProxy()V
    .locals 15

    .prologue
    const/4 v2, 0x0

    .line 148
    const-string v0, "content://telephony/carriers/preferapn"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v1

    .line 149
    .local v1, "PREFERAPN_URI":Landroid/net/Uri;
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "numeric=\""

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, "gsm.sim.operator.numeric"

    const-string v5, ""

    invoke-static {v4, v5}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, "\""

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 150
    .local v3, "where":Ljava/lang/String;
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mContext:Landroid/content/Context;

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v5, "name ASC"

    move-object v4, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v7

    .line 152
    .local v7, "cursor":Landroid/database/Cursor;
    if-nez v7, :cond_0

    .line 153
    const-string v0, "JbedMidpManager"

    const-string v2, "ERROR:-----------setJbedHttpProxy failed to get the apn information"

    invoke-static {v0, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 192
    :goto_0
    return-void

    .line 156
    :cond_0
    invoke-interface {v7}, Landroid/database/Cursor;->moveToFirst()Z

    .line 158
    invoke-interface {v7}, Landroid/database/Cursor;->isAfterLast()Z

    move-result v0

    if-nez v0, :cond_4

    .line 161
    const-string v0, "name"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v8

    .line 162
    .local v8, "name":Ljava/lang/String;
    const-string v0, "apn"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v6

    .line 163
    .local v6, "apn":Ljava/lang/String;
    const-string v0, "proxy"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v11

    .line 164
    .local v11, "proxy":Ljava/lang/String;
    const-string v0, "port"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v10

    .line 165
    .local v10, "port":Ljava/lang/String;
    const-string v0, "type"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v13

    .line 166
    .local v13, "type":Ljava/lang/String;
    const-string v0, "user"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v14

    .line 167
    .local v14, "user":Ljava/lang/String;
    const-string v0, "password"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v9

    .line 171
    .local v9, "password":Ljava/lang/String;
    const-string v12, ""

    .line 172
    .local v12, "proxyAndPort":Ljava/lang/String;
    if-eqz v11, :cond_1

    invoke-virtual {v11}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    if-eqz v0, :cond_1

    .line 173
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, ":"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v12

    .line 176
    :cond_1
    const-string v0, "com.sun.midp.io.http.proxy"

    invoke-virtual {p0, v0, v12}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 183
    if-eqz v14, :cond_2

    .line 184
    const-string v0, "com.sun.midp.io.http.proxy.login"

    invoke-virtual {p0, v0, v14}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 186
    :cond_2
    if-eqz v9, :cond_3

    .line 187
    const-string v0, "com.sun.midp.io.http.proxy.password"

    invoke-virtual {p0, v0, v9}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 189
    :cond_3
    invoke-interface {v7}, Landroid/database/Cursor;->moveToNext()Z

    .line 191
    .end local v6    # "apn":Ljava/lang/String;
    .end local v8    # "name":Ljava/lang/String;
    .end local v9    # "password":Ljava/lang/String;
    .end local v10    # "port":Ljava/lang/String;
    .end local v11    # "proxy":Ljava/lang/String;
    .end local v12    # "proxyAndPort":Ljava/lang/String;
    .end local v13    # "type":Ljava/lang/String;
    .end local v14    # "user":Ljava/lang/String;
    :cond_4
    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    goto/16 :goto_0
.end method

.method private setJbedUserAgent()V
    .locals 2

    .prologue
    .line 135
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getUserAgent()Ljava/lang/String;

    move-result-object v0

    .line 136
    .local v0, "agentStr":Ljava/lang/String;
    if-eqz v0, :cond_0

    .line 137
    const-string v1, "microedition.ua.default"

    invoke-virtual {p0, v1, v0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 139
    :cond_0
    return-void
.end method

.method static setVibrate(Z)V
    .locals 3
    .param p0, "isVibrate"    # Z

    .prologue
    .line 270
    if-eqz p0, :cond_0

    .line 271
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVibrator:Landroid/os/Vibrator;

    const-wide v1, 0x757b12c00L

    invoke-virtual {v0, v1, v2}, Landroid/os/Vibrator;->vibrate(J)V

    .line 275
    :goto_0
    return-void

    .line 273
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVibrator:Landroid/os/Vibrator;

    invoke-virtual {v0}, Landroid/os/Vibrator;->cancel()V

    goto :goto_0
.end method

.method public static updateLocale()V
    .locals 3

    .prologue
    .line 316
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->getLocaleString()Ljava/lang/String;

    move-result-object v0

    .line 317
    .local v0, "localStr":Ljava/lang/String;
    if-eqz v0, :cond_0

    .line 318
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    const-string v2, "microedition.locale"

    invoke-virtual {v1, v2, v0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 320
    :cond_0
    return-void
.end method


# virtual methods
.method public native nativeSetJbedProperty(Ljava/lang/String;Ljava/lang/String;)V
.end method

.method public onCreate(Landroid/content/Context;)V
    .locals 6
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 89
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mContext:Landroid/content/Context;

    .line 90
    new-instance v0, Landroid/content/IntentFilter;

    const-string v2, "android.intent.action.PHONE_STATE"

    invoke-direct {v0, v2}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 91
    .local v0, "incomingCallFilter":Landroid/content/IntentFilter;
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mIncomingCallReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v2, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 93
    new-instance v1, Landroid/content/IntentFilter;

    const-string v2, "com.esmertec.android.jbed.action.VMSTARTED"

    invoke-direct {v1, v2}, Landroid/content/IntentFilter;-><init>(Ljava/lang/String;)V

    .line 94
    .local v1, "vmStartFilter":Landroid/content/IntentFilter;
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVmStartedReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v2, v1}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 96
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v2

    sget-object v3, Landroid/provider/Telephony$Carriers;->CONTENT_URI:Landroid/net/Uri;

    const/4 v4, 0x1

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->apnObserver:Landroid/database/ContentObserver;

    invoke-virtual {v2, v3, v4, v5}, Landroid/content/ContentResolver;->registerContentObserver(Landroid/net/Uri;ZLandroid/database/ContentObserver;)V

    .line 98
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 101
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    .line 102
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mIncomingCallReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 103
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->mVmStartedReceiver:Landroid/content/BroadcastReceiver;

    invoke-virtual {p1, v0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 105
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->apnObserver:Landroid/database/ContentObserver;

    invoke-virtual {v0, v1}, Landroid/content/ContentResolver;->unregisterContentObserver(Landroid/database/ContentObserver;)V

    .line 106
    return-void
.end method
