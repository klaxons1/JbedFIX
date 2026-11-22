.class Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;
.super Ljava/lang/Object;
.source "JbedMediaManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;->onPrepared(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;

.field final synthetic val$mp:Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;)V
    .locals 0

    .prologue
    .line 162
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;->this$1:Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2;

    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;->val$mp:Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 164
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$2$2;->val$mp:Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;

    invoke-interface {v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager$Playable;->getNativeContext()I

    move-result v0

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedMediaManager;->access$600(I)V

    .line 165
    return-void
.end method
