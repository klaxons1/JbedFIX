.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;
.super Ljava/lang/Object;
.source "JbedTextFieldConnection.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->onTextChanged(ILjava/lang/String;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

.field final synthetic val$id:I

.field final synthetic val$text:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;ILjava/lang/String;)V
    .locals 0

    .prologue
    .line 60
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->val$id:I

    iput-object p3, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->val$text:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 62
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->val$id:I

    iget-object v2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$2;->val$text:Ljava/lang/String;

    invoke-static {v0, v1, v2}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$300(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;ILjava/lang/String;)V

    .line 63
    return-void
.end method
