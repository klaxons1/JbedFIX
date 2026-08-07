.class Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$1;
.super Ljava/lang/Object;
.source "JbedShowInfoActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;)V
    .locals 0

    .prologue
    .line 40
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 42
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->finish()V

    .line 43
    return-void
.end method
