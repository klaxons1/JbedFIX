.class Lcom/esmertec/android/jbed/app/JbedAppActivity$1;
.super Landroid/os/Handler;
.source "JbedAppActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/app/JbedAppActivity;
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
    .line 80
    iput-object p1, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 9
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const-wide/16 v5, 0x190

    const/4 v3, 0x1

    const-string v8, "root"

    const-string v7, "no"

    const-string v4, "JbedAppActivity"

    .line 83
    iget v2, p1, Landroid/os/Message;->what:I

    sparse-switch v2, :sswitch_data_0

    .line 171
    const-string v2, "JbedAppActivity"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "WARNING: unhandled event "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p1, Landroid/os/Message;->what:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 173
    :goto_0
    return-void

    .line 85
    :sswitch_0
    const-string v2, "JbedAppActivity"

    const-string v2, "get EVENT_SERVICE_CONNECTED from JbedApp"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 86
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$000(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    move-result-object v2

    if-eqz v2, :cond_1

    .line 87
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$100(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 88
    const-string v2, "JbedAppActivity"

    const-string v2, "......setStartWay......from home and fullscreen"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 89
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$200(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView;

    move-result-object v2

    invoke-virtual {v2, v3}, Lcom/esmertec/android/jbed/app/JbedView;->setStartWay(Z)V

    .line 91
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$000(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView$Callback;

    move-result-object v2

    invoke-interface {v2}, Lcom/esmertec/android/jbed/app/JbedView$Callback;->onServiceConnected()V

    goto :goto_0

    .line 94
    :cond_1
    const-string v2, "JbedAppActivity"

    const-string v2, "WARNING: mJbedViewCallback is null! failed to calback onConnected"

    invoke-static {v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 97
    :sswitch_1
    const-string v2, "JbedAppActivity"

    const-string v2, "WARNING: get EVENT_SERVICE_DISCONNECTED from JbedApp"

    invoke-static {v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 98
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->finish()V

    .line 103
    :sswitch_2
    new-instance v2, Lcom/esmertec/android/jbed/app/JbedAppActivity$1$1;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$1$1;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity$1;)V

    invoke-virtual {p0, v2, v5, v6}, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_0

    .line 112
    :sswitch_3
    const-string v2, "JbedAppActivity"

    const-string v2, "get EVENT_SURFACE_CREATED from JbedView"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 113
    invoke-static {}, Landroid/view/Surface;->openTransaction()V

    .line 114
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$200(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView;

    move-result-object v2

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedView;->getHolder()Landroid/view/SurfaceHolder;

    move-result-object v2

    invoke-interface {v2}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object v2

    const/16 v3, 0x3e9

    invoke-virtual {v2, v3}, Landroid/view/Surface;->setLayer(I)V

    .line 115
    invoke-static {}, Landroid/view/Surface;->closeTransaction()V

    goto :goto_0

    .line 118
    :sswitch_4
    const-string v2, "JbedAppActivity"

    const-string v2, "get EVENT_SURFACE_DESTROYED from JbedView"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 121
    :sswitch_5
    const-string v2, "JbedAppActivity"

    const-string v2, "get EVENT_ON_SERVICE_REQUEST_FINISH from JbedView"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 122
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->finish()V

    goto/16 :goto_0

    .line 125
    :sswitch_6
    const-string v2, "JbedAppActivity"

    const-string v2, "get EVENT_ON_VM_READY from JbedView"

    invoke-static {v4, v2}, Lcom/esmertec/android/jbed/LogTag;->appDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 127
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    .line 128
    .local v0, "homeIntent":Landroid/content/Intent;
    const-string v2, "root"

    invoke-virtual {v0, v8}, Landroid/content/Intent;->hasExtra(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2

    const-string v2, "no"

    invoke-virtual {v0, v7}, Landroid/content/Intent;->hasExtra(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 129
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$200(Lcom/esmertec/android/jbed/app/JbedAppActivity;)Lcom/esmertec/android/jbed/app/JbedView;

    move-result-object v2

    const-string v3, "root"

    invoke-virtual {v0, v8}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "no"

    const/4 v4, 0x0

    invoke-virtual {v0, v7, v4}, Landroid/content/Intent;->getIntExtra(Ljava/lang/String;I)I

    move-result v4

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/app/JbedView;->runMidlet(Ljava/lang/String;I)V

    goto/16 :goto_0

    .line 135
    :cond_2
    new-instance v2, Lcom/esmertec/android/jbed/app/JbedAppActivity$1$2;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/app/JbedAppActivity$1$2;-><init>(Lcom/esmertec/android/jbed/app/JbedAppActivity$1;)V

    invoke-virtual {p0, v2, v5, v6}, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->postDelayed(Ljava/lang/Runnable;J)Z

    goto/16 :goto_0

    .line 160
    .end local v0    # "homeIntent":Landroid/content/Intent;
    :sswitch_7
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->access$300(Lcom/esmertec/android/jbed/app/JbedAppActivity;Z)V

    goto/16 :goto_0

    .line 165
    :sswitch_8
    new-instance v1, Landroid/content/Intent;

    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    const-class v3, Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 166
    .local v1, "jbedIntent":Landroid/content/Intent;
    const/16 v2, 0x2726

    invoke-virtual {v1, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 167
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v2, v1}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->startActivity(Landroid/content/Intent;)V

    .line 168
    iget-object v2, p0, Lcom/esmertec/android/jbed/app/JbedAppActivity$1;->this$0:Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/app/JbedAppActivity;->finish()V

    goto/16 :goto_0

    .line 83
    :sswitch_data_0
    .sparse-switch
        0x271d -> :sswitch_2
        0x2726 -> :sswitch_8
        0x2727 -> :sswitch_7
        0x182b9 -> :sswitch_0
        0x182ba -> :sswitch_1
        0x1d4c0 -> :sswitch_3
        0x1d4c1 -> :sswitch_4
        0x1d4c2 -> :sswitch_5
        0x1d4c3 -> :sswitch_6
    .end sparse-switch
.end method
