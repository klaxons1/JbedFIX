.class Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;
.super Ljava/lang/Object;
.source "JbedSmsManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedSmsManager$NewMessageListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->onCreate(Landroid/content/Context;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;)V
    .locals 0

    .prologue
    .line 96
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public notifyNewSms(Ljava/lang/String;IIIJ[B)V
    .locals 10
    .param p1, "srcAddr"    # Ljava/lang/String;
    .param p2, "srcPort"    # I
    .param p3, "dstPort"    # I
    .param p4, "encoding"    # I
    .param p5, "timestamp"    # J
    .param p7, "payload"    # [B

    .prologue
    .line 99
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedSmsManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedSmsManager;)Landroid/os/Handler;

    move-result-object v0

    const/4 v1, 0x3

    invoke-virtual {v0, v1}, Landroid/os/Handler;->obtainMessage(I)Landroid/os/Message;

    move-result-object v9

    .line 100
    .local v9, "msg":Landroid/os/Message;
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1$1;

    move-object v1, p0

    move-object v2, p1

    move v3, p2

    move v4, p3

    move v5, p4

    move-wide v6, p5

    move-object/from16 v8, p7

    invoke-direct/range {v0 .. v8}, Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1$1;-><init>(Lcom/esmertec/android/jbed/jsr/JbedSmsManager$1;Ljava/lang/String;IIIJ[B)V

    iput-object v0, v9, Landroid/os/Message;->obj:Ljava/lang/Object;

    .line 105
    invoke-virtual {v9}, Landroid/os/Message;->sendToTarget()V

    .line 106
    return-void
.end method
