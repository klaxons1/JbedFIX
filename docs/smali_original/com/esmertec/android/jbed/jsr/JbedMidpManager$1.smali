.class Lcom/esmertec/android/jbed/jsr/JbedMidpManager$1;
.super Landroid/database/ContentObserver;
.source "JbedMidpManager.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedMidpManager;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;Landroid/os/Handler;)V
    .locals 0
    .param p2, "x0"    # Landroid/os/Handler;

    .prologue
    .line 67
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-direct {p0, p2}, Landroid/database/ContentObserver;-><init>(Landroid/os/Handler;)V

    return-void
.end method


# virtual methods
.method public onChange(Z)V
    .locals 1
    .param p1, "selfChange"    # Z

    .prologue
    .line 71
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMidpManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedMidpManager;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMidpManager;->access$000(Lcom/esmertec/android/jbed/jsr/JbedMidpManager;)V

    .line 72
    return-void
.end method
