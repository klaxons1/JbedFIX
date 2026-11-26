.class public Lcom/esmertec/android/jbed/PushJbedAlarmManager;
.super Landroid/content/BroadcastReceiver;
.source "PushJbedAlarmManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# static fields
.field private static final DEBUG:Z = false

.field private static INSTANCE:Lcom/esmertec/android/jbed/PushJbedAlarmManager; = null

.field private static final SCHEMA_ALARM:Ljava/lang/String; = "alarm"

.field static final TAG:Ljava/lang/String; = "PushJbedAlarmManager"

.field private static mContext:Landroid/content/Context;


# instance fields
.field private mPort:I


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 42
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    .line 43
    sput-object p0, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->INSTANCE:Lcom/esmertec/android/jbed/PushJbedAlarmManager;

    .line 45
    return-void
.end method

.method public static checkAndstartAlarm(Landroid/content/Context;)V
    .locals 2
    .param p0, "context"    # Landroid/content/Context;

    .prologue
    const/4 v1, 0x0

    .line 82
    sput-object p0, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->mContext:Landroid/content/Context;

    .line 83
    const-string v0, "alarm"

    invoke-static {v0, v1, v1}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->checkPushSchemaAndPorts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z

    .line 84
    return-void
.end method

.method public static checkPushSchemaAndPorts(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z
    .locals 8
    .param p0, "schema"    # Ljava/lang/String;
    .param p1, "port"    # Ljava/lang/String;
    .param p2, "param1"    # Ljava/lang/String;

    .prologue
    .line 114
    const/4 v0, 0x0

    .line 115
    .local v0, "isMatch":Z
    new-instance v5, Ljava/util/Scanner;

    invoke-static {}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->getPushListText()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v5, v6}, Ljava/util/Scanner;-><init>(Ljava/lang/String;)V

    .line 116
    .local v5, "s":Ljava/util/Scanner;
    const-string v6, "P(\\w+)://:?([\\d|\\w]*),(.*?),.*"

    invoke-static {v6}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v4

    .line 117
    .local v4, "p":Ljava/util/regex/Pattern;
    :cond_0
    :goto_0
    invoke-virtual {v5, v4}, Ljava/util/Scanner;->hasNext(Ljava/util/regex/Pattern;)Z

    move-result v6

    if-eqz v6, :cond_1

    .line 118
    invoke-virtual {v5, v4}, Ljava/util/Scanner;->next(Ljava/util/regex/Pattern;)Ljava/lang/String;

    .line 119
    invoke-virtual {v5}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x1

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v3

    .line 120
    .local v3, "mSchema":Ljava/lang/String;
    invoke-virtual {v5}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x2

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v2

    .line 121
    .local v2, "mPort":Ljava/lang/String;
    invoke-virtual {v5}, Ljava/util/Scanner;->match()Ljava/util/regex/MatchResult;

    move-result-object v6

    const/4 v7, 0x3

    invoke-interface {v6, v7}, Ljava/util/regex/MatchResult;->group(I)Ljava/lang/String;

    move-result-object v1

    .line 125
    .local v1, "mParam1":Ljava/lang/String;
    invoke-virtual {p0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_0

    .line 126
    const/4 v0, 0x1

    .line 127
    invoke-static {v1}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->startAlarm(Ljava/lang/String;)V

    goto :goto_0

    .line 131
    .end local v1    # "mParam1":Ljava/lang/String;
    .end local v2    # "mPort":Ljava/lang/String;
    .end local v3    # "mSchema":Ljava/lang/String;
    :cond_1
    return v0
.end method

.method private static getPushListText()Ljava/lang/String;
    .locals 6

    .prologue
    .line 88
    const-string v2, "/data/data/com.esmertec.android.jbed/Installed/pushlist.txt"

    .line 89
    .local v2, "fileName":Ljava/lang/String;
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 90
    .local v1, "file":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_0

    .line 93
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v3

    long-to-int v3, v3

    new-array v0, v3, [B

    .line 95
    .local v0, "data":[B
    :try_start_0
    new-instance v3, Ljava/io/FileInputStream;

    invoke-direct {v3, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {v3, v0}, Ljava/io/FileInputStream;->read([B)I

    .line 96
    new-instance v3, Ljava/lang/String;

    invoke-direct {v3, v0}, Ljava/lang/String;-><init>([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 102
    .end local v0    # "data":[B
    :goto_0
    return-object v3

    .line 97
    .restart local v0    # "data":[B
    :catch_0
    move-exception v3

    .line 101
    .end local v0    # "data":[B
    :cond_0
    const-string v3, "PushJbedAlarmManager"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Have no push information at "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Lcom/esmertec/android/jbed/LogTag;->serviceDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 102
    const-string v3, ""

    goto :goto_0
.end method

.method public static startAlarm(Ljava/lang/String;)V
    .locals 12
    .param p0, "mAlarmParam1"    # Ljava/lang/String;

    .prologue
    const/4 v11, 0x0

    .line 62
    sget-object v9, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->mContext:Landroid/content/Context;

    const-string v10, "alarm"

    invoke-virtual {v9, v10}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/AlarmManager;

    .line 63
    .local v0, "alarmManager":Landroid/app/AlarmManager;
    new-instance v3, Landroid/content/Intent;

    const-string v9, "com.esmertec.android.jbed.action.PUSHALARM"

    invoke-direct {v3, v9}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 64
    .local v3, "intent":Landroid/content/Intent;
    sget-object v9, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->mContext:Landroid/content/Context;

    invoke-static {v9, v11, v3, v11}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v6

    .line 66
    .local v6, "sender":Landroid/app/PendingIntent;
    const/16 v9, 0x10

    invoke-static {p0, v9}, Ljava/lang/Long;->parseLong(Ljava/lang/String;I)J

    move-result-wide v4

    .line 69
    .local v4, "launchTime":J
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v9

    sub-long v1, v4, v9

    .line 70
    .local v1, "delayMillis":J
    const-wide/16 v9, 0x0

    cmp-long v9, v1, v9

    if-gez v9, :cond_0

    .line 71
    const-wide/16 v1, 0x0

    .line 74
    :cond_0
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v9

    add-long v7, v9, v1

    .line 77
    .local v7, "wakeupTime":J
    const/4 v9, 0x3

    invoke-virtual {v0, v9, v7, v8, v6}, Landroid/app/AlarmManager;->set(IJLandroid/app/PendingIntent;)V

    .line 78
    return-void
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 0
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 49
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 53
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->INSTANCE:Lcom/esmertec/android/jbed/PushJbedAlarmManager;

    .line 56
    invoke-static {p1}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->checkAndstartAlarm(Landroid/content/Context;)V

    .line 57
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 7
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 139
    invoke-virtual {p2}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v0

    .line 141
    .local v0, "action":Ljava/lang/String;
    const-string v4, "com.esmertec.android.jbed.action.PUSHALARM"

    invoke-virtual {v0, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 144
    new-instance v3, Landroid/content/Intent;

    invoke-direct {v3}, Landroid/content/Intent;-><init>()V

    .line 145
    .local v3, "serviceIntent":Landroid/content/Intent;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, ".service.JbedService"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 146
    invoke-virtual {p0, p1, v3}, Lcom/esmertec/android/jbed/PushJbedAlarmManager;->peekService(Landroid/content/Context;Landroid/content/Intent;)Landroid/os/IBinder;

    move-result-object v1

    .line 147
    .local v1, "binder":Landroid/os/IBinder;
    const-string v4, "PushJbedAlarmManager"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "binder="

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 148
    if-nez v1, :cond_0

    .line 149
    new-instance v2, Landroid/content/Intent;

    invoke-direct {v2}, Landroid/content/Intent;-><init>()V

    .line 150
    .local v2, "jbedIntent":Landroid/content/Intent;
    const-string v4, "com.esmertec.android.jbed"

    const-string v5, "com.esmertec.android.jbed.app.JbedAppActivity"

    invoke-virtual {v2, v4, v5}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 151
    const/high16 v4, 0x10000000

    invoke-virtual {v2, v4}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 152
    invoke-virtual {p1, v2}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 155
    .end local v1    # "binder":Landroid/os/IBinder;
    .end local v2    # "jbedIntent":Landroid/content/Intent;
    .end local v3    # "serviceIntent":Landroid/content/Intent;
    :cond_0
    return-void
.end method
