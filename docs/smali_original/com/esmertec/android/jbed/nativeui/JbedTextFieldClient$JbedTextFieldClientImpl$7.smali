.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;
.super Ljava/lang/Object;
.source "JbedTextFieldClient.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;->setClip(IIIII)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

.field final synthetic val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V
    .locals 0

    .prologue
    .line 273
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl;

    iput-object p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 275
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldClient$JbedTextFieldClientImpl$7;->val$textField:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/nativeui/JbedEditText;->invalidate()V

    .line 276
    return-void
.end method
