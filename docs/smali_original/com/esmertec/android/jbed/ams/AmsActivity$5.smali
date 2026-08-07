.class Lcom/esmertec/android/jbed/ams/AmsActivity$5;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Landroid/view/View$OnKeyListener;


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
    .line 289
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onKey(Landroid/view/View;ILandroid/view/KeyEvent;)Z
    .locals 3
    .param p1, "v"    # Landroid/view/View;
    .param p2, "keyCode"    # I
    .param p3, "event"    # Landroid/view/KeyEvent;

    .prologue
    const-string v2, "123"

    .line 292
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigForAdamEnable()Z

    move-result v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-virtual {p3}, Landroid/view/KeyEvent;->getAction()I

    move-result v0

    if-nez v0, :cond_2

    const/16 v0, 0x1b

    if-eq p2, v0, :cond_0

    const/16 v0, 0x42

    if-ne p2, v0, :cond_2

    .line 295
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$900(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/lang/StringBuffer;

    move-result-object v0

    const-string v1, "123"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 296
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->openOptionsMenu()V

    .line 320
    :cond_1
    const/4 v0, 0x0

    :goto_0
    return v0

    .line 297
    :cond_2
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-virtual {p3}, Landroid/view/KeyEvent;->getAction()I

    move-result v0

    if-nez v0, :cond_1

    .line 298
    packed-switch p2, :pswitch_data_0

    .line 315
    :goto_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$900(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/lang/StringBuffer;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "123"

    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 316
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->openOptionsMenu()V

    .line 317
    const/4 v0, 0x1

    goto :goto_0

    .line 309
    :pswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$900(Lcom/esmertec/android/jbed/ams/AmsActivity;)Ljava/lang/StringBuffer;

    move-result-object v0

    const/4 v1, 0x7

    sub-int v1, p2, v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(I)Ljava/lang/StringBuffer;

    goto :goto_1

    .line 298
    nop

    :pswitch_data_0
    .packed-switch 0x7
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
    .end packed-switch
.end method
