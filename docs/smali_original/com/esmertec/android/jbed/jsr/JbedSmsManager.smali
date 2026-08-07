.class public Lcom/esmertec/android/jbed/jsr/JbedSmsManager;
.super Landroid/content/BroadcastReceiver;
.source "JbedSmsManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender;,
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;,
        Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;
    }
.end annotation


# static fields
.field static final DEBUG:Z = false

.field static final ENC_8BIT_BIN:I = 0x1

.field static final ENC_ASCII:I = 0x3

.field static final ENC_GSM_7BIT:I = 0x0

.field static final ENC_UCS_2:I = 0x2

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager; = null

.field private static MESSAGE_SENT_ACTION:Ljava/lang/String; = null

.field private static NATIVE_CONTEXT_KEY:Ljava/lang/String; = null

.field static final TAG:Ljava/lang/String; = "JbedSmsManager"

.field private static receiverMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field private mContext:Landroid/content/Context;

.field private mHandler:Landroid/os/Handler;

.field mListeners:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 44
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    .line 50
    const-string v0, "jbed.intent.action.SMS.MESSAGE_SENT"

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->MESSAGE_SENT_ACTION:Ljava/lang/String;

    .line 53
    const-string v0, "nativeContext"

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->NATIVE_CONTEXT_KEY:Ljava/lang/String;

    return-void
.end method

.method public constructor <init>(Landroid/os/Handler;)V
    .locals 1
    .param p1, "handler"    # Landroid/os/Handler;

    .prologue
    .line 84
    invoke-direct {p0}, Landroid/content/BroadcastReceiver;-><init>()V

    .line 81
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mListeners:Ljava/util/List;

    .line 85
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mHandler:Landroid/os/Handler;

    .line 86
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    .line 87
    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;)Landroid/os/Handler;
    .locals 1
    .param p0, "x0"    # Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    .prologue
    .line 42
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100(Ljava/lang/String;IIIJ[B)V
    .locals 0
    .param p0, "x0"    # Ljava/lang/String;
    .param p1, "x1"    # I
    .param p2, "x2"    # I
    .param p3, "x3"    # I
    .param p4, "x4"    # J
    .param p6, "x5"    # [B

    .prologue
    .line 42
    invoke-static/range {p0 .. p6}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->nativeNotifyNewSms(Ljava/lang/String;IIIJ[B)V

    return-void
.end method

.method static synthetic access$200()Ljava/lang/String;
    .locals 1

    .prologue
    .line 42
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->MESSAGE_SENT_ACTION:Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$300()Ljava/lang/String;
    .locals 1

    .prologue
    .line 42
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->NATIVE_CONTEXT_KEY:Ljava/lang/String;

    return-object v0
.end method

.method static synthetic access$400(IZ)V
    .locals 0
    .param p0, "x0"    # I
    .param p1, "x1"    # Z

    .prologue
    .line 42
    invoke-static {p0, p1}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->nativeNotifySmsSendResult(IZ)V

    return-void
.end method

.method static synthetic access$500()Lcom/esmertec/android/jbed/jsr/JbedSmsManager;
    .locals 1

    .prologue
    .line 42
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    return-object v0
.end method

.method public static deregister(I)I
    .locals 3
    .param p0, "port"    # I

    .prologue
    .line 141
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 142
    const-string v0, "JbedSmsManager"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, " port "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " haven\'t been registered"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 143
    const/4 v0, -0x1

    .line 147
    .end local p0    # "port":I
    :goto_0
    return v0

    .line 146
    .restart local p0    # "port":I
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "port":I
    check-cast p0, Landroid/content/BroadcastReceiver;

    invoke-virtual {v0, p0}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 147
    const/4 v0, 0x0

    goto :goto_0
.end method

.method private static deregisterAll()V
    .locals 3

    .prologue
    .line 154
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-virtual {v1}, Ljava/util/HashMap;->values()Ljava/util/Collection;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .line 155
    .local v0, "receivers":Ljava/util/Iterator;, "Ljava/util/Iterator<Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;>;"
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 156
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v2, v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/content/BroadcastReceiver;

    invoke-virtual {v2, v1}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    goto :goto_0

    .line 158
    :cond_0
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-virtual {v1}, Ljava/util/HashMap;->clear()V

    .line 159
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    invoke-virtual {v1, v2}, Landroid/content/Context;->unregisterReceiver(Landroid/content/BroadcastReceiver;)V

    .line 160
    return-void
.end method

.method static getText([BI)Ljava/lang/String;
    .locals 5
    .param p0, "payload"    # [B
    .param p1, "type"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/UnsupportedEncodingException;
        }
    .end annotation

    .prologue
    .line 171
    const/4 v1, 0x0

    .line 172
    .local v1, "result":Ljava/lang/String;
    packed-switch p1, :pswitch_data_0

    .line 188
    new-instance v2, Ljava/lang/IllegalArgumentException;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "JbedSmsManager unsupport type = "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 178
    :pswitch_0
    :try_start_0
    new-instance v1, Ljava/lang/String;

    .end local v1    # "result":Ljava/lang/String;
    const-string v2, "utf-16be"

    invoke-direct {v1, p0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    .line 190
    .restart local v1    # "result":Ljava/lang/String;
    :goto_0
    :pswitch_1
    return-object v1

    .line 179
    .end local v1    # "result":Ljava/lang/String;
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 180
    .local v0, "e1":Ljava/io/UnsupportedEncodingException;
    new-instance v2, Ljava/io/UnsupportedEncodingException;

    invoke-direct {v2}, Ljava/io/UnsupportedEncodingException;-><init>()V

    throw v2

    .line 184
    .end local v0    # "e1":Ljava/io/UnsupportedEncodingException;
    .restart local v1    # "result":Ljava/lang/String;
    :pswitch_2
    new-instance v1, Ljava/lang/String;

    .end local v1    # "result":Ljava/lang/String;
    invoke-direct {v1, p0}, Ljava/lang/String;-><init>([B)V

    .line 185
    .restart local v1    # "result":Ljava/lang/String;
    goto :goto_0

    .line 172
    nop

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_0
        :pswitch_2
    .end packed-switch
.end method

.method private static native nativeNotifyNewSms(Ljava/lang/String;IIIJ[B)V
.end method

.method private static native nativeNotifySmsSendResult(IZ)V
.end method

.method public static register(I)I
    .locals 5
    .param p0, "port"    # I

    .prologue
    .line 121
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 122
    const-string v2, "JbedSmsManager"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, " have registered this port "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 123
    const/4 v2, -0x1

    .line 134
    :goto_0
    return v2

    .line 126
    :cond_0
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mHandler:Landroid/os/Handler;

    invoke-direct {v1, p0, v2}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;-><init>(ILandroid/os/Handler;)V

    .line 127
    .local v1, "receiver":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$SmsReceiver;
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->receiverMap:Ljava/util/HashMap;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-virtual {v2, v3, v1}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 129
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 130
    .local v0, "filter":Landroid/content/IntentFilter;
    const-string v2, "com.esmertec.android.jbed.action.PUSHSMS"

    invoke-virtual {v0, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 132
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v1, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 134
    const/4 v2, 0x0

    goto :goto_0
.end method

.method private static sendSms(ILjava/lang/String;I[BI)I
    .locals 11
    .param p0, "nativeContext"    # I
    .param p1, "dstAddr"    # Ljava/lang/String;
    .param p2, "dstPort"    # I
    .param p3, "payload"    # [B
    .param p4, "type"    # I
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/UnsupportedEncodingException;
        }
    .end annotation

    .prologue
    const/4 v10, 0x0

    const/4 v9, 0x0

    .line 200
    invoke-static {}, Landroid/telephony/gsm/SmsManager;->getDefault()Landroid/telephony/gsm/SmsManager;

    move-result-object v5

    .line 201
    .local v5, "smsManager":Landroid/telephony/gsm/SmsManager;
    invoke-static {p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->getText([BI)Ljava/lang/String;

    move-result-object v6

    .line 202
    .local v6, "text":Ljava/lang/String;
    new-instance v2, Landroid/content/Intent;

    sget-object v7, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->MESSAGE_SENT_ACTION:Ljava/lang/String;

    invoke-direct {v2, v7}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 203
    .local v2, "intent":Landroid/content/Intent;
    sget-object v7, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->NATIVE_CONTEXT_KEY:Ljava/lang/String;

    new-instance v8, Ljava/lang/Integer;

    invoke-direct {v8, p0}, Ljava/lang/Integer;-><init>(I)V

    invoke-virtual {v2, v7, v8}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/io/Serializable;)Landroid/content/Intent;

    .line 209
    if-nez v6, :cond_0

    .line 210
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;

    invoke-direct {v0, p1, p2, v10, p3}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$BinarySmsData;-><init>(Ljava/lang/String;ILjava/lang/String;[B)V

    .line 215
    .local v0, "data":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
    :goto_0
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->size()I

    move-result v3

    .line 216
    .local v3, "messageCount":I
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4, v3}, Ljava/util/ArrayList;-><init>(I)V

    .line 217
    .local v4, "sentIntents":Ljava/util/List;, "Ljava/util/List<Landroid/app/PendingIntent;>;"
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    if-ge v1, v3, :cond_1

    .line 218
    sget-object v7, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    iget-object v7, v7, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    invoke-static {v7, v9, v2, v9}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v7

    invoke-interface {v4, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 217
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 212
    .end local v0    # "data":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
    .end local v1    # "i":I
    .end local v3    # "messageCount":I
    .end local v4    # "sentIntents":Ljava/util/List;, "Ljava/util/List<Landroid/app/PendingIntent;>;"
    :cond_0
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;

    invoke-direct {v0, p1, p2, v10, v6}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$TextSmsData;-><init>(Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V

    .restart local v0    # "data":Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;
    goto :goto_0

    .line 221
    .restart local v1    # "i":I
    .restart local v3    # "messageCount":I
    .restart local v4    # "sentIntents":Ljava/util/List;, "Ljava/util/List<Landroid/app/PendingIntent;>;"
    :cond_1
    const/4 v7, 0x1

    if-ne v3, v7, :cond_2

    .line 223
    invoke-interface {v4, v9}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "nativeContext":I
    check-cast p0, Landroid/app/PendingIntent;

    invoke-virtual {v0, p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->sendSinglepartMessage(Landroid/app/PendingIntent;)V

    .line 229
    :goto_2
    return v9

    .line 226
    .restart local p0    # "nativeContext":I
    :cond_2
    invoke-virtual {v0, v4}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$JbedSmsSender$SmsData;->sendMultipartMessage(Ljava/util/List;)V

    goto :goto_2
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 90
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mContext:Landroid/content/Context;

    .line 92
    new-instance v0, Landroid/content/IntentFilter;

    invoke-direct {v0}, Landroid/content/IntentFilter;-><init>()V

    .line 93
    .local v0, "filter":Landroid/content/IntentFilter;
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->MESSAGE_SENT_ACTION:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 94
    invoke-virtual {p1, p0, v0}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;)Landroid/content/Intent;

    .line 96
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mListeners:Ljava/util/List;

    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;)V

    invoke-interface {v1, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 109
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 112
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->deregisterAll()V

    .line 113
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mListeners:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 114
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    .line 115
    return-void
.end method

.method public onReceive(Landroid/content/Context;Landroid/content/Intent;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "intent"    # Landroid/content/Intent;

    .prologue
    .line 234
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->mHandler:Landroid/os/Handler;

    const/4 v2, 0x3

    invoke-virtual {v1, v2}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v0

    .line 235
    .local v0, "msg":Landroid/os/Message;
    new-instance v1, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;

    invoke-direct {v1, p0, p2}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$2;-><init>(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;Landroid/content/Intent;)V

    iput-object v1, v0, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 247
    invoke-virtual {v0}, Landroid/os/Message;->sendToTarget()V

    .line 248
    return-void
.end method
