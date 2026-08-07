.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;
.super Landroid/os/Handler;
.source "RunningMidletManagerActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V
    .locals 0

    .prologue
    .line 88
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 6
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const-string v5, "RunningActivity"

    .line 91
    iget v4, p1, Landroid/os/Message;->what:I

    sparse-switch v4, :sswitch_data_0

    .line 158
    const-string v4, "RunningActivity"

    const/4 v4, 0x6

    invoke-static {v5, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_0

    const-string v4, "RunningActivity"

    const-string v4, "RunningManagerHandler received un-recognized message "

    invoke-static {v5, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 161
    :cond_0
    :goto_0
    return-void

    .line 94
    :sswitch_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v4}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    .line 95
    .local v0, "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    if-eqz v0, :cond_0

    .line 98
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getRunningMidletList()Ljava/util/List;

    move-result-object v3

    .line 137
    .local v3, "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    invoke-interface {v3}, Ljava/util/List;->size()I

    move-result v4

    if-nez v4, :cond_1

    .line 138
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    const/4 v5, 0x2

    invoke-virtual {v4, v5}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->setResult(I)V

    .line 140
    :cond_1
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v4, v3}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$100(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Ljava/util/List;)V

    goto :goto_0

    .line 144
    .end local v0    # "amsClient":Lcom/esmertec/android/jbed/ams/AmsClient;
    .end local v3    # "runningMidletList":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :sswitch_1
    const-string v4, "RunningActivity"

    const/4 v4, 0x5

    invoke-static {v5, v4}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v4

    if-eqz v4, :cond_0

    const-string v4, "RunningActivity"

    const-string v4, "WARNING: receive EVENT_SERVICE_DISCONNECTED event"

    invoke-static {v5, v4}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 147
    :sswitch_2
    new-instance v2, Landroid/content/Intent;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    const-class v5, Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {v2, v4, v5}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 149
    .local v2, "jbedIntent":Landroid/content/Intent;
    const/high16 v4, 0x4000000

    invoke-virtual {v2, v4}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 150
    iget-object v4, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v4, Ljava/lang/Boolean;

    invoke-virtual {v4}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1

    .line 151
    .local v1, "isFullScreen":Z
    const-string v4, "isFullScreen"

    invoke-virtual {v2, v4, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 152
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v4, v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->startActivity(Landroid/content/Intent;)V

    .line 155
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$1;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->finish()V

    goto :goto_0

    .line 91
    nop

    :sswitch_data_0
    .sparse-switch
        0x2710 -> :sswitch_2
        0x271f -> :sswitch_0
        0x182b9 -> :sswitch_0
        0x182ba -> :sswitch_1
    .end sparse-switch
.end method
