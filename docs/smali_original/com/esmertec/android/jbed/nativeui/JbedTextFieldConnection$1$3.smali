.class Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;
.super Ljava/lang/Object;
.source "JbedTextFieldConnection.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->requestRefresh(I)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

.field final synthetic val$id:I


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;I)V
    .locals 0

    .prologue
    .line 70
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    iput p2, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;->val$id:I

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    .prologue
    .line 72
    iget-object v0, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;->this$1:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;

    iget-object v0, v0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;

    iget v1, p0, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection$1$3;->val$id:I

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;->access$400(Lcom/esmertec/android/jbed/nativeui/JbedTextFieldConnection;I)V

    .line 73
    return-void
.end method
