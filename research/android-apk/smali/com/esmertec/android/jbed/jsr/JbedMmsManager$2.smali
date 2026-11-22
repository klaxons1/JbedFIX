.class Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;
.super Ljava/lang/Object;
.source "JbedMmsManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->notifyNewMessage(Z)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

.field final synthetic val$isPush:Z


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMmsManager;Z)V
    .locals 0

    .prologue
    .line 557
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMmsManager;

    iput-boolean p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;->val$isPush:Z

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 559
    const-string v0, "-----------notifyNewMessage() have new message--------- "

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->access$000(Ljava/lang/String;)V

    .line 560
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMmsManager$2;->val$isPush:Z

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMmsManager;->access$300(Z)V

    .line 561
    return-void
.end method
