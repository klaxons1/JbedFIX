.class Lcom/esmertec/android/jbed/JbedSettings$1;
.super Ljava/lang/Thread;
.source "JbedSettings.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/JbedSettings;-><init>(Landroid/content/Context;Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/JbedSettings;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/JbedSettings;)V
    .locals 0

    .prologue
    .line 98
    iput-object p1, p0, Lcom/esmertec/android/jbed/JbedSettings$1;->this$0:Lcom/esmertec/android/jbed/JbedSettings;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 100
    iget-object v0, p0, Lcom/esmertec/android/jbed/JbedSettings$1;->this$0:Lcom/esmertec/android/jbed/JbedSettings;

    iget-object v1, p0, Lcom/esmertec/android/jbed/JbedSettings$1;->this$0:Lcom/esmertec/android/jbed/JbedSettings;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/JbedSettings;->getCertDeviceDir()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/esmertec/android/jbed/JbedSettings;->syncCerts(Ljava/lang/String;)V

    .line 101
    return-void
.end method
