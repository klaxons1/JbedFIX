.class Lcom/esmertec/android/jbed/ams/AmsActivity$6;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0

    .prologue
    .line 326
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 328
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$6;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1000(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    .line 329
    return-void
.end method
