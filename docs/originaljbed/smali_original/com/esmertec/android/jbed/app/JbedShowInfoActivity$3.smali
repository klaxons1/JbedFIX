.class Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;
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
    .line 50
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 52
    new-instance v0, Landroid/content/Intent;

    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    const-class v2, Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {v0, v1, v2}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 53
    .local v0, "amsIntent":Landroid/content/Intent;
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v1, v0}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->startActivity(Landroid/content/Intent;)V

    .line 54
    iget-object v1, p0, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity$3;->this$0:Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/app/JbedShowInfoActivity;->finish()V

    .line 55
    return-void
.end method
