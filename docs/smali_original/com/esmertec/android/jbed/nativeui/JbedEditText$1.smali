.class Lcom/esmertec/android/jbed/nativeui/JbedEditText$1;
.super Ljava/lang/Object;
.source "JbedEditText.java"

# interfaces
.implements Landroid/text/InputFilter;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/nativeui/JbedEditText;->setUneditable()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/nativeui/JbedEditText;)V
    .locals 0

    .prologue
    .line 71
    iput-object p1, p0, Lcom/esmertec/android/jbed/nativeui/JbedEditText$1;->this$0:Lcom/esmertec/android/jbed/nativeui/JbedEditText;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public filter(Ljava/lang/CharSequence;IILandroid/text/Spanned;II)Ljava/lang/CharSequence;
    .locals 2
    .param p1, "src"    # Ljava/lang/CharSequence;
    .param p2, "start"    # I
    .param p3, "end"    # I
    .param p4, "dst"    # Landroid/text/Spanned;
    .param p5, "dstart"    # I
    .param p6, "dend"    # I

    .prologue
    .line 74
    invoke-interface {p1}, Ljava/lang/CharSequence;->length()I

    move-result v0

    const/4 v1, 0x1

    if-ge v0, v1, :cond_0

    invoke-interface {p4, p5, p6}, Landroid/text/Spanned;->subSequence(II)Ljava/lang/CharSequence;

    move-result-object v0

    :goto_0
    return-object v0

    :cond_0
    const-string v0, ""

    goto :goto_0
.end method
