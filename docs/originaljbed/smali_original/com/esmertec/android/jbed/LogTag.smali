.class public Lcom/esmertec/android/jbed/LogTag;
.super Ljava/lang/Object;
.source "LogTag.java"


# static fields
.field private static final AMSTAG:Ljava/lang/String; = "jbedams"

.field private static final APPTAG:Ljava/lang/String; = "jbedapp"

.field public static final DEBUG_AMS:Z = false

.field public static final DEBUG_APP:Z = false

.field public static final DEBUG_SERVICE:Z = false

.field private static final SEVICETAG:Ljava/lang/String; = "jbedservice"

.field private static sAmsDebug:Z

.field private static sAmsError:Z

.field private static sAmsVerbose:Z

.field private static sAmsWarning:Z

.field private static sAppDebug:Z

.field private static sAppVerbose:Z

.field private static sAppWarning:Z

.field private static sServiceDebug:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .prologue
    const/4 v1, 0x1

    const/4 v0, 0x0

    .line 24
    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsDebug:Z

    .line 26
    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsVerbose:Z

    .line 28
    sput-boolean v1, Lcom/esmertec/android/jbed/LogTag;->sAmsError:Z

    .line 30
    sput-boolean v1, Lcom/esmertec/android/jbed/LogTag;->sAmsWarning:Z

    .line 32
    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppDebug:Z

    .line 34
    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppVerbose:Z

    .line 36
    sput-boolean v1, Lcom/esmertec/android/jbed/LogTag;->sAppWarning:Z

    .line 38
    sput-boolean v1, Lcom/esmertec/android/jbed/LogTag;->sServiceDebug:Z

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 65
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsDebug:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 66
    :cond_0
    return-void
.end method

.method public static amsError(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 73
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsError:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 74
    :cond_0
    return-void
.end method

.method public static amsVerbose(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 69
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsVerbose:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    .line 70
    :cond_0
    return-void
.end method

.method public static amsWarning(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 77
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsWarning:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 78
    :cond_0
    return-void
.end method

.method public static appDebug(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 81
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppDebug:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 82
    :cond_0
    return-void
.end method

.method public static appVerbose(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 85
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppVerbose:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    .line 86
    :cond_0
    return-void
.end method

.method public static appWarning(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 89
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppWarning:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 90
    :cond_0
    return-void
.end method

.method public static queryLoggingLevel()V
    .locals 6

    .prologue
    const/4 v5, 0x5

    const/4 v4, 0x2

    const/4 v2, 0x3

    const-string v3, "jbedapp"

    const-string v1, "jbedams"

    .line 54
    const-string v0, "jbedams"

    invoke-static {v1, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsDebug:Z

    .line 55
    const-string v0, "jbedams"

    invoke-static {v1, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsVerbose:Z

    .line 56
    const-string v0, "jbedams"

    const/4 v0, 0x6

    invoke-static {v1, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsError:Z

    .line 57
    const-string v0, "jbedams"

    invoke-static {v1, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAmsWarning:Z

    .line 58
    const-string v0, "jbedapp"

    invoke-static {v3, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppDebug:Z

    .line 59
    const-string v0, "jbedapp"

    invoke-static {v3, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppVerbose:Z

    .line 60
    const-string v0, "jbedapp"

    invoke-static {v3, v5}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sAppWarning:Z

    .line 61
    const-string v0, "jbedservice"

    invoke-static {v0, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    sput-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sServiceDebug:Z

    .line 62
    return-void
.end method

.method public static serviceDebug(Ljava/lang/String;Ljava/lang/String;)V
    .locals 1
    .param p0, "tag"    # Ljava/lang/String;
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 93
    sget-boolean v0, Lcom/esmertec/android/jbed/LogTag;->sServiceDebug:Z

    if-eqz v0, :cond_0

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 94
    :cond_0
    return-void
.end method
