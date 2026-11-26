.class Lcom/esmertec/android/jbed/app/JbedAppActivity$5;
.super Ljava/lang/Object;
.source "JbedAppActivity.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/app/JbedAppActivity;->onPause()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V
    .locals 0

    .prologue
    .line 393
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .prologue
    .line 395
    iget-object v0, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$5;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$800(Lcom/esmertec/android/jbed/app/JbedAppActivity;)V

    .line 396
    return-void
.end method
